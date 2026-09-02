-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Plugin management via lazy.nvim
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local result = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Failed to install lazy.nvim:\n" .. result)
    end
end
vim.opt.rtp:prepend(lazypath)

local function config(name)
    return function()
        require("plugins." .. name)
    end
end

-- 本机优先加载工作区中的 omp.nvim，便于直接测试未提交改动。
-- 使用 `OMP_NVIM_DEV=0 nvim` 可临时验证 lazy-lock.json 锁定的远端版本。
local omp_dev_path = vim.fn.expand("~/code/omp.nvim")
local omp_spec = { "jinzhongjia/omp.nvim" }
if vim.env.OMP_NVIM_DEV ~= "0" and vim.fn.isdirectory(omp_dev_path) == 1 then
    omp_spec = { dir = omp_dev_path, name = "omp.nvim" }
    vim.g.omp_nvim_dev_path = omp_dev_path
end

require("lazy").setup({
    spec = {
        -- 启动期基础设施：quickfile/bigfile 必须赶在首次读文件前启用。
        {
            "folke/snacks.nvim",
            lazy = false,
            priority = 1000,
            config = config("snacks"),
        },
        {
            "Mofiqul/vscode.nvim",
            lazy = false,
            priority = 900,
            config = config("colorscheme"),
        },

        -- 读文件前注册 FileType/LSP 回调，避免错过首个 buffer。
        {
            "nvim-treesitter/nvim-treesitter",
            branch = "main",
            event = { "BufReadPre", "BufNewFile" },
            dependencies = {
                { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
            },
            config = config("treesitter"),
        },
        {
            "saghen/blink.cmp",
            version = "1.*",
            event = { "BufReadPre", "BufNewFile", "InsertEnter", "CmdlineEnter" },
            config = config("completion"),
        },
        {
            "neovim/nvim-lspconfig",
            lazy = false,
            dependencies = { "saghen/blink.cmp", "williamboman/mason.nvim" },
        },
        {
            "folke/lazydev.nvim",
            ft = "lua",
            config = config("lazydev"),
        },
        {
            "echasnovski/mini.diff",
            event = { "BufReadPre", "BufNewFile" },
            config = config("diff"),
        },

        -- UI：启动完成后再加载，不阻塞首屏。
        {
            "akinsho/bufferline.nvim",
            event = "VeryLazy",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = config("bufferline"),
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            config = config("which-key"),
        },
        {
            "echasnovski/mini.surround",
            event = "VeryLazy",
            config = config("surround"),
        },

        -- 命令/按键触发的低频功能。
        {
            "nvim-tree/nvim-tree.lua",
            cmd = { "NvimTreeOpen", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
            keys = {
                { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree" },
                { "<leader>fe", "<cmd>NvimTreeFocus<cr>", desc = "File explorer (focus)" },
            },
            dependencies = { "nvim-tree/nvim-web-devicons" },
            init = function()
                vim.g.loaded_netrw = 1
                vim.g.loaded_netrwPlugin = 1
                vim.api.nvim_create_autocmd("VimEnter", {
                    group = vim.api.nvim_create_augroup("NvimTreeDirOpen", { clear = true }),
                    callback = function()
                        local arg = vim.fn.argv(0)
                        if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
                            require("lazy").load({ plugins = { "nvim-tree.lua" } })
                            vim.cmd.NvimTreeOpen()
                        end
                    end,
                })
            end,
            config = config("file-explorer"),
        },
        {
            "hedyhli/outline.nvim",
            cmd = { "Outline", "OutlineOpen", "OutlineFocus" },
            keys = {
                { "<leader>ao", "<cmd>Outline<cr>", desc = "Toggle outline" },
                { "<leader>aO", "<cmd>OutlineFocus<cr>", desc = "Outline focus" },
            },
            config = config("outline"),
        },
        {
            "jinzhongjia/LspUI.nvim",
            event = "LspAttach",
            keys = {
                "K",
                "<leader>rn",
                "<leader>ca",
                "<leader>gd",
                "<leader>gD",
                "<leader>gi",
                "<leader>gr",
                "<leader>gy",
                "<leader>gk",
                "<leader>gj",
                "<leader>gh",
                "<leader>gl",
            },
            config = config("lspui"),
        },
        {
            "folke/flash.nvim",
            keys = {
                { "s", mode = { "n", "x", "o" } },
                { "S", mode = { "n", "x", "o" } },
            },
            config = config("flash"),
        },
        {
            "Wansmer/treesj",
            keys = { "<leader>m" },
            config = config("treesj"),
        },
        {
            "williamboman/mason.nvim",
            cmd = {
                "Mason",
                "MasonInstall",
                "MasonUninstall",
                "MasonUpdate",
                "MasonLog",
                "MasonInstallAll",
                "MasonUpdateAll",
                "MasonStatus",
            },
            config = config("mason"),
        },
        {
            "tpope/vim-fugitive",
            cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite" },
            keys = {
                "<leader>Gg",
                "<leader>Gc",
                "<leader>Gp",
                "<leader>GP",
                "<leader>Gb",
                "<leader>Gf",
                "<leader>Gw",
                "<leader>Gr",
                "<leader>Gd",
            },
            config = config("git"),
        },
        {
            "NeogitOrg/neogit",
            cmd = "Neogit",
            keys = { "<leader>ng" },
            dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
            config = config("neogit"),
        },
        {
            "stevearc/conform.nvim",
            cmd = "ConformInfo",
            config = config("format"),
        },
        {
            "mfussenegger/nvim-dap",
            keys = {
                "<leader>db",
                "<leader>dB",
                "<leader>dl",
                "<leader>dc",
                "<leader>dn",
                "<leader>dp",
                "<leader>dt",
                "<leader>dr",
                "<leader>dj",
                "<leader>di",
                "<leader>do",
                "<leader>dO",
                "<leader>dR",
                "<leader>du",
                { "<leader>de", mode = { "n", "v" } },
                "<leader>dC",
                "<leader>dg",
                "<leader>dw",
                "<F5>",
                "<F10>",
                "<F11>",
                "<F12>",
            },
            dependencies = {
                "nvim-neotest/nvim-nio",
                "rcarriga/nvim-dap-ui",
            },
            config = config("dap"),
        },

        -- 事件和文件类型触发。
        {
            "saghen/blink.pairs",
            version = "*",
            event = "InsertEnter",
            dependencies = { "saghen/blink.lib" },
            build = function()
                require("blink.pairs").download():pwait(60000)
            end,
            config = config("pairs"),
        },
        {
            "zbirenbaum/copilot.lua",
            event = "InsertEnter",
            config = config("copilot"),
        },
        {
            "max397574/better-escape.nvim",
            event = "InsertEnter",
            config = config("escape"),
        },
        {
            "nacro90/numb.nvim",
            event = "CmdlineEnter",
            config = config("numb"),
        },
        {
            "hat0uma/csvview.nvim",
            ft = { "csv", "tsv" },
            config = config("csvview"),
        },
        {
            "folke/todo-comments.nvim",
            event = { "BufReadPost", "BufNewFile" },
            dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
            config = config("todo"),
        },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            ft = { "markdown", "opencode_output", "omp_output" },
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
                "saghen/blink.cmp",
            },
            config = config("markdown"),
        },

        -- AI 前端统一推迟到 VeryLazy；Copilot 单独在 InsertEnter 加载。
        {
            "coder/claudecode.nvim",
            event = "VeryLazy",
            dependencies = {
                "folke/snacks.nvim",
                "sudo-tee/opencode.nvim",
                omp_spec,
            },
            config = config("ai"),
        },
    },
    defaults = {
        lazy = true,
        version = false,
    },
    install = {
        colorscheme = { "vscode", "habamax" },
    },
    checker = {
        enabled = false,
    },
    change_detection = {
        notify = false,
    },
    ui = {
        border = "rounded",
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- 仓库内置模块和基于 Snacks 的轻量键位不进入插件依赖图。
require("plugins.statusline")
require("plugins.terminal")
require("plugins.ui2")
require("plugins.difftool")
require("plugins.implements")
