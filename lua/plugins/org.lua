return
--- @type LazySpec
{
    {
        "nvim-neorg/neorg",
        lazy = true, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
        version = "*", -- Pin Neorg to the latest stable release
        enabled = false,
        config = true,
    },
}
