-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline — lualine.nvim（主题用 vscode.nvim 自带的 lualine 主题）
-- 布局: [模式] [分支 diff | 文件] REC ……… [进度] [诊断 LSP 类型] [位置]
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ── LSP 进度缓存 ──────────────────────────────────────────────
-- 不能在 statusline 里调 vim.lsp.status()：它会消费进度队列，而
-- statusline 每次重绘都会执行，消息被第一次重绘吃掉后就消失了。
-- 这里从事件负载自建缓存，按 client + token 跟踪。
local progress = {} -- client_id -> token -> { name, title, message, percentage }

local function progress_text()
    local parts = {}
    for _, tokens in pairs(progress) do
        for _, t in pairs(tokens) do
            local s = t.name .. ": " .. (t.title or "")
            if t.message then
                s = s .. " " .. t.message
            end
            if t.percentage then
                s = s .. (" (%d%%)"):format(t.percentage)
            end
            parts[#parts + 1] = s
        end
    end
    -- 截断防刷屏；% 需转义，否则会被当成 statusline 语法
    return (vim.fn.strcharpart(table.concat(parts, "  "), 0, 60):gsub("%%", "%%%%"))
end

vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("SLProgress", { clear = true }),
    callback = function(args)
        local params = args.data and args.data.params
        local value = params and params.value
        if type(value) ~= "table" or params.token == nil then
            return
        end
        local cid = args.data.client_id
        progress[cid] = progress[cid] or {}
        if value.kind == "end" then
            progress[cid][params.token] = nil
            if next(progress[cid]) == nil then
                progress[cid] = nil
            end
        else
            if value.kind == "begin" then
                local client = vim.lsp.get_client_by_id(cid)
                progress[cid][params.token] = { name = client and client.name or "lsp", title = value.title }
            end
            local t = progress[cid][params.token]
            if not t then -- report 先于 begin，丢弃
                return
            end
            t.message = value.message or t.message
            t.percentage = value.percentage or t.percentage
        end
        require("lualine").refresh({ place = { "statusline" } })
    end,
})

-- mini.diff 的 hunk 统计（buffer 未 attach 时为 nil）
local function diff_source()
    local d = vim.b.minidiff_summary
    if d then
        return { added = d.add, modified = d.change, removed = d.delete }
    end
end

local function lsp_names()
    local names = {}
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        names[#names + 1] = c.name
    end
    return #names > 0 and (" " .. table.concat(names, " ")) or ""
end

-- 录制宏提示（showmode 已关，不提示会忘）
local function recording()
    local rec = vim.fn.reg_recording()
    return rec ~= "" and (" REC @" .. rec) or ""
end

require("lualine").setup({
    options = {
        theme = "vscode",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            { "branch", icon = "" },
            { "diff", source = diff_source },
        },
        lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            {
                "filename",
                path = 1,
                shorting_target = 40,
                symbols = { modified = "●", readonly = "", unnamed = "[No Name]" },
            },
            { recording, color = "DiagnosticError" },
        },
        lualine_x = {
            { progress_text, color = "Comment" },
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            { lsp_names, color = "Comment" },
            "filetype",
            -- 非常规编码/换行才显示
            {
                "encoding",
                cond = function()
                    return vim.bo.fileencoding ~= "" and vim.bo.fileencoding ~= "utf-8"
                end,
            },
            {
                "fileformat",
                symbols = { unix = "unix", dos = "dos", mac = "mac" },
                cond = function()
                    return vim.bo.fileformat ~= "unix"
                end,
            },
        },
        lualine_y = {},
        lualine_z = { "location", "progress" },
    },
    extensions = { "nvim-tree", "quickfix", "fugitive", "nvim-dap-ui" },
})

-- 这些事件不一定触发重绘，手动刷一下（LspProgress 在上面的缓存回调里刷）
local redraw_group = vim.api.nvim_create_augroup("SLRedraw", { clear = true })
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = redraw_group,
    callback = function()
        -- RecordingLeave 时 reg_recording() 还没清空，延后一拍
        vim.schedule(function()
            require("lualine").refresh({ place = { "statusline" } })
        end)
    end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniDiffUpdated",
    group = redraw_group,
    command = "redrawstatus",
})
