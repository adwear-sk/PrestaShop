#!/usr/bin/env bash
# One-shot triage for www.adwear.sk, run as deploy on the VPS:  /opt/adwear/diagnose.sh
# Strictly read-only: it kills, restarts, deletes and writes nothing (not even the
# healthcheck state files), so it is safe to run at any time, as often as you like.
#
# Each line starts with "ok", "--" (information) or "!!" (look at this). A "!!" line
# names the RUNBOOK.md card that handles it. Exit code: number of "!!" lines.
#
# This is the daily morning check until alerts leave the box, and the first thing to
# run when something looks wrong. Thresholds follow healthcheck.sh.
#
# Never prints secrets: MySQL is queried with the password the container already
# holds, and the admin folder name (this repo is public) is masked in every output.

set -uo pipefail

STACK_DIR=/opt/adwear
DOMAIN="${DOMAIN:-https://www.adwear.sk}"
DISK_ALERT_PCT=85
CONN_ALERT=70           # of max_connections 80, like healthcheck.sh
SLOW_QUERY_S=60         # a storefront query running this long means a backlog
CRAWL_ALERT=100         # ?q= requests Caddy let through in 10 minutes (2026-11-10 scraper: ~90)

cd "$STACK_DIR" || { echo "!! $STACK_DIR missing"; exit 1; }

RED=0
ok()   { printf 'ok  %s\n' "$*"; }
info() { printf '--  %s\n' "$*"; }
bad()  { printf '!!  %s\n' "$*"; RED=$((RED + 1)); }
head_() { printf '\n== %s\n' "$*"; }
mask() { sed -E 's#/admin[^ /"]*#/ADMIN#g'; }

# Runs SQL from stdin in the shop database as root, inside the mysql container.
# Root has one connection reserved beyond max_connections, so this works while the
# shop's connections are all taken.
sql() {
  timeout 20 docker compose exec -T mysql sh -c \
    'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --connect-timeout=5 -uroot -N -B "$MYSQL_DATABASE"' 2>/dev/null
}

http() { curl -s -o /dev/null -w '%{http_code} %{time_total}s' --max-time 20 "$1" 2>/dev/null; }

echo "adwear diagnose — $(date '+%Y-%m-%d %H:%M %Z')   host up $(uptime -p | sed 's/^up //')"

head_ "Containers"
for svc in caddy app mysql; do
  state=$(timeout 20 docker compose ps -a --format '{{.State}} {{.Status}}' "$svc" 2>/dev/null | head -1)
  case $state in
    running*) ok "$svc: $state" ;;
    *) bad "$svc: ${state:-missing}  → card 'Containers down'" ;;
  esac
done

head_ "Web"
for path in / /1002-vetrovky; do
  r=$(http "$DOMAIN$path")
  case $r in
    200*) ok "$path $r" ;;
    404*) bad "$path $r  → card 'Pages 404'" ;;
    *) bad "$path $r  → card 'Site down or slow'" ;;
  esac
done
# The admin folder name comes from the container and is never printed.
admin=$(timeout 20 docker compose exec -T app sh -c '
  for d in /var/www/html/admin*/; do
    grep -q _PS_ADMIN_DIR_ "$d/index.php" 2>/dev/null && { basename "$d"; exit 0; }
  done' 2>/dev/null | tr -d '\r\n')
if [ -z "$admin" ]; then
  bad "back office: admin folder not readable from the app container  → card 'Containers down'"
else
  r=$(http "$DOMAIN/$admin/login")
  case $r in 200*) ok "back office login $r" ;; *) bad "back office login $r  → card 'Back office 500, shop works'" ;; esac
fi

head_ "Server"
pct=$(df --output=pcent / | tail -1 | tr -dc 0-9)
avail=$(df -h --output=avail / | tail -1 | tr -d ' ')
if [ "$pct" -ge "$DISK_ALERT_PCT" ]; then bad "disk ${pct}% used, $avail free  → card 'Disk full'"; else ok "disk ${pct}% used, $avail free"; fi
read -r l1 l5 l15 _ < /proc/loadavg
cpus=$(nproc)
if awk -v l="$l5" -v c="$cpus" 'BEGIN { exit !(l > 4 * c) }'; then
  bad "load $l1 $l5 $l15 on $cpus CPUs  → card 'Site down or slow'"
else
  ok "load $l1 $l5 $l15 on $cpus CPUs"
fi
[ -f /var/run/reboot-required ] && info "kernel/library updates wait for a reboot (card 'After a reboot')"

head_ "MySQL"
status=$(sql <<'SQL'
SELECT 'conns', VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_connected'
UNION ALL SELECT 'running', VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_running'
UNION ALL SELECT 'max', @@max_connections
UNION ALL SELECT 'met', @@max_execution_time;
SQL
)
if [ -z "$status" ]; then
  bad "MySQL does not answer  → card 'Site down or slow' (or 'Disk full' if the disk is at 100%)"
