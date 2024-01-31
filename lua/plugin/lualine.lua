local status, lualine = pcall(require, "lualine")
if not status then
    vim.notify("not found lualine")
    return
end

vim.g.gitblame_display_virtual_text = 0

local LspUI = require("LspUI")
local git_blame = require("gitblame")

local is_insert = false
local is_blame = false

lualine.setup({
    sections = {
        lualine_x = {
            {
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
                color = { fg = "#ff9e64" },
            },
            "copilot",
            "encoding",
            "fileformat",
            "filetype",
        },
        lualine_c = {
            {
                function()
                    if is_insert then
                        local signature = LspUI.api.signature()
                        if not signature then
                            return ""
                        end
                        if not signature.hint then
                            return signature.label
                        end
                        local res = ""
                        for i, parameter in ipairs(signature.parameters) do
                            res = string.format("%s%s%s", res, parameter, i == #signature.parameters and "" or ", ")
                        end

                        return res
                    elseif is_blame then
                        return git_blame.get_current_blame_text()
                    end
                end,
                cond = function()
                    local mode_info = vim.api.nvim_get_mode()
                    local mode = mode_info["mode"]
                    is_insert = mode:find("i") ~= nil or mode:find("ic") ~= nil

                    local text = git_blame.get_current_blame_text()
                    if text then
                        is_blame = text ~= ""
                    else
                        is_blame = false
                    end

                    return is_insert or is_blame
                end,
            },
        },
    },
})
