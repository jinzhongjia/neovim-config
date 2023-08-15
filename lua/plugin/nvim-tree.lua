local status, nvim_tree = pcall(require, "nvim-tree")
if not status then
    vim.notify("not found nvim-tree")
    return
end

local tool = require("tool")

nvim_tree.setup({
    filters = {
        dotfiles = true,
        custom = { "node_modules" },
    },
    actions = {
        open_file = {
            -- 首次打开大小适配
            resize_window = true,
            -- 打开文件时关闭
            quit_on_open = true,
        },
    },
    -- keymap override
    on_attach = function(buffer_id)
        local api = require("nvim-tree.api")

        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = buffer_id, noremap = true, silent = true, nowait = true }
        end
        -- use add default mappings
        api.config.mappings.default_on_attach(buffer_id)

        vim.keymap.set("n", "sv", api.node.open.vertical, opts("Open: Vertical Split"))
        vim.keymap.set("n", "sh", api.node.open.horizontal, opts("Open: Horizontal Split"))
    end,
})

tool.map("n", "<leader>e", ":NvimTreeToggle<CR>")
