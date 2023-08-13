local status, mason = pcall(require, "mason")
if not status then
	vim.notify("not found mason")
	return
end

local mason_registry = require("mason-registry")
local list = require("plugin.mason.list")

mason.setup()

for _, name in pairs(list) do
	if not mason_registry.is_installed(name) then
		local package = mason_registry.get_package(name)
		package:install()
	end
end

require("plugin.mason.lsp")
-- require("plugin.mason.null-ls")
