local opt = { noremap = true, silent = true }

--- @param name string
--- @return boolean
function _G.__check_exec(name)
    return vim.fn.executable(name) == 1
end

function _G.__key_bind(mode, lhs, rhs)
    vim.api.nvim_set_keymap(mode, lhs, rhs, opt)
end

