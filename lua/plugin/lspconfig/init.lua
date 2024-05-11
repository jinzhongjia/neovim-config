local status, lspconfig = pcall(require, "lspconfig")
if not status then
    vim.notify("not found lspconfig")
    return
end

local list = require("plugin.lspconfig.list")

local default_config = require("plugin.lspconfig.default")

for _, ele in pairs(list) do
    local cmd = ele.cmd or ele.name
    if check_exec(cmd) then
        local cmd_status, config = pcall(require, "plugin.lspconfig.config." .. ele.name)
        if not cmd_status then
            config = {}
        end

        lspconfig[ele.name].setup(vim.tbl_deep_extend("force", default_config(), config))
    end
end
