-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ui2 — Neovim 0.12 experimental core UI redesign
-- Eliminates "Press ENTER" interruptions, highlights cmdline
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local ok, ui2 = pcall(require, "vim._core.ui2")
if not ok or not ui2 then
  return
end

ui2.enable({
  msg = {
    -- Route LSP progress to the ephemeral msg window instead of the cmdline,
    -- so it never sits on top of what you are typing.
    targets = { lsp_progress = "msg" },
  },
})

-- ── LSP progress, rendered by ui2 ─────────────────────────────
-- Built from the event payload rather than vim.lsp.status(), because that
-- function *consumes* client.progress — whoever calls it first wins and every
-- other consumer gets an empty string.
-- A stable `id` makes ui2 replace the line in place instead of stacking one
-- message per update.
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("LspProgressUI", { clear = true }),
  callback = function(args)
    local value = args.data and args.data.params and args.data.params.value
    -- "end" needs no echo: ui2 fades the last line after msg.timeout (4s)
    if type(value) ~= "table" or not value.kind or value.kind == "end" then
      return
    end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local text = ("%s: %s"):format(client and client.name or "lsp", value.title or "")
    if value.message then
      text = text .. " " .. value.message
    end
    if value.percentage then
      text = ("%s (%d%%)"):format(text, value.percentage)
    end

    vim.api.nvim_echo({ { text } }, false, { kind = "lsp_progress", id = "lsp_progress" })
  end,
})
