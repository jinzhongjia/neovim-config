# AGENTS.md - Neovim Configuration

## Commands
- **Format**: `stylua lua/` (format Lua files)
- **Validate**: Open Neovim and run `:checkhealth`
- **Plugins**: `:Lazy sync` (install/update), `:Lazy profile` (performance)

## Code Style (enforced by .stylua.toml)
- **Indent**: 4 spaces, 120 char line width, Unix line endings
- **Quotes**: Double quotes preferred
- **Naming**: `snake_case` for functions/variables, global utils prefixed `__` (e.g., `__check_exec`)

## Structure
- `lua/core/` - Options, keymaps, utilities
- `lua/plugins/` - lazy.nvim plugin specs (grouped by domain)
- `lua/langs/` - Per-language LSP/tool configs using `LangSpec` type
- `lua/_meta.lua` - Type definitions

## Patterns
- Use LuaCATS annotations: `--- @type`, `--- @param`, `--- @return`
- Plugin specs: `return { { "plugin/name", event = "VeryLazy", opts = {} } }`
- Lang specs: `return --- @type LangSpec { lsp = "server", others = { "tool" } }`
- Prefer `event = "VeryLazy"` or `ft = "filetype"` for lazy loading

## Keybinding Guidelines
- **Before adding/modifying keybindings**: Search the codebase for existing uses of the key sequence to avoid conflicts
- **Check for conflicts**: Use `grep` to search `lua/plugins/` and `lua/core/keybind.lua` for the key pattern
- **Avoid overwriting**: Plugin keybindings in `on_attach` or `keys` tables may override each other based on load order
