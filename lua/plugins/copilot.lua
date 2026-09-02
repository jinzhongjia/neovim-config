-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Copilot — inline ghost-text suggestions (needs Node.js)
-- 由 lazy.nvim 在首次 InsertEnter 时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("copilot").setup({
    suggestion = {
        enabled = true,
        auto_trigger = true,
    },
    panel = { enabled = false },
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
