# dotfiles

```bash
git clone --recurse-submodules https://github.com/nashyvan/dotfiles.git
ln -s "$HOME/.config/.zshrc" "$HOME/.zshrc"
```

## Fonts

[JetBrains Mono](https://jetbrains.com/lp/mono/)  
[Nerd Font](https://www.nerdfonts.com/)

## Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
> [!TIP]
> ```bash
> brew bundle dump --file=~/.config/Brewfile --force
> ```

## WezTerm

```bash
brew install --cask wezterm
```

## Pure

[sindresorhus/pure](https://github.com/sindresorhus/pure)

```bash
brew install pure
```

## Zsh

```bash
brew install zsh
```

## eza

```bash
brew install eza
```

## Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Zsh Plugins:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Open the "~/.zshrc" file and add plugins:

```
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)
```

`source ~/.zshrc` to reload zsh config

## Neovim

- [Neovim](https://neovim.io/) (Version 0.8 or Later)
- [Ripgrep](https://github.com/BurntSushi/ripgrep) - For Telescope Fuzzy Finder

```bash
brew install neovim
```

```bash
brew install node
```

```bash
brew install ripgrep
```

## kickstart.nvim

[nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Official Repository  
[nashyvan/kickstart.nvim](https://github.com/nashyvan/kickstart.nvim) - My Fork

### Plugins
```vim
  require 'custom.plugins.ui.devicons', -- Icons for nvim-tree and bufferline
  require 'custom.plugins.ui.nvim-tree', -- A file explorer tree
  require 'custom.plugins.ui.bufferline', -- Buffer line with tabpage integration
  require 'custom.plugins.ui.lualine', -- Statusline
  require 'custom.plugins.ui.barbecue', -- Winbar
  require 'custom.plugins.ui.alpha', -- Start page
  require 'custom.plugins.ui.colorizer', -- Highlight colors
  require 'custom.plugins.ui.dressing', -- Plugin improves the default vim.ui interfaces
  require 'custom.plugins.ui.fidget', -- Extensible UI for Neovim notifications and LSP progress messages
  require 'custom.plugins.ui.illuminate', -- For automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching
  require 'custom.plugins.ui.indent-blankline', -- This plugin adds indentation guides to Neovim
  require 'custom.plugins.ui.nvim-bqf', -- Better quickfix window
  require 'custom.plugins.ui.sunglasses', -- enhances Neovim's interface and color schemes for a better coding experience (Dims unactive window)
  require 'custom.plugins.ui.transparent', -- Remove all background colors to make nvim transparent
  require 'custom.plugins.ui.twilight', -- Dims inactive portions of the code you're editing using TreeSitter
  require 'custom.plugins.ui.virt-column', -- Display a character as the colorcolumn
  require 'custom.plugins.colorscheme.vscode',
```

> [!NOTE]
> These commands reset Neovim by deleting its data, cache, and config.
> ```bash
> rm -rf ~/.local/share/nvim
> rm -rf ~/.cache/nvim
> rm -rf ~/.config/nvim
> ```

## tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

`^a+I` to install packages  
`^a+r` to reload tmux config

## Borgmatic

```bash
brew install borgmatic
cp ~/.config/borgmatic/.env.example ~/.config/borgmatic/.env && vim ~/.config/borgmatic/.env
```
