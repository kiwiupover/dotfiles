#!/usr/bin/env node

const readline = require("node:readline");
const { stdin: input, stdout: output } = require("node:process");
const lib = require("./lib.js");

// Catppuccin Mocha
const PINK = [243, 139, 168];
const TEXT = [205, 214, 244];
const SUBTEXT = [166, 173, 200];
const MUTED = [108, 112, 134];
const SURFACE = [49, 50, 68];
const BASE = [24, 24, 37];
const CRUST = [17, 17, 27];

const fg = ([r, g, b]) => `\x1b[38;2;${r};${g};${b}m`;
const bg = ([r, g, b]) => `\x1b[48;2;${r};${g};${b}m`;
const RESET = `\x1b[0m${bg(BASE)}`;
const BOLD = "\x1b[1m";

const truncate = (text, width) => (text.length > width ? `${text.slice(0, Math.max(0, width - 1))}…` : text);
const plural = (count, word) => `${count} ${word}${count === 1 ? "" : "s"}`;

// Each content line is { text, width, center? } where width is the visible length of text.
const plain = (text, color, style = "") => ({ text: `${style}${fg(color)}${text}${RESET}`, width: text.length });
const button = (text, back, front) => ({ text: `${bg(back)}${fg(front)}  ${text}  ${RESET}`, width: text.length + 4 });
const join = (parts, gap) => ({
	text: parts.map((part) => part.text).join(" ".repeat(gap)),
	width: parts.reduce((sum, part) => sum + part.width, 0) + gap * (parts.length - 1),
	center: true,
});

// herdr draws the popup frame, so this only lays out content inside it.
function render(lines) {
	const cols = output.columns || 60;
	const rows = output.rows || 9;
	const padX = 2;
	const padY = rows > lines.length + 1 ? 1 : 0;
	const blankRow = " ".repeat(cols);

	const out = [];
	for (let i = 0; i < padY; i++) out.push(blankRow);
	for (const line of lines) {
		const left = line.center ? Math.max(0, Math.floor((cols - line.width) / 2)) : padX;
		out.push(`${" ".repeat(left)}${line.text}${" ".repeat(Math.max(0, cols - left - line.width))}`);
	}
	while (out.length < rows) out.push(blankRow);

	output.write(`${bg(BASE)}\x1b[2J\x1b[H${out.slice(0, rows).join("\r\n")}`);
}

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

	output.write("\x1b[?25l");
	const room = Math.max(10, (output.columns || 60) - 4);
	if (!workspace || !tab) {
		render([plain("The tab was already closed. Nothing to do.", MUTED)]);
		return;
	}

	const closesWorkspace = tabs.length === 1;
	const workspaceName = workspace.label || workspaceId;
	const tabName = tab.label || tabId;
	const title = closesWorkspace ? "Close workspace?" : "Close tab?";
	const detail = closesWorkspace
		? `${workspaceName} — ${plural(workspace.pane_count ?? tab.pane_count ?? 1, "pane")}`
		: `${workspaceName} › tab ${tabName} — ${plural(tab.pane_count ?? 1, "pane")}`;
	const header = [plain(title, PINK, BOLD), plain(truncate(detail, room), SUBTEXT)];
	const buttons = join([button("↵ confirm", PINK, CRUST), button("esc cancel", SURFACE, TEXT)], 4);
	const status = (text, color = MUTED) => render([...header, plain("", MUTED), { ...plain(text, color), center: true }]);

	const draw = () => render([...header, plain("", MUTED), buttons]);
	draw();
	output.on("resize", draw);
	const confirmed = await waitForDecision();
	output.off("resize", draw);

	if (!confirmed) {
		status("Cancelled.");
		return;
	}

	const currentTabs = lib.runJson(["tab", "list", "--workspace", workspaceId]).result?.tabs || [];
	if (!currentTabs.some((item) => item.tab_id === tabId)) {
		status("The tab was already closed. Nothing to do.");
		return;
	}
	if (currentTabs.length === 1) lib.runJson(["workspace", "close", workspaceId]);
	else lib.runJson(["tab", "close", tabId]);
	status(currentTabs.length === 1 ? "Workspace closed." : "Tab closed.");
}

process.on("exit", () => output.write("\x1b[0m\x1b[?25h"));

main().catch((error) => {
	output.write(`\nCould not close tab: ${error.message}\n`);
	process.exitCode = 1;
});
