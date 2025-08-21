# 现代化 Neovim 配置

[English](https://github.com/jinzhongjia/neovim-config/blob/main/Readme.md) | [插件列表](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

一个功能全面的 Neovim 配置，集成了内置 LSP、AI 助手和现代化开发工具。

> *这个配置是为我个人使用而定制的。我不建议直接复制使用，而是希望它能为你提供灵感，帮助你理解插件生态系统、依赖管理和配置组织模式，从而构建适合自己的配置。*

## ✨ 核心特性

> 快速、开箱即用、主观优化，但保持易裁剪。

- 🧠 **AI 集成**: CodeCompanion / Claude Code / Copilot，多模型(MCP)，可自定义系统提示。
- 🔧 **LSP 全托管**: Mason 统一安装更新，按语言覆写配置。
- ✏️ **智能编辑**: Blink.cmp、Snippets、autopairs、surround、多光标、结构化文本对象。
- 🎯 **代码智能/导航**: Treesitter 高亮、符号大纲、Peek 预览、智能折叠。
- 🐛 **调试**: nvim-dap + UI，持久断点，行内虚拟文本，Go/JS/Python 辅助。
- 🔍 **搜索工作流**: Telescope（文件/实时/频率/符号），ripgrep & fd 集成。
- 📁 **项目/文件**: NvimTree 浮动/预览，项目根检测，最近 & 收藏。
- 📊 **数据库工具**: 内置 SQL 客户端 + 补全 + UI。
- 🎨 **现代 UI**: Catppuccin 主题、动态状态栏、通知、命令面板、Snacks 增强。
- 🌀 **Git 协作**: Gitsigns、Fugitive、Neogit、Lazygit、Diff/Blame 快捷。
- 🧩 **可扩展设计**: 模块边界清晰、懒加载模式、覆写钩子。
- 🚀 **性能优先**: 激进懒加载、启动分析、缓存与 GC 调优。
- 🛡️ **安全默认**: 防御式自动命令 & Keymap，插件异常降级。

## 📸 截图

![概览](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)
![仪表板](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![定义跳转](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![悬停提示](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![代码操作](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)

## 📦 安装

### 系统要求
- Neovim `>= 0.10`
- Git
- [Nerd Font](https://www.nerdfonts.com/) 字体（推荐：JetBrainsMono Nerd Font）

### 快速安装

```bash
# Unix-like 系统（Linux/macOS）
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim

# Windows
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

### 首次启动
1. 首次打开等待 Lazy.nvim 安装插件
2. 运行 `:checkhealth` 验证环境
3. 运行 `:Mason` 安装 LSP / 格式化 / 诊断工具
4. 重启 Neovim

### TL;DR
```bash
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
nvim           # 等待插件安装
# 进入后:
:Mason
:checkhealth
```

## 🛠️ 依赖

### 核心工具
- **git** - 版本管理 / 插件下载
- **ripgrep** - 文本搜索
- **fd** - 文件查找
- **curl / wget** - 网络下载
- **unzip** - 解压
- **cmake / make** - 构建原生扩展

### 语言运行时（按需安装）
- **Node.js + npm** (TS/JS LSP / 工具链)
- **Python + pip** (Python LSP / 格式化、诊断)
- **Go** (gopls / 调试工具)
- **Rust + cargo** (rust-analyzer / 构建工具)
- **Zig** (Zig 语法/构建)
- **GCC / Clang** (C/C++ / Treesitter 编译)
- **.NET SDK** (C#)
- **Java (>=11)** (Java LSP)

### 开发辅助（可选）
- **Lazygit** - Git 终端 UI
- **Lazydocker** - Docker 终端 UI
- **MCP Hub** - MCP 服务管理
- **GitHub CLI (gh)** - GitHub 集成
- **jq** - JSON 处理

### 可选系统库
- 编译工具链（gcc/clang, make, cmake）
- 压缩/解压工具（unzip / tar）
- SSL 库（如 libssl）供少量工具使用

### 推荐的 GUI 客户端
- [**Neovide**](https://neovide.dev/) - 现代化的 Neovim GUI，支持动画效果
- [**Nvy**](https://github.com/RMichelsen/Nvy) - 跨平台 Neovim GUI

*这两个 GUI 客户端都已在配置中预设好。*

## 🔧 配置管理

### 健康检查
安装完成后，运行 `:checkhealth` 诊断潜在问题。

### LSP 和工具管理
所有 LSP 服务器和开发工具都通过 Mason 管理：
- 使用 `:Mason` 查看和管理已安装的工具
- 使用 `:LspInfo` 检查活跃的语言服务器
- 使用 `:ConformInfo` 验证格式化工具

### 快捷键
- `<leader>ff` - 查找文件
- `<leader>fg` - 实时搜索
- `<leader>fb` - 浏览缓冲区
- `<leader>fh` - 帮助标签
- `<leader>e` - 文件浏览器
- `<leader>xx` - 诊断信息
- `<leader>ai` - AI 助手

## 🧩 自定义

核心目录结构：
```
lua/
  core/     -> 选项 / 自动命令 / 基础键位
  plugins/  -> lazy.nvim 插件声明分组
  lsp/      -> 服务器配置 / capabilities / on_attach
  ui/       -> 主题 & 界面增强
```

扩展思路：
1. 创建 `lua/custom/` 添加你自己的 spec。
2. 使用同名插件 spec + `opts = function(_, opts)` 进行覆写。
3. 禁用不需要插件：
```lua
return { { "nvim-neo-tree/neo-tree.nvim", enabled = false } }
```
4. 语言专属：`after/ftplugin/<filetype>.lua`。

最小化引导示例：
```lua
require("core").setup()
require("lazy").setup({
  { import = "plugins.core" },
  { import = "plugins.lsp" },
})
```

## 🐞 常见问题 (FAQ)

Q: 首次安装卡住？  
A: 检查网络/代理，执行 `:Lazy sync`，必要时删除 `lazy-lock.json`。

Q: LSP 没 attach？  
A: `:LspInfo` 查看状态，确认已在 `:Mason` 安装，对应 `:set ft?` 正确。

Q: 格式化失败？  
A: `:ConformInfo` 确认 formatter 存在，排除旧 null-ls 冲突。

Q: 卡顿/高 CPU？  
A: `:Lazy profile` 定位耗时，逐步禁用 UI 插件二分排查。

Q: AI 提示干扰？  
A: 使用映射切换或禁用相关 spec。

速查：
```
:Lazy sync
:Lazy profile
:Mason
:LspInfo
:checkhealth
```

## ⚡ 性能建议

- 精简 Treesitter & Mason 语言列表。
- 禁用多余 provider（Perl/Ruby/Node）已大多预设。
- ripgrep + fd 已集成，保持可执行即可。
- 冷启动慢可尝试 `:Lazy restore`。
- 远程/低配裁剪 UI/动画插件。

## 📄 许可

此为个人配置示例，可引用片段（注明来源），大型需求欢迎以 PR 形式参与。
