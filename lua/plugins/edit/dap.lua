---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
    local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
    local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

    config = vim.deepcopy(config)
    ---@cast args string[]
    config.args = function()
        local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
        if config.type and config.type == "java" then
            ---@diagnostic disable-next-line: return-type-mismatch
            return new_args
        end
        return require("dap.utils").splitstr(new_args)
    end
    return config
end

return
--- @type LazySpec
{
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        dependencies = {
            {
                "Weissle/persistent-breakpoints.nvim",
                config = function()
                    require("persistent-breakpoints").setup({
                        load_breakpoints_event = { "BufReadPost" },
                    })
                end,
            },
        },
        -- stylua: ignore
        keys = {
            { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require('persistent-breakpoints.api').toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
            { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
            { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end, desc = "Down" },
            { "<leader>dk", function() require("dap").up() end, desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end, desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
            { "<leader>dn", function () require('persistent-breakpoints.api').clear_all_breakpoints() end , desc = "Clear All BreakPoint"}
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "mfussenegger/nvim-dap",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup({
                element_mappings = {
                    scopes = { open = "<CR>", edit = "e", expand = "o", repl = "r" },
                },
                layouts = {
                    {
                        elements = {
                            -- Elements can be strings or table with id and size keys.
                            { id = "scopes", size = 0.4 },
                            "stacks",
                            "watches",
                            "breakpoints",
                            "console",
                        },
                        size = 0.35, -- 40 columns
                        position = "left",
                    },
                    {
                        elements = { "repl" },
                        size = 0.25, -- 25% of total lines
                        position = "bottom",
                    },
                },
                floating = {
                    max_height = nil, -- These can be integers or a float between 0 and 1.
                    max_width = nil, -- Floats will be treated as percentage of your screen.
                    border = "rounded", -- Border style. Can be "single", "double" or "rounded"
                    mappings = { close = { "q", "<Esc>" } },
                },
            })

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        event = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        config = function()
            local vt = require("nvim-dap-virtual-text")
            vt.setup({ commented = true })

            vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
            vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#31353f" })
            vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379", bg = "#31353f" })


             vim.fn.sign_define(
                 "DapBreakpoint",
                 { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
             )
            -- vim.fn.sign_define(
            --     "DapBreakpointCondition",
            --     { text = "ﳁ", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
            -- )
            -- vim.fn.sign_define(
            --     "DapBreakpointRejected",
            --     { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
            -- )
            -- vim.fn.sign_define(
            --     "DapLogPoint",
            --     { text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
            -- )
            -- vim.fn.sign_define(
            --     "DapStopped",
            --     { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
            -- )
        end,
    },
}
