-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- AI Coding — Claude Code + OpenCode + OMP
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ── Claude Code (claudecode.nvim) ────────────────────────────
-- Pure Lua WebSocket MCP bridge to Claude Code CLI
require("claudecode").setup({
    -- Auto-start the WebSocket server
    auto_start = true,
    log_level = "warn",

    -- Terminal
    terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks", -- 复用 Snacks.terminal（styles.terminal）
        auto_close = true,
        auto_insert = true,
    },

    -- Diff integration
    diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
        auto_resize_terminal = true,
    },

    -- Selection tracking (Claude sees your cursor/selection in real-time)
    track_selection = true,
})

-- Claude Code keymaps
local map = vim.keymap.set
map("n", "<leader>ac", "<cmd>ClaudeCode<CR>", { desc = "Claude: Toggle" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<CR>", { desc = "Claude: Focus" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", { desc = "Claude: Select model" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { desc = "Claude: Add buffer" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<CR>", { desc = "Claude: Send selection" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", { desc = "Claude: Accept diff" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", { desc = "Claude: Deny diff" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<CR>", { desc = "Claude: Resume" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<CR>", { desc = "Claude: Continue" })

-- ── OpenCode (opencode.nvim) ─────────────────────────────────
require("opencode").setup({
    preferred_picker = "snacks",
    preferred_completion = "vim_complete",
    default_global_keymaps = true,
    keymap_prefix = "<leader>o",
    default_mode = "build",

    ui = {
        position = "right",
        window_width = 0.40,
        display_model = true,
        display_context_size = true,
        icons = {
            preset = "nerdfonts",
        },
        output = {
            tools = {
                show_output = true,
                use_folds = true,
                folding_threshold = 25,
            },
        },
    },

    context = {
        enabled = true,
        diagnostics = {
            warning = true,
            error = true,
        },
        current_file = {
            enabled = true,
            show_full_path = true,
        },
        selection = {
            enabled = true,
        },
    },

    logging = {
        enabled = false,
        level = "warn",
    },
})

-- ── OMP (omp.nvim) ───────────────────────────────────────────
-- Neovim frontend for `omp --mode rpc`
require("omp").setup({
    omp_executable = "omp",
    preferred_picker = "snacks",
    preferred_completion = "vim_complete",
    default_global_keymaps = true,
    keymap_prefix = "<leader>p",

    rpc = {
        timeout = 10000,
        extra_args = {},
    },

    ui = {
        position = "right",
        window_width = 0.40,
        display_model = true,
        display_context_size = true,
        icons = {
            preset = "nerdfonts",
        },
        output = {
            tools = {
                show_output = true,
                show_reasoning_output = true,
                use_folds = true,
                folding_threshold = 25,
            },
        },
    },

    context = {
        enabled = true,
        diagnostics = {
            warning = true,
            error = true,
        },
        current_file = {
            enabled = true,
            show_full_path = true,
        },
        selection = {
            enabled = true,
        },
    },

    logging = {
        enabled = false,
        level = "warn",
    },
})
