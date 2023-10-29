# Quick Start

[中文](https://github.com/jinzhongjia/neovim-config/blob/main/Readme_CN.md)

Now, I have two branches for neovim, one is using `embed lsp`, anothor is using `coc.nvim`.

Embed lsp is for geek customization, coc is for lightweight configuration.

> *In fact, I don’t want you to directly copy or git it down and use my configuration. My configuration is more suitable for myself. The role of my configuration is more often to provide you with an idea for your own configuration, so that you can Understand which plug-ins are needed, how to deal with dependencies, how to deal with file organization structure, and more!*

## Install

For embed lsp users:

neovim version: `nightly`

```sh
git clone -b hybrid https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
```

> The current neovim development version seems to have some strange modifications. The theme will trigger strange errors or crash when it is first installed, but everything will be normal after restarting.

For coc users:

neovim version: `latest release`

```sh
git clone -b coc https://github.com/jinzhongjia/neovim-config.git ~/.config/nvim
```

## Denpendences

- Golang
- Rust
- Python
- Nodejs
- Zig
- Gcc/Clang
- Lazygit
- Lazydocker
- fd (*embed lsp*)
- ripgrep (*embed lsp*)
- unzip (*embed lsp*)
- Cmake (*embed lsp*)

## Note

When you install this configuration compeletely, you need to run`:checkhealth` for check whether has problem.

### For `embed lsp` users

lsp server and guard denpendences are all installed by mason, you can use `:mason` to check installing information

### FOr `coc` users

coc depends `nodejs`, you may need to read coc help!
