-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/code/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    root = vim.fn.stdpath("data") .. "/code/lazy",
    lockfile = vim.fn.stdpath("config") .. "/code/lazy-lock.json",
    spec = {
        -- import your plugins
        { import = "code.plugins" },
    },
    -- automatically check for plugin updates
    checker = { enabled = false },
    change_detection = {
        -- automatically check for config file changes and reload the ui
        enabled = false,
        notify = false, -- get a notification when changes are found
    },
    pkg = {
        cache = vim.fn.stdpath("state") .. "/code/lazy/pkg-cache.lua",
    },
    rocks = {
        enabled = true,
        root = vim.fn.stdpath("data") .. "/code/lazy-rocks",
        server = "https://nvim-neorocks.github.io/rocks-binaries/",
        hererocks = true,
    },
    readme = {
        enabled = true,
        root = vim.fn.stdpath("state") .. "/code/lazy/readme",
        files = { "README.md", "lua/**/README.md" },
        -- only generate markdown helptags for plugins that don't have docs
        skip_if_doc_exists = true,
    },
    state = vim.fn.stdpath("state") .. "/code/lazy/state.json",
})
