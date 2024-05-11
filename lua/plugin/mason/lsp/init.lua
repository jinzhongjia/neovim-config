local list = require("plugin.lspconfig.list")
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

local alones = {}
local servers = {}
local installServers = {}

local default_config = require("plugin.lspconfig.default")

for _, ele in pairs(list) do
    if ele.enable or true then
        table.insert(installServers, ele.name)
        if ele.alone then
            table.insert(alones, ele.name)
        else
            table.insert(servers, ele.name)
        end
    end
end

local servers_handlers = {}

for _, value in pairs(servers) do
    local status, config = pcall(require, "plugin.lspconfig.config." .. value)
    if not status then
        config = {}
    end
    servers_handlers[value] = function()
        lspconfig[value].setup(vim.tbl_deep_extend("force", default_config(), config))
    end
end

mason_lspconfig.setup({
    ensure_installed = installServers,
    handlers = servers_handlers,
})

for _, ele in pairs(alones) do
    require("plugin.lspconfig.config." .. ele)
end
