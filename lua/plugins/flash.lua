-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- flash.nvim — label-based motions
-- Options carried over from the repo's previous lazy.nvim spec.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local flash = require("flash")

flash.setup({
  label = {
    rainbow = { enabled = true }, -- 彩虹标签
  },
  modes = {
    char = {
      jump_labels = true, -- f/F/t/T 显示跳转标签
    },
  },
})

local map = vim.keymap.set

map({ "n", "x", "o" }, "s", function() flash.jump() end, { desc = "Flash" })
map({ "n", "x", "o" }, "S", function() flash.treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() flash.remote() end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function() flash.treesitter_search() end, { desc = "Treesitter Search" })
map("c", "<C-s>", function() flash.toggle() end, { desc = "Toggle Flash Search" })
