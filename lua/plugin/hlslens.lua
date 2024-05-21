local status, hlslens = pcall(require, "hlslens")
if not status then
    vim.notify("not found hlslens")
    return
end

hlslens.setup({
    nearest_only = true,
})

--- @param lhs string
--- @param fn function
local function key_map_fn(lhs, fn)
    vim.api.nvim_set_keymap("n", lhs, "", {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_exec2(fn(), {})
            hlslens.start()
        end,
    })
end

local function key_map(lhs, command)
    key_map_fn(lhs, function()
        return command
    end)
end

key_map_fn("n", function()
    return string.format("normal! %dn", vim.v.count1)
end)
key_map_fn("N", function()
    return string.format("normal! %dN", vim.v.count1)
end)
key_map("*", "*")
key_map("#", "#")
key_map("g*", "g*")
key_map("g#", "g#")
vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", { noremap = true, silent = true })
