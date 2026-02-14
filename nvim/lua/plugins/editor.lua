-- lua/plugins/editor.lua
-- surround, autopairs, flash, commentary, refactoring, grug-far, persistence

return {
  -- Surround
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Commentary
  { "tpope/vim-commentary" },

  -- Flash (빠른 점프 + treesitter 선택)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
      vim.keymap.set("x", "<leader>re", function() require("refactoring").refactor("Extract Function") end, {desc = "Extract Function"})
      vim.keymap.set("x", "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, {desc = "Extract Variable"})
      vim.keymap.set("n", "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, {desc = "Inline Variable"})
    end,
  },

  -- Grug-far (프로젝트 전체 검색/치환)
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup()
      vim.keymap.set('n', '<leader>sr', function() require("grug-far").open() end, {desc = 'Search and Replace'})
    end,
  },

  -- Persistence (세션 자동 저장/복원)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>ps", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>pS", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>pl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>pd", function() require("persistence").stop() end, desc = "Don't Save Session" },
    },
  },

  -- 터미널
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = 'float',
        open_mapping = [[<c-\>]],
      })
    end,
  },
}
