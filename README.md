# Neovim 0.12 Minimal Performance Config

这是一套基于 Neovim 0.12 的极简高性能配置，追求**极致的启动速度和运行性能**。配置原则是：**能用内置功能解决的绝不引入插件**。

## ✨ 核心特性

- **极致性能**：启动时间极快（<50ms），仅保留必要的极少数插件。
- **Neovim 0.12 原生能力**：
  - 使用内置 `vim.pack` 替代 lazy.nvim/packer。
  - 使用内置 `'autocomplete'` 替代 nvim-cmp。
  - 使用内置 `vim.lsp.config` + `vim.lsp.enable`；`nvim-lspconfig` 只作为
    `cmd`/`filetypes`/`root_markers` 的基础配置来源，`after/lsp/*.lua` 覆盖 settings。
  - 使用内置实验性 `ui2` 替代 noice.nvim。
  - 使用内置状态栏和诊断 API（`vim.diagnostic.status`）。
- **完整语言支持**：Lua、TypeScript/JavaScript、Go、Rust、Zig、Python、C/C++、
  CSS、HTML、YAML、Protobuf 的 LSP，以及 Go/Rust/C/Python/TS 的 DAP。
- **最少插件依赖**：
  - `fzf-lua`：提供最快、最轻量的搜索体验（依赖系统 `fzf` 和 `rg`）。
  - `nvim-tree`：侧边栏文件树（+ `nvim-web-devicons` 图标），替代 netrw。
  - `flash.nvim`：标签式跳转（含 f/F/t/T 标签与 treesitter 选择）。
  - `copilot.lua`：Copilot 行内补全（ghost text，需要 Node.js）。
  - `bufferline.nvim`：Buffer 标签栏（带诊断计数、NvimTree offset）。
  - `nvim-lspconfig`：只当 server base 配置来源（`cmd`/`filetypes`/`root_markers`），
    不调 `setup()`；`eslint` 的 `workspace/configuration` handler、`clangd` 的
    utf-8 offsetEncoding、`rust_analyzer`/`gopls` 的多层根探测都靠它。
  - `lazydev.nvim`：按需给 `lua_ls` 喂 Neovim/插件的 Lua 类型。
  - `nvim-treesitter`：管理语法高亮。
  - `nvim-dap` / `nvim-dap-ui`：处理调试功能。
  - `vscode.nvim`：VS Code Dark+ 风格配色方案。

## 📦 安装指南

### 1. 环境依赖

确保系统中已安装以下工具：
- **Neovim >= 0.12**
- `git`
- `fzf` 和 `ripgrep` (用于 fzf-lua 搜索)
- `fd` (可选，用于更快的寻找文件)
- 各语言对应的 LSP 和 DAP（见下文）

### 2. 获取配置

```bash
# 备份原有配置
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# 将本配置复制到 Neovim 目录
cp -r ./nvim-config ~/.config/nvim
```

### 3. 安装 LSP Server

用 Mason 一把装齐（列表见 `lua/plugins/mason.lua`）：

```vim
:MasonInstallAll
```

启用的 server 见 `lua/core/lsp.lua` 的 `vim.lsp.enable`，逐个的 settings 覆盖放在
`after/lsp/<name>.lua`：lua_ls、vtsls、eslint、gopls、rust_analyzer、zls、
basedpyright、ruff、clangd、cssls、html、yamlls、buf_ls、protols、typos_lsp。

### 4. 安装 DAP Debugger

- **Go**: `go install github.com/go-delve/delve/cmd/dlv@latest`
- **Python**: `pip install debugpy`
- **Rust/C**: 安装 `codelldb` 或 `lldb-dap`
- **TypeScript**: `npm install -g @anthropic-ai/js-debug-adapter`

## ⌨️ 核心快捷键

### 基础与窗口
- `<leader>w`：保存
- `<leader>q`：退出
- `<C-h/j/k/l>`：窗口切换
- `<leader>wh/wj/wk/wl`：窗口切换（leader 版）
- `<leader>sv` / `<leader>sh` / `<leader>sc`：竖分屏 / 横分屏 / 关闭窗口
- `<C-Up/Down/Left/Right>`：窗口调整大小
- `<S-h/l>`：Buffer 切换
- `<Esc>` 或 `<leader>l`：清除搜索高亮
- localleader 为 `,`

### 文件与搜索 (fzf-lua & nvim-tree)
- `<leader>ff`：查找文件
- `<leader>sg`：全局搜索文本 (Live Grep)
- `<leader>sw`：搜索光标下的词
- `<leader>e`：开关文件树 (nvim-tree)
- `<leader>fe`：聚焦文件树
- 树内 `g?` 查看全部按键

### Copilot (copilot.lua)
首次使用先 `:Copilot auth` 登录。仅在白名单文件类型启用（见 `lua/plugins/copilot.lua`）。
- `<M-l>`：接受建议
- `<M-]>` / `<M-[>`：下一条 / 上一条
- `<C-]>`：丢弃当前建议

