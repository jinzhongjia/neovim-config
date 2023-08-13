local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
    vim.notify("not found nvim-treesitter")
    return
end

treesitter.setup({
    ensure_installed = {
        "c",
        "go",
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "cmake",
        "cpp",
        "comment",
        "css",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "gomod",
        "gosum",
        "gowork",
        "hjson",
        "html",
        "ini",
        "javascript",
        "json",
        "json5",
        "jsdoc",
        "jsonc",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "meson",
        "ninja",
        "nix",
        "python",
        "rust",
        "scss",
        "sql",
        "toml",
        "typescript",
        "vue",
        "yaml",
        "zig",
    },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn", -- set to `false` to disable one of the mappings
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    context_commentstring = {
        enable = true,
    },
})
