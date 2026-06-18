return {
    "saghen/blink.pairs",
    event = "InsertEnter",
    version = "*", -- (recommended) only required with prebuilt binaries
    dependencies = "saghen/blink.lib",
    build = function()
        require("blink.pairs").download():pwait(60000)
    end,
    --- @module 'blink.pairs'
    --- @type blink.pairs.Config
    opts = {
        mappings = {
            enabled = true,
            cmdline = true,
            disabled_filetypes = {},
            -- see the defaults:
            -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
            pairs = {},
        },
        highlights = {
            enabled = true,
            -- requires require('vim._core.ui2').enable({}), otherwise has no effect
            cmdline = false,
            -- set to { 'BlinkPairs' } to disable rainbow highlighting
            groups = { "BlinkPairsOrange", "BlinkPairsPurple", "BlinkPairsBlue" },
            unmatched_group = "BlinkPairsUnmatched",

            -- highlights matching pairs under the cursor
            matchparen = {
                enabled = true,
                -- known issue where typing won't update matchparen highlight, disabled by default
                cmdline = false,
                -- also include pairs not on top of the cursor, but surrounding the cursor
                include_surrounding = false,
                group = "BlinkPairsMatchParen",
                priority = 250,
            },
        },
    },
}
