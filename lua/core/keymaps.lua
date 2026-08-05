-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Keymaps — built-in LSP mappings (gra/grr/grn/grt/grx/gO)
-- are already provided by Neovim 0.12 defaults
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local map = vim.keymap.set

-- ── General ──────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Better movement
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Window navigation (leader variants)
map("n", "<leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<leader>wj", "<C-w>j", { desc = "Window down" })
map("n", "<leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<leader>wl", "<C-w>l", { desc = "Window right" })

-- Window splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close split" })

-- Window resize
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize up" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize down" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize right" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
-- <leader>b* is bufferline's namespace, see plugins/bufferline.lua

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up", silent = true })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ── Search ───────────────────────────────────────────────────
-- <leader>sg/<leader>sw 等搜索键由 fzf-lua 提供（plugins/fzf.lua）；
-- 这里原有的内置 grep 版本一直被 fzf 同名映射覆盖，已删

-- Quickfix navigation
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
map("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next loclist" })
map("n", "[l", "<cmd>lprev<CR>zz", { desc = "Prev loclist" })

-- ── Diagnostics ──────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- Not under <leader>d/<leader>e: those are taken by dap.lua, fzf.lua and the file tree
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>cD", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- ── LSP (supplements built-in gra/grr/grn/grt/grx/gO) ───────
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cf", function()
    require("conform").format({ async = true })
end, { desc = "Format (conform, LSP fallback)" })
map("n", "<leader>ci", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
map("n", "<leader>co", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>cs", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- ── File explorer (nvim-tree, see plugins/file-explorer.lua) ─
-- netrw is disabled there, so :Explore no longer exists
map("n", "<leader>fe", "<cmd>NvimTreeFocus<CR>", { desc = "File explorer (focus)" })

-- Terminal keymaps → see lua/plugins/terminal.lua (floating multi-terminal)

-- ── Built-in Undotree (0.12) ─────────────────────────────────
-- 内置可选插件，必须 packadd 才有 :Undotree 命令（之前漏了，报
-- Not an editor command 就是这个原因）
vim.cmd.packadd("nvim.undotree")
map("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undo tree" })

-- ── DAP (loaded after plugin) ────────────────────────────────
-- See lua/plugins/dap.lua for DAP-specific keymaps
