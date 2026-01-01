# AGENTS.md - Neovim Configuration

## Commands
- **Format**: `stylua lua/` (format Lua files)
- **Validate**: Open Neovim and run `:checkhealth`
- **Plugins**: `:Lazy sync` (install/update), `:Lazy profile` (performance)
- **LSP**: `:Mason` (manage LSP servers), `:LspInfo` (view attached LSP)

## Code Style (enforced by .stylua.toml)
- **Indent**: 4 spaces, 120 char line width, Unix line endings
- **Quotes**: Double quotes preferred
- **Naming**: `snake_case` for functions/variables
- **Comments**: Use Chinese for inline comments when explaining complex logic

## Project Structure
```
nvim-config/
├── init.lua                 # Entry point, loads core and plugins
├── lua/
│   ├── core/                # Core settings
│   │   ├── init.lua         # Loads all core modules
│   │   ├── basic.lua        # Basic vim options
│   │   └── util.lua         # Utility functions
│   ├── plugin.lua           # lazy.nvim bootstrap
│   └── plugins/             # Plugin configurations (one file per plugin/group)
├── after/
│   └── lsp/                 # Language-specific LSP configs (Neovim 0.11+)
└── plugin/                  # Auto-loaded Lua files for custom commands
```

## Plugin Configuration Pattern

### Basic Structure
All plugin configs in `lua/plugins/` must follow this pattern:

```lua
return
--- @type LazySpec
{
    {
        "author/plugin-name",
        event = "VeryLazy",           -- or: ft, cmd, keys for lazy loading
        dependencies = { "dep/name" }, -- optional
        opts = {},                     -- plugin options (calls setup automatically)
    },
}
```

### Loading Strategies
| Strategy | Usage | Example |
|----------|-------|---------|
| `event = "VeryLazy"` | General plugins | Most UI plugins |
| `ft = { "lua", "go" }` | Filetype-specific | Language tools |
| `cmd = { "Command" }` | Command-triggered | Utility plugins |
| `keys = { ... }` | Keymap-triggered | Toggle plugins |

### Configuration Approaches
1. **Simple plugins**: Use `opts = {}` (uses defaults)
2. **Custom options**: Use `opts = { key = value }`
3. **Complex setup**: Use `config = function() ... end`

### Examples

**Simple plugin (defaults):**
```lua
{
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
}
```

**Plugin with options:**
```lua
{
    "stevearc/conform.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = false, lsp_fallback = true })
            end,
            mode = { "n", "v" },
            desc = "Format file or range",
        },
    },
}
```

**Plugin with config function:**
```lua
{
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    config = function()
        require("hlslens").setup()
        -- Custom keymaps here
        vim.keymap.set("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
    end,
}
```

## LSP Configuration (Neovim 0.11+)

### Architecture
This config uses Neovim 0.11's native LSP API:
- **mason.nvim**: Manages LSP server binaries
- **mason-lspconfig.nvim**: Bridges Mason and LSP, auto-enables servers
- **nvim-lspconfig**: Provides default LSP configurations
- **blink.cmp**: Handles LSP capabilities automatically

### Adding a New LSP Server

1. **Add to ensure_installed** in `lua/plugins/lsp.lua`:
```lua
ensure_installed = { "gopls", "basedpyright", "ts_ls", "lua_ls", "NEW_SERVER" },
```

2. **Create language-specific config** in `after/lsp/<server_name>.lua`:
```lua
-- after/lsp/NEW_SERVER.lua
return {
    settings = {
        -- Server-specific settings
    },
}
```

### LSP Config File Structure
Files in `after/lsp/` are automatically loaded by Neovim 0.11 and merged with defaults.

```lua
-- after/lsp/<server_name>.lua
return {
    settings = {
        server_name = {
            -- Enable features
            feature = true,
            -- Configure analyses
            analyses = {
                unusedparams = true,
            },
            -- Configure hints
            hints = {
                parameterNames = true,
            },
        },
    },
}
```

### Current LSP Servers
| Server | Language | Config File |
|--------|----------|-------------|
| `gopls` | Go | `after/lsp/gopls.lua` |
| `basedpyright` | Python | `after/lsp/basedpyright.lua` |
| `ts_ls` | TypeScript/JavaScript | `after/lsp/ts_ls.lua` |
| `lua_ls` | Lua | `after/lsp/lua_ls.lua` |

## Keybinding Guidelines
- **Before adding keybindings**: Search the codebase for existing uses to avoid conflicts
- **Check for conflicts**: Use `grep` to search `lua/plugins/` for the key pattern
- **All keybindings need descriptions**: Use `desc = "Description"` for better discoverability
- **Prefer `<leader>` prefix**: Use `<leader>` for custom keybindings

## Important Notes
- **VimL plugins**: Do NOT use `opts = {}` for VimL plugins (they don't have Lua `setup()`)
- **Lazy loading**: Prefer lazy loading to improve startup time
- **Dependencies**: Declare dependencies explicitly in `dependencies` field
- **Type annotations**: Use `--- @type LazySpec` for better LSP support in plugin files

## For LLM

LLM can modify this file if necessary to keep it up to date with changes in the configuration structure or best practices.

