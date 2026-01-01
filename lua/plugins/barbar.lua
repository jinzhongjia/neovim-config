return
--- @type LazySpec
{
    {
        "romgrk/barbar.nvim",
        event = "VeryLazy",
        dependencies = {
            "tiagovla/scope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            {
                "<leader>bp",
                "<Cmd>BufferPrevious<CR>",
                desc = "Previous buffer",
            },
            {
                "<leader>bn",
                "<Cmd>BufferNext<CR>",
                desc = "Next buffer",
            },
            {
                "<leader>bb",
                "<Cmd>BufferPick<CR>",
                desc = "Pick buffer",
            },
            {
                "<leader>bc",
                "<Cmd>BufferClose<CR>",
                desc = "Close buffer",
            },
            {
                "<leader>bo",
                "<Cmd>BufferCloseAllButCurrent<CR>",
                desc = "Close all buffers except current",
            },
            {
                "<leader>bd",
                "<Cmd>BufferCloseBuffersLeft<CR>",
                desc = "Close buffers to the left",
            },
            {
                "<leader>bf",
                "<Cmd>BufferCloseBuffersRight<CR>",
                desc = "Close buffers to the right",
            },
            {
                "<leader>br",
                "<Cmd>BufferRestore<CR>",
                desc = "Restore buffer",
            },
            {
                "<leader>bm",
                "<Cmd>BufferMovePrevious<CR>",
                desc = "Move buffer previous",
            },
            {
                "<leader>bi",
                "<Cmd>BufferMoveNext<CR>",
                desc = "Move buffer next",
            },
            {
                "<leader>bg",
                "<Cmd>BufferGoto<CR>",
                desc = "Goto buffer",
            },
            {
                "<leader>bs",
                "<Cmd>BufferSortByDirectory<CR>",
                desc = "Sort buffers by directory",
            },
            {
                "<leader>be",
                "<Cmd>BufferSortByExtension<CR>",
                desc = "Sort buffers by extension",
            },
            {
                "<leader>bt",
                "<Cmd>BufferSortByRelativeDirectory<CR>",
                desc = "Sort buffers by relative directory",
            },
        },
        opts = {
            animation = true,
            auto_hide = false,
            tabpages = true,
            clickable = true,
            focus_on_close = "left",
            hide = { extensions = false, inactive = false, current = false },
            highlight_alternate = false,
            highlight_inactive_file_icons = false,
            highlight_visible = true,
            icons = {
                buffer_index = true,
                buffer_number = false,
                button = "×",
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true, icon = "ﬀ" },
                    [vim.diagnostic.severity.WARN] = { enabled = false },
                    [vim.diagnostic.severity.INFO] = { enabled = false },
                    [vim.diagnostic.severity.HINT] = { enabled = true },
                },
                filetype = {
                    custom_colors = false,
                    enabled = true,
                },
                separator = { left = "▎", right = "" },
                modified = { button = "●" },
                pinned = { button = "󰐂", filename = true },
                alternate = { filetype = { enabled = false } },
                current = { buffer_index = true, filetype = { enabled = false } },
                inactive = { button = "×", filetype = { enabled = false } },
                visible = { modified = { buffer_number = false }, filetype = { enabled = false } },
            },
            insert_at_end = false,
            insert_at_start = false,
            maximum_padding = 1,
            minimum_padding = 1,
            maximum_length = 30,
            semantic_letters = true,
            letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP",
            no_name_title = nil,
        },
        version = "^1.0.0",
    },
    {
        "tiagovla/scope.nvim",
        event = "VeryLazy",
        opts = {},
    },
}

