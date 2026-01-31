local languages = {
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
}

return
--- @type LazySpec
{
    {
        -- main 分支是完全重写版本，需要 Neovim 0.11+
        -- 不再支持懒加载
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({})
            require("nvim-treesitter").install(languages)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = languages,
                callback = function()
                    vim.treesitter.start()
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldmethod = "expr"
                    -- 实验性功能，如需启用取消下行注释
                    -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
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
        branch = "main",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "VeryLazy" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                move = { set_jumps = true },
            })
        end,
        keys = {
            {
                "<leader>]m",
                function()
                    require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
                end,
                mode = { "n", "x", "o" },
                desc = "Next function end",
            },
            {
                "<leader>[m",
                function()
                    require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
                end,
                mode = { "n", "x", "o" },
                desc = "Previous function start",
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = false,
        },
        config = function(_, opts)
            require("nvim-ts-autotag").setup({
                opts = opts,
                per_filetype = {},
            })
        end,
    },
}
