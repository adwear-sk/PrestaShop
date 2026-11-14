#!/usr/bin/env bash
# Retention prune for two history tables that core never trims. Install on the
# VPS via deploy/crontab (the deploy workflow copies this file to /opt/adwear/).
#
#   ps_stock_mvt     one row per stock change. The Malfini and Anda syncs write
#                    ~15k a day (2.7M rows, 345 MB by 2026-11-14), all with no
#                    order and no employee. Those go after KEEP_STOCK_DAYS.
#                    Rows tied to an order or written by an employee in the BO
#                    stay forever: they are the accounting trail, and few.
#   ps_pagenotfound  the pagesnotfound module's 404 log, ~5k bot-heavy rows a
#                    day. KEEP_404_DAYS is enough for the BO report that drives
#                    redirects.
#
# Both tables were 461 MB of a ~670 MB database; pruned, the whole live DB fits
# the 512 MB buffer pool that release.sh sets (found-mysql). Runs after the
# 03:15 backup, so the nightly dump still holds whatever it removes.
#
# HOW IT STAYS CHEAP: ps_stock_mvt.date_add has no index, so a plain
# DELETE ... WHERE date_add < x LIMIT n would scan the table once per batch.
# Instead one scan finds the highest id old enough to go, and the deletes walk
# the primary key up to it in BATCH-sized id ranges. Each range re-checks the
# date and the keep rules, so gaps or out-of-order ids only make a range
# smaller, never wrong. ps_pagenotfound has an index on date_add, so a plain
# batched delete is already index-only there.
#
# TIMEZONE: MySQL runs UTC but PHP writes local time (CET/CEST) into date_add,
# so rows are kept 1-2 h longer than nominal. That errs toward retention; do
# not shift the threshold to "fix" it (same as prune-logs.sh).
set -euo pipefail

APP_DIR="/opt/adwear"

KEEP_STOCK_DAYS="${KEEP_STOCK_DAYS:-90}"
KEEP_404_DAYS="${KEEP_404_DAYS:-30}"

# Rows per delete, so no pass holds a long lock or a huge binlog event.
BATCH="${BATCH:-20000}"

# Stop after this long and resume next night. The first run meets a backlog of
# ~1.9M stock rows and ~0.9M 404 rows; later runs remove one day's worth.
MAX_SECONDS="${MAX_SECONDS:-900}"

# sql() hides MySQL's stderr (the password warning), so leave a line in the cron
# log when a statement fails instead of stopping silently.
trap 'echo "[$(date -u "+%F %T")] prune-history FAILED at line $LINENO"' ERR

cd "$APP_DIR"
# shellcheck disable=SC1091
set -a; . ./.env; set +a

STOCK="${DB_PREFIX}stock_mvt"
NOTFOUND="${DB_PREFIX}pagenotfound"

sql() {
  docker compose exec -T mysql \
    mysql -N -B -u root -p"$DB_ROOT_PASSWD" "$DB_NAME" -e "$1" 2>/dev/null
}

has_table() {
  [ -n "$(sql "SHOW TABLES LIKE '$1';")" ]
}

# Fixed once per run, so every batch uses the same cut-off.
STOCK_CUTOFF="$(sql "SELECT DATE_SUB(NOW(), INTERVAL $KEEP_STOCK_DAYS DAY);")"
NOTFOUND_CUTOFF="$(sql "SELECT DATE_SUB(NOW(), INTERVAL $KEEP_404_DAYS DAY);")"

# Sync movements only: no order, no employee.
STOCK_WHERE="date_add < '$STOCK_CUTOFF' AND IFNULL(id_order, 0) = 0 AND id_employee = 0"
NOTFOUND_WHERE="date_add < '$NOTFOUND_CUTOFF'"

has_404=0
if has_table "$NOTFOUND"; then has_404=1; fi

stock_before="$(sql "SELECT COUNT(*) FROM \`$STOCK\`;")"
notfound_before=0
[ "$has_404" -eq 1 ] && notfound_before="$(sql "SELECT COUNT(*) FROM \`$NOTFOUND\`;")"

if [ "${1:-}" = "--dry-run" ]; then
  stock_doomed="$(sql "SELECT COUNT(*) FROM \`$STOCK\` WHERE $STOCK_WHERE;")"
  stock_kept_old="$(sql "SELECT COUNT(*) FROM \`$STOCK\` WHERE date_add < '$STOCK_CUTOFF' AND NOT ($STOCK_WHERE);")"
  echo "[$(date -u '+%F %T')] DRY RUN"
  echo "  $STOCK: $stock_before rows, $stock_doomed sync rows before $STOCK_CUTOFF would go;" \
       "$stock_kept_old older order/employee rows stay"
  if [ "$has_404" -eq 1 ]; then
    notfound_doomed="$(sql "SELECT COUNT(*) FROM \`$NOTFOUND\` WHERE $NOTFOUND_WHERE;")"
    echo "  $NOTFOUND: $notfound_before rows, $notfound_doomed before $NOTFOUND_CUTOFF would go"
  else
    echo "  $NOTFOUND: no such table (pagesnotfound not installed), skipped"
  fi
  exit 0
fi

start=$SECONDS
finished=1
out_of_time() { [ $((SECONDS - start)) -ge "$MAX_SECONDS" ]; }

# Walk ps_stock_mvt by primary key across the ids old enough to go. Both bounds
# come from the deletable rows, not the table: the kept order rows pin the
# table's MIN id, and starting there would re-walk every pruned range nightly.
stock_deleted=0
read -r lo stop_id <<<"$(sql "SELECT IFNULL(MIN(id_stock_mvt), 0), IFNULL(MAX(id_stock_mvt), 0) FROM \`$STOCK\` WHERE $STOCK_WHERE;")"
while [ "$stop_id" -gt 0 ] && [ "$lo" -le "$stop_id" ]; do
  if out_of_time; then finished=0; break; fi
  hi=$((lo + BATCH - 1))
  [ "$hi" -gt "$stop_id" ] && hi="$stop_id"
  # ROW_COUNT() runs on the same connection as the DELETE.
  n="$(sql "DELETE FROM \`$STOCK\` WHERE id_stock_mvt BETWEEN $lo AND $hi AND $STOCK_WHERE; SELECT ROW_COUNT();")"
  stock_deleted=$((stock_deleted + ${n:-0}))
  lo=$((hi + 1))
done

# ps_pagenotfound: the date_add index makes each batch a range read.
notfound_deleted=0
if [ "$has_404" -eq 1 ]; then
  while :; do
    if out_of_time; then finished=0; break; fi
    n="$(sql "DELETE FROM \`$NOTFOUND\` WHERE $NOTFOUND_WHERE LIMIT $BATCH; SELECT ROW_COUNT();")"
    n="${n:-0}"
    notfound_deleted=$((notfound_deleted + n))
    [ "$n" -lt "$BATCH" ] && break
  done
fi

state="done"
[ "$finished" -eq 0 ] && state="time budget hit, resumes next run"
# healthcheck.sh alerts when this goes stale: a run that keeps failing or
# keeps running out of time never touches it.
if [ "$finished" -eq 1 ]; then touch "$APP_DIR/logs/.ok-prune-history"; fi
echo "[$(date -u '+%F %T')] history pruned: $STOCK -$stock_deleted of $stock_before (keep ${KEEP_STOCK_DAYS}d of sync rows)," \
     "$NOTFOUND -$notfound_deleted of $notfound_before (keep ${KEEP_404_DAYS}d) ($state)"
