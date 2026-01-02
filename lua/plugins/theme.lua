return
--- @type LazySpec
{
    {
        "Mofiqul/vscode.nvim",
        priority = 1000,
        opts = {
            italic_comments = true,
            italic_inlayhints = true,
            underline_links = true,
            disable_nvimtree_bg = true,
            terminal_colors = true,
        },
        config = function(_, opts)
            require("vscode").setup(opts)
            require("vscode").load()
        end,
    },
    
}
