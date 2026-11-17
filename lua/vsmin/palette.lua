-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- vsmin 调色板 — VS Code Dark/Light Modern 的取色，按语义命名。
-- 深色沿用之前 vscode.nvim 的观感；浅色按 VS Code Light+ 校正过
-- （行号、常量、类型、标签等 vscode.nvim 里偏差较大的颜色）。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}

M.dark = {
    -- 界面
    bg = "#1F1F1F",
    fg = "#D4D4D4",
    fg_dim = "#BBBBBB", -- 弹窗正文、次要文字
    muted = "#8C8C8C", -- 路径、被忽略的文件
    faint = "#5A5A5A", -- 不可见字符、缩进引导符
    float = "#202020", -- 浮窗 / 补全菜单背景
    panel = "#252526", -- 标签栏留白、非活动状态栏
    panel_hi = "#2D2D2D", -- 非当前标签
    raised = "#373737", -- 状态栏
    line = "#282828", -- 光标行
    column = "#262626", -- colorcolumn
    border = "#444444",
    line_nr = "#6E7681",
    line_nr_cur = "#CCCCCC",
    indent = "#404040",
    indent_scope = "#707070",
    selection = "#264F78",
    search = "#613315",
    search_cur = "#9E6A03",
    match_paren = "#51504F",
    reference = "#343B41", -- 光标下符号的引用
    fold = "#202D39",
    ghost = "#6A6A6A", -- inlay hint、幽灵补全
    menu_sel = "#04395E",
    menu_sbar = "#2A2A2A",
    menu_thumb = "#5A5A5A",
    accent = "#0A7ACA",
    match = "#18A2FE", -- 模糊匹配命中的字符
    heading_bg = "#2A2D2E",
    stopped = "#4C4C19", -- 调试停靠行

    -- Diff
    diff_add = "#373D29",
    diff_add_hi = "#4B5632",
    diff_del = "#4B1818",
    diff_del_hi = "#6F1313",
    diff_change = "#23303D",
    diff_text = "#36506B",

    -- Git
    git_add = "#81B88B",
    git_change = "#E2C08D",
    git_delete = "#C74E39",
    git_new = "#73C991",
    git_conflict = "#E4676B",

    -- 诊断
    error = "#F44747",
    warn = "#CCA700",
    info = "#3794FF",
    hint = "#4EC9B0",
    ok = "#73C991",
    unused = "#729DB3",

    -- 语法
    comment = "#6A9955",
    keyword = "#569CD6", -- 声明类关键字、内建常量
    control = "#C586C0", -- 流程控制 / import
    func = "#DCDCAA",
    type = "#4EC9B0",
    variable = "#9CDCFE",
    constant = "#4FC1FF",
    string = "#CE9178",
    number = "#B5CEA8",
    regex = "#D16969",
    special = "#D7BA7D", -- 转义、选择器等
    tag = "#569CD6",
    tag_attr = "#9CDCFE",
    tag_delim = "#808080",
    violet = "#646695",
    orange = "#F28B25",
    yellow = "#FFD602",

    -- 状态栏模式色（bg, fg）
    mode = {
        normal = { "#0A7ACA", "#FFFFFF" },
        insert = { "#4EC9B0", "#1F1F1F" },
        visual = { "#FFAF00", "#1F1F1F" },
        replace = { "#F44747", "#1F1F1F" },
        command = { "#C586C0", "#1F1F1F" },
        terminal = { "#73C991", "#1F1F1F" },
    },
    status_inactive = "#666666",

    terminal = {
        "#000000", "#CD3131", "#0DBC79", "#E5E510", "#2472C8", "#BC3FBC", "#11A8CD", "#E5E5E5",
        "#666666", "#F14C4C", "#23D18B", "#F5F543", "#3B8EEA", "#D670D6", "#29B8DB", "#E5E5E5",
    },
}

M.light = {
    -- 界面
    bg = "#FFFFFF",
    fg = "#343434",
    fg_dim = "#3B3B3B",
    muted = "#8E8E90",
    faint = "#CECECE",
    float = "#F8F8F8",
    panel = "#E8E8E8",
    panel_hi = "#DADADA",
    raised = "#E4E4E4",
    line = "#F3F3F3",
    column = "#F0F0F0",
    border = "#D4D4D4",
    line_nr = "#6E7681",
    line_nr_cur = "#171184",
    indent = "#D2D2D2",
    indent_scope = "#929292",
    selection = "#ADD6FF",
    search = "#F8C9AB",
    search_cur = "#A8AC94",
    match_paren = "#B2DFDB",
    reference = "#D7EAFE",
    fold = "#E6F3FF",
    ghost = "#868686",
    menu_sel = "#E8E8E8",
    menu_sbar = "#EEEEEE",
    menu_thumb = "#C4C4C4",
    accent = "#007ACC",
    match = "#007ACC",
    heading_bg = "#F0F0F0",
    stopped = "#FFFFBA",

    -- Diff
    diff_add = "#EBF1DD",
    diff_add_hi = "#DBE6C2",
    diff_del = "#FFCCCC",
    diff_del_hi = "#FFA3A3",
    diff_change = "#E3EEFA",
    diff_text = "#BCD9F5",

    -- Git
    git_add = "#587C0C",
    git_change = "#895503",
    git_delete = "#AD0707",
    git_new = "#007100",
    git_conflict = "#AD0707",

    -- 诊断
    error = "#E51400",
    warn = "#BF8803",
    info = "#1A85FF",
    hint = "#16825D",
    ok = "#007100",
    unused = "#729DB3",

    -- 语法
    comment = "#008000",
    keyword = "#0000FF",
    control = "#AF00DB",
    func = "#795E26",
    type = "#267F99",
    variable = "#001080",
    constant = "#0070C1",
    string = "#A31515",
    number = "#098658",
    regex = "#811F3F",
    special = "#800000",
    tag = "#800000",
    tag_attr = "#E50000",
    tag_delim = "#800000",
    violet = "#000080",
    orange = "#C72E0F",
    yellow = "#BF8803",

    mode = {
        normal = { "#007ACC", "#FFFFFF" },
        insert = { "#16825D", "#FFFFFF" },
        visual = { "#BF8803", "#FFFFFF" },
        replace = { "#CD3131", "#FFFFFF" },
        command = { "#AF00DB", "#FFFFFF" },
        terminal = { "#587C0C", "#FFFFFF" },
    },
    status_inactive = "#888888",

    terminal = {
        "#000000", "#CD3131", "#107C10", "#949800", "#0451A5", "#BC05BC", "#0598BC", "#555555",
        "#666666", "#CD3131", "#14CE14", "#B5BA00", "#0451A5", "#BC05BC", "#0598BC", "#A5A5A5",
    },
}

---当前 'background' 对应的调色板
function M.get()
    return vim.o.background == "light" and M.light or M.dark
end

return M
