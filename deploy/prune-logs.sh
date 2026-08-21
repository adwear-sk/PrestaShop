#!/usr/bin/env bash
# Retention prune for PrestaShop's `ps_log` table. Install on the VPS via
# deploy/crontab (the deploy workflow copies this file to /opt/adwear/).
#
# Core ships no retention policy for this table. The only built-in is the BO
# "Erase all logs" button -> PrestaShopLogger::eraseAllLogs(), a blunt TRUNCATE.
#
# WHY THIS MATTERS more than disk: PrestaShopLogger::addLog() calls isPresent(),
# which runs SELECT COUNT(*) ... WHERE message = ? against an unindexed
# mediumtext column, and its in-process cache is broken upstream (the isset()
# guard is keyed on md5($this->message) but the value is stored under
# $this->getHash(), so the keys never match and every write full-scans). At 2M
# rows that scan cost ~1s per write, the Malfini stock sync crawled, and the
# `flock -n` guard then silently skipped every following hourly run. Keeping the
# table small is what keeps that latent bug harmless.
#
# TWO TRAPS, both deliberately handled below:
#
#   1. ID GAPS. ps_log.id_log is far ahead of the row count (AUTO_INCREMENT was
#      2,018,131 against 85,951 rows after the Aug 2026 manual prune). So the
#      obvious cap -- DELETE WHERE id_log < MAX(id_log) - MAX_ROWS -- computes a
#      threshold above every surviving id and DELETES THE WHOLE TABLE. The cut
#      point must be chosen by row offset (ORDER BY id_log DESC LIMIT 1 OFFSET
#      MAX_ROWS), which is correct whatever the gaps and still index-only.
#
#   2. TIMEZONE. The host and MySQL run UTC, but PHP writes CEST into date_add,
#      so stored timestamps are ~2h AHEAD of MySQL NOW(). DATE_SUB(NOW(),
#      INTERVAL n DAY) therefore keeps rows ~2h LONGER than nominal. That errs
#      toward retention, which is the safe direction. Do NOT "fix" it by
#      shifting the threshold -- that would delete 2h more than intended.
set -euo pipefail

APP_DIR="/opt/adwear"

# Age bound. At the measured ~50-75 rows/day this settles around 5k rows.
KEEP_DAYS="${KEEP_DAYS:-90}"

# Burst cap. An age prune cannot bound a runaway logging loop inside its own
# retention window -- that is exactly the failure above. This is the backstop.
MAX_ROWS="${MAX_ROWS:-200000}"

# Delete in chunks so a large pass never holds one long row lock.
BATCH="${BATCH:-5000}"

cd "$APP_DIR"
# shellcheck disable=SC1091
set -a; . ./.env; set +a

TABLE="${DB_PREFIX}log"

sql() {
  docker compose exec -T mysql \
    mysql -N -B -u root -p"$DB_ROOT_PASSWD" "$DB_NAME" -e "$1" 2>/dev/null
}

# Loops a DELETE until it comes back short, meaning nothing is left to remove.
# ROW_COUNT() runs on the same connection as the DELETE, so it reports that
# statement's affected rows.
delete_batched() {
  local where="$1" total=0 n
  while :; do
    n="$(sql "DELETE FROM \`$TABLE\` WHERE $where LIMIT $BATCH; SELECT ROW_COUNT();")"
    n="${n:-0}"
    total=$((total + n))
    [ "$n" -lt "$BATCH" ] && break
  done
  echo "$total"
}

AGE_WHERE="date_add < DATE_SUB(NOW(), INTERVAL $KEEP_DAYS DAY)"

before="$(sql "SELECT COUNT(*) FROM \`$TABLE\`;")"
# Empty result => fewer than MAX_ROWS rows => cap not reached.
cut_id="$(sql "SELECT id_log FROM \`$TABLE\` ORDER BY id_log DESC LIMIT 1 OFFSET $MAX_ROWS;")"

if [ "${1:-}" = "--dry-run" ]; then
  aged="$(sql "SELECT COUNT(*) FROM \`$TABLE\` WHERE $AGE_WHERE;")"
  echo "[$(date -u '+%F %T')] DRY RUN $TABLE: $before rows"
  echo "  age    : $aged older than ${KEEP_DAYS}d would be deleted"
  if [ -n "$cut_id" ]; then
    echo "  cap    : over $MAX_ROWS rows, would also delete id_log <= $cut_id"
  else
    echo "  cap    : under $MAX_ROWS rows, nothing to do"
  fi
  exit 0
fi

# date_add is unindexed (ps_log has only PRIMARY KEY (id_log)), so each batch is
# a table scan. Cheap at this size, and batching is what keeps it cheap if the
# table is ever large.
aged_deleted="$(delete_batched "$AGE_WHERE")"

capped_deleted=0
if [ -n "$cut_id" ]; then
  capped_deleted="$(delete_batched "id_log <= $cut_id")"
fi

after="$(sql "SELECT COUNT(*) FROM \`$TABLE\`;")"
echo "[$(date -u '+%F %T')] $TABLE pruned: $before -> $after rows (aged $aged_deleted, capped $capped_deleted; keep ${KEEP_DAYS}d, cap $MAX_ROWS)"
