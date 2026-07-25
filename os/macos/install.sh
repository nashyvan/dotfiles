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
# Homebrew 6+ refuses formulae from untrusted third-party taps, so trust any
# tap the Brewfile declares before bundling.
if brew trust --help >/dev/null 2>&1; then
  while IFS= read -r tap_name; do
    [[ -z "$tap_name" ]] && continue
    info "Trusting third-party tap ${tap_name}…"
    brew tap "$tap_name" >/dev/null 2>&1 || true
    brew trust "$tap_name" >/dev/null 2>&1 || true
  done < <(grep -E '^[[:space:]]*tap[[:space:]]' "$CONFIG/os/macos/Brewfile" \
             | sed -E 's/^[[:space:]]*tap[[:space:]]+"([^"]+)".*/\1/')
fi

info "Installing Homebrew packages from Brewfile…"
# Don't let one flaky formula/cask abort the whole setup.
if brew bundle --file="$CONFIG/os/macos/Brewfile"; then
  ok "Brew packages installed"
else
  warn "Some brew packages failed to install (see above) — continuing setup"
fi

# 3a. Claude Code CLI — installed via its own installer, not brew ---------------
# It lands in ~/.local/bin; put that on PATH for the rest of this script so the
# installer doesn't warn about it. ~/.config/.zshrc adds it for future shells.
export PATH="$HOME/.local/bin:$PATH"
if ! command -v claude >/dev/null 2>&1; then
  info "Installing Claude Code CLI…"
  curl -fsSL https://claude.ai/install.sh | bash
else
  ok "Claude Code CLI present"
fi

# 3b. GitHub auth — SSH key first, gh CLI as fallback --------------------------
# GitHub dropped username/password auth over HTTPS. Primary: load the personal
# SSH key into the agent, backed by the macOS Keychain so it survives reboots
# (the key itself comes from ~/.ssh via sync-to-new-mac.sh, not this repo).
# gh is set up regardless — it's also how `gh pr create` / `gh issue` etc. auth.
SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$SSH_KEY" ]] && ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null; then
  ok "SSH key loaded into agent (Keychain-backed)"
elif [[ -f "$SSH_KEY" ]]; then
  warn "SSH key found but couldn't be loaded — run manually: ssh-add --apple-use-keychain $SSH_KEY"
else
  warn "No SSH key at $SSH_KEY — copy it from your old Mac, or generate one, then re-run"
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    ok "gh already authenticated"
  else
    info "Logging into GitHub via gh (opens a browser)…"
    gh auth login -h github.com -w || warn "gh auth login failed — run it manually: gh auth login"
  fi
  gh auth setup-git || warn "gh auth setup-git failed — run it manually later"
fi

# 3c. WezTerm — the wezterm@nightly cask is not in the Brewfile because its
# install step breaks upstream; fetch the current nightly straight from GitHub.
if [[ ! -d /Applications/WezTerm.app ]]; then
  info "Fetching the WezTerm nightly build…"
  WT_TMP="$(mktemp -d)"
  WT_URL="https://github.com/wezterm/wezterm/releases/download/nightly/WezTerm-macos-nightly.zip"
  if curl -fL -o "$WT_TMP/wezterm.zip" "$WT_URL" && unzip -oq "$WT_TMP/wezterm.zip" -d "$WT_TMP"; then
    WT_APP="$(find "$WT_TMP" -maxdepth 2 -name WezTerm.app -type d | head -1)"
    if [[ -n "$WT_APP" ]]; then
      rm -rf /Applications/WezTerm.app
      mv "$WT_APP" /Applications/
      xattr -dr com.apple.quarantine /Applications/WezTerm.app 2>/dev/null || true
      ok "WezTerm installed to /Applications (direct nightly download)"
    else
      warn "Could not find WezTerm.app in the download — install WezTerm manually"
    fi
  else
    warn "WezTerm nightly download failed — install WezTerm manually"
  fi
  rm -rf "$WT_TMP"
else
  ok "WezTerm present"
fi

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
    info "Setting default shell to ${BREW_ZSH}…"
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