else
  v() { printf '%s\n' "$status" | awk -v k="$1" '$1 == k {print $2}'; }
  conns=$(v conns); max=$(v max)
  if [ "${conns:-0}" -ge "$CONN_ALERT" ]; then
    bad "connections $conns of $max, $(v running) running  → card 'Site down or slow'"
  else
    ok "connections $conns of $max, $(v running) running"
  fi
  [ "$(v met)" = 120000 ] || bad "max_execution_time is $(v met) ms, expected 120000  → card 'After a reboot'"
  slow=$(sql <<SQL
SELECT time, LEFT(REPLACE(REPLACE(COALESCE(info, ''), '\n', ' '), '\t', ' '), 90)
FROM information_schema.processlist
WHERE command = 'Query' AND time >= $SLOW_QUERY_S AND info NOT LIKE '%information_schema.processlist%'
ORDER BY time DESC LIMIT 5;
SQL
)
  if [ -n "$slow" ]; then
    bad "queries running ${SLOW_QUERY_S}s or longer  → card 'Site down or slow':"
    printf '%s\n' "$slow" | mask | sed 's/^/      /'
  else
    ok "no query running ${SLOW_QUERY_S}s or longer"
  fi
  prefix=$(sed -n 's/^DB_PREFIX=//p' .env 2>/dev/null | tail -1)
  prefix=${prefix:-ps_}
  case $prefix in *[!A-Za-z0-9_]*) prefix=ps_ ;; esac
  sizes=$(sql <<SQL
SELECT table_name, ROUND((data_length + index_length) / 1048576)
FROM information_schema.tables WHERE table_schema = DATABASE()
ORDER BY data_length + index_length DESC LIMIT 3;
SELECT 'last order', COALESCE(TIMESTAMPDIFF(HOUR, MAX(date_add), NOW()), -1) FROM ${prefix}orders;
SQL
)
  printf '%s\n' "$sizes" | awk -F'\t' '$1 != "last order" && $1 != "" {printf "--  table %s %s MB\n", $1, $2}'
  last=$(printf '%s\n' "$sizes" | awk -F'\t' '$1 == "last order" {print $2}')
  [ -n "$last" ] && [ "$last" -ge 0 ] && info "last order ${last} h ago"
fi

head_ "Crawlers (Caddy log, last 10 minutes)"
if [ -r logs/caddy/access.log ]; then
  crawl=$(tail -n 50000 logs/caddy/access.log | awk -v since=$(($(date +%s) - 600)) '
    match($0, /"ts":[0-9.]+/) {
      if (substr($0, RSTART + 5, RLENGTH - 5) + 0 < since) next
      total++
      if (!match($0, /"uri":"[^"]*"/)) next
      if (substr($0, RSTART, RLENGTH) !~ /[?&]q=/) next
      q++
      ip = "?"
      if (match($0, /"client_ip":"[^"]*"/)) ip = substr($0, RSTART + 13, RLENGTH - 14)
      n[ip]++
      if (match($0, /"status":(403|429)[,}]/)) blocked++
    }
    END {
      printf "%d %d %d\n", total, q, blocked
      for (ip in n) printf "%d %s\n", n[ip], ip
    }')
  read -r total q blocked <<<"$(printf '%s\n' "$crawl" | head -1)"
  line="$total requests, $q filter (?q=) requests, $blocked of them blocked (403/429)"
  if [ $((q - blocked)) -ge "$CRAWL_ALERT" ]; then bad "$line  → card 'Site down or slow'"; else ok "$line"; fi
  printf '%s\n' "$crawl" | tail -n +2 | sort -rn | head -5 | awk '{printf "      %6d %s\n", $1, $2}'
else
  info "logs/caddy/access.log not readable"
fi

head_ "Syncs and nightly jobs (logs/.ok-* markers)"
now=$(date +%s)
for m in sync-stock:4 sync-anda-stock:4 sync-products:26 sync-prices:26 sync-anda-products:26 catalog-apply:26 prune-history:26; do
  name=${m%%:*}; max_h=${m##*:}; f=logs/.ok-$name
  if [ ! -e "$f" ]; then bad "$name: no marker yet  → card 'Sync stale'"; continue; fi
  age=$((now - $(stat -c %Y "$f"))); age_h=$((age / 3600))
  if [ "$age" -gt $((max_h * 3600)) ]; then bad "$name last succeeded ${age_h} h ago (limit ${max_h} h)  → card 'Sync stale'"; else ok "$name ${age_h} h ago"; fi
done
# A container compiled while MySQL was down has no module commands; the syncs then
# fail silently while the site stays 200 (2026-10-24, 10 days unnoticed). Skipped while
# MySQL is down: on an empty cache `list` would compile exactly that broken container.
for ns in adwear:malfini adwear:anda; do
  [ -n "$status" ] || { info "$ns: not checked while MySQL does not answer"; continue; }
  n=$(timeout 60 docker compose exec -T -u www-data app php bin/console list "$ns" --env=prod 2>/dev/null | grep -c " $ns:")
  if [ "$n" -gt 0 ]; then ok "$ns: $n commands"; else bad "$ns: no commands (container compiled without modules)  → card 'Sync stale'"; fi
done
b=$(ls -t backups/db-*.sql.gz 2>/dev/null | head -1)
if [ -z "$b" ]; then
  bad "no local DB dump in backups/  → card 'Data loss'"
else
  age_h=$(((now - $(stat -c %Y "$b")) / 3600))
  if [ "$age_h" -gt 26 ]; then bad "newest DB dump is ${age_h} h old  → card 'Data loss'"; else ok "newest DB dump ${age_h} h old ($(du -h "$b" | cut -f1))"; fi
fi

head_ "Healthcheck (every 5 min)"
failing=$(grep -l '^fail$' logs/.healthcheck.* 2>/dev/null | sed 's#.*/\.healthcheck\.##' | tr '\n' ' ')
if [ -n "$failing" ]; then bad "failing now: $failing (see the log tail)"; else ok "no check failing"; fi
tail -n 5 logs/cron-healthcheck.log 2>/dev/null | mask | sed 's/^/      /'

head_ "Releases (newest last)"
tail -n 2 logs/releases.log 2>/dev/null | sed 's/^/      /'

echo
if [ "$RED" -eq 0 ]; then echo "All green."; else echo "$RED line(s) marked !! — open deploy/RUNBOOK.md at the card named on each."; fi
exit "$RED"
