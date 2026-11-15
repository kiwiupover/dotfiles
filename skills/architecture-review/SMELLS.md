# Code smells

A fixed baseline of Fowler code smells (_Refactoring_, ch. 3), adapted from `mattpocock/skills`' `code-review`. Used by `polish` (Simplicity pass) and the design pass in [DESIGN-PASS.md](DESIGN-PASS.md). Match each smell against the diff or plan.

Two rules bind the list:

- **The repo wins.** A documented repo standard always overrides the baseline; where it endorses something a smell would flag, let it stand. Skip anything tooling already enforces.
- **Judgement calls.** Report each as a labelled heuristic ("possible Feature Envy"), with the hunk quoted.

Each smell reads _what it is_ → _how to fix_. The design-vocabulary name in brackets is the term to use in a design finding.

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → Rename it; if no honest name comes, the design is murky.
- **Duplicated Code**: the same logic shape in more than one hunk or file. → Extract the shared shape and call it from both.
- **Feature Envy** [the seam is in the wrong place]: a method that reaches into another object's data more than its own. → Move the method onto the data it envies.
- **Data Clumps** [a type that wants to exist]: the same few fields or params keep travelling together. → Bundle them into one type and pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → Give the concept its own small type, named from `GLOSSARY.md` when it has one.
- **Repeated Switches** [one decision encoded in many modules]: the same `switch` or `if`-cascade on the same type recurs. → Replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** [no locality]: one logical change forces scattered edits across many files. → Gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → Split so each module changes for one reason.
- **Speculative Generality** [hypothetical seam; YAGNI]: abstraction, parameters, or hooks for needs nobody has yet. → Delete it; inline back until a real need shows.
- **Message Chains** [leak across the seam]: long `a.b().c().d()` navigation the caller shouldn't depend on. → Hide the walk behind one method on the first object.
- **Middle Man** [shallow module]: a class or function that mostly delegates onward. → Cut it and call the real target directly.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → Drop the inheritance and use composition.
