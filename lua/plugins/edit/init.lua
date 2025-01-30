return
--- @type LazySpec
{
    require("plugins.edit.complete"),
    require("plugins.edit.search"),
    require("plugins.edit.fold"),
    require("plugins.edit.indent"),
    require("plugins.edit.format"),
    require("plugins.edit.lint"),
    require("plugins.edit.outline"),
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
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
        opts = {},
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = "VeryLazy",
        opts = {},
    },
    {
        "chrisgrieser/nvim-rip-substitute",
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
}
