local status, mason = pcall(require, "mason")
if not status then
    vim.notify("not found mason")
    return
end

mason.setup()

require("plugin.mason.lsp")
-- require("plugin.mason.null-ls")