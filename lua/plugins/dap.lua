-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DAP (Debug Adapter Protocol) configuration
-- Supports: Go (delve), Rust/C (codelldb/lldb), Python (debugpy), TS/JS (js-debug)
-- 懒加载：调试是低频场景，dap+dapui 推迟到首次按 DAP 键位
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local loaded = false
local function load_dap()
    if loaded then
        return
    end
    loaded = true

    local dap = require("dap")
    local dapui = require("dapui")

    -- ── DAP UI Setup ─────────────────────────────────────────────
    dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "●" },
        layouts = {
            {
                elements = {
                    { id = "scopes", size = 0.4 },
                    { id = "breakpoints", size = 0.2 },
                    { id = "stacks", size = 0.2 },
                    { id = "watches", size = 0.2 },
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
    })

    -- Auto open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

    -- ── Breakpoint signs ─────────────────────────────────────────
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DapLogPoint", { text = "◇", texthl = "DiagnosticInfo" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })

    -- ── Adapters ─────────────────────────────────────────────────

    -- Go (Delve)
    dap.adapters.delve = {
        type = "server",
        port = "${port}",
        executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:${port}" },
        },
    }

    -- C/Rust (codelldb)
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = "codelldb",
            args = { "--port", "${port}" },
        },
    }

    -- C/Rust fallback (lldb-dap, ships with LLVM)
    dap.adapters["lldb-dap"] = {
        type = "executable",
        command = "lldb-dap",
    }

    -- Python (debugpy)
    dap.adapters.python = function(cb, config)
        if config.request == "attach" then
            cb({
                type = "server",
                port = config.connect.port or 5678,
                host = config.connect.host or "127.0.0.1",
            })
        else
            cb({
                type = "executable",
                command = "python3",
                args = { "-m", "debugpy.adapter" },
            })
        end
    end

    -- JavaScript/TypeScript (js-debug-adapter via vscode-js-debug)
    dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "js-debug-adapter",
            args = { "${port}" },
        },
    }

    -- ── Configurations ───────────────────────────────────────────

    -- Go
    dap.configurations.go = {
        {
            type = "delve",
            name = "Debug",
            request = "launch",
            program = "${file}",
        },
        {
            type = "delve",
            name = "Debug (package)",
            request = "launch",
            program = "./${relativeFileDirname}",
        },
        {
            type = "delve",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
    }

    -- Rust
    dap.configurations.rust = {
        {
            name = "Debug",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }

    -- C/C++
    dap.configurations.c = {
        {
            name = "Debug",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
    dap.configurations.cpp = dap.configurations.c

    -- Python
    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            pythonPath = function()
                -- Use virtualenv if available
                local venv = os.getenv("VIRTUAL_ENV")
                if venv then
                    return venv .. "/bin/python"
                end
                return "python3"
            end,
        },
        {
            type = "python",
            request = "launch",
            name = "Launch module",
            module = function()
                return vim.fn.input("Module: ")
            end,
        },
    }

    -- TypeScript/JavaScript
    dap.configurations.typescript = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "npx",
            runtimeArgs = { "tsx" },
        },
    }
    dap.configurations.javascript = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
        },
    }
end

-- ── Keymaps（按下时才加载 dap/dapui）─────────────────────────
local map = vim.keymap.set

local function d(fn)
    return function()
        load_dap()
        require("dap")[fn]()
    end
end
local function du(fn)
    return function()
        load_dap()
        require("dapui")[fn]()
    end
end

-- 键位同 main：dj/di/do/dO 步进，dl 日志断点，dR REPL，dC 跑到光标
map("n", "<leader>db", d("toggle_breakpoint"), { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>dB", function()
    load_dap()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Breakpoint condition" })
map("n", "<leader>dl", function()
    load_dap()
    require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "DAP: Logpoint" })
map("n", "<leader>dc", d("continue"), { desc = "DAP: Continue" })
map("n", "<leader>dn", function()
    load_dap()
    require("dap").continue({ new = true })
end, { desc = "DAP: New session" })
map("n", "<leader>dp", d("pause"), { desc = "DAP: Pause" })
map("n", "<leader>dt", d("terminate"), { desc = "DAP: Terminate" })
map("n", "<leader>dr", d("restart"), { desc = "DAP: Restart" })
map("n", "<leader>dj", d("step_over"), { desc = "DAP: Step over" })
map("n", "<leader>di", d("step_into"), { desc = "DAP: Step into" })
map("n", "<leader>do", d("step_out"), { desc = "DAP: Step out" })
map("n", "<leader>dO", d("step_back"), { desc = "DAP: Step back" })
map("n", "<leader>dR", function()
    load_dap()
    require("dap").repl.toggle()
end, { desc = "DAP: Toggle REPL" })
map("n", "<leader>du", du("toggle"), { desc = "DAP: Toggle UI" })
map({ "n", "v" }, "<leader>de", du("eval"), { desc = "DAP: Eval" })
map("n", "<leader>dC", d("run_to_cursor"), { desc = "DAP: Run to cursor" })
map("n", "<leader>dg", d("goto_"), { desc = "DAP: Go to line (no execute)" })
map("n", "<leader>dw", function()
    load_dap()
    require("dap.ui.widgets").hover()
end, { desc = "DAP: Widgets" })
map("n", "<F5>", d("continue"), { desc = "DAP: Continue" })
map("n", "<F10>", d("step_over"), { desc = "DAP: Step over" })
map("n", "<F11>", d("step_into"), { desc = "DAP: Step into" })
map("n", "<F12>", d("step_out"), { desc = "DAP: Step out" })
