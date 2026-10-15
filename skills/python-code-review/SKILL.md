---
name: python-code-review
description: Review newly written or modified Python code with exactly four focused subagents covering idiomatic Python, repository standards, security and sensitive-data exposure, and reuse of existing codebase patterns. Use for local working-tree changes, staged or unstaged code, untracked files, named files or symbols, commits, branches, pasted snippets, or pull requests when asked for a Python code review, security-aware review, codebase-consistency review, or duplication and abstraction review.
---

# Python Code Review

Produce one evidence-based review from four independent specialist passes. Review only; do not edit code unless the user separately asks for fixes.

## Establish the review target

1. Read repository instructions such as `AGENTS.md`, then inspect the working tree and Python configuration. Establish:
   - supported Python versions from `requires-python`, runtime files, CI, or equivalent evidence;
   - configured linting, formatting, typing, testing, coverage, and packaging tools;
   - the framework and concurrency model used by the target code.
2. Resolve the smallest target that matches the request, in this order:
   - Review user-specified files, directories, symbols, line ranges, commits, branches, diffs, or pasted code.
   - When the user refers to code they just wrote or asks to review current code without naming a target, review staged, unstaged, and untracked Python-related working-tree changes relative to `HEAD`.
   - Review a pull request or calculate a merge-base diff only when the user requests a PR or branch comparison.
   - Ask for a target only when no reasonable review scope can be discovered. Do not default to reviewing the entire repository.
3. Include directly related tests, migrations, configuration, schemas, and call sites needed to evaluate the target. For pasted code, use repository context when available and clearly identify conclusions that cannot be verified without its source location.
4. Inspect enough surrounding implementation and tests to understand behaviour. Do not judge isolated patch fragments without their context.
5. Record the exact target and comparison point, if any, so every reviewer evaluates the same code.

## Start exactly four subagents

Use the environment's subagent or delegation tool to start exactly four subagents with the tasks below. In Codex, use the collaboration tool; in Claude Code, use the Agent tool. Give each agent the resolved target, comparison point if any, repository path, and output contract. Ask them to perform read-only review and return findings only; do not reveal another reviewer's conclusions.

Start as many concurrently as the environment permits. If the concurrency limit prevents all four from running at once, start the remaining reviewer as soon as a slot opens. Do not collapse two roles into one agent.

### 1. Idiomatic Python reviewer

Check the target code for:

- clear, idiomatic Python appropriate to the supported Python version;
- type annotations that accurately describe public contracts and important internal boundaries without adding speculative complexity;
- appropriate use of standard-library facilities such as `pathlib`, `contextlib`, `collections.abc`, `functools`, and `itertools` when they make the code clearer or safer;
- correct iteration, context-manager, exception, resource-lifetime, and structured-logging patterns;
- suitable use of dataclasses, protocols, type aliases, and dependency injection when they simplify an existing design; do not demand them categorically;
- correct async behaviour, including blocking calls in async paths, cancellation, task lifetime, concurrency limits, exception propagation, and sync/async boundary handling;
- framework-appropriate validation, serialization, and error handling;
- misleading APIs, mutable defaults, resource-lifetime errors, broad exception handling, hidden side effects, and fragile boundary handling;
- performance concerns only when the target contains a plausible hot path, avoidable repeated work, unnecessary materialisation, or measurable I/O/concurrency cost;
- readability or maintainability issues that have a concrete impact.

Do not report personal style preferences, formatter output, speculative type-system rewrites, or micro-optimisations without a demonstrated cost. Do not assume newer Python syntax is valid until the project's supported versions confirm it.

### 2. Repository standards reviewer

Derive standards from evidence in this order:

1. repository instructions and documented conventions;
2. `pyproject.toml`, lint, type-check, test, packaging, and CI configuration;
3. analogous nearby production code and tests.

Check architecture, naming, module boundaries, error handling, logging, typing, tests, fixtures, dependency usage, packaging, and compatibility. When the project uses pytest, evaluate fixture scope, parametrization, mocking boundaries, and whether tests assert behaviour rather than implementation details. Label a convention as documented or inferred. Do not invent a standard from a single example.

