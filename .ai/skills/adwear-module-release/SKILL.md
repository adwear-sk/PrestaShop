---
name: adwear-module-release
description: >
  Release a custom Adwear module: version bump, upgrade script, local upgrade test, and — for a brand-new
  module — the full first rollout to prod (secrets, mount dir, VPS compose, install). Trigger: "release the
  module", "bump the module version", "roll out the new module to prod", "install module X on prod".
argument-hint: "<module_name> [new|update]"
allowed-tools: Bash, Read, Write, Edit
produces: Committed version bump + upgrade script in the module repo, and an ordered rollout checklist for the user
---

# Module release

Module repos live at `modules/<name>` (own git repo, branch `main`, remote `adwear-sk/<kebab>`).
Pushing `main` deploys it (rsync + `app` restart). **Deploys never run `upgrade/` scripts** — that's a manual step.

## Update of an existing module

1. Decide if install-time state changes (hooks, config keys, tables, tabs, mail templates). If yes:
   - bump `$this->version` (semver) in `<name>.php` (and `config.xml` if present),
   - add `upgrade/upgrade-<X.Y.Z>.php` with `function upgrade_module_<X_Y_Z>($module): bool`, idempotent.
   Pure code/template/CSS changes need no bump.
2. If the module uses Composer: `composer install` (not `dump-autoload`) in the container, or `cache:clear` breaks.
3. Test locally: `docker exec -u www-data adwearpresta-prestashop-git-1 php bin/console prestashop:module upgrade <name>`
   then `cache:clear`; render the affected page (`adwear-verify-storefront`). Local DB is a prod clone, so the
   upgrade path is realistic.
4. BO settings chosen locally don't travel — note any that need copying (scratchpad SQL via `adwear-prod-oneoff`).
5. Commit in the module repo. Don't push. Report: version, upgrade needed on prod: yes/no.

**After the user pushes** (prod): check `SELECT version FROM ps_module WHERE name='<name>'`, then run
`prestashop:module upgrade <name> --env=prod` **after** the deploy finishes (before, it no-ops and claims success);
clear CCC bundles if CSS changed.

## Brand-new module — first rollout

Scaffold with `scaffold-adwear-repo` first. Then list these for the user **up front** (Claude can't do the
starred ones — permission classifier blocks secrets, prod SSH writes and workflow dispatch):

1. ★ Deploy secrets per repo: `gh secret set SSH_HOST|SSH_USER|SSH_KEY -R adwear-sk/<repo>`
   (`178.105.70.62`, `deploy`, `< ~/.ssh/adwear-deploy`).
2. Mount dir: `/opt/adwear/custom/modules/` is root-owned — create `<name>/` via a throwaway container
   (`docker run --rm -v /opt/adwear/custom/modules:/m alpine sh -c "mkdir /m/<name> && chown <sibling uid:gid> /m/<name> && chmod 2775 /m/<name>"`).
3. Add the bind mount to `deploy/docker-compose.yml` (commit) **and** ★ by hand on the VPS copy
   (`cp` backup, then edit; Claude verifies with `diff` + `docker compose config -q`).
4. ★ Apply the mount by re-releasing the live image (no build; all post-recreate steps run):
   `ssh … 'cd /opt/adwear && ./release.sh "$(sed -n "s/^APP_IMAGE=//p" .env)"'` — or push `production` if it has
   commits to ship anyway. **Never** a bare `docker compose up -d app` — recreating the container
   wipes `.htaccess`, `translations/sk-SK` and module mail templates.
5. ★ Push the module `main`; wait for its deploy.
6. CMS pages the module links to must exist first. Then install:
   `docker compose exec -T -u www-data app php bin/console prestashop:module install <name> --env=prod`,
   then `rm -rf var/cache/*`, `cache:clear --env=prod`, `docker compose restart app`.
7. Verify read-only and record the rollout in memory (module, date, anything left unset on prod).
