---
name: pre-review
description: Trigger this when the user says 'pre-review', 'self-review' or 'check for over-engineering'.
---

<objective>
Catch the problems reviewers flag in "code quality" comments: things that work but shouldn't exist. This is not an idiom or style review; it asks whether each addition earns its place. It applies to app code, shell scripts, config files, and docs.
</objective>

<workflow>
1. Get the diff.
   - Current branch: run `git fetch origin main`, then `git diff origin/main...HEAD`. Local `main` can be stale and inflate the diff. If the file count looks too large for the PR, review the branch's own commits instead (`git log origin/main..HEAD`, then `git show <sha>`).
   - A PR by number: `gh pr diff <n>`. Read full files with `git fetch origin pull/<n>/head:refs/pre/<n>` and `git show refs/pre/<n>:<path>`, without changing the current branch.
   - A stack: fetch every PR in the stack the same way. Review one PR's diff, but answer "is this used?" against the top of the stack.
2. For large diffs, read the source in full and read tests only to see what machinery they cover.
3. Answer each check below from the diff.
4. Confirm every hit before reporting it. Open the file at the line you cite. For "unused", "never read", "no caller", or "always passed X", search callers across backend and web at the top of the stack, and say if only tests use it. Drop any hit you can't confirm, or mark it inferred.
5. For each fix, check what it breaks: tests that assert the behavior, and later PRs in the stack that use the thing. If a later PR uses it, the fix is "move it to that PR", not "delete it".
6. Report only. Do not apply fixes unless asked; some fixes change behavior and need a decision.
</workflow>

<checks>
<check name="unused-values">
Is there a column, enum value, field, flag, option, prop, prompt, or script that nothing uses or sets to a non-default value today? Look for enums with one reachable member, fields that are always empty or constant, columns that are written but never read, "deprecated" fields for callers that only exist in this branch, response fields the client never reads, and temporary test scripts. Also look for a function argument that every caller passes the same value, a return value every caller discards, and a branch for a case the data cannot produce. Fix: delete until a second value exists, or make the constant a constant.
</check>

<check name="parallel-paths">
Do two code paths answer the same question with different inputs, budgets, timing, or placement rules? Two endpoints that start the same job? Two polling schemes for one status? Fix: keep one, move the other to its own PR.
</check>

<check name="duplicated-state">
Are two stored things written and deleted by the same event under the same key? Does a status mean "a related record exists"? Is the same data stored or sent under several names? Is a server enum copied into a second enum or a client list? Fix: keep one and derive the other.
</check>

<check name="machinery-for-rare-cases">
Is there a queue, waiting state, counter, retry loop, lease, sweep, journal, or backup for something that happens rarely or has headroom? Compare the limit with the worst-case use, and check whether the limit is shared (per org or global). Also look for work repeated far more often than needed: data sent on every tick, render, or poll when the receiver only needs a summary or a state change. Fix: fail with a clear message, use `/tmp/` for scratch files, and add machinery only if real data shows the case.
</check>

<check name="failure-paths">
Where is an error caught and only logged? What retries it? Does any "X will handle it" comment point at something that actually runs on a schedule or trigger, not a one-off script? Does that recovery actually cover the lost work? Fix: same transaction, or a sweep that retries.
</check>

<check name="destructive-defaults">
Does anything overwrite or delete a user's file or data, especially one not tracked in git? Does a prompt default to yes? Is there a "skip if it already exists" case? Does a script leave the user in a different directory? Fix: skip when the file exists, default to No, and only overwrite on an explicit force.
</check>

<check name="reads-that-write">
Does opening a page, a GET, a render effect, or a query function cause a write, a queued job, or an audit log (such as a PHI access record) for something the user didn't choose to open? Fix: do the work at the event that matters (create, approve) on the server, and load sensitive data only on an explicit action.
</check>

<check name="existing-conventions">
Does this add a parallel way of doing something the repo already has a standard for: a second env or config source, a new helper beside identical inline copies, repeated per-directory setup, expectations copied from another script, or a mandatory tool where users have their own preference? Does `.env.example` follow the rule that required vars are uncommented and optional ones are commented out? Does the client re-implement a rule or state list the server already decides? Fix: reuse the existing source of truth, or have the server send the answer as a flag.
</check>

<check name="docs-claims">
Does any README, comment, docstring, help text, or UI copy state something this PR never ran or verified, or something the code contradicts? Does it mention a feature that only a later PR adds? Does it hard-code a number the code owns (a limit, count, or timeout), so it will drift? Does it overstate what the tool automates? Fix: state only what is true here, have the server send the number, and let the script prompt the user.
</check>

<check name="size-and-copies">
Did a file grow past about 1,000 lines or take on a second job? Was a block of fields or logic copied from another model or module? Are several helpers returning the same value (list every function that returns the same trimmed or normalized result)? Are the same fields, timeouts, or retry settings copied from an earlier PR in the stack? Fix: split by job, extract on the second use, keep one helper.
</check>

<check name="stack-fit">
For stacked PRs: is everything added here used by the end of the stack? Does a later PR make this PR's addition redundant? Does this PR add something only a later PR needs (options, props, enum values, or copy for a feature that doesn't exist yet)? Fix: remove it or move it to the PR that uses it.
</check>
</checks>

<output>
List hits by how much code the fix removes, largest first. For each hit: the check name, `file:line`, one sentence on what is redundant or unsafe, the smallest fix, whether it was confirmed or inferred, whether the fix changes behavior (needs a decision), and what the fix breaks (tests, later PRs).
If you notice a correctness bug, list it separately under "Possible bugs". Don't drop it because it's out of scope.
If nothing hits, say so plainly.
End with the single decision that would remove the most code, if there is one.

Example:

**unused-values** — `api/models/report.py:31` (confirmed)
`Report.format` has `PDF` and `CSV`, but every write sets `PDF` and no client offers CSV.
Fix: delete `CSV`, the `format` query param, and the CSV branch in `export_report`. Changes behavior: no. Breaks: `test_report_router.py:88`, which requests CSV.
</output>