### Buffer 标签栏 (bufferline.nvim)
- `<leader>1`…`<leader>9`：跳到第 N 个 buffer
- `<leader>bp` / `<leader>bn`：上一个 / 下一个（`<S-h>` / `<S-l>` 同效）
- `<leader>bb`：picker 选 buffer
- `<leader>bc` / `<leader>bo`：关闭当前 / 关闭其他
- `<leader>bd` / `<leader>bf`：关闭左侧 / 右侧
- `<leader>bm` / `<leader>bi`：左移 / 右移当前 buffer
- `<leader>bs` / `<leader>be` / `<leader>bt`：按目录 / 扩展名 / 相对目录排序

### 跳转 (flash.nvim)
- `s`：Flash 跳转（n/x/o）
- `S`：Treesitter 节点跳转（n/x/o）
- `r`：Remote Flash（operator-pending）
- `R`：Treesitter Search（o/x）
- `<C-s>`：搜索命令行内开关 Flash

### LSP

配置见 `lua/core/lsp.lua`（`vim.lsp.enable` + LspAttach）、`lua/core/keymaps.lua`、
`lua/plugins/fzf.lua`。

**Neovim 0.12 内置默认键位**（无需配置，开箱即有）：

| 键位 | 作用 |
|---|---|
| `grn` | 重命名 |
| `gra` | Code Action |
| `grr` | 查找引用 |
| `gri` | 跳转实现 |
| `grt` | 跳转类型定义 |
| `gO` | 文档符号大纲 |
| `<C-x><C-o>` | 手动触发补全（本配置另绑了 `<C-n>` / `<C-p>`） |

**本配置补充的跳转与操作**：

| 键位 | 作用 |
|---|---|
| `gd` | 跳转定义 |
| `gD` | 跳转声明 |
| `K` | 悬停文档 |
| `<C-s>`（插入模式） | 签名帮助 |
| `<leader>cs` | 签名帮助（普通模式） |
| `<leader>ca` | Code Action |
| `<leader>cr` | 重命名 |
| `<leader>cf` | 格式化（异步） |
| `<leader>ci` / `<leader>co` | 调用层级：调入 / 调出 |
| `<leader>ih` | 开关 inlay hints（buffer 局部，attach 后才有） |

**fzf-lua 列表式入口**（`<leader>l*`，适合结果多的场景）：

| 键位 | 作用 |
|---|---|
| `<leader>ls` / `<leader>lS` | 文档符号 / 工作区符号 |
| `<leader>ld` | 定义列表 |
| `<leader>lr` | 引用列表 |
| `<leader>li` | 实现列表 |
| `<leader>la` | Code Action 列表 |

**诊断**：

| 键位 | 作用 |
|---|---|
| `[d` / `]d` | 上 / 下一个诊断 |
| `<leader>cd` | 诊断浮窗（`<leader>e` 已归文件树，`<leader>d*` 已归 DAP） |
| `<leader>cD` | 诊断写入 loclist |
| `<leader>dd` / `<leader>dw` | fzf 列出文档 / 工作区诊断 |

> Inlay hints 在 attach 时自动打开，code lens 刻意不开（太吵），需要时用
> `vim.lsp.codelens.run()`。LSP 加载进度由 ui2 的 msg 浮窗渲染，见
> `lua/plugins/ui2.lua`。

### 调试 (DAP)
- `<F5>`：启动/继续调试
- `<F10>`：单步跳过 (Step Over)
- `<F11>`：单步进入 (Step Into)
- `<F12>`：单步跳出 (Step Out)
- `<leader>db`：切换断点
- `<leader>du`：切换调试 UI
- `<leader>de`：评估表达式 (Eval)

## 📁 目录结构

```text
~/.config/nvim/
├── init.lua                # 入口文件
├── lua/
│   ├── core/               # 核心配置（无插件依赖）
│   │   ├── options.lua     # 选项与性能设置
│   │   ├── keymaps.lua     # 快捷键
│   │   ├── autocmds.lua    # 自动命令
│   │   ├── diagnostics.lua # 诊断样式
│   │   ├── lsp.lua         # 内置 LSP 加载器
│   │   └── completion.lua  # 内置自动补全配置
│   └── plugins/            # 插件配置
│       ├── init.lua        # vim.pack 插件管理器入口
│       ├── treesitter.lua  # 语法高亮
│       ├── fzf.lua         # 搜索
│       ├── files.lua       # 文件树
│       ├── dap.lua         # 调试
│       ├── colorscheme.lua # 配色
│       ├── statusline.lua  # 原生状态栏
│       └── ui2.lua         # 原生 UI2
├── lsp/                    # 各语言 LSP 配置
│   ├── ts_ls.lua
│   ├── gopls.lua
│   ├── rust_analyzer.lua
│   ├── pyright.lua
│   ├── clangd.lua
│   ├── cssls.lua
│   └── html.lua
└── dap/                    # DAP 说明文档
    └── README.md
```
