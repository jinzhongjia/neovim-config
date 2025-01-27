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
}
