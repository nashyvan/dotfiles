# To setup run:
# ln -s ~/.config/.zshrc ~/.zshrc
# source ~/.config/.zshrc

# Initialize completion system
autoload -Uz compinit && compinit

# zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/plugins/zsh-syntax-highlighting
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
#source $ZSH/oh-my-zsh.sh

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
alias l="eza -lah --git"
alias lt="eza -lahT --git"


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

export $(cat ~/.config/borgmatic/.env | xargs)

fpath+=/opt/homebrew/share/zsh/site-functions
autoload -U promptinit && promptinit
prompt pure
