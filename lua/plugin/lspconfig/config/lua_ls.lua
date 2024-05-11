local status, neodev = pcall(require, "neodev")
if not status then
    vim.notify("not found neodev.nvim")
    return
end

neodev.setup({
    -- add any options here, or leave empty to use the default settings
})

return {
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
}
