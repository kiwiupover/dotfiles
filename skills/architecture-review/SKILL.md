---
name: architecture-review
description: Trigger this when the user says 'architecture review', 'review the architecture' or review the architecture of the code. 
compatibility: Requires git.
---

# Architecture review

Evaluate the branch against what a careful senior engineer would merge: correct, well-shaped, idiomatic to this codebase, as simple as possible, and safe. "Well-shaped" means deep modules behind small interfaces, seams where something actually varies, and libraries used to their full extent rather than rebuilt.

This skill extends `polish` with a real design pass. The design checklist lives in [DESIGN-PASS.md](DESIGN-PASS.md); `architecture-plan` uses the same file before coding.

## Choose the mode

Follow the user's words, including modifiers in the same sentence ("architecture review, findings only", "architecture review, learn mode"):

- **Review**: "findings only", "review only", "don't change anything", or a request to audit or assess. Leave the checkout untouched: no edits, installs, or formatting. Run anything that writes files in a disposable location outside it.
- **Edit** (default): apply task-scoped fixes, leave them uncommitted unless asked to commit, and return the improved branch with a summary. Design fixes follow the **design-edit level**:
  - `contained` (default): apply only small deepenings inside the diff, such as inlining a pass-through the diff added, deleting a single-adapter seam, merging shallow helpers the diff introduced, or swapping hand-rolled code for the library feature it duplicates when the swap stays inside the diff. Anything that changes an interface used outside the diff becomes a decision.
  - `learn`: apply non-design fixes, but never apply design findings. Return each one as a decision in the teaching format, so the user makes every architecture call.
  - `bold`: apply any deepening that tests and type checks show is safe, including callers outside the diff. Summarize each with its before and after interface.

An explicit read-only constraint wins.

## Establish ground truth

1. **Find the change.** Use a caller-supplied baseline when given. Otherwise diff the branch against its base (`origin/HEAD`, else `main`), including uncommitted work; on the base branch itself, review the uncommitted work. Nothing to review: say so and stop.
2. **Learn its intent** from commit messages, the user's words, and the docs and tests it touches.
3. **Find the plan.** Look for an approved plan for this work: the user's words, the conversation, or a recent file in `~/.claude/plans/` that names this branch or its files. If one has a **Design decisions** section or a library map, the code must match it. Flag drift, for example "the plan said use the SDK's reconnect, but the code rolls its own."
4. **Inspect changed behavior** and relevant callers, tests, and configuration.
5. **Triage risk.** Logic, data shapes, migrations, auth, concurrency, and external integrations deserve more attention than cleanup and formatting.
6. **Establish a verification baseline** with checks suited to the change's risk, recording inherited failures separately.

## The six passes

Order matters. Correctness gates everything. Design comes next, because polishing code that has the wrong shape is wasted work. Conventions come before simplicity, so you simplify toward the codebase's idiom rather than your own taste.

### 1. Correctness

Trace what the code actually does, not what its names and comments claim:

- Edge cases and boundaries: empty inputs, single elements, first and last page, zero or negative arguments, `n` vs `n-1`.
- Basis mismatches: 0- vs 1-based, inclusive vs exclusive, especially where new code must agree with existing code.
- Wrong assumptions about nullability, state, ordering, or timing.
- Async: missing `await`, unhandled rejections, races.
- Error paths: failed I/O, missed lookups, bad parses.
- Drift from the contracts of the code it calls.
- Comments and tests describing behavior the code doesn't have.

Branch-authored tests are suspects, not witnesses: they often assert the bug or cover only the happy path. Re-derive expected values independently. Confirm each suspected bug with a small reproduction, and cover each fix with a test.

When code, tests, and docs can't settle a material user-visible outcome, raise it as a question and leave that outcome unchanged.

### 2. Design

Run every check in [DESIGN-PASS.md](DESIGN-PASS.md) against the diff's inventory of modules, and report findings in its teaching format.

A **Blocking shape** finding means a materially better approach exists. In review mode, stop: return the design problem with evidence, a sketch of the alternative, why it's better, and what it costs. Include confirmed findings so far, list the skipped passes, and mark the review **incomplete**. In edit mode, apply it only at the `bold` level and only when it's safe; otherwise return it as a decision before continuing.

### 3. Conventions

The new code should look like it grew out of this codebase.

- Search the repo for code that does similar things, and reuse existing helpers instead of duplicating them.
- Match surrounding naming, error handling, module layout, config and secret access, logging, and test structure, plus anything the repo's AGENTS.md, README, or CONTRIBUTING documents. A strange pattern that recurs is probably deliberate; verify before "fixing" it.
- Verify changed or version-sensitive library calls against the installed version's documentation.

### 4. Simplicity

Ask of each piece: would a careful engineer have written this, or is it scaffolding the generator left behind? Remove:

- Parameters nobody passes, half-built features, dead constants, values nothing reads, config only partly wired.
- Branches for cases that can't happen, especially beside real edge cases left unhandled.
- Tests that restate the implementation or the framework.
- Comments that narrate the code or claim an intent the code doesn't satisfy.

Redundant state and speculative abstraction are covered by the design pass; don't report them twice.

### 5. Generalization

When the change near-duplicates existing logic or adds a third variation of a pattern, fold them together only if the result is a strict improvement: less code, no new concepts, no behavior change for existing callers. Flexibility for hypothetical needs goes in the summary as a suggestion.

### 6. Double check

A final sweep for real risks:

- Injection into SQL, shell, paths, or HTML; hardcoded secrets; missing validation at trust boundaries; authn or authz gaps on new endpoints.
- Credentials or PII in logs; data kept or exposed in ways users wouldn't expect.
- Resources leaked on error paths; swallowed failures; network calls with no timeout or retry.
- Compatibility breaks and migration risk for data or interfaces that already have consumers.
- Failures that would be undiagnosable in production.
- N+1 queries, I/O in loops, unbounded scans or growth, blocking work on hot paths, missing pagination.

## Iterate

In edit mode, re-review fixes and the code they affect. Continue until no material in-scope issues remain or a real blocker stops you. If fixes keep exposing significant issues, reassess the design instead of patching.

Stay within the requested change. Note pre-existing issues and neighborhood deepening opportunities as suggestions.

## Verify and hand back

1. After edits, run affected tests, lint, type, and formatting checks. Fix regressions your edits caused; report inherited failures separately.
2. If the branch changed an interface, config surface, migration, or operational behavior, confirm the matching tests, docs, or rollout notes changed too.
3. Summarize, in proportion to what you found:
   - **Design**: design findings first, in the teaching format, ordered by severity.
   - **Findings** (review mode) or **Fixed** (edit mode): other issues with `file:line`, impact, and the fix.
   - **Questions**: unresolved outcomes, blockers, and design decisions waiting on the user.
   - **Suggestions**: improvements deliberately left out, such as non-strict generalizations, larger deepenings, neighborhood opportunities, and pre-existing issues.
   - **Verified**: commands and results, inherited failures, and checks not run with reasons.

A branch in good shape earns a short confirmation of what you checked.

## Visual report

When the user asks for a visual, an HTML report, or diagrams ("architecture review, visual"), also write the report described in [HTML-REPORT.md](HTML-REPORT.md), with one card per design finding.

## Follow-up

After the hand-back, offer to explore any design finding further. When the user picks one ("grill finding 2"), follow `~/.claude/skills/codebase-design/DESIGN-IT-TWICE.md`: frame the constraints, run parallel sub-agents that design very different interfaces, then compare them on depth, locality, and seam placement and recommend one.
