---
name: handoff
description: Write a HANDOFF.md so work survives a context reset, or resume from one.
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

Ground the handoff in the repo, with conversation memory as the last source: memory is exactly what's about to be lost, and it's the least reliable input. The step is done when every claim you will write has been checked against the repo:

```
git status --short
git log --oneline -15
git diff --stat
git branch --show-current
```

Read any file you're about to describe as "in progress." Verify claims before making them: if you say tests pass, run them. If you say a function is complete, look at it.

### Write HANDOFF.md

Put it at the repo root unless the project has a `docs/` or `notes/` convention. Follow the structure in [TEMPLATE.md](TEMPLATE.md).

### Rules for the content

**Be specific to the point of tedium.** "Fixed the auth bug" is worthless. "Fixed `refreshToken()` in `src/auth/session.ts`, it was comparing expiry in seconds against a millisecond timestamp" is a handoff.

**Dead ends are the highest-value section.** They're what a fresh session cannot reconstruct and will otherwise repeat. Record every approach tried and abandoned, with the reason.

**Write for a cold reader.** The next session has none of this conversation. Every reference is a path, every pronoun has its noun in the same sentence.

**Point at code by path and line range.** The next session can read the files; what it can't read is your reasoning, so spend the words there.

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
7. Start at step 1 of `## Next`. Treat `## Decisions` as settled and `## Dead ends` as closed.
8. Keep `HANDOFF.md` current as you work. Update `## Done`, `## In progress`, and `## Next` at each meaningful checkpoint, not only at the end. The next reset may not be planned.
