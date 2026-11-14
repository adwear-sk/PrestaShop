#!/usr/bin/env bash
# Back-office reachability check for www.adwear.sk, run from the deploy user's
# crontab every 5 minutes.
#
# Why this exists: the front office and the back office boot SEPARATE Symfony
# kernels with separate compiled containers, so the BO can be returning 500 on
# every single page while the homepage happily serves 200. That is not
# hypothetical — it is the normal shape of the failure here:
#   - 2026-08-09  .htaccess lost on a manual recreate -> ~2 weeks of 404s
#   - 2026-10-03  stale admin container pin -> BO 500 for ~4 days, unnoticed
# Nothing on this box watched the BO, and uptime checks aimed at the homepage
# cannot see any of it. So: check the BO login page explicitly.
#
# The check is deliberately dumb (is the login page 200?) because that single
# request exercises the whole admin stack: Apache -> mod_php -> AdminKernel ->
# compiled container -> routing -> Twig. Anything that breaks the compiled
# container breaks this.
#
# It also watches things that break with the site still looking fine:
#   - disk usage. On 2026-11-04 crawlers filled the disk through the facet cache
#     and binlogs, MySQL stopped committing and the whole shop 500'd for 13h.
#   - the Malfini and Anda syncs, via the logs/.ok-sync-* markers the crontab touches on
#     success. A container compiled while MySQL restarted on 2026-10-24 lost the
#     module's commands and the syncs failed for 10 days with the site at 200.
#     The nightly prune-history.sh touches logs/.ok-prune-history the same way.
#   - MySQL: reachable, connections below max_connections, and no burst of
#     queries killed at max_execution_time (the 2026-11-10 crawler outage held
#     every connection with 2-minute facet counts while the homepage was cached).
#
# Output goes to logs/cron-healthcheck.log. Failures are logged on every run so
# an ongoing outage is visible in the tail; recoveries are logged once.
#
# ALERT_URL: set it in /opt/adwear/.env to get alerts off this box, as a plain
# POST of the message text (an ntfy topic works as is). Sent once when a check
# fails and once when it recovers. Without it alerts only reach the log, which
# cannot be written when the disk is full. Whoever holds the URL reads the
# messages, so they must never contain the admin folder name.
#
# AUTO_RESTART: off by default. When set to 1, a confirmed failure triggers one
# `docker compose restart app` per cooldown window. That is the known-correct
# cure for the stale-container-pin failure (restart flushes OPcache; it keeps the
# container layer, so .htaccess and friendly URLs survive, unlike a recreate).
# Enable it by editing the live crontab entry to pass AUTO_RESTART=1.

set -uo pipefail

STACK_DIR=/opt/adwear
DOMAIN="${DOMAIN:-https://www.adwear.sk}"
STATE_FILE="$STACK_DIR/logs/.healthcheck.state"
RESTART_STAMP="$STACK_DIR/logs/.healthcheck.last-restart"
AUTO_RESTART="${AUTO_RESTART:-0}"
RESTART_COOLDOWN="${RESTART_COOLDOWN:-3600}"   # seconds between self-heal attempts
CURL_TIMEOUT=20
DISK_ALERT_PCT="${DISK_ALERT_PCT:-85}"
STOCK_MAX_AGE=$((4 * 3600))      # hourly, with the 23:30 UTC slot skipped
DAILY_MAX_AGE=$((26 * 3600))     # products and prices run once a day
CONN_ALERT="${CONN_ALERT:-70}"   # of max_connections 80 (release.sh)
CONN_OK="${CONN_OK:-60}"         # recovers below this
KILLED_ALERT="${KILLED_ALERT:-3}" # queries killed at 120 s between two runs

cd "$STACK_DIR" || exit 1

ALERT_URL="${ALERT_URL:-$(sed -n 's/^ALERT_URL=//p' .env 2>/dev/null)}"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S%z')" "$*"; }

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_TIMEOUT" "$1" 2>/dev/null; }

notify() {
  [ -n "$ALERT_URL" ] || return 0
  curl -s -o /dev/null --max-time 10 -d "adwear: $*" "$ALERT_URL" || log "WARN could not deliver alert"
}

