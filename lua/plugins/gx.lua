return
--- @type LazySpec
{
    {
        "chrishrb/gx.nvim",
        keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open URL under cursor" } },
        cmd = { "Browse" },
        init = function()
            vim.g.netrw_nogx = 1 -- 禁用 netrw 的 gx
        end,
        submodules = false,
        config = true,
    },
}
