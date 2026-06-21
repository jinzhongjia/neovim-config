return
--- @type LazySpec
{
    {
        name = "goplements",
        dir = vim.fn.stdpath("config"),
        ft = "go",
        config = function()
            vim.g.__load_goplements = true
            dofile(vim.fn.stdpath("config") .. "/plugin/golement.lua")
            vim.g.__load_goplements = nil
        end,
    },
}
