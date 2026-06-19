#!/usr/bin/env bash
# Nightly database backup. Install on the VPS via cron (as the deploy user):
#   crontab -e
#   15 3 * * *  /opt/adwear/backup.sh >> /opt/adwear/backups/backup.log 2>&1
set -euo pipefail

APP_DIR="/opt/adwear"
BACKUP_DIR="$APP_DIR/backups"
KEEP_DAYS=14
STAMP="$(date +%Y%m%d-%H%M%S)"

cd "$APP_DIR"
# shellcheck disable=SC1091
set -a; . ./.env; set +a

echo "[$(date)] dumping database $DB_NAME"
docker compose exec -T mysql \
  mysqldump --single-transaction --quick --no-tablespaces \
  -u root -p"$DB_ROOT_PASSWD" "$DB_NAME" \
  | gzip > "$BACKUP_DIR/db-$STAMP.sql.gz"

echo "[$(date)] pruning dumps older than $KEEP_DAYS days"
find "$BACKUP_DIR" -name 'db-*.sql.gz' -mtime +"$KEEP_DAYS" -delete

# OPTIONAL off-site copy to a Hetzner Storage Box (uncomment + configure):
# rsync -az "$BACKUP_DIR/db-$STAMP.sql.gz" \
#   u123456@u123456.your-storagebox.de:backups/

echo "[$(date)] done"