# Logs and notifies only when a check changes state, so a stale sync does not
# repeat every 5 minutes.
track() {
  local state=$2 message=$3 file="$STACK_DIR/logs/.healthcheck.$1" prev
  prev=$(cat "$file" 2>/dev/null)
  printf '%s' "$state" > "$file"
  [ "$state" = "${prev:-ok}" ] && return
  if [ "$state" = fail ]; then
    log "ALERT $message"
    notify "ALERT $message"
  else
    log "RECOVERED $message"
    notify "RECOVERED $message"
  fi
}

check_disk() {
  local pct
  pct=$(df --output=pcent / | tail -1 | tr -dc 0-9)
  if [ "$pct" -ge "$DISK_ALERT_PCT" ]; then
    track disk fail "disk at ${pct}%"
  else
    track disk ok "disk at ${pct}%"
  fi
}

check_marker() {
  local name=$1 max_age=$2 marker="$STACK_DIR/logs/.ok-$1" age
  # No marker yet right after this check is installed: start the clock.
  [ -e "$marker" ] || touch "$marker"
  age=$(($(date +%s) - $(stat -c %Y "$marker")))
  if [ "$age" -gt "$max_age" ]; then
    track "$name" fail "$name has not succeeded for $((age / 3600))h"
  else
    track "$name" ok "$name succeeded"
  fi
}

# Status counters are cumulative since mysqld started, so compare them with the
# previous run's values (kept in a state file); a smaller value means mysqld
# restarted, and then the delta is the value itself.
mysql_status() {
  timeout 30 docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --connect-timeout=5 -uroot -N -B -e "SHOW GLOBAL STATUS WHERE Variable_name IN (\"Threads_connected\", \"Connection_errors_max_connections\", \"Max_execution_time_exceeded\")"' 2>/dev/null
}

# Prints the named counter, or 0 if it is missing or not a number, so a bad
# value can never stop the script before the back-office check.
counter() {
  local v
  v=$(printf '%s\n' "$1" | awk -v k="$2" '$1 == k {print $2}')
  case $v in ''|*[!0-9]*) echo 0 ;; *) echo "$v" ;; esac
}

check_mysql() {
  local status file="$STACK_DIR/logs/.healthcheck.mysql-counters" conns errors killed
  local prev_errors prev_killed d_errors d_killed
  # One retry, like the HTTP check: a deploy can briefly recreate the container.
  status=$(mysql_status) || { sleep 15; status=$(mysql_status); }
  if [ -z "$status" ]; then
    track mysql fail "MySQL does not answer (down, hung, or every connection taken)"
    return
  fi
  track mysql ok "MySQL answers"
  conns=$(counter "$status" Threads_connected)
  errors=$(counter "$status" Connection_errors_max_connections)
  killed=$(counter "$status" Max_execution_time_exceeded)

  # First run (or a lost file): record a baseline instead of alerting on
  # everything since mysqld started.
  if [ ! -r "$file" ]; then
    printf '%s %s\n' "$errors" "$killed" > "$file"
    return
  fi
  read -r prev_errors prev_killed < "$file"
  case $prev_errors in ''|*[!0-9]*) prev_errors=$errors ;; esac
  case $prev_killed in ''|*[!0-9]*) prev_killed=$killed ;; esac
  printf '%s %s\n' "$errors" "$killed" > "$file"
  d_errors=$((errors >= prev_errors ? errors - prev_errors : errors))
  d_killed=$((killed >= prev_killed ? killed - prev_killed : killed))

  # Alert at CONN_ALERT, recover only below CONN_OK, so a load hovering at the
  # threshold does not flip the state every run.
  if [ "$conns" -ge "$CONN_ALERT" ] || [ "$d_errors" -gt 0 ]; then
    track mysql-connections fail "MySQL connections at $conns, $d_errors refused since the last check"
  elif [ "$conns" -lt "$CONN_OK" ]; then
    track mysql-connections ok "MySQL connections at $conns"
  fi
  if [ "$d_killed" -ge "$KILLED_ALERT" ]; then
    track mysql-killed fail "$d_killed queries hit the 120 s limit since the last check"
  else
    track mysql-killed ok "no burst of queries hitting the 120 s limit"
  fi
}

# The admin folder is renamed to an unguessable name at build time from the
# ADMIN_FOLDER secret. This repo is PUBLIC, so the name must never be committed
# here — ask the running container for it instead. admin-api also lives in the
# web root, so match on the index.php that defines _PS_ADMIN_DIR_.
admin_dir() {
  docker compose exec -T app sh -c '
    for d in /var/www/html/admin*/; do
      [ -f "$d/index.php" ] || continue
      if grep -q _PS_ADMIN_DIR_ "$d/index.php" 2>/dev/null; then
        basename "$d"; exit 0
      fi
    done
    exit 1' 2>/dev/null | tr -d '\r\n'
}

