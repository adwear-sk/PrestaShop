---
name: adwear-retro
description: >
  Session retro for the Adwear AI tooling: find what in this session (or a set of past sessions) is worth saving
  as a new or extended skill, agent or memory note, and what existing memory is now stale. Proposals only.
  Trigger: "retro", "anything worth saving?", "what should become a skill/agent", before ending a long session.
argument-hint: "[sweep <N sessions | since YYYY-MM-DD>]"
allowed-tools: Read, Grep, Glob, Bash
produces: A ranked proposal list in chat; the ones the user picks go on the task board as `tooling` items
---

# Retro: what is worth saving?

Proposals only — never write a skill, agent or memory note here. Whatever the user picks becomes a board item
and goes through WORKFLOW §0 like any other change (`create-skill` for the build).

## Modes

- **Session (default)** — run inline by the main agent; it already holds the session. Best right before a
  compaction or the end of a long session (after a compaction only the summary is left).
- **Sweep** (`sweep 5`, `sweep since 2026-11-01`) — spawn a general-purpose agent over the transcripts in
  `~/.claude/projects/-home-kciariot-AdwearPresta/*.jsonl` (some are > 100 MB: extract user prompts and tool
  commands with python, never read whole files). It returns candidates with evidence; the main agent presents.

## Steps

1. **Collect signals** from the session (or sweep):
   - procedures done more than once, or multi-step command sequences likely to recur;
   - non-obvious fixes and gotchas (something failed, then a specific workaround worked);
   - user corrections and stated preferences ("don't…", "always…", "next time…");
   - prompts an agent had to rebuild context for, or work that would have been cheaper as a delegated agent.
2. **Check coverage** — for each signal grep `.ai/skills/*/SKILL.md`, `.claude/agents/*.md`, `.ai/WORKFLOW.md`
   and the memory index + notes (`~/.claude/projects/-home-kciariot-AdwearPresta/memory/`). Also check the task
   board items: if a board item already plans it (runbook, smoke test, rollback…), it's covered — say so.
3. **Classify** each uncovered signal:
   | Kind | When |
   |---|---|
   | new skill | a repeatable procedure with steps/commands, triggered by a recognisable request |
   | extend skill X | fits an existing skill's scope — name the section to add |
   | new agent | self-contained work with a large input and a small result, worth its own context/tools |
   | memory note | a fact, preference or gotcha, not a procedure |
   | retire/merge memory | a memory note now duplicated by a skill or out of date |
   | nothing | one-off, or already covered |
4. **Rank** by expected reuse before launch (endgame: stability and launch work first; tooling for its own
   sake ranks last). Drop anything with no evidence.

## Output

- One line per proposal: kind · name · why (evidence: date/session + what happened) · rough size (S/M).
- Then "Covered already" (signal → where) and "Stale memory" (note → duplicated by / why).
- If nothing qualifies, say `Reusable: none` and stop — an empty retro is a fine result.
- **Stop.** On the user's picks: add each as a board item in section `tooling` (see `adwear-task-board`);
  memory-note picks may be written directly, since they are not tooling changes.
