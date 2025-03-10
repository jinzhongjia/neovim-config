--- @type LazySpec
local M = {

    {
        "m-demare/hlargs.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "RRethy/vim-illuminate",
        event = "VeryLazy",
        config = function()
            require("illuminate").configure({
                filetypes_denylist = {
                    "dirbuf",
                    "dirvish",
                    "fugitive",
                    "NvimTree",
                    "Outline",
                    "LspUI-rename",
                    "LspUI-diagnostic",
                    "LspUI-code_action",
                    "LspUI-definition",
                    "LspUI-type_definition",
                    "LspUI-declaration",
                    "LspUI-reference",
                    "LspUI-implementation",
                    "mason",
                    "floaterm",
                    "lazy",
                    "alpha",
                },
            })
        end,
    },
    {
        "Wansmer/treesj",
        event = "VeryLazy",
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
        opts = {},
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = "VeryLazy",
        opts = {
            filetypes = {
                "css",
                "javascript",
                "html",
            },
        },
    },
    {
        "chrisgrieser/nvim-rip-substitute",
        event = "VeryLazy",
        cmd = "RipSubstitute",
        opts = {},
        keys = {
            {
                "<leader>rs",
                function()
                    require("rip-substitute").sub()
                end,
                mode = { "n", "x" },
                desc = "rip substitute",
            },
        },
    },
    {
        "echasnovski/mini.move",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        opts = {},
    },
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "VeryLazy",
        config = true,
    },
}

-- all plugins
__arr_concat(M, require("plugins.edit.comment"))
__arr_concat(M, require("plugins.edit.complete"))
__arr_concat(M, require("plugins.edit.fold"))
__arr_concat(M, require("plugins.edit.format"))
__arr_concat(M, require("plugins.edit.indent"))
__arr_concat(M, require("plugins.edit.lint"))
__arr_concat(M, require("plugins.edit.outline"))
__arr_concat(M, require("plugins.edit.search"))
__arr_concat(M, require("plugins.edit.snippet"))
__arr_concat(M, require("plugins.edit.dap"))

return M
