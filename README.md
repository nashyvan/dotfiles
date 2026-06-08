# dotfiles

Personal `~/.config` setup for shell, editor, terminal, and tmux.
Supports **macOS** and **Debian/Ubuntu**.

## Repository layout

```
.config/
├── .zshrc                  # Zsh config (cross-platform, OS-aware)
├── git/config              # Git identity and credential helper
├── nvim/                   # Neovim — git submodule (nashyvan/kickstart-modular.nvim)
├── tmux/                   # tmux config + themes
├── wezterm/                # WezTerm terminal config (macOS + Linux)
├── borgmatic/              # Borgmatic backup config (.env.example included)
└── os/
    ├── macos/Brewfile       # macOS — Homebrew packages and casks
    └── linux/packages.sh   # Debian/Ubuntu — apt + manual installs
```

> Other folders under `~/.config` (gcloud, filezilla, gh, etc.) exist locally and are gitignored.

---

## macOS setup

### 1. Clone

```bash
git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git ~/.config
```

### 2. Homebrew + packages

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file="$HOME/.config/os/macos/Brewfile"
```

### 3. Zsh plugins

```bash
mkdir -p ~/.config/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.config/zsh/plugins/zsh-syntax-highlighting
```

### 4. Shell

```bash
ln -sf ~/.config/.zshrc ~/.zshrc
chsh -s $(which zsh)
source ~/.zshrc
```

### 5. tmux plugins

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux source ~/.config/tmux/tmux.conf
# then inside tmux: prefix + I  (Ctrl-b + I) to install plugins
```

### 6. Neovim

First launch installs all plugins automatically via lazy.nvim:

```bash
nvim
```

Run `:checkhealth` inside Neovim to verify everything is healthy.

### 7. Fonts

Install a [Nerd Font](https://www.nerdfonts.com/) — the config uses **JetBrains Mono Nerd Font**.
WezTerm also falls back to Iosevka and FantasqueSansM Nerd Font.

### 8. Borgmatic (optional — backups)

```bash
cp ~/.config/borgmatic/.env.example ~/.config/borgmatic/.env
$EDITOR ~/.config/borgmatic/.env   # fill in BORG_REPO and BORG_PASSPHRASE
```

---

## Debian/Ubuntu setup

### 1. Clone

```bash
sudo apt-get install -y git
git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git ~/.config
```

### 2. Packages

```bash
chmod +x ~/.config/os/linux/packages.sh
~/.config/os/linux/packages.sh
```

This installs: zsh, git, tmux, neovim, ripgrep, fd, eza, ffmpeg, pandoc, gh, node (via nvm), pnpm, pure-prompt, python3, borgmatic, Git Credential Manager, and more.

### 3. Zsh plugins

```bash
mkdir -p ~/.config/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.config/zsh/plugins/zsh-syntax-highlighting
```

### 4. Shell

```bash
ln -sf ~/.config/.zshrc ~/.zshrc
chsh -s $(which zsh)   # log out and back in for chsh to take effect
source ~/.zshrc
```

### 5. tmux plugins

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux source ~/.config/tmux/tmux.conf
# then inside tmux: prefix + I  (Ctrl-b + I) to install plugins
```

### 6. Neovim

First launch installs all plugins automatically:

```bash
nvim
```

Run `:checkhealth` inside Neovim to verify everything is healthy.

### 7. Fonts

Download and install a [Nerd Font](https://www.nerdfonts.com/) manually:

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -Lo JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
unzip JetBrainsMono.zip -d JetBrainsMono
fc-cache -fv
```

### 8. WezTerm (optional — GUI terminal)

```bash
curl -fsSL https://apt.fury.io/wezfurlong/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wezfurlong/ * *" \
  | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt-get update && sudo apt-get install -y wezterm
```

### 9. Borgmatic (optional — backups)

```bash
cp ~/.config/borgmatic/.env.example ~/.config/borgmatic/.env
$EDITOR ~/.config/borgmatic/.env   # fill in BORG_REPO and BORG_PASSPHRASE
```

---

## What lives where

| Config | macOS | Linux | Notes |
|--------|-------|-------|-------|
| `nvim/` | ✓ | ✓ | git submodule |
| `tmux/` | ✓ | ✓ | tpm plugins cloned manually |
| `wezterm/` | ✓ | ✓ | GUI terminal |
| `.zshrc` | ✓ | ✓ | OS-aware (uname detection) |
| `git/config` | ✓ | ✓ | |
| `borgmatic/` | ✓ | ✓ | needs `.env` filled in |
| `os/macos/Brewfile` | ✓ | — | Homebrew only |
| `os/linux/packages.sh` | — | ✓ | Debian/Ubuntu |

---

## Maintenance

### Update Homebrew packages (macOS)

```bash
brew update && brew upgrade
brew bundle dump --force --file=~/.config/os/macos/Brewfile
```

### Update upstream nvim (kickstart-modular)

```bash
cd ~/.config/nvim
git fetch upstream
git log --oneline HEAD..upstream/master   # preview changes
git merge upstream/master
```

Keep these two lines when merging — see [`nvim/UPSTREAM.md`](nvim/UPSTREAM.md) for details.

### Update tmux plugins

Inside tmux: `prefix + U`

### Update nvim plugins

Inside Neovim: `:Lazy update`
