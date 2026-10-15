#!/usr/bin/env node

const lib = require("./lib.js");

try {
	const target = lib.resolveTarget();
	lib.openConfirmation(target.workspace.workspace_id, target.tab.tab_id);
} catch (error) {
	process.stderr.write(`tab-close-confirm: ${error.message}\n`);
	process.exitCode = 1;
}
