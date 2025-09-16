return
--- @type LazySpec
{
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
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
            },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>", -- set to `false` to disable one of the mappings
                    node_incremental = "<CR>",
                    scope_incremental = "<BS>",
                    node_decremental = "<TAB>",
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
        dependencies = "nvim-treesitter/nvim-treesitter-context",
        event = { "VeryLazy" },
        opts = {
            multiline_threshold = 5,
        },
        keys = {
            -- stylua: ignore
            { "[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "jumping to context(upwards)" },
        },
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
