#!/bin/sh
# Puts an app image live on the VPS and runs every step a fresh app container needs.
# The deploy workflow and rollbacks both go through here, so a rollback can never
# skip the post-steps (.htaccess, robots.txt, translations, mails, cache, crontab).
#
#   release.sh <image>      deploy that image, e.g. ghcr.io/adwear-sk/prestashop:<sha>
#   release.sh rollback     go back to the image released before the current one
#                           (a second rollback returns to where you started; for an
#                           older image pass it explicitly: `release.sh list`)
#   release.sh list         show the release history (newest last)
#
# The image is pinned in .env as APP_IMAGE, so a later `docker compose up` keeps it.
# logs/releases.log records each release; the current and previous images stay on
# disk so a rollback needs no registry pull. Older ones are removed.
set -eu
cd /opt/adwear

LOG=logs/releases.log
# As root, `crontab` below would install the schedule for root and every cron would run twice.
[ "$(id -u)" != 0 ] || { echo "release.sh: run it as the deploy user, not root" >&2; exit 1; }
mkdir -p logs
# One release at a time: CI's concurrency group does not cover a manual rollback.
exec 9>logs/release.lock
flock -n 9 || { echo "release.sh: another release is running" >&2; exit 1; }

running_image() {
  docker inspect --format '{{.Config.Image}}' "$(docker compose ps -a -q app)" 2>/dev/null || true
}

# The image that is supposed to be live: the .env pin, else the app container's image.
# Read from .env so a rollback still knows what to leave when the app container has
# crashed or a failed `up` removed it.
current_image() {
  pinned=$(sed -n 's/^APP_IMAGE=//p' .env | tail -n 1)
  if [ -n "$pinned" ]; then echo "$pinned"; else running_image; fi
}

case "${1:-}" in
  list)
    cat "$LOG" 2>/dev/null || echo "no releases recorded yet"
    exit 0
    ;;
  rollback)
    current=$(current_image)
    # Newest logged image that differs from the one running now.
    image=$(awk '{print $2}' "$LOG" 2>/dev/null | grep -vxF "$current" | tail -n 1 || true)
    [ -n "$image" ] || { echo "rollback: no earlier release in $LOG" >&2; exit 1; }
    echo "rollback: $current -> $image"
    ;;
  ""|-*)
    echo "usage: release.sh <image> | rollback | list" >&2
    exit 2
    ;;
  *)
    image=$1
    ;;
esac

# The first release under this script records what was running before it, so the
# image deployed before the pinning is still a rollback target.
if [ ! -s "$LOG" ] && [ -n "$(running_image)" ]; then
  echo "$(date -u +%FT%TZ) $(running_image) (before release.sh)" >> "$LOG"
fi

docker image inspect "$image" >/dev/null 2>&1 || docker pull "$image"
if grep -q '^APP_IMAGE=' .env; then
  sed -i "s|^APP_IMAGE=.*|APP_IMAGE=$image|" .env
else
  # Never glue the pin onto a last line that has no newline (it would corrupt that secret).
  [ -z "$(tail -c 1 .env)" ] || echo >> .env
  echo "APP_IMAGE=$image" >> .env
fi
docker compose up -d --force-recreate app
echo "$(date -u +%FT%TZ) $image" >> "$LOG"

# app/config is the ps-config volume (it holds parameters.php), so it hides the
# image's config files and upstream changes to them never reached prod. Sync
# them in from the image's copy before anything boots the kernel; the copy has
# no parameters.php/.yml, so those stay. Images built before 2026-11-12 have
# no copy: warn instead of failing, so rolling back to one still works.
if docker compose exec -T app test -d /usr/local/share/adwear-app-config; then
  docker compose exec -T -u www-data app cp -a /usr/local/share/adwear-app-config/. app/config/
else
  echo "WARNING: this image has no app/config copy; app/config left as it was"
fi

# Keep the current and the previous image, drop the rest (~4 GB each).
keep=$(awk '{print $2}' "$LOG" | tac | awk '!seen[$0]++' | head -n 2)
repo=${image%:*}
docker images --format '{{.Repository}}:{{.Tag}}' "$repo" | while read -r ref; do
  echo "$keep" | grep -qxF "$ref" || docker rmi "$ref" >/dev/null 2>&1 || true
done
docker image prune -f >/dev/null

