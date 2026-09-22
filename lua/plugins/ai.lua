-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- AI Coding — OMP
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
