---
name: architecture-review
description: Use this skill when the user say 'architecture review' or 'review architecture'
compatibility: Requires git.
---

# Architecture review

`polish` with a real design pass. "Well-shaped" code has deep modules behind small interfaces, seams only where something actually varies, and libraries used to their full extent rather than rebuilt.

Run [polish](../polish/SKILL.md) end to end (modes, ground truth, passes, iterate, verify and hand back) with the changes below. The design checklist lives in [DESIGN-PASS.md](DESIGN-PASS.md); `architecture-plan` uses the same file before coding.

## Mode

Polish's review and edit modes apply, read from the user's whole sentence ("architecture review, findings only", "architecture review, learn mode"). In edit mode, design fixes follow the **design-edit level**:

- `contained` (default): apply only small deepenings inside the diff, such as inlining a pass-through the diff added, deleting a single-adapter seam, merging shallow helpers the diff introduced, or swapping hand-rolled code for the library feature it duplicates when the swap stays inside the diff. Anything that changes an interface used outside the diff becomes a decision.
- `learn`: apply non-design fixes, and return every design finding as a decision in the teaching format, so the user makes each architecture call.
- `bold`: apply any deepening that tests and type checks show is safe, including callers outside the diff. Summarize each with its before and after interface.

## Ground truth: add the plan check

After polish's step 2 (learn its intent), find the approved plan for this work: the user's words, the conversation, or a recent file in `~/.claude/plans/` that names this branch or its files. If it has a **Design decisions** section or a **Library map**, the code must match it. Flag drift, for example "the plan said use the SDK's reconnect, but the code rolls its own."

## Passes: insert Design second

Run **Design** between polish's Correctness and Conventions passes. Correctness still gates everything; design comes next because polishing code with the wrong shape is wasted work.

**Design:** run every check in [DESIGN-PASS.md](DESIGN-PASS.md) against the diff's module inventory, and report findings in its teaching format. For a **Blocking shape**:

- Review mode: handle it like polish's superior-approach stop: return it with evidence, a sketch of the alternative, why it's better, and its cost, and mark the review **incomplete**.
- Edit mode: apply it only at the `bold` level and only when it's safe; otherwise return it as a decision before continuing.

In polish's Simplicity pass, skip the redundant-state and speculative-abstraction bullets; the design pass's data-model and seam checks own them.

## Hand back: design first

Lead polish's summary with a **Design** section: design findings in the teaching format, ordered by severity. Add larger deepenings and neighborhood opportunities to **Suggestions**, and design decisions waiting on the user to **Questions**.

## Visual report

When the user asks for a visual, an HTML report, or diagrams ("architecture review, visual"), also write the report described in [HTML-REPORT.md](HTML-REPORT.md), with one card per design finding.

## Follow-up

After the hand-back, offer to explore any design finding further. When the user picks one ("grill finding 2"), follow `~/.claude/skills/codebase-design/DESIGN-IT-TWICE.md`: frame the constraints, run parallel sub-agents that design very different interfaces, then compare them on depth, locality, and seam placement and recommend one.
