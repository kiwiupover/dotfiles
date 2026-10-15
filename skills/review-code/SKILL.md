---
name: review-code
description: Parallel code review for staged git changes using 4 specialized agents (React idioms, TypeScript idioms, maintainability, existing patterns), then generate phased implementation plans with task tracking. Use when the user asks to review code, check code quality, or before committing changes.
---

<objective>
Run comprehensive code review on staged git changes using 4 parallel subagents, consolidate findings into an actionable report, and generate phased implementation plans with task tracking for systematic fixes.
</objective>

<quick_start>
<workflow>
1. Get staged files with `git diff --cached --name-only`
2. Launch 4 Task agents in parallel (single message, multiple tool calls)
3. Wait for all agents to complete
4. Consolidate findings into severity-grouped report
5. Generate phased implementation plan (Quick Wins → Helpers → Major Refactoring)
6. Create tasks for progress tracking and implement fixes (with user approval)
7. Run verification (lint + types)
</workflow>

<invocation>
User says: "review my code", "check this before commit", "/review-code"
</invocation>
</quick_start>

<agent_definitions>
<agent name="react-idioms">
<focus>React patterns, hooks rules, component architecture, performance</focus>
<prompt_template>
Review these staged files for React idioms and best practices:

FILES TO REVIEW:
{staged_files_content}

REVIEW CRITERIA (prioritized by impact):

**CRITICAL - Eliminating Waterfalls:**
- Parallel data fetching (Promise.all, not sequential awaits)
- Proper Suspense boundaries
- Avoiding async request chains

**CRITICAL - Bundle Size:**
- Dynamic imports for heavy components
- Tree-shaking friendly exports
- Avoiding barrel file re-exports in app code

**HIGH - Server-Side Patterns:**
- Proper use of Server vs Client Components
- Data fetching at appropriate boundaries
- Caching strategies

