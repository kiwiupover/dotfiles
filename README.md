# My Dot files
My dot and atom files

## New Mac setup

Work through these in order. Everything is safe to repeat; see [Rerun](#rerun) for a machine that's already set up.

### 1. HomeBrew
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Git and shell tools
```sh
brew install git git-recent rbenv zsh direnv
```

### 3. Ohmyzsh
```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
This writes its own `~/.zshrc`. That's fine: `link.sh` (step 7) backs it up and links the one from this repo.

### 4. Volta
```sh
curl https://get.volta.sh | bash
```

Add node dependencies ember-cli and bower and yarn
```sh
volta install ember-cli bower yarn
```

### 5. Pull Configs
```sh
git clone git@github.com:kiwiupover/dotfiles.git ~/dotfiles
```

### 6. Apps

#### Ghostty
https://ghostty.org/download

Download the .dmg and drag Ghostty to Applications, or:
```sh
brew install --cask ghostty
```

#### herdr
https://herdr.dev
```sh
curl -fsSL https://herdr.dev/install.sh | sh
```
Installs to `~/.local/bin/herdr`. Keep it current with `herdr update`.
The tab-close-confirm plugin needs `node` (from Volta, step 4).

#### VSCode
https://code.visualstudio.com/download
Download and run vscode.

#### Dropbox
https://www.dropbox.com/install

#### Postico
https://eggerapps.at/postico/

#### Editor Font
http://www.dafont.com/bitstream-vera-mono.font

https://www.dropbox.com/home/DankMono

### 7. Symlink Files

```sh
cd ~/dotfiles
./link.sh -n   # dry run: show what would change
./link.sh
```

`link.sh` is safe to run as often as you like:
- links that already point into `~/dotfiles` are left alone (`ok`)
- missing links are created, along with any missing parent folders
- a real file or folder in the way is moved to `~/.dotfiles-backup/<timestamp>/` before it's replaced

To add something new, put it in the repo and add a `link` line at the bottom of `link.sh`.

## Rerun

For a machine that's already set up, or one where the first run missed things:

```sh
cd ~/dotfiles
git pull
./link.sh -n   # check what will change
./link.sh
```

Then:
- Install anything from [New Mac setup](#new-mac-setup) that's missing. Re-running an installer you already have is fine to skip.
- Restart any app whose config changed, or for herdr run `herdr server reload-config`.
- Once you're happy, delete old backups in `~/.dotfiles-backup/`.

## herdr

Tracked in `herdr/`:
- `config.toml`: keybindings, UI and theme. `cmd+w` and `prefix+shift+x` are bound to the plugin below instead of herdr's built-in `close_tab`.
- `plugins/tab-close-confirm/`: a local plugin that asks for confirmation (Enter to close, Esc to cancel) before closing a tab. Needs `node`.

`ghostty/config` unbinds `cmd+t` and `cmd+w` so those keys reach herdr.

Left out on purpose: logs (`herdr-*.log`), sockets (`*.sock`), session state (`session.json`, `release-notes.json`, `.plugins.lock`), `plugins.json` (absolute paths, herdr regenerates it) and `plugins/config/` (per-plugin state dir).
