---
name: scaffold-adwear-repo
description: >
  Scaffold a new standalone Adwear repo (PrestaShop module, theme, etc.) nested in this
  PrestaShop tree, then init git, create a private GitHub repo under the adwear-sk org, and
  push. Trigger: "create a new module", "scaffold a theme", "new adwear module/theme/repo",
  "set up a repo like malfini_api".
argument-hint: "[module|theme] [name]"
allowed-tools: Bash, Read, Write, Edit
produces: A standalone git repo under modules/ or themes/ with origin set to adwear-sk and main pushed
---

# Scaffold a new Adwear repo

Creates a new Adwear-owned artifact (module, theme, …) as its **own independent git repo**
nested inside this PrestaShop checkout, then publishes it as a **private** repo under the
`adwear-sk` GitHub org. Mirrors the existing `modules/malfini_api` and `modules/category_migrator`.

## Key facts (do not violate)

- These artifacts are **independent nested git repos, NOT git submodules**. The parent tree
  gitignores `modules/*` (and themes), so the nested repo is invisible to the parent — it
  lives and versions entirely on its own.
- Default branch is **`main`**.
- GitHub repos are **private**, under the **`adwear-sk`** org, with an **SSH** remote:
  `git@github.com:adwear-sk/<repo>.git`.
- Reference existing examples before writing files: `modules/malfini_api/` (full-featured) and
  `modules/category_migrator/` (minimal scaffold).

## Inputs

- `$1` — kind: `module` or `theme` (default `module` if only one arg given).
- `$2` — name in `snake_case` (e.g. `category_migrator`).

If a required input is missing, ask with `AskUserQuestion`. Derive every other name from the
snake_case name — confirm the derived names with the user before creating the GitHub repo:

| Thing | Rule | Example (`category_migrator`) |
|-------|------|-------------------------------|
| Module dir / `$this->name` | snake_case as given | `category_migrator` |
| PHP class | `Snake_Case` (ucfirst each part) | `Category_Migrator` |
| Composer package | `adwear/<kebab-case>` | `adwear/category-migrator` |
| PSR-4 namespace | `Adwear\<PascalCase>\` | `Adwear\CategoryMigrator\` |
| GitHub repo | `adwear-sk/<kebab-case>` | `adwear-sk/category-migrator` |

## Steps

### 1. Pre-flight

- Confirm `gh` is installed and authenticated: `gh auth status`. If not logged in, stop and
  ask the user to run `! gh auth login` (interactive — you cannot drive it). The account/token
  must have access to the `adwear-sk` org.
- Check the target path is free: `modules/<name>/` (or `themes/<name>/`).

### 2. Scaffold files (module)

Create `modules/<name>/` with these files. Keep the scaffold **lean** — no controllers,
routes, BO tab, or DB tables until the module's purpose is known.

`composer.json`:
```json
{
  "name": "adwear/<kebab>",
  "description": "<one-line description>",
  "type": "prestashop-module",
  "license": "proprietary",
  "autoload": {
    "psr-4": {
      "Adwear\\<PascalCase>\\": "src/"
    }
  },
  "require": {
    "php": ">=8.1"
  }
}
```

`.gitignore`:
```
vendor/
.env
```

> ⚠️ Because `vendor/` is gitignored, **any deploy/CI for this module MUST run
> `composer install` before shipping** — even with zero third-party deps. That step
> generates `vendor/autoload.php`, which registers the `Adwear\<PascalCase>\` PSR-4
> namespace. Without it, Symfony can't autoload the module's classes when compiling
> the admin container, so the container fails to build and **every** back-office page
> 500s. `composer dump-autoload` alone is not enough — use the full `composer install`.

`<name>.php` (main module class):
```php
<?php

declare(strict_types=1);

if (!defined('_PS_VERSION_')) {
    exit;
}

$autoload = __DIR__ . '/vendor/autoload.php';
if (file_exists($autoload)) {
    require_once $autoload;
}

class <Snake_Case> extends Module
{
    public function __construct()
    {
        $this->name = '<name>';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Adwear';
        $this->need_instance = 0;

        parent::__construct();

        $this->displayName = $this->l('<Display Name>');
        $this->description = $this->l('<description>');
        $this->ps_versions_compliancy = ['min' => '9.0.0', 'max' => _PS_VERSION_];
    }

    public function install(): bool
    {
        return parent::install();
    }

    public function uninstall(): bool
    {
        return parent::uninstall();
    }
}
```

`config/services.yml`:
```yaml
services:
  _defaults:
    autowire: true
    autoconfigure: true
    public: true

  Adwear\<PascalCase>\:
    resource: '../src/'
```

`README.md` — short title + one-line purpose + "Initial scaffold" status note. Create an empty
`src/` (and `config/`) directory.

> For a **theme** instead of a module, the internal file layout differs (theme.yml, templates,
> assets — model it on an existing PrestaShop theme under `themes/`), but the git + GitHub +
> push workflow in steps 3–4 is identical.

### 3. Init the nested git repo

```bash
cd modules/<name>
git init -q
git add -A
git branch -M main
git commit -q -m "Initial scaffold: <Display Name> module skeleton

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
git remote add origin git@github.com:adwear-sk/<kebab>.git
```

### 4. Create the GitHub repo and push

```bash
gh repo create adwear-sk/<kebab> --private
git push -u origin main
```

`gh repo create` only creates the empty remote — the `origin` remote is already set in step 3,
so push separately rather than using `--source`/`--push` (keeps the SSH remote intact instead of
letting gh rewrite it to HTTPS).

## Output

Report: the created path, the GitHub URL, visibility, and that `main` is pushed and tracking.
Then note the scaffold is intentionally minimal and ask what the artifact should do before
building further.
