local status, guard = pcall(require, "guard")
if not status then
    vim.notify("not found guard")
    return
end

local ft = require("guard.filetype")

ft("c"):fmt("clang-format")
ft("go"):fmt("gofumpt"):append("goimports")
ft("typescript,javascript,typescriptreact"):fmt("prettier")
-- ft("lua"):fmt("stylua"):lint("luacheck")
ft("lua"):fmt("stylua")
ft("zig"):fmt("zigfmt")
ft("json"):fmt("jq")
ft("sh"):fmt("shfmt")
ft("rust"):fmt("rustfmt")
ft("python"):fmt("black"):append("isort")

guard.setup({
    -- the only options for the setup function
    fmt_on_save = false,
    -- Use lsp if no formatter was defined for this filetype
    lsp_as_default_formatter = true,
})
