#!/usr/bin/env bash
# Symlink dotfiles into place. Safe to re-run: correct links are left alone,
# missing ones are created, and anything else in the way is moved to
# ~/.dotfiles-backup/<timestamp>/ first.
#
#   ./link.sh      make the links
#   ./link.sh -n   dry run: show what would change

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
APP_SUPPORT="$HOME/Library/Application Support"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
[[ "${1:-}" == "-n" ]] && DRY_RUN=1

run() {
  if [[ $DRY_RUN == 1 ]]; then echo "        would: $*"; else "$@"; fi
}

# link <path in repo> <destination>
link() {
  local src="$DOTFILES/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    echo "missing $src (skipped)"
    return
  fi

  if [[ -L "$dest" && "$(realpath "$dest" 2>/dev/null)" == "$(realpath "$src")" ]]; then
    echo "ok      $dest"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="$BACKUP_DIR/${dest#"$HOME"/}"
    echo "backup  $dest -> $backup"
    run mkdir -p "$(dirname "$backup")"
    run mv "$dest" "$backup"
  fi

  echo "link    $dest -> $src"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

run mkdir -p "$HOME/code" "$HOME/projects"

link .gitconfig                       "$HOME/.gitconfig"
link .zshrc                           "$HOME/.zshrc"
link .gitignore_global                "$HOME/.gitignore_global"
link .githelpers                      "$HOME/.githelpers"
link vscode/settings.json             "$APP_SUPPORT/Code/User/settings.json"
link vscode/snippets                  "$APP_SUPPORT/Code/User/snippets"
link ghostty/config                   "$APP_SUPPORT/com.mitchellh.ghostty/config"
link herdr/config.toml                "$HOME/.config/herdr/config.toml"
link herdr/plugins/tab-close-confirm  "$HOME/.config/herdr/plugins/tab-close-confirm"

# Claude Code skills
link skills/blast-radius              "$HOME/.claude/skills/blast-radius"
link skills/bro                       "$HOME/.claude/skills/bro"
link skills/handoff                   "$HOME/.claude/skills/handoff"
link skills/unslop                    "$HOME/.claude/skills/unslop"
link skills/review-code               "$HOME/.claude/skills/review-code"
link skills/python-code-review        "$HOME/.claude/skills/python-code-review"
link claude/commands/review-code.md   "$HOME/.claude/commands/review-code.md"

# Codex skills
link skills/unslop                    "$HOME/.codex/skills/unslop"
link skills/grilling                  "$HOME/.codex/skills/grilling"
link skills/grill-me                  "$HOME/.codex/skills/grill-me"
link skills/domain-modeling           "$HOME/.codex/skills/domain-modeling"
