#!/usr/bin/env node

const readline = require("node:readline");
const { stdin: input, stdout: output } = require("node:process");
const lib = require("./lib.js");

function waitForDecision() {
	if (!input.isTTY || typeof input.setRawMode !== "function") {
		throw new Error("confirmation popup has no interactive terminal");
	}

	readline.emitKeypressEvents(input);
	const wasRaw = input.isRaw;
	input.setRawMode(true);
	input.resume();

	return new Promise((resolve) => {
		function finish(confirmed) {
			input.off("keypress", onKeypress);
			input.setRawMode(wasRaw);
			input.pause();
			resolve(confirmed);
		}

		function onKeypress(_text, key = {}) {
			if (key.name === "return" || key.name === "enter") finish(true);
			else if (key.name === "escape" || (key.ctrl && key.name === "c")) finish(false);
		}

		input.on("keypress", onKeypress);
	});
}

async function main() {
	const workspaceId = process.env.HERDR_CLOSE_WORKSPACE_ID;
	const tabId = process.env.HERDR_CLOSE_TAB_ID;
	if (!lib.isSafeId(workspaceId) || !lib.isSafeId(tabId)) throw new Error("invalid close target");

	const workspace = (lib.runJson(["workspace", "list"]).result?.workspaces || [])
		.find((item) => item.workspace_id === workspaceId);
	const tabs = lib.runJson(["tab", "list", "--workspace", workspaceId]).result?.tabs || [];
	const tab = tabs.find((item) => item.tab_id === tabId);

	output.write("\x1b[2J\x1b[H");
	if (!workspace || !tab) {
		output.write("The tab was already closed. Nothing to do.\n");
		return;
	}

	output.write("Close this tab?\n\n");
	output.write(`Tab       : ${tab.label || tabId}\n`);
	output.write(`Workspace : ${workspace.label || workspaceId}\n\n`);
	if (tabs.length === 1) output.write("This is the last tab, so its workspace will also close.\n\n");

	output.write("[Enter] Close tab    [Esc] Cancel");
	const confirmed = await waitForDecision();

	if (!confirmed) {
		output.write("\nCancelled. Tab kept.\n");
		return;
	}

	const currentTabs = lib.runJson(["tab", "list", "--workspace", workspaceId]).result?.tabs || [];
	if (!currentTabs.some((item) => item.tab_id === tabId)) {
		output.write("\nThe tab was already closed. Nothing to do.\n");
		return;
	}
	if (currentTabs.length === 1) lib.runJson(["workspace", "close", workspaceId]);
	else lib.runJson(["tab", "close", tabId]);
	output.write("\nTab closed.\n");
}

main().catch((error) => {
	output.write(`\nCould not close tab: ${error.message}\n`);
	process.exitCode = 1;
});
