-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline — built-in, colored segments (no lualine)
-- 布局: [模式] [ 分支  文件 ●] ……… [进度] [诊断 LSP 类型] [位置]
-- 配色对齐 vscode.nvim dark
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local palette = {
    black = "#1e1e1e",
    bg = "#2d2d30",
    fg = "#cccccc",
    dim = "#808080",
    blue = "#569cd6",
    green = "#6a9955",
    teal = "#4ec9b0",
    purple = "#c586c0",
    red = "#f44747",
    orange = "#ce9178",
    yellow = "#dcdcaa",
    warn = "#cca700",
    info = "#3794ff",
    hint = "#b0b0b0",
}

local function set_hl()
    local hl = function(name, opts)
        vim.api.nvim_set_hl(0, name, opts)
    end
    -- 模式色块（右侧位置块共用）
    hl("SLModeN", { fg = palette.black, bg = palette.blue, bold = true })
    hl("SLModeI", { fg = palette.black, bg = palette.teal, bold = true })
    hl("SLModeV", { fg = palette.black, bg = palette.purple, bold = true })
    hl("SLModeR", { fg = palette.black, bg = palette.red, bold = true })
    hl("SLModeC", { fg = palette.black, bg = palette.yellow, bold = true })
    hl("SLModeT", { fg = palette.black, bg = palette.orange, bold = true })
    -- 灰色信息段及其内部着色
    hl("SLSection", { fg = palette.fg, bg = palette.bg })
    hl("SLDim", { fg = palette.dim, bg = palette.bg })
    hl("SLGit", { fg = palette.orange, bg = palette.bg })
    hl("SLModified", { fg = palette.orange, bg = palette.bg, bold = true })
    hl("SLDiagError", { fg = palette.red, bg = palette.bg })
    hl("SLDiagWarn", { fg = palette.warn, bg = palette.bg })
    hl("SLDiagInfo", { fg = palette.info, bg = palette.bg })
    hl("SLDiagHint", { fg = palette.hint, bg = palette.bg })
    hl("SLDiffAdd", { fg = palette.green, bg = palette.bg })
    hl("SLDiffChange", { fg = palette.warn, bg = palette.bg })
    hl("SLDiffDelete", { fg = palette.red, bg = palette.bg })
    -- 透明背景（中段）上的元素
    hl("SLProgress", { fg = palette.dim })
    hl("SLRec", { fg = palette.black, bg = palette.red, bold = true })
end

set_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("SLHighlights", { clear = true }),
    callback = set_hl,
})

-- 模式 → 标签 + 高亮组（按首字节归类）
local modes = {
    ["n"] = { "NORMAL", "SLModeN" },
    ["i"] = { "INSERT", "SLModeI" },
    ["v"] = { "VISUAL", "SLModeV" },
    ["V"] = { "V-LINE", "SLModeV" },
    ["\22"] = { "V-BLOCK", "SLModeV" },
    ["s"] = { "SELECT", "SLModeV" },
    ["S"] = { "S-LINE", "SLModeV" },
    ["\19"] = { "S-BLOCK", "SLModeV" },
    ["R"] = { "REPLACE", "SLModeR" },
    ["c"] = { "COMMAND", "SLModeC" },
    ["r"] = { "PROMPT", "SLModeC" },
    ["!"] = { "SHELL", "SLModeC" },
    ["t"] = { "TERMINAL", "SLModeT" },
}

local diag_defs = {
    { vim.diagnostic.severity.ERROR, " ", "SLDiagError" },
    { vim.diagnostic.severity.WARN, " ", "SLDiagWarn" },
    { vim.diagnostic.severity.INFO, " ", "SLDiagInfo" },
    { vim.diagnostic.severity.HINT, " ", "SLDiagHint" },
}

-- devicons 图标色随文件类型走，高亮组按颜色缓存
local icon_groups = {}
local function file_icon()
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if not ok then
        return ""
    end
    local name = vim.fn.expand("%:t")
    local icon, color = devicons.get_icon_color(name, vim.fn.fnamemodify(name, ":e"), { default = true })
    if not icon then
        return ""
    end
    local group = "SLIcon" .. color:sub(2)
    if not icon_groups[group] then
        vim.api.nvim_set_hl(0, group, { fg = color, bg = palette.bg })
        icon_groups[group] = true
    end
    return "%#" .. group .. "#" .. icon .. " %#SLSection#"
