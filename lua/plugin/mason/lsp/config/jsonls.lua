local status, schemastore = pcall(require, "schemastore")
if not status then
    vim.notify("not found schemastore")
    return
end

local opt = {
    settings = {
        schemas = schemastore.json.schemas(),
    },
}

return opt
