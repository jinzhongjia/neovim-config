local fn = vim.fn
local tool = require("tool")
local map = tool.map
local dap = require("dap")
local dapui = require("dapui")
require("nvim-dap-virtual-text").setup({
    commented = true,
})

fn.sign_define("DapBreakpoint", {
    text = "🛑",
    texthl = "LspDiagnosticsSignError",
    linehl = "",
    numhl = "",
})

fn.sign_define("DapStopped", {
    text = "",
    texthl = "LspDiagnosticsSignInformation",
    linehl = "DiagnosticUnderlineInfo",
    numhl = "LspDiagnosticsSignInformation",
})

fn.sign_define("DapBreakpointRejected", {
    text = "",
    texthl = "LspDiagnosticsSignHint",
    linehl = "",
})

dapui.setup({
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "o", "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    sidebar = {
        -- You can change the order of elements in the sidebar
        elements = {
            -- Provide as ID strings or tables with "id" and "size" keys
            {
                id = "scopes",
                size = 0.25, -- Can be float or integer > 1
            },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 00.25 },
        },
        size = 40,
        position = "left", -- Can be "left", "right", "top", "bottom"
    },
    tray = {
        elements = { "repl" },
        size = 10,
        position = "bottom", -- Can be "left", "right", "top", "bottom"
    },
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
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

do
    map("n", "<leader>dd", ":RustDebuggables<CR>")
    -- 结束 (dapui无法自动关闭可能是bug，手动关闭能想到的一切)
    map(
        "n",
        "<leader>de",
        ":lua require'dap'.close()<CR>"
            .. ":lua require'dap'.terminate()<CR>"
            .. ":lua require'dap.repl'.close()<CR>"
            .. ":lua require'dapui'.close()<CR>"
            .. ":lua require('dap').clear_breakpoints()<CR>"
            .. "<C-w>o<CR>"
    )
    -- 继续
    map("n", "<leader>dc", ":lua require'dap'.continue()<CR>")
    -- 设置断点
    map("n", "<leader>dt", ":lua require('dap').toggle_breakpoint()<CR>")
    map("n", "<leader>dT", ":lua require('dap').clear_breakpoints()<CR>")
    --  stepOver, stepOut, stepInto
    map("n", "<leader>dj", ":lua require'dap'.step_over()<CR>")
    map("n", "<leader>dk", ":lua require'dap'.step_out()<CR>")
    map("n", "<leader>dl", ":lua require'dap'.step_into()<CR>")
    -- 弹窗
    map("n", "<leader>dh", ":lua require'dapui'.eval()<CR>")
end
