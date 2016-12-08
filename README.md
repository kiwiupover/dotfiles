# My Dot files
My dot and atom files

## Install
### HomeBrew
```sh 
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Git
```
brew install git direnv yarn
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

## Symlink Files

```sh
cd ~
ln -shi dotfiles/.atom .atom 
ln -shi dotfiles/.gitconfig .gitconfig
ln -shi dotfiles/.zshrc .zshrc
ln -shi dotfiles/.gitignore_global .gitignore_global
ln -shi dotfiles/.githelpers .githelpers
```
