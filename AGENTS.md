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

## Claude Code 集成 (claudecode.nvim)

### 概述
claudecode.nvim 提供 Claude Code CLI 的原生 Neovim 集成，通过 WebSocket 协议实现与官方 VS Code 扩展相同的功能。

### 核心特性
- **实时上下文追踪**: Claude 能看到你当前编辑的文件和选中的代码
- **原生 Diff 支持**: 直接在 Neovim 中查看和应用 Claude 提议的修改
- **Git 仓库感知**: 自动识别项目根目录，提供完整项目上下文
- **文件树集成**: 从 NvimTree 直接添加文件到 Claude 上下文

### 快捷键

| 快捷键 | 模式 | 功能 | 说明 |
|--------|------|------|------|
| `<leader>ac` | Normal | 切换窗口 | 打开/关闭 Claude Code（主要入口） |
| `<leader>af` | Normal | 聚焦窗口 | 智能聚焦/隐藏 |
| `<leader>ab` | Normal | 添加当前文件 | 将正在编辑的文件加入上下文 |
| `<leader>as` | Visual | 发送选中 | 发送代码片段给 Claude |
| `<leader>as` | NvimTree | 添加文件 | 从文件树添加文件到上下文 |
| `<leader>aa` | Normal | 接受修改 | 应用 Claude 提议的修改 |
| `<leader>ad` | Normal | 拒绝修改 | 丢弃 Claude 提议的修改 |
| `<leader>ar` | Normal | 恢复会话 | 继续上次的对话 |
| `<leader>aC` | Normal | 继续对话 | 在当前会话继续 |
| `<leader>am` | Normal | 选择模型 | 切换不同的 Claude 模型 |
| `<C-,>` | Terminal | 快速隐藏 | 在终端模式下快速隐藏窗口 |

### 典型工作流

1. **启动 Claude**: 按 `<leader>ac` 打开浮动终端
2. **添加上下文**:
   - 方式一: 选中代码按 `<leader>as` 发送选中内容
   - 方式二: 按 `<leader>ab` 添加当前文件
   - 方式三: 在 NvimTree 中按 `<leader>as` 添加文件
3. **与 Claude 对话**: 在终端中描述你的需求
4. **查看修改**: Claude 提议修改时自动打开 diff 窗口
5. **应用修改**:
   - 按 `<leader>aa` 接受修改
   - 按 `<leader>ad` 拒绝修改
   - 或直接编辑 diff 再保存
6. **关闭窗口**: 在终端模式按 `<C-,>` 隐藏

### 配置说明

配置文件: `lua/plugins/claudecode.lua`

关键配置项:
- `terminal_cmd = nil`: 使用系统 PATH 中的 `claude` 命令
- `git_repo_cwd = true`: 在 git 仓库根目录运行，提供完整项目视图
- `focus_after_send = true`: 发送代码后自动聚焦终端，方便继续对话
- `keep_terminal_focus = true`: 打开 diff 后保持焦点在终端

### 故障排查

- **Claude 无法连接?** 检查 `:ClaudeCodeStatus` 并验证 lock 文件存在于 `~/.claude/ide/`
- **需要调试日志?** 在 opts 中设置 `log_level = "debug"`
- **终端问题?** snacks.nvim 已启用 terminal 支持，无需额外配置

### 与其他 AI 工具的关系

| 工具 | 用途 | 适用场景 |
|------|------|----------|
| **CodeCompanion** | 聊天式 AI 助手 | 问答、代码解释、小范围修改 |
| **Copilot** | 代码补全 | 实时行内补全 |
| **claudecode.nvim** | IDE 集成 | 项目级重构、多文件修改、完整上下文感知 |

它们互补而不重叠，可以同时使用。

## For LLM

LLM can modify this file if necessary to keep it up to date with changes in the configuration structure or best practices.

