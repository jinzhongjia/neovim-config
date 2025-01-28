return
--- @type LazySpec
{
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
}
