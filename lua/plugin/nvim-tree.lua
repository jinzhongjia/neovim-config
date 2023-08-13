local status, nvim_tree = pcall(require, "nvim-tree")
if not status then
	vim.notify("not found nvim-tree")
	return
end

local tool = require("tool")

nvim_tree.setup({
	filters = {
		dotfiles = true,
		custom = { "node_modules" },
	},
	actions = {
		open_file = {
			-- 首次打开大小适配
			resize_window = true,
			-- 打开文件时关闭
			quit_on_open = true,
		},
	},
})

tool.map("n", "<leader>e", ":NvimTreeToggle<CR>")