# On failure, record the diagnostic that actually distinguishes the two causes:
# if the Container* directory named in the newest CRITICAL is absent from disk,
# the Apache workers are pinned to a deleted container -> restart. If it is
# present, the container itself is incomplete or something else is wrong ->
# rm -rf var/cache/* && cache:clear --env=prod, then restart.
diagnose() {
  local line container
  line=$(docker compose exec -T app sh -c \
    "grep CRITICAL var/logs/prod-\$(date +%Y-%m-%d).log 2>/dev/null | tail -1" 2>/dev/null)
  [ -z "$line" ] && { log "  diag: no CRITICAL in today's prod log"; return; }

  container=$(printf '%s' "$line" | grep -o 'Container[A-Za-z0-9]\{6,\}' | head -1)
  log "  diag: $(printf '%s' "$line" | cut -c1-240)"
  [ -z "$container" ] && return

  if docker compose exec -T app sh -c "test -d var/cache/prod/admin/$container" 2>/dev/null; then
    log "  diag: $container EXISTS on disk -> incomplete container; needs cache:clear + restart"
  else
    log "  diag: $container MISSING on disk -> workers pinned to a deleted container; restart clears it"
  fi
}

# Before the HTTP checks, which exit early. These do not need the app.
check_disk
check_marker sync-stock "$STOCK_MAX_AGE"
check_marker sync-products "$DAILY_MAX_AGE"
check_marker sync-prices "$DAILY_MAX_AGE"
check_marker sync-anda-stock "$STOCK_MAX_AGE"
check_marker sync-anda-products "$DAILY_MAX_AGE"
check_marker prune-history "$DAILY_MAX_AGE"
check_mysql

ADMIN_DIR=$(admin_dir)
if [ -z "$ADMIN_DIR" ]; then
  # Expected briefly during a deploy (the app container is recreated), so this
  # is a warning rather than an alert unless it persists across runs.
  log "WARN could not read the admin folder from the app container (deploy in progress, or container down)"
  exit 0
fi

check() {
  FRONT=$(http_code "$DOMAIN/")
  BO=$(http_code "$DOMAIN/$ADMIN_DIR/login")
  [ "$FRONT" = "200" ] && [ "$BO" = "200" ]
}

# One retry before declaring a failure: absorbs a single blip and the few seconds
# mid-deploy when the container is being replaced.
if check; then
  RESULT=ok
else
  sleep 15
  if check; then RESULT=ok; else RESULT=fail; fi
fi

PREV=$(cat "$STATE_FILE" 2>/dev/null || echo unknown)
printf '%s' "$RESULT" > "$STATE_FILE"

if [ "$RESULT" = ok ]; then
  # Quiet on success, so the log is all signal. Note the recovery once.
  if [ "$PREV" = fail ]; then
    log "RECOVERED front=$FRONT bo_login=$BO"
    notify "RECOVERED site front=$FRONT bo_login=$BO"
  fi
  exit 0
fi

log "ALERT back office unhealthy: front=$FRONT bo_login=$BO (/$ADMIN_DIR/login)"
[ "$PREV" = fail ] || notify "ALERT site unhealthy: front=$FRONT bo_login=$BO"
diagnose

[ "$AUTO_RESTART" = "1" ] || exit 1

NOW=$(date +%s)
LAST=$(cat "$RESTART_STAMP" 2>/dev/null || echo 0)
if [ $((NOW - LAST)) -lt "$RESTART_COOLDOWN" ]; then
  log "  self-heal: skipped, last restart was $(((NOW - LAST) / 60))m ago (cooldown ${RESTART_COOLDOWN}s)"
  exit 1
fi

printf '%s' "$NOW" > "$RESTART_STAMP"
log "  self-heal: docker compose restart app"
if docker compose restart app >/dev/null 2>&1; then
  sleep 10
  if check; then
    log "  self-heal: OK front=$FRONT bo_login=$BO"
    notify "RECOVERED site after self-heal restart"
    printf 'ok' > "$STATE_FILE"
    exit 0
  fi
  log "  self-heal: restart did NOT fix it (front=$FRONT bo_login=$BO) — needs a human"
else
  log "  self-heal: restart command failed"
fi
exit 1
