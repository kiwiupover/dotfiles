---
description: Parallel code review for staged changes (React, TypeScript, maintainability, existing patterns)
allowed-tools: Skill(review-code), Task, Bash, Read, Glob, Grep
---

<objective>
Delegate code review to the review-code skill for staged git changes.

This routes to a specialized skill that runs 4 parallel agents to review:
- React idioms and best practices
- TypeScript idioms and type safety
- Maintainability and clarity
- Existing patterns that might be duplicated
</objective>

<process>
1. Use Skill tool to invoke review-code skill
2. Skill handles parallel agent execution
3. Results consolidated into severity-grouped report
</process>

<success_criteria>
- Skill successfully invoked
- All 4 review agents complete
- Consolidated report presented to user
</success_criteria>