**MEDIUM - Re-render Optimization:**
- Stable references (useCallback, useMemo when needed)
- Proper key usage in lists
- State colocation (state close to where it's used)
- Avoiding inline object/array literals in JSX props

**MEDIUM - Component Architecture:**
- Composition over boolean props
- Compound components for complex UI
- Explicit variants instead of boolean modes
- Children over render props

**React 19 Patterns:**
- Direct ref props (no forwardRef needed)
- use() for context consumption
- Proper Server Component boundaries

For each issue found:
- State severity: CRITICAL, HIGH, MEDIUM, LOW
- Quote the problematic code
- Explain why it's an issue
- Provide corrected code example
</prompt_template>
</agent>

<agent name="typescript-idioms">
<focus>Type safety, inference, patterns, strict mode compliance</focus>
<prompt_template>
Review these staged files for TypeScript idioms and best practices:

FILES TO REVIEW:
{staged_files_content}

REVIEW CRITERIA:

**Type Safety:**
- Avoid `any` - use `unknown` with type guards
- Proper generic constraints
- Discriminated unions for state
- Exhaustive switch/if checks

**Type Inference:**
- Let TypeScript infer when obvious
- Explicit return types for public APIs
- Const assertions for literals
- Satisfies operator for validation without widening

**Patterns:**
- Prefer `type` over `interface` for consistency
- Template literal types for string patterns
- Mapped types for transformations
- Utility types (Partial, Required, Pick, Omit)

**Strictness:**
- No implicit any
- Strict null checks
- No unused variables/parameters (prefix with _)

For each issue found:
- State severity: CRITICAL, HIGH, MEDIUM, LOW
- Quote the problematic code
- Explain why it's an issue
- Provide corrected code example
</prompt_template>
</agent>

<agent name="maintainability">
<focus>Clarity, readability, simplicity, documentation</focus>
<prompt_template>
Review these staged files for maintainability and clarity:

FILES TO REVIEW:
{staged_files_content}

REVIEW CRITERIA:

**Clarity:**
- Clear, descriptive naming (variables, functions, components)
- Single responsibility (functions do one thing)
- Appropriate abstraction level (not over/under-engineered)
- Self-documenting code structure

**Readability:**
- Consistent formatting and style
- Logical code organization
- Appropriate line length and function size
- Clear control flow (avoid deep nesting)

**Simplicity:**
- No premature optimization
- No unnecessary abstractions
- Direct solutions over clever ones
- Minimal dependencies between modules

**Documentation:**
- Complex logic has explanatory comments
- Public APIs have JSDoc when non-obvious
- No redundant comments (code should speak)

For each issue found:
- State severity: CRITICAL, HIGH, MEDIUM, LOW
- Quote the problematic code
- Explain why it's an issue
- Provide corrected code example
</prompt_template>
</agent>

<agent name="existing-patterns">
<focus>Find existing implementations that new code might duplicate</focus>
<prompt_template>
Analyze these staged files and search the codebase for existing patterns that might be duplicated:

FILES TO REVIEW:
{staged_files_content}

SEARCH STRATEGY:
1. Identify what the new code is implementing (utilities, hooks, components, helpers)
2. Search entire codebase for similar implementations:
   - Use Grep to find similar function/component names
   - Use Glob to find files in relevant directories (src/lib, src/utils, src/hooks, src/components)
   - Read potentially matching files to confirm similarity

LOOK FOR:
- Utility functions that already exist
- Custom hooks with similar functionality
- Components that do the same thing
- Helper functions that are being reinvented
- Constants/configs that are already defined elsewhere

For each potential duplication found:
- State confidence: HIGH, MEDIUM, LOW
- Show the new code being added
- Show the existing code location and snippet
- Recommend: use existing, extend existing, or keep new (with justification)
</prompt_template>
</agent>
</agent_definitions>

<execution_protocol>
<step_1>
**Get staged files**

```bash
git diff --cached --name-only --diff-filter=ACMR
```

Filter to relevant files: `*.ts`, `*.tsx`, `*.js`, `*.jsx`

If no staged files, inform user and offer to review specific files instead.
</step_1>

<step_2>
**Get file contents**

Read each staged file's content. For the diff context:
```bash
git diff --cached -- {file}
```
</step_2>

<step_3>
**Launch 4 parallel agents**

Use a SINGLE message with 4 Task tool calls:

```
Task(subagent_type="general-purpose", prompt="[react-idioms prompt]", description="React idioms review")
Task(subagent_type="general-purpose", prompt="[typescript-idioms prompt]", description="TypeScript idioms review")
Task(subagent_type="general-purpose", prompt="[maintainability prompt]", description="Maintainability review")
Task(subagent_type="general-purpose", prompt="[existing-patterns prompt]", description="Existing patterns check")
```

All 4 must be in the same message to run in parallel.
</step_3>

<step_4>
**Consolidate findings**

Group by severity across all agents:

```
## Critical Issues (must fix)
[issues from all agents]

## High Priority
[issues from all agents]

## Medium Priority
[issues from all agents]

## Low Priority / Suggestions
[issues from all agents]

## Existing Patterns Found
[from existing-patterns agent]
```
</step_4>

<step_5>
**Generate phased implementation plan**

Organize all issues into a phased implementation plan:

```markdown
## Review Findings

### Critical Issues ({count})
| Issue | File | Impact |
|-------|------|--------|
| Description | path.ts:line | Why it matters |

### High Priority ({count})
| Issue | File | Impact |
|-------|------|--------|
| Description | path.ts:line | Why it matters |

### Medium Priority ({count})
| Issue | File | Impact |
|-------|------|--------|
| Description | path.ts:line | Why it matters |

---

## Recommended Fix Priority

### Phase 1: Quick Wins (Low Risk)
Simple fixes with immediate impact:
- Magic numbers → named constants
- Fire-and-forget patterns (analytics, logging)
- Missing error handling on isolated functions
- Simple type fixes

### Phase 2: Extract Helpers (Medium Risk)
Consolidation and extraction:
- Extract complex conditions to named functions
- Consolidate duplicate patterns
- Create shared utilities from repeated code

### Phase 3: Major Refactoring (Higher Risk)
Structural changes requiring careful testing:
- Break down large functions into focused helpers
- Restructure component hierarchies
- Significant API changes
```

Present this plan to the user clearly.
</step_5>

<step_6>
**Offer to implement fixes with task tracking**

Ask user: "I've identified {n} issues across {phases} phases. Would you like me to implement these fixes?"

If yes, proceed to step 7.
</step_6>

<step_7>
**Implement fixes with task tracking**

Use TaskCreate to create tasks for each phase:

```
TaskCreate(
  subject="Phase 1: Quick Wins",
  description="Implement low-risk fixes: [list specific fixes]",
  activeForm="Implementing quick wins"
)
```

For each phase:
1. Mark task as `in_progress` using TaskUpdate
2. Apply fixes using Edit tool
3. Mark task as `completed` when done
4. Move to next phase

User sees progress spinner during implementation.
</step_7>

<step_8>
**Run verification**

After all fixes applied:

```bash
pnpm lint:eslint
pnpm lint:types
```

Report results:
- If passing: "All fixes verified. Lint and type checks pass."
- If failing: List new issues introduced and offer to fix them
</step_8>
</execution_protocol>

<success_criteria>
- All 4 agents complete successfully
- Findings consolidated by severity with table format
- Critical issues clearly highlighted
- Existing pattern duplications identified
- Implementation plan generated with clear phases (Quick Wins → Helpers → Major Refactoring)
- Tasks created for progress visibility during implementation
- Verification passes (lint + types) after all fixes applied
</success_criteria>

<anti_patterns>
- Don't run agents sequentially - must be parallel
- Don't review unstaged files unless user specifies
- Don't auto-fix without asking - always get user approval before implementing
- Don't report on files outside the staged changes
- Don't skip verification after applying fixes
- Don't implement all phases at once - work through them systematically with task tracking
</anti_patterns>

<implementation_planning>
After consolidating findings, generate a phased implementation plan that groups issues by risk level:

**Phase 1: Quick Wins (Low Risk)**
Fixes that are isolated and unlikely to cause regressions:
- Magic numbers → named constants in constants files
- Fire-and-forget patterns (void analytics calls, Promise.resolve())
- Simple type annotations
- Missing await on independent async calls
- Obvious null checks

**Phase 2: Extract Helpers (Medium Risk)**
Refactoring that creates new abstractions:
- Extract complex boolean conditions to named predicate functions
- Consolidate duplicate code patterns into shared utilities
- Create type guards for repeated type narrowing
- Extract inline objects/arrays to constants

**Phase 3: Major Refactoring (Higher Risk)**
Structural changes that may affect multiple call sites:
- Break down large functions (>50 lines) into focused helpers
- Restructure component props/state
- API signature changes
- Moving code between files/modules

**Table format for presenting issues:**
```markdown
| Issue | File | Impact |
|-------|------|--------|
| Large function hard to test | src/lib/handler.ts:50 | Maintenance burden |
| Sequential awaits causing waterfall | src/api/fetch.ts:112 | Performance bottleneck |
```

This format helps users understand both what needs fixing and why it matters.
</implementation_planning>

<task_tracking>
Use TaskCreate/TaskUpdate to provide progress visibility during implementation:

**Creating tasks:**
```
TaskCreate(
  subject="Phase 1: Quick Wins - [specific description]",
  description="Fix magic numbers, fire-and-forget patterns, simple types",
  activeForm="Implementing quick wins"
)
```

**Working on tasks:**
```
TaskUpdate(taskId="...", status="in_progress")
# ... apply fixes ...
TaskUpdate(taskId="...", status="completed")
```

**Benefits:**
- User sees spinner with current phase description
- Clear progress through multi-phase implementation
- Easy to pause/resume if user needs to intervene
- Audit trail of what was changed
</task_tracking>

<verification>
After all fixes are applied, run verification to ensure no regressions:

```bash
pnpm lint:eslint
pnpm lint:types
```

**If verification passes:**
Report success and summarize changes made.

**If verification fails:**
1. List the specific errors introduced
2. Identify which fix caused the issue
3. Offer to fix the new issues or rollback the problematic change

Never consider the review complete until verification passes.
</verification>
