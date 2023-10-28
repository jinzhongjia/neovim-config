local theme = {
    {
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd("colorscheme kanagawa")
        end,
    },
    {
        "catppuccin/nvim",
        config = function()
            local catppuccin = require("catppuccin")

            catppuccin.setup({
                flavour = "mocha",
            })

            vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "projekt0n/github-nvim-theme",
        config = function()
            require("github-theme").setup({})
            vim.cmd("colorscheme github_dark_dimmed")
        end,
    },
    {
        "Mofiqul/vscode.nvim",
        config = function()
            local vscode = require("vscode")
            vscode.setup()
            vscode.load()
        end,
    },
    {
        "Everblush/nvim",
        config = function()
            vim.cmd("colorscheme everblush")
        end,
    },
    {
        "Mofiqul/adwaita.nvim",
        config = function()
            vim.g.adwaita_darker = false -- for darker version
            vim.g.adwaita_disable_cursorline = false -- to disable cursorline
            vim.g.adwaita_transparent = false -- makes the background transparent
            vim.cmd([[colorscheme adwaita]])
        end,
    },
    {
        "JoosepAlviste/palenightfall.nvim",
        config = function()
            require("palenightfall").setup()
        end,
    },
    {
        "Yagua/nebulous.nvim",
        config = function()
            -- more details, see github
            require("nebulous").setup({
                variant = "fullmoon",
            })
        end,
    },
    {
        "savq/melange-nvim",
        config = function()
            vim.cmd([[colorscheme melange]])
        end,
    },
    {
        "askfiy/visual_studio_code",
        config = function()
            vim.cmd([[colorscheme visual_studio_code]])
        end,
    },
    {
        "rockyzhang24/arctic.nvim",
        branch = "v2",
        dependencies = { "rktjmp/lush.nvim" },
        config = function()
            vim.cmd([[colorscheme arctic]])
        end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                --- @usage 'auto'|'main'|'moon'|'dawn'
                variant = "auto",
            })

            -- Set colorscheme after options
            vim.cmd("colorscheme rose-pine")
        end,
    },
    {
        "uloco/bluloco.nvim",
        enabled = true,
        dependencies = { "rktjmp/lush.nvim" },
        config = function()
            require("bluloco").setup({
                style = "auto", -- "auto" | "dark" | "light"
                transparent = false,
                italics = false,
                terminal = true, -- bluoco colors are enabled in gui terminals per default.
                guicursor = true,
            })

            vim.cmd[[colorscheme bluloco]]
        end,
    },
}
