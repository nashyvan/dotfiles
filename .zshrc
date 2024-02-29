# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

#ZSH_THEME="spaceship"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
source $ZSH/oh-my-zsh.sh

# SSH kitty fix
alias s="kitty +kitten ssh"

# Neovim
alias n='nvim'

# Tmux
alias tn='tmux new -s'

# Ripgrep aliases
alias rgl='rg -l'


# Git aliases
alias gs='git status --short'
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gme='git merge'
alias gplo='git pull origin $(git branch --show-current)'
alias gpso='git push origin $(git branch --show-current)'
alias gl='git log'
alias glp='git log -p'
alias gln='git log --name-only'
alias gcv='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gd='git diff'
alias gms='BRANCH=$(git branch --show-current); git checkout staging; git merge $BRANCH; git push origin staging; git checkout $BRANCH'
alias gda='git diff --color --name-only --diff-filter=A'
alias gdm='git diff --color --name-only --diff-filter=M'
alias gdd='git diff --color --name-only --diff-filter=D'


# ls
alias l="exa -lah --git"
alias lt="exa -lahT --git"


# cd
#alias cdd='cd ~/Downloads'
alias cdd='cd ~/Developer'


# Docker aliases
alias dps='docker ps'


#TODO
alias td="cat $NOTES_DIR/TODO.md"
alias tde="(cd $NOTES_DIR && vim TODO.md && git add TODO.md && git commit -m 'update TODO')"


#NOTES
alias nt="(cd $NOTES_DIR && vim tmp.md)"
alias nu="(cd $NOTES_DIR && git add . && git commit -m 'update notes')"

export EDITOR=nvim
export PATH="/usr/local/sbin:$PATH"


autoload -U promptinit; promptinit
prompt pure