### 3. Security and privacy reviewer

Trace untrusted and sensitive data across inputs, storage, logs, telemetry, exceptions, outputs, and third-party services. Check for:

- committed credentials, tokens, private keys, connection strings, or unsafe defaults;
- PII, authentication data, financial data, health data, customer content, or internal identifiers exposed through logs, traces, analytics, errors, fixtures, snapshots, caches, or responses;
- injection, unsafe deserialisation, path traversal, SSRF, insecure temporary files, subprocess and shell hazards, weak cryptography, access-control mistakes, and missing validation at trust boundaries;
- dependency or configuration changes that materially weaken security.

State the data type, source, sink, attacker or exposure path, and practical impact. Never reproduce a full secret or sensitive value; redact it. Distinguish confirmed leaks from plausible risks that require verification.

### 4. Reuse and duplication reviewer

Search the repository before proposing an abstraction. Check whether the target code repeats or bypasses existing:

- functions, classes, modules, services, adapters, validators, serializers, decorators, context managers, fixtures, or test helpers;
- error-handling, logging, retry, configuration, persistence, or API-client patterns;
- extension points and public interfaces intended for this behaviour.

Provide the existing symbol and path when recommending reuse. Prefer the codebase's established abstraction when semantics match. Do not recommend abstraction based only on superficial similarity or a one-off repetition; explain the maintenance or correctness benefit.

## Require a common output contract

Each subagent must return zero or more findings in this format:

```text
[P0|P1|P2|P3] Short title
Location: path/to/file.py:line
Evidence: What the target code does and the repository evidence used.
Impact: The concrete failure, vulnerability, privacy exposure, or maintenance cost.
Recommendation: The smallest practical correction.
Confidence: high|medium|low
```

Priority meanings:

- `P0`: immediate, broad, or irreversible harm; block release.
- `P1`: likely serious bug, vulnerability, or data exposure; fix before merge.
- `P2`: real defect or significant maintainability problem; normally fix.
- `P3`: worthwhile improvement with limited impact.

Reject findings that lack an in-scope trigger, concrete impact, or reproducible codebase evidence. Allow a nearby out-of-scope line only when the reviewed code makes that existing defect reachable or materially worse.

## Perform the coordinator pass

While subagents review, independently inspect the target code for functional correctness and regression risk, including:

- behaviour at boundaries, failure paths, state transitions, concurrency, and backwards compatibility;
- whether tests exercise the changed behaviour and meaningful failure cases;
- schema, migration, public API, CLI, serialization, and deployment implications.

Run the smallest relevant existing checks when safe and practical:

- Prefer repository-defined commands and configuration.
- Use configured tools such as Ruff, Black check mode, mypy, Pyright, pytest, or coverage only when they are already dependencies or clearly part of the repository workflow.
- Scope checks to the target when the tool supports it.
- Do not install tools, introduce configuration, auto-fix files, or impose arbitrary coverage/type strictness during a read-only review.

Report commands and outcomes separately from findings. Manually validate tool output before promoting it to a finding. A passing check does not invalidate a code-level defect, and a failing unrelated check is not a finding against the reviewed code.

## Consolidate the review

1. Validate every subagent claim against the review target and repository before including it.
2. Merge duplicates by root cause, keeping the strongest evidence and all relevant locations.
3. Calibrate severity from impact and likelihood, not reviewer wording.
4. Separate blocking findings from non-blocking suggestions. Do not inflate optional refactors into defects.
5. Sort findings by priority, then confidence.

Return:

1. `Findings` with the highest-priority issues first.
2. `Questions or assumptions` only when an unresolved point changes the verdict.
3. `Checks run` with commands and outcomes.
4. A brief `Review coverage` naming all four completed specialist passes.

If there are no actionable findings, say so explicitly and mention any untested or unverified risk. Keep the summary secondary to the findings.
