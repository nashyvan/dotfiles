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

## Neovim — what to edit and what not to touch

The `nvim/` directory is a separate git repo (submodule). It has two layers:

| Path | Owner | Rule |
|------|-------|------|
| `nvim/lua/custom/` | **you** | edit freely — upstream never touches this directory |
| `nvim/lua/custom/plugins/` | **you** | add/remove your own plugins here |
| `nvim/init.lua` | upstream + you | upstream owns this file; your only addition is `require 'custom'` at the very bottom |
| `nvim/lua/lazy-plugins.lua` | upstream + you | upstream owns this file; your only change is `{ import = 'custom.plugins' }` being uncommented |
| `nvim/lua/kickstart/` | **upstream** | never edit — always accept upstream changes as-is |
| `nvim/lua/options.lua` | **upstream** | never edit — put your overrides in `nvim/lua/custom/options.lua` |
| `nvim/lua/keymaps.lua` | **upstream** | never edit — put your keymaps in `nvim/lua/custom/keymaps.lua` |

### Your customization entry points

- **Options** → `nvim/lua/custom/options.lua`
- **Keymaps** → `nvim/lua/custom/keymaps.lua`
- **Commands** → `nvim/lua/custom/commands.lua`
- **Highlights** → `nvim/lua/custom/highlights.lua`
- **Plugins** → add a new file under `nvim/lua/custom/plugins/` and require it in `nvim/lua/custom/plugins/init.lua`

---

## Updating nvim (kickstart-modular upstream)

### First time — add the upstream remote

```bash
git -C ~/.config/nvim remote add upstream https://github.com/dam9000/kickstart-modular.nvim.git
```

Only needed once per machine. Skip if already done (`git -C ~/.config/nvim remote -v` to check).

### Regular update flow

```bash
git -C ~/.config/nvim fetch upstream
git -C ~/.config/nvim log --oneline HEAD..upstream/master   # preview what's incoming
git -C ~/.config/nvim merge upstream/master
```

The merge will be conflict-free: git knows you *added* the two custom lines (they were never in upstream), so it keeps them automatically. No manual conflict resolution needed.

After merging, sync plugins:

```bash
nvim --headless '+Lazy! sync' '+qa'
nvim                   # open and run :checkhealth
```

### After the merge — push correctly

The dotfiles repo stores a commit hash pointer to `nvim/`. **Push nvim first**, otherwise the pointer in dotfiles will reference a commit that doesn't exist on GitHub yet.

```bash
# 1. Push nvim submodule
git -C ~/.config/nvim push origin master

# 2. Then push dotfiles
git -C ~/.config push origin main
```

If you accidentally push dotfiles first, GitHub shows a broken submodule link. Fix it by pushing nvim right after — the link resolves automatically once the commit exists.

---

## Maintenance

### Update Homebrew packages (macOS)

```bash
brew update && brew upgrade
brew bundle dump --force --file=~/.config/os/macos/Brewfile
```

### Update tmux plugins

Inside tmux: `prefix + U`

### Update nvim plugins

Inside Neovim: `:Lazy update`
