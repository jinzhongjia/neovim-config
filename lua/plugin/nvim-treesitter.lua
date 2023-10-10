local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
    vim.notify("not found nvim-treesitter")
    return
end

---@diagnostic disable-next-line: missing-fields
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
        "diff",
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
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
            scope_incremental = "<TAB>",
        },
    },
    context_commentstring = {
        enable = true,
    },
})
