-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Colorscheme — vscode.nvim (dark/light follows 'background')
-- Options carried over from the repo's previous lazy.nvim spec.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local vscode = require("vscode")

vscode.setup({
  italic_comments = true,
  italic_inlayhints = true,
  underline_links = true,
  disable_nvimtree_bg = true,
  terminal_colors = true,
})

vscode.load()
