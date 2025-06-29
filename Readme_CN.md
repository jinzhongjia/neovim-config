# 现代化 Neovim 配置

[English](https://github.com/jinzhongjia/neovim-config/blob/main/Readme.md) | [插件列表](https://github.com/jinzhongjia/neovim-config/blob/main/plugin_list.md)

一个功能全面的 Neovim 配置，集成了内置 LSP、AI 助手和现代化开发工具。

> *这个配置是为我个人使用而定制的。我不建议直接复制使用，而是希望它能为你提供灵感，帮助你理解插件生态系统、依赖管理和配置组织模式，从而构建适合自己的配置。*

## ✨ 核心特性

- 🧠 **AI 集成**: 内置 AI 助手（CodeCompanion）和可定制的系统提示。
- 🔧 **内置 LSP**: 原生 Neovim LSP，支持多种编程语言。
- 🎨 **现代化界面**: 精美主题（Catppuccin、Kanagawa、Arctic）和增强状态栏。
- 🔍 **高级搜索**: Telescope 模糊搜索、实时搜索和基于频率的结果。
- 📁 **文件管理**: NvimTree 文件浏览器，支持预览和高级文件操作。
- 🐛 **调试工具**: 完整的 DAP 集成，包含虚拟文本和调试界面。
- 📊 **数据库工具**: 内置数据库客户端和智能补全。
- 🎯 **代码导航**: Treesitter 语法高亮、大纲视图和智能代码折叠。
- 🚀 **性能优化**: 启动优化，懒加载和智能退出。

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
安装完成后，运行 `:checkhealth` 检查配置是否正常工作。

## 🛠️ 依赖

### 核心工具
- **wget** 和 **curl** - 下载工具
- **fd** - 快速文件查找
- **ripgrep** - 快速文本搜索
- **unzip** - 解压工具
- **cmake** - 构建系统

### 语言运行时
- **Go** - Go 语言支持
- **Rust** - Rust 语言支持
- **Python** - Python 语言支持
- **Node.js** - JavaScript/TypeScript 支持
- **Zig** - Zig 语言支持
- **GCC/Clang** - C/C++ 编译器
- **.NET** - C# 语言支持

### 开发工具
- **Lazygit** - Git 终端界面客户端
- **Lazydocker** - Docker 终端界面客户端
- **VectorCode** - 矢量图形支持
- **Microsoft C++ Build Tools**（仅 Windows）

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
