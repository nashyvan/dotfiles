#!/usr/bin/env bash
# Debian/Ubuntu package setup — equivalent of os/macos/Brewfile
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  zsh \
  git \
  tmux \
  neovim \
  ripgrep \
  fd-find \
  ffmpeg \
  pandoc \
  php \
  php-cli \
  pkg-config \
  libpq-dev \
  python3 \
  python3-pip \
  wakeonlan \
  wimtools \
  curl \
  unzip

# fd is installed as fdfind on Debian; add a symlink
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# eza (modern ls) — not in older apt repos, install from GitHub
if ! command -v eza &>/dev/null; then
  EZA_VER=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d'"' -f4)
  curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VER}/eza_x86_64-unknown-linux-gnu.tar.gz"
  tar -xzf /tmp/eza.tar.gz -C /tmp
  sudo mv /tmp/eza /usr/local/bin/eza
fi

# GitHub CLI
if ! command -v gh &>/dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt-get update && sudo apt-get install -y gh
fi

# Node.js via NVM (matches the macOS NVM setup in .zshrc)
if ! command -v node &>/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
fi

# npm globals
npm install -g pnpm pure-prompt tree-sitter-cli

# PHP Composer
if ! command -v composer &>/dev/null; then
  php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
  php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
fi

# borgmatic (backup tool)
pip3 install --user borgmatic

# Git Credential Manager
if ! command -v git-credential-manager &>/dev/null; then
  GCM_VER=$(curl -s https://api.github.com/repos/git-ecosystem/git-credential-manager/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/v//')
  curl -Lo /tmp/gcm.deb "https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GCM_VER}/gcm-linux_amd64.${GCM_VER}.deb"
  sudo dpkg -i /tmp/gcm.deb
fi

echo "Done. Restart your shell or run: source ~/.zshrc"
