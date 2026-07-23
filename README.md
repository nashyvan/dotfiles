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

## Migrate to a new Mac

Moves configs, all Homebrew packages, WezTerm, and **live tmux sessions** to a fresh machine.
tmux sessions persist via [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) +
[tmux-continuum](https://github.com/tmux-plugins/tmux-continuum), which save to
`~/.local/share/tmux/resurrect/`. Copy that directory over and sessions (windows, panes,
working dirs, and captured pane contents) restore on the new Mac.

> tmux-resurrect stores each pane's **working directory and command**, not the live process
> state. Restored panes reopen in the right folder; long-running programs (nvim, ssh, etc.)
> relaunch, but unsaved in-memory state does not survive.

### On the OLD Mac — export

```bash
# 1. Commit and push all config changes (nvim submodule first — see push order below)
cd ~/.config/nvim && git push origin master
cd ~/.config && git add -A && git commit -m "sync before migration" && git push origin main

# 2. Refresh the Brewfile so it captures everything currently installed
brew bundle dump --force --file=~/.config/os/macos/Brewfile
cd ~/.config && git commit -am "chore: refresh Brewfile" && git push origin main

# 3. Snapshot current tmux sessions right now (or press: prefix + Ctrl-s inside tmux)
tmux run-shell ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh

# 4. Copy the resurrect saves to the new Mac (adjust host/user), or AirDrop the folder
rsync -av ~/.local/share/tmux/resurrect/ newmac.local:~/.local/share/tmux/resurrect/
```

### On the NEW Mac — import

```bash
# 1. Get git (triggers the Command Line Tools installer if missing)
xcode-select --install

# 2. Clone the repo (with the nvim submodule)
git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git ~/.config

# 3. Run the one-shot installer: Homebrew, Brewfile, zsh plugins, tmux tpm, shell, fonts
~/.config/os/macos/install.sh

# 4. Make sure the tmux resurrect folder from the old Mac is in place
#    (skip if you already rsync'd/AirDropped it above)
ls ~/.local/share/tmux/resurrect/last   # should exist

# 5. Open WezTerm and start tmux — continuum auto-restores the last session.
#    If it doesn't restore automatically, press: prefix + Ctrl-r
tmux
```

The [`os/macos/install.sh`](os/macos/install.sh) script is idempotent — safe to re-run if a
step fails. The step-by-step manual equivalent is documented below.

---

## macOS setup

> For a new machine, prefer the scripted flow in [Migrate to a new Mac](#migrate-to-a-new-mac).
> The steps below are the manual equivalent.

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
| `nvim/init.lua` | upstream + you | upstream owns this file; your only addition is `require 'custom'` before `require 'pack'` |
| `nvim/lua/plugins.lua` | upstream + you | upstream owns this file; your only change is `require 'custom.plugins'` being uncommented |
| `nvim/lua/custom/plugins/init.lua` | **you** | explicit ordered require list — upstream's auto-loader doesn't recurse into subdirs |
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

Usually conflict-free for `lua/kickstart/` files. The three diverging files (`init.lua`, `plugins.lua`, `custom/plugins/init.lua`) may need manual fixups — see [`nvim/UPSTREAM.md`](nvim/UPSTREAM.md).

After merging, update plugins and check health:

```bash
nvim --headless -c 'lua vim.pack.update()' -c 'qa'
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

Inside Neovim: `:lua vim.pack.update()`

Check pending updates without downloading: `:lua vim.pack.update(nil, { offline = true })`
