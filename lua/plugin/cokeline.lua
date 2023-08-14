local status, cokeline = pcall(require, "cokeline")
if not status then
	vim.notify("not found cokeline")
	return
end
cokeline.setup({})

local map = vim.api.nvim_set_keymap

map("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true })
map("n", "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true })
-- map('n', 'bp', '<Plug>(cokeline-switch-prev)', { silent = true })
map("n", "bp", "<Plug>(cokeline-focus-prev)", { silent = true })
-- map('n', 'bn', '<Plug>(cokeline-switch-next)', { silent = true })
map("n", "bn", "<Plug>(cokeline-focus-next)", { silent = true })

for i = 1, 9 do
	map("n", ("<F%s>"):format(i), ("<Plug>(cokeline-focus-%s)"):format(i), { silent = true })
	map("n", ("<Leader>%s"):format(i), ("<Plug>(cokeline-switch-%s)"):format(i), { silent = true })
end

map("n", "bd", ":Bdelete<cr>", { silent = true })
