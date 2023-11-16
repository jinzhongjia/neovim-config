local status, mason = pcall(require, "mason")
if not status then
    vim.notify("not found mason")
    return
end

-- require the custom list
local list = require("plugin.mason.list")
local mason_registry = require("mason-registry")

mason.setup()

local ensure_installed = function()
    for _, name in pairs(list) do
        if not mason_registry.is_installed(name) then
            local package = mason_registry.get_package(name)
            package:install()
        end
    end
end

mason_registry.refresh(vim.schedule_wrap(ensure_installed))

require("plugin.mason.lsp")
