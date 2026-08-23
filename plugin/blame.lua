-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- lineblame — 当前行 git blame 虚拟文本（GitLens 风格,零依赖）
-- 光标停在某行 500ms 后,行尾显示「作者, 相对时间 • 提交摘要」。
-- blame 走 --contents - 把 buffer 内容喂给 git,未保存的修改也能对上行号。
-- <leader>Gv 或 :BlameToggle 开关。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local api = vim.api
local uv = vim.loop

local enabled = true
local DELAY = 500

local namespace = api.nvim_create_namespace("lineblame")
api.nvim_set_hl(0, "LineBlame", { default = true, link = "Comment" })

-- blame 结果缓存:[bufnr] = { tick = changedtick, lines = { [lnum] = text } }
local cache = {}
-- [bufnr] = false 表示该 buffer 不可 blame(不在仓库/未跟踪),避免反复起进程
local blameable = {}
-- 当前已显示的标注,光标在同一行内移动时保留不闪
local shown = {}
local generation = 0
local timer

local function relative_time(ts)
    if not ts then
        return ""
    end
    local diff = os.time() - ts
    if diff < 60 then
        return "刚刚"
    elseif diff < 3600 then
        return math.floor(diff / 60) .. " 分钟前"
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. " 小时前"
    elseif diff < 86400 * 30 then
        return math.floor(diff / 86400) .. " 天前"
    elseif diff < 86400 * 365 then
        return math.floor(diff / (86400 * 30)) .. " 个月前"
    end
    return math.floor(diff / (86400 * 365)) .. " 年前"
end

local function parse_porcelain(stdout)
    local sha = stdout:match("^(%x+) ")
    if not sha then
        return nil
    end
    if sha:match("^0+$") then
        return "未提交的修改"
    end
    local author = stdout:match("\nauthor ([^\n]+)") or "?"
    local time = tonumber(stdout:match("\nauthor%-time (%d+)"))
    local summary = stdout:match("\nsummary ([^\n]+)") or ""
    return string.format("%s, %s • %s", author, relative_time(time), summary)
end

local function can_blame(bufnr)
    return blameable[bufnr] ~= false
        and vim.bo[bufnr].buftype == ""
        and api.nvim_buf_get_name(bufnr) ~= ""
end

local function clear(bufnr)
    if api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
    shown = {}
end

local function set_text(bufnr, lnum, tick, text)
    local ok = pcall(api.nvim_buf_set_extmark, bufnr, namespace, lnum - 1, 0, {
        virt_text = { { "  " .. text, "LineBlame" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
    })
    if ok then
        shown = { buf = bufnr, lnum = lnum, tick = tick }
    end
end

local function show_blame(bufnr, lnum, tick)
    -- 回调时机校验:buffer/行/内容任一变了就作废,等下一次触发
    local function still_current()
        return api.nvim_buf_is_valid(bufnr)
            and api.nvim_get_current_buf() == bufnr
            and api.nvim_buf_get_changedtick(bufnr) == tick
            and api.nvim_win_get_cursor(0)[1] == lnum
            and not vim.fn.mode():match("^i")
    end

    local c = cache[bufnr]
    if c and c.tick == tick and c.lines[lnum] then
        set_text(bufnr, lnum, tick, c.lines[lnum])
        return
    end

    generation = generation + 1
    local gen = generation
    local fname = api.nvim_buf_get_name(bufnr)
    local content = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"

    vim.system({
        "git",
        "-C",
        vim.fn.fnamemodify(fname, ":h"),
        "blame",
        "-L",
        lnum .. "," .. lnum,
        "--porcelain",
        "--contents",
        "-",
        "--",
        fname,
    }, { stdin = content, text = true }, function(res)
        vim.schedule(function()
            if gen ~= generation or not enabled or not api.nvim_buf_is_valid(bufnr) then
                return
            end
            if res.code ~= 0 then
                -- 不在 git 仓库或文件未跟踪:整个 buffer 关掉,写盘后再重新探测
                blameable[bufnr] = false
                return
            end
            local text = parse_porcelain(res.stdout or "")
            if not text then
                return
            end
            if not cache[bufnr] or cache[bufnr].tick ~= tick then
                cache[bufnr] = { tick = tick, lines = {} }
            end
            cache[bufnr].lines[lnum] = text
            if still_current() then
                set_text(bufnr, lnum, tick, text)
            end
        end)
    end)
end

local function cancel_timer()
    if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
    end
    timer = nil
end

local function on_move()
    local bufnr = api.nvim_get_current_buf()
    if not enabled or not can_blame(bufnr) then
        return
    end

    local lnum = api.nvim_win_get_cursor(0)[1]
    local tick = api.nvim_buf_get_changedtick(bufnr)
    -- 同一行内移动(列变化)保留现有标注,不闪
    if shown.buf == bufnr and shown.lnum == lnum and shown.tick == tick then
        return
    end

    clear(bufnr)
    cancel_timer()
    timer = uv.new_timer()
    if not timer then
        return
    end
    timer:start(DELAY, 0, function()
        cancel_timer()
        vim.schedule(function()
            if enabled and not vim.fn.mode():match("^i") then
                show_blame(bufnr, lnum, tick)
            end
        end)
    end)
end

local function toggle()
    enabled = not enabled
    if enabled then
        on_move()
    else
        cancel_timer()
        clear(api.nvim_get_current_buf())
    end
    vim.notify("Line blame: " .. (enabled and "on" or "off"))
end

api.nvim_create_user_command("BlameToggle", toggle, { desc = "Toggle line blame virtual text" })
vim.keymap.set("n", "<leader>Gv", toggle, { desc = "Blame virtual text (toggle)" })

local augroup = api.nvim_create_augroup("LineBlame", { clear = true })

api.nvim_create_autocmd({ "CursorMoved", "TextChanged", "InsertLeave", "BufEnter" }, {
    group = augroup,
    callback = on_move,
})

-- 插入模式下不显示,避免和补全/ghost text 挤在一起
api.nvim_create_autocmd("InsertEnter", {
    group = augroup,
    callback = function()
        cancel_timer()
        clear(api.nvim_get_current_buf())
    end,
})

-- 写盘后重新探测可 blame 状态(新文件首次 commit 后就能 blame 了)
api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    callback = function(args)
        blameable[args.buf] = nil
    end,
})

api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    callback = function(args)
        cache[args.buf] = nil
        blameable[args.buf] = nil
    end,
})
