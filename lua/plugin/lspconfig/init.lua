local status, lspconfig = pcall(require, "lspconfig")
if not status then
    vim.notify("not found lspconfig")
    return
end

local list = require("plugin.lspconfig.list")

local default_config = require("plugin.mason.lsp.default")

--- @param name string
local check_function = function(name)
    return vim.fn.executable(name) == 1
end

for _, ele in pairs(list) do
    local cmd = ele.cmd or ele.name
    if check_function(cmd) then
        local cmd_status, config = pcall(require, "plugin.mason.lsp.config." .. ele.name)
        if not cmd_status then
            config = {}
        end

        lspconfig[ele.name].setup(vim.tbl_deep_extend("force", default_config(), config))
    end
end
