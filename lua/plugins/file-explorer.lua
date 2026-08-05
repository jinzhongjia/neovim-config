-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- nvim-tree — file explorer (replaces netrw)
-- Options carried over from the repo's previous lazy.nvim spec.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("nvim-tree").setup({
  view = { adaptive_size = true },
  disable_netrw = true,
  hijack_netrw = true,
  sync_root_with_cwd = true,
  update_focused_file = { enable = true },
  filters = {
    dotfiles = true,
    custom = { "node_modules", "^.git$" },
  },
  actions = {
    open_file = {
      resize_window = true,
      quit_on_open = true,
    },
  },
  live_filter = {
    prefix = "[FILTER]: ",
    always_show_folders = false,
  },
  git = { timeout = 1000 },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  select_prompts = true,
})

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTree" })
