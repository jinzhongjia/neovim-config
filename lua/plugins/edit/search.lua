local function nN(char)
    local ok, winid = require("hlslens").nNPeekWithUFO(char)
    if ok and winid then
        -- Safe to override buffer scope keymaps remapped by ufo,
        -- ufo will restore previous buffer keymaps before closing preview window
        -- Type <CR> will switch to preview window and fire `trace` action
        vim.keymap.set("n", "<CR>", function()
            return "<Tab><CR>"
        end, { buffer = true, remap = true, expr = true })
    end
end

return
--- @type LazySpec
{
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        event = "VeryLazy",
        opts = {
            defaults = {
                layout_strategy = "vertical",
                layout_config = {
                    width = 0.9,
                    height = 0.9,
                    preview_cutoff = 20,
                    prompt_position = "bottom",
                },

                -- layout_config = {
                --     horizontal = {
                --         height = 0.8,
                --         preview_cutoff = 120,
                --         prompt_position = "bottom",
                --         width = 0.8,
                --     },
                -- },
                -- The initial mode entered after opening the pop-up window, the default is insert, it can also be normal
                initial_mode = "insert",
                -- Shortcut keys in the window
                mappings = {
                    i = {
                        -- Moving up and down
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                        ["<Down>"] = "move_selection_next",
                        ["<Up>"] = "move_selection_previous",
                        -- history record
                        ["<C-n>"] = "cycle_history_next",
                        ["<C-p>"] = "cycle_history_prev",
                        -- close the window
                        ["<C-c>"] = "close",
                        -- The preview window scrolls up and down
                        ["<C-u>"] = "preview_scrolling_up",
                        ["<C-d>"] = "preview_scrolling_down",
                        ["<C-h>"] = "preview_scrolling_left",
                        ["<C-l>"] = "preview_scrolling_right",
                    },
                },
                file_ignore_patterns = {
                    "node_modules",
                    "dist",
                    "__pycache__",
                    "%.pb%.go$", -- 忽略 *.pb.go 文件
                    "%.connect%.go$", -- 忽略 *.connect.go 文件
                    "gen%.go$", -- 忽略 gen.go 文件
                    "query/", -- 忽略 query 目录
                    "dal/query/", -- 忽略 dal/query 目录
                    "%.gen%.go$", -- 忽略 *.gen.go 文件
                },
            },
            pickers = {
                -- Built-in pickers configuration
                live_grep = {
                    hidden = false,
                },
                find_files = {
                    hidden = true,
                    border = true,
                    borderchars = {
                        { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                        prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                        results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    },
                    layout_config = {
                        width = 0.75,
                        height = 0.55,
                        -- width = function(_, max_columns, _)
                        --     return math.min(max_columns, 80)
                        -- end,
                        -- height = function(_, _, max_lines)
                        --     return math.min(max_lines, 15)
                        -- end,
                    },
                    layout_strategy = "center",
                    previewer = false,
                    prompt_title = "find files",
                    results_title = false,
                },
            },
            extensions = {
                frecency = {
                    hidden = true,
                    border = true,
                    borderchars = {
                        { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                        prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                        results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    },
                    layout_config = {
                        width = 0.75,
                        height = 0.55,
                    },
                    layout_strategy = "center",
                    previewer = false,
                    prompt_title = "frecency files",
                    results_title = false,
                    db_validate_threshold = 30,
                    db_version = "v2",
                    enable_prompt_mappings = false,
                    matcher = "fuzzy",
                    show_scores = true,
                },
            },
        },
        keys = {
            { "<C-f>", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
            { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
            {
                "<C-S-p>",
                "<cmd>Telescope find_files no_ignore=true<cr>",
                desc = "Telescope find files (include ignored)",
            },
            {
                "<C-S-f>",
                "<cmd>Telescope live_grep no_ignore=true<cr>",
                desc = "Telescope live grep (include ignored)",
            },
            { "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
            { "<leader>tg", "<cmd>Telescope git_branches<cr>", desc = "Telescope git branches" },
            { "<leader>tc", "<cmd>Telescope git_commits<cr>", desc = "Telescope git commits" },
            { "<leader>tt", "<cmd>Telescope<cr>", desc = "Telescope" },
        },
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        -- install the latest stable version
        version = "*",
        config = function()
            require("telescope").load_extension("frecency")
        end,
    },
    {
        "debugloop/telescope-undo.nvim",
        dependencies = "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        -- install the latest stable version
        version = "*",
        config = function()
            require("telescope").load_extension("undo")
        end,
    },
    {
        "paopaol/telescope-git-diffs.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "sindrets/diffview.nvim",
        },
        event = "VeryLazy",
        config = function()
            require("telescope").load_extension("git_diffs")
        end,
    },
    {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "mfussenegger/nvim-dap",
            "nvim-treesitter/nvim-treesitter",
        },
        event = "VeryLazy",
        config = function()
            require("telescope").load_extension("dap")
        end,
    },
    {
        "nvim-telescope/telescope-live-grep-args.nvim",
        branch = "master",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("telescope").load_extension("live_grep_args")
        end,
    },
    {
        "kevinhwang91/nvim-hlslens",
        dependencies = "kevinhwang91/nvim-ufo",
        event = "VeryLazy",
        opts = {
            nearest_only = true,
            override_lens = function(render, posList, nearest, idx, relIdx)
                local sfw = vim.v.searchforward == 1
                local indicator, text, chunks
                local absRelIdx = math.abs(relIdx)
                if absRelIdx > 1 then
                    ---@diagnostic disable-next-line: undefined-field
                    indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and "▲" or "▼")
                elseif absRelIdx == 1 then
                    indicator = sfw ~= (relIdx == 1) and "▲" or "▼"
                else
                    indicator = ""
                end

                local lnum, col = unpack(posList[idx])
                if nearest then
                    local cnt = #posList
                    if indicator ~= "" then
                        ---@diagnostic disable-next-line: undefined-field
                        text = ("[%s %d/%d]"):format(indicator, idx, cnt)
                    else
                        ---@diagnostic disable-next-line: undefined-field
                        text = ("[%d/%d]"):format(idx, cnt)
                    end
                    chunks = { { " " }, { text, "HlSearchLensNear" } }
                else
                    ---@diagnostic disable-next-line: undefined-field
                    text = ("[%s %d]"):format(indicator, idx)
                    chunks = { { " " }, { text, "HlSearchLens" } }
                end
                render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
            end,
        },
        -- stylua: ignore
        keys = {
            { "n", function() nN("n") end, mode = { "n", "x" }, desc = "key map for ufocmd" },
            { "N", function() nN("N") end, mode = { "n", "x" }, desc = "key map for ufocmd" },
            { "*", [[*<Cmd>lua require('hlslens').start()<CR>]], desc = "next cursor word" },
            { "#", [[#<Cmd>lua require('hlslens').start()<CR>]], desc = "prev cursor word" },
            { "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], desc = "next cursor word no bound" },
            { "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], desc = "prev cursor word no bound" },
            { "<Leader>l", "<Cmd>noh<CR>", desc = "disable search hightlight" },
        },
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
          { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
          { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
          { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
          { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
          { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },
    {
        "MagicDuck/grug-far.nvim",
        event = "VeryLazy",
        opts = {},
        -- stylua: ignore
        keys = {
            {
                "<leader>gf",
                function() require("grug-far").open({ transient = true }) end,
                desc = "grug far open",
            },
            {
                "<leader>gfc",
                function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end,
                desc = "grug far open current file",
            },
            {
                "<leader>gfw",
                function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
                desc = "grug far open with cursor word",
            },
        },
    },
    {
        "cshuaimin/ssr.nvim",
        event = "VeryLazy",
        opts = {},
        -- stylua: ignore
        keys = {
            { "<leader>sr", function() require("ssr").open() end, desc = "structural search and replace" },
        },
    },
}
