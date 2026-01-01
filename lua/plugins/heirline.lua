return
--- @type LazySpec
{
    {
        "rebelot/heirline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local conditions = require("heirline.conditions")
            local utils = require("heirline.utils")

            local Align = { provider = "%=" }
            local Space = { provider = " " }

            local ViMode = {
                init = function(self)
                    self.mode = vim.fn.mode(1)
                end,
                static = {
                    mode_names = {
                        n = "NORMAL",
                        i = "INSERT",
                        v = "VISUAL",
                        V = "V-LINE",
                        ["\22"] = "V-BLOCK",
                        c = "COMMAND",
                        s = "SELECT",
                        S = "S-LINE",
                        ["\19"] = "S-BLOCK",
                        R = "REPLACE",
                        r = "REPLACE",
                        ["!"] = "SHELL",
                        t = "TERMINAL",
                    },
                },
                provider = function(self)
                    local mode_name = self.mode_names[self.mode] or self.mode or "UNKNOWN"
                    return " " .. mode_name .. " "
                end,
                hl = function(self)
                    local mode_colors = {
                        n = { fg = "#000000", bg = "#7aa2f7", bold = true },
                        i = { fg = "#000000", bg = "#9ece6a", bold = true },
                        v = { fg = "#000000", bg = "#bb9af7", bold = true },
                        V = { fg = "#000000", bg = "#bb9af7", bold = true },
                        ["\22"] = { fg = "#000000", bg = "#bb9af7", bold = true },
                        c = { fg = "#000000", bg = "#e0af68", bold = true },
                        s = { fg = "#000000", bg = "#f7768e", bold = true },
                        S = { fg = "#000000", bg = "#f7768e", bold = true },
                        ["\19"] = { fg = "#000000", bg = "#f7768e", bold = true },
                        R = { fg = "#000000", bg = "#e0af68", bold = true },
                        r = { fg = "#000000", bg = "#e0af68", bold = true },
                        ["!"] = { fg = "#000000", bg = "#f7768e", bold = true },
                        t = { fg = "#000000", bg = "#7aa2f7", bold = true },
                    }
                    return mode_colors[self.mode] or { fg = "#c0caf5", bg = "#1a1b26" }
                end,
                update = {
                    "ModeChanged",
                    pattern = "*:*",
                    callback = vim.schedule_wrap(function()
                        vim.cmd("redrawstatus")
                    end),
                },
            }

            local FileNameBlock = {
                init = function(self)
                    self.filename = vim.api.nvim_buf_get_name(0)
                end,
                hl = { fg = "#c0caf5", bg = "#1a1b26" },
                {
                    provider = function(self)
                        local filename = vim.fn.fnamemodify(self.filename, ":t")
                        if filename == "" or filename == nil then
                            return " [No Name] "
                        end
                        local modified = vim.bo.modified and " ● " or " "
                        return modified .. filename .. " "
                    end,
                },
            }

            local FileIcon = {
                init = function(self)
                    local filename = vim.api.nvim_buf_get_name(0)
                    local extension = vim.fn.fnamemodify(filename, ":e")
                    self.icon, self.icon_color =
                        require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
                end,
                provider = function(self)
                    return self.icon and (self.icon .. " ")
                end,
                hl = function(self)
                    return { fg = self.icon_color }
                end,
            }

            local FileType = {
                provider = function()
                    local ft = vim.bo.filetype
                    if ft == "" then
                        return ""
                    end
                    return " " .. ft:upper() .. " "
                end,
                hl = { fg = "#7aa2f7", bg = "#1a1b26" },
            }

            local Ruler = {
                provider = function()
                    local line = vim.api.nvim_win_get_cursor(0)[1]
                    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
                    local lines = vim.api.nvim_buf_line_count(0)
                    return string.format(" %d/%d:%d ", line, lines, col)
                end,
                hl = { fg = "#c0caf5", bg = "#1a1b26" },
            }

            -- 特殊窗口状态栏（NvimTree, Outline 等）
            local special_filetypes = {
                NvimTree = { icon = "", label = "NvimTree", bg = "#9ece6a" },
                Outline = { icon = "", label = "Outline", bg = "#7aa2f7" },
            }

            local SpecialStatusLine = {
                condition = function()
                    return conditions.buffer_matches({ filetype = vim.tbl_keys(special_filetypes) })
                end,
                {
                    provider = function()
                        local ft = vim.bo.filetype
                        local info = special_filetypes[ft] or { icon = "", label = ft, bg = "#7aa2f7" }
                        return " " .. info.icon .. " " .. info.label .. " "
                    end,
                    hl = function()
                        local ft = vim.bo.filetype
                        local info = special_filetypes[ft] or { bg = "#7aa2f7" }
                        return { fg = "#000000", bg = info.bg, bold = true }
                    end,
                },
                Align,
                {
                    provider = function()
                        local line = vim.api.nvim_win_get_cursor(0)[1]
                        local lines = vim.api.nvim_buf_line_count(0)
                        return string.format(" %d/%d ", line, lines)
                    end,
                    hl = { fg = "#c0caf5", bg = "#1a1b26" },
                },
            }

            -- 默认状态栏
            local DefaultStatusLine = {
                ViMode,
                Space,
                FileIcon,
                FileNameBlock,
                Align,
                FileType,
                Space,
                Ruler,
            }

            -- 主状态栏：根据 filetype 选择不同的状态栏
            local StatusLine = {
                hl = { bg = "#1a1b26" },
                fallthrough = false, -- 第一个匹配的条件生效
                SpecialStatusLine,
                DefaultStatusLine,
            }

            require("heirline").setup({
                statusline = StatusLine,
            })
        end,
    },
}
