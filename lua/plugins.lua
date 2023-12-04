local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = {
  checker = {
    -- automatically check for plugin updates
    enabled = false,
    concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    notify = false,   -- get a notification when new updates are found
    frequency = 3600, -- check for updates every hour
  },
}

require("lazy").setup({
  "folke/lazy.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = "VeryLazy",
    build = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
    config = function()
      require("plugin-config.nvim-treesitter")
    end,
  },
  {
    "m-demare/hlargs.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
      require("plugin-config.hlargs")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "BufEnter",
    config = function()
      require("plugin-config.lualine")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "moll/vim-bbye",
    },
    event = "BufEnter",
    config = function()
      require("plugin-config.bufferline")
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    config = function()
      require("plugin-config.indent-blankline")
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("plugin-config.comment")
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    tag = "nightly",                 -- optional, updated every week. (see issue #1193)
    config = function()
      require("plugin-config.nvim-tree")
    end,
  },
  {
    "anuvyklack/windows.nvim",
    event = "VeryLazy",
    dependencies = "anuvyklack/middleclass",
    config = function()
      require("plugin-config.windows")
    end,
  },
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = "VeryLazy",
    config = function()
      require("coc-config")
    end,
  },
  {
    "voldikss/vim-translator",
    event = "VeryLazy",
    config = function()
      local tool = require("tool")

      tool.map("n", "<Leader>tl", ":TranslateW<cr>")
      tool.map("v", "<Leader>tl", ":TranslateW<cr>")
    end,
  },
  {
    "gelguy/wilder.nvim",
    event = "VeryLazy",
    build = ":UpdateRemotePlugins",
    config = function()
      require("plugin-config.wilder")
    end
  },
  {
    "voldikss/vim-floaterm",
    event = "VeryLazy",
    config = function()
      local tool = require("tool")
      local map = tool.map

      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8

      map("n", "ft", ":FloatermNew<CR>")
      map("t", "ft", "<C-\\><C-n>:FloatermNew<CR>")
      map("n", "fj", ":FloatermPrev<CR>")
      map("t", "fj", "<C-\\><C-n>:FloatermPrev<CR>")
      map("n", "fk", ":FloatermNext<CR>")
      map("t", "fk", "<C-\\><C-n>:FloatermNext<CR>")
      map("n", "fs", ":FloatermToggle<CR>")
      map("t", "fs", "<C-\\><C-n>:FloatermToggle<CR>")
      map("n", "fc", ":FloatermKill<CR>")
      map("t", "fc", "<C-\\><C-n>:FloatermKill<CR>")

      if vim.fn.executable("lazygit") then
        map("n", "fg", ":FloatermNew lazygit <CR>")
      end

      if vim.fn.executable("lazydocker") then
        map("n", "fd", ":FloatermNew lazydocker <CR>")
      end
    end
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
              { text = { "%s" },                  click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
    event = "BufReadPost",
    config = function()
      require("plugin-config.nvim-ufo")
    end,
  },
  {
    "anuvyklack/fold-preview.nvim",
    event = "VeryLazy",
    dependencies = "anuvyklack/keymap-amend.nvim",
    config = true,
  },
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "folke/zen-mode.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/twilight.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "levouh/tint.nvim",
    event = "VeryLazy",
    config = function()
      require("tint").setup()
    end,
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
  },

  --------------------- colorschemes --------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      local status, catppuccin = pcall(require, "catppuccin")
      if not status then
        vim.notify("not found Catppuccin")
        return
      else
        catppuccin.setup({
          flavour = "macchiato",
        })
      end
      -- vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    enabled = true,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({})
      vim.cmd("colorscheme github_dark_dimmed")
    end,
  },
}, lazy_config)
