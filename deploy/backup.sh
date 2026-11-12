#!/usr/bin/env bash
# Nightly backup, run from the deploy user's crontab (deploy/crontab, 03:15).
#
#  1. Dumps the database and VERIFIES the dump (on 2026-11-04 a full disk left
#     a 0-byte dump that nothing noticed).
#  2. Keeps 14 days of dumps locally, for quick restores on this box.
#  3. Sends the dump, the shop's volumes (img, upload, download, config, mails)
#     and /opt/adwear itself to the encrypted borg repo on the Storage Box, via
#     the pinned borgmatic container (deploy/borgmatic/config.yaml).
#
# Off-site is skipped with a warning until BORG_REPO is set in .env, so this
# script can ship before the Storage Box exists.
#
# .env keys: BORG_REPO (ssh://uNNN@uNNN.your-storagebox.de:23/./adwear),
# BORG_PASSPHRASE, HC_BACKUP_URL (healthchecks.io check: start/success/fail
# pings; a missing ping alerts too), ALERT_URL (ntfy, see healthcheck.sh).
# The Storage Box key and its known_hosts are ~/.ssh/storagebox{,_known_hosts}.
set -euo pipefail

APP_DIR="/opt/adwear"
BACKUP_DIR="$APP_DIR/backups"
KEEP_DAYS=14
STAMP="$(date +%Y%m%d-%H%M%S)"
DUMP="$BACKUP_DIR/db-$STAMP.sql.gz"
BORGMATIC_IMAGE="b3vis/borgmatic:2.1.10"

cd "$APP_DIR"
# shellcheck disable=SC1091
set -a; . ./.env; set +a

log() { echo "[$(date)] $*"; }

ping_hc() {
  [ -n "${HC_BACKUP_URL:-}" ] || return 0
  curl -fsS -m 10 --retry 3 -o /dev/null --data-raw "${2:-}" "$HC_BACKUP_URL$1" || log "WARN healthchecks ping failed"
}

fail() {
  log "FAILED: $*"
  ping_hc /fail "$*"
  [ -z "${ALERT_URL:-}" ] || curl -s -o /dev/null -m 10 -d "adwear: ALERT backup failed: $*" "$ALERT_URL" || true
  rm -f "$DUMP.tmp"
  exit 1
}
trap 'fail "line $LINENO exited $?"' ERR

# One run at a time: the first off-site seed can outlast a night.
exec 9>/tmp/adwear-backup.lock
if ! flock -n 9; then
  log "previous backup still running, skipping"
  ping_hc /fail "previous backup still running"
  exit 0
fi

ping_hc /start

log "dumping database $DB_NAME"
# --rsyncable keeps unchanged stretches byte-identical so borg can dedup them.
docker compose exec -T mysql \
  mysqldump --single-transaction --quick --no-tablespaces \
  -u root -p"$DB_ROOT_PASSWD" "$DB_NAME" \
  | gzip --rsyncable > "$DUMP.tmp"

# A dump cut short by a full disk or a killed mysqldump is still valid gzip,
# so also require mysqldump's own completion trailer.
[ -s "$DUMP.tmp" ] || fail "dump is empty"
gzip -t "$DUMP.tmp" || fail "dump is not valid gzip"
zcat "$DUMP.tmp" | tail -n 1 | grep -q -- '-- Dump completed' || fail "dump is incomplete (no completion trailer)"
mv "$DUMP.tmp" "$DUMP"
log "dump ok: $(du -h "$DUMP" | cut -f1)"

log "pruning dumps older than $KEEP_DAYS days"
find "$BACKUP_DIR" -name 'db-*.sql.gz' -mtime +"$KEEP_DAYS" -delete

if [ -z "${BORG_REPO:-}" ]; then
  log "WARN BORG_REPO not set: no off-site copy made"
  ping_hc /fail "BORG_REPO not set: no off-site copy"
  exit 0
fi

log "off-site backup to the borg repo"
# `docker run -v` silently creates an empty volume for a wrong name, which
# would back up empty trees and let retention age out the good archives.
docker volume inspect adwear_ps-img adwear_ps-upload adwear_ps-download \
  adwear_ps-config adwear_ps-mails >/dev/null || fail "a shop volume is missing"
for f in "$APP_DIR/borgmatic/config.yaml" "$HOME/.ssh/storagebox" "$HOME/.ssh/storagebox_known_hosts"; do
  [ -f "$f" ] || fail "missing $f"
done

# The config volume holds parameters.php and the cookie keys; the repo is
# encrypted client-side. --cpus keeps the 2-vCPU box serving pages while borg
# hashes 1M image files. BORG_HOST_ID is fixed because each container gets a
# random hostname, and borg could then never break a lock left by a killed run.
# The state volume remembers when the checks last ran (the image keeps it in
# an anonymous volume that --rm would delete, so both checks ran nightly).
# Files are checked above: a bind mount of a missing file can create a
# root-owned directory in its place, which deploy (no sudo) can't remove.
docker run --rm --cpus 1 --hostname adwear-backup \
  -e BORG_REPO -e BORG_PASSPHRASE \
  -e BORG_HOST_ID=adwear-backup -e BORG_RELOCATED_REPO_ACCESS_IS_OK=no \
  -e TZ=Europe/Bratislava \
  --mount "type=bind,src=$APP_DIR/borgmatic/config.yaml,dst=/etc/borgmatic/config.yaml,readonly" \
  --mount "type=bind,src=$HOME/.ssh/storagebox,dst=/root/.ssh/storagebox,readonly" \
  --mount "type=bind,src=$HOME/.ssh/storagebox_known_hosts,dst=/root/.ssh/known_hosts,readonly" \
  -v adwear-borg-cache:/root/.cache/borg \
  -v adwear-borg-config:/root/.config/borg \
  -v adwear-borgmatic-state:/root/.local/state/borgmatic \
  --mount "type=bind,src=$DUMP,dst=/source/db.sql.gz,readonly" \
  -v adwear_ps-img:/source/volumes/img:ro \
  -v adwear_ps-upload:/source/volumes/upload:ro \
  -v adwear_ps-download:/source/volumes/download:ro \
  -v adwear_ps-config:/source/volumes/config:ro \
  -v adwear_ps-mails:/source/volumes/mails:ro \
  -v "$APP_DIR:/source/host:ro" \
  --entrypoint borgmatic "$BORGMATIC_IMAGE" \
  -c /etc/borgmatic/config.yaml --stats

ping_hc "" "dump $(du -h "$DUMP" | cut -f1), off-site ok"
log "done"
