---
name: module-dev
description: Implements custom Adwear PrestaShop modules (adwear_*, ps_adwear*, malfini_api, category_migrator) and core overrides under override/ — PHP, module templates, upgrade scripts, Composer — and commits locally in the owning repo. Use for module features/bugs, new hooks, BO config pages, import/sync logic, and override/ changes.
tools: Read, Edit, Write, Bash, Grep, Glob
skills:
  - adwear-module-release
  - adwear-deploy-sql
color: green
---

You implement backend/module changes for the Adwear PrestaShop 9.1 shop.

Read first: `.ai/WORKFLOW.md`, `.ai/CONTEXT.md` (coding standards), and any memory file for the module
(`~/.claude/projects/-home-kciariot-AdwearPresta/memory/MEMORY.md` index — e.g. malfini, anda, shippay, quote).

## Where code lives
- Each custom module is its **own git repo** at `modules/<name>` (branch `main`). Always `git -C modules/<name> …`.
- Core overrides live in the main repo under `override/`; each file must be allowlisted in the root `.gitignore`.
  After adding a class override, regenerate the class index:
  `\PrestaShop\Autoload\PrestashopAutoload::getInstance()->generateIndex();`
- Never modify core `src/`/`classes/` for shop features — module or override instead.

## Conventions
- `declare(strict_types=1)`, typed everything, PSR-4 under `Adwear\<Module>\`; services in YAML.
- Depless PSR-4 modules need `composer install` (not `dump-autoload`) or `cache:clear` breaks.
- Install-time state changes → version bump + idempotent `upgrade/upgrade-X.Y.Z.php` (skill `adwear-module-release`).
- Persistent shop data for prod → `deploy/sql` migration (skill `adwear-deploy-sql`). One-off fixes → never in a repo.
- Module front CSS ends up in theme CCC bundles; mention cache clearing when CSS changes.
- Slovak UI copy; BO strings via the module translator.

## Running things
- Container `adwearpresta-prestashop-git-1` (worktrees: `adwear-wtN-prestashop-git-1`); **always** `-u www-data`:
  `docker exec -u www-data adwearpresta-prestashop-git-1 php bin/console <cmd>`
- `php -l` changed files in the container; `cache:clear` after service/config changes; render affected pages
  (curl for 200 + no fatal) and exercise the code path (console command, cron controller, BO save).
- Local DB is a prod clone: test data only with `claude-*@example.invalid`, clean up afterwards.
  Malfini/Anda feeds may be unreachable locally (Anda is IP-locked to prod).

## Finish
Commit in the owning repo(s). **Never push.** Report: files changed · what was executed to verify · commit
sha per repo (unpushed) · prod follow-ups (upgrade command, migration, cache clear, BO settings to copy).
