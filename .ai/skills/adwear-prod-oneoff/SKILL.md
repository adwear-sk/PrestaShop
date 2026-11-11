---
name: adwear-prod-oneoff
description: >
  Run a one-time data fix or PHP/SQL script on production www.adwear.sk: write it in the scratchpad, prove it
  locally, then hand the user a paste-ready `!` command. Trigger: "fix this on prod", "run this on the live shop",
  "update the CMS page on prod", "clean up X in the prod DB".
argument-hint: "<what-to-fix>"
allowed-tools: Bash, Read, Write
produces: A scratchpad script tested locally + a short `! …` command for the user to run against prod
---

# One-off prod change

One-time scripts are **never stored in the repo** (no new files under `deploy/` for ad-hoc fixes).
Persistent data that every future prod must have belongs in `adwear-deploy-sql` instead.

## Prod facts

- SSH: `deploy@178.105.70.62`, stack in `/opt/adwear`, services `app`, `mysql`, `caddy`.
- PHP in the app: `docker compose exec -T -u www-data app php …`; CLI needs `SYMFONY_ENV=prod` / `--env=prod`.
- Claude's SSH **writes** to prod are blocked by the permission classifier — the user runs the write step.
  Read-only SSH (logs, `SELECT`, `docker compose ps`) is fine for Claude.

## Steps

1. **Write** the script in the scratchpad. Idempotent (safe to run twice), prints what it changed.
   PHP: `require '/var/www/html/config/config.inc.php';` at the top; prefer CQRS commands
   (e.g. `EditCmsPageCommand` via the kernel's command bus) over raw SQL for entities with caches/hooks.
2. **Run locally** against the dev container (`adwearpresta-prestashop-git-1`, `-u www-data`) — local DB is a
   prod clone. Run twice; second run must change nothing. Check the result renders.
3. **Snapshot first** for destructive changes: have the script print the affected rows before changing them,
   or tell the user to run `/opt/adwear/backup.sh` first.
4. **Hand over** a command the user can paste. Keep each line < ~110 chars (wrapped lines break on copy).
   Single step:
   ```
   ! scp <abs-scratch-path>/fix.php deploy@178.105.70.62:/tmp/fix.php
   ! ssh deploy@178.105.70.62 'cd /opt/adwear && docker compose cp /tmp/fix.php app:/tmp/fix.php && docker compose exec -T -u www-data app php /tmp/fix.php'
   ```
   Multi-step: write `<scratchpad>/run-prod.sh` (one `ssh` per step, stdin `< /dev/null` — `docker compose exec -T`
   inside a heredoc swallows the rest of the script) and give `! bash <abs-path>/run-prod.sh`.
5. **After it runs**: clear what the change touches (`Tools::clearSmartyCache()`, `rm -rf var/cache/prod/*` +
   `cache:clear --env=prod`), verify read-only (curl the page / `SELECT`), then discard the script.