# Symfony XLF translation packs live in translations/<locale>, which
# is in the ephemeral container layer (no named volume), so a recreate
# wipes them. Without them the BO translation API 400s and the
# "Modify translations" page just renders "undefined". Re-fetch any
# locale whose catalogue is missing. Runs BEFORE the cache clear
# below because installSfLanguagePack() calls Tools::clearSf2Cache().
docker compose exec -T -u www-data app php -r "require '/var/www/html/config/config.inc.php'; foreach (Language::getLanguages(false) as \$l) { \$loc = \$l['locale']; if (!\$loc || is_dir(_PS_ROOT_DIR_ . '/translations/' . \$loc)) { continue; } \$e = []; if (Language::downloadLanguagePack(\$l['iso_code'], _PS_VERSION_, \$e)) { Language::installSfLanguagePack(\$loc, \$e); } echo 'translations ' . \$loc . ': ' . (\$e ? implode('; ', \$e) : 'restored') . PHP_EOL; }"
# Data changes (settings, translations, address formats) ship as
# deploy/sql/*.sql; each runs once. Before the cache clear so cached
# translations and config pick them up. A failing file fails the deploy.
chmod +x /opt/adwear/migrate.sh
/opt/adwear/migrate.sh
# MySQL server settings: the whole budget lives here, re-applied on every
# deploy. Set as root because migrate.sh runs as the shop user, and with
# SET PERSIST because every value is dynamic and needs no MySQL restart:
# a restart under traffic can compile a container with no modules in it.
# The box has 3.8 GB RAM shared with 24 mod_php workers and the crons, and
# mysqld was already 768 MB into swap at the 128 MB defaults (2026-11-14,
# found-mysql). --force applies the rest if one statement fails.
docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot --force' <<'SQL' || echo "WARNING: some MySQL settings were not applied"
-- 3 days of binlogs (default 30): no replica, and at the default they took
-- 21 GB of the disk in the 2026-11-04 outage.
SET PERSIST binlog_expire_logs_seconds = 259200;
-- Smaller binlogs on disk; the payload stays readable by mysqlbinlog.
SET PERSIST binlog_transaction_compression = ON;
-- Abort any SELECT running over 2 minutes, so a burst of expensive
-- faceted-filter counts cannot hold every connection for hours (2026-11-10).
SET PERSIST max_execution_time = 120000;
-- 512 MB holds the whole live DB once the tracking tables are pruned
-- (~300 MB; 673 MB before); the 128 MB default read ~10 GB a day from disk.
-- Kept below 768 MB because 24 busy workers (~87 MB each) plus the crons
-- would leave too little RAM; raise it only if swap stays flat. Resized
-- online in 128 MB chunks.
SET PERSIST innodb_buffer_pool_size = 536870912;
-- 512 MB redo (default 100 MB) absorbs the nightly import bursts.
SET PERSIST innodb_redo_log_capacity = 536870912;
-- One in-memory temp table may take 1 GB by default; only 51 ever spilled
-- to disk, so 256 MB costs nothing and removes a per-query RAM surprise.
SET PERSIST temptable_max_ram = 268435456;
-- 24 Apache workers + crons + backup + healthcheck + CLI; 151 let a burst
-- exhaust connections on 2026-10-03 before the worker cap existed.
SET PERSIST max_connections = 80;
-- Reuse threads instead of creating one per request (65k created at 9).
SET PERSIST thread_cache_size = 32;
-- Slow log at 2 s, at a fixed path (the default name carries the container
-- hostname, which changes on every recreate). mysql-weekly.sh rotates it.
SET PERSIST slow_query_log_file = '/var/lib/mysql/slow.log';
SET PERSIST long_query_time = 2;
SET PERSIST log_slow_admin_statements = ON;
SET PERSIST slow_query_log = ON;
SQL
# The mail layouts (mails/themes) are git-managed but sit in the mails
# volume, so sync them in from the image. Must run BEFORE the cache
# clear: cache:clear warms the prod Twig cache, which never
# revalidates (no auto_reload), so layouts copied in afterwards are
# ignored by the generator below. Non-fatal like the generation.
docker compose exec -T -u www-data app cp -a /usr/local/share/adwear-mail-themes/. mails/themes/ || echo "WARNING: mail layout sync failed"
# PrestaShop's web kernels run in prod; clear ALL kernel caches and
# warm the (heavy) prod admin cache via CLI with unlimited memory so
# the first web hit doesn't cold-build under PHP's memory_limit.
docker compose exec -T -u www-data app sh -c "rm -rf var/cache/*"
docker compose exec -T -u www-data app php -d memory_limit=-1 bin/console cache:clear --env=prod
# Module templates (modules/*/mails/sk) live in the ephemeral
# container layer, so a recreate wipes them and those mails fall back
# to English. --overwrite regenerates everything so layout changes
# (e.g. the footer) reach already-generated templates. Non-fatal:
# stale mails beat skipping the .htaccess and crontab steps below.
docker compose exec -T -u www-data app php -d memory_limit=-1 bin/console prestashop:mail:generate modern sk --overwrite --env=prod || echo "WARNING: mail template generation failed"
# Friendly URLs need the PS-generated .htaccess; it lives in the
# ephemeral container layer, so regenerate it after every recreate.
docker compose exec -T -u www-data app php -r "require '/var/www/html/config/config.inc.php'; Tools::generateHtaccess();"
# robots.txt is in the same ephemeral layer, and without it crawlers
# walk every facet combination (?q=), each one a row in the
# ps_layered_filter_block cache. Core's default rules block ?q= and
# &q=. Non-fatal: the crontab step below must still run.
docker compose exec -T -u www-data app php -r "require '/var/www/html/config/config.inc.php'; exit(Tools::generateRobotsFile(true) ? 0 : 1);" || echo "WARNING: robots.txt generation failed"
# scp does not preserve the exec bit, and the crons call these
# scripts directly.
chmod +x /opt/adwear/prune-logs.sh /opt/adwear/prune-visitors.sh /opt/adwear/prune-history.sh /opt/adwear/healthcheck.sh /opt/adwear/backup.sh /opt/adwear/mysql-weekly.sh
# Install the git-managed cron schedule (deploy/crontab).
crontab /opt/adwear/crontab

echo "released: $image"
