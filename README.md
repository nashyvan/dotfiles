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

Two scripts do the work:

| Script | Runs on | Does |
|--------|---------|------|
| [`os/macos/sync-to-new-mac.sh`](os/macos/sync-to-new-mac.sh) | **OLD** Mac | rsyncs live state (below) to the new Mac |
| [`os/macos/install.sh`](os/macos/install.sh) | **NEW** Mac | Homebrew + Brewfile, zsh plugins, tmux tpm, shell, WezTerm |

Configs themselves (shell, nvim, tmux, wezterm) travel via **git** — the sync script only moves
the live state git doesn't track:

| Data | Path (same on both Macs) | Notes |
|------|--------------------------|-------|
| tmux sessions | `~/.local/share/tmux/resurrect/` | [resurrect](https://github.com/tmux-plugins/tmux-resurrect) + [continuum](https://github.com/tmux-plugins/tmux-continuum); auto-restores on new Mac |
| WezTerm layout | `~/Library/Application Support/wezterm/` | [resurrect.wezterm](https://github.com/MLFlexer/resurrect.wezterm) saves in the plugin's own `…/plugins/*resurrect*/state/` |
| Claude Code history | `~/.claude/` + `~/.claude.json` | transcripts in `projects/`; **auth is in the Keychain → re-login** |
| Codex history | `~/.codex/` | `sessions/` + config; caches/logs/plugins are excluded; `auth.json` is copied |
| SSH keys | `~/.ssh/` | keys, `config`, `known_hosts`; live `agent/` sockets skipped |
| Shell history | `~/.zsh_history` | |
| CLI credentials | `~/.config/{gh,gcloud,filezilla,borgmatic/.env,stripe,sanity}`, `~/.docker/` | gcloud `virtenv/` + docker `bin/` skipped (regenerable) |
| Dev projects | `~/Developer/` | `.git` + `.env` kept; `node_modules`, `.next`, `dist`, `build`, caches, venvs skipped — reinstall deps after |

> tmux/WezTerm restore each pane's **working directory and command**, not live process state —
> panes reopen in the right folder and relaunch programs, but unsaved in-memory state is lost.
>
> Keys and credentials travel **encrypted over SSH** and land with their original permissions.
> Not covered (use Migration Assistant or re-auth): macOS Keychain, app preferences, browser data.

### Steps — in this order

**1. OLD Mac — push configs to GitHub:**

```bash
cd ~/.config/nvim && git push origin master                 # push nvim submodule first
brew bundle dump --force --file=~/.config/os/macos/Brewfile  # capture all installed packages
cd ~/.config && git commit -am "sync before migration" && git push origin main
```

**2. NEW Mac — enable SSH, then clone and install:**

```bash
sudo systemsetup -setremotelogin on   # or System Settings → General → Sharing → Remote Login
xcode-select --install                # git
git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git ~/.config
~/.config/os/macos/install.sh
```

**3. OLD Mac — sync live state across** (run *after* step 2 — the credential stores land inside
`~/.config`, which must exist first; you can't clone into a non-empty dir):

```bash
./os/macos/sync-to-new-mac.sh nashyvan@macbook-pro.local     # prompts for host if omitted
```

The script snapshots tmux, reuses one SSH connection for every transfer, and reminds you to quit
Claude Code / the Codex app (live SQLite DBs) and press **⌘S** in WezTerm first. Use the target's
real name (`scutil --get LocalHostName`) or IP (`ipconfig getifaddr en0`) — both Macs are often
named `MacBook-Pro`, which collides.

**4. NEW Mac — finish up:** **WezTerm** auto-restores its layout on open (or ⌘R to pick one);
**`tmux`** auto-restores the last session (or `prefix + Ctrl-r`); **`claude`** → `/login`
(Keychain auth); first **`nvim`** installs plugins.

> **No SSH / prefer AirDrop?** Skip the sync script and AirDrop the paths in the table above
> (`open <path>` in Finder → Share → AirDrop); on the new Mac move each into the same location.

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
