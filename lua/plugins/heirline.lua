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
                    return " " .. self.mode_names[self.mode] .. " "
                end,
                hl = function(self)
                    local mode_color = {
                        n = "red",
                        i = "green",
                        v = "cyan",
                        V = "cyan",
                        ["\22"] = "cyan",
                        c = "orange",
                        s = "purple",
                        S = "purple",
                        ["\19"] = "purple",
                        R = "orange",
                        r = "orange",
                        ["!"] = "red",
                        t = "red",
                    }
                    return { fg = mode_color[self.mode], bold = true }
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
                hl = { fg = "white" },
                {
                    provider = function(self)
                        local filename = vim.fn.fnamemodify(self.filename, ":t")
                        if filename == "" or filename == nil then
                            return " [No Name] "
                        end
                        return " " .. filename .. " "
                    end,
                },
            }

            local FileType = {
                provider = function()
                    local ft = vim.bo.filetype
                    if ft == "" then
                        return ""
                    end
                    return " " .. ft .. " "
                end,
                hl = { fg = "white", bg = "blue" },
            }

            local Ruler = {
                provider = function()
                    return " %3l:%-2c "
                end,
                hl = { fg = "white", bg = "black" },
            }

            local StatusLine = {
                ViMode,
                FileNameBlock,
                { provider = "%=" },
                FileType,
                Ruler,
            }

            require("heirline").setup({
                statusline = StatusLine,
            })
        end,
    },
}
