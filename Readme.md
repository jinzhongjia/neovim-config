# Modern Neovim Configuration

[中文文档](https://github.com/jinzhongjia/neovim-config/blob/main/Readme_CN.md) | [Plugin List](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

A comprehensive Neovim configuration featuring built-in LSP, AI assistance, and modern development tools.

> *This configuration is tailored for my personal use. Rather than directly copying it, I encourage you to use it as inspiration to understand plugin ecosystems, dependency management, and configuration organization patterns for your own setup.*

## ✨ Key Features

> Fast, batteries‑included, opinionated — but intentionally easy to fork & trim.

- 🧠 **AI Integration**: CodeCompanion, Claude Code, GitHub Copilot (MCP aware), extensible system prompts.
- 🔧 **Fully Managed LSP**: Mason driven install/update, sensible defaults, per‑language overrides.
- ✏️ **Smart Editing**: Blink.cmp, snippets, autopairs, surround, multi‑cursor, structural text objects.
- 🎯 **Navigation & Code Intelligence**: Treesitter, symbols outline, peek & preview, intelligent folding.
- 🐛 **First‑Class Debugging**: nvim-dap + UI, persistent breakpoints, inline virtual text, Go / JS / Python helpers.
- 🔍 **Search & Fuzzy Workflow**: Telescope (files, live grep, frecency, symbols), ripgrep & fd integration.
- 📁 **File & Project Ops**: NvimTree (floating / preview), project root detection, recent & pinned files.
- 📊 **Database Toolkit**: SQL client + completion + UI integration.
- 🎨 **Modern UI**: Catppuccin theme, animated statusline, notifications, command palette, snacks.
- 🌀 **Git & Collaboration**: Gitsigns, Fugitive, Neogit, Lazygit integration, diff & blame helpers.
- 🧩 **Extensible Plugin Layout**: Clear module boundaries, lazy loading patterns, override hooks.
- 🚀 **Performance Focus**: Aggressive lazy spec, startup profiling helpers, cache & GC tuning.
- 🛡️ **Safe Defaults**: Opinionated keymaps, guarded autocmds, defensive plugin loading.

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

## 🎨 Optional Enhancement Tools

### Bat and Delta Setup (Recommended)

Installing `bat` and `delta` significantly enhances file preview and Git diff visualization.

#### Installation

**Windows (using scoop):**
```powershell
scoop install bat delta
```

**macOS:**
```bash
brew install bat git-delta
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install bat
cargo install git-delta

# Arch Linux
sudo pacman -S bat git-delta
```

#### Configuring Delta

After installation, configure Git to use delta:

```bash
# Set delta as git pager
git config --global core.pager "delta"

# Set interactive diff filter
git config --global interactive.diffFilter "delta --color-only"

# Enable navigation
git config --global delta.navigate "true"

# Enable line numbers
git config --global delta.line-numbers "true"

# Use standard diff mode (not side-by-side)
git config --global delta.side-by-side "false"

# Enhance merge conflict display
git config --global merge.conflictstyle "diff3"

# Enable moved code detection
git config --global diff.colorMoved "default"
```

#### Benefits

After configuration:
- File previews in fzf-lua (`<C-p>`) will show syntax highlighting (via bat)
- Git status in fzf-lua (`<leader>tgs`) will display beautiful diffs (via delta)
- Command-line Git operations (`git diff`, `git log -p`, `git show`) will automatically use delta



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
- **bat** - Syntax highlighting for file previews (enhances fzf-lua)
- **delta** - Beautiful Git diff viewer

### Optional System Libraries
- Compilation toolchain (gcc/clang, make, cmake) for building native extensions & Treesitter
- unzip / tar utilities for extracting packages
- SSL development libs (e.g. libssl) if certain tools require HTTPS features

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

## 🧩 Customization

Directory layout (core parts only):
```
lua/
  core/       -> options, autocmds, keymaps
  plugins/    -> lazy.nvim specs (grouped by domain)
  lsp/        -> server setups, capabilities, on_attach
  ui/         -> theme & statusline helpers
``` 

Recommended ways to extend:
1. Create `lua/custom/` and add your own lazy specs (auto‑loaded if you require them in `init.lua`).
2. Override plugin opts using lazy's `opts = function(_, opts) ... end` pattern in a new spec with same `name`.
3. Disable what you do not need:
```lua
return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
```
4. Add per‑language tweaks in `after/ftplugin/<filetype>.lua`.

Minimal bootstrap example (if you want to start trimming):
```lua
-- init.lua
require("core").setup()
require("lazy").setup({
  { import = "plugins.core" },
  { import = "plugins.lsp" },
})
```

## 🐞 Troubleshooting & FAQ

Q: Plugins stuck on first install?  
A: Check network / proxy, then run `:Lazy sync` or delete `lazy-lock.json` and reopen.

Q: LSP server not attaching?  
A: Run `:LspInfo` to see status, ensure tool installed in `:Mason`, check filetype detection via `:set ft?`.

Q: Formatting not working?  
A: Run `:ConformInfo`, confirm formatter installed, ensure no conflicting formatter running (e.g. null-ls remnants).

Q: High CPU / lag?  
A: Use `:Lazy profile` to inspect startup cost; temporarily disable heavy UI plugins to isolate.

Q: AI popup noisy?  
A: Toggle / scope suggestions with provided AI keymaps or disable corresponding spec.

Common commands cheat:
```
:Lazy sync    # install/clean plugins
:Lazy profile # measure startup
:Mason        # manage external tools
:LspInfo      # active servers
:checkhealth  # diagnostics
```

## ⚡ Performance Tips

- Remove languages you do not use from Treesitter & Mason ensure lists.
- Disable large providers: `vim.g.loaded_perl_provider = 0`, etc. (already handled, keep if trimming).
- Use ripgrep + fd (already leveraged) for fastest Telescope experience.
- Run `:Lazy restore` if lockfile drift causes slow cold startups.
- Consider pinning fewer plugins or pruning UI niceties for headless / remote sessions.

## 📄 License / Usage

Personal configuration shared for learning. Feel free to copy excerpts with attribution; avoid filing broad feature requests unless you contribute a PR.
