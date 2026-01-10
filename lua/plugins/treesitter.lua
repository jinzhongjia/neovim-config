return
--- @type LazySpec
{
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
        lazy = false, -- main 分支不支持 lazy-loading
        build = ":TSUpdate",
        branch = "main",
        config = function()
            -- main 分支的配置非常简单，只需指定 install_dir（可选）
            require("nvim-treesitter").setup({
                -- 可选：指定 parser 安装目录
                -- install_dir = vim.fn.stdpath('data') .. '/site',
            })

            -- 安装常用的 parsers（首次运行时）
            -- 之后可以使用 :TSInstall <language> 命令安装其他 parsers
            local parsers = {
                "c",
                "go",
                "lua",
                "vim",
                "vimdoc",
                "bash",
                "c_sharp",
                "cmake",
                "cpp",
                "comment",
                "css",
                "diff",
                "dockerfile",
                "git_config",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "gomod",
                "gosum",
                "gowork",
                "hjson",
                "html",
                "http",
                "ini",
                "javascript",
                "json",
                "json5",
                "jsdoc",
                "jsonc",
                "latex",
                "luadoc",
                "luap",
                "make",
                "markdown",
                "meson",
                "ninja",
                "nix",
                "norg",
                "proto",
                "python",
                "pug",
                "regex",
                "rust",
                "scss",
                "sql",
                "svelte",
                "toml",
                "tsx",
                "typescript",
                "typst",
                "vue",
                "yaml",
                "zig",
                "prisma",
            }

            -- 异步安装 parsers（如果尚未安装）
            require("nvim-treesitter").install(parsers)

            -- 全局启用 treesitter highlighting
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        branch = "main",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "VeryLazy" },
        opts = {
            multiline_threshold = 5,
        },
        config = function(_, opts)
            require("treesitter-context").setup(opts)
            -- 添加底部下划线边界，视觉上区分 context 窗口和代码区域
            vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
            vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true, sp = "Grey" })
        end,
        keys = {
            -- stylua: ignore
            { "<leader>[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "jumping to context(upwards)" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "VeryLazy" },
        config = function()
            -- 配置
            require("nvim-treesitter-textobjects").setup({
                move = {
                    set_jumps = true, -- 在跳转列表中记录跳转
                },
            })

            -- 键映射
            local move = require("nvim-treesitter-textobjects.move")

            -- 跳转到下一个函数/类/参数的开始
            vim.keymap.set({ "n", "x", "o" }, "<leader>]m", function()
                move.goto_next_start("@function.outer", "textobjects")
            end, { desc = "Next function start" })
            vim.keymap.set({ "n", "x", "o" }, "]c", function()
                move.goto_next_start("@class.outer", "textobjects")
            end, { desc = "Next class start" })
            vim.keymap.set({ "n", "x", "o" }, "]a", function()
                move.goto_next_start("@parameter.inner", "textobjects")
            end, { desc = "Next parameter start" })

            -- 跳转到下一个函数/类/参数的结束
            vim.keymap.set({ "n", "x", "o" }, "<leader>]M", function()
                move.goto_next_end("@function.outer", "textobjects")
            end, { desc = "Next function end" })
            vim.keymap.set({ "n", "x", "o" }, "]C", function()
                move.goto_next_end("@class.outer", "textobjects")
            end, { desc = "Next class end" })
            vim.keymap.set({ "n", "x", "o" }, "]A", function()
                move.goto_next_end("@parameter.inner", "textobjects")
            end, { desc = "Next parameter end" })

            -- 跳转到上一个函数/类/参数的开始
            vim.keymap.set({ "n", "x", "o" }, "<leader>[m", function()
                move.goto_previous_start("@function.outer", "textobjects")
            end, { desc = "Previous function start" })
            vim.keymap.set({ "n", "x", "o" }, "[c", function()
                move.goto_previous_start("@class.outer", "textobjects")
            end, { desc = "Previous class start" })
            vim.keymap.set({ "n", "x", "o" }, "[a", function()
                move.goto_previous_start("@parameter.inner", "textobjects")
            end, { desc = "Previous parameter start" })

            -- 跳转到上一个函数/类/参数的结束
            vim.keymap.set({ "n", "x", "o" }, "<leader>[M", function()
                move.goto_previous_end("@function.outer", "textobjects")
            end, { desc = "Previous function end" })
            vim.keymap.set({ "n", "x", "o" }, "[C", function()
                move.goto_previous_end("@class.outer", "textobjects")
            end, { desc = "Previous class end" })
            vim.keymap.set({ "n", "x", "o" }, "[A", function()
                move.goto_previous_end("@parameter.inner", "textobjects")
            end, { desc = "Previous parameter end" })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- 全局默认配置
            enable_close = true,           -- 自动关闭标签
            enable_rename = true,          -- 自动重命名配对的标签
            enable_close_on_slash = false, -- 在输入 </ 时自动关闭
        },
        config = function(_, opts)
            require("nvim-ts-autotag").setup({
                opts = opts,
                -- 可以针对特定文件类型进行配置覆盖
                per_filetype = {
                    -- 例如: ["html"] = { enable_close = false }
                },
                -- 如果需要支持额外的语言，可以添加别名
                -- aliases = {
                --     ["your_language"] = "html",
                -- }
            })
        end,
    },
}
