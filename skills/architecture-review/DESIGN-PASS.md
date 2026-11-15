# Design pass

The architecture checklist shared by `architecture-review` (run on a diff) and `architecture-plan` (run on a plan). Each check applies to both: for a diff, judge the code as written; for a plan, write out the interface the plan implies and judge that.

Load the `codebase-design` skill first and use its vocabulary exactly: **module**, **interface**, **implementation**, **depth**, **deep**, **shallow**, **seam**, **adapter**, **leverage**, **locality**. Don't substitute "component," "service," "API," "boundary," "layer," or "wrapper." Read its `~/.claude/skills/codebase-design/DEEPENING.md` for dependency categories when a module does I/O.

## Project context

Read `GLOSSARY.md` and `docs/adr/` when they exist, plus every AGENTS.md, CLAUDE.md, or CONTRIBUTING.md covering the touched directories. Name modules with the project's domain words. Don't re-suggest what an ADR settled unless the friction is real enough to reopen it, and say so when you do.

## Checks

1. **Inventory.** List every module the change adds or whose interface it changes: functions, hooks, classes, components, endpoints, tables, events. Every later check runs against this list.
2. **Deletion test.** Imagine deleting each new module. If its complexity reappears across callers, it earns its keep. If the complexity just moves, it's a pass-through: inline it.
3. **Depth.** Write down everything a caller must know to use the module: parameters, flags, ordering rules, error modes, required config, performance traps. When that list is nearly as long as the implementation, the module is shallow. Ask: can the interface lose a method, a parameter, a mode?
4. **Seams.** A new port, dependency injection, strategy, or injected prop with only one adapter is a hypothetical seam: remove it. A seam is real when two adapters exist (usually production and test). Also flag leaks: callers that depend on internals, call ordering, or data shapes the module should hide.
5. **Locality.** One concept edited across many files, or one decision (a format, a status rule, a storage key, a threshold) encoded in more than one module. Gather it into the module that owns the decision.
6. **Pass-through.** Parameters or props threaded through modules that don't use them. The module that needs the value should get it more directly, or the modules in between should merge.
7. **Data model.** Each fact lives in exactly one place. Fields, flags, caches, or copies that duplicate other state or can be derived from it should be derived where they're read. Parallel booleans that encode one status become one status.
8. **Library leverage.** A well-chosen library is already a deep module. Rebuilding its features adds a second, shallower copy and loses locality.
   - List the libraries the change touches. Read the docs and source of the installed version (`node_modules`, `site-packages`, lockfile versions), plus any vendor docs MCP or skill (for LiveKit, the `livekit-docs` MCP and the `reading-livekit-docs` skill). Don't rely on memory for library APIs.
   - For each new module, ask whether the library already provides it. Common rebuilds: connection and reconnect handling, retries and backoff, event or state machines, session or room lifecycle, media or track handling, validation, date math, caching, types the library already exports, and test harnesses or fakes the library ships.
   - Flag modules that mirror the library one-to-one (shallow, a Middle Man) and hand-written types that duplicate exported ones.
   - Keep a module around a library only when it passes the deletion test: it hides one of our decisions (domain rules, a second adapter) and doesn't re-expose the library's surface.
   - When no installed library covers a need the change builds by hand, follow `~/code/skills/library-search/SKILL.md` before accepting the custom code. Ask before adding a dependency.
9. **Test surface.** The interface is the test surface. Flag tests that reach past it: mocking internals, testing an extracted pure helper while the real call site goes untested, asserting on internal state. For each I/O dependency, name its category from DEEPENING.md (in-process, local-substitutable, ports and adapters, mock) and say how it should be tested.
10. **Smells, in this vocabulary.** Middle Man → shallow module. Shotgun Surgery → no locality. Feature Envy → the seam is in the wrong place. Speculative Generality → hypothetical seam. Data Clumps → a type that wants to exist. Repeated Switches → one decision encoded in many modules.
11. **Neighborhood.** Run `git log --oneline -- <touched paths>` for a good stretch of history. If the area keeps churning, look for a deepening opportunity next to the change. Report it as a suggestion; never expand the change's scope for it.

## Severity

- **Blocking shape**: the design is wrong at a level that later fixes won't recover, such as a rebuilt library feature the code depends on, a seam in the wrong place, or one fact stored twice. Stop and return it as a decision for the user.
- **Worth fixing**: a real loss of depth, locality, or testability that a contained change fixes.
- **Note**: minor, or a judgment call worth knowing about.

## Teaching format

The user is building their architecture skills, so every design finding teaches the principle as well as the fix:

- **What**: the plan section or `file:line`, and what the code or plan does.
- **Principle**: the named rule (for example "deletion test", "one adapter means a hypothetical seam", "the interface is the test surface", "library leverage").
- **Why it matters here**: the cost in leverage, locality, or testing, in this code specifically.
- **Deeper shape**: a short sketch of the deeper interface, as a few lines of signature or usage.
- **Cost**: what the change takes, and who it touches.

Keep each finding tight. A clear principle and a concrete sketch teach more than paragraphs.
