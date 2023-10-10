local status, comment = pcall(require, "Comment")
if not status then
    vim.notify("not found Comment")
    return
end

local status_commentstring, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
if not status_commentstring then
    vim.notify("not found commentstring")
    return
end

---@diagnostic disable-next-line: missing-fields
comment.setup({
    pre_hook = commentstring.create_pre_hook(),
})
