-- lualine 主题：与 vsmin 配色同源。lualine 每次 ColorScheme 都会
-- dofile 本文件，所以切换 'background' 后状态栏自动跟着换。
local c = require("vsmin.palette").get()

local theme = {
    inactive = {
        a = { fg = c.status_inactive, bg = c.panel, gui = "bold" },
        b = { fg = c.status_inactive, bg = c.panel },
        c = { fg = c.status_inactive, bg = c.panel },
    },
}

for mode, color in pairs(c.mode) do
    local bg, fg = color[1], color[2]
    theme[mode] = {
        a = { fg = fg, bg = bg, gui = "bold" },
        b = { fg = bg, bg = c.raised },
        c = { fg = c.fg, bg = c.panel },
    }
end

return theme
