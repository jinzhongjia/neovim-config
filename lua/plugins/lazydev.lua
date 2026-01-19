return
--- @type LazySpec
{
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- 当检测到 'vim.uv' 时，加载 luvit 类型定义
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
            integrations = {
                lspconfig = true, -- 修正 lspconfig 对 LuaLS 的工作区管理
            },
        },
    },
}
