-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Statusline — built-in (no lualine needed)
-- Uses 0.12 features: vim.diagnostic.status(), vim.ui.progress_status()
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Mode map
local mode_map = {
  ["n"]  = "NOR",
  ["no"] = "O-P",
  ["v"]  = "VIS",
  ["V"]  = "V-L",
  [""] = "V-B",
  ["s"]  = "SEL",
  ["S"]  = "S-L",
  [""] = "S-B",
  ["i"]  = "INS",
  ["R"]  = "REP",
  ["Rv"] = "V-R",
  ["c"]  = "CMD",
  ["cv"] = "VIM",
  ["ce"] = "EXC",
  ["r"]  = "PRM",
  ["rm"] = "MOR",
  ["r?"] = "CON",
  ["!"]  = "SHL",
  ["t"]  = "TRM",
}

function _G.statusline()
  local parts = {}

  -- Mode
  local mode = vim.api.nvim_get_mode().mode
  local mode_str = mode_map[mode] or mode:upper()
  table.insert(parts, " " .. mode_str .. " ")

  -- Git branch (use built-in if available)
  local branch = vim.b.gitsigns_head or ""
  if branch ~= "" then
    table.insert(parts, "  " .. branch)
  end

  -- File info
  table.insert(parts, " %f")
  table.insert(parts, "%m%r")

  -- Separator
  table.insert(parts, "%=")

  -- LSP progress (0.12)
  local progress = vim.ui.progress_status and vim.ui.progress_status() or ""
  if progress and progress ~= "" then
    table.insert(parts, progress .. " ")
  end

  -- Diagnostics (0.12: vim.diagnostic.status())
  local diag_status = vim.diagnostic.status and vim.diagnostic.status() or ""
  if diag_status and diag_status ~= "" then
    table.insert(parts, diag_status .. " ")
  end

  -- LSP clients
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    local names = {}
    for _, c in ipairs(clients) do
      table.insert(names, c.name)
    end
    table.insert(parts, " [" .. table.concat(names, ",") .. "]")
  end

  -- Filetype
  local ft = vim.bo.filetype
  if ft ~= "" then
    table.insert(parts, " " .. ft)
  end

  -- Position
  table.insert(parts, " %l:%c ")
  table.insert(parts, " %p%% ")

  return table.concat(parts)
end

vim.o.statusline = "%!v:lua.statusline()"
