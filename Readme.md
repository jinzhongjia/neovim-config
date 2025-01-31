# Quick Start

[中文](https://github.com/jinzhongjia/neovim-config/blob/main/Readme_CN.md)

Now, my neovim is using embed lsp feature, which is more geek!

> *In fact, I don’t want you to directly copy or git it down and use my configuration. My configuration is more suitable for myself. The role of my configuration is more often to provide you with an idea for your own configuration, so that you can Understand which plug-ins are needed, how to deal with dependencies, how to deal with file organization structure, and more!*

## Overview

![overview](https://github.com/jinzhongjia/neovim-config/blob/main/pic/overview.png?raw=true)

## Install

For embed lsp users:

neovim version: `0.10`

```sh
# for unix-like
git clone https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
# for windows
git clone https://github.com/jinzhongjia/neovim-config.git ~/AppData/Local/nvim
```

## Denpendences

- wget
- curl
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
- Microsoft C++ Build Tools (For MS Windows)

For GUI, you can install [Neovide](https://neovide.dev/) or [Nvy](https://github.com/RMichelsen/Nvy), they are great GUI client!

## Note

When you install this configuration compeletely, you need to run`:checkhealth` for check whether has problem.

Lsp server and guard denpendences are all installed by mason, you can use `:mason` to check installing information

## More Picture

![dash](https://github.com/jinzhongjia/neovim-config/blob/main/pic/dash.png?raw=true)
![definition](https://github.com/jinzhongjia/neovim-config/blob/main/pic/definition.png?raw=true)
![hover](https://github.com/jinzhongjia/neovim-config/blob/main/pic/hover.png?raw=true)
![code_action](https://github.com/jinzhongjia/neovim-config/blob/main/pic/code_action.png?raw=true)
