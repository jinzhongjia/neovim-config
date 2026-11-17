-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- vsmin — 配置自带的 VS Code 风格配色（替掉 vscode.nvim）
-- 深/浅两套跟随 'background'，只定义本配置实际用到的高亮组：
-- 内建 UI / 语法 / treesitter / LSP + 已装插件。
-- 其余插件的高亮组默认 link 到内建组，自动跟着走。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}

---@param c table 调色板
---@return table<string, vim.api.keyset.highlight>
local function groups(c)
    local g = {
        -- ── 编辑区 ────────────────────────────────────────────
        Normal = { fg = c.fg, bg = c.bg },
        NormalFloat = { fg = c.fg, bg = c.float },
        FloatBorder = { fg = c.border, bg = c.float },
        FloatTitle = { fg = c.fg, bg = c.float, bold = true },
        FloatFooter = { fg = c.muted, bg = c.float },
        ColorColumn = { bg = c.column },
        Conceal = { fg = c.muted },
        Cursor = { fg = c.bg, bg = c.fg },
        CursorLine = { bg = c.line },
        CursorColumn = { bg = c.line },
        CursorLineNr = { fg = c.line_nr_cur },
        LineNr = { fg = c.line_nr },
        SignColumn = {},
        FoldColumn = { fg = c.line_nr },
        Folded = { bg = c.fold },
        EndOfBuffer = { fg = c.bg },
        NonText = { fg = c.faint },
        Whitespace = { fg = c.faint },
        SpecialKey = { fg = c.keyword },
        WinSeparator = { fg = c.border },
        VertSplit = { link = "WinSeparator" },
        MatchParen = { bg = c.match_paren },
        Visual = { bg = c.selection },
        VisualNOS = { bg = c.selection },
        Search = { bg = c.search },
        IncSearch = { bg = c.search_cur },
        CurSearch = { bg = c.search_cur },
        Substitute = { fg = c.bg, bg = c.orange, bold = true },
        QuickFixLine = { bg = c.line, bold = true },
        Directory = { fg = c.keyword },
        Title = { bold = true },

        -- ── 状态栏 / 标签栏 / winbar ──────────────────────────
        StatusLine = { fg = c.fg, bg = c.raised },
        StatusLineNC = { fg = c.muted, bg = c.panel },
        TabLine = { fg = c.muted, bg = c.panel_hi },
        TabLineFill = { fg = c.fg, bg = c.panel },
        TabLineSel = { fg = c.fg, bg = c.bg },
        WinBar = { fg = c.fg, bg = c.bg, bold = true },
        WinBarNC = { fg = c.muted, bg = c.bg },

        -- ── 消息 ──────────────────────────────────────────────
        ModeMsg = { fg = c.fg },
        MoreMsg = { fg = c.info },
        Question = { fg = c.info },
        ErrorMsg = { fg = c.error },
        WarningMsg = { fg = c.warn },
        OkMsg = { fg = c.ok },

        -- ── 补全菜单 ──────────────────────────────────────────
        Pmenu = { fg = c.fg_dim, bg = c.float },
        PmenuSel = { bg = c.menu_sel },
        PmenuSbar = { bg = c.menu_sbar },
        PmenuThumb = { bg = c.menu_thumb },
        PmenuBorder = { link = "FloatBorder" },
        PmenuMatch = { fg = c.match, bold = true },
        PmenuMatchSel = { fg = c.match, bold = true },
        PmenuKind = { fg = c.muted },
        PmenuExtra = { fg = c.muted },
        WildMenu = { bg = c.selection },
        ComplMatchIns = { fg = c.ghost },
        SnippetTabstop = { bg = c.reference },

        -- ── Diff ──────────────────────────────────────────────
        DiffAdd = { bg = c.diff_add },
        DiffDelete = { bg = c.diff_del },
        DiffChange = { bg = c.diff_change },
        DiffText = { bg = c.diff_text },
        DiffTextAdd = { bg = c.diff_add_hi },
        Added = { fg = c.git_add },
        Changed = { fg = c.git_change },
        Removed = { fg = c.git_delete },
        diffAdded = { link = "Added" },
        diffChanged = { link = "Changed" },
        diffRemoved = { link = "Removed" },

        -- ── 拼写 ──────────────────────────────────────────────
        SpellBad = { undercurl = true, sp = c.error },
        SpellCap = { undercurl = true, sp = c.warn },
        SpellRare = { undercurl = true, sp = c.violet },
        SpellLocal = { undercurl = true, sp = c.info },

        -- ── 语法（legacy）─────────────────────────────────────
        Comment = { fg = c.comment, italic = true },
        SpecialComment = { fg = c.comment },
        Constant = { fg = c.keyword },
        String = { fg = c.string },
        Character = { fg = c.string },
        Number = { fg = c.number },
        Float = { fg = c.number },
        Boolean = { fg = c.keyword },
        Identifier = { fg = c.variable },
        Function = { fg = c.func },
        Statement = { fg = c.control },
        Keyword = { fg = c.control },
        Operator = { fg = c.fg },
        PreProc = { fg = c.control },
        Type = { fg = c.keyword },
        StorageClass = { fg = c.keyword },
        Structure = { fg = c.type },
        Typedef = { fg = c.keyword },
        Special = { fg = c.special },
        SpecialChar = { fg = c.special },
        Tag = { fg = c.fg },
        Delimiter = { fg = c.fg },
        Debug = { fg = c.fg },
        Underlined = { underline = true },
        Ignore = { fg = c.faint },
        Error = { fg = c.error },
        Todo = { fg = c.special, bold = true },

        -- ── Treesitter ────────────────────────────────────────
        ["@variable"] = { fg = c.variable },
        ["@variable.builtin"] = { fg = c.keyword },
        ["@variable.parameter"] = { fg = c.variable },
        ["@variable.member"] = { fg = c.variable },
        ["@property"] = { fg = c.variable },
        ["@constant"] = { fg = c.constant },
        ["@constant.builtin"] = { fg = c.keyword },
        ["@constant.macro"] = { fg = c.type },
        ["@module"] = { fg = c.type },
        ["@label"] = { fg = c.variable },
        ["@string"] = { fg = c.string },
        ["@string.regexp"] = { fg = c.regex },
        ["@string.escape"] = { fg = c.special },
        ["@string.special.url"] = { fg = c.string, underline = true },
        ["@character"] = { fg = c.string },
        ["@number"] = { fg = c.number },
        ["@number.float"] = { fg = c.number },
        ["@boolean"] = { fg = c.keyword },
        ["@type"] = { fg = c.type },
        ["@type.builtin"] = { fg = c.keyword },
        ["@type.builtin.typescript"] = { link = "@type" },
        ["@type.builtin.tsx"] = { link = "@type" },
        ["@type.qualifier"] = { fg = c.keyword },
        ["@attribute"] = { fg = c.func },
        ["@attribute.builtin"] = { fg = c.type },
        ["@function"] = { fg = c.func },
        ["@function.builtin"] = { fg = c.func },
        ["@function.macro"] = { fg = c.func },
        ["@function.method"] = { fg = c.func },
        ["@constructor"] = { fg = c.type },
        ["@constructor.lua"] = { fg = c.fg }, -- lua 的 {} 表构造
        ["@operator"] = { fg = c.fg },
        ["@keyword"] = { fg = c.keyword },
        ["@keyword.conditional"] = { fg = c.control },
        ["@keyword.repeat"] = { fg = c.control },
        ["@keyword.return"] = { fg = c.control },
        ["@keyword.exception"] = { fg = c.control },
        ["@keyword.import"] = { fg = c.control },
        ["@keyword.coroutine"] = { fg = c.control },
        ["@punctuation.bracket"] = { fg = c.fg },
        ["@punctuation.delimiter"] = { fg = c.fg },
        ["@punctuation.special"] = { fg = c.keyword }, -- 模板字符串的 ${}
        ["@comment"] = { link = "Comment" },
        ["@comment.note"] = { fg = c.hint, bold = true },
        ["@comment.todo"] = { fg = c.info, bold = true },
        ["@comment.warning"] = { fg = c.warn, bold = true },
        ["@comment.error"] = { fg = c.error, bold = true },
        ["@tag"] = { fg = c.tag },
        ["@tag.builtin"] = { fg = c.tag },
        ["@tag.attribute"] = { fg = c.tag_attr },
        ["@tag.delimiter"] = { fg = c.tag_delim },

        ["@markup.strong"] = { fg = c.keyword, bold = true },
        ["@markup.italic"] = { italic = true },
        ["@markup.underline"] = { underline = true },
        ["@markup.strikethrough"] = { strikethrough = true },
        ["@markup.heading"] = { fg = c.keyword, bold = true },
        ["@markup.heading.1"] = { fg = c.keyword, bold = true },
        ["@markup.heading.2"] = { fg = c.string, bold = true },
        ["@markup.heading.3"] = { fg = c.func, bold = true },
        ["@markup.heading.4"] = { fg = c.comment, bold = true },
        ["@markup.heading.5"] = { fg = c.type, bold = true },
        ["@markup.heading.6"] = { fg = c.control, bold = true },
        ["@markup.raw"] = { fg = c.string },
        ["@markup.raw.block"] = { fg = c.fg },
        ["@markup.quote"] = { fg = c.comment },
        ["@markup.math"] = { fg = c.number },
        ["@markup.link"] = { fg = c.variable },
        ["@markup.link.label"] = { fg = c.variable, underline = true },
        ["@markup.link.url"] = { fg = c.muted, underline = true },
        ["@markup.list"] = { fg = c.keyword },
        ["@markup.list.checked"] = { fg = c.ok },
        ["@markup.list.unchecked"] = { fg = c.muted },

        ["@diff.plus"] = { link = "Added" },
        ["@diff.minus"] = { link = "Removed" },
        ["@diff.delta"] = { link = "Changed" },

        -- ── LSP ───────────────────────────────────────────────
        ["@lsp.type.type"] = { link = "@type" },
        ["@lsp.type.typeParameter"] = { link = "@type" },
        ["@lsp.type.macro"] = { link = "@constant" },
        ["@lsp.type.enumMember"] = { link = "@constant" },
        ["@lsp.type.keyword"] = { link = "@keyword" },
        ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
        ["@lsp.typemod.variable.readonly"] = { link = "@constant" },
        ["@lsp.typemod.property.readonly"] = { link = "@constant" },
        ["@lsp.typemod.variable.constant"] = { link = "@constant" },
        ["@lsp.typemod.keyword.controlFlow"] = { fg = c.control },
        -- clangd 用 comment 标记 #if 0 之类的失效代码
        ["@lsp.type.comment.c"] = { fg = c.ghost },
        ["@lsp.type.comment.cpp"] = { fg = c.ghost },

        LspReferenceText = { bg = c.reference },
        LspReferenceRead = { bg = c.reference },
        LspReferenceWrite = { bg = c.reference },
        LspInlayHint = { fg = c.ghost, italic = true },
        LspCodeLens = { fg = c.ghost },
        LspSignatureActiveParameter = { bg = c.selection, bold = true },

        DiagnosticError = { fg = c.error },
        DiagnosticWarn = { fg = c.warn },
        DiagnosticInfo = { fg = c.info },
        DiagnosticHint = { fg = c.hint },
        DiagnosticOk = { fg = c.ok },
        DiagnosticUnnecessary = { fg = c.unused },
        DiagnosticDeprecated = { strikethrough = true },
        DiagnosticUnderlineError = { undercurl = true, sp = c.error },
        DiagnosticUnderlineWarn = { undercurl = true, sp = c.warn },
        DiagnosticUnderlineInfo = { undercurl = true, sp = c.info },
        DiagnosticUnderlineHint = { undercurl = true, sp = c.hint },

        -- ── blink.cmp ─────────────────────────────────────────
        BlinkCmpMenu = { link = "Pmenu" },
        BlinkCmpMenuBorder = { link = "FloatBorder" },
        BlinkCmpMenuSelection = { link = "PmenuSel" },
        BlinkCmpScrollBarThumb = { link = "PmenuThumb" },
        BlinkCmpScrollBarGutter = { link = "PmenuSbar" },
        BlinkCmpLabel = { fg = c.fg },
        BlinkCmpLabelMatch = { fg = c.match, bold = true },
        BlinkCmpLabelDeprecated = { fg = c.muted, strikethrough = true },
        BlinkCmpLabelDetail = { fg = c.muted },
        BlinkCmpLabelDescription = { fg = c.muted },
        BlinkCmpSource = { fg = c.muted },
        BlinkCmpGhostText = { fg = c.ghost },
        BlinkCmpDoc = { link = "NormalFloat" },
        BlinkCmpDocBorder = { link = "FloatBorder" },
        BlinkCmpDocSeparator = { link = "FloatBorder" },
        BlinkCmpSignatureHelp = { link = "NormalFloat" },
        BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
        BlinkCmpSignatureHelpActiveParameter = { link = "LspSignatureActiveParameter" },
        BlinkCmpKind = { fg = c.fg_dim },

        -- ── bufferline（其余组由它从 Normal/Comment 自行推导）──
        BufferLineFill = { bg = c.panel },
        BufferLineIndicatorSelected = { fg = c.accent },

        -- ── nvim-tree ─────────────────────────────────────────
        NvimTreeRootFolder = { fg = c.fg, bold = true },
        NvimTreeFolderName = { fg = c.fg },
        NvimTreeOpenedFolderName = { fg = c.fg },
        NvimTreeEmptyFolderName = { fg = c.muted },
        NvimTreeFolderIcon = { fg = c.accent },
        NvimTreeIndentMarker = { fg = c.indent },
        NvimTreeSpecialFile = { fg = c.control, underline = true },
        NvimTreeImageFile = { fg = c.violet },
        NvimTreeGitDirty = { fg = c.git_change },
        NvimTreeGitStaged = { fg = c.git_change },
        NvimTreeGitNew = { fg = c.git_add },
        NvimTreeGitRenamed = { fg = c.git_new },
        NvimTreeGitMerge = { fg = c.git_conflict },
        NvimTreeGitDeleted = { fg = c.git_delete },
        NvimTreeGitIgnored = { fg = c.muted },

        -- ── snacks ────────────────────────────────────────────
        SnacksIndent = { fg = c.indent, nocombine = true },
        SnacksIndentScope = { fg = c.indent_scope, nocombine = true },
        SnacksPicker = { link = "Normal" },
        SnacksPickerBorder = { fg = c.border, bg = c.bg },
        SnacksPickerTitle = { fg = c.fg, bg = c.bg, bold = true },
        SnacksPickerDir = { fg = c.muted },
        SnacksPickerMatch = { fg = c.match, bold = true },
        SnacksPickerListCursorLine = { bg = c.menu_sel },
        SnacksPickerPreviewCursorLine = { bg = c.line },

        -- ── mini.diff（sign 走 Added/Changed/Removed）─────────
        MiniDiffOverAdd = { bg = c.diff_add_hi },
        MiniDiffOverDelete = { bg = c.diff_del_hi },
        MiniDiffOverChange = { bg = c.diff_text },
        MiniDiffOverContext = { bg = c.diff_change },

        -- ── neogit ────────────────────────────────────────────
        NeogitWinSeparator = { link = "WinSeparator" },
        NeogitDiffAdd = { fg = c.git_add, bg = c.diff_add },
        NeogitDiffAddHighlight = { fg = c.git_add, bg = c.diff_add_hi },
        NeogitDiffAddCursor = { link = "NeogitDiffAddHighlight" },
        NeogitDiffDelete = { fg = c.git_delete, bg = c.diff_del },
        NeogitDiffDeleteHighlight = { fg = c.git_delete, bg = c.diff_del_hi },
        NeogitDiffDeleteCursor = { link = "NeogitDiffDeleteHighlight" },
        NeogitDiffContext = { fg = c.fg_dim, bg = c.panel },
        NeogitDiffContextHighlight = { fg = c.fg_dim, bg = c.raised },
        NeogitDiffContextCursor = { link = "NeogitDiffContextHighlight" },
        NeogitDiffHeader = { fg = c.muted, bg = c.bg },
        NeogitDiffHeaderHighlight = { fg = c.muted, bg = c.bg },
        NeogitHunkHeader = { fg = c.git_change, bg = c.panel },
        NeogitHunkHeaderHighlight = { fg = c.git_change, bg = c.raised },
        NeogitHunkHeaderCursor = { link = "NeogitHunkHeaderHighlight" },

        -- ── which-key ─────────────────────────────────────────
        WhichKeySeparator = { fg = c.muted },
        WhichKeyValue = { fg = c.muted },
        WhichKeyIconAzure = { fg = c.type },
        WhichKeyIconBlue = { fg = c.keyword },
        WhichKeyIconCyan = { fg = c.constant },
        WhichKeyIconGreen = { fg = c.comment },
        WhichKeyIconGrey = { fg = c.muted },
        WhichKeyIconOrange = { fg = c.orange },
        WhichKeyIconPurple = { fg = c.control },
        WhichKeyIconRed = { fg = c.error },
        WhichKeyIconYellow = { fg = c.warn },

        -- ── flash ─────────────────────────────────────────────
        FlashBackdrop = { fg = c.ghost },
        FlashLabel = { fg = c.bg, bg = c.orange, bold = true },

        -- ── nvim-dap / dap-ui ─────────────────────────────────
        debugPC = { bg = c.stopped },
        DapStoppedLine = { bg = c.stopped },

        -- ── copilot ───────────────────────────────────────────
        CopilotSuggestion = { fg = c.ghost },
        CopilotAnnotation = { fg = c.ghost },

        -- ── outline.nvim ──────────────────────────────────────
        OutlineCurrent = { fg = c.match, bold = true },
        OutlineGuides = { fg = c.indent },
        OutlineFoldMarker = { fg = c.muted },
    }

    -- render-markdown：标题前景同 treesitter，背景统一一条浅色带
    local headings = { c.keyword, c.string, c.func, c.comment, c.type, c.control }
    for i, fg in ipairs(headings) do
        g["RenderMarkdownH" .. i] = { fg = fg, bold = true }
        g["RenderMarkdownH" .. i .. "Bg"] = { fg = fg, bg = c.heading_bg, bold = true }
    end
    g.RenderMarkdownCode = { bg = c.column }
    g.RenderMarkdownCodeInline = { fg = c.string, bg = c.column }

    -- dap-ui 自带的默认色是写死的深色值，按语义重新指一遍
    local dapui = {
        [c.type] = {
            "BreakpointsInfo", "PlayPause", "PlayPauseNC", "Restart", "RestartNC",
            "Thread", "WatchesValue",
        },
        [c.control] = {
            "BreakpointsLine", "BreakpointsPath", "Decoration", "FloatBorder", "LineNumber",
            "Scope", "StepBack", "StepBackNC", "StepInto", "StepIntoNC", "StepOut", "StepOutNC",
            "StepOver", "StepOverNC", "StoppedThread", "Type",
        },
        [c.error] = { "Stop", "StopNC", "WatchesError" },
        [c.muted] = { "BreakpointsDisabledLine", "Unavailable", "UnavailableNC", "WatchesEmpty" },
    }
    for fg, names in pairs(dapui) do
        for _, name in ipairs(names) do
            g["DapUI" .. name] = { fg = fg }
        end
    end
    g.DapUISource = { fg = c.match }
    g.DapUIBreakpointsCurrentLine = { fg = c.type, bold = true }
    g.DapUICurrentFrameName = { fg = c.type, bold = true }
    g.DapUIModifiedValue = { fg = c.control, bold = true }
    g.DapUIWinSelect = { fg = c.control, bold = true }

    return g
end

function M.load()
    if vim.g.colors_name then
        vim.cmd("highlight clear")
    end
    vim.g.colors_name = "vsmin"

    local c = require("vsmin.palette").get()
    for name, spec in pairs(groups(c)) do
        vim.api.nvim_set_hl(0, name, spec)
    end
    for i, color in ipairs(c.terminal) do
        vim.g["terminal_color_" .. (i - 1)] = color
    end
end

return M
