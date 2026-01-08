return
--- @type LazySpec
{
    {
        "akinsho/bufferline.nvim",
        version = "*",
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            {
                "<leader>bp",
                "<Cmd>BufferLineCyclePrev<CR>",
                desc = "Previous buffer",
            },
            {
                "<leader>bn",
                "<Cmd>BufferLineCycleNext<CR>",
                desc = "Next buffer",
            },
            {
                "<leader>bb",
                "<Cmd>BufferLinePick<CR>",
                desc = "Pick buffer",
            },
            {
                "<leader>bc",
                function()
                    Snacks.bufdelete()
                end,
                desc = "Close buffer",
            },
            {
                "<leader>bo",
                function()
                    Snacks.bufdelete.other()
                end,
                desc = "Close all buffers except current",
            },
            {
                "<leader>bd",
                "<Cmd>BufferLineCloseLeft<CR>",
                desc = "Close buffers to the left",
            },
            {
                "<leader>bf",
                "<Cmd>BufferLineCloseRight<CR>",
                desc = "Close buffers to the right",
            },
            {
                "<leader>bm",
                "<Cmd>BufferLineMovePrev<CR>",
                desc = "Move buffer previous",
            },
            {
                "<leader>bi",
                "<Cmd>BufferLineMoveNext<CR>",
                desc = "Move buffer next",
            },
            {
                "<leader>bs",
                "<Cmd>BufferLineSortByDirectory<CR>",
                desc = "Sort buffers by directory",
            },
            {
                "<leader>be",
                "<Cmd>BufferLineSortByExtension<CR>",
                desc = "Sort buffers by extension",
            },
            {
                "<leader>bt",
                "<Cmd>BufferLineSortByRelativeDirectory<CR>",
                desc = "Sort buffers by relative directory",
            },
            -- 使用数字快捷跳转到指定 buffer
            { "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "Go to buffer 1" },
            { "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "Go to buffer 2" },
            { "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "Go to buffer 3" },
            { "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", desc = "Go to buffer 4" },
            { "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", desc = "Go to buffer 5" },
            { "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", desc = "Go to buffer 6" },
            { "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", desc = "Go to buffer 7" },
            { "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", desc = "Go to buffer 8" },
            { "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", desc = "Go to buffer 9" },
        },
        opts = {
            options = {
                mode = "buffers",
                numbers = "ordinal", -- 显示 buffer 序号
                close_command = function(n)
                    Snacks.bufdelete(n)
                end,
                right_mouse_command = function(n)
                    Snacks.bufdelete(n)
                end,
                left_mouse_command = "buffer %d",
                middle_mouse_command = nil,
                indicator = {
                    icon = "▎",
                    style = "icon",
                },
                buffer_close_icon = "󰅖",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                max_name_length = 30,
                max_prefix_length = 15,
                truncate_names = true,
                tab_size = 18,
                diagnostics = "nvim_lsp",
                diagnostics_update_in_insert = false,
                diagnostics_indicator = function(count, level, _, _)
                    local icon = level:match("error") and "󰅚 " or (level:match("warning") and " " or " ")
                    return " " .. icon .. count
                end,
                color_icons = true,
                show_buffer_icons = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_indicators = true,
                show_duplicate_prefix = true,
                persist_buffer_sort = true,
                separator_style = "thin",
                enforce_regular_tabs = false,
                always_show_bufferline = true,
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = { "close" },
                },
                sort_by = "insert_after_current",
                -- 为 NvimTree/neo-tree 等文件浏览器留出空间
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "center",
                        separator = true,
                    },
                },
            },
        },
    },
}
