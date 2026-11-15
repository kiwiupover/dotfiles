---
name: architecture-plan
description: Trigger this whne the user say 'architecture plan', 'plan the architecture' or review the architecture of the plan. 
---

# Architecture plan

Review a plan before any code exists,and update the plan so the code starts in the right shape. 
The aim: deep modules behind small interfaces, seams only where something varies, and libraries 
used to their full extent instead of rebuilt.

This skill runs the same design checklist as `architecture-review`, in [DESIGN-PASS.md](../architecture-review/DESIGN-PASS.md), plus polish's other passes adapted to a plan.

## Choose the mode

- **Update** (default): edit the plan file in place. Plan mode allows writes to the plan file, so this works mid-planning.
- **Review**: "findings only", "review only", or "don't change the plan". Return findings without editing anything.

## Find the plan

Use, in order: a path the user gave, the plan being drafted in this conversation, or the most recently modified file in `~/.claude/plans/`. Say which plan you're reviewing. If none exists, say so and stop.

## Establish ground truth

1. **Read the plan** and learn its intent: the problem, the intended outcome, and the constraints the user stated.
2. **Read the code it touches**: every file it names, their callers, and the tests around them. Check each claim the plan makes about the code ("reuse X", "Y already handles Z", "the hook lives in W") and flag the ones that are wrong.
3. **Read the project context** listed in DESIGN-PASS.md.
4. **Challenge the approach.** Is there a materially simpler or safer way to the same outcome: a different data model, a different owner for the decision, or an existing capability that removes whole concepts or steps? Require a concrete alternative grounded in the codebase, weighed against its tradeoffs. Stylistic preferences don't qualify.

## Design pass

Run every check in DESIGN-PASS.md against the modules the plan proposes. Plans describe modules loosely, so for each new or changed module, write out the interface the plan implies (signatures, parameters, error modes, ordering rules) and judge that.

**Library map.** For each part of the plan that touches a library, the plan must name the library feature it uses, checked against the installed version's docs. For example: "reconnection: LiveKit `Room` auto-reconnect, handled through `RoomEvent.Reconnecting` and `RoomEvent.Reconnected`." Anything the plan builds by hand must say why the library can't do it. A plan that rebuilds a library feature it depends on is a **Blocking shape**.

## Polish passes, run on the plan

- **Correctness**: edge cases, empty and boundary inputs, nullability, ordering, timing, async, and error paths the plan doesn't account for. Mismatches with the contracts of the code it calls.
- **Conventions**: existing helpers, patterns, and installed dependencies the plan should reuse. Search the repo; plans often propose building what already exists. Check the repo's AGENTS.md and similar guides for rules the plan breaks.
- **Simplicity**: steps, options, flags, or configuration nobody needs yet; features larger than what was asked for.
- **Generalization**: whether the plan adds a third variation of an existing pattern that should be folded in. Fold only when it's a strict improvement.
- **Double check**: auth, PII and logging, migrations and backfills, compatibility for existing consumers, performance on hot paths, timeouts and retries, rollout and feature flags.
- **Verification**: does the plan say how the result will be tested and run end to end? Tests should go through each module's interface, using the dependency categories from DESIGN-PASS.md.

## Decide before changing the shape

For a **Blocking shape** or a real interface choice the plan leaves open, don't pick silently:

- When several interface shapes are plausible, offer to follow `~/.claude/skills/codebase-design/DESIGN-IT-TWICE.md`: parallel sub-agents design very different interfaces, then you compare them and recommend one.
- When the open question is about intent or constraints only the user knows, ask it directly, one question at a time, with your recommended answer.

Apply fixes for everything else without asking.

## Update the plan

In update mode, edit the plan so it reads as one coherent plan, not a plan with patches attached:

- Change the steps, files, and interfaces in place where findings apply.
- Add or update a **Library map** section listing each library feature the plan relies on.
- Add or update a **Design decisions** section: one line per decision, naming the principle (for example "Merged `useVisitTimer` into `useVisitSession`: deletion test — the timer's complexity reappeared in both callers"). `architecture-review` checks the code against this section later.
- Keep the plan concise. Don't paste the review into it.

Then report in chat:

- **Design**: design findings in the teaching format from DESIGN-PASS.md, ordered by severity, noting which ones you applied.
- **Other changes**: correctness, conventions, simplicity, and safety fixes made to the plan.
- **Questions**: decisions waiting on the user.
- **Suggestions**: improvements left out of scope, such as neighborhood deepening opportunities, and why each would help.

In review mode, report the same sections without editing, and say what you'd change in the plan.

## Visual report

When the user asks for a visual, an HTML report, or diagrams ("architecture plan, visual"), also write the report described in [HTML-REPORT.md](../architecture-review/HTML-REPORT.md), with one card per design finding.
