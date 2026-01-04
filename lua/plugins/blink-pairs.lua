return 
{
    "saghen/blink.pairs",
    version = "*", -- (recommended) only required with prebuilt binaries
    dependencies = "saghen/blink.download",
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
            cmdline = true,
            groups = {
                "BlinkPairsOrange",
                "BlinkPairsPurple",
                "BlinkPairsBlue",
            },
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
        debug = false,
    },
}
