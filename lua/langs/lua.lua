return
--- @type LangSpec
{
    lsp = "lua_ls",
    opt = {
        settings = {
            Lua = {
                hint = {
                    enable = true,
                    arrayIndex = "Enable",
                    setType = true,
                },
                workspace = {
                    checkThirdParty = false,
                },
            },
        },
    },
    others = { "stylua" },
    before_set = nil,
    after_set = nil,
    plugins = {
        {
            "folke/lazydev.nvim",
            ft = "lua", -- only load on lua files
            opts = {
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
    },
}
