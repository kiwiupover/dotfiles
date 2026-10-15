const { spawnSync } = require("node:child_process");

const herdr = process.env.HERDR_BIN_PATH || "herdr";
const SAFE_ID = /^[A-Za-z0-9:._-]+$/;

function isSafeId(value) {
	return typeof value === "string" && SAFE_ID.test(value) && !value.startsWith("-");
}

function run(args) {
	const result = spawnSync(herdr, args, {
		encoding: "utf8",
		stdio: ["ignore", "pipe", "pipe"],
	});
	if (result.error) throw new Error(`${herdr} failed to start: ${result.error.message}`);
	if (result.status !== 0) {
		throw new Error((result.stderr || result.stdout || `exit ${result.status}`).trim());
	}
	return result.stdout;
}

function runJson(args) {
	const output = run(args);
	try {
		return JSON.parse(output);
	} catch {
		throw new Error(`${herdr} returned non-JSON output`);
	}
}

function readJson(value) {
	if (!value) return null;
	try {
		return JSON.parse(value);
	} catch {
		return null;
	}
}

function resolveTarget() {
	const context = readJson(process.env.HERDR_PLUGIN_CONTEXT_JSON) || {};
	const requestedWorkspaceId = process.env.HERDR_WORKSPACE_ID || context.workspace_id;
	const requestedTabId = process.env.HERDR_TAB_ID || context.tab_id;
	const workspaces = runJson(["workspace", "list"]).result?.workspaces || [];
	let workspace = isSafeId(requestedWorkspaceId)
		? workspaces.find((item) => item.workspace_id === requestedWorkspaceId)
		: null;
	if (!workspace) workspace = workspaces.find((item) => item.focused) || null;
	if (!workspace) throw new Error("no focused workspace");

	const tabs = runJson(["tab", "list", "--workspace", workspace.workspace_id]).result?.tabs || [];
	const tabId = isSafeId(requestedTabId) ? requestedTabId : workspace.active_tab_id;
	const tab = tabs.find((item) => item.tab_id === tabId);
	if (!tab) throw new Error("the active tab no longer exists");
	return { workspace, tab };
}

function openConfirmation(workspaceId, tabId) {
	if (!isSafeId(workspaceId) || !isSafeId(tabId)) throw new Error("invalid close target");
	run([
		"plugin", "pane", "open",
		"--plugin", "tab-close-confirm",
		"--entrypoint", "confirm",
		"--focus",
		"--env", `HERDR_CLOSE_WORKSPACE_ID=${workspaceId}`,
		"--env", `HERDR_CLOSE_TAB_ID=${tabId}`,
	]);
}

module.exports = { isSafeId, openConfirmation, resolveTarget, runJson };
