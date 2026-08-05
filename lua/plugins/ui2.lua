-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ui2 — Neovim 0.12 experimental core UI redesign
-- Eliminates "Press ENTER" interruptions, highlights cmdline
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local ok, ui2 = pcall(require, "vim._core.ui2")
if not ok or not ui2 then
    return
end

-- LSP progress lives in the statusline now (vim.lsp.status()), not here
ui2.enable({})
