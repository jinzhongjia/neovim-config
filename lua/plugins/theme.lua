return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        enabled = false,
        opts = {
            compile = true,
            dimInactive = true,
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd.colorscheme("kanagawa")
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        enabled = false,
        opts = {
            dim_inactive = {
                enabled = true,
                shade = "dark",
                percentage = 0.15,
            },
            integrations = {
                nvimtree = true,
                treesitter = true,
                mini = { enabled = true },
                blink_cmp = true,
                diffview = true,
                dropbar = { enabled = true, color_mode = true },
                fidget = true,
                grug_far = true,
                indent_blankline = { enabled = true, colored_indent_levels = true },
                mason = true,
                nvim_surround = true,
                overseer = true,
                snacks = { enabled = true },
                lsp_trouble = true,
                which_key = true,
                symbols_outline = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },
    {
        "Mofiqul/vscode.nvim",
        priority = 1000,
        enabled = true,
        opts = {
            italic_comments = true,
            italic_inlayhints = true,
            underline_links = true,
            disable_nvimtree_bg = true,
            terminal_colors = true,
        },
        config = function(_, opts)
            require("vscode").setup(opts)
            require("vscode").load()
        end,
    },
}
