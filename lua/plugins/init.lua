-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Plugin management via vim.pack (built-in, Neovim 0.12)
-- Minimal plugin set — only what built-in cannot do
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local gh = function(repo)
    return "https://github.com/" .. repo
end

vim.pack.add({
    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Treesitter — syntax highlighting & textobjects          │
    -- │ (built-in TS exists but nvim-treesitter manages parsers)│
    -- └─────────────────────────────────────────────────────────┘
    { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
    -- textobjects 必须跟主仓库同用 main 分支（API 已重写）
    { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Fuzzy Finder — fzf-lua (fastest picker, no dependencies)│
    -- └─────────────────────────────────────────────────────────┘
    gh("ibhagwan/fzf-lua"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ File Tree — nvim-tree (sidebar tree, replaces netrw)    │
    -- └─────────────────────────────────────────────────────────┘
    gh("nvim-tree/nvim-tree.lua"),
    gh("nvim-tree/nvim-web-devicons"), -- icons for nvim-tree + bufferline

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Bufferline — buffer tabs                                │
    -- └─────────────────────────────────────────────────────────┘
    gh("akinsho/bufferline.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Completion + auto pairs — blink.cmp / blink.pairs       │
    -- │ Pinned to release tags so the prebuilt Rust binaries    │
    -- │ download automatically (no cargo needed)                │
    -- └─────────────────────────────────────────────────────────┘
    { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
    gh("saghen/blink.lib"), -- runtime dep of blink.pairs
    { src = gh("saghen/blink.pairs"), version = vim.version.range("*") },

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Motion — flash.nvim (label jumps, treesitter select)    │
    -- └─────────────────────────────────────────────────────────┘
    gh("folke/flash.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Surround — mini.surround（gs 前缀，s 被 flash 占用）     │
    -- └─────────────────────────────────────────────────────────┘
    gh("echasnovski/mini.surround"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ TODO 注释高亮 + 搜索（plenary 是它的运行时依赖）          │
    -- └─────────────────────────────────────────────────────────┘
    gh("folke/todo-comments.nvim"),
    gh("nvim-lua/plenary.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Mason — LSP/DAP package manager                         │
    -- └─────────────────────────────────────────────────────────┘
    gh("williamboman/mason.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ lspconfig — base lsp/<name>.lua (cmd/filetypes/roots).  │
    -- │ Our after/lsp/*.lua only carry settings overrides, so   │
    -- │ this supplies what they omit. No setup() call needed.   │
    -- └─────────────────────────────────────────────────────────┘
    gh("neovim/nvim-lspconfig"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ lazydev — Neovim Lua types for lua_ls                   │
    -- └─────────────────────────────────────────────────────────┘
    gh("folke/lazydev.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ DAP — Debug Adapter Protocol                            │
    -- └─────────────────────────────────────────────────────────┘
    gh("mfussenegger/nvim-dap"),
    gh("rcarriga/nvim-dap-ui"),
    gh("nvim-neotest/nvim-nio"), -- required by dap-ui

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Git — Fugitive (classic, fast, zero-config)             │
    -- │       + mini.diff (gutter 标记 / hunk 操作)              │
    -- │       + neogit (magit 式 status/stage/rebase 界面)       │
    -- └─────────────────────────────────────────────────────────┘
    gh("tpope/vim-fugitive"),
    gh("echasnovski/mini.diff"),
    gh("NeogitOrg/neogit"), -- plenary 已在上面

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Format — conform.nvim（<leader>cf，LSP fallback）        │
    -- └─────────────────────────────────────────────────────────┘
    gh("stevearc/conform.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ AI — Claude Code + OpenCode + Copilot                   │
    -- └─────────────────────────────────────────────────────────┘
    gh("coder/claudecode.nvim"),
    gh("sudo-tee/opencode.nvim"),
    gh("zbirenbaum/copilot.lua"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Colorscheme — vscode.nvim (no deps)                     │
    -- └─────────────────────────────────────────────────────────┘
    gh("Mofiqul/vscode.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ which-key — leader 键位速查弹窗                          │
    -- └─────────────────────────────────────────────────────────┘
    gh("folke/which-key.nvim"),

    -- ┌─────────────────────────────────────────────────────────┐
    -- │ Markdown — 缓冲区内渲染（treesitter based）              │
    -- └─────────────────────────────────────────────────────────┘
    gh("MeanderingProgrammer/render-markdown.nvim"),
})

-- :PackUpdate [插件名...] 更新插件（无参=全部；加 ! 跳过确认 buffer）
vim.api.nvim_create_user_command("PackUpdate", function(cmd)
    vim.pack.update(#cmd.fargs > 0 and cmd.fargs or nil, { force = cmd.bang })
end, {
    nargs = "*",
    bang = true,
    complete = function()
        return vim.tbl_map(function(p)
            return p.spec.name
        end, vim.pack.get())
    end,
    desc = "vim.pack update (! = no confirm)",
})

-- Load plugin configs after pack
require("plugins.mason")
require("plugins.lazydev")
require("plugins.completion")
require("plugins.treesitter")
require("plugins.markdown")
require("plugins.fzf")
require("plugins.file-explorer")
require("plugins.flash")
require("plugins.surround")
require("plugins.todo")
require("plugins.dap")
require("plugins.colorscheme")
require("plugins.statusline")
require("plugins.bufferline")
require("plugins.ui2")
require("plugins.difftool")
require("plugins.git")
require("plugins.neogit")
require("plugins.diff")
require("plugins.format")
require("plugins.ai")
require("plugins.copilot")
require("plugins.terminal")
require("plugins.pairs")
require("plugins.which-key")
