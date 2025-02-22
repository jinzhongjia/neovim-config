return
--- @type LazySpec
{
    "goolord/alpha-nvim",
    dependencies = "echasnovski/mini.icons",
    event = "VIMEnter",
    enabled = (vim.g.neovide or vim.g.nvy) and true or false,
    config = function()
        require("alpha").setup(require("alpha.themes.startify").config)
    end,
}
