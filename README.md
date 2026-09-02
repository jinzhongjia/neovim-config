# Neovim 0.12 Minimal Performance Config

基于 Neovim 0.12 的极简高性能配置。原则：**能用内置功能解决的绝不引入插件；
必须引入的插件，低频场景一律懒加载**。

## ✨ 核心特性

- **精简启动路径**：只保留配色和 snacks 基础设施；bufferline/which-key/AI
  推迟到 `VeryLazy`，补全/treesitter/LSP 数据在读文件前加载，其余低频插件按
  命令、按键、事件或 filetype 拦截加载。
- **lazy.nvim 插件管理**：自动引导，版本锁定见 `lazy-lock.json`。
- **Neovim 0.12 原生能力**：
  - 内置 `vim.lsp.config` + `vim.lsp.enable`；`nvim-lspconfig` 只作为
    `cmd`/`filetypes`/`root_markers` 基础配置来源，`after/lsp/*.lua` 覆盖 settings。
  - 内置实验性 `ui2`（消除 Press-ENTER、cmdline 高亮）。
  - 内置 difftool（`:DiffTool`）、undotree（`<leader>u`）、注释（`gc`）、
    增量选区（`v_an`/`v_in`）、`[d`/`]d` 诊断跳转、`exrc` 项目本地配置。
  - 自绘彩色状态栏（模式色块 / fugitive 分支 / mini.diff hunk 计数 /
    诊断 / LSP 进度事件缓存 / 宏录制提示），无 lualine。
  - `statuscolumn` 交给 snacks：左 mark/sign，右 fold/git（认 mini.diff 的 sign）。
- **Go / TS 实现关系提示**：`plugin/golement.lua`、`plugin/tslement.lua`
  是仓库自带的两个零依赖脚本（treesitter + LSP），给 interface/struct 打上
  `implements:` / `implemented by:` 行尾虚拟文本，按 filetype 懒加载。
- **Go 工作流**：`after/ftplugin/go.lua` 用 tab 缩进；picker 全局排除
  `*.gen.go`/`gen.go`/`*.pb.go`/`*.connect.go`/`*.connector.go` 这些生成物。
- **完整语言支持**：Lua、TS/JS、Go、Rust、Zig、Python、C/C++、CSS、HTML、
  JSON、YAML、Protobuf、Bash、Dockerfile（LSP + treesitter + 格式化 + DAP）。

## 📦 插件清单（按职责）

| 职责 | 插件 | 加载时机 |
|---|---|---|
| 补全 | blink.cmp（+ lazydev） | 读文件前 / InsertEnter / CmdlineEnter |
| 括号配对 | blink.pairs（+ blink.lib） | InsertEnter |
| 语法 | nvim-treesitter + textobjects（均 main 分支） | 读文件前 |
| LSP 基础数据 | nvim-lspconfig（不调 setup） | 读文件前 |
| 包管理 | mason.nvim（`:MasonInstallAll`） | 首次 Mason 命令 |
| 搜索 / 终端 / 通知 / 缩进线 | snacks.nvim（picker、terminal、statuscolumn、`vim.ui.input`+`select`、bigfile、scratch、zen） | 启动 |
| 文件树 | nvim-tree + nvim-web-devicons | 首次命令/按键或目录启动 |
| Buffer 栏 | bufferline.nvim | VeryLazy |
| Git | vim-fugitive + mini.diff | 首次命令/按键 / 读文件前 |
| 格式化 | conform.nvim | 首次格式化 |
| 调试 | nvim-dap + nvim-dap-ui + nvim-nio | 首次 DAP 按键 |
| 跳转 | flash.nvim（`s`/`S`） | 首次按键 |
| split/join | treesj（`<leader>m`） | 首次按键 |
| 行号预览 | numb.nvim（`:123`） | 首次进 cmdline |
| CSV | csvview.nvim（`:CsvViewToggle`） | 首个 csv/tsv |
| 退出插入 | better-escape.nvim（`jk`/`jj`） | InsertEnter |
| 包围 | mini.surround（`gs` 前缀） | VeryLazy |
| TODO | todo-comments.nvim（+ plenary） | 读文件后 |
| Markdown | render-markdown.nvim | 首个 markdown |
| 键位速查 | which-key.nvim | VeryLazy |
| AI | claudecode.nvim / opencode.nvim / omp.nvim / copilot.lua | VeryLazy / InsertEnter |
| 配色 | vscode.nvim | 启动 |

## 📦 安装指南

### 1. 环境依赖

- **Neovim >= 0.12**、`git`
- `ripgrep`（grep 搜索）、`fd`（可选，加速找文件）；snacks picker 是纯 Lua，不需要 `fzf`
- Node.js（copilot / 部分 LSP）、Nerd Font
- Rust 二进制（blink.cmp/blink.pairs 的匹配器）由插件按 tag 自动下载，无需 cargo

