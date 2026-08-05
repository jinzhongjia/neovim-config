-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Floating Terminal — pure Lua, no plugin needed
-- Supports multiple named terminals, toggle, and navigation
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}

-- Terminal state
M.terminals = {}  -- { [id] = { buf, win, chan } }
M.current = 1
M.total = 0

-- Float window config
local function float_opts()
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.80)
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Terminal ",
    title_pos = "center",
  }
end

-- Create a new terminal
function M.new_terminal()
  M.total = M.total + 1
  local id = M.total

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "floatterm"

  -- Open float window
  local opts = float_opts()
  opts.title = string.format(" Terminal %d ", id)
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Start terminal in the buffer
  local chan = vim.fn.termopen(vim.o.shell, {
    on_exit = function()
      -- Mark as exited but don't auto-close (user might want to see output)
      if M.terminals[id] then
        M.terminals[id].exited = true
      end
    end,
  })

  M.terminals[id] = { buf = buf, win = win, chan = chan, exited = false }
  M.current = id

  -- Enter insert mode
  vim.cmd("startinsert")

  return id
end

-- Toggle terminal (show/hide)
function M.toggle(id)
  id = id or M.current

  -- If no terminals exist, create one
  if M.total == 0 then
    M.new_terminal()
    return
  end

  -- Clamp id
  if id < 1 then id = 1 end
  if id > M.total then id = M.total end

  local term = M.terminals[id]
  if not term then
    M.new_terminal()
    return
  end

  -- If window is valid and visible, hide it
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    term.win = nil
    return
  end

  -- If buffer is gone (terminal exited and wiped), create new
  if not vim.api.nvim_buf_is_valid(term.buf) then
    M.terminals[id] = nil
    M.new_terminal()
    return
  end

  -- Show the terminal in a float
  local opts = float_opts()
  opts.title = string.format(" Terminal %d ", id)
  term.win = vim.api.nvim_open_win(term.buf, true, opts)
  M.current = id
  vim.cmd("startinsert")
end

-- Go to next terminal
function M.next()
  if M.total == 0 then
    M.new_terminal()
    return
  end

  -- Hide current
  local cur = M.terminals[M.current]
  if cur and cur.win and vim.api.nvim_win_is_valid(cur.win) then
    vim.api.nvim_win_hide(cur.win)
    cur.win = nil
  end

  -- Find next valid terminal
  local next_id = M.current
  for _ = 1, M.total do
    next_id = next_id % M.total + 1
    if M.terminals[next_id] and vim.api.nvim_buf_is_valid(M.terminals[next_id].buf) then
      M.toggle(next_id)
      return
    end
  end

  -- No valid terminals, create new
  M.new_terminal()
end

-- Go to previous terminal
function M.prev()
  if M.total == 0 then
    M.new_terminal()
    return
  end

  -- Hide current
  local cur = M.terminals[M.current]
  if cur and cur.win and vim.api.nvim_win_is_valid(cur.win) then
    vim.api.nvim_win_hide(cur.win)
    cur.win = nil
  end

  -- Find prev valid terminal
  local prev_id = M.current
  for _ = 1, M.total do
    prev_id = prev_id - 1
    if prev_id < 1 then prev_id = M.total end
    if M.terminals[prev_id] and vim.api.nvim_buf_is_valid(M.terminals[prev_id].buf) then
      M.toggle(prev_id)
      return
    end
  end

  M.new_terminal()
end

-- Send command to current terminal
function M.send(cmd)
  local term = M.terminals[M.current]
  if term and term.chan then
    vim.fn.chansend(term.chan, cmd .. "\n")
  end
end

-- Expose globally
_G.FloatTerm = M

-- ── Keymaps ──────────────────────────────────────────────────
local map = vim.keymap.set

-- Toggle terminal (Ctrl+\)
map({ "n", "t" }, "<C-\\>", function()
  M.toggle()
end, { desc = "Terminal: Toggle" })

-- New terminal
map({ "n", "t" }, "<C-\\><C-n>", function()
  -- Hide current first
  local cur = M.terminals[M.current]
  if cur and cur.win and vim.api.nvim_win_is_valid(cur.win) then
    vim.api.nvim_win_hide(cur.win)
    cur.win = nil
  end
  M.new_terminal()
end, { desc = "Terminal: New" })

-- Navigate terminals
map("t", "<C-]>", function()
  M.next()
end, { desc = "Terminal: Next" })

map("t", "<C-[>", function()
  -- In terminal mode, <C-[> is Esc by default, remap to prev only with modifier
  M.prev()
end, { desc = "Terminal: Prev" })

-- Leader keymaps (normal mode)
map("n", "<leader>tn", function() M.new_terminal() end, { desc = "Terminal: New" })
map("n", "<leader>tt", function() M.toggle() end, { desc = "Terminal: Toggle" })
map("n", "<leader>t]", function() M.next() end, { desc = "Terminal: Next" })
map("n", "<leader>t[", function() M.prev() end, { desc = "Terminal: Prev" })

-- Toggle specific terminal by number (1-5)
for i = 1, 5 do
  map("n", "<leader>t" .. i, function()
    if not M.terminals[i] or not vim.api.nvim_buf_is_valid(M.terminals[i].buf) then
      -- Create terminals up to this number
      while M.total < i do
        -- Hide current if showing
        local cur = M.terminals[M.current]
        if cur and cur.win and vim.api.nvim_win_is_valid(cur.win) then
          vim.api.nvim_win_hide(cur.win)
          cur.win = nil
        end
        M.new_terminal()
        -- Hide the newly created one too (unless it's the target)
        if M.total ~= i then
          local t = M.terminals[M.total]
          if t and t.win and vim.api.nvim_win_is_valid(t.win) then
            vim.api.nvim_win_hide(t.win)
            t.win = nil
          end
        end
      end
    else
      M.toggle(i)
    end
  end, { desc = "Terminal: Toggle #" .. i })
end

-- Exit terminal mode with Esc Esc (keep single Esc for terminal apps)
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: Exit to normal mode" })
