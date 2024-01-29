local status, lsp_signature = pcall(require, "lsp_signature")
if not status then
    vim.notify("not found lsp_signature")
    return
end

lsp_signature.setup({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
        border = "rounded",
    },
    transparency = 75,
    auto_close_after = 2,
    toggle_key = "<M-x>",
    select_signature_key = "<M-n>",
})
