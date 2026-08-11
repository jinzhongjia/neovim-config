-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Treesitter — parser management & enhanced highlighting
-- nvim-treesitter `main` branch: no .configs module, no auto
-- highlight/indent. Parsers via install(), rest via autocmd.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local ts = require("nvim-treesitter")

local langs = {
    "bash",
    "c",
    "css",
    "dockerfile",
    "go",
    "gomod",
    "gosum",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "proto",
    "python",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
    "zig",
}

-- Install only what's missing (install() re-downloads otherwise)
local installed = {}
for _, l in ipairs(ts.get_installed("parsers")) do
    installed[l] = true
end
local missing = vim.tbl_filter(function(l)
    return not installed[l]
end, langs)
if #missing > 0 then
    ts.install(missing)
end

-- highlight + indent are opt-in per buffer on `main`
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter", {}),
    callback = function(ev)
        -- Skip very large files (performance)
        local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(ev.buf))
        if stats and stats.size > 1024 * 1024 then
            return
        end
        -- ponytail: pcall instead of checking parser availability first —
        -- start() already resolves filetype→lang and fails cheaply.
        if not pcall(vim.treesitter.start, ev.buf) then
            return
        end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- 0.12 built-in incremental selection: v_an / v_in

-- ── Textobjects（main 分支 API：keymap 手动建）────────────────
require("nvim-treesitter-textobjects").setup({
    select = { lookahead = true },
    move = { set_jumps = true },
})

local function sel(lhs, query, desc)
    vim.keymap.set({ "x", "o" }, lhs, function()
        require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
    end, { desc = desc })
end
sel("af", "@function.outer", "Function (outer)")
sel("if", "@function.inner", "Function body")
sel("ac", "@class.outer", "Class (outer)")
sel("ic", "@class.inner", "Class body")
sel("aa", "@parameter.outer", "Parameter (with separator)")
sel("ia", "@parameter.inner", "Parameter")

-- ]c/[c 留给 diff 模式（Gdiffsplit 里跳 hunk），函数跳转用 f
local function mv(lhs, fn, query, desc)
    vim.keymap.set({ "n", "x", "o" }, lhs, function()
        require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
    end, { desc = desc })
end
mv("]f", "goto_next_start", "@function.outer", "Next function")
mv("[f", "goto_previous_start", "@function.outer", "Prev function")
