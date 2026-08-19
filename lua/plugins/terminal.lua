-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 浮动终端 — Snacks.terminal（替掉原来手写的 250 行实现）
-- snacks 按 count 区分终端实例：count=1..N 各自一个 buffer，
-- toggle 同一个 count 就是显示/隐藏同一个终端。
-- 窗口参数在这里按次传（不写进 styles.terminal）：claudecode 也用
-- Snacks.terminal，全局样式会连它右侧那个 split 一起改掉。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local MAX = 5 -- <leader>t1..t5，同时也是 ]/[ 循环的上界
local current = 1

local win = { position = "float", border = "rounded", width = 0.85, height = 0.8 }

-- create=false：只查不建，用来判断某个槽位是否已经有终端
local function get(id)
    return Snacks.terminal.get(nil, { count = id, create = false })
end

local function toggle(id)
    current = math.max(1, math.min(id or current, MAX))
    Snacks.terminal.toggle(nil, { count = current, win = win })
end

local function hide_current()
    local term = get(current)
    if term and term:win_valid() then
        term:hide()
    end
end

-- 切到下一个/上一个槽位：先收起当前的，再打开目标（没有就新建）
local function cycle(step)
    hide_current()
    current = (current - 1 + step) % MAX + 1
    Snacks.terminal.toggle(nil, { count = current, win = win })
end

-- 开一个新终端：占用第一个空槽位，满了就沿用当前的
local function new()
    for i = 1, MAX do
        if not get(i) then
            hide_current()
            toggle(i)
            return
        end
    end
    toggle()
end

local map = vim.keymap.set

map({ "n", "t" }, "<C-\\>", function()
    toggle()
end, { desc = "Terminal: Toggle" })

map("n", "<leader>tt", function()
    toggle()
end, { desc = "Terminal: Toggle" })
map("n", "<leader>tn", new, { desc = "Terminal: New" })
map("n", "<leader>t]", function()
    cycle(1)
end, { desc = "Terminal: Next" })
map("n", "<leader>t[", function()
    cycle(-1)
end, { desc = "Terminal: Prev" })

for i = 1, MAX do
    map("n", "<leader>t" .. i, function()
        toggle(i)
    end, { desc = "Terminal: Toggle #" .. i })
end

-- 终端内切下一个终端。不再映射 <C-[>：它在终端里就是 Esc，
-- 之前那份配置把它抢去当"上一个"，等于把 Esc 弄坏了。
map("t", "<C-]>", function()
    cycle(1)
end, { desc = "Terminal: Next" })

-- <Esc><Esc> 回 normal（snacks 的 terminal style 默认也是双击 Esc，
-- 这里显式补一条，免得以后它改默认值）；单个 Esc 留给终端里的程序
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: Exit to normal mode" })
