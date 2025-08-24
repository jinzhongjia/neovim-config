return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        enabled = false,
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
    {
        "Mofiqul/vscode.nvim",
        priority = 1000,
        config = function()
            local c = require("vscode.colors").get_colors()
            require("vscode").setup({
                -- Alternatively set style in setup
                -- style = 'light'

                -- Enable transparent background
                -- transparent = true,

                -- Enable italic comment
                italic_comments = true,

                -- Enable italic inlay type hints
                italic_inlayhints = true,

                -- Underline `@markup.link.*` variants
                underline_links = true,

                -- Disable nvim-tree background color
                disable_nvimtree_bg = true,

                -- Apply theme colors to terminal
                terminal_colors = true,
            })
            require("vscode").load()

            -- load the theme without affecting devicon colors.
            -- vim.cmd.colorscheme("vscode")
        end,
    },
}
