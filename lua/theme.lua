local M = {}
M.theme = function()
    return {
        {
            "rebelot/kanagawa.nvim",
            -- event = "UIEnter",
            enabled = true,
            priority = 1000,
            config = function()
                -- vim.cmd("colorscheme kanagawa")
            end,
        },
        {
            "catppuccin/nvim",
            enabled = true,
            name = "catppuccin",
            priority = 1000,
            config = function()
                local catppuccin = require("catppuccin")

                catppuccin.setup({
                    flavour = "mocha",
                })

                -- vim.cmd.colorscheme("catppuccin")
            end,
        },
        {
            "projekt0n/github-nvim-theme",
            enabled = true,
            priority = 1000, -- make sure to load this before all the other start plugins
            config = function()
                require("github-theme").setup({})
                -- vim.cmd("colorscheme github_dark_dimmed")
            end,
        },
        {
            "Mofiqul/vscode.nvim",
            enabled = true,
            priority = 1000,
            config = function()
                local vscode = require("vscode")
                vscode.setup()
                -- vscode.load()
            end,
        },
        {
            "Everblush/nvim",
            enabled = true,
            name = "everblush",
            priority = 1000,
            config = function()
                -- vim.cmd("colorscheme everblush")
            end,
        },
        {
            "Mofiqul/adwaita.nvim",
            enabled = true,
            priority = 1000,
            config = function()
                vim.g.adwaita_darker = false -- for darker version
                vim.g.adwaita_disable_cursorline = false -- to disable cursorline
                vim.g.adwaita_transparent = false -- makes the background transparent
                -- vim.cmd([[colorscheme adwaita]])
            end,
        },
        {
            "JoosepAlviste/palenightfall.nvim",
            enabled = true,
            priority = 1000,
            config = function()
                -- require("palenightfall").setup()
            end,
        },
        {
            "Yagua/nebulous.nvim",
            enabled = true,
            priority = 1000,
            config = function()
                -- more details, see github
                -- require("nebulous").setup({
                --     variant = "fullmoon",
                -- })
            end,
        },
        {
            "savq/melange-nvim",
            enabled = true,
            priority = 1000,
            config = function()
                -- vim.cmd([[colorscheme melange]])
            end,
        },
        {
            "askfiy/visual_studio_code",
            enabled = true,
            priority = 1000,
            config = function()
                -- vim.cmd([[colorscheme visual_studio_code]])
            end,
        },
        {
            "rockyzhang24/arctic.nvim",
            branch = "v2",
            enabled = false,
            priority = 1000,
            dependencies = { "rktjmp/lush.nvim" },
            config = function()
                -- vim.cmd([[colorscheme arctic]])
            end,
        },
        {
            "rose-pine/neovim",
            name = "rose-pine",
            enabled = true,
            priority = 1000,
            config = function()
                require("rose-pine").setup({
                    --- @usage 'auto'|'main'|'moon'|'dawn'
                    variant = "auto",
                })

                -- Set colorscheme after options
                -- vim.cmd("colorscheme rose-pine")
            end,
        },
        {
            "uloco/bluloco.nvim",
            enabled = true,
            priority = 1000,
            dependencies = { "rktjmp/lush.nvim" },
            config = function()
                require("bluloco").setup({
                    style = "auto", -- "auto" | "dark" | "light"
                    transparent = false,
                    italics = false,
                    terminal = true, -- bluoco colors are enabled in gui terminals per default.
                    guicursor = true,
                })

                -- vim.cmd[[colorscheme bluloco]]
            end,
        },
        {
            "ronisbr/nano-theme.nvim",
            enabled = true,
            priority = 1000,
            config = function()
                -- vim.cmd[[colorscheme nano-theme]]
            end,
        },
        {
            "olivercederborg/poimandres.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                require("poimandres").setup({})
            end,

            -- optionally set the colorscheme within lazy config
            init = function()
                vim.cmd("colorscheme poimandres")
            end,
        },
        {
            "rmehri01/onenord.nvim",
            config = function()
                require("onenord").setup()
            end,
        },
    }
end

return M
