# dotfiles

Personal `~/.config` setup for shell, editor, terminal, and tmux.

## Quick setup

```bash
git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git ~/.config
cd ~/.config
git submodule update --init --recursive
ln -sf "$HOME/.config/.zshrc" "$HOME/.zshrc"
```

## Repository layout

- `.zshrc` - main Zsh config
- `nvim/` - Neovim config (git submodule: [`nashyvan/kickstart.nvim`](https://github.com/nashyvan/kickstart.nvim))
- `tmux/` - tmux config and themes
- `wezterm/` - WezTerm config and colorscheme
- `borgmatic/` - Borgmatic backup config (`.env.example` template included)
- `Brewfile` - Homebrew packages and apps

> [!NOTE]
> This repo tracks the main config files above. Other folders under `~/.config` may exist locally and are machine-specific.

## Fonts

[JetBrains Mono](https://jetbrains.com/lp/mono/)  
[Nerd Fonts](https://www.nerdfonts.com/)

## Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file="$HOME/.config/Brewfile"
```

## WezTerm

```bash
brew install --cask wezterm
```

## Zsh

```bash
brew install zsh pure eza
mkdir -p ~/.config/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/plugins/zsh-syntax-highlighting
source ~/.zshrc
```

## Neovim

- Config lives in the `nvim` submodule
- Read `nvim/README.md` for the full Kickstart docs
- Main dependencies used here: `neovim`, `node`, `ripgrep`, `tree-sitter` (CLI)
- Local customizations live in `nvim/lua/custom/*`

```bash
brew install neovim node ripgrep tree-sitter
```

Check CLI availability:

```bash
tree-sitter --version
```

### Check upstream kickstart.nvim updates

```bash
cd ~/.config/nvim
git fetch upstream && git log --oneline HEAD..upstream/master
```

### Update kickstart.nvim (future)

```bash
git -C ~/.config/nvim remote add upstream https://github.com/nvim-lua/kickstart.nvim.git 2>/dev/null || true
git -C ~/.config/nvim config core.hooksPath .githooks
git -C ~/.config/nvim fetch upstream
git -C ~/.config/nvim merge --no-ff upstream/master
rm -f ~/.config/nvim/lazy-lock.json
NVIM_APPNAME=nvim nvim --headless '+Lazy! sync' '+qa'
NVIM_APPNAME=nvim nvim --headless '+checkhealth' '+qa'
git -C ~/.config/nvim status --short
```

### Automatic `custom.plugins` import fix

- `nvim/scripts/ensure-custom-import.sh` keeps `{ import = 'custom.plugins' }` in `nvim/init.lua`
- `.githooks/post-merge` and `.githooks/post-checkout` run the script automatically
- The script is idempotent (safe to run multiple times):

```bash
~/.config/nvim/scripts/ensure-custom-import.sh
```

- What is automatic: restoring/keeping the `custom.plugins` import line
- What to check manually after update: merge conflicts (if any), then open Neovim and run `:Lazy sync` and `:checkhealth`

## tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

- `prefix + I` to install tmux plugins (default prefix is `Ctrl-b`)
- `prefix + r` to reload tmux config

## Borgmatic

```bash
brew install borgmatic
cp ~/.config/borgmatic/.env.example ~/.config/borgmatic/.env
$EDITOR ~/.config/borgmatic/.env
```
