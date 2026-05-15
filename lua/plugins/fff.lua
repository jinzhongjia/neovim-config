return
--- @type LazySpec
{
    {
        "dmtrKovalenko/fff.nvim",
        build = function()
            -- 下载预编译的 fff 二进制文件，或回退到 cargo build
            require("fff.download").download_or_build_binary()
        end,
        lazy = false, -- 插件会自行延迟初始化
        opts = {
            -- 搜索模式: plain（默认）、regex、fuzzy，<S-Tab> 切换
            grep = {
                smart_case = true,
                modes = { "plain", "regex", "fuzzy" },
            },
            -- 频率+最近程度排序（frecency），越常打开的文件排名越高
            frecency = {
                enabled = true,
            },
            -- 查询历史记录
            history = {
                enabled = true,
            },
            -- 布局
            layout = {
                height = 0.8,
                width = 0.8,
                prompt_position = "bottom",
                preview_position = "right",
            },
            -- 预览
            preview = {
                enabled = true,
                line_numbers = false,
            },
            -- 快捷键映射（大部分与 blink.cmp 一致的快捷键）
            keymaps = {
                close = "<Esc>",
                select = "<CR>",
                select_split = "<C-s>",
                select_vsplit = "<C-v>",
                select_tab = "<C-t>",
                move_up = { "<Up>", "<C-p>", "<C-k>" },
                move_down = { "<Down>", "<C-n>", "<C-j>" },
                preview_scroll_up = "<C-u>",
                preview_scroll_down = "<C-d>",
                toggle_select = "<Tab>",
                send_to_quickfix = "<C-q>",
                cycle_grep_modes = "<S-Tab>",
            },
            debug = {
                enabled = false,
                show_scores = false,
            },
        },
        keys = {
            -- ===== FFF 文件查找 =====
            {
                "<leader>ff",
                function()
                    require("fff").find_files()
                end,
                desc = "Find files (FFF)",
            },
            {
                "<leader>fF",
                function()
                    require("fff").find_files({ ignore = {} })
                end,
                desc = "Find files (all, FFF)",
            },
            -- ===== FFF 内容搜索 =====
            {
                "<leader>fg",
                function()
                    require("fff").live_grep()
                end,
                desc = "Live grep (FFF)",
            },
            {
                "<leader>/",
                function()
                    require("fff").live_grep()
                end,
                desc = "Live grep (FFF)",
            },
            {
                "<leader>*",
                function()
                    require("fff").live_grep({ query = vim.fn.expand("<cword>") })
                end,
                desc = "Grep cursor word (FFF)",
            },
            -- ===== FFF 其他搜索 =====
            {
                "<leader>fz",
                function()
                    require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
                end,
                desc = "Fuzzy grep (FFF)",
            },
        },
    },
}
