local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
  vim.notify("not found nvim-treesitter")
  return
end

treesitter.setup({
  -- Install language parser
  -- :TSInstallInfo command to view supported languages
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
  -- Enable code highlighting module
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  -- Enable incremental selection module
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      node_decremental = "<BS>",
      scope_incremental = "<TAB>",
    },
  },
  -- Enable code indentation module (=)
  indent = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
  callback = function()
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  end,
})

vim.opt.foldlevel = 99