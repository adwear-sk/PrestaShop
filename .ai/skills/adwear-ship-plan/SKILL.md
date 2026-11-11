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

Pushing **is** deploying: main `production` → CI image + VPS deploy (incl. `deploy/sql` migrations, crontab);
module/theme `main` → rsync + `app` restart. This skill never pushes — the user decides.

## 1. Survey

`.ai/skills/adwear-ship-plan/ship-status.sh` (pass a worktree root to survey `~/AdwearPresta-wtN`).
Prints only repos with unpushed commits or a dirty tree. Uncommitted changes are **not shippable** — call them out.
Worktree branches (`wt/<name>`) must be merged into `production` / `main` before they ship; list them separately.

## 2. Classify what each queued commit needs on prod

Read each unpushed diff (`git -C <repo> show --stat <sha>`) and flag:

| Signal in diff | Post-deploy need |
|----------------|------------------|
| new `deploy/sql/*.sql` | runs automatically in the main deploy — check it was run-twice tested |
| `deploy/docker-compose.yml`, `Caddyfile`, `caddy/` | **not** synced by CI — user edits VPS copy by hand (see `deploy/README.md`), then a full deploy |
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
