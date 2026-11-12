---
name: adwear-ship-plan
description: >
  Survey committed-but-unpushed and uncommitted work across the main repo, the adwear theme and every custom
  module repo, then produce an ordered bulk-push plan with paste-ready commands and post-deploy steps.
  Trigger: "what's queued", "what's unpushed", "ship it", "push in bulk", "prepare the deploy".
allowed-tools: Bash, Read
produces: Per-repo queue summary + ordered ship plan (commands for the user; nothing is pushed by this skill)
---

# Ship plan

Pushing **is** deploying: main `production` → CI image `:<sha>` → `/opt/adwear/release.sh <image>:<sha>` on the VPS
(pins the image in `.env`, recreates `app`, runs `deploy/sql` migrations, crontab and every post-recreate step);
module/theme `main` → rsync + `app` restart (the pinned image stays). This skill never pushes — the user decides.

## 1. Survey

`.ai/skills/adwear-ship-plan/ship-status.sh` (pass a worktree root to survey `~/AdwearPresta-wtN`).
Prints only repos with unpushed commits or a dirty tree. Uncommitted changes are **not shippable** — call them out.
Worktree branches (`wt/<name>`) must be merged into `production` / `main` before they ship; list them separately.

## 2. Classify what each queued commit needs on prod

Read each unpushed diff (`git -C <repo> show --stat <sha>`) and flag:

| Signal in diff | Post-deploy need |
|----------------|------------------|
| new `deploy/sql/*.sql` | runs automatically in the main deploy — check it was run-twice tested |
| `deploy/docker-compose.yml` | **not** synced by CI — user edits the VPS copy by hand, then the main deploy (or a re-release, §5) applies it |
| `Caddyfile`, `caddy/` | **not** synced, and `release.sh` never touches caddy — edit in place, then `docker compose up -d --no-deps --no-build caddy` (`deploy/README.md`) |
| `deploy/release.sh`, `migrate.sh`, host scripts, `crontab` | synced by the main deploy before `release.sh` runs — no extra step |
| module `$this->version` bump / new `upgrade/` file | `prestashop:module upgrade <name> --env=prod` **after** that module's deploy |
| module CSS/JS changed | clear CCC bundles: `Media::clearCache()` + `Tools::clearSmartyCache()` (workflow does it if pushed recently — verify) |
| brand-new module repo | full rollout via `adwear-module-release` (secrets, mount dir, compose, install) |
| theme `translations/*.xlf` | `rm -rf var/cache/prod/translations` |
| hooks / module positions | check the migration or BO step is included |

## 3. Order

1. Main repo `production` (compose/infra/migrations other repos depend on) — wait for the run to finish.
2. Modules, **one at a time** (each restarts `app`; parallel runs die with exit 143). Wait for each.
3. Theme last (its CCC bundles pick up module CSS changes).
4. Post-deploy steps from §2, then read-only verification (curl key pages, grep the live CCC css for a new class).

## 4. Output

```
Queued:   <repo>: <n> commits — <one-line themes>
Blocked:  <repo>: uncommitted / unmerged wt branch / untested migration
Plan:
  1. ! git -C /home/kciariot/AdwearPresta push origin production      → watch: gh run watch -R adwear-sk/PrestaShop
  2. ! git -C /home/kciariot/AdwearPresta/modules/<m> push origin main
  …
After:    <post-deploy commands, one per line, < 110 chars>
```

Use absolute paths in every `!` command (the shell's cwd may be a nested repo). When the user approves and runs
pushes, watch runs with `gh run watch` / `gh run list -R adwear-sk/<repo>` and report outcomes faithfully.
After a main deploy, confirm the release line: `ssh … '/opt/adwear/release.sh list | tail -n 2'` (read-only).

## 5. Release, re-release, rollback (main app only)

All run as `deploy` (never root — the crontab would install for root) via
`! ssh -i ~/.ssh/adwear-deploy deploy@178.105.70.62 '<cmd>'`. Claude can't run them; hand the user the command.

| Need | Command on the VPS |
|------|--------------------|
| What is live / history | `/opt/adwear/release.sh list` (newest last; `.env` `APP_IMAGE` = live `:<sha>`) |
| Bad main deploy | `/opt/adwear/release.sh rollback` — previous image, kept on disk, no pull; run again to return |
| Older release | `release.sh ghcr.io/adwear-sk/prestashop:<sha>` (pulls from GHCR if pruned locally) |
| Apply a hand-edited compose file without a new image | `cd /opt/adwear && ./release.sh "$(sed -n "s/^APP_IMAGE=//p" .env)"` (re-releases the live image) |

- **Never** edit `APP_IMAGE` + `docker compose up -d app` by hand, or a bare `compose up`: it skips `.htaccess`
  (product/category 404s), robots.txt, translations, mails and the cache clear.
- A rollback reverts the app image only — applied `deploy/sql` migrations, the crontab and host scripts stay at the
  newer version. If a migration is the problem, ship a new forward migration.
- Module/theme deploys don't go through `release.sh`; roll those back by pushing a revert commit to their `main`.
