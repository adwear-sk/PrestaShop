# Adwear — Definitive Change Workflow

> Applies to every change in this Adwear fork (theme, custom modules, overrides, deploy/sql, prod ops).
> Start at §0 — nothing is implemented before a path is chosen.
> Core PrestaShop conventions still live in [CONTEXT.md](CONTEXT.md); this file says *how work flows*.

## 0. Intake → Analyze → Choose → Plan (always first)

```
request (= idea) → analyzer: goal check + every usable path → board + chat → STOP
   → user chooses path + stopping points → steps on the board → per step: the loop below → stop at checkpoints
```

- A new request is an **idea to explore**, never an instruction to build what was named — even in auto mode.
- Run the `analyzer` agent (skill `adwear-analyze`) first: does the goal make sense (`sound` / `reframe` / `doubtful`),
  then **all** usable alternatives — no fixed count — including ones different from the user's idea, plus
  rejected ones with reasons. Write the result to the task board, then **stop and wait** for the user's choice.
- Presenting: ≤ 5 usable paths → all in chat with strengths/weaknesses; > 5 → goal check, top 3, counts and the
  board link (full list lives on the board).
- After the choice: ask for stopping points if not given, write the steps (with checkpoints) to the board.
  Then each step runs through the loop below; stop at every checkpoint and report.
- **No work on a task while it has an open blocking question.** New questions go on the board immediately.
- **Bypass only** when the user explicitly says so ("just do it", "skip analysis"), or for "next step" on an
  approved tasklist. Plain questions get a direct answer; investigations report findings.

### Task board

The true goal, analyses, chosen paths, steps and questions live in the **Launch Readiness** artifact:
https://claude.ai/artifact/KsMrS3dk7cnLtxZYYMweEt — schema and operations in
[`adwear-task-board`](skills/adwear-task-board/SKILL.md). Check its true goal before recommending a direction.

## The loop (per step)

```
1 Classify → 2 Locate repo → 3 Implement → 4 Verify → 5 Review → 6 Commit locally → 7 Report queue
                                                                    (8 Ship — only when the user says so)
```

### 1. Classify the request

| Kind | Owning repo | Agent (Claude Code) | Verify with |
|------|-------------|---------------------|-------------|
| Storefront look / templates / JS | `themes/adwear` (adwear-sk/adwear-theme) | `theme-dev` | build + lint + `adwear-verify-storefront` |
| Custom module (`adwear_*`, `ps_adwear*`, `malfini_api`, `category_migrator`) | `modules/<name>` (own repo) | `module-dev` | php -l, cache clear, render check |
| Core override (`override/**`) | main repo (allowlist each file in `.gitignore`) | `module-dev` | class index regen + render check |
| Shop data that must reach prod (config, CMS, link blocks) | main repo `deploy/sql/` | any, via `adwear-deploy-sql` | run twice locally, 2nd = `Changed: 0` |
| One-off data fix on prod | **no repo** (scratchpad only) | any, via `adwear-prod-oneoff` | run locally first |
| Prod diagnosis (outage, crons, disk, logs) | none | `prod-investigator` (read-only) | — |
| Investigation ("why does…", "check…") | none | Explore / main agent | report findings **before** changing anything |

### 2. Locate the owning repo

- Theme and custom modules are **independent nested git repos**, gitignored by the main repo — not submodules.
  A clean `git status` at the root proves nothing; always use `git -C <repo> status`.
- Parallel work goes in a worktree: `bin/worktree.sh up wtN 80N1` → `http://wtN.localhost:80N1`
  (shared DB — module installs/config changes hit every checkout).

### 3. Implement

- Read the memory/notes for the area first (styling guide for theme work, rollout notes for modules).
- Theme: edit `src/`, never built assets. Forms use `adw-form`; icons `material-icons-outlined`;
  Slovak copy hardcoded, core strings keep `{l s=… d=…}`; keep every `js-*` / `data-ps-*` hook.
