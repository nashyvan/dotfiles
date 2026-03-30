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

# Set custom path for Zsh completion dump file, using hostname to avoid conflicts across machines
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Neovim
alias n='nvim'

# Tmux
alias tn='tmux new -s'

# Ripgrep
alias rgl='rg -l'

# Git
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
alias cdd='cd ~/Developer'

# Docker
alias dps='docker ps'

# TODO
alias td="cat $NOTES_DIR/TODO.md"
alias tde="(cd $NOTES_DIR && vim TODO.md && git add TODO.md && git commit -m 'update TODO')"

# Notes
alias nt="(cd $NOTES_DIR && vim tmp.md)"
alias nu="(cd $NOTES_DIR && git add . && git commit -m 'update notes')"

# Set default editor to Neovim
export EDITOR=nvim

# Prepend /usr/local/sbin to the PATH
export PATH="/usr/local/sbin:$PATH"

# Load environment variables from .env file used by Borgmatic
export $(cat ~/.config/borgmatic/.env | xargs)

# OpenAI API Key
#bw sync
#export BW_SESSION=$(bw unlock --raw)
#export OPENAI_API_KEY=$(bw get password "OpenAI API Key" --session $BW_SESSION)

# Add Homebrew-managed zsh completions to function path
fpath+=/opt/homebrew/share/zsh/site-functions

# Initialize and set the "pure" prompt
autoload -U promptinit && promptinit
prompt pure

# Set up Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Load NVM
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load NVM bash completion
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
