local mason_null_ls = require("mason-null-ls")
local null_ls = require("null-ls")

local list = require("plugin.mason.null-ls.list")

--- @type string[]
local ensure_installed = {}
local handlers = {
    function() end,
}

for _, val in pairs(list) do
    if val.auto_install then
        table.insert(ensure_installed, val.name)
    end
    handlers[val.name] = function()
        for _, method in pairs(val.methods) do
            null_ls.register(null_ls.builtins[method][val.name])
        end
    end
end

mason_null_ls.setup({
    ensure_installed = ensure_installed,
    automatic_installation = true,
    handlers = handlers,
})

null_ls.setup()
