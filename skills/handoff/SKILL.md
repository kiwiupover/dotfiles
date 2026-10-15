---
name: handoff
description: Write or resume a HANDOFF.md so work survives a context reset. Use when the user says context is filling up, asks for a handoff, wants to start a clean session, says "before I /clear", "write this down so we can continue", or when a fresh session should pick up prior work. Also use at the start of a session when a HANDOFF.md exists and the user says "continue".
disable-model-invocation: true
---

# Session handoff

Two modes. Pick by what the user asked for.

- **WRITE.** The current session is ending or its context is filling. Produce `HANDOFF.md`.
- **RESUME.** A fresh session is starting from an existing `HANDOFF.md`.

If ambiguous: a `HANDOFF.md` already exists and the user said "continue" means RESUME. Otherwise WRITE.

---

## Mode: WRITE

### Gather before writing

Do not write from memory of the conversation alone. Memory is exactly what's about to be lost, and it's the least reliable input. Ground the handoff in the repo:

```
git status --short
git log --oneline -15
git diff --stat
git branch --show-current
```

Read any file you're about to describe as "in progress." Verify claims before making them: if you say tests pass, run them. If you say a function is complete, look at it.

### Write HANDOFF.md

Put it at the repo root unless the project has a `docs/` or `notes/` convention. Use this structure:

```markdown
# Handoff: <short task name>
_Last updated: <date> · Branch: <branch> · Last commit: <sha> <subject>_

## Where to work
Exact directory and branch. If sibling clones, worktrees, or other agent
sessions exist, say which paths and ports belong to them and must be left
alone, and what is unsafe there (e.g. "never `git stash` in <path>, another
session's uncommitted work is in it").

## Goal
One paragraph. What are we ultimately trying to accomplish, and why.
Include the acceptance condition, how we'll know it's done.
Link the tracking issue and the plan/ADR docs by path or number.

## State
Working tree: clean | N files modified (list them)
Build: passing | failing (<error>)
Tests: <command> → passing | N failing (<which>)

## Done
- [x] Thing, with the file path where it lives
- [x] Thing, with the file path where it lives

## In progress
The one thing that is half-finished. Exactly where it stopped:
file, function, and what the next edit needs to be.
If nothing is half-finished, write "Nothing in flight, clean stopping point."

## Next
1. Concrete action, with file path
2. Concrete action, with file path
3. Concrete action, with file path

## Key files
| Path | Why it matters |
|------|----------------|
| `src/foo.ts` | Entry point for X; the retry logic lives here |

## Decisions
- **Chose X over Y** because Z. Revisit only if <condition>.

## Dead ends
- **Tried A.** Failed because B. Do not retry.

## Blockers outside code
Human gates: sign-offs, legal, accounting, provisioning, anyone a task is
assigned to and since when. If the real critical path is not code, say so
here in those words.

## Local setup
Services the work needs and how to start each one: containers, ports, env
vars, exact commands. Note which ports/services belong to other sessions.
Include version-manager traps ("plain `mix` silently uses the wrong Elixir,
run `mise exec -- mix`").

## Gotchas
Environment quirks, flaky tests, slow commands, things that look broken but aren't.

## Verify
```bash
<build command>
<test command>
<lint command>
```

## Open questions for the user
- Question that needs a human answer before proceeding
```

### Rules for the content

**Be specific to the point of tedium.** "Fixed the auth bug" is worthless. "Fixed `refreshToken()` in `src/auth/session.ts`, it was comparing expiry in seconds against a millisecond timestamp" is a handoff.

**Dead ends are the highest-value section.** They're what a fresh session cannot reconstruct and will otherwise repeat. Record every approach tried and abandoned, with the reason.

**Write for a reader with zero memory.** No "as we discussed," no "the file from earlier," no pronouns without antecedents. Every reference is a path.

**Don't dump code.** Point at files and line ranges. The next session can read them; it can't read your reasoning.

**Distinguish verified from assumed.** Mark anything you believe but didn't check: `(unverified)`.

**Keep it under ~200 lines.** A handoff that costs 30k tokens to read has defeated its own purpose.

**Flag work that exists only in one place.** An unpushed commit, an unsaved dashboard config, a container with state. Name it and say where the only copy lives; losing it silently is the worst handoff failure.

**Name the risky change explicitly.** If one commit touches production config or shared infrastructure, point at it and say what it changes and what it deliberately does not touch.

**Give Next options a decision, not a menu.** If there are several candidate next tasks, list them with enough context to choose (what each unblocks, what it depends on), and say which one you'd pick.

### Promote durable facts out

Anything that will be true next week too, like build commands, project conventions, directory rules, and style preferences, belongs in `CLAUDE.md`, not the handoff. The handoff is for *this task*; `CLAUDE.md` is for *this project*. Offer to move such items when you notice them.

### Finish

Tell the user the file path and give them the resume line to paste into the clean session:

> Read HANDOFF.md, then continue from "Next".

---

## Mode: RESUME

1. Read `HANDOFF.md` in full. Read `CLAUDE.md` if present.
2. Confirm you are in the directory and on the branch named under `## Where to work` before running anything. Treat paths and ports listed as belonging to other sessions as off-limits.
3. Re-verify state rather than trusting it. The tree may have changed since it was written:
   ```
   git status --short && git log --oneline -5
   ```
   Run the commands in the `## Verify` section.
4. If reality contradicts the handoff, say so plainly before doing anything else, and ask how to proceed.
5. Read the files in `## Key files` before editing anything.
6. If `## Open questions` is non-empty, ask them now.
7. Start at step 1 of `## Next`. Do not re-litigate anything under `## Decisions` or retry anything under `## Dead ends`.
8. Keep `HANDOFF.md` current as you work. Update `## Done`, `## In progress`, and `## Next` at each meaningful checkpoint, not only at the end. The next reset may not be planned.
