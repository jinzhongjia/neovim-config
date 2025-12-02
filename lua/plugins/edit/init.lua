--- @type LazySpec
local M = {

    {
        "jinzhongjia/hlargs.nvim",
        enabled = true,
        branch = "fix_err",
        dev = true,
        event = "LspAttach", -- LSP 加载时触发
        config = function()
            require("hlargs").setup()
            vim.api.nvim_create_augroup("LspAttach_hlargs", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = "LspAttach_hlargs",
                callback = function(args)
                    if not (args.data and args.data.client_id) then
                        return
                    end

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local caps = client.server_capabilities
                    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
                        require("hlargs").disable_buf(args.buf)
                    end
                end,
            })
        end,
    },
    {
        "Wansmer/treesj",
        -- 按键触发即可
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
        opts = {},
    },
    {
        "ckolkey/ts-node-action",
        dependencies = { "nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            {
                "<leader>na",
                function()
                    require("ts-node-action").node_action()
                end,
                desc = "Trigger Node Action",
            },
        },
        config = function()
            local ts_node_action = require("ts-node-action")
            ts_node_action.setup({
                go = {
                    -- err == SomeError -> errors.Is(err, SomeError)
                    -- err != SomeError -> !errors.Is(err, SomeError)
                    ["binary_expression"] = function(node)
                        local helpers = require("ts-node-action.helpers")
                        local text = helpers.node_text(node)

                        local err_var, err_type = text:match("(%w+)%s*==%s*([%w%.]+)")
                        if err_var and err_type and err_type ~= "nil" and not err_type:match("^%d") then
                            return string.format("errors.Is(%s, %s)", err_var, err_type)
                        end

                        err_var, err_type = text:match("(%w+)%s*!=%s*([%w%.]+)")
                        if err_var and err_type and err_type ~= "nil" and not err_type:match("^%d") then
                            return string.format("!errors.Is(%s, %s)", err_var, err_type)
                        end
                    end,
                },
            })
        end,
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = { "BufReadPost", "BufNewFile" }, -- 打开文件时加载
        opts = {
            filetypes = {
                "css",
                "javascript",
                "html",
            },
        },
    },
    {
        "echasnovski/mini.move",
        version = "*",
        -- 按键触发时才需要,通过 keys 定义
        keys = {
            { "<M-h>", mode = { "n", "v" } },
            { "<M-j>", mode = { "n", "v" } },
            { "<M-k>", mode = { "n", "v" } },
            { "<M-l>", mode = { "n", "v" } },
        },
        opts = {},
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = { "BufReadPost", "BufNewFile" }, -- 编辑文件时加载
        opts = {},
    },
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "ModeChanged", -- 模式切换时加载(进入 visual 模式)
        config = true,
    },
    {
        "qwavies/smart-backspace.nvim",
        event = { "InsertEnter", "CmdlineEnter" }, -- 进入插入或命令行模式时加载
        opts = {
            enabled = true, -- 启用智能退格
            silent = true, -- 切换时不显示通知
            disabled_filetypes = { -- 禁用智能退格的文件类型
                "markdown",
                "text",
            },
        },
        keys = {
            {
                "<leader>bs",
                "<cmd>SmartBackspaceToggle<CR>",
                desc = "Toggle Smart Backspace",
                mode = "n",
            },
        },
    },
}

-- all plugins
__arr_concat(M, require("plugins.edit.comment"))
__arr_concat(M, require("plugins.edit.complete"))
__arr_concat(M, require("plugins.edit.fold"))
__arr_concat(M, require("plugins.edit.format"))
__arr_concat(M, require("plugins.edit.indent"))
__arr_concat(M, require("plugins.edit.lint"))
__arr_concat(M, require("plugins.edit.outline"))
__arr_concat(M, require("plugins.edit.search"))
__arr_concat(M, require("plugins.edit.snippet"))
__arr_concat(M, require("plugins.edit.debug"))

return M
