# AGENTS.md

This repo is **public** on GitHub. Every committed line, on every branch and in every past commit, is world-readable, so write each change as if posting it.

## Private values live outside the repo

Keep the repo generic and put private values in the untracked files it already loads:

- `~/dotfiles/.env`: shell variables, sourced by `.zshrc`. Add each new variable to `.env.example` with a placeholder value.
- `~/.gitconfig.local`: per-machine git settings, such as the commit signing key. Included from `.gitconfig`.

Tracked files refer to these values by variable name or by a generic description.

Private means:

- secrets: API keys, tokens, passwords, private keys, connection strings
- work details: employer and client names, internal project or repo names, internal URLs, colleague names
- account identifiers: Notion page or database IDs, Slack channel IDs, Linear team IDs, workspace names
- personal data beyond the name and email already in `.gitconfig`

## Before committing

Read the staged diff (`git diff --cached`) for anything in the list above, including inside skills and their examples. Skills get copied around, so write their examples with made-up names.

If private data has already been pushed, stop and tell the user. Removing it takes a history rewrite and a force push, plus rotating any secret, so the user decides.
