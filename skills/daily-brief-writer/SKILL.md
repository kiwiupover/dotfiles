---
name: daily-brief-writer
description: Use when a worker or orchestrator finishes overnight work and writes the daily or morning brief for Dave: publishes a self-contained brief to his work Notion.
---

# Writing the daily brief

Dave reviews this brief by voice with a Claude that can't see the repo, files, logs, terminal or earlier chats. **Anything not in the brief can't be discussed.** Write it so it stands on its own.

## Where it goes

Work Notion, under the private page **Daily Brief**. Create the brief as a page under its project's page. The page IDs live in [NOTION.local.md](NOTION.local.md), an untracked file on this machine; if it's missing, search work Notion for the "Daily Brief" page and pick the project page under it.

One brief per project per night. If several workers ran on one project, the orchestrator merges them into one brief.

**Title:** name the topic, for example "Search latency reduction". Never put a date in the title.

**First line:** the date, the worker or session name, and the branch or PR if there is one.

**Referenced files:** if a file matters to a decision (REVIEW.md, a plan, a results file), summarise what it says in the brief. If Dave may need the full text, add it as a child page of the brief, titled after the file.

If you can't reach Notion, write the brief as markdown in the usual briefing folder and say so in your final message.

## Structure

Number every section (1, 2, 3...) so Dave can say "go back to section 4".

1. **Summary:** 3 to 5 lines. What was built, what's blocked, what was spent, how many decisions are waiting.
2. **What was done:** one numbered section per piece of work. For each: what it is, why it matters, what changed, and the result.
3. **Risks and surprises:** risks, anything done without approval, anything broken or left running.
4. **Decisions for Dave:** numbered. For each: the question, the options, your recommendation, the default you took, and what it unblocks.
5. **Discussion notes:** leave this heading empty. The reviewer fills it during the call.

## Writing rules

- Explain in plain words. Don't just name files, flags or functions; say what they do.
- Paste in the facts needed to decide: numbers, short quotes, test results, costs and the reasoning behind them. Never write "see REVIEW.md" without summarising it.
- Mark how solid each number is: measured live, offline estimate, or synthetic or provisional data.
- Keep it speakable: short sentences, no big tables, no long code blocks, no em dashes.
- Never include secrets, keys, .env contents or patient data.
