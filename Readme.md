# Modern Neovim Configuration

[中文文档](https://github.com/jinzhongjia/neovim-config/blob/main/Readme_CN.md) | [Plugin List](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

A comprehensive Neovim configuration featuring built-in LSP, AI assistance, and modern development tools.

> *This configuration is tailored for my personal use. Rather than directly copying it, I encourage you to use it as inspiration to understand plugin ecosystems, dependency management, and configuration organization patterns for your own setup.*

## ✨ Key Features

- 🧠 **AI Integration**: Built-in AI assistance with CodeCompanion and customizable system prompts.
- 🔧 **Built-in LSP**: Native Neovim LSP with comprehensive language support.
- 🎨 **Modern UI**: Beautiful themes (Catppuccin, Kanagawa, Arctic) with enhanced statusline.
- 🔍 **Advanced Search**: Telescope with fuzzy finding, live grep, and frequency-based results.
- 📁 **File Management**: NvimTree with preview and advanced file operations.
- 🐛 **Debugging**: Full DAP integration with virtual text and UI.
- 📊 **Database Tools**: Built-in database client with completion.
- 🎯 **Code Navigation**: Treesitter, outline view, and intelligent code folding.
- 🚀 **Performance**: Optimized startup with lazy loading and early retirement.

## 📸 Screenshots

![overview](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)
![dash](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![definition](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![hover](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![code_action](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)

## 📦 Installation

### Requirements
- Neovim `>= 0.10`
- Git
- A [Nerd Font](https.www.nerdfonts.com/) (recommended: JetBrainsMono Nerd Font)

### Quick Install

```bash
# Unix-like systems (Linux/macOS)
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim

# Windows
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

### First Launch
After installation, run `:checkhealth` to verify everything is working correctly.

## 🛠️ Dependencies

### Core Tools
- **wget** & **curl** - Download utilities
- **fd** - Fast file finder
- **ripgrep** - Fast text search
- **unzip** - Archive extraction
- **cmake** - Build system

### Language Runtimes
- **Go** - Go language support
- **Rust** - Rust language support  
- **Python** - Python language support
- **Node.js** - JavaScript/TypeScript support
- **Zig** - Zig language support
- **GCC/Clang** - C/C++ compilation
- **.NET** - C# language support

### Development Tools
- **Lazygit** - Git TUI client
- **Lazydocker** - Docker TUI client
- **VectorCode** - Vector graphics support
- **Microsoft C++ Build Tools** (Windows only)

### Recommended GUI Clients
- [**Neovide**](https://neovide.dev/) - Modern Neovim GUI with animations
- [**Nvy**](https://github.com/RMichelsen/Nvy) - Cross-platform Neovim GUI

*Both GUI clients are pre-configured in this setup.*

## 🔧 Configuration Management

### Health Check
After installation, run `:checkhealth` to diagnose any issues.

### LSP & Tools Management
All LSP servers and development tools are managed through Mason:
- Use `:Mason` to view and manage installed tools
- Use `:LspInfo` to check active language servers
- Use `:ConformInfo` to verify formatters

### Key Commands
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Browse buffers
- `<leader>fh` - Help tags
- `<leader>e` - File explorer
- `<leader>xx` - Diagnostics
- `<leader>ai` - AI assistant
