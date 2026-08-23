-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Git — vim-fugitive (classic, fast, zero-config)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local map = vim.keymap.set

-- <leader>g* 归 LSP 导航（同 main，见 plugins/lspui.lua），git 用 <leader>G*
-- Gl（log）/ Gs（status picker）/ GB（branches）/ Gy（gitbrowse）在 plugins/snacks.lua
map("n", "<leader>Gg", "<cmd>Git<CR>", { desc = "Fugitive: Status" })
map("n", "<leader>Gc", "<cmd>Git commit<CR>", { desc = "Fugitive: Commit" })
map("n", "<leader>Gp", "<cmd>Git push<CR>", { desc = "Fugitive: Push" })
map("n", "<leader>GP", "<cmd>Git pull<CR>", { desc = "Fugitive: Pull" })
map("n", "<leader>Gb", "<cmd>Git blame<CR>", { desc = "Fugitive: Blame" })
map("n", "<leader>Gf", "<cmd>Git fetch<CR>", { desc = "Fugitive: Fetch" })
map("n", "<leader>Gw", "<cmd>Gwrite<CR>", { desc = "Fugitive: Stage file" })
map("n", "<leader>Gr", "<cmd>Gread<CR>", { desc = "Fugitive: Checkout file" })
map("n", "<leader>Gd", "<cmd>Gdiffsplit<CR>", { desc = "Fugitive: Diff vs index" })
