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
event="VeryLazy",
config=function()

  require("plugin.wilder")
end
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
