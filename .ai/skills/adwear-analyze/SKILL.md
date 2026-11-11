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

- The **true goal** and principles: board doc `meta/goal` (the main agent passes it in; see `adwear-task-board`).
- The linked checklist item (title, detail, note) and its open questions, if any.
- Relevant memory (`~/.claude/projects/-home-kciariot-AdwearPresta/memory/MEMORY.md` index → area notes) and `.ai/WORKFLOW.md`.

## Steps

1. **Restate** the request in one sentence, and the underlying need behind it (why would the user want this?).
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
5. **Assess usable paths**: `approach` (2–4 sentences, concrete: which files/modules/settings), `strengths[]`, `weaknesses[]`, `effort` (`S` ≤ half a day, `M` ≤ 2 days, `L` more), `risk` (`low`/`med`/`high` + what could break), `fitsGoal` (one line). Recommend one path or a combination, and say why it beats the runner-up.
6. **Questions**: list what you could not determine. `blocking: true` only when the answer would change which path is best or whether to do it at all; otherwise `false`. Each has `why` (what it decides).

## Output (return exactly this, then a ≤ 10-line human summary)

```json
{
  "itemId": "<checklist item id or proposed new id, kebab-case with section prefix>",
  "newItem": null | {"section": "<section key>", "title": "…", "detail": "…"},
  "analysis": {
    "request": "<verbatim>",
    "goalCheck": {"verdict": "sound|reframe|doubtful", "reasoning": "…", "reframedGoal": "…|null"},
    "summary": "…",
    "paths": [{"key": "p1", "title": "…", "origin": "user-idea|alternative", "approach": "…",
               "strengths": ["…"], "weaknesses": ["…"], "effort": "S|M|L", "risk": "low|med|high — …",
               "fitsGoal": "…", "usable": true, "rejectReason": null, "recommended": false}],
    "recommendation": "…"
  },
  "questions": [{"text": "…", "why": "…", "blocking": true}]
}
```

Section keys: foundations, legal, checkout, catalogue, seo, performance, security, ops, cicd, ownerapp, ux, marketing.
Evidence over opinion: cite file paths, query results or command output for claims about the current state.
