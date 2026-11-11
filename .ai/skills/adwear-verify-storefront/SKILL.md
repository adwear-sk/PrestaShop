---
name: adwear-verify-storefront
description: >
  Screenshot Adwear storefront pages at 1440 and 390 px with Playwright (Docker) and flag HTTP errors,
  horizontal overflow, Smarty fatals and JS errors. Trigger: "verify the page", "take screenshots",
  "check it on mobile", "does it overflow", after any visible theme/module change.
argument-hint: "<url> [url...]"
allowed-tools: Bash, Read
produces: PNG screenshots in the scratchpad + a pass/fail line per URL and width
---

# Verify storefront pages

## Steps

1. **Prepare the page state.** After Smarty/template changes clear caches first:
   `docker exec -u www-data adwearpresta-prestashop-git-1 php -r "require '/var/www/html/config/config.inc.php'; Tools::clearSmartyCache();"`
   (worktree: container `adwear-wtN-prestashop-git-1`). After SCSS/TS changes, `npm run build` in `themes/adwear` first.
2. **Pick URLs.** Main checkout `http://localhost:8001/…`, worktrees `http://wtN.localhost:80N1/…`,
   prod `https://www.adwear.sk/…` (read-only comparison). Cover every page type the change touches
   (home, category, product, cart, checkout, account…), not just one.
3. **Run:** `.ai/skills/adwear-verify-storefront/shot.sh <scratchpad>/shots <url> [url...]`
   — prints `ok`/`FAIL` per width with status, overflow px, fatal flag, JS error count and PNG path.
   Exit code 1 if anything failed.
4. **Look at the screenshots** with Read — numbers don't catch visual regressions. Compare against prod when
   the question is "did I change something else?".
5. **Report** exactly what was checked (URLs × widths) and paste the result lines. Say "screenshot-verified",
   not "browser-tested", unless interactions were exercised.

## Interactions (hover, flyouts, checkout steps)

`shot.mjs` only loads pages. For interactions copy it to the scratchpad, add the steps, and run it the same
way (`docker run … mcr.microsoft.com/playwright:v1.48.2-jammy`, `--network host`). Keep the Chrome user agent —
the shop treats headless UAs as bots and serves **no cart**.

## Gotchas

- Local dev mode prints a psgdpr `Deprecated: sha1()` notice in the newsletter consent that adds ~42 px overflow
  at 320 px (2 px at 360). Prod has no notices — compare with prod before blaming the layout.
- Test data (customers, orders, carts) only locally, with `claude-*@example.invalid` e-mails; delete afterwards.
- Pinned image/version `v1.48.2` must match the npm `playwright@1.48.2` cached in `~/.cache/adwear-playwright`.
