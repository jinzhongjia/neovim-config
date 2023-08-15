local opt = {
    cmd = { "clangd", "--offset-encoding=utf-16" },
    root_dir = function()
        return vim.fn.getcwd()
    end,
}

return opt
