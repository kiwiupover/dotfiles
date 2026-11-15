---
name: herdr-tidy
description: Close Herdr tabs in the current workspace whose agents (are idle or done)
---

<objective>
Close the Herdr tabs in this workspace whose agents have finished. Leave everything else running.
</objective>

<workflow>
1. List the candidates: `python3 ~/.claude/skills/herdr-tidy/scripts/idle_tabs.py`. A tab qualifies only when **every** pane in it runs an agent whose status is `idle` or `done`. Tabs with a plain shell, a dev server, an unknown pane, or any agent still `working` or `blocked` never qualify, and the tab you're running in is always skipped.
2. Before closing, check whether any candidate holds something that's still needed:
   - an agent waiting for an answer to a question;
   - a report or result that nobody has saved yet. If a result exists only in its terminal, read it with `herdr pane read <pane_id> --lines 200` and save it to a file before you close the tab.
3. Show the user the list, with each tab's label and agent title. Close the tabs once the user confirms. If the user has already said to close everything idle, close without asking again.
4. Close the tabs: `python3 ~/.claude/skills/herdr-tidy/scripts/idle_tabs.py --close`. To close only some of them, run `herdr tab close <tab_id>` for each one.
5. Report which tabs you closed and which you kept, and why.
</workflow>

<notes>
- Closing a tab ends its agent process. A Claude session can still be resumed later with `claude --resume`, but its terminal scrollback is lost.
- The script reads `herdr pane current`, `herdr pane list` and `herdr tab list`. It only ever closes whole tabs, never individual panes.
</notes>
