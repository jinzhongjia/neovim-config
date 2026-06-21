return
--- @type LazySpec
{
    {
        name = "tsplements",
        dir = vim.fn.stdpath("config"),
        ft = { "typescript", "typescriptreact" },
        config = function()
            vim.g.__load_tsplements = true
            dofile(vim.fn.stdpath("config") .. "/plugin/tslement.lua")
            vim.g.__load_tsplements = nil
        end,
    },
}
