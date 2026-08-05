-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Treesitter — parser management & enhanced highlighting
-- nvim-treesitter `main` branch: no .configs module, no auto
-- highlight/indent. Parsers via install(), rest via autocmd.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local ts = require("nvim-treesitter")

local langs = {
  "c",
  "css",
  "go",
  "gomod",
  "gosum",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
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
