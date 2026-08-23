-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- LspUI — LSP 浮窗交互（hover / rename / code action / 跳转 / 诊断）
-- 参照 main 分支配置迁移；键位适配 min 约定：
--   main 的 <leader>g* 在这里被 git 占用，改为覆盖内置同义键
--   （gd/gD/K/grr/gri/grt）+ <leader>c* 命名空间
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
map("n", "gd", lspui("definition"), { desc = "Go to definition" })
map("n", "gD", lspui("declaration"), { desc = "Go to declaration" })
map("n", "K", lspui("hover"), { desc = "Hover" })
map("n", "grr", lspui("reference"), { desc = "Find references" })
map("n", "gri", lspui("implementation"), { desc = "Go to implementation" })
map("n", "grt", lspui("type_definition"), { desc = "Go to type definition" })
map("n", "<leader>ca", lspui("code_action"), { desc = "Code action" })
map("n", "<leader>cr", lspui("rename"), { desc = "Rename" })
map("n", "<leader>ci", lspui("call_hierarchy incoming"), { desc = "Incoming calls" })
map("n", "<leader>co", lspui("call_hierarchy outgoing"), { desc = "Outgoing calls" })
map("n", "<leader>cj", lspui("diagnostic next"), { desc = "Next diagnostic (float)" })
map("n", "<leader>ck", lspui("diagnostic prev"), { desc = "Prev diagnostic (float)" })
