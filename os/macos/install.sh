#!/usr/bin/env bash
#
# One-shot macOS setup for this dotfiles repo.
#
# Assumes the repo is already cloned to ~/.config, e.g.:
#   git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git ~/.config
#
# Then run:
#   ~/.config/os/macos/install.sh
#
# Idempotent: safe to re-run. It installs Homebrew + packages, zsh plugins,
# tmux tpm, symlinks ~/.zshrc, and sets zsh as the default shell.
#
set -euo pipefail

CONFIG="$HOME/.config"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is macOS-only. For Linux use os/linux/packages.sh." >&2
  exit 1
fi

if [[ ! -d "$CONFIG/.git" ]]; then
  echo "Expected the repo at $CONFIG (clone it there first)." >&2
  exit 1
fi

# 1. Xcode Command Line Tools (provides git, needed for everything else) --------
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools (accept the GUI prompt, then re-run)…"
  xcode-select --install || true
  exit 0
fi
ok "Xcode Command Line Tools present"

# 2. Homebrew ------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into this shell (Apple Silicon vs Intel prefix)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
ok "Homebrew ready ($(brew --version | head -1))"

# Persist brew onto PATH for future login shells (.zshrc does NOT add it).
# This is the "Next steps" line the Homebrew installer prints.
ZPROFILE="$HOME/.zprofile"
if ! grep -qsF "brew shellenv" "$ZPROFILE" 2>/dev/null; then
  info "Adding Homebrew to ~/.zprofile for future shells…"
  printf '\neval "$(%s/bin/brew shellenv)"\n' "$(brew --prefix)" >> "$ZPROFILE"
fi
ok "Homebrew on PATH for future shells"

# 3. Brewfile — all formulae, casks, fonts -------------------------------------
info "Installing Homebrew packages from Brewfile…"
brew bundle --file="$CONFIG/os/macos/Brewfile"
ok "Brew packages installed"

# 4. Zsh plugins ---------------------------------------------------------------
info "Setting up zsh plugins…"
mkdir -p "$CONFIG/zsh/plugins"
clone_if_missing() {
  local url="$1" dst="$2"
  if [[ -d "$dst/.git" ]]; then
    ok "$(basename "$dst") already cloned"
  else
    git clone --depth 1 "$url" "$dst"
  fi
}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions      "$CONFIG/zsh/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting  "$CONFIG/zsh/plugins/zsh-syntax-highlighting"

# 5. Symlink ~/.zshrc ----------------------------------------------------------
info "Linking ~/.zshrc → ~/.config/.zshrc…"
ln -sf "$CONFIG/.zshrc" "$HOME/.zshrc"
ok "~/.zshrc linked"

# 6. tmux — tpm + plugins ------------------------------------------------------
info "Setting up tmux plugin manager…"
clone_if_missing https://github.com/tmux-plugins/tpm "$CONFIG/tmux/plugins/tpm"
# Install the plugins listed in tmux.conf without needing an interactive session
mkdir -p "$HOME/.local/share/tmux/resurrect"
"$CONFIG/tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || \
  warn "tpm plugin install skipped — run 'prefix + I' inside tmux to finish"
ok "tmux plugins ready"

# 7. Default shell -------------------------------------------------------------
BREW_ZSH="$(brew --prefix)/bin/zsh"
if [[ -x "$BREW_ZSH" ]]; then
  if ! grep -qxF "$BREW_ZSH" /etc/shells; then
    info "Adding $BREW_ZSH to /etc/shells (needs sudo)…"
    echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "$BREW_ZSH" ]]; then
    info "Setting default shell to $BREW_ZSH…"
    chsh -s "$BREW_ZSH" || warn "chsh failed — run 'chsh -s $BREW_ZSH' manually"
  fi
fi
ok "Default shell configured"

# 8. tmux session restore hint -------------------------------------------------
echo
if [[ -e "$HOME/.local/share/tmux/resurrect/last" ]]; then
  ok "Found a tmux-resurrect save — sessions will auto-restore when tmux starts"
  echo "     (or restore manually inside tmux with: prefix + Ctrl-r)"
else
  warn "No tmux-resurrect save found."
  echo "     To migrate live sessions from your old Mac, copy its"
  echo "     ~/.local/share/tmux/resurrect/ directory here, then open tmux."
fi

echo
info "Done. Start a new terminal (or run: exec zsh) to load everything."
echo "     First 'nvim' launch installs plugins automatically."
