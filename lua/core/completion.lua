-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Native completion (0.12) — no nvim-cmp needed
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Enable LSP completion on attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspCompletion", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- Completion keymaps for navigating the popup
vim.keymap.set("i", "<C-n>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<C-x><C-o>"
  end
end, { expr = true, desc = "Next completion / trigger" })

vim.keymap.set("i", "<C-p>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  else
    return "<C-x><C-o>"
  end
end, { expr = true, desc = "Prev completion / trigger" })

-- Confirm with <CR>
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  else
    return "<CR>"
  end
end, { expr = true, desc = "Confirm completion or newline" })

-- Cancel with <C-e>
vim.keymap.set("i", "<C-e>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-e>"
  else
    return "<End>"
  end
end, { expr = true, desc = "Cancel completion or end of line" })

-- Tab to navigate snippets or completion
vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet and vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<CR>"
  else
    return "<Tab>"
  end
end, { expr = true, desc = "Tab completion" })

vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet and vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<CR>"
  else
    return "<S-Tab>"
  end
end, { expr = true, desc = "Shift-Tab completion" })
