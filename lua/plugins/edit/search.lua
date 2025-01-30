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
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            },
        },
        event = "VeryLazy",
        opts = {
            defaults = {
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
                    },
                },
                file_ignore_patterns = { "node_modules", "dist", "__pycache__" },
            },
            pickers = {
                -- Built-in pickers configuration
                find_files = {
                    hidden = false,
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                },
            },
        },
        keys = {
            { "<C-p>", "<cmd>Telescope find_files<cr>" },
            { "<C-f>", "<cmd>Telescope live_grep<cr>" },
            { "<leader>wd", "<cmd>Telescope diagnostics<cr>" },
        },
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
        keys = {
            -- stylua: ignore
            { "n", function() nN("n") end, mode = { "n", "x" }, desc = "key map for ufocmd" },
            { "N", function() nN("N") end, mode = { "n", "x" }, desc = "key map for ufocmd" },
            { "*", [[*<Cmd>lua require('hlslens').start()<CR>]] },
            { "#", [[#<Cmd>lua require('hlslens').start()<CR>]] },
            { "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]] },
            { "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]] },
            { "<Leader>l", "<Cmd>noh<CR>" },
        },
    },
}
