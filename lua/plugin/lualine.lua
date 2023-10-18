local status, lualine = pcall(require, "lualine")
if not status then
    vim.notify("not found lualine")
    return
end

vim.g.gitblame_display_virtual_text = 0
local git_blame = require("gitblame")

lualine.setup({
    sections = {
        lualine_c = {
            { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
        },
    },
})
