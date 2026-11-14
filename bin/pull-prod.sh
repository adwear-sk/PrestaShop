#!/usr/bin/env bash
#
# Refresh local dev from www.adwear.sk: code, database, var/anda and img/.
# Only reads from prod (mysqldump --single-transaction, tar via the app container).
#
#   bin/pull-prod.sh                  preflight + code + db + files
#   bin/pull-prod.sh code|db|files    one phase (preflight always runs)
#   bin/pull-prod.sh --check          preflight only
#
# Local dev tooling (tracked despite the /bin/ ignore; stripped from the prod image).
#
# db     backs up the local DB to ~/adwear-backups first, then replaces it with a
#        prod dump (tracking/log tables as schema only) and localizes it:
#        localhost:8001, no SSL, maildev, Google Analytics off.
#        BO login afterwards = prod employee credentials.
# files  var/anda in full; img/ in ~100 chunks (a broken first run resumes at
#        the next chunk), later runs only copy files newer than the last pull.
#        Files deleted on prod are not deleted locally.

set -euo pipefail

MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAIN="$(cd "$(git -C "$MAIN" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"
PROD="${PROD_SSH:-deploy@178.105.70.62}"
PROD_DIR=/opt/adwear
LOCAL_DOMAIN="${LOCAL_DOMAIN:-localhost:8001}"
BACKUPS="$HOME/adwear-backups"
STATE="$MAIN/var/pull-prod"
DB="docker exec -i adwearpresta-mysql-1 mysql -uroot -pprestashop"
# Same client, with only the password warning filtered so real errors stay visible.
db() { $DB "$@" 2> >(grep -v "Using a password" >&2); }
APP=adwearpresta-prestashop-git-1
# Tables whose rows are bot/visitor tracking, logs or caches (~600 MB of 673 on prod).
SKIP_DATA=(ps_stock_mvt ps_pagenotfound ps_connections_source ps_connections ps_guest
    ps_log ps_malfini_api_sync_log ps_adwear_anda_sync_log ps_layered_filter_block)

die() { echo "error: $*" >&2; exit 1; }
log() { echo -e "\n* $*"; }
# Keepalives: a long tar stream over WSL networking can stall; give it ~2 min before ssh gives up.
prod() { ssh -o BatchMode=yes -o ServerAliveInterval=15 -o ServerAliveCountMax=8 "$PROD" "cd $PROD_DIR && $1"; }

nested_repos() {
    find "$MAIN/themes" "$MAIN/modules" -mindepth 2 -maxdepth 2 -name .git \
        | sed -e "s#^$MAIN/##" -e 's#/\.git$##' | sort
}

preflight() {
    log "Preflight"
    local extra; extra="$(git -C "$MAIN" worktree list | tail -n +2)"
    [ -z "$extra" ] || die "worktrees share this DB and must be on the same code — remove them first:\n$extra"
    [ -z "$(docker ps --format '{{.Names}}' | grep '^adwear-' || true)" ] || die "worktree containers are running (bin/worktree.sh down <name>)"
    docker ps --format '{{.Names}}' | grep -qx adwearpresta-mysql-1 || die "local mysql is not running (docker compose up -d mysql)"
    # img/ holds a few tracked files whose prod copies differ (admin icons); they come from prod.
    [ -z "$(git -C "$MAIN" status --porcelain --untracked-files=no -- . ':!img')" ] || die "main repo has uncommitted changes"
    local repo
    while read -r repo; do
        [ -z "$(git -C "$MAIN/$repo" status --porcelain)" ] || die "$repo has uncommitted changes"
    done < <(nested_repos)
    local free_gb; free_gb=$(df -BG --output=avail "$MAIN" | tail -1 | tr -dc 0-9)
    [ "$free_gb" -ge 40 ] || die "only ${free_gb} GB free; img/ alone is ~22 GB"
    prod "true" || die "cannot ssh to $PROD"
    echo "  ok"
}

pull_code() {
    log "Code: fast-forward main + nested repos"
    git -C "$MAIN" fetch -q origin
    git -C "$MAIN" merge --ff-only "origin/$(git -C "$MAIN" branch --show-current)"
    local repo
    while read -r repo; do
        git -C "$MAIN/$repo" pull -q --ff-only || die "$repo cannot fast-forward"
    done < <(nested_repos)
    echo "  main at $(git -C "$MAIN" log --oneline -1)"
    echo "  restart the app container to run composer + the asset build: docker compose up -d prestashop-git"
}

pull_db() {
    mkdir -p "$BACKUPS" "$STATE"
    local stamp; stamp=$(date +%F-%H%M)
    local backup="$BACKUPS/local-before-pull-$stamp.sql.gz"
    log "DB: backing up local to $backup"
    docker exec adwearpresta-mysql-1 mysqldump -uroot -pprestashop --single-transaction --routines \
        --no-tablespaces prestashop 2>/dev/null | gzip > "$backup"
    zcat "$backup" | tail -1 | grep -q 'Dump completed' || die "local backup is incomplete: $backup"

    local dump="$STATE/prod-$stamp.sql.gz" ignore="" t
    for t in "${SKIP_DATA[@]}"; do ignore="$ignore --ignore-table=\$MYSQL_DATABASE.$t"; done
    log "DB: dumping prod (schema for all tables, data without ${#SKIP_DATA[@]} tracking tables)"
    prod "docker compose exec -T mysql sh -c '
        A=\"-u\$MYSQL_USER -p\$MYSQL_PASSWORD --single-transaction --no-tablespaces --skip-triggers\"
        mysqldump \$A --no-data \$MYSQL_DATABASE && mysqldump \$A --no-create-info $ignore \$MYSQL_DATABASE
    ' 2>/dev/null | gzip" > "$dump"
    [ "$(zcat "$dump" | grep -c 'Dump completed')" = 2 ] || die "prod dump is incomplete: $dump"
    echo "  $(du -h "$dump" | cut -f1) gz"

    log "DB: replacing local prestashop"
    # From here on a failure leaves the local DB half-replaced: every step says how to get it back.
    local restore="restore with: zcat $backup | $DB prestashop"
    db -e "DROP DATABASE IF EXISTS prestashop; CREATE DATABASE prestashop" || die "drop/create failed — $restore"
    zcat "$dump" | db prestashop || die "import failed — $restore"

    log "DB: localizing ($LOCAL_DOMAIN, no SSL, maildev, GA off)"
    db prestashop <<SQL || die "localize failed — $restore"
UPDATE ps_shop_url SET domain = '$LOCAL_DOMAIN', domain_ssl = '$LOCAL_DOMAIN';
UPDATE ps_configuration SET value = '$LOCAL_DOMAIN' WHERE name IN ('PS_SHOP_DOMAIN', 'PS_SHOP_DOMAIN_SSL');
UPDATE ps_configuration SET value = '0' WHERE name IN ('PS_SSL_ENABLED', 'PS_SSL_ENABLED_EVERYWHERE');
UPDATE ps_configuration SET value = '2' WHERE name = 'PS_MAIL_METHOD';
UPDATE ps_configuration SET value = 'maildev' WHERE name = 'PS_MAIL_SERVER';
UPDATE ps_configuration SET value = '1025' WHERE name = 'PS_MAIL_SMTP_PORT';
UPDATE ps_configuration SET value = 'off' WHERE name = 'PS_MAIL_SMTP_ENCRYPTION';
UPDATE ps_configuration SET value = '' WHERE name IN ('PS_MAIL_USER', 'PS_MAIL_PASSWD');
UPDATE ps_configuration SET value = '0' WHERE name = 'PS_MAIL_DKIM_ENABLE';
UPDATE ps_module SET active = 0 WHERE name = 'ps_googleanalytics';
DELETE FROM ps_module_shop WHERE id_module = (SELECT id_module FROM ps_module WHERE name = 'ps_googleanalytics');
SQL
    [ "$(db -N prestashop -e "SELECT domain FROM ps_shop_url LIMIT 1")" = "$LOCAL_DOMAIN" ] \
        || die "localize check failed — $restore"
    clear_caches
    echo "  rollback: zcat $backup | $DB prestashop"
}

clear_caches() {
    docker ps --format '{{.Names}}' | grep -qx "$APP" || { echo "  ($APP not running — clear caches after starting it)"; return; }
    log "Clearing caches + regenerating .htaccess"
    docker exec -u www-data "$APP" sh -c 'rm -rf var/cache/*'
    docker exec -u www-data "$APP" php -r '
        require "config/config.inc.php";
        Tools::generateHtaccess(); Tools::clearSmartyCache(); Media::clearCache();'
}

# Runs $1 (a tar producer) in the prod img dir and unpacks the stream into local img/.
img_stream() {
    prod "docker compose exec -T app nice -n 19 sh -c 'cd /var/www/html/img && $1'" | tar -C "$MAIN/img" -xf -
}

pull_files() {
    mkdir -p "$STATE/chunks" "$MAIN/var/anda"
    log "Files: var/anda"
    prod "docker compose exec -T app tar -C /var/www/html/var -cf - anda" | tar -C "$MAIN/var" -xf -
    du -sh "$MAIN/var/anda" | sed 's/^/  /'

    # Stamps are prod's clock (epoch), so local clock drift can't skip files.
    local started; started=$(prod "date +%s")
    if [ -f "$STATE/img-since" ]; then
        local since; since=$(cat "$STATE/img-since")
        # Stamps written before 2026-11-14 hold a UTC date string.
        [[ "$since" =~ ^[0-9]+$ ]] || since=$(date -u -d "$since UTC" +%s)
        log "Files: img changed on prod since $(date -u -d "@$since" '+%F %T') UTC"
        img_stream "find . -type f -newermt @$since | tar -cf - -T -"
    else
        log "Files: img first full copy (~22 GB; rerun resumes at the next chunk)"
        # A resumed first copy keeps the start of the run that copied the first chunk.
        [ -f "$STATE/chunks/.started" ] || echo "$started" > "$STATE/chunks/.started"
        started=$(cat "$STATE/chunks/.started")
        local chunks c
        chunks=$(prod "docker compose exec -T app sh -c 'cd /var/www/html/img && ls -d p/[0-9]/[0-9] 2>/dev/null'" | tr -d '\r')
        for c in $chunks; do
            [ -f "$STATE/chunks/${c//\//_}" ] && continue
            echo "  $c"
            local try
            for try in 1 2 3; do
                img_stream "tar -cf - $c" && break
                [ "$try" = 3 ] && die "chunk $c failed 3 times — rerun to resume from it"
                echo "  $c broke off, retry $try"
            done
            touch "$STATE/chunks/${c//\//_}"
        done
        echo "  rest of img/ (everything outside p/<d>/<d>)"
        img_stream "find . -type f ! -path \"./p/[0-9]/[0-9]/*\" | tar -cf - -T -"
        rm -rf "$STATE/chunks"
    fi
    # Stamp the start time, so files written on prod during this run are fetched next time.
    echo "$started" > "$STATE/img-since"
    echo "  img: $(find "$MAIN/img" -type f | wc -l) files, $(du -sh "$MAIN/img" | cut -f1)"
}

case "${1:-all}" in
    --check) preflight ;;
    code)    preflight; pull_code ;;
    db)      preflight; pull_db ;;
    files)   preflight; pull_files ;;
    all)     preflight; pull_code; pull_db; pull_files ;;
    *)       sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
