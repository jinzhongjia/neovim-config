return
--- @type LazySpec
{
    "goolord/alpha-nvim",
    dependencies = "echasnovski/mini.icons",
    enabled = not __TUI,
    config = function()
        require("alpha").setup(require("alpha.themes.startify").config)
    end,
}
