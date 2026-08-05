-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Git — vim-fugitive (classic, fast, zero-config)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local map = vim.keymap.set

map("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Fugitive: Status" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Fugitive: Commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Fugitive: Push" })
map("n", "<leader>gP", "<cmd>Git pull<CR>", { desc = "Fugitive: Pull" })
map("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Fugitive: Log" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Fugitive: Blame" })
map("n", "<leader>gf", "<cmd>Git fetch<CR>", { desc = "Fugitive: Fetch" })
map("n", "<leader>gw", "<cmd>Gwrite<CR>", { desc = "Fugitive: Stage file" })
map("n", "<leader>gr", "<cmd>Gread<CR>", { desc = "Fugitive: Checkout file" })
map("n", "<leader>gD", "<cmd>Gdiffsplit<CR>", { desc = "Fugitive: Diff split" })
