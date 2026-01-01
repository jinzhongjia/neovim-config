return
--- @type LazySpec
{
    {
        "rebelot/heirline.nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
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

            -- CodeCompanion 专用状态栏
            local CodeCompanionStatusLine = {
                condition = function()
                    return conditions.buffer_matches({ filetype = { "codecompanion" } })
                end,
                -- 左侧：CodeCompanion 标签
                {
                    provider = " 󰚩 CodeCompanion ",
                    hl = { fg = "#000000", bg = "#bb9af7", bold = true },
                },
                Space,
                -- 模型名称
                {
                    provider = function()
                        local bufnr = vim.api.nvim_get_current_buf()
                        local metadata = _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[bufnr]
                        if metadata and metadata.model then
                            return "󰘦 " .. metadata.model .. " "
                        end
                        return ""
                    end,
                    hl = { fg = "#7aa2f7", bg = "#1a1b26" },
                },
                Align,
                -- Tokens 数量
                {
                    provider = function()
                        local bufnr = vim.api.nvim_get_current_buf()
                        local metadata = _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[bufnr]
                        if metadata and metadata.tokens then
                            return "󰆾 " .. metadata.tokens .. " "
                        end
                        return ""
                    end,
                    hl = { fg = "#9ece6a", bg = "#1a1b26" },
                },
                -- 行号信息
                {
                    provider = function()
                        local line = vim.api.nvim_win_get_cursor(0)[1]
                        local lines = vim.api.nvim_buf_line_count(0)
                        return string.format(" %d/%d ", line, lines)
                    end,
                    hl = { fg = "#c0caf5", bg = "#1a1b26" },
                },
            }

            -- 特殊窗口状态栏（NvimTree, Outline, OpenCode, Neogit 等）
            local special_filetypes = {
                NvimTree = { icon = "", label = "NvimTree", bg = "#9ece6a" },
                Outline = { icon = "", label = "Outline", bg = "#7aa2f7" },
                opencode = { icon = "", label = "OpenCode", bg = "#f7768e" },
                opencode_output = { icon = "", label = "OpenCode Output", bg = "#e0af68" },
                NeogitStatus = { icon = "", label = "Neogit", bg = "#f5a97f" },
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
                CodeCompanionStatusLine,
                SpecialStatusLine,
                DefaultStatusLine,
            }

            -- Winbar: 显示文件路径和代码位置（navic）
            local Navic = {
                condition = function()
                    local navic = require("nvim-navic")
                    return navic.is_available()
                end,
                provider = function()
                    local navic = require("nvim-navic")
                    return navic.get_location({ highlight = true })
                end,
                update = "CursorMoved",
            }

            local WinbarFileName = {
                init = function(self)
                    self.filename = vim.api.nvim_buf_get_name(0)
                end,
                {
                    provider = function(self)
                        local filename = vim.fn.fnamemodify(self.filename, ":.")
                        if filename == "" then
                            return ""
                        end
                        -- 截断过长的路径
                        if not conditions.width_percent_below(#filename, 0.4) then
                            filename = vim.fn.pathshorten(filename)
                        end
                        return filename
                    end,
                    hl = { fg = "#7aa2f7" },
                },
            }

            -- 判断是否为真实文件
            local function is_real_file()
                local bufname = vim.api.nvim_buf_get_name(0)
                local buftype = vim.bo.buftype
                local filetype = vim.bo.filetype

                -- 必须有文件名
                if bufname == "" then
                    return false
                end

                -- buftype 必须为空（普通文件）
                if buftype ~= "" then
                    return false
                end

                -- 排除特殊 filetype
                local excluded_ft = vim.tbl_keys(special_filetypes)
                vim.list_extend(excluded_ft, { "gitcommit", "gitrebase", "hgcommit" })
                if vim.tbl_contains(excluded_ft, filetype) then
                    return false
                end

                return true
            end

            local WinBar = {
                -- 只在真实文件中显示 winbar
                condition = is_real_file,
                WinbarFileName,
                {
                    condition = function()
                        local navic = require("nvim-navic")
                        return navic.is_available() and navic.get_location() ~= ""
                    end,
                    provider = " › ",
                    hl = { fg = "#565f89" },
                },
                Navic,
            }

            require("heirline").setup({
                statusline = StatusLine,
                winbar = WinBar,
                opts = {
                    disable_winbar_cb = function(args)
                        -- 禁用 winbar 的条件（返回 true 则禁用）
                        local bufname = vim.api.nvim_buf_get_name(args.buf)
                        local buftype = vim.bo[args.buf].buftype
                        local filetype = vim.bo[args.buf].filetype

                        -- 无文件名
                        if bufname == "" then
                            return true
                        end

                        -- 非普通 buffer
                        if buftype ~= "" then
                            return true
                        end

                        -- 特殊 filetype
                        local excluded_ft = vim.tbl_keys(special_filetypes)
                        vim.list_extend(excluded_ft, { "gitcommit", "gitrebase", "hgcommit", "codecompanion" })
                        if vim.tbl_contains(excluded_ft, filetype) then
                            return true
                        end

                        return false
                    end,
                },
            })
        end,
    },
}
