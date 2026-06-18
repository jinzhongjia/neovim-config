return
--- @type LazySpec
{
    {
        "linux-cultist/venv-selector.nvim",
        ft = "python",
        cmd = { "VenvSelect" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/snacks.nvim",
        },
        keys = {
            { "<leader>pv", "<cmd>VenvSelect<cr>", ft = "python", desc = "Select Python venv" },
        },
        init = function()
            require("core.python").setup_auto_refresh()
        end,
        opts = {
            options = {
                picker = "snacks",
                enable_default_searches = true,
                enable_cached_venvs = true,
                cached_venv_automatic_activation = true,
                activate_venv_in_terminal = true,
                set_environment_variables = true,
                notify_user_on_venv_activation = true,
                require_lsp_activation = true,
            },
        },
    },
}
