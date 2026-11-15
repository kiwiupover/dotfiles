---
name: polish
description: Trigger this when the user says 'polish', 'review the code' or 'clean up the code'.
compatibility: Requires git.
---

# Polish

Evaluate the branch against what a careful senior engineer would merge: correct, idiomatic to this codebase, as simple as possible, and safe.

## Choose the mode

Follow the user's requested action, including when another skill invokes this one:

- **Review:** a request to review, audit, assess, or check the branch, including `$polish review`. Leave the user's checkout untouched: no edits, dependency installs, or formatting; run anything that writes files in a disposable location outside it. Every pass below yields findings and suggested fixes, not applied changes.
- **Edit:** a request to polish, clean up, or fix the branch, including `$polish the current branch` or an unqualified `$polish`. Apply task-scoped fixes, leave them uncommitted unless the user asked for a commit, and return the improved branch with a summary.

An explicit read-only constraint wins. Otherwise, a request to apply fixes selects edit mode even when it also asks for a review.

## Establish ground truth

1. **Find the change.** Use the caller-supplied baseline and change scope when provided. Otherwise diff the branch against its base (`origin/HEAD`, else `main`), including uncommitted work; on the base branch itself, review the uncommitted work. Nothing to review: say so and stop.
2. **Learn its intent** from commit messages, the user's words, and the docs and tests it touches.
3. **Inspect changed behavior** and relevant callers, tests, and configuration.
4. **Challenge the approach early.** Is there a materially simpler or safer way to achieve the same intended outcome—not merely a cleaner version of this implementation? Look for a different data model, ownership boundary, or existing capability that eliminates whole concepts, branches, or layers. Require a concrete alternative grounded in the codebase's behavior and constraints, weighed against its tradeoffs and rewrite cost; speculative alternatives and stylistic preferences do not qualify.
   - **Review mode:** whenever the evidence establishes a superior approach, here or later, stop reviewing and return it for the user's decision: the current design problem with file/line evidence, a sketch of the alternative, why it is better, and what it would cost. Include material findings already confirmed, list skipped checks, and mark the review **incomplete**.
5. **Triage risk.** Logic, data shapes, migrations, auth, concurrency, and external integrations deserve more attention than cleanup and formatting.
6. **Establish a verification baseline** with checks appropriate to the change's risk, recording inherited failures separately.

## The five passes

Order matters: correctness gates everything, and you learn conventions before simplifying so you simplify toward the codebase's idiom rather than your own taste.

### 1. Correctness

Trace what the code actually does, not what its names and comments claim. Fast-written code fails in predictable places:

- Edge cases and boundaries: empty inputs, single elements, first/last page, zero or negative arguments, `n` vs `n-1`.
- Basis mismatches: 0- vs 1-based, inclusive vs exclusive, especially where new code must agree with existing code.
- Wrong assumptions about nullability, state, ordering, or timing.
- Async: missing `await` (a returned Promise is always truthy), unhandled rejections, races.
- Error paths: failed I/O, missed lookups, bad parses.
- Drift from the contracts of the code it calls.
- Comments and tests describing behavior the code no longer has, or never had.

Branch-authored tests are suspects, not witnesses: they often assert the bug they were generated against or cover only the happy path. Re-derive expected values independently. Confirm each suspected bug with a small reproduction, and cover each fix with a test.

Resolve implementation details autonomously. When code, tests, and docs cannot settle a material user-visible outcome, raise it as a question and keep that outcome unchanged unless the user has authorized assumptions.

### 2. Conventions

The new code should look like it grew out of this codebase.

- Search the repo for code that does similar things. AI-written code routinely reimplements existing helpers (query builders, validation, sorting, logging, config access); reuse them and delete the duplicates.
- Run `library-search` when a replacement could materially reduce complexity or risk and the choice is not already clear. Pass the current scope and evidence. Adopt only suitable already-installed dependencies; ask before adding a new one unless that specific addition is already authorized.
- Match surrounding naming, error handling, module layout, config and secret access, logging, and test structure, plus anything README or CONTRIBUTING documents. A strange-looking pattern that recurs is probably deliberate; verify before "fixing" it.
- Verify changed, unfamiliar, or version-sensitive library calls against the installed version's documentation.

### 3. Simplicity

Ask of each piece: would a careful engineer have written this, or is it scaffolding the generator left behind? Start with the data model: each fact lives in exactly one place, and everything else is derived from it. Remove:

- Redundant state: fields, flags, columns, caches, or copies that duplicate other state or can be derived from it, including parallel flags that encode one status. Derive the value where it is read; each piece of state removed retires the code that keeps it in sync and the bugs when it drifts.
- Speculative abstraction: patterns wrapping trivial logic, one-caller classes with no state worth managing, layers that only forward, helpers that rename without simplifying.
- Parameters nobody passes, half-implemented features, dead constants, computed values nothing reads, config surfaces only partly wired.
- Branches for cases that cannot happen, especially beside real edge cases left unhandled.
- Tests that restate the implementation or framework, or cover behavior that no longer exists.
- Comments that narrate the code or claim an intention the code doesn't satisfy.

When a meaningfully simpler design solves the same problem and the rewrite is small and safe, rewrite. Simplifying exposes bugs; passes 1 and 3 feed each other.

### 4. Generalization

The opposite check. When the change near-duplicates existing logic or adds a third variation of a pattern, fold them together only if the result is a strict improvement: less code, no new concepts, no behavior change for existing callers. Flexibility for hypothetical needs goes in the summary as a suggestion, not in the code.

### 5. Double check

A final sweep of the changed code for real risks, pragmatic but never negligent:

- Injection into SQL, shell, paths, or HTML; hardcoded secrets; missing validation at trust boundaries; authn/authz gaps on new endpoints.
- Credentials or PII in logs; data kept or exposed in ways users would not expect.
- Resources leaked on error paths; swallowed failures; network calls with no timeout or retry.
- Compatibility breaks and migration risk for data or APIs that already have consumers.
- Failures that would be undiagnosable in production.
- N+1 queries or I/O in loops, unbounded scans or in-memory growth, blocking work on hot paths, missing pagination where the codebase paginates.

## Iterate until reasonably good

In edit mode, re-review fixes and affected interactions; repeat the whole review when the scope or risk warrants it. Continue until no material in-scope issues remain or a genuine blocker prevents completion. If fixes keep exposing significant issues, reassess the approach rather than patching indefinitely.

Scope: stay within the requested change. Note pre-existing issues elsewhere in the summary rather than fixing them, and keep the feature at the size that was asked for.

## Verify and hand back

1. After edits, run affected tests, lint, type, and formatting checks, plus full validation when repository policy or change risk warrants it. Reuse earlier results only when the checked code and environment are unchanged. Fix regressions caused by your edits; report inherited failures separately.
2. If the branch changed an API, config surface, migration, or operational behavior, confirm the matching tests, docs, or rollout notes changed too.
3. Summarize, proportional to what you found:
   - **Findings** (review mode): issues ordered by severity, with file/line, impact, evidence, and suggested fix.
   - **Fixed** (edit mode): each issue as *what* + *why*, e.g. "Added bounds check on page index — off-by-one returned empty results on the last page."
   - **Questions**: unresolved outcomes or blockers, and any explicitly authorized assumptions used.
   - **Suggestions**: improvements deliberately left out (non-strict generalizations, larger refactors, pre-existing issues) and why each would help.
   - **Verified**: commands and results, including reused evidence, inherited failures, and checks not run with reasons.

A branch already in good shape earns a short confirmation of what you checked.
