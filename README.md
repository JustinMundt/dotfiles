# Justin's Dotfiles

A comprehensive development environment configuration featuring Neovim, Tmux, and Zsh. Managed with GNU Stow for clean symlink management.

## Table of Contents

- [Quick Start](#quick-start)
- [What's Included](#whats-included)
- [Neovim](#neovim)
  - [Plugins](#plugins)
  - [Keymaps](#keymaps)
  - [LSP Support](#lsp-support)
  - [Debugging](#debugging)
  - [Formatting & Linting](#formatting--linting)
- [Tmux](#tmux)
- [Zsh](#zsh)
- [Scripts](#scripts)
- [Bootstrap Options](#bootstrap-options)
- [Customization](#customization)

---

## Quick Start

### Full Installation (New Machine)

```bash
# Clone the repository
git clone git@github.com:JustinMundt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the bootstrap script (installs everything)
./bootstrap.sh --yes
```

### Symlinks Only (Dependencies Already Installed)

```bash
cd ~/.dotfiles
./install.sh
```

### Post-Installation

1. Copy and edit your secrets file:
   ```bash
   cp ~/.dotfiles/.secrets.example ~/.secrets
   # Edit ~/.secrets with your API keys
   ```

2. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

3. Open Neovim - plugins will auto-install on first launch:
   ```bash
   nvim
   ```

---

## What's Included

```
~/.dotfiles/
├── bootstrap.sh      # Full environment setup script
├── install.sh        # Symlink-only installation (GNU Stow)
├── .secrets.example  # Template for API keys
│
├── nvim/             # Neovim configuration
│   └── .config/nvim/
│       ├── init.lua
│       ├── lua/config/     # Options and keymaps
│       ├── lua/plugins/    # Plugin configurations
│       └── lsp/            # LSP server configs
│
├── tmux/             # Tmux configuration
│   └── .tmux.conf
│
├── zsh/              # Zsh configuration
│   ├── .zshrc
│   └── .zsh_profile
│
└── scripts/          # Custom scripts
    └── .local/bin/
        └── tmux-sessionizer
```

### Supported Platforms

- Ubuntu / Debian
- Fedora
- Arch Linux
- macOS

---

## Neovim

Modern Neovim 0.11+ configuration with lazy.nvim plugin manager.

### Plugins

| Plugin | Purpose |
|--------|---------|
| **Core** | |
| `folke/lazy.nvim` | Plugin manager |
| `navarasu/onedark.nvim` | Color scheme |
| `nvim-lualine/lualine.nvim` | Status line |
| `folke/which-key.nvim` | Keybinding hints |
| `lukas-reineke/indent-blankline.nvim` | Indentation guides |
| **Navigation** | |
| `nvim-telescope/telescope.nvim` | Fuzzy finder |
| `stevearc/oil.nvim` | File explorer |
| `ThePrimeagen/harpoon` | Quick file navigation |
| **LSP & Completion** | |
| `neovim/nvim-lspconfig` | LSP configurations |
| `williamboman/mason.nvim` | LSP/tool installer |
| `hrsh7th/nvim-cmp` | Completion engine |
| `L3MON4D3/LuaSnip` | Snippet engine |
| `folke/lazydev.nvim` | Lua development |
| `pmizio/typescript-tools.nvim` | Enhanced TypeScript |
| **Treesitter** | |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting |
| `nvim-treesitter/nvim-treesitter-textobjects` | Code text objects |
| **Formatting & Linting** | |
| `stevearc/conform.nvim` | Auto-formatting |
| `mfussenegger/nvim-lint` | Async linting |
| **Git** | |
| `lewis6991/gitsigns.nvim` | Git decorations |
| `tpope/vim-fugitive` | Git commands |
| `tpope/vim-rhubarb` | GitHub integration |
| **Debugging** | |
| `mfussenegger/nvim-dap` | Debug adapter protocol |
| `rcarriga/nvim-dap-ui` | Debugging UI |
| `theHamsta/nvim-dap-virtual-text` | Inline variable values |
| **Editing** | |
| `numToStr/Comment.nvim` | Commenting |
| `kylechui/nvim-surround` | Surround text objects |
| `windwp/nvim-autopairs` | Auto-close brackets |
| `tpope/vim-sleuth` | Auto-detect indentation |
| **Database** | |
| `tpope/vim-dadbod` | Database interface |
| `kristijanhusak/vim-dadbod-ui` | Database UI |

### Keymaps

Leader key: `<Space>`

#### General

| Keymap | Action |
|--------|--------|
| `<leader>e` | Open floating diagnostic |
| `<leader>q` | Open diagnostics list |
| `<leader>o` | Open Oil file explorer |
| `<leader>p` | Paste without yanking (visual mode) |
| `[d` / `]d` | Previous/next diagnostic |
| `j` / `k` | Move by visual line (respects wrap) |

#### Find (Telescope)

| Keymap | Action |
|--------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Find by grep (live) |
| `<leader>fb` | Find buffers |
| `<leader><space>` | Find buffers |
| `<leader>?` | Recent files |
| `<leader>/` | Fuzzy find in current buffer |
| `<leader>b` | Buffer picker (dropdown) |
| `<leader>m` | Marks picker |

#### Search

| Keymap | Action |
|--------|--------|
| `<leader>sh` | Search help tags |
| `<leader>sw` | Search current word |
| `<leader>sg` | Search by grep |
| `<leader>sG` | Search by grep (git root) |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last search |
| `<leader>ss` | Document symbols |
| `<leader>sS` | Workspace symbols |

#### LSP

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>D` | Type definition |

#### Git

| Keymap | Action |
|--------|--------|
| `]c` / `[c` | Next/previous git hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gS` | Stage buffer |
| `<leader>gR` | Reset buffer |
| `<leader>gu` | Undo stage hunk |
| `<leader>gb` | Blame line |
| `<leader>gd` | Diff this |
| `<leader>gD` | Diff this ~ |
| `<leader>gtb` | Toggle line blame |
| `<leader>gtd` | Toggle deleted |
| `<leader>gf` | Git files (Telescope) |

#### Harpoon

| Keymap | Action |
|--------|--------|
| `<leader>ha` | Add file to Harpoon |
| `<leader>hm` | Toggle Harpoon menu |
| `<leader>h1` - `<leader>h4` | Jump to file 1-4 |
| `<leader>hp` | Previous Harpoon file |
| `<leader>hn` | Next Harpoon file |

#### Debug

| Keymap | Action |
|--------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dl` | Log point |
| `<leader>dc` | Start/Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Restart |
| `<leader>dq` | Terminate |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Evaluate expression |
| `<leader>dR` | Toggle REPL |
| `<leader>dL` | Run last |

#### Treesitter Text Objects

| Keymap | Object |
|--------|--------|
| `af` / `if` | Function (outer/inner) |
| `ac` / `ic` | Class (outer/inner) |
| `aa` / `ia` | Parameter (outer/inner) |
| `]m` / `[m` | Next/prev function start |
| `]M` / `[M` | Next/prev function end |
| `]]` / `[[` | Next/prev class start |
| `<leader>a` | Swap parameter next |
| `<leader>A` | Swap parameter prev |

#### Workspace

| Keymap | Action |
|--------|--------|
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |

### LSP Support

Language servers are auto-installed via Mason:

| Language | Server | Features |
|----------|--------|----------|
| Lua | lua_ls | LuaJIT runtime, vim globals |
| Python | pyright | Type checking, diagnostics |
| TypeScript/JavaScript | typescript-tools.nvim | Enhanced TS support, inlay hints |
| Go | gopls | staticcheck, gofumpt (installed via bootstrap, not Mason) |
| Rust | rust_analyzer | clippy on save, cargo features |
| C/C++ | clangd | clang-tidy, background indexing |
| Bash | bashls | Shellcheck integration |
| JSON | jsonls | Schema validation |
| YAML | yamlls | Schema validation |
| HTML | html | Completions, formatting |
| CSS | cssls | Completions, linting |
| Docker | dockerls | Dockerfile support |
| Tailwind | tailwindcss | Class completions |

### Debugging

Debug adapters are auto-installed via Mason:

| Language | Adapter | Notes |
|----------|---------|-------|
| Python | debugpy | Full debugging support |
| Go | delve | Via nvim-dap-go |
| JavaScript/TypeScript | js-debug-adapter | Node.js and Jest |
| Rust | codelldb | Also works for C/C++ |
| C/C++ | codelldb | Shared with Rust |

### Formatting & Linting

**Formatters** (via conform.nvim, format on save):

| Language | Formatter |
|----------|-----------|
| Lua | stylua |
| Python | black |
| JavaScript/TypeScript | prettierd, prettier |
| JSON/YAML/HTML/CSS/Markdown | prettierd, prettier |
| Go | gofumpt, gofmt |
| Rust | rustfmt |
| Shell | shfmt |
| C/C++ | clang-format |

**Linters** (via nvim-lint, lint on save):

| Language | Linter |
|----------|--------|
| JavaScript/TypeScript | eslint_d |
| Python | ruff |
| Lua | luacheck |
| Shell | shellcheck |
| Go | golangci-lint |
| Rust | clippy |
| YAML | yamllint |
| JSON | jsonlint |
| Markdown | markdownlint |
| Dockerfile | hadolint |

---

## Tmux

### Prefix Key

`C-a` (GNU Screen compatible)

### Keymaps

#### Sessions

| Keymap | Action |
|--------|--------|
| `C-a C-c` | Create new session |
| `C-a C-f` | Find session |
| `C-a BTab` | Switch to last session |

#### Windows

| Keymap | Action |
|--------|--------|
| `C-a C-h` | Previous window |
| `C-a C-l` | Next window |
| `C-a Tab` | Last active window |

#### Panes

| Keymap | Action |
|--------|--------|
| `C-a -` | Split horizontal |
| `C-a _` | Split vertical |
| `C-a h/j/k/l` | Navigate panes (vim-style) |
| `C-a H/J/K/L` | Resize panes |
| `C-a >` | Swap pane with next |
| `C-a <` | Swap pane with previous |

#### Copy Mode (vi-style)

| Keymap | Action |
|--------|--------|
| `C-a Enter` | Enter copy mode |
| `v` | Begin selection |
| `C-v` | Rectangle toggle |
| `y` | Copy to clipboard |
| `Escape` | Cancel |

#### Other

| Keymap | Action |
|--------|--------|
| `C-a r` | Reload config |
| `C-a m` | Toggle mouse |
| `C-a b` | List paste buffers |
| `C-a p` | Paste from buffer |
| `C-a P` | Choose buffer to paste |

### Features

- True color support (24-bit)
- Catppuccin-inspired theme
- Cross-platform clipboard integration (WSL, X11, Wayland, macOS)
- Activity monitoring
- Automatic window renaming/renumbering

---

## Zsh

### Framework

Oh-My-Zsh with agnoster theme

### Plugins

| Plugin | Purpose |
|--------|---------|
| git | Git aliases and completions |
| zsh-autosuggestions | Fish-like autosuggestions |
| zsh-syntax-highlighting | Command syntax highlighting |

### Custom Functions

| Function | Usage |
|----------|-------|
| `convert` | Convert m4a to mp3: `convert filename` |
| `music_abc` | Convert ABC notation to MP3: `music_abc file.abc` |
| `take_audio` | Download audio from YouTube: `take_audio "search query" [count] [outdir]` |
| `flask_insights_project_env` | Activate Flask project environment |

### Aliases

| Alias | Action |
|-------|--------|
| `flaskinsights` | Activate Flask insights project |
| `windoc` | CD to Windows Documents (WSL) |
| `insightsproduction` | CD to insights production project |

### Environment

- **Editor:** Neovim (`$EDITOR`, `$VISUAL`)
- **Node:** Managed via NVM
- **Rust:** Cargo in PATH
- **Go:** `/usr/local/go/bin` and `~/go/bin` in PATH
- **Local scripts:** `~/.local/bin` in PATH

---

## Scripts

### tmux-sessionizer

Quick project session creation using fzf.

```bash
# Usage
tmux-sessionizer           # Interactive: select from project directories
tmux-sessionizer /path     # Direct: create/attach to session for path
```

Searches these directories for projects:
- `~/work/builds`
- `~/projects`
- `~/`
- `~/work`
- `~/personal`
- `~/personal/yt`

---

## Bootstrap Options

```bash
./bootstrap.sh [OPTIONS]

Options:
  -y, --yes           Non-interactive mode (auto-confirm all)
  -h, --help          Show help
  --skip-langs        Skip Go, Rust, Node.js installation
  --skip-tools        Skip lazygit, GitHub CLI installation
  --skip-docker       Skip Docker installation
  --skip-shell        Skip zsh, oh-my-zsh setup
  --skip-fonts        Skip Nerd Font installation
  --skip-keyd         Skip keyd (Caps Lock to Ctrl remap)
  --dotfiles-repo URL Custom dotfiles repository URL
```

### What Bootstrap Installs

| Category | Components |
|----------|------------|
| System | git, stow, ripgrep, fzf, tmux, zsh, cmake |
| Languages | Go, Rust (rustup), Node.js (nvm) |
| Tools | lazygit, GitHub CLI, Docker |
| Neovim | Latest stable from GitHub releases |
| Fonts | JetBrainsMono Nerd Font |
| Shell | oh-my-zsh, zsh-autosuggestions, zsh-syntax-highlighting |
| Keyboard | keyd (Caps Lock → Ctrl remap, Linux only) |
| Formatters | stylua, black, prettierd, shfmt, gofumpt, clang-format |
| Linters | eslint_d, ruff, luacheck, shellcheck, golangci-lint, yamllint, jsonlint, markdownlint, hadolint |

---

## Customization

### Adding a New Neovim Plugin

1. Create a new file in `nvim/.config/nvim/lua/plugins/`:
   ```lua
   -- nvim/.config/nvim/lua/plugins/my-plugin.lua
   return {
     'author/plugin-name',
     opts = {
       -- configuration
     },
   }
   ```

2. Restart Neovim - lazy.nvim auto-loads all files in `lua/plugins/`

### Adding a New LSP Server

1. Add to the servers list in `lua/plugins/lsp.lua`:
   ```lua
   local servers = {
     -- ... existing servers
     'new_server',
   }
   ```

2. Create config file in `nvim/.config/nvim/lsp/new_server.lua`:
   ```lua
   return {
     -- server-specific settings
   }
   ```

### Modifying Keymaps

- Global keymaps: `nvim/.config/nvim/lua/config/keymaps.lua`
- Plugin keymaps: In the respective plugin file in `lua/plugins/`
- LSP keymaps: `lua/plugins/lsp.lua` in the `LspAttach` autocmd

### Secrets File

Create `~/.secrets` for API keys:

```bash
# ~/.secrets
export OPENAI_API_KEY="your-key-here"
export ANTHROPIC_API_KEY="your-key-here"
```

This file is sourced by `.zshrc` if it exists.

---

## Uninstalling

```bash
cd ~/.dotfiles

# Remove symlinks
stow -D nvim tmux zsh scripts

# Or remove specific package
stow -D nvim
```

---

## License

MIT
