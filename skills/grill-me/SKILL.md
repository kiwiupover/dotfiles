---
name: grill-me
description: Stress-test a plan, decision, or idea through a structured grilling session while sharpening and recording the project's domain language. Use when the user asks to be grilled or wants hidden assumptions, terminology, and decision branches forced into the open.
---

# Grill Me

Run the installed `grilling` and `domain-modeling` skills together.

Before starting, read these files completely:

- `${CODEX_HOME:-$HOME/.codex}/skills/grilling/SKILL.md`
- `${CODEX_HOME:-$HOME/.codex}/skills/domain-modeling/SKILL.md`

Treat both as active instructions for the session. The grilling workflow controls the interview and decision tree. Domain modeling controls terminology, concrete scenarios, code checks, glossary updates, and ADR decisions.

Apply these integration rules:

- Investigate facts in the repository instead of asking the user. Ask the user for decisions and meanings that cannot be discovered from evidence.
- Keep distinct concepts distinct, especially where similar language belongs to different regulatory, business, or technical processes.
- Update the relevant `CONTEXT.md` when a canonical term or relationship is settled. Do not use it as a plan, specification, or implementation log.
- Offer an ADR only when the decision is hard to reverse, surprising without its rationale, and based on a real trade-off.
- Create glossary and ADR files lazily. Do not scaffold them before the session produces something worth recording.
- Do not load, install, or depend on any other Matt Pocock skills.

Finish only when the decision frontier is empty and the user confirms shared understanding. Do not implement the resulting plan unless the user separately asks for implementation.
