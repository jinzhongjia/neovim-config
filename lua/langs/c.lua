return
--- @type LangSpec
{
    lsp = "clangd",
    opt = {
        cmd = { "clangd", "--offset-encoding=utf-16" },
        root_dir = function()
            return vim.fn.getcwd()
        end,
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    },
    others = { "clang-format" },
    before_set = nil,
    after_set = nil,
}
