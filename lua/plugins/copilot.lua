return {

    -- ========== Copilot ==========
    {
        "zbirenbaum/copilot.lua",
        event = "VeryLazy",
        opts = {
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
        },
    },
}
