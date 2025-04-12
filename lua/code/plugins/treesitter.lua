return {
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
            -- not enable treesitter hightlight
            highlight = {
                enable = false,
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
}