### 2. 获取配置

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
git clone <本仓库> ~/.config/nvim
```

首次启动会自动引导 `lazy.nvim`、安装插件并生成/更新 `lazy-lock.json`；
treesitter 会自动安装缺失 parser。后续用 `:Lazy` 查看、更新和清理插件。

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
- `<leader>cf` 格式化（conform，LSP fallback）· `<leader>m` split/join 切换

### 文件与搜索（snacks picker）

- `<leader>ff`/`fr`/`fb` 文件/最近/buffer · `<leader>sg` live grep（可视模式搜选区）
- `<leader>sw`/`sW` 搜光标词/WORD · `<leader>sb`、`<leader>/` buffer 内搜 ·
  `<leader>sB` 搜所有打开的 buffer · `<leader>st` 搜 TODO
- `<leader>fh`/`fk`/`fc` help/keymaps/命令 · `<leader>fR` 重开上次 picker ·
  `<leader>fP` 列出所有 picker
- `<leader>e` 文件树开关 · `<leader>fe` 聚焦（树内 `g?` 看键位）

### LSP

0.12 内置：`grn` 重命名 · `gra` code action · `grr` 引用 · `gri` 实现 ·
`grt` 类型定义 · `grx` codelens · `gO` 大纲 · 插入模式 `<C-s>` 签名帮助。

本配置补充：`gd`/`gD` 定义/声明 · `K` 悬停 · `<leader>ca` action ·
`<leader>cr` 重命名 · `<leader>ci`/`co` 调用层级 · `<leader>ih` inlay hints 开关。

picker 列表版（结果多时）：`<leader>ls`/`lS` 符号 · `ld` 定义 · `lr` 引用 ·
`li` 实现 · `la` action。`]]`/`[[` 在同名符号间跳（snacks words）。

诊断：`[d`/`]d` 跳转（内置） · `<leader>cd` 浮窗 · `<leader>cD` loclist ·
`<leader>dd`/`dw` picker 文档/工作区诊断 · `gK` 当前行 virtual_lines 展开/收起
（virtual_text 只显示第一行，长诊断看不全时用它）。

### Git（`<leader>g*`，一键一职）

| 键 | 功能 | 键 | 功能 |
|---|---|---|---|
| `gg` | fugitive 状态 | `gs` | status picker |
| `gc` | commit | `gl` | log 浏览 |
| `gb` | blame | `gB` | 分支 |
| `gp`/`gP`/`gf` | push/pull/fetch | `gw`/`gr` | 暂存/检出当前文件 |
| `gd` | Gdiffsplit vs index | `gD` | difftool vs HEAD |
| `go` | mini.diff overlay | `gy` | 浏览器打开远端（可视模式带行号） |

hunk 操作（mini.diff）：`gh` 暂存（operator）· `gH` 撤销 · `[h`/`]h` 跳转；
任意两路径比较用 `:DiffTool <l> <r>`。

### 终端（Snacks.terminal）

- `<C-\>` 或 `<leader>tt` 开关浮动终端 · `<leader>tn` 新开一个
- `<leader>t1..t5` 直达第 N 个 · `<leader>t]`/`t[` 前后切 · 终端内 `<C-]>` 切下一个
- `<Esc><Esc>` 回 normal（单个 `<Esc>` 留给终端里的程序）· `q` 收起

### 其它（snacks）

- `<leader>n` 通知历史 · `<leader>N` 清掉当前通知
- `<leader>.` 草稿 buffer（带持久化文件）· `<leader>S` 挑一个草稿
- `<leader>zz` zen 模式 · `<leader>zw` 最大化当前窗口
- `<leader>T*` 各种开关：`Ts` 拼写 · `Tw` 折行 · `Tc` conceal · `Tl` 行号 ·
  `Td` 诊断 · `Tt` treesitter · `Ti` 缩进线 · `TD` dim

### 调试（DAP，首次按键自动加载）

- `<F5>` 继续 · `<F10>`/`<F11>`/`<F12>` 步过/入/出
- `<leader>db` 断点 · `dB` 条件断点 · `du` UI · `de` 求值（可视模式可用）

## 📁 目录结构

```text
~/.config/nvim/
├── init.lua                  # 入口
├── lazy-lock.json            # lazy.nvim 版本锁
├── after/lsp/                # 各 server settings 覆盖（15+ 个）
├── after/ftplugin/go.lua     # Go 用 tab（覆盖全局 expandtab）
├── plugin/                   # 启动时自动 source
│   ├── golement.lua          # Go implements 虚拟文本（守卫 + 懒 dofile）
│   ├── tslement.lua          # TS 版同上
│   └── pwsh.lua              # Windows 上把 shell 换成 pwsh
├── lua/core/                 # 无插件依赖
│   ├── options.lua           # 选项（exrc、fold、grep=rg…）
│   ├── keymaps.lua           # 基础键位
│   ├── autocmds.lua          # 自动命令
│   ├── diagnostics.lua       # 诊断样式
│   └── lsp.lua               # vim.lsp.enable + LspAttach
└── lua/plugins/
    ├── init.lua              # lazy.nvim 引导、插件规格与加载拦截
    ├── completion.lua        # blink.cmp（capabilities 注入）
    ├── pairs.lua             # blink.pairs（InsertEnter）
    ├── treesitter.lua        # parser 管理 + textobjects
    ├── snacks.lua            # picker/terminal/statuscolumn/通知/ui_select
    ├── file-explorer.lua     # nvim-tree（懒加载）
    ├── statusline.lua        # 自绘彩色状态栏
    ├── diff.lua / git.lua    # mini.diff / fugitive
    ├── format.lua            # conform
    ├── dap.lua               # 调试（懒加载）
    ├── markdown.lua          # render-markdown（懒加载）
    ├── implements.lua        # golement/tslement 的按 ft 懒加载器
    ├── treesj.lua / numb.lua / csvview.lua / escape.lua
    ├── surround.lua / todo.lua / which-key.lua / flash.lua
    ├── copilot.lua           # InsertEnter 懒加载
    ├── terminal.lua          # 浮动终端（Snacks.terminal）
    ├── ai.lua / bufferline.lua / colorscheme.lua
    ├── mason.lua             # :MasonInstallAll
    ├── lazydev.lua / difftool.lua / ui2.lua
    └── …
```
