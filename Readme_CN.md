# 快速开始

目前我的 neovim 使用的是内置的LSP特性，并未使用 coc

> *其实，我并不希望你直接照抄或者直接git下来使用我的配置，我的配置更多的是适合我自己，我的配置的作用更多情况下是给你提供一个自己配置的思路，让你明白需要哪些插件，如何处理依赖，如何处理文件组织结构等等！*

## 概览

![概览](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)

## 安装

至少为 `0.10` 版本！

```sh
# for unix-like
git clone -b hybrid https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
# for windows
git clone -b hybrid https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
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
- fd 
- ripgrep 
- unzip 
- Cmake 
- Microsoft C++ Build Tools (MS Windows)

关于 GUI，建议使用 [Neovide](https://neovide.dev/)或者[Nvy](https://github.com/RMichelsen/Nvy)，非常棒的客户端，我的配置已经包含它们的设置。

## 注意

安装完成后后，运行 `:checkhealth` 来检查是否存在问题。

所有的 Lsp server 均通过 `mason` 来安装，你可以使用命令 `:mason` 来查看具体的安装情况！

## 更多图片

![dash](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![definition](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![hover](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![code_action](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)
