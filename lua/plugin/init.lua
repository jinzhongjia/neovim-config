local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- manage itself
    "folke/lazy.nvim",
    -- file explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "antosha417/nvim-lsp-file-operations",
            "echasnovski/mini.base16"
        },
        config = function()
            require("plugin.nvim-tree")
        end,
    },
    -- buffer line
    {
        "willothy/nvim-cokeline",
        event = "UIEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",       -- Required for v0.4.0+
            "nvim-tree/nvim-web-devicons", -- If you want devicons
            "famiu/bufdelete.nvim"
        },
        config = function()
            require("plugin.cokeline")
        end
    },
    -- status line
    {
        "nvim-lualine/lualine.nvim",
        event = "UIEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("plugin.lualine")
        end,
    },
    -- windows
    {
        "anuvyklack/windows.nvim",
        event = "VeryLazy",
        dependencies = "anuvyklack/middleclass",
        config = function()
            require("plugin.windows")
        end,
    },

    -- comment
    {
        "numToStr/Comment.nvim",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring"
        },
        event = "VeryLazy",
        config = function()
            require("plugin.Comment")
        end,
    },
    -- lsp progress
    {
        "j-hui/fidget.nvim",
        branch = "legacy",
        event = "VeryLazy",
        config = function()
            require("plugin.fidget")
        end,
    },

    -- lspui
    {
        "jinzhongjia/LspUI.nvim",
        branch = "v2",
        event = "VeryLazy",
        config = function()
            require("plugin.LspUI")
        end,
    },
    -- glance
    {
        "dnlhc/glance.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.glance")
        end,
    },
    -- symbol line
    {
        "stevearc/aerial.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.aerial")
        end,
    },
    -- floaterm
    {
        "voldikss/vim-floaterm",
        event = "VeryLazy",
        config = function()
            require("plugin.vim-floaterm")
        end
    },
    -- gitsigns
    {
        "lewis6991/gitsigns.nvim",
        enabled = true,
        event = "VeryLazy",
        config = function()
            require("plugin.gitsigns")
        end,
    },
    {
        "gelguy/wilder.nvim",
        event = "VeryLazy",
        build = ':UpdateRemotePlugins',
        config = function()
            require("plugin.wilder")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        event = "VeryLazy",
        build = ":TSUpdate",
        config = function()
            require("plugin.nvim-treesitter")
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.indent-blankline")
        end,
    },
    {
        "williamboman/mason.nvim",
        event = "VeryLazy",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason-lspconfig.nvim",
            "jose-elias-alvarez/null-ls.nvim",
            "jayp0521/mason-null-ls.nvim",
            "b0o/schemastore.nvim",
            "folke/neodev.nvim"
        },
        config = function()
            require("plugin.mason")
        end
    },

    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            --
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            --- ui denpendences
            "onsails/lspkind-nvim",
            --- autopairs
            "windwp/nvim-autopairs",
        },
        event = "VeryLazy",
        config = function()
            require("plugin.cmp")
        end,
    },

    -- fugitive
    {
        "tpope/vim-fugitive",
        event = "VeryLazy",
    },

    -- colorscheme
    {
        "rebelot/kanagawa.nvim",
        -- event = "UIEnter",
        config = function()
            vim.cmd("colorscheme kanagawa")
        end
    },
    {
        "catppuccin/nvim",
        enable = false,
        name = "catppuccin",
        priority = 1000
    }
})
