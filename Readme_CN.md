# Neovim 配置

[English](./Readme.md)

一个现代化的 Neovim 配置，集成了 LSP、代码补全、AI 辅助和开发工具。

## 系统要求

- Neovim >= 0.10.0
- Git >= 2.19.0
- Nerd Font 字体（推荐：JetBrainsMono Nerd Font）

## 安装

### Linux/macOS
```bash
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
```

### Windows
```bash
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

## 快速开始

1. 克隆仓库
2. 启动 Neovim - lazy.nvim 会自动安装所有插件
3. 运行 `:Mason` 安装语言服务器和工具
4. 运行 `:checkhealth` 验证配置
5. 重启 Neovim

## 核心功能

### 语言支持
- 通过 nvim-lspconfig 集成 LSP
- 使用 Mason 管理语言服务器
- 使用 blink.cmp 提供代码补全
- 通过 Treesitter 实现语法高亮
- 使用 conform.nvim 进行代码格式化

### 开发工具
- Git 集成（gitsigns、neogit、diffview）
- snacks.nvim 模糊查找
- nvim-dap 调试支持
- floaterm 终端集成

### AI 辅助
- GitHub Copilot 集成
- Claude Code 支持

### 界面增强
- lualine 状态栏
- bufferline 缓冲区栏
- outline.nvim 代码大纲
- hlslens 增强搜索
- nvim-ufo 代码折叠

## 依赖

### 必需
- git >= 2.19.0
- curl 或 wget
- tree sitter cli

### 推荐
- unzip
- ripgrep

### 可选语言运行时
根据开发需求安装：
- Node.js >= 18.0.0（用于 TypeScript/JavaScript LSP）
- Python >= 3.8（用于 Python LSP）
- Go >= 1.20（用于 Go LSP）
- Rust 工具链（用于 Rust LSP）

## 配置结构

```
nvim-config/
├── init.lua              # 入口文件
├── lua/
│   ├── core/            # 核心配置
│   │   ├── basic.lua    # 基础设置
│   │   ├── util.lua     # 工具函数
│   │   └── init.lua     # 核心初始化
│   ├── plugins/         # 插件配置
│   └── plugin.lua       # 插件管理器设置
├── after/               # 运行时文件
└── plugin/              # 插件覆盖文件
```

## 插件管理

本配置使用 lazy.nvim 进行插件管理。

### 常用命令
- `:Lazy` - 打开插件管理器界面
- `:Lazy update` - 更新所有插件
- `:Lazy sync` - 安装缺失的插件并更新
- `:Lazy clean` - 删除未使用的插件

## 额外配置

### Git UTF-8 支持
```bash
git config --global core.quotepath false
```

## 说明

此配置为个人使用而定制。建议将其作为参考来理解插件生态系统和配置模式，而不是直接复制使用。
