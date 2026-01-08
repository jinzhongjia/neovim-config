return
--- @type LazySpec
{
    -- DAP 核心插件
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- DAP UI - 提供调试界面
            {
                "rcarriga/nvim-dap-ui",
                dependencies = {
                    "nvim-neotest/nvim-nio",
                },
            },
            -- 显示内联变量值
            {
                "theHamsta/nvim-dap-virtual-text",
                dependencies = { "nvim-treesitter/nvim-treesitter" },
            },
        },
        keys = {
            -- 断点操作
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle Breakpoint",
            },
            {
                "<leader>dB",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "Breakpoint Condition",
            },
            {
                "<leader>dl",
                function()
                    require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
                end,
                desc = "Logpoint",
            },
            -- 调试控制
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "Continue",
            },
            {
                "<leader>dn",
                function()
                    require("dap").new()
                end,
                desc = "New Session",
            },
            {
                "<leader>dp",
                function()
                    require("dap").pause()
                end,
                desc = "Pause",
            },
            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "Terminate",
            },
            {
                "<leader>dr",
                function()
                    require("dap").restart()
                end,
                desc = "Restart",
            },
            -- 步进操作（使用方向键风格）
            {
                "<leader>dj",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<leader>dO",
                function()
                    require("dap").step_back()
                end,
                desc = "Step Back",
            },
            -- REPL 和 UI
            {
                "<leader>dR",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Toggle REPL",
            },
            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "Toggle DAP UI",
            },
            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                mode = { "n", "v" },
                desc = "Eval Expression",
            },
            -- 其他
            {
                "<leader>dC",
                function()
                    require("dap").run_to_cursor()
                end,
                desc = "Run to Cursor",
            },
            {
                "<leader>dg",
                function()
                    require("dap").goto_()
                end,
                desc = "Go to Line (No Execute)",
            },
            {
                "<leader>dw",
                function()
                    require("dap.ui.widgets").hover()
                end,
                desc = "Widgets",
            },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- DAP UI 设置
            ---@diagnostic disable-next-line: missing-fields
            dapui.setup({
                icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                mappings = {
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    edit = "e",
                    repl = "r",
                    toggle = "t",
                },
                element_mappings = {},
                expand_lines = true,
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks", size = 0.25 },
                            { id = "watches", size = 0.25 },
                        },
                        position = "left",
                        size = 40,
                    },
                    {
                        elements = {
                            { id = "repl", size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        position = "bottom",
                        size = 10,
                    },
                },
                floating = {
                    max_height = nil,
                    max_width = nil,
                    border = "rounded",
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
                controls = {
                    enabled = true,
                    element = "repl",
                    icons = {
                        pause = "",
                        play = "",
                        step_into = "",
                        step_over = "",
                        step_out = "",
                        step_back = "",
                        run_last = "",
                        terminate = "",
                    },
                },
                ---@diagnostic disable-next-line: missing-fields
                render = {
                    max_type_length = nil,
                    max_value_lines = 100,
                },
            })

            -- DAP 虚拟文本设置
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,
                only_first_definition = true,
                all_references = false,
                clear_on_continue = false,
                virt_text_pos = "eol",
            })

            -- 自动打开/关闭 DAP UI
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            -- 自定义断点图标
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
            vim.fn.sign_define(
                "DapBreakpointCondition",
                { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
            )
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "" })
            vim.fn.sign_define(
                "DapBreakpointRejected",
                { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" }
            )

            -- 设置高亮
            vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
            vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f5a623" })
            vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
            vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = "#31353f" })
            vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#656565" })

            ------------------------------------------------------------------
            -- 调试适配器配置
            ------------------------------------------------------------------

            -- Go (Delve)
            dap.adapters.delve = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                    detached = vim.fn.has("win32") == 0,
                },
            }

            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Debug",
                    request = "launch",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Debug (go.mod)",
                    request = "launch",
                    program = "./${relativeFileDirname}",
                },
                {
                    type = "delve",
                    name = "Debug test",
                    request = "launch",
                    mode = "test",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Debug test (go.mod)",
                    request = "launch",
                    mode = "test",
                    program = "./${relativeFileDirname}",
                },
                {
                    type = "delve",
                    name = "Attach",
                    request = "attach",
                    mode = "local",
                    processId = require("dap.utils").pick_process,
                },
            }
        end,
    },
}
