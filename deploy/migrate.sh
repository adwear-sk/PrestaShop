#!/bin/sh
# Applies deploy/sql/*.sql (copied to /opt/adwear/sql) to the shop database,
# once each, in filename order. Applied files are recorded in adwear_migration;
# a failing file stops the deploy and is not recorded, so it is retried next time.
# Name new files YYYY-MM-DD-what.sql and never edit one that has shipped.
set -eu
cd /opt/adwear

db() {
  docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -u"$MYSQL_USER" --default-character-set=utf8mb4 "$@" "$MYSQL_DATABASE"' sh "$@"
}

echo "CREATE TABLE IF NOT EXISTS adwear_migration (name VARCHAR(191) PRIMARY KEY, applied_at DATETIME NOT NULL)" | db

for file in sql/*.sql; do
  [ -e "$file" ] || continue
  name=$(basename "$file")
  if [ -n "$(echo "SELECT 1 FROM adwear_migration WHERE name = '$name'" | db -N)" ]; then
    continue
  fi
  echo "migrating: $name"
  { cat "$file"; echo; echo "INSERT INTO adwear_migration (name, applied_at) VALUES ('$name', NOW());"; } | db
done