- Modules: bump `$this->version` + add `upgrade/upgrade-X.Y.Z.php` when install-time state changes.
- Never edit a shipped `deploy/sql` file; add a new one.
- No ad-hoc scripts in the repo — scratchpad only.

### 4. Verify (proportionate, but never skipped)

| Changed | Minimum check |
|---------|---------------|
| SCSS/TS | `npm run build` (Node 20) + `npx stylelint`/`npx eslint` on changed files |
| Smarty | `Tools::clearSmartyCache()` + render the page (HTTP 200, no Smarty fatal) |
| Visible UI | screenshots at **1440** and **390**, no horizontal scroll (`adwear-verify-storefront`) |
| PHP | `php -l` in the container; `cache:clear` as `www-data` |
| deploy/sql | run twice, second run changes 0 rows |

State what was actually checked: "built + rendered" ≠ "verified in a browser".

### 5. Review

Before committing a non-trivial change, run the `reviewer` agent on the owning repo's diff.
Fix CONFIRMED findings; mention PLAUSIBLE ones to the user.

### 6. Commit locally

- Commit in the owning repo with a short imperative subject (match `git log` style).
- **Never push** the theme, module repos or main `production` — pushes deploy. The user batches pushes.
- Preserve unrelated local changes; don't commit files you didn't touch.

### 7. Report the queue

End every change with: what changed, what was verified, and what is **committed but unpushed** per repo
(the `ship-planner` agent / `adwear-ship-plan` skill produces this across all repos).

### 8. Ship (only on explicit request)

`adwear-ship-plan` gives the order and paste-ready commands. Rules of thumb:
- main `production` first if a module needs new compose mounts or migrations; then modules **one at a time**
  (each deploy restarts `app`); then theme.
- After a module deploy that changes CSS: clear CCC bundles; after a version bump: run
  `prestashop:module upgrade <name> --env=prod` **after** the deploy finishes.
- Claude cannot push to prod over SSH writes / dispatch workflows / set secrets — hand the user `! …`
  commands (< 110 chars each, or a scratchpad script for multi-step work) and watch with `gh run watch`.

## Agents & skills at a glance

| Agent | Role | Writes code? |
|-------|------|--------------|
| `analyzer` | Runs first: goal check + every usable path, returns board JSON | no |
| `theme-dev` | Implements storefront changes in `themes/adwear` | yes |
| `module-dev` | Implements custom modules and core overrides | yes |
| `ui-verifier` | Screenshots + overflow checks, reports | no |
| `reviewer` | Reviews a repo diff against Adwear conventions | no |
| `ship-planner` | Lists unpushed work across repos, builds the ship plan | no |
| `prod-investigator` | Read-only diagnostics on the VPS | no |

| Skill | Use for |
|-------|---------|
| [`adwear-analyze`](skills/adwear-analyze/SKILL.md) | Goal check + exhaustive path analysis before any work |
| [`adwear-task-board`](skills/adwear-task-board/SKILL.md) | Board pointer + schema; write analyses/steps/questions, follow steps |
| [`adwear-verify-storefront`](skills/adwear-verify-storefront/SKILL.md) | Playwright screenshots / overflow check of local or prod pages |
| [`adwear-deploy-sql`](skills/adwear-deploy-sql/SKILL.md) | Writing + idempotency-testing a `deploy/sql` migration |
| [`adwear-prod-oneoff`](skills/adwear-prod-oneoff/SKILL.md) | One-time prod data fixes via scratchpad script + paste-ready command |
| [`adwear-ship-plan`](skills/adwear-ship-plan/SKILL.md) | Survey unpushed commits, ordered bulk-push plan |
| [`adwear-module-release`](skills/adwear-module-release/SKILL.md) | Version bump, upgrade script, new-module prod rollout |
| [`scaffold-adwear-repo`](skills/scaffold-adwear-repo/SKILL.md) | New module/theme repo |

**When to delegate:** the `analyzer` always runs as an agent (keeps the exploration out of the main context). Otherwise spawn agents for self-contained work with a small result (verification, review,
ship survey, prod diagnosis) or for parallel independent changes in separate worktrees. Small edits stay inline.
