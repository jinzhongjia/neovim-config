# Neovim 0.12 Minimal Performance Config

基于 Neovim 0.12 的极简高性能配置。原则：**能用内置功能解决的绝不引入插件；
必须引入的插件，低频场景一律懒加载**。

## ✨ 核心特性

- **启动 ~200ms**（warm，全功能加载；重型低频插件已移出启动路径：
  blink.pairs → InsertEnter，copilot → InsertEnter，DAP → 首次按键，
  nvim-tree → 首次打开，render-markdown → 首个 markdown 文件）。
- **Neovim 0.12 原生能力**：
  - 内置 `vim.pack` 管理插件（版本锁定见 `nvim-pack-lock.json`）。
  - 内置 `vim.lsp.config` + `vim.lsp.enable`；`nvim-lspconfig` 只作为
    `cmd`/`filetypes`/`root_markers` 基础配置来源，`after/lsp/*.lua` 覆盖 settings。
  - 内置实验性 `ui2`（消除 Press-ENTER、cmdline 高亮）。
  - 内置 difftool（`:DiffTool`）、undotree（`<leader>u`）、注释（`gc`）、
    增量选区（`v_an`/`v_in`）、`[d`/`]d` 诊断跳转、`exrc` 项目本地配置。
  - 自绘彩色状态栏（模式色块 / fugitive 分支 / mini.diff hunk 计数 /
    诊断 / LSP 进度事件缓存 / 宏录制提示），无 lualine。
- **完整语言支持**：Lua、TS/JS、Go、Rust、Zig、Python、C/C++、CSS、HTML、
  JSON、YAML、Protobuf、Bash、Dockerfile（LSP + treesitter + 格式化 + DAP）。

## 📦 插件清单（按职责）

| 职责 | 插件 | 加载时机 |
|---|---|---|
| 补全 | blink.cmp（+ lazydev） | 启动 |
| 括号配对 | blink.pairs（+ blink.lib） | InsertEnter |
| 语法 | nvim-treesitter + textobjects（均 main 分支） | 启动 |
| LSP 基础数据 | nvim-lspconfig（不调 setup） | 启动 |
| 包管理 | mason.nvim（`:MasonInstallAll`） | 启动 |
| 搜索 | fzf-lua（max-perf profile，接管 `vim.ui.select`） | 启动 |
| 文件树 | nvim-tree + nvim-web-devicons | 首次 `<leader>e` |
| Buffer 栏 | bufferline.nvim | 启动 |
| Git | vim-fugitive + mini.diff | 启动 |
| 格式化 | conform.nvim | 启动（按键才干活） |
| 调试 | nvim-dap + nvim-dap-ui + nvim-nio | 首次 DAP 按键 |
| 跳转 | flash.nvim（`s`/`S`） | 启动 |
| 包围 | mini.surround（`gs` 前缀） | 启动 |
| TODO | todo-comments.nvim（+ plenary） | 启动 |
| Markdown | render-markdown.nvim | 首个 markdown |
| 键位速查 | which-key.nvim | 启动 |
| AI | claudecode.nvim / opencode.nvim / copilot.lua | 启动 / 启动 / InsertEnter |
| 配色 | vscode.nvim | 启动 |

## 📦 安装指南

### 1. 环境依赖

- **Neovim >= 0.12**、`git`
- `fzf`、`ripgrep`（搜索）、`fd`（可选，加速找文件）
- Node.js（copilot / 部分 LSP）、Nerd Font
- Rust 二进制（blink.cmp/blink.pairs 的匹配器）由插件按 tag 自动下载，无需 cargo

### 2. 获取配置

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
git clone <本仓库> ~/.config/nvim
```

首次启动 `vim.pack` 自动克隆插件、treesitter 自动装缺失 parser。

### 3. 安装 LSP / DAP / 格式化器

```vim
:MasonInstallAll
```

列表见 `lua/plugins/mason.lua`；启用的 server 见 `lua/core/lsp.lua`，
settings 覆盖在 `after/lsp/<name>.lua`。rustfmt/zigfmt 随语言工具链走，
不经 Mason。

## ⌨️ 核心快捷键

leader 为空格，localleader 为 `,`。**按下 `<leader>` 停顿即弹 which-key 速查**，
以下只列主干。

### 基础

- `<leader>w` 保存 · `<leader>q` 退出 · `<C-h/j/k/l>` 窗口切换
- `<leader>sv`/`sh`/`sc` 分屏 · `<S-h>`/`<S-l>` 切 buffer
- `<leader>1..9` 跳第 N 个 buffer（bufferline，`<leader>b*` 更多操作）
- `<Esc>` 清搜索高亮 · `<leader>u` 内置 Undotree

### 补全（blink.cmp）

- `<C-j>`/`<C-k>` 选择 · `<CR>` 确认 · `<A-.>`/`<A-,>` 手动开/关菜单
- `<Tab>`：菜单可见选下一项 → copilot 建议可见则接受 → snippet 跳转
- `<C-b>`/`<C-f>` 文档滚动 · `<C-l>`/`<C-h>` snippet 前后跳
- `<A-;>` copilot 开关自动触发 · `<A-'>` copilot 下一条/丢弃
- cmdline 补全同样由 blink 接管；copilot 首次 `:Copilot auth` 登录

