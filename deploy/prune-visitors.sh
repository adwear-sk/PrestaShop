#!/usr/bin/env bash
# Removes the crawler backlog from PrestaShop's visitor statistics: ps_guest,
# ps_connections, ps_connections_source (and ps_connections_page). Install on
# the VPS via deploy/crontab (the deploy workflow copies this file to
# /opt/adwear/).
#
# Until 2026-10-12 core's Connection::isBot() missed nearly every crawler, and
# bots never keep the cookie, so each bot request created a guest, a
# connection and a source row: ~30k a day, 3M+ rows, ~2 GB. The overrides in
# override/classes/{Connection,Guest}.php stopped that; this clears what was
# already written.
#
# WHAT GOES: guests up to BOT_FILTER_GUEST_ID (the last id before the filter
# shipped) that are not a customer and are not referenced by a cart, a product
# comment or a GDPR log entry -- plus their connections and sources. Before the
# filter those were ~99.9% bots (4 customers among 3.07M guests), and they
# carry no user agent, so there is no finer way to tell them apart. Anonymous
# visits after the filter are left alone: they are real statistics now.
#
# Once the backlog is gone every pass is a no-op over empty id ranges, so the
# cron can stay or be dropped. Runs after the 03:15 backup, so the nightly dump
# still holds whatever it removes.
set -euo pipefail

APP_DIR="/opt/adwear"

# Last ps_guest id written before the bot filter was deployed.
BOT_FILTER_GUEST_ID="${BOT_FILTER_GUEST_ID:-3069452}"

# Guest ids per pass. Every table is reached through an index (ps_guest PK,
# ps_connections.id_guest, ps_connections_source.connections, ps_cart.id_guest),
# so a pass touches only its own range and never holds a long lock.
BATCH="${BATCH:-20000}"

# Stop after this long and resume next night; the deleted ranges come back
# empty, so the next run moves through them at index speed.
MAX_SECONDS="${MAX_SECONDS:-2400}"

cd "$APP_DIR"
# shellcheck disable=SC1091
set -a; . ./.env; set +a

P="$DB_PREFIX"

sql() {
  docker compose exec -T mysql \
    mysql -N -B -u root -p"$DB_ROOT_PASSWD" "$DB_NAME" -e "$1" 2>/dev/null
}

has_table() {
  [ -n "$(sql "SHOW TABLES LIKE '$P$1';")" ]
}

# A guest is only removable if nothing outside the statistics points at it.
KEEP="IFNULL(g.id_customer, 0) = 0
  AND NOT EXISTS (SELECT 1 FROM \`${P}cart\` x WHERE x.id_guest = g.id_guest)"
for t in product_comment psgdpr_log; do
  if has_table "$t"; then
    KEEP="$KEEP
  AND NOT EXISTS (SELECT 1 FROM \`$P$t\` x WHERE x.id_guest = g.id_guest)"
  fi
done

guests_before="$(sql "SELECT COUNT(*) FROM \`${P}guest\`;")"
conns_before="$(sql "SELECT COUNT(*) FROM \`${P}connections\`;")"
sources_before="$(sql "SELECT COUNT(*) FROM \`${P}connections_source\`;")"

if [ "${1:-}" = "--dry-run" ]; then
  doomed="$(sql "SELECT COUNT(*) FROM \`${P}guest\` g WHERE g.id_guest <= $BOT_FILTER_GUEST_ID AND $KEEP;")"
  echo "[$(date -u '+%F %T')] DRY RUN visitor stats: $guests_before guests, $conns_before connections, $sources_before sources"
  echo "  would delete $doomed guests (id <= $BOT_FILTER_GUEST_ID, anonymous, unreferenced) and their connections/sources"
  exit 0
fi

start=$SECONDS
lo="$(sql "SELECT IFNULL(MIN(id_guest), 0) FROM \`${P}guest\`;")"
finished=1

while [ "$lo" -le "$BOT_FILTER_GUEST_ID" ]; do
  if [ $((SECONDS - start)) -ge "$MAX_SECONDS" ]; then
    finished=0
    break
  fi
  hi=$((lo + BATCH - 1))
  [ "$hi" -gt "$BOT_FILTER_GUEST_ID" ] && hi="$BOT_FILTER_GUEST_ID"
  RANGE="g.id_guest BETWEEN $lo AND $hi AND $KEEP"

  # Children first, so an interrupted pass never leaves orphans behind.
  sql "DELETE p FROM \`${P}connections_page\` p
         JOIN \`${P}connections\` c ON c.id_connections = p.id_connections
         JOIN \`${P}guest\` g ON g.id_guest = c.id_guest WHERE $RANGE;
       DELETE s FROM \`${P}connections_source\` s
         JOIN \`${P}connections\` c ON c.id_connections = s.id_connections
         JOIN \`${P}guest\` g ON g.id_guest = c.id_guest WHERE $RANGE;
       DELETE c FROM \`${P}connections\` c
         JOIN \`${P}guest\` g ON g.id_guest = c.id_guest WHERE $RANGE;
       DELETE g FROM \`${P}guest\` g WHERE $RANGE;" >/dev/null
  lo=$((hi + 1))
done

guests_after="$(sql "SELECT COUNT(*) FROM \`${P}guest\`;")"
conns_after="$(sql "SELECT COUNT(*) FROM \`${P}connections\`;")"
sources_after="$(sql "SELECT COUNT(*) FROM \`${P}connections_source\`;")"
state="done"
[ "$finished" -eq 0 ] && state="time budget hit at guest id $lo, resumes next run"
echo "[$(date -u '+%F %T')] visitor stats pruned: guests $guests_before -> $guests_after, connections $conns_before -> $conns_after, sources $sources_before -> $sources_after ($state)"
