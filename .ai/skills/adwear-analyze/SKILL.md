---
name: adwear-analyze
description: >
  Analyze an Adwear request before any work: check whether the goal itself makes sense, then find every usable
  path to it (the user's idea, variations, entirely different approaches), with strengths, weaknesses, effort,
  risk and blocking questions. Trigger: any new change request or idea, "analyze", "what are the options",
  "should we…", "how would we…".
argument-hint: "<the user's request, verbatim> [checklist item id]"
allowed-tools: Read, Grep, Glob, Bash
produces: JSON matching the task board's `analyses` + `questions` schema, plus a short human summary
---

# Analyze a request

The user's request is an **idea to explore, not a chosen direction**. Never implement anything here — read-only.

## Inputs to read first

- The **board dump** the main agent passes in (a scratchpad dir with `items/`, `questions/`, `analyses/`, `steps/`,
  one JSON per doc — see `adwear-task-board` § Board dump). It is the source of truth for what is planned, decided,
  done or already asked. No dump given → say so at the top of the summary; the analysis is then unreliable.
- The **true goal** and principles: board doc `meta/goal` (in the dump or passed in).
- The linked item (title, detail, note) and **all** its questions, answered ones too.
- Relevant memory (`~/.claude/projects/-home-kciariot-AdwearPresta/memory/MEMORY.md` index → area notes) and `.ai/WORKFLOW.md`.
  Memory never holds board state; when it disagrees with the dump, the dump wins.

## Steps

1. **Restate** the request in one sentence, and the underlying need behind it (why would the user want this?).
   **Check the board:** grep the dump for the topic — other items, their notes and steps, and answered questions
   carry decisions that bind this analysis (e.g. "no Cloudflare", "backups paused"). Cite them (`found-edge-q1`)
   instead of re-deciding, and list overlapping items in the summary (`dependsOn` / covered by).
2. **Goal check** — before any solution:
   - Is the problem real? Look for evidence in code, local DB (prod clone), logs, or read-only prod checks.
   - Does solving it serve the true goal and principles, now, in the endgame? Is it worth the effort vs. other open items?
   - Is there a better or bigger framing (the request is a symptom of something else), or a reason not to do it at all?
   - Verdict: `sound` (do it as framed), `reframe` (goal is right but should be stated as `reframedGoal`), `doubtful` (probably not worth doing — say why).
3. **Breadth first — enumerate every alternative.** No cap, no padding; 2 is fine if only 2 exist, 20 is fine if 20 exist. Sweep:
   - the user's idea as stated (`origin: user-idea`), and variations on it;
   - configuration / BO settings instead of code; existing PrestaShop core features;
   - existing native or marketplace modules; third-party services/SaaS;
   - theme-only vs. module vs. override vs. data-migration implementations;
   - process/manual changes; deferring; doing nothing.
4. **Usability filter** — test each candidate against reality: this codebase (PS 9.1 fork, Hummingbird-based theme, nested module repos), the prod deploy model, a solo maintainer, Slovak-only market, endgame timeline, cost. Mark `usable: true`, or `usable: false` with a one-line `rejectReason` grounded in a fact you checked. Keep rejected ones in the output — the user wants to see what was considered.
5. **Assess usable paths**: `approach` (2–4 sentences, concrete: which files/modules/settings), `strengths[]`, `weaknesses[]`, `effort` (`S` ≤ half a day, `M` ≤ 2 days, `L` more), `risk` (`low`/`med`/`high` + what could break), `fitsGoal` (one line),
   `flow` (Mermaid `flowchart TD`, ≤ 12 nodes: the normal run **plus** failure and recovery branches — what breaks,
   how we notice, how we roll back; quote every label `A["…"]`; skip for rejected paths). Recommend one path or a combination, and say why it beats the runner-up.
6. **Questions** — triage every candidate before emitting it; the user's attention is the scarcest resource:
   - **Already on the board?** (any item, note, step, or question — answered ones too) → don't ask; cite the doc.
     Same question already open on another item → don't duplicate; return it with `alsoItems` on the existing id.
   - **Researchable?** (a fact you can check: code, git, prod read-only, vendor docs) → find it now, or make it a
     spike step in the recommended path. Not a user question.
   - **Sensible default?** → emit it already answered: `"status": "answered", "resolution": "default",
     "answer": "Default taken: X (override any time)"`.
   - **Only real decisions stay open** — money, legal, risk appetite, taste, scope, priorities.
   `blocking: true` only when the answer would change which path is best or whether to do it at all. Each has
   `why` (what it decides); a question that becomes moot once another is answered names it in `dependsOn`.

## Output (return exactly this, then a ≤ 10-line human summary)

```json
{
  "itemId": "<checklist item id or proposed new id, kebab-case with section prefix>",
  "newItem": null | {"section": "<section key>", "title": "…", "detail": "…", "kind": "build|fix|check|decide|routine",
                     "tags": ["<from meta/schema>"], "dependsOn": ["<item id>"]},
  "analysis": {
    "request": "<verbatim>",
    "goalCheck": {"verdict": "sound|reframe|doubtful", "reasoning": "…", "reframedGoal": "…|null"},
    "summary": "…",
    "paths": [{"key": "p1", "title": "…", "origin": "user-idea|alternative", "approach": "…",
               "strengths": ["…"], "weaknesses": ["…"], "effort": "S|M|L", "risk": "low|med|high — …",
               "fitsGoal": "…", "flow": "flowchart TD\n  A[\"…\"] --> B[\"…\"]", "usable": true, "rejectReason": null, "recommended": false}],
    "recommendation": "…"
  },
  "questions": [{"text": "…", "why": "…", "blocking": true}],
  "boardFindings": [{"doc": "questions/<id> | items/<id>", "finding": "stale|duplicate|settled by …|drifted", "fix": "…"}]
}
```

`boardFindings` (optional): stale, duplicate or drifted board docs you noticed — the main agent fixes them;
include missing dependency edges as `{"doc": "items/<id>", "finding": "dependsOn", "fix": "add <other id>"}`.
`tags` only from `meta/schema` in the dump; recommend paths that respect `dependsOn` (an item waiting on an
unfinished one says so in its summary instead of planning around it).
Section keys: foundations, legal, checkout, catalogue, seo, performance, security, ops, cicd, ownerapp, ux, marketing, tooling.
Evidence over opinion: cite file paths, query results or command output for claims about the current state.
