local status, lualine = pcall(require, "lualine")
if not status then
    vim.notify("not found lualine")
    return
end

vim.g.gitblame_display_virtual_text = 0

local git_blame = require("gitblame")

local lsp_signature_status, lsp_signature = pcall(require, "lsp_signature")

local is_insert = false
local is_blame = false
-- there is some problems
local previous_signature = nil

local blame_signature = {
    display = function()
        if is_insert and lsp_signature_status then
            -- there are some problems
            local sig = lsp_signature.status_line(75)
            if sig.label ~= "" then
                local text = string.format("%s🐼%s", sig.label, sig.hint)
                previous_signature = text
                return text
            end
            return previous_signature
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

        return (is_insert and lsp_signature_status) or is_blame
    end,
}

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
                -- git_blame.get_current_blame_text,
                blame_signature.display,
                cond = blame_signature.cond,
                -- cond = function()
                --     local text = git_blame.get_current_blame_text()
                --     if text then
                --         return text ~= ""
                --     end
                --     return false
                -- end,
            },
        },
    },
})
