-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Copilot — inline ghost-text suggestions (needs Node.js)
-- setup 花 ~23ms 且要拉起 node agent，挂首次 InsertEnter：
-- ghost text 本来只在插入模式有意义
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("CopilotLazy", { clear = true }),
    once = true,
    callback = function()
        require("copilot").setup({
            suggestion = {
                enabled = true,
                auto_trigger = true,
            },
            panel = { enabled = false },
            -- Opt-in per filetype: everything off unless listed
            filetypes = {
                ["*"] = false,
                lua = true,
                go = true,
                zig = true,
                typescript = true,
                javascript = true,
                vue = true,
                c = true,
                cpp = true,
                proto = true,
                markdown = true,
                yaml = true,
                python = true,
                html = true,
                css = true,
                sql = true,
                typescriptreact = true,
                javascriptreact = true,
                dockerfile = true,
                json = true,
                ini = true,
            },
        })
    end,
})
