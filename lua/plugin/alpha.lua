if not vim.g.neovide then
    return
end

local status, alpha = pcall(require, "alpha")
if not status then
    vim.notify("not found alpha")
    return
end

local base_path = "~/code"

local header = {
    type = "text",
    val = {
        [[                                  __                   ]],
        [[     ___     ___    ___   __  __ /\_\    ___ ___       ]],
        [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\     ]],
        [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \    ]],
        [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\   ]],
        [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/   ]],
    },
    opts = {
        position = "center",
        hl = "Type",
        -- wrap = "overflow";
    },
}

-- local function get_extension(fn)
--     local match = fn:match("^.+(%..+)$")
--     local ext = ""
--     if match ~= nil then
--         ext = match:sub(2)
--     end
--     return ext
-- end
--
-- local function icon(fn)
--     local nwd = require("nvim-web-devicons")
--     local ext = get_extension(fn)
--     return nwd.get_icon(fn, ext, { default = true })
-- end

--- @param key string
--- @param txt string
--- @param callback function? optional
local function button(key, txt, callback)
    local sc_ = key:gsub("%s", ""):gsub("SPC", "<leader>")

    local opts = {
        position = "center",
        shortcut = key,
        cursor = 3,
        width = 50,
        align_shortcut = "right",
        hl_shortcut = "Keyword",
    }

    local function on_press()
        if callback then
            vim.api.nvim_buf_delete(0, {})

            callback()
        end
    end
    local keybind_opts = { noremap = true, silent = true, nowait = true, callback = on_press }
    opts.keymap = { "n", sc_, "", keybind_opts }

    return {
        type = "button",
        val = txt,
        on_press = on_press,
        opts = opts,
    }
end

local function projects()
    local iterator = vim.fs.dir(base_path)

    local tbl = {}
    local index = 0
    while true do
        local filename, type = iterator()
        if not filename then
            break
        end
        if type == "directory" then
            tbl[index] = button(tostring(index), "  " .. filename, function()
                vim.api.nvim_set_current_dir(string.format("%s/%s", base_path, filename))
            end)
            index = index + 1
        end
    end

    return {
        type = "group",
        val = tbl,
        opts = {},
    }
end

local section_project = {
    type = "group",
    val = {
        {
            type = "text",
            val = "Projects",
            opts = {
                hl = "SpecialComment",
                shrink_margin = false,
                position = "center",
            },
        },
        { type = "padding", val = 1 },
        {
            type = "group",
            val = function()
                return { projects() }
            end,
            opts = { shrink_margin = false },
        },
    },
}

local buttons = {
    type = "group",
    val = {
        { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
        { type = "padding", val = 1 },
        button("e", "  New file", function()
            vim.cmd([[ene]])
        end),
        button("c", "  Configuration", function()
            vim.cmd([[cd ~/.config/nvim/]])
        end),
        button("u", "  Update plugins", function()
            vim.cmd([[Lazy sync]])
        end),
    },
    position = "center",
}

local theme = {
    layout = {
        { type = "padding", val = 2 },
        header,
        { type = "padding", val = 2 },
        section_project,
        { type = "padding", val = 2 },
        buttons,
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
