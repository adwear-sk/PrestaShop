---
name: adwear-assignee
description: >
  Run this session as a board assignee (wt1, wt2, wt3): resume from the progress log, work only on board items
  assigned to it, code in its own worktree, keep research in an untracked folder, write back to its own board docs.
  Trigger: "start work as assignee wt1", "you are wt2", "continue as wt3".
argument-hint: "<wt1|wt2|wt3>"
allowed-tools: Bash, Read, Write, Edit
produces: Progress in .ai/work/<assignee>/, commits on wt/<assignee> branches, updated steps/questions on own board items
---

# Assignee session

Several Claude sessions can work the board in parallel, one per assignee. This session is one of them. It never
picks up unassigned work, never pushes, and never touches the shared database's structure or config. Rules for
everyone else are in [WORKFLOW](../../WORKFLOW.md) §2 and [`adwear-task-board`](../adwear-task-board/SKILL.md) (Who writes).

## 1. Bind

| Assignee | Checkout | Storefront | Findings + progress |
|---|---|---|---|
| `wtN` | `/home/kciariot/AdwearPresta-wtN` (branch `wt/wtN` in main and every nested repo) | `http://wtN.localhost:80N1` | `/home/kciariot/AdwearPresta/.ai/work/wtN/` |

- `bin/worktree.sh list` (run from main) shows whether the worktree is up. Needed for code and missing →
  `bin/worktree.sh up wtN 80N1`. Research-only items need no worktree.
- Console in the worktree: `docker compose -f /home/kciariot/AdwearPresta-wtN/docker-compose.worktree.yml exec -u www-data prestashop-git php bin/console …`.
- Say which assignee and checkout you are bound to in your first reply.

## 2. Resume

1. Read `.ai/work/<a>/progress.md` (create it with a header if missing). The last entry says where you stopped.
2. `git -C <checkout> status` plus the same for `themes/adwear` and each `modules/*` repo in the checkout:
   uncommitted work from an earlier session is yours to finish or explain — never discard it.
3. Load `ArtifactData` (ToolSearch `select:ArtifactData`). Query `items` where `assignee` == `<a>`; for each, read
   its steps (`steps` where `itemId` ==), questions (`questions` where `itemId` ==) and `analyses/<itemId>`.
   Save the dump under `.ai/work/<a>/board/` (gitignored; the /tmp scratchpad dies on WSL restarts). Re-read before
   each write — other sessions and the page change the board. Also read `meta/goal` (incl. `launch`).

## 3. Pick

- The item you already claimed (`claimedAt` set, not done) comes first; otherwise the assigned `launch: pre` item
  with the lowest `queueOrder`, then `post` ones. **One item at a time.**
- Nothing assigned → say so and stop. Never take an unassigned item or another assignee's item.

## 4. Gates (same as the main session)

- Open **blocking** question on the item → report it and stop.
- `phase` empty/`analyzing` on a build or fix → run the `analyzer` agent with the board dump, write
  `analyses/<itemId>` + questions, set `phase: choose`, stop. `phase: choose` → stop; the user picks.
- `kind: check` (or a plain investigation) → investigate and report; no analysis needed.
- `planned` / `working` → take the lowest-order `todo` step; stop after a `checkpoint` step.

## 5. Claim and work

- Claim: set `claimedAt`, `status: doing`, `phase: working` on the item (pinned with `if_version`).
- Work the step with the WORKFLOW loop **inside your checkout** (implement → verify → review → commit on `wt/<a>`).
  The **`reviewer` agent is required** on every code diff before the step is done — record its verdict in `verified`.
  Core edits and overrides are flagged (`CORE CHANGE:` / `OVERRIDE:`) — module first.
- **Hand to main, don't do:** module install/upgrade/uninstall, configuration writes, running `deploy/sql`,
  category/product data changes on the shared DB, `bin/pull-prod.sh`, anything on prod beyond read-only. You may
  write the migration or script in your checkout and test it read-only; main runs it. Write a step-note line
  `NEEDS MAIN: <what, exact command/file, why>`, leave the step `doing`, report, stop.
- **Findings about other items** (you can't write those docs): add a line to **your own item's** `note` starting
  `NEEDS MAIN: <target doc> — <full text to copy>`, plus the same line in `progress.md`. Main copies it over and
  clears the line. New items you think are needed: same way, with the proposed `launch` (default `post`; `pre`
  only with the L1–L6 criterion it breaks — main asks the user).
- Never push, never merge into `production`/`main` — integration is main's job.

## 6. Write back (after every step)

- Step → `status: done`, `commit: "<repo>:<sha>"` (labels as on existing steps: `main`, `theme`, the module dir name
  such as `malfini_api`), `verified` (what was actually checked), `note` starting with `branch wt/<a>` so main
  knows it awaits integration. Research: the full write-up in `.ai/work/<a>/<itemId>.md`, a summary plus that path
  in the step note.
- New questions → `questions/<itemId>-qN` right away (triage as in `adwear-analyze` step 6).
- All steps done → **rebase first**: in each repo you committed in, `git rebase <main tip>` (main's current
  `production`/`main` branch in the main checkout) so main can fast-forward and the shas you record stay valid;
  re-run the checks if the rebase touched your files, update `commit` on the steps. Then the item `note` gets
  `READY TO INTEGRATE (wt/<a>)`; main merges and sets the item done.
- `version_mismatch` → re-read the doc, merge your change into what it holds now, retry. Never write blind.
- **Timestamps** (`updatedAt`, `claimedAt`, progress entries) come from `date -u +%Y-%m-%dT%H:%M:%SZ` — never
  guess or round them.
- Append to `progress.md`: date, item, step, outcome, next action.

## 7. Report

End with: item and step, what changed, what was verified, commits on `wt/<a>`, anything handed to main, and the
next step (or "stopped at checkpoint").
