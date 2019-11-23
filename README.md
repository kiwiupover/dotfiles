# My Dot files
My dot and atom files

## Install
### iTerm
https://www.iterm2.com/downloads.html

### HomeBrew
```sh 
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Dropbox
https://www.dropbox.com/install

### VSCode 
https://code.visualstudio.com/download

### Postico
https://eggerapps.at/postico/



### Git
```
brew install git node yarn git-recent rbenv zsh

```

### Ohmyzsh
```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Pull Configs
```sh
git clone https://github.com/kiwiupover/dotfiles.git
```

### NVM Node version manager
`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash`

Add node dependancies ember-cli and bower
```
yarn global add ember-cli bower
```

### Editor Font
http://www.dafont.com/bitstream-vera-mono.font

### direnv config
.envrc in the root of the folder
```js
export GIT_AUTHOR_EMAIL=kiwiupover@gmail.com
export GIT_COMMITTER_EMAIL=kiwiupover@gmail.com
```

### Volta
curl https://get.volta.sh | bash

## Symlink Files

```sh
cd ~
ln -shi dotfiles/.gitconfig .gitconfig
ln -shi dotfiles/.zshrc .zshrc
ln -shi dotfiles/.gitignore_global .gitignore_global
ln -shi dotfiles/.githelpers .githelpers
ln -shi ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -Fshfiv ~/dotfiles/vscode/snippets/ ~/Library/Application\ Support/Code/User
```
