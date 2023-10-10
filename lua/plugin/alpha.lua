if not vim.g.neovide then
    return
end

local status, alpha = pcall(require, "alpha")
if not status then
    vim.notify("not found alpha")
    return
end

local header = {
    type = "text",
    val = {
        [[                                  __]],
        [[     ___     ___    ___   __  __ /\_\    ___ ___]],
        [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\]],
        [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
        [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
    },
    opts = {
        position = "center",
        hl = "Type",
        -- wrap = "overflow";
    },
}

local function get_extension(fn)
    local match = fn:match("^.+(%..+)$")
    local ext = ""
    if match ~= nil then
        ext = match:sub(2)
    end
    return ext
end

local function icon(fn)
    local nwd = require("nvim-web-devicons")
    local ext = get_extension(fn)
    return nwd.get_icon(fn, ext, { default = true })
end

local theme = {
    layout = {
        { type = "padding", val = 2 },
        header,
        -- { type = "padding", val = 2 },
        -- section_mru,
        -- { type = "padding", val = 2 },
        -- buttons,
    },
    opts = {
        margin = 5,
        setup = function()
            vim.api.nvim_create_autocmd("DirChanged", {
                pattern = "*",
                group = "alpha_temp",
                callback = function()
                    require("alpha").redraw()
                end,
            })
        end,
    },
}

alpha.setup(theme)