end

local function git_branch()
    local ok, branch = pcall(vim.fn.FugitiveHead)
    return ok and branch or ""
end

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
    return table.concat(parts, "  ")
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
        vim.cmd.redrawstatus()
    end,
})

function _G.statusline()
    local mode = vim.api.nvim_get_mode().mode
    local m = modes[mode:sub(1, 1)] or { mode:upper(), "SLModeN" }

    -- 文件树窗口给个极简版
    if vim.bo.filetype == "NvimTree" then
        return "%#" .. m[2] .. "# " .. m[1] .. " %#SLSection#  Explorer %#StatusLine#"
    end

    local s = {}
    local add = function(part)
        s[#s + 1] = part
    end

    -- ── 左:模式块 ──
    add("%#" .. m[2] .. "# " .. m[1] .. " ")

    -- ── 左:分支 + 文件 ──
    add("%#SLSection# ")
    local branch = git_branch()
    if branch ~= "" then
        add("%#SLGit# " .. branch .. " ")
        -- mini.diff 的 hunk 统计（buffer 未 attach 时为 nil）
        local diff = vim.b.minidiff_summary
        if diff then
            if (diff.add or 0) > 0 then
                add("%#SLDiffAdd#+" .. diff.add .. " ")
            end
            if (diff.change or 0) > 0 then
                add("%#SLDiffChange#~" .. diff.change .. " ")
            end
            if (diff.delete or 0) > 0 then
                add("%#SLDiffDelete#-" .. diff.delete .. " ")
            end
        end
        add("%#SLDim#│%#SLSection# ")
    end
    if vim.bo.buftype == "terminal" then
        add(" terminal ")
    else
        add(file_icon())
        local path = vim.fn.expand("%:.")
        add((path == "" and "[No Name]" or vim.fn.pathshorten(path)) .. " ")
        if vim.bo.modified then
            add("%#SLModified#● ")
        end
        if vim.bo.readonly then
            add("%#SLDim# ")
        end
    end
    add("%#StatusLine#%<")

    -- 录制宏提示（showmode 已关，不提示会忘）
    local rec = vim.fn.reg_recording()
    if rec ~= "" then
        add(" %#SLRec#  REC @" .. rec .. " %#StatusLine#")
    end

    add("%=")

    -- ── 右:LSP 进度（截断防刷屏）──
    local prog = progress_text()
    if prog ~= "" then
        add("%#SLProgress#" .. vim.fn.strcharpart(prog, 0, 60) .. " ")
    end

    -- ── 右:诊断 + LSP + 文件类型 ──
    add("%#SLSection# ")
    local counts = vim.diagnostic.count(0)
    for _, d in ipairs(diag_defs) do
        if counts[d[1]] then
            add("%#" .. d[3] .. "#" .. d[2] .. counts[d[1]] .. " ")
        end
    end
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        local names = {}
        for _, c in ipairs(clients) do
            names[#names + 1] = c.name
        end
        add("%#SLDim# " .. table.concat(names, " ") .. " ")
    end
    if vim.bo.filetype ~= "" then
        add("%#SLSection#" .. vim.bo.filetype .. " ")
    end
    -- 非常规编码/换行才显示
    if vim.bo.fileencoding ~= "" and vim.bo.fileencoding ~= "utf-8" then
        add("%#SLDim#" .. vim.bo.fileencoding .. " ")
    end
    if vim.bo.fileformat ~= "unix" then
        add("%#SLDim#" .. vim.bo.fileformat .. " ")
    end

    -- ── 右:位置块（与模式同色）──
    add("%#" .. m[2] .. "#  %l:%c  %p%% ")

    return table.concat(s)
end

vim.o.statusline = "%!v:lua.statusline()"

-- 这些事件不一定触发重绘，手动刷一下（LspProgress 在上面的缓存回调里刷）
local redraw_group = vim.api.nvim_create_augroup("SLRedraw", { clear = true })
vim.api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged", "RecordingEnter", "RecordingLeave" }, {
    group = redraw_group,
    command = "redrawstatus",
})
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniDiffUpdated",
    group = redraw_group,
    command = "redrawstatus",
})
