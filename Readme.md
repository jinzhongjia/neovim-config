# Modern Neovim Configuration

[中文文档](https://github.com/jinzhongjia/neovim-config/blob/main/Readme_CN.md) | [Plugin List](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

A comprehensive Neovim configuration featuring built-in LSP, AI assistance, and modern development tools.

> *This configuration is tailored for my personal use. Rather than directly copying it, I encourage you to use it as inspiration to understand plugin ecosystems, dependency management, and configuration organization patterns for your own setup.*

## 📸 Screenshots

![overview](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)
![dash](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![definition](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![hover](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![code_action](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)

## 📦 Installation

### Requirements
- **Neovim** `>= 0.10.0` (required for all features)
- **Git** `>= 2.19.0` (for plugin management and version control)
- A [Nerd Font](https://www.nerdfonts.com/) (recommended: JetBrainsMono Nerd Font for icons and symbols)

### Quick Install

```bash
# Unix-like systems (Linux/macOS)
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim

# Windows
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

### TL;DR Quick Start
```bash
# clone
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
cd ~/.config/nvim

# first open (downloads plugins)
nvim

# inside Neovim (after install finishes)
:Mason         # install language servers / linters / formatters
:checkhealth   # verify environment

# optional helpers
:Lazy update   # keep plugins fresh
```

### First Launch
1. Open Neovim and wait for Lazy.nvim to install all plugins automatically
2. Run `:checkhealth` to verify your environment
3. Run `:Mason` to install LSP servers, formatters, and linters
4. Restart Neovim to ensure all configurations are loaded

## 🛠️ Dependencies

### Essential Tools (Required)
- **git** `>= 2.19.0` - Version control and plugin management
- **curl** or **wget** - HTTP client for downloading tools

### Build Tools (Recommended)
- **cmake** `>= 3.10` - Build system for native extensions
- **make** - Build automation
- **gcc** or **clang** - C compiler for Treesitter parsers
- **unzip** - Archive extraction for Mason packages

### Language Support (Optional - Install based on your needs)

#### Primary Languages
- **Node.js** `>= 18.0.0` & **npm** - JavaScript/TypeScript development
  - Required for many LSP servers and tools
- **Python** `>= 3.8` & **pip** - Python development
  - Required for some formatters and linters
- **Go** `>= 1.20` - Go development
  - Required for Go LSP and tools
- **Rust** & **cargo** - Rust development
  - Required for Rust analyzer and some tools

#### Additional Languages
- **Zig** `>= 0.11.0` - Zig language support
- **.NET SDK** `>= 6.0` - C# development
- **Lua** `>= 5.1` - Lua development

### Development Tools (Optional)
- **Lazygit** - Terminal UI for Git (integrated with Neovim)
- **Lazydocker** - Terminal UI for Docker
- **MCP Hub** - Model Context Protocol server support
- **GitHub CLI** (`gh`) - GitHub integration
- **jq** - JSON processor (for some plugins)
- **ripgrep** (`rg`) - Fast text search (used by Snacks.nvim)

### Optional System Libraries
- Compilation toolchain (gcc/clang, make, cmake) for building native extensions & Treesitter
- unzip / tar utilities for extracting packages
- SSL development libs (e.g. libssl) if certain tools require HTTPS features

### GUI Clients (Optional)
- [**Neovide**](https://neovide.dev/) - GPU-accelerated Neovim GUI with smooth animations
- [**Nvy**](https://github.com/RMichelsen/Nvy) - Fast, native Windows Neovim GUI

*Note: The configuration auto-detects and configures settings for these GUI clients.*

### Command

```sh
# for utf-8 file names in Git
git config --global core.quotepath false
```