### 编辑

- `gsa`/`gsd`/`gsr` 加/删/换包围（mini.surround，`gsaiw"` 给词加引号）
- `af`/`if` 函数、`ac`/`ic` 类、`aa`/`ia` 参数（treesitter textobjects）
- `]f`/`[f` 函数间跳 · `]t`/`[t` TODO 间跳 · `s`/`S` flash 跳转
- `<leader>cf` 格式化（conform，LSP fallback）

### 文件与搜索（fzf-lua）

- `<leader>ff`/`fr`/`fb` 文件/最近/buffer · `<leader>sg` live grep
- `<leader>sw` 搜光标词 · `<leader>/` buffer 内搜 · `<leader>st` 搜 TODO
- `<leader>e` 文件树开关 · `<leader>fe` 聚焦（树内 `g?` 看键位）

### LSP

0.12 内置：`grn` 重命名 · `gra` code action · `grr` 引用 · `gri` 实现 ·
`grt` 类型定义 · `grx` codelens · `gO` 大纲 · 插入模式 `<C-s>` 签名帮助。

本配置补充：`gd`/`gD` 定义/声明 · `K` 悬停 · `<leader>ca` action ·
`<leader>cr` 重命名 · `<leader>ci`/`co` 调用层级 · `<leader>ih` inlay hints 开关。

fzf 列表版（结果多时）：`<leader>ls`/`lS` 符号 · `ld` 定义 · `lr` 引用 ·
`li` 实现 · `la` action。

诊断：`[d`/`]d` 跳转（内置） · `<leader>cd` 浮窗 · `<leader>cD` loclist ·
`<leader>dd`/`dw` fzf 文档/工作区诊断。

### Git（`<leader>g*`，一键一职）

| 键 | 功能 | 键 | 功能 |
|---|---|---|---|
| `gg` | fugitive 状态 | `gs` | fzf status picker |
| `gc` | commit | `gl` | fzf log 浏览 |
| `gb` | blame | `gB` | fzf 分支 |
| `gp`/`gP`/`gf` | push/pull/fetch | `gw`/`gr` | 暂存/检出当前文件 |
| `gd` | Gdiffsplit vs index | `gD` | difftool vs HEAD |
| `go` | mini.diff overlay | | |

hunk 操作（mini.diff）：`gh` 暂存（operator）· `gH` 撤销 · `[h`/`]h` 跳转；
任意两路径比较用 `:DiffTool <l> <r>`。

### 调试（DAP，首次按键自动加载）

- `<F5>` 继续 · `<F10>`/`<F11>`/`<F12>` 步过/入/出
- `<leader>db` 断点 · `dB` 条件断点 · `du` UI · `de` 求值（可视模式可用）

## 📁 目录结构

```text
~/.config/nvim/
├── init.lua                  # 入口
├── nvim-pack-lock.json       # vim.pack 版本锁
├── after/lsp/                # 各 server settings 覆盖（15+ 个）
├── lua/core/                 # 无插件依赖
│   ├── options.lua           # 选项（exrc、fold、grep=rg…）
│   ├── keymaps.lua           # 基础键位
│   ├── autocmds.lua          # 自动命令
│   ├── diagnostics.lua       # 诊断样式
│   └── lsp.lua               # vim.lsp.enable + LspAttach
└── lua/plugins/
    ├── init.lua              # vim.pack 清单 + require 入口
    ├── completion.lua        # blink.cmp（capabilities 注入）
    ├── pairs.lua             # blink.pairs（InsertEnter）
    ├── treesitter.lua        # parser 管理 + textobjects
    ├── fzf.lua               # 搜索 + ui_select
    ├── file-explorer.lua     # nvim-tree（懒加载）
    ├── statusline.lua        # 自绘彩色状态栏
    ├── diff.lua / git.lua    # mini.diff / fugitive
    ├── format.lua            # conform
    ├── dap.lua               # 调试（懒加载）
    ├── markdown.lua          # render-markdown（懒加载）
    ├── surround.lua / todo.lua / which-key.lua / flash.lua
    ├── copilot.lua           # InsertEnter 懒加载
    ├── ai.lua / terminal.lua / bufferline.lua / colorscheme.lua
    ├── mason.lua             # :MasonInstallAll
    ├── lazydev.lua / difftool.lua / ui2.lua
    └── …
```
