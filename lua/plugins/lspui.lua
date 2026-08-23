-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- LspUI — LSP 浮窗交互（hover / rename / code action / 跳转 / 诊断）
-- 键位与 main 分支一致：<leader>g* 归 LSP 导航，K hover，
-- <leader>rn 重命名，<leader>ca code action（git 已挪去 <leader>G*）
-- 懒加载：setup 推迟到首次 LspAttach（签名提示 / inlay hint 是
-- 被动功能，必须在 attach 时初始化，不能等按键）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local loaded = false
local function ensure_setup()
    if loaded then
        return
    end
    loaded = true
    require("LspUI").setup({
        signature = { enable = true },
        inlay_hint = { enable = true },
        lightbulb = { enable = false },
    })
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspUILazy", { clear = true }),
    once = true,
    callback = ensure_setup,
})

-- :LspUI 命令在 setup 内部 vim.schedule 注册；冷启动首次按键时
-- 把命令也排到同一队列之后，保证命令已存在
local function lspui(args)
    local cmd = "LspUI " .. args
    return function()
        if loaded then
            vim.cmd(cmd)
        else
            ensure_setup()
            vim.schedule(function()
                vim.cmd(cmd)
            end)
        end
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
