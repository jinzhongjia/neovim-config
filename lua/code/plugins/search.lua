return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {
            label = {
                -- allow uppercase labels
                uppercase = true,
            },
        },
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
            { "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, desc = "key map for ufocmd" },
            { "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, desc = "key map for ufocmd" },
            { "*", [[*<Cmd>lua require('hlslens').start()<CR>]], desc = "next cursor word" },
            { "#", [[#<Cmd>lua require('hlslens').start()<CR>]], desc = "prev cursor word" },
            { "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], desc = "next cursor word no bound" },
            { "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], desc = "prev cursor word no bound" },
            { "<Leader>l", "<Cmd>noh<CR>", desc = "disable search hightlight" },
        },
    },
}
