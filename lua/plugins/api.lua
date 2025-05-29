return
--- @type LazySpec
{
    {
        "mistweaverco/kulala.nvim",
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
            { "<leader>Rb", desc = "Open scratchpad" },
        },
        opts = {
            -- your configuration comes here
            global_keymaps = false,
            global_keymaps_prefix = "<leader>R",
            kulala_keymaps_prefix = "",
        },
    },
    {
        "oysandvik94/curl.nvim",
        cmd = { "CurlOpen" },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = true,
    },
}
