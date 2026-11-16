-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Autocommands
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Resize splits on window resize
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Remove trailing whitespace on save
-- 不用 `%s/\s\+$//e`：它无条件重写整个缓冲区（50000 行实测 142ms），
-- 还要配一套光标保存/恢复。逐行比对、只重写真正命中的行，5 万行降到
-- ~22ms，且光标、marks、折叠都不用动。多次 set_lines 仍是一个 undo 块。
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  callback = function(event)
    local buf = event.buf
    if not vim.bo[buf].modifiable then
      return
    end
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      -- 先用 find 探一下：没有尾随空白时比 gsub 便宜，绝大多数行走这条路
      if line:find("%s$") then
        vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { (line:gsub("%s+$", "")) })
      end
    end
  end,
})

-- Return to last edit position
autocmd("BufReadPost", {
  group = augroup("LastPosition", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- :<行号> 输入过程中预览目标行（替掉 numb.nvim）
-- 离开 cmdline 时先还原视图：回车的话由命令本身跳转，取消则留在原位
local peek_view
autocmd("CmdlineChanged", {
  group = augroup("PeekLine", { clear = true }),
  pattern = ":",
  callback = function()
    local line = tonumber(vim.fn.getcmdline())
    if line then
      peek_view = peek_view or vim.fn.winsaveview()
      line = math.max(1, math.min(line, vim.api.nvim_buf_line_count(0)))
      vim.api.nvim_win_set_cursor(0, { line, 0 })
      vim.cmd("normal! zz")
      vim.cmd.redraw()
    elseif peek_view then
      vim.fn.winrestview(peek_view)
      peek_view = nil
      vim.cmd.redraw()
    end
  end,
})
autocmd("CmdlineLeave", {
  group = "PeekLine",
  pattern = ":",
  callback = function()
    if peek_view then
      vim.fn.winrestview(peek_view)
      peek_view = nil
    end
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories on save (0.12: :wall ++p also works)
autocmd("BufWritePre", {
  group = augroup("AutoMkdir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Terminal settings
autocmd("TermOpen", {
  group = augroup("TermSettings", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

-- Filetype-specific indent
-- Lua keeps the default 4 spaces, matching .stylua.toml.
autocmd("FileType", {
  group = augroup("IndentOverrides", { clear = true }),
  pattern = { "html", "css", "javascript", "typescript", "typescriptreact", "json", "yaml" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})
