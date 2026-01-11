# Neovim Configuration

[中文文档](./Readme_CN.md)

A modern Neovim configuration with LSP, code completion, AI assistance, and development tools.

## Requirements

- Neovim >= 0.10.0
- Git >= 2.19.0
- A Nerd Font (recommended: JetBrainsMono Nerd Font)

## Installation

### Linux/macOS
```bash
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
```

### Windows
```bash
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

## Quick Start

1. Clone the repository
2. Launch Neovim - plugins will be installed automatically by lazy.nvim
3. Run `:Mason` to install language servers and tools
4. Run `:checkhealth` to verify the configuration
5. Restart Neovim

## Core Features

### Language Support
- LSP integration via nvim-lspconfig
- Language server management with Mason
- Code completion with blink.cmp
- Syntax highlighting via Treesitter
- Code formatting with conform.nvim

### Development Tools
- Git integration (gitsigns, neogit, diffview)
- Fuzzy finding with snacks.nvim
- Debugging support via nvim-dap
- Terminal integration with floaterm

### AI Assistance
- GitHub Copilot integration
- Claude Code support

### UI Enhancements
- Status line with lualine
- Buffer line with bufferline
- Code outline with outline.nvim
- Enhanced search with hlslens
- Code folding with nvim-ufo

## Dependencies

### Required
- git >= 2.19.0
- curl or wget

### Recommended
- unzip
- ripgrep

### Optional Language Runtimes
Install based on your development needs:
- Node.js >= 18.0.0 (for TypeScript/JavaScript LSP)
- Python >= 3.8 (for Python LSP)
- Go >= 1.20 (for Go LSP)
- Rust toolchain (for Rust LSP)

## Configuration Structure

```
nvim-config/
├── init.lua              # Entry point
├── lua/
│   ├── core/            # Core configurations
│   │   ├── basic.lua    # Basic settings
│   │   ├── util.lua     # Utility functions
│   │   └── init.lua     # Core initialization
│   ├── plugins/         # Plugin configurations
│   └── plugin.lua       # Plugin manager setup
├── after/               # Runtime files
└── plugin/              # Plugin override files
```

## Plugin Management

This configuration uses lazy.nvim for plugin management.

### Common Commands
- `:Lazy` - Open plugin manager UI
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Install missing plugins and update
- `:Lazy clean` - Remove unused plugins

## Additional Configuration

### Git UTF-8 Support
```bash
git config --global core.quotepath false
```

## Notes

This configuration is tailored for personal use. Use it as reference to understand plugin ecosystems and configuration patterns rather than copying directly.
