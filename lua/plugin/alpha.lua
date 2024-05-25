local status, alpha = pcall(require, "alpha")
if not status then
    vim.notify("not found alpha")
    return
end
local api, fn, fs = vim.api, vim.fn, vim.fs

--- @type function
local generate_config

-- basic path for code
local project_path = "~/code"

--- @alias alpha_config_position "left"|"center"|"right"

--- @type alpha_config_position
local header_position = "center"
--- @type alpha_config_position
local project_position = "center"
--- @type alpha_config_position
local button_position = "center"

vim.api.nvim_set_hl(0, "NeovimDashboardLogo1", { fg = "#DA4939" })
vim.api.nvim_set_hl(0, "NeovimDashboardLogo2", { fg = "#FF875F" })
vim.api.nvim_set_hl(0, "NeovimDashboardLogo3", { fg = "#FFC66D" })
vim.api.nvim_set_hl(0, "NeovimDashboardLogo4", { fg = "#00FF03" })
vim.api.nvim_set_hl(0, "NeovimDashboardLogo5", { fg = "#00AFFF" })
vim.api.nvim_set_hl(0, "NeovimDashboardLogo6", { fg = "#8800FF" })

local header_content = {
    " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
}
local header_hl = {
    "NeovimDashboardLogo1",
    "NeovimDashboardLogo2",
    "NeovimDashboardLogo3",
    "NeovimDashboardLogo4",
    "NeovimDashboardLogo5",
    "NeovimDashboardLogo6",
}

local function Makeheader()
    local tbl = {}
    for i, v in ipairs(header_content) do
        tbl[i] = {
            type = "text",
            val = v,
            opts = { hl = header_hl[i], shrink_margin = false, position = header_position },
        }
    end
    return { type = "group", val = tbl }
end

local header = Makeheader()

--- @param key string
--- @param txt string
--- @param position string
--- @param callback function? optional
--- @param retain boolean?
local function button(key, txt, position, callback, retain)
    local sc_ = key:gsub("%s", ""):gsub("SPC", "<leader>")

    local opts = {
        position = position,
        shortcut = "[" .. key .. "] ",
        cursor = position == "left" and 1 or 2,
        width = 50,
        align_shortcut = (position == "left" and "left" or "right"),
        hl_shortcut = "Keyword",
    }

    local function on_press()
        if callback then
            if not retain then
                vim.api.nvim_buf_delete(0, {})
            end
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

--- @type integer
local project_index = 0

local project_length = 7

local function projects()
    local path = fn.expand(project_path)
    local iterator = fs.dir(path)
    local tbl, index = {}, 0
    while true do
        local filename, type = iterator()
        if not filename then
            break
        end
        if type == "directory" then
            -- if index >= project_index and index < project_length + project_index then
            tbl[index - project_index] = button(
                tostring(index),
                string.format(" %s", filename),
                project_position,
                function()
                    local path1 = string.format("%s/%s", project_path, filename)
                    local path2 = fn.expand(path1)
                    api.nvim_set_current_dir(path2)
                end
            )
            -- end
            index = index + 1
        end
    end
    -- tbl[index] = button("d", "next 7 page", project_position, function()
    --     if index % 7 == 0 then
    --         project_index = project_index + project_length
    --         alpha.redraw(generate_config())
    --     end
    -- end, true)
    -- tbl[index + 1] = button("u", "up 7 page", project_position, function()
    --     if 0 < index and index < project_length then
    --         project_index = 0
    --         alpha.redraw(generate_config())
    --     else
    --         project_index = project_index - project_length
    --         alpha.redraw(generate_config())
    --     end
    -- end, true)

    return { type = "group", val = tbl }
end

generate_config = function()
    local section_project = {
        type = "group",
        val = {
            {
                type = "text",
                val = " Projects ",
                opts = {
                    hl = "SpecialComment",
                    shrink_margin = false,
                    position = project_position,
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
            { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = button_position } },
            { type = "padding", val = 1 },
            button("e", " New file", button_position, function()
                vim.cmd([[ene]])
            end),
            button("c", " Configuration", button_position, function()
                local config_path = vim.fn.stdpath("config")
                ---@diagnostic disable-next-line: param-type-mismatch
                vim.fn.chdir(config_path)
                vim.api.nvim_command("bdelete")
            end),
            button("u", " Update plugins", button_position, function()
                vim.cmd([[Lazy sync]])
            end),
        },
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
        },
    }

    return theme
end

alpha.setup(generate_config())
