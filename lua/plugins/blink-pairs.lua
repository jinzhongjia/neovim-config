return {
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
            enabled = false,
        },
    },
}
