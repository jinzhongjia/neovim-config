local opt = { noremap = true, silent = true }

local function map(mode, lhs, rhs)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opt)
end

return {
    map = map,
}
