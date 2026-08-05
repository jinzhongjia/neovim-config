-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Copilot — inline ghost-text suggestions (needs Node.js)
-- Options carried over from the repo's previous lazy.nvim spec.
-- Panel is off; the built-in pum handles completion (core/completion.lua).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
  },
  panel = { enabled = false },
  -- Opt-in per filetype: everything off unless listed
  filetypes = {
    ["*"] = false,
    lua = true,
    go = true,
    zig = true,
    typescript = true,
    javascript = true,
    vue = true,
    c = true,
    cpp = true,
    proto = true,
    markdown = true,
    yaml = true,
    python = true,
    html = true,
    css = true,
    sql = true,
    typescriptreact = true,
    javascriptreact = true,
    dockerfile = true,
    json = true,
    ini = true,
  },
})
