# 现代化 Neovim 配置

[English](https://github.com/jinzhongjia/neovim-config/blob/main/Readme.md) | [插件列表](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

一个功能全面的 Neovim 配置，集成了内置 LSP、AI 助手和现代化开发工具。

> *这个配置是为我个人使用而定制的。我不建议直接复制使用，而是希望它能为你提供灵感，帮助你理解插件生态系统、依赖管理和配置组织模式，从而构建适合自己的配置。*

## 📸 截图

![概览](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)
![仪表板](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![定义跳转](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![悬停提示](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![代码操作](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)

## 📦 安装

### 系统要求
- **Neovim** `>= 0.10.0`（所有功能必需）
- **Git** `>= 2.19.0`（用于插件管理和版本控制）
- [Nerd Font](https://www.nerdfonts.com/) 字体（推荐：JetBrainsMono Nerd Font，用于图标和符号显示）

### 快速安装

```bash
# Unix-like 系统（Linux/macOS）
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim

# Windows
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

### TL;DR 快速开始
```bash
# 克隆仓库
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
cd ~/.config/nvim

# 首次启动（自动下载插件）
nvim

# 在 Neovim 中（安装完成后）
:Mason         # 安装语言服务器 / 代码检查工具 / 格式化工具
:checkhealth   # 验证环境配置

# 可选辅助命令
:Lazy update   # 保持插件更新
```

### 首次启动
1. 打开 Neovim，等待 Lazy.nvim 自动安装所有插件
2. 运行 `:checkhealth` 验证您的环境配置
3. 运行 `:Mason` 安装 LSP 服务器、格式化工具和代码检查工具
4. 重启 Neovim 以确保所有配置加载完成

## 🛠️ 依赖

### 核心必需工具
- **git** `>= 2.19.0` - 版本控制和插件管理
- **curl** 或 **wget** - HTTP 客户端，用于下载工具

### 构建工具（推荐）
- **cmake** `>= 3.10` - 原生扩展的构建系统
- **make** - 构建自动化
- **gcc** 或 **clang** - C 编译器，用于 Treesitter 解析器
- **unzip** - 用于解压 Mason 软件包

### 语言支持（可选 - 根据需要安装）

#### 主要语言
- **Node.js** `>= 18.0.0` & **npm** - JavaScript/TypeScript 开发
  - 许多 LSP 服务器和工具需要
- **Python** `>= 3.8` & **pip** - Python 开发
  - 一些格式化工具和代码检查工具需要
- **Go** `>= 1.20` - Go 开发
  - Go LSP 和工具需要
- **Rust** & **cargo** - Rust 开发
  - Rust analyzer 和一些工具需要

#### 其他语言
- **Zig** `>= 0.11.0` - Zig 语言支持
- **.NET SDK** `>= 6.0` - C# 开发
- **Lua** `>= 5.1` - Lua 开发

### 开发工具（可选）
- **Lazygit** - Git 终端 UI（与 Neovim 集成）
- **Lazydocker** - Docker 终端 UI
- **MCP Hub** - 模型上下文协议服务器支持
- **GitHub CLI** (`gh`) - GitHub 集成
- **jq** - JSON 处理器（某些插件使用）
- **ripgrep** (`rg`) - 快速文本搜索（Snacks.nvim 使用）

### 可选系统库
- 编译工具链（gcc/clang, make, cmake）用于构建原生扩展和 Treesitter
- unzip / tar 工具用于解压软件包
- SSL 开发库（例如 libssl），某些工具需要 HTTPS 功能

### GUI 客户端（可选）
- [**Neovide**](https://neovide.dev/) - GPU 加速的 Neovim GUI，具有流畅动画效果
- [**Nvy**](https://github.com/RMichelsen/Nvy) - 快速、原生的 Windows Neovim GUI

*注意：配置会自动检测并为这些 GUI 客户端配置相应设置。*


