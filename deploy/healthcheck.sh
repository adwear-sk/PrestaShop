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
# Output goes to logs/cron-healthcheck.log. Failures are logged on every run so
# an ongoing outage is visible in the tail; recoveries are logged once.
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

cd "$STACK_DIR" || exit 1

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S%z')" "$*"; }

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time "$CURL_TIMEOUT" "$1" 2>/dev/null; }

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
  [ "$PREV" = fail ] && log "RECOVERED front=$FRONT bo_login=$BO"
  exit 0
fi

log "ALERT back office unhealthy: front=$FRONT bo_login=$BO (/$ADMIN_DIR/login)"
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
    printf 'ok' > "$STATE_FILE"
    exit 0
  fi
  log "  self-heal: restart did NOT fix it (front=$FRONT bo_login=$BO) — needs a human"
else
  log "  self-heal: restart command failed"
fi
exit 1
