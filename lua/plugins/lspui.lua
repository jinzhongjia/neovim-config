-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- LspUI — LSP 浮窗交互
-- 由 lazy.nvim 在 LspAttach 或首次按键时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("LspUI").setup({
    signature = { enable = true },
    inlay_hint = { enable = true },
    lightbulb = { enable = false },
})

-- 插件在 setup() 内通过 vim.schedule 注册 :LspUI，首个按键也延后一拍执行。
local function lspui(args)
    return function()
        vim.schedule(function()
            vim.cmd("LspUI " .. args)
        end)
    end
end

local map = vim.keymap.set
map("n", "K", lspui("hover"), { desc = "Hover information" })
map("n", "<leader>rn", lspui("rename"), { desc = "Rename symbol" })
map("n", "<leader>ca", lspui("code_action"), { desc = "Code action" })
map("n", "<leader>gd", lspui("definition"), { desc = "Go to definition" })
map("n", "<leader>gD", lspui("declaration"), { desc = "Go to declaration" })
map("n", "<leader>gi", lspui("implementation"), { desc = "Go to implementation" })
map("n", "<leader>gr", lspui("reference"), { desc = "Find references" })
map("n", "<leader>gy", lspui("type_definition"), { desc = "Go to type definition" })
map("n", "<leader>gk", lspui("diagnostic prev"), { desc = "Previous diagnostic" })
map("n", "<leader>gj", lspui("diagnostic next"), { desc = "Next diagnostic" })
map("n", "<leader>gh", lspui("call_hierarchy incoming"), { desc = "Call hierarchy (callers)" })
map("n", "<leader>gl", lspui("call_hierarchy outgoing"), { desc = "Call hierarchy (callees)" })
