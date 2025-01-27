return
--- @type LangSpec
{
    lsp = "clangd",
    opt = {
        cmd = { "clangd", "--offset-encoding=utf-16" },
        root_dir = function()
            return vim.fn.getcwd()
        end,
    },
    others = {},
    before_set = nil,
    after_set = nil,
}
