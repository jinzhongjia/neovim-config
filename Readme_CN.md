# 快速开始

现在关于 `Neovim` 的配置我有两个维护的分支，一个使用 `embed lsp`，另一个使用 `coc.nvim`.

内置 `lsp` 更加极客化，而 `coc` 提供了类似vscode的开箱即用功能！

> *其实，我并不希望你直接照抄或者直接git下来使用我的配置，我的配置更多的是适合我自己，我的配置的作用更多情况下是给你提供一个自己配置的思路，让你明白需要哪些插件，如何处理依赖，如何处理文件组织结构等等！*

## 概览

![概览](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)

## 安装

对于内置Lsp用户：

需要最新开发版的Neovim,即 `nightly`。

```sh
# for unix-like
git clone -b hybrid https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
# for windows
git clone -b hybrid https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

对于Coc用户：

0.8之后的Neovim即可。

```sh
# for unix-like
git clone -b coc https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
# for windows
git clone -b coc https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

## 依赖

- Golang
- Rust
- Python
- Nodejs
- Zig
- Gcc/Clang
- Lazygit
- Lazydocker
- fd (*内置LSP*)
- ripgrep (*内置LSP*)
- unzip (*内置LSP*)
- Cmake (*内置LSP*)

关于 GUI，建议使用 [Neovide](https://neovide.dev/)，非常棒的客户端，我的配置已经包含 neovide 的设置。

## 注意

安装完成后后，运行 `:checkhealth` 来检查是否存在问题。

### 对于内置Lsp用户

所有的 Lsp 均通过 `mason` 来安装，你可以使用命令 `:mason` 来查看具体的安装情况！

### 对于Coc用户

仅仅依赖于nodejs,不过你可能需要自己阅读以下Coc的使用帮助！

## 更多图片

![dash](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![definition](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![hover](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![code_action](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)