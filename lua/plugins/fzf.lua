-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- fzf-lua — fastest fuzzy finder (uses native fzf binary)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local fzf = require("fzf-lua")

fzf.setup({
    -- Use "max-perf" profile for speed
    "max-perf",
    winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = "rounded",
        preview = {
            layout = "flex",
            flip_columns = 120,
            delay = 50,
        },
    },
    fzf_opts = {
        ["--layout"] = "reverse",
        ["--info"] = "inline-right",
    },
    files = {
        cmd = vim.fn.executable("fd") == 1 and "fd --type f --hidden --follow --exclude .git"
            or "find . -type f -not -path '*/.git/*'",
    },
    grep = {
        -- max-perf 关闭了 fzf 的 --ansi 解析，rg 必须 --color=never，
        -- 否则转义码会原样显示（fzf 自身仍高亮匹配片段）。
        -- 相比 profile 默认多了 --hidden -g '!.git/'（搜隐藏文件）
        rg_opts = "--column --line-number --no-heading --color=never --smart-case"
            .. " --max-columns=4096 --hidden -g '!.git/' -e",
    },
})

-- vim.ui.select 走 fzf 浮窗（code action 选择等）
fzf.register_ui_select()

-- Keymaps
local map = vim.keymap.set

-- Files
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })

-- Search/Grep
map("n", "<leader>sg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>sw", fzf.grep_cword, { desc = "Grep word" })
map("n", "<leader>sW", fzf.grep_cWORD, { desc = "Grep WORD" })
map("n", "<leader>sb", fzf.lgrep_curbuf, { desc = "Grep current buffer" })
map("v", "<leader>sg", fzf.grep_visual, { desc = "Grep selection" })

-- LSP
map("n", "<leader>ls", fzf.lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>lS", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>ld", fzf.lsp_definitions, { desc = "Definitions" })
map("n", "<leader>lr", fzf.lsp_references, { desc = "References" })
map("n", "<leader>li", fzf.lsp_implementations, { desc = "Implementations" })
map("n", "<leader>la", fzf.lsp_code_actions, { desc = "Code actions" })

-- Diagnostics
map("n", "<leader>dd", fzf.diagnostics_document, { desc = "Document diagnostics" })
map("n", "<leader>dw", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })

-- Git（gc/gb 留给 fugitive 的 commit/blame，见 plugins/git.lua）
map("n", "<leader>gl", fzf.git_commits, { desc = "Git log (commits)" })
map("n", "<leader>gs", fzf.git_status, { desc = "Git status (picker)" })
map("n", "<leader>gB", fzf.git_branches, { desc = "Git branches" })

-- Misc
map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
map("n", "<leader>fc", fzf.commands, { desc = "Commands" })
map("n", "<leader>/", fzf.lgrep_curbuf, { desc = "Search in buffer" })
