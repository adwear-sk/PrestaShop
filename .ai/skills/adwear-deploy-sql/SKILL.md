---
name: adwear-deploy-sql
description: >
  Write a `deploy/sql` data migration that the prod deploy applies once, and prove it is idempotent locally.
  Trigger: "add a migration", "ship this config/CMS/link change to prod", "make this DB change deployable".
argument-hint: "<what-it-changes>"
allowed-tools: Bash, Read, Write, Edit
produces: deploy/sql/YYYY-MM-DD-<what>.sql, run twice locally with 0 changes on the second run
---

# deploy/sql migration

`deploy/migrate.sh` applies `deploy/sql/*.sql` on prod in filename order, **once each**, recording names in
`adwear_migration`. A failing file stops the deploy and is retried next deploy.

## When to use (vs. alternatives)

| Change | Where |
|--------|-------|
| Persistent shop data prod must have (config, CMS text, link blocks, hook positions, states) | **this skill** |
| One-time cleanup/repair that only matters once | `adwear-prod-oneoff` (never in the repo) |
| Module install-time state | module `install()` / `upgrade/` script (`adwear-module-release`) |
| Core string wording | theme `translations/sk-SK/*.xlf` override, not SQL |

## Rules

- Name `deploy/sql/YYYY-MM-DD-<kebab-what>.sql` (today's date). **Never edit a file that has shipped** — add a new one.
- Use the `ps_` prefix literally (prod uses it too). Plain SQL only — no shell, no PHP.
- Must be **idempotent by construction**: guard with `WHERE` on the old value, `INSERT … SELECT … WHERE NOT EXISTS`,
  `ON DUPLICATE KEY UPDATE`, never blind `INSERT`.
- Text guards need `COLLATE utf8mb4_bin` — the DB is accent-insensitive, so `WHERE value = 'Sečovska'` also matches
  the fixed `'Sečovská'` and rewrites the row every run.
- Multilang rows: cover every `id_lang` (the shop is SK-only today, but don't hardcode `id_lang = 1` blindly — join `ps_lang`).
- Configuration: update `ps_configuration` for all scopes that exist (`id_shop`/`id_shop_group` NULL and per-shop rows).
- Header comment: one line on what and why.

## Test locally (required)

```bash
f=deploy/sql/<file>.sql
for i in 1 2; do docker exec -i adwearpresta-mysql-1 mysql -uroot -p"$PW" -vv prestashop < "$f" | grep -E 'affected|Changed|Records'; done
```
(`$PW` = `database_password` from `app/config/parameters.php`.) Run 1 changes what you expect; **run 2 must report
`Changed: 0` / `0 rows affected` everywhere**. Then check the front/BO shows the change (clear Smarty cache if it renders).

## Then

Commit in the main repo (`production` branch). It ships with the next main-repo deploy — tell the user it's queued.
