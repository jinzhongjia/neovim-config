local status, comment = pcall(require, "Comment")
if not status then
    vim.notify("not found Comment")
    return
end

local status_commentstring, commentstring = pcall(require, "ts_context_commentstring")
if not status_commentstring then
    vim.notify("not found commentstring")
    return
end
vim.g.skip_ts_context_commentstring_module = true

---@diagnostic disable-next-line: missing-fields
commentstring.setup({
    enable_autocmd = false,
})

---@diagnostic disable-next-line: missing-fields
comment.setup({
    pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})
