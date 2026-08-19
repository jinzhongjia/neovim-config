-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- bufferline.nvim — buffer tabs
-- Options carried over from the repo's previous lazy.nvim spec.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Snacks.bufdelete 删 buffer 时会保住窗口布局（普通 :bdelete 会把窗口一起关掉）
local function bufdelete(n)
  Snacks.bufdelete((n == nil or n == 0) and vim.api.nvim_get_current_buf() or n)
end

local function bufdelete_others()
  Snacks.bufdelete.other()
end

require("bufferline").setup({
  options = {
    mode = "buffers",
    numbers = "ordinal", -- 显示 buffer 序号
    close_command = bufdelete,
    right_mouse_command = bufdelete,
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,
    indicator = {
      icon = "▎",
      style = "icon",
    },
    buffer_close_icon = "󰅖",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 30,
    max_prefix_length = 15,
    truncate_names = true,
    tab_size = 18,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, _, _)
      local icon = level:match("error") and "󰅚 " or (level:match("warning") and " " or " ")
      return " " .. icon .. count
    end,
    color_icons = true,
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    show_duplicate_prefix = true,
    persist_buffer_sort = true,
    separator_style = "thin",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    hover = {
      enabled = true,
      delay = 200,
      reveal = { "close" },
    },
    sort_by = "insert_after_current",
    -- 为 NvimTree 留出空间
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        separator = true,
      },
    },
  },
})

local map = vim.keymap.set

map("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
map("n", "<leader>bc", function() bufdelete() end, { desc = "Close buffer" })
map("n", "<leader>bo", bufdelete_others, { desc = "Close all buffers except current" })
map("n", "<leader>bd", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
map("n", "<leader>bf", "<cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
map("n", "<leader>bm", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer previous" })
map("n", "<leader>bi", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer next" })
map("n", "<leader>bs", "<cmd>BufferLineSortByDirectory<CR>", { desc = "Sort buffers by directory" })
map("n", "<leader>be", "<cmd>BufferLineSortByExtension<CR>", { desc = "Sort buffers by extension" })
map("n", "<leader>bt", "<cmd>BufferLineSortByRelativeDirectory<CR>", { desc = "Sort buffers by relative directory" })

-- 数字快捷跳转
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end
