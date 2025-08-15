# Modern Neovim Configuration

[中文文档](https://github.com/jinzhongjia/neovim-config/blob/main/Readme_CN.md) | [Plugin List](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

A comprehensive Neovim configuration featuring built-in LSP, AI assistance, and modern development tools.

> *This configuration is tailored for my personal use. Rather than directly copying it, I encourage you to use it as inspiration to understand plugin ecosystems, dependency management, and configuration organization patterns for your own setup.*

## ✨ Key Features

- 🧠 **AI Integration**: Multiple AI assistants including CodeCompanion, Claude Code, and GitHub Copilot with MCP support.
- 🔧 **Built-in LSP**: Native Neovim LSP with comprehensive language support via Mason.
- 🎨 **Modern UI**: Beautiful themes (Catppuccin) with enhanced statusline and UI components.
- 🔍 **Advanced Search**: Telescope with fuzzy finding, live grep, ripgrep integration, and frequency-based results.
- 📁 **File Management**: NvimTree with preview, advanced operations, and floating windows.
- 🐛 **Debugging**: Full DAP integration with UI, persistent breakpoints, and Go support.
- 📊 **Database Tools**: Built-in database client with SQL completion and UI.
- 🎯 **Code Navigation**: Treesitter-based highlighting, outline view, and intelligent code folding.
- ✏️ **Smart Editing**: Blink.cmp completion, auto-pairs, surround, and multi-cursor support.
- 🚀 **Performance**: Optimized startup with lazy loading, early retirement, and efficient plugin management.

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

### First Launch
1. Open Neovim and wait for Lazy.nvim to install all plugins automatically
2. Run `:checkhealth` to verify your environment
3. Run `:Mason` to install LSP servers, formatters, and linters
4. Restart Neovim to ensure all configurations are loaded

### Installing Dependencies

#### Quick Install Commands

**Windows (with Scoop)**:
```powershell
scoop install git ripgrep fd neovim
scoop install nodejs python go rust zig
scoop install lazygit cmake make
```

**macOS (with Homebrew)**:
```bash
brew install neovim git ripgrep fd
brew install node python go rust zig
brew install lazygit cmake
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install neovim git ripgrep fd-find
sudo apt install nodejs npm python3 python3-pip
sudo apt install golang rustc cargo
sudo apt install cmake build-essential
```

**Arch Linux**:
```bash
sudo pacman -S neovim git ripgrep fd
sudo pacman -S nodejs npm python python-pip
sudo pacman -S go rust zig
sudo pacman -S cmake base-devel
```

## 🛠️ Dependencies

### Essential Tools (Required)
- **git** `>= 2.19.0` - Version control and plugin management
- **ripgrep** `>= 13.0.0` - Fast text search (required for Telescope and search features)
- **fd** `>= 8.0.0` - Fast file finder (improves Telescope performance)
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
- **Java** `>= 11` - Java development (for Java LSP)
- **Lua** `>= 5.1` - Lua development

### Development Tools (Optional)
- **Lazygit** - Terminal UI for Git (integrated with Neovim)
- **Lazydocker** - Terminal UI for Docker
- **MCP Hub** - Model Context Protocol server support
- **GitHub CLI** (`gh`) - GitHub integration
- **jq** - JSON processor (for some plugins)

### Platform-Specific

#### Windows
- **PowerShell** `>= 7.0` - Modern shell (recommended)
- **Microsoft C++ Build Tools** - Required for native modules
- **Windows Terminal** - Better terminal experience

#### macOS
- **Homebrew** - Package manager (simplifies dependency installation)
- **Xcode Command Line Tools** - Development tools

#### Linux
- **build-essential** (Debian/Ubuntu) or **base-devel** (Arch) - Compilation tools
- **libssl-dev** - SSL development libraries

### GUI Clients (Optional)
- [**Neovide**](https://neovide.dev/) - GPU-accelerated Neovim GUI with smooth animations
- [**Nvy**](https://github.com/RMichelsen/Nvy) - Fast, native Windows Neovim GUI

*Note: The configuration auto-detects and configures settings for these GUI clients.*

## 📦 Plugin Overview

This configuration includes 100+ carefully selected plugins. Key highlights:

- **Plugin Manager**: Lazy.nvim for fast, lazy-loaded plugin management
- **Completion**: Blink.cmp with AI-powered suggestions
- **LSP**: Native LSP with Mason for automatic server installation
- **AI Integration**: CodeCompanion, Claude Code, and GitHub Copilot
- **File Navigation**: Telescope, NvimTree, and enhanced search tools
- **Git Integration**: Fugitive, Gitsigns, Neogit, and Lazygit
- **UI Enhancements**: Catppuccin theme, Lualine statusline, and Snacks.nvim
- **Debugging**: nvim-dap with UI and language-specific adapters

For a complete list, see [plugin_list.md](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md).

## 🔧 Configuration Management

### Health Check
After installation, run `:checkhealth` to diagnose any issues with:
- Neovim version and features
- Required dependencies
- Plugin installations
- LSP server status

### LSP & Tools Management
All LSP servers and development tools are managed through Mason:
- `:Mason` - Open Mason UI to install/update tools
- `:LspInfo` - Check active language servers for current buffer
- `:ConformInfo` - Verify formatter configuration
- `:LinterInfo` - Check linter status

### Key Mappings

#### General
- `<leader>` - Space key (leader key)
- `<leader>e` - Toggle file explorer (NvimTree)
- `<leader>w` - Save file
- `<leader>q` - Quit

#### Search & Navigation
- `<leader>ff` - Find files (Telescope)
- `<leader>fg` - Live grep in files
- `<leader>fb` - Browse open buffers
- `<leader>fh` - Search help tags
- `<leader>fr` - Recent files (frecency)
- `<leader>fs` - Search symbols

#### AI Assistance
- `<leader>cc` - Toggle CodeCompanion chat
- `<leader>ac` - Toggle Claude Code
- `<leader>af` - Focus Claude Code window
- `<leader>ar` - Resume Claude Code session

#### Code Actions
- `<leader>ca` - Code actions
- `<leader>cf` - Format code
- `<leader>cr` - Rename symbol
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation

#### Diagnostics
- `<leader>xx` - Trouble diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic

#### Git
- `<leader>gg` - Lazygit
- `<leader>gd` - Git diff view
- `<leader>gb` - Git blame
