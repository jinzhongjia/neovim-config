return
--- @type LangSpec
{
    lsp = "buf_ls",
    opt = {
        -- Override PR #4179: 禁用客户端重用以修复启动问题
        -- https://github.com/neovim/nvim-lspconfig/pull/4179
        reuse_client = function()
            return false
        end,
    },
    others = { "buf" },
    before_set = nil,
    after_set = nil,
    lint = {},
}
