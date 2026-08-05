-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- AI Coding — Claude Code + OpenCode
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ── Claude Code (claudecode.nvim) ────────────────────────────
-- Pure Lua WebSocket MCP bridge to Claude Code CLI
require("claudecode").setup({
  -- Auto-start the WebSocket server
  auto_start = true,
  log_level = "warn",

  -- Terminal
  terminal = {
    split_side = "right",
    split_width_percentage = 0.35,
    provider = "native",  -- no snacks.nvim dependency
    auto_close = true,
    auto_insert = true,
  },

  -- Diff integration
  diff_opts = {
    layout = "vertical",
    open_in_new_tab = false,
    auto_resize_terminal = true,
  },

  -- Selection tracking (Claude sees your cursor/selection in real-time)
  track_selection = true,
})

-- Claude Code keymaps
local map = vim.keymap.set
map("n", "<leader>ac", "<cmd>ClaudeCode<CR>", { desc = "Claude: Toggle" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<CR>", { desc = "Claude: Focus" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", { desc = "Claude: Select model" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { desc = "Claude: Add buffer" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<CR>", { desc = "Claude: Send selection" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", { desc = "Claude: Accept diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", { desc = "Claude: Deny diff" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<CR>", { desc = "Claude: Resume" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<CR>", { desc = "Claude: Continue" })

-- ── OpenCode (opencode.nvim) ─────────────────────────────────
-- Neovim frontend for the opencode AI agent
require("opencode").setup({
  -- Use fzf-lua as picker (already in our config)
  preferred_picker = "fzf-lua",
  -- Use native vim completion (no blink/nvim-cmp)
  preferred_completion = "vim_complete",
  -- Default keymaps
  default_global_keymaps = true,
  keymap_prefix = "<leader>o",
  -- Default mode
  default_mode = "build",

  -- UI
  ui = {
    position = "right",
    window_width = 0.40,
    display_model = true,
    display_context_size = true,
    icons = {
      preset = "nerdfonts",
    },
    output = {
      tools = {
        show_output = true,
        use_folds = true,
        folding_threshold = 25,
      },
    },
  },

  -- Context
  context = {
    enabled = true,
    diagnostics = {
      warning = true,
      error = true,
    },
    current_file = {
      enabled = true,
      show_full_path = true,
    },
    selection = {
      enabled = true,
    },
  },

  -- Logging
  logging = {
    enabled = false,
    level = "warn",
  },
})
