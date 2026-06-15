# To setup run:
# ln -sf ~/.config/.zshrc ~/.zshrc

# OS detection
export OS_TYPE="$(uname -s)"

# macOS: Homebrew paths and completions
if [[ "$OS_TYPE" == "Darwin" ]]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  export PATH="/usr/local/sbin:$PATH"
  fpath+=/opt/homebrew/share/zsh/site-functions
fi

# Linux: pure-prompt installed via npm; add to fpath
if [[ "$OS_TYPE" == "Linux" ]]; then
  NPM_PREFIX=$(npm prefix -g 2>/dev/null || true)
  [[ -n "$NPM_PREFIX" ]] && fpath+=("$NPM_PREFIX/lib/node_modules/pure-prompt/functions")
  export PATH="$HOME/.local/bin:$PATH"
fi

# Initialize completion system
autoload -Uz compinit && compinit

# zsh-autosuggestions
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting
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

# Load environment variables from .env file used by Borgmatic
[[ -f ~/.config/borgmatic/.env ]] && export $(cat ~/.config/borgmatic/.env | xargs)

# Initialize and set the "pure" prompt
autoload -U promptinit && promptinit
prompt pure

# Set up Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm
if [[ "$OS_TYPE" == "Darwin" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
