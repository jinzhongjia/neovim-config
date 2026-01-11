return
--- @type LazySpec
{
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        event = { "VeryLazy" },
        build = ":TSUpdate",
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        opts = {
            ensure_installed = {
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
                "luadoc",
                "luap",
                "make",
                "markdown",
                "meson",
                "ninja",
                "nix",
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
                "vue",
                "yaml",
                "zig",
                "prisma",
            },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = false },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gnn", -- set to `false` to disable one of the mappings
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                },
            },
        },
        ---@param opts TSConfig
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        branch = "master",
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
        branch = "master",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "VeryLazy" },
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_end = {
                            ["<leader>]m"] = { query = "@function.outer", desc = "Next function end" },
                        },
                        goto_previous_start = {
                            ["<leader>[m"] = { query = "@function.outer", desc = "Previous function start" },
                        },
                    },
                },
            })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- 全局默认配置
            enable_close = true, -- 自动关闭标签
            enable_rename = true, -- 自动重命名配对的标签
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
