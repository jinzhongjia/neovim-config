--- this file is configuration for langs plugins
--- @type LazySpec[]
local langs_plugins = {}

---@diagnostic disable-next-line: param-type-mismatch
local langs_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "langs"))
for file, _ in vim.fs.dir(langs_path) do
    local file_name = vim.fn.fnamemodify(file, ":t:r")
    --- @type LangSpec
    local lang = require("langs." .. file_name)
    if lang.plugins then
        table.insert(langs_plugins, lang.plugins)
    end
end

return langs_plugins
