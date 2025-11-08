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
        "kevinhwang91/nvim-hlslens",
        dependencies = "kevinhwang91/nvim-ufo",
        event = { "BufReadPost", "BufNewFile" },
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
        -- 按键触发即可,不需要提前加载
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
        -- 命令和按键触发
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
        -- 按键触发即可
        opts = {},
        -- stylua: ignore
        keys = {
            { "<leader>sr", function() require("ssr").open() end, desc = "structural search and replace" },
        },
    },
}
