if vim.g.vscode then
    -- this for vscode
    require("code")

    return
end
-- this will be the first file to be loaded
require("core")

-- this is plugin load
require("plugin")
