if not vim.g.nvy then
    return
end
local o, fn = vim.o, vim.fn

o.guifont = "Maple Mono SC NF:h15"
fn.chdir(vim.fn.expand("~"))
