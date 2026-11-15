# HANDOFF.md template

The structure `handoff` writes and RESUME reads. Fill every section; write "none" rather than deleting one.

````markdown
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
````
