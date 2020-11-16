# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="muse"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git brew gem)

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

ZSH_DISABLE_COMPFIX="true"
source $ZSH/oh-my-zsh.sh

# using http://direnv.net/ for multiple git users
# brew install direnv
eval "$(direnv hook zsh)"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias gitcongif="code ~/.gitconfig"

export MONGO_PATH=/usr/local/mongodb
export PATH=$PATH:$MONGO_PATH/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm


export GEM_EDITOR='code'

c() { cd ~/code/$1; }

_c() { _files -W ~/code -/; }
compdef _c c

p() { cd ~/Projects/$1;  }


_p() { _files -W ~/Projects -/; }
compdef _p p

alias df='cd ~/code/frontend'
alias dd='cd ~/code/frontend/packages/outdoorsy-dashboard'
alias ds='cd ~/code/frontend/packages/outdoorsy-search'
alias dr='cd ~/code/frontend/packages/reserve'
alias mc='cd ~/code/frontend/packages/marketplace-components'
alias esd='cd ~/code/frontend/packages/ember-shared-data'
alias dadmin='cd ~/code/frontend/packages/admin-portal'
alias odr='cd ~/code/outdoorsy-renter'

alias rs='rails s'
alias rc='rails c'
alias rj='rake jobs:work'

alias pgs='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pgstop='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop'

# git alias files
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpr='git pull --rebase'
alias gst='git status -s'
alias gs='git status'

alias gcm='git commit -m'
alias gam='git commit -am'
alias gcam='git commit --amend'
alias gad='git add --all'

alias gd='git diff'

alias gup='git smart-pull'
alias gm='git smart-merge'
alias gl='git smart-log'
alias gap='git add -p'
alias gcp='git commit -p'
alias gll='git pull -p'
alias gre='git recent' #depends on https://github.com/paulirish/git-recent

alias gbsort="git for-each-ref --sort=-committerdate --format='%1B[32m%(committerdate:iso8601) %1B[34m%(committerdate:relative) %1B[0;m%(refname:short)' refs/heads/"

alias redis='launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist'

alias bower='noglob bower'

alias tc='top-commands'
alias tcg='top-non-git'

alias e='ember'
alias es="ember server"
alias eg='ember generate'
alias edp="ember build --environment=production"
alias eb='ember build -w --output-path="../server/dist"'

alias testp="ember t -s --launch PhantomJS"
alias testc="ember t -s --launch Chrome"
alias tests="ember t -s --launch Safari"
alias testcc="ember t -s --launch Chrome\ Canary"
alias testf="ember t -s --launch Firefox"
alias testa="ember t -s"

alias gdev="grunt dev"

alias a='code .'

alias dnsflush='sudo discoveryutil mdnsflushcache;sudo discoveryutil udnsflushcaches;say flushed'

alias bt='broccoli-taco'
alias bts='broccoli-taco serve'
alias btbp='BROCCOLI_TACO_ENV=production broccoli-taco build dist'

alias bower='noglob bower'

alias ls="ls -pal"
alias ..="cd ../ && ls -al"
alias ...="cd ../../ && ls -al"
alias ....="cd ../../../ && ls -al"

alias lkd=npm-list-linked # depends on https://www.npmjs.com/package/npm-list-linked

alias server="python -m SimpleHTTPServer 3456"

function lc () {
  cd $1;
  ls
}

alias tc='top-commands'
alias tcg='top-non-git'

alias npm-bower='reinstall-npm-bower'

function command-frequency() {
  tail -n 10000 ~/.zsh_history | cut -d ';' -f 2 | awk '{print $1 " " $2}' | sort | uniq -c | sort -rn
}

# List the most-frequently used commands
function top-commands() {
  command-frequency | head -n 15
}

# List the most-frequently used non-Git commands
function top-non-git() {
  command-frequency | grep -v ' g ' | grep -v ' git ' | head -n 15
}

function reinstall-npm-bower() {
  CONT=
  vared -p "Are you sure you want to update npm and bower dependancies? (y/n)? " CONT
  if [ "$CONT" == "y" ]; then
    echo $fg[green] "Removing the node_modules and bower_components folders"
    rm -rf node_modules
    rm -rf bower_components
    echo $fg[green] "Clean and clear the caches"
    npm cache clear
    bower cache clean

    npm-bower-install
    echo "\n\n\n"
    echo $fg[green] "Done!"
  else
    echo $fg[green] "Ok then!"
  fi
}

function npm-bower-install() {
  echo $fg[green] "Installing NPM and Bower dependancies"
  npm set progress=false
  npm install
  bower install
  npm set progress=true
}

# export PATH="$PATH:$HOME/.rv/bin" # Add RVM to PATH for scripting
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:$HOME/.yarn/bin"
export PATH="$PATH:$HOME/.webdriver"
export PATH="$PATH:$HOME/.volta"
export PATH="/usr/local/opt/node@10/bin:$PATH"

export VOLTA_HOME="$HOME/.volta"
[ -s "$VOLTA_HOME/load.sh" ] && . "$VOLTA_HOME/load.sh"

export PATH="$VOLTA_HOME/bin:$PATH"
