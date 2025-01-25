if vim.g.neovide then
    require("editor.neovide")
elseif vim.g.nvy then
    require("editor.nvy")
end
