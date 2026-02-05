return
--- @type LazySpec
{
    {
        "esmuellert/codediff.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = "CodeDiff",
        opts = {
            explorer = {
                view_mode = "tree",
            },
        },
    },
}
