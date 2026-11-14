#!/usr/bin/env bash
#
# Spin up extra PrestaShop checkouts (git worktrees) that run side by side with
# the main one, each on its own port, all sharing the main MySQL db, maildev and
# product images.
#
#   bin/worktree.sh up   <name> <port> [branch]   create (if needed) + start
#   bin/worktree.sh down <name> [--remove]        stop; --remove also deletes the worktrees
#   bin/worktree.sh list
#
# Example:  bin/worktree.sh up wt1 8011   ->  http://wt1.localhost:8011/
#
# Local dev tooling (tracked despite the /bin/ ignore; stripped from the prod image).
# Requires the main stack to be running (mysql + maildev on the external
# `prestashop-network`).
#
# What `up` does on first run:
#   - git worktree at ../AdwearPresta-<name> on <branch> (default: new branch wt/<name> from HEAD)
#   - a worktree of every nested repo (themes/adwear, custom modules) on wt/<name>
#   - copies main's gitignored runtime files (vendor, native modules, built admin
#     assets, mails, parameters.php, .htaccess, ...) — skips node_modules and caches
#   - applies the local "use request host instead of DB domain" hack to
#     Shop.php / ShopUrl.php and hides it with `git update-index --skip-worktree`
#   - writes docker-compose.worktree.yml (app container only, img/upload/download
#     bind-mounted from main) and starts it as compose project adwear-<name>
#
# Use a distinct hostname per worktree (<name>.localhost): browser cookies ignore
# the port, so two checkouts on plain `localhost` would clobber each other's sessions.

set -euo pipefail

MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# When run from inside a worktree, resolve back to the main checkout.
MAIN="$(cd "$(git -C "$MAIN" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"
# WT_IMAGE runs a worktree on another image, e.g. a PHP upgrade build.
IMAGE="${WT_IMAGE:-adwearpresta-prestashop-git:latest}"
COMPOSE_FILE="docker-compose.worktree.yml"
PATCHED_FILES=(classes/shop/Shop.php classes/shop/ShopUrl.php)

die() { echo "error: $*" >&2; exit 1; }
log() { echo -e "\n* $*"; }

wt_path() { echo "$(dirname "$MAIN")/$(basename "$MAIN")-$1"; }

nested_repos() {
    # Nested git repos (theme + custom modules) are gitignored in the main repo.
    find "$MAIN/themes" "$MAIN/modules" -mindepth 2 -maxdepth 2 -name .git -type d \
        | sed -e "s#^$MAIN/##" -e 's#/\.git$##' | sort
}

# Make sure our generated / patched files never show up in `git status`.
exclude_locally() {
    local exclude="$MAIN/.git/info/exclude"
    for p in "/$COMPOSE_FILE"; do
        grep -qxF "$p" "$exclude" 2>/dev/null || echo "$p" >> "$exclude"
    done
}

ensure_branch_worktree() {
    # $1 = repo dir, $2 = worktree dir, $3 = branch
    local repo="$1" dir="$2" branch="$3"
    if [ -e "$dir/.git" ]; then
        return
    fi
    if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$repo" worktree add "$dir" "$branch"
    else
        git -C "$repo" worktree add -b "$branch" "$dir" HEAD
    fi
}

copy_ignored() {
    # $1 = source repo dir, $2 = destination dir, $3 = optional extra skip regex (ERE)
    local src="$1" dst="$2" skip="(^|/)node_modules/|^\.idea/"
    [ -n "${3:-}" ] && skip="$skip|$3"
    git -C "$src" ls-files --others --ignored --exclude-standard --directory \
        | { grep -v -E "$skip" || true; } \
        | tar -C "$src" -cf - -T - | tar -C "$dst" -xpf -
}

apply_host_hack() {
    local dir="$1"
    python3 - "$dir" <<'PY'
import sys, pathlib

root = pathlib.Path(sys.argv[1])
MARK = "local worktree hack"
patches = {
    "classes/shop/Shop.php": [
        # Shop::findShopByHost(): accept any host, so the FO doesn't redirect to the DB domain.
        ("WHERE (su.domain = \\'' . pSQL($host) . '\\' OR su.domain_ssl = \\'' . pSQL($host) . '\\')",
         "WHERE su.main = 1 /* " + MARK + ": any host matches */"),
        # Shop::setUrl(): build links/assets from the request host.
        ("        $this->domain = $row['domain'];\n        $this->domain_ssl = $row['domain_ssl'];",
         "        // " + MARK + ": use the request host instead of the DB domain\n"
         "        $this->domain = !empty($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : $row['domain'];\n"
         "        $this->domain_ssl = !empty($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : $row['domain_ssl'];"),
    ],
    "classes/shop/ShopUrl.php": [
        # ShopUrl main-domain cache, used by Tools::getShopDomain(Ssl).
        ("                self::$main_domain[(int) $id_shop] = $row['domain'];\n"
         "                self::$main_domain_ssl[(int) $id_shop] = $row['domain_ssl'];",
         "                // " + MARK + ": use the request host instead of the DB domain\n"
         "                self::$main_domain[(int) $id_shop] = !empty($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : $row['domain'];\n"
         "                self::$main_domain_ssl[(int) $id_shop] = !empty($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : $row['domain_ssl'];"),
    ],
}
for rel, reps in patches.items():
    f = root / rel
    text = f.read_text()
    for old, new in reps:
        if new in text:
            continue
        if text.count(old) != 1:
            sys.exit(f"host hack: pattern not found exactly once in {rel} — upstream changed, patch by hand")
        text = text.replace(old, new)
    f.write_text(text)
PY
    git -C "$dir" update-index --skip-worktree "${PATCHED_FILES[@]}"
}

write_compose() {
    local name="$1" port="$2" dir="$3"
    cat > "$dir/$COMPOSE_FILE" <<YAML
# Generated by bin/worktree.sh — local only.
name: adwear-$name

services:
  prestashop-git:
    image: $IMAGE
    hostname: $name.localhost
    restart: unless-stopped
    environment:
      DISABLE_MAKE: 1           # vendor + built assets are copied from main
      PS_INSTALL_AUTO: 0        # parameters.php is copied, shop is already installed
      PS_USE_DOCKER_MAILDEV: 0  # main already configured maildev in the shared db
      PS_DEV_MODE: 1
      PS_ENABLE_SSL: 0
      PS_DEMO_MODE: 0
      BLACKFIRE_ENABLE: 0
      DB_SERVER: mysql
      PS_SHOP_ID: 1             # malfini_api + adwear_anda sync services (as on prod)
      PS_LANGUAGE_ID: 1
    command: /tmp/wait-for-it.sh --timeout=60 --strict mysql:3306 -- /tmp/docker_run_git.sh
    ports:
      - "$port:80"
    volumes:
      - ./:/var/www/html
      - $MAIN/img:/var/www/html/img
      - $MAIN/upload:/var/www/html/upload
      - $MAIN/download:/var/www/html/download
    networks:
      - prestashop-network

networks:
  prestashop-network:
    external: true
YAML
}

cmd_up() {
    local name="${1:-}" port="${2:-}" branch="${3:-}"
    [ -n "$name" ] && [ -n "$port" ] || die "usage: $0 up <name> <port> [branch]"
    [[ "$name" =~ ^[a-z0-9-]+$ ]] || die "name must be lowercase letters, digits, dashes (it becomes <name>.localhost)"
    [[ "$port" =~ ^[0-9]+$ ]] || die "port must be a number"
    docker image inspect "$IMAGE" >/dev/null 2>&1 || die "image $IMAGE missing — start the main stack once first"
    docker network inspect prestashop-network >/dev/null 2>&1 || die "prestashop-network missing — start the main stack first"

    local dir; dir="$(wt_path "$name")"
    local fresh=0
    [ -e "$dir/.git" ] || fresh=1

    exclude_locally

    if [ $fresh = 1 ]; then
        log "Creating worktree $dir"
        ensure_branch_worktree "$MAIN" "$dir" "${branch:-wt/$name}"
    elif [ -n "$branch" ]; then
        echo "worktree exists — ignoring branch '$branch' (currently on $(git -C "$dir" branch --show-current))"
    fi

    local repo nested_skip=""
    while read -r repo; do
        nested_skip="${nested_skip:+$nested_skip|}$repo"
        if [ ! -e "$dir/$repo/.git" ]; then
            log "Nested repo $repo -> branch wt/$name"
            ensure_branch_worktree "$MAIN/$repo" "$dir/$repo" "wt/$name"
            copy_ignored "$MAIN/$repo" "$dir/$repo"
        fi
    done < <(nested_repos)

    if [ $fresh = 1 ]; then
        log "Copying gitignored runtime files from main (vendor, modules, built assets, config) ..."
        copy_ignored "$MAIN" "$dir" \
            "^(img|upload|download)/|^var/(cache|logs|sessions)/|^docker-compose\.override\.yml$|^$COMPOSE_FILE$|^($nested_skip)/"
        mkdir -p "$dir/var/cache" "$dir/var/logs" "$dir/var/sessions"

        # .htaccess pins the image rewrites to the main domain; let any host through.
        sed -i -E 's#^(RewriteCond %\{HTTP_HOST\}) \^[^ ]+\$$#\1 .#' "$dir/.htaccess"

        log "Applying local request-host hack (skip-worktree)"
        apply_host_hack "$dir"
    fi

    write_compose "$name" "$port" "$dir"

    log "Starting adwear-$name on port $port"
    docker compose -f "$dir/$COMPOSE_FILE" up -d

    cat <<EOF

  Worktree:     $dir  ($(git -C "$dir" branch --show-current))
  Front-office: http://$name.localhost:$port/
  Back-office:  http://$name.localhost:$port/admin-dev
  Shell:        docker compose -f $dir/$COMPOSE_FILE exec -u www-data prestashop-git bash
  Logs:         docker compose -f $dir/$COMPOSE_FILE logs -f

  Shared with main: database, maildev, img/ upload/ download/.
  Module installs/upgrades, config changes and SQL migrations hit every checkout.
EOF
}

cmd_down() {
    local name="${1:-}" remove="${2:-}"
    [ -n "$name" ] || die "usage: $0 down <name> [--remove]"
    local dir; dir="$(wt_path "$name")"
    [ -e "$dir/.git" ] || die "no worktree at $dir"

    # By project name, so a missing compose file can't leave the container running.
    log "Stopping adwear-$name"
    docker compose -p "adwear-$name" down

    [ "$remove" = "--remove" ] || return 0

    # Refuse to drop uncommitted work (the skip-worktree hack files don't count).
    # A nested repo can also be a standalone clone (.git is a directory, not a
    # worktree link): it then must not hold commits or stashes that exist nowhere else.
    local repo dirty=0
    while read -r repo; do
        [ -e "$dir/$repo/.git" ] || continue
        if [ -n "$(git -C "$dir/$repo" status --porcelain)" ]; then
            echo "uncommitted changes in $dir/$repo"; dirty=1
        fi
        if [ -d "$dir/$repo/.git" ]; then
            if [ -n "$(git -C "$dir/$repo" log --branches --not --remotes --oneline)" ] \
                || [ -n "$(git -C "$dir/$repo" stash list)" ]; then
                echo "unpushed commits or stashes in standalone clone $dir/$repo"; dirty=1
            fi
        fi
    done < <(nested_repos)
    if [ -n "$(git -C "$dir" status --porcelain)" ]; then
        echo "uncommitted changes in $dir"; dirty=1
    fi
    [ $dirty = 0 ] || die "commit or discard first; nothing removed"

    while read -r repo; do
        if [ -d "$dir/$repo/.git" ]; then
            log "Removing standalone clone $repo (everything in it is on its remote)"
            rm -rf "${dir:?}/$repo"
        elif [ -e "$dir/$repo/.git" ]; then
            log "Removing nested worktree $repo (branch wt/$name kept)"
            git -C "$MAIN/$repo" worktree remove --force "$dir/$repo"
        fi
    done < <(nested_repos)

    log "Removing worktree $dir (branch kept)"
    # --force: the untracked copies (vendor, modules, ...) and the skip-worktree patch
    git -C "$MAIN" worktree remove --force "$dir"
}

cmd_list() {
    git -C "$MAIN" worktree list
    echo
    docker ps --filter "label=com.docker.compose.project" \
        --format '{{.Label "com.docker.compose.project"}}\t{{.Ports}}' | grep '^adwear-' || true
}

case "${1:-}" in
    up)   shift; cmd_up "$@" ;;
    down) shift; cmd_down "$@" ;;
    list) cmd_list ;;
    *)    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
