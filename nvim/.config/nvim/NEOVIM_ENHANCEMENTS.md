# Neovim Enhancements

## Recently added
- [x] Format on save via conform.nvim
- [x] Lint on save via nvim-lint
- [x] Auto-pairs (nvim-autopairs)
- [x] Harpoon setup + keymaps
- [x] Debugging (nvim-dap + nvim-dap-ui)
  - Python (debugpy)
  - Go (delve)
  - JavaScript/TypeScript (js-debug-adapter)
  - Rust/C/C++ (codelldb)

## Suggested next additions
- [ ] Diagnostics list UI (trouble.nvim)
- [ ] Session/project management (auto-session or persisted)
- [ ] Git diff view (diffview.nvim)
- [ ] Vim-tmux seamless navigation (vim-tmux-navigator)
- [ ] Todo comments highlighting (todo-comments.nvim)

## Debug Keymaps (<leader>d)
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
| `<leader>du` | Toggle UI |
| `<leader>de` | Evaluate expression |
| `<leader>dR` | Toggle REPL |
| `<leader>dL` | Run last |

## Tooling installed via bootstrap.sh
- Formatters: stylua, black, prettierd/prettier, shfmt, gofumpt/gofmt, rustfmt, clang-format
- Linters: eslint_d, ruff, luacheck, shellcheck, golangci-lint, clippy, yamllint, markdownlint, jsonlint, hadolint
