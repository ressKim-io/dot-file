# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Korean-language personal dotfiles repository for automated Cloud Native DevOps environment setup. It targets Mac, Linux (Ubuntu/Debian), and WSL environments with a focus on Kubernetes, Terraform, and AWS tooling.

## Module Architecture

The repository is organized into independent modules, each with its own `install.sh` and `README.md`:

| Module | Purpose |
|--------|---------|
| `prerequisites/` | Foundational runtimes (Go, Node.js, Python) and DevOps tools (kubectl, helm, terraform, jq, yq) |
| `zsh/` | Oh-My-Zsh with platform-aware configuration (Mac/WSL/Linux detection) |
| `nvim/` | Neovim IDE with modular config (`lua/config/` + `lua/plugins/`), Mason-managed LSP/DAP, blink.cmp, debugger, test runner, conform/lint, 50+ plugins |
| `kubectl/` | kubectl aliases and shell completion |
| `kubectx/` | Context/namespace switching with safety prompts for production |
| `aws/` | AWS CLI shortcuts and EC2/cost management functions |
| `vim/` | Legacy Vim configuration for remote servers |

## Installation Order (Mandatory)

Prerequisites must be installed first, then zsh, then other modules:
```bash
cd prerequisites && ./install.sh && cd ..
cd zsh && ./install.sh && cd ..
cd kubectl && ./install.sh && cd ..
cd kubectx && ./install.sh && cd ..
cd nvim && ./install.sh && cd ..
# Optional
cd aws && ./install.sh && cd ..
cd vim && ./install.sh && cd ..
```

## Script Conventions

All installation scripts follow this pattern:
1. OS detection via `uname -s` (Darwin for Mac, Linux with WSL check)
2. Tool existence check before installation
3. Platform-appropriate package manager (brew, apt-get, yum)
4. Backup existing config to `.backup.TIMESTAMP`
5. Append to shell RC files (`~/.zshrc` or `~/.bashrc`)
6. Version verification at script completion

## Key Configuration Files

- **`zsh/.zshrc`** (508 lines): Platform detection functions (`is_mac()`, `is_wsl()`, `is_linux()`), 2-line prompt with git branch, kubernetes integration
- **`nvim/init.lua`** (~150 lines): Entry point - lazy.nvim bootstrap, config/plugin module loading, theme auto-switching logic
- **`nvim/lua/config/`**: Core settings split into `options.lua`, `keymaps.lua`, `autocmds.lua`, `devops.lua`
- **`nvim/lua/plugins/`**: 12 plugin modules - `lsp.lua` (Mason + 9 LSP servers), `completion.lua` (blink.cmp), `dap.lua` (Go/Python/JS debugger), `testing.lua` (neotest), `formatting.lua` (conform + nvim-lint), `telescope.lua`, `treesitter.lua`, `git.lua`, `editor.lua`, `ui.lua`, `navigation.lua`, `devops.lua`
- **`aws/aws-aliases.sh`** (110 lines): EC2 management functions, cost optimization helpers

## Production Safety Features

- Neovim auto-switches to Gruvbox theme in `/production`, `/prod` directories or on `main`/`master` branches
- `prod()` shell function requires confirmation before switching context
- `ec2rm` shows instance details and requires confirmation before deletion
- All installation scripts create backups before overwriting config files

## Platform Detection

The codebase uses these detection patterns:
```bash
is_mac()   # uname -s == "Darwin"
is_wsl()   # uname -r contains "microsoft" or "WSL"
is_linux() # uname -s == "Linux" and not WSL
```

## Version Management

- `nvim/lazy-lock.json` pins Neovim plugin versions for reproducibility
- Prerequisites scripts auto-detect latest stable versions from:
  - Go: `https://go.dev/VERSION?m=text`
  - kubectl: `https://dl.k8s.io/release/stable.txt`
  - yq/hadolint: GitHub Releases API

## No Build/Test Process

This is a configuration distribution system without compilation or automated tests. Verification is manual: each install script outputs version checks at completion.
