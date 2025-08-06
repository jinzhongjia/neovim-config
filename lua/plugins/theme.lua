return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = false,
                dim_inactive = {
                    enabled = true, -- dims the background color of inactive window
                    shade = "dark",
                    percentage = 0.15, -- percentage of the shade to apply to the inactive window
                },
                integrations = {
                    nvimtree = true,
                    treesitter = true,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                    blink_cmp = true,
                    diffview = true,
                    dropbar = {
                        enabled = true,
                        color_mode = true, -- enable color for kind's texts, not just kind's icons
                    },
                    fidget = true,
                    grug_far = true,

                    indent_blankline = {
                        enabled = true,
                        colored_indent_levels = true,
                    },
                    mason = true,
                    nvim_surround = true,
                    overseer = true,
                    snacks = {
                        enabled = true,
                    },
                    lsp_trouble = true,
                    illuminate = {
                        enabled = true,
                        lsp = true,
                    },
                    which_key = true,
                    symbols_outline = true,
                },
            })
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },
}
