#!/usr/bin/env python3
"""List, or close, Herdr tabs in the current workspace whose agents have all finished.

A tab qualifies only when every pane in it runs an agent (Claude, Codex, ...) that is idle or done.
Tabs with a plain shell, a server or an unknown pane are never touched, nor is the caller's own tab.

  idle_tabs.py            print the qualifying tabs as JSON
  idle_tabs.py --close    close them, then print what was closed
"""

import json
import subprocess
import sys

FINISHED = {"idle", "done"}


def herdr(*args: str) -> dict:
    output = subprocess.run(["herdr", *args], capture_output=True, text=True, check=True).stdout
    return json.loads(output)["result"]


def idle_tabs() -> list[dict]:
    current = herdr("pane", "current")["pane"]
    panes_by_tab: dict[str, list[dict]] = {}
    for pane in herdr("pane", "list")["panes"]:
        panes_by_tab.setdefault(pane.get("tab_id", ""), []).append(pane)
    tabs = []
    for tab in herdr("tab", "list")["tabs"]:
        if tab["workspace_id"] != current["workspace_id"] or tab["tab_id"] == current["tab_id"]:
            continue
        panes = panes_by_tab.get(tab["tab_id"], [])
        if panes and all(pane.get("agent") and pane.get("agent_status") in FINISHED for pane in panes):
            tabs.append(
                {
                    "tab_id": tab["tab_id"],
                    "label": tab["label"],
                    "agents": [f'{pane["agent"]} ({pane["agent_status"]}): {pane.get("terminal_title_stripped", "")}' for pane in panes],
                }
            )
    return tabs


def main() -> None:
    tabs = idle_tabs()
    if "--close" in sys.argv[1:]:
        for tab in tabs:
            subprocess.run(["herdr", "tab", "close", tab["tab_id"]], capture_output=True, check=True)
    print(json.dumps({"closed" if "--close" in sys.argv[1:] else "idle": tabs}, indent=2))


if __name__ == "__main__":
    main()
