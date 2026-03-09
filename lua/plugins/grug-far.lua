return
--- @type LazySpec
{
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar", "GrugFarWithin" },
        opts = {},
        keys = {
            {
                "<leader>gfg",
                function()
                    require("grug-far").toggle_instance({
                        instanceName = "search",
                        staticTitle = "Search",
                    })
                end,
                mode = { "n" },
                desc = "Global search (grug-far)",
            },
            {
                "<leader>gfr",
                function()
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    require("grug-far").open({
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "x" },
                desc = "Search and replace (grug-far)",
            },
            {
                "<leader>gff",
                function()
                    require("grug-far").open({
                        transient = true,
                        prefills = { paths = vim.fn.expand("%") },
                    })
                end,
                mode = { "n" },
                desc = "Search and replace in current file",
            },
            {
                "<leader>gfw",
                function()
                    require("grug-far").open({
                        transient = true,
                        prefills = { search = vim.fn.expand("<cword>") },
                    })
                end,
                mode = { "n" },
                desc = "Search word under cursor",
            },
            {
                "<leader>gfg",
                function()
                    require("grug-far").with_visual_selection({ transient = true })
                end,
                mode = { "x" },
                desc = "Search selected text",
            },
            {
                "<leader>gfi",
                function()
                    require("grug-far").open({
                        visualSelectionUsage = "operate-within-range",
                    })
                end,
                mode = { "n", "x" },
                desc = "Search and replace within selection",
            },
            {
                "<leader>gfs",
                function()
                    local search = vim.fn.getreg("/")
                    if search and vim.startswith(search, "\\<") and vim.endswith(search, "\\>") then
                        search = "\\b" .. search:sub(3, -3) .. "\\b"
                    elseif search and vim.startswith(search, "\\V") then
                        search = search:sub(3)
                    end
                    local inst = require("grug-far").open({
                        transient = true,
                        prefills = { search = search },
                    })
                    inst:when_ready(function()
                        inst:goto_input("replacement")
                    end)
                end,
                mode = { "n" },
                desc = "Bring current search to replace",
            },
            {
                "<leader>gft",
                function()
                    require("grug-far").toggle_instance({
                        instanceName = "far",
                        staticTitle = "Find and Replace",
                    })
                end,
                mode = { "n" },
                desc = "Toggle search and replace panel",
            },
        },
    },
}
