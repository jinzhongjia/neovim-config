-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Keymaps — built-in LSP mappings (gra/grr/grn/grt/grx/gO)
-- are already provided by Neovim 0.12 defaults
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local map = vim.keymap.set

-- ── General ──────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>l", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Better movement
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- 插入模式连打 jk / jj 回 normal（替掉 better-escape.nvim）
-- 不用 imap jk：那会让 j 等 timeoutlen 才上屏。j 立即输入，第二键在
-- timeoutlen 内到达再退格 + Esc；若期间只有 j 和退格这两次改动（靠
-- changedtick 判定），还原成未修改状态。
-- 用 on_key 记上一个键而不是读缓冲区：宏回放时映射求值早于字符落盘。
local esc_at, esc_tick, last_key = 0, nil, nil
vim.on_key(function(key)
    last_key = key
end)
local function escape_on(key)
    return function()
        if last_key == "j" and vim.uv.now() - esc_at < vim.o.timeoutlen then
            esc_at = 0
            local buf, tick = vim.api.nvim_get_current_buf(), esc_tick
            vim.schedule(function()
                if tick and vim.api.nvim_buf_is_valid(buf) and vim.b[buf].changedtick == tick + 2 then
                    vim.bo[buf].modified = false
                end
            end)
            return "<BS><Esc>"
        end
        if key == "j" then
            esc_at, esc_tick = vim.uv.now(), not vim.bo.modified and vim.b.changedtick or nil
        end
        return key
    end
end
map("i", "j", escape_on("j"), { expr = true })
map("i", "k", escape_on("k"), { expr = true })

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
-- <leader>fg / <leader>/ / <leader>* 等搜索键由 snacks picker 提供
--（plugins/snacks.lua，键位同 main）

-- Quickfix navigation
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
map("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next loclist" })
map("n", "[l", "<cmd>lprev<CR>zz", { desc = "Prev loclist" })

-- ── Diagnostics ──────────────────────────────────────────────
-- [d / ]d 是 0.10+ 内置默认（支持 count），不再自建（旧实现用的
-- goto_prev/goto_next 已废弃）
-- Not under <leader>d/<leader>e: those are taken by dap.lua, snacks.lua and the file tree
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>cD", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- ── LSP ──────────────────────────────────────────────────────
-- K/<leader>rn/<leader>ca 与 <leader>gd/gD/gi/gr/gy/gk/gj/gh/gl
-- 由 LspUI 提供（plugins/lspui.lua，键位同 main）；内置默认 gr* 仍可用
map("n", "<leader>f", function()
    require("conform").format({ async = true })
end, { desc = "Format buffer" })
map("n", "<leader>cs", vim.lsp.buf.signature_help, { desc = "Signature help" })
-- 插入模式签名帮助：0.11+ 内置 <C-s>，不再自建

-- ── File explorer ────────────────────────────────────────────
-- <leader>e / <leader>fe 都在 plugins/file-explorer.lua（懒加载）

-- Terminal keymaps → see lua/plugins/terminal.lua (floating multi-terminal)

-- ── Built-in Undotree (0.12) ─────────────────────────────────
-- 内置可选插件，必须 packadd 才有 :Undotree 命令（之前漏了，报
-- Not an editor command 就是这个原因）
vim.cmd.packadd("nvim.undotree")
map("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undo tree" })

-- ── DAP (loaded after plugin) ────────────────────────────────
-- See lua/plugins/dap.lua for DAP-specific keymaps
