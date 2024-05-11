local lists = {
    { cmd = "lua-language-server", name = "lua_ls", alone = false },
    { name = "clangd", alone = false },
    { cmd = "bash-language-server", name = "bashls", alone = false },
    { name = "cmake", alone = false },
    { cmd = "vscode-css-language-server", name = "cssls", alone = false },
    { cmd = "docker-langserver", name = "dockerls", alone = false },
    { cmd = "emmet-language-server", name = "emmet_ls", alone = false },
    { cmd = "gopls", name = "gopls", alone = false },
    { cmd = "vscode-html-language-server", name = "html", alone = false },
    { cmd = "vscode-json-language-server", name = "jsonls", alone = false },
    { name = "rust_analyzer", alone = false },
    { name = "pyright", alone = false },
    { name = "volar", alone = false },
    { cmd = "vim-language-server", name = "vimls", alone = false },
    { name = "vtsls", alone = false }, -- TODO: for nixos
    { name = "unocss", alone = false }, -- TODO: for nixos
    { cmd = "yaml-language-server", name = "yamlls", alone = false },
    { name = "lemminx", alone = false },
    { name = "taplo", alone = false },
    { cmd = "efm-langserver", name = "efm", alone = false },
}

return lists
