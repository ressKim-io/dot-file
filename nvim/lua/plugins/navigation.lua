-- lua/plugins/navigation.lua
-- nvim-tree, oil, aerial

return {
  -- NvimTree (파일 트리)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },
        filters = { dotfiles = false },
        git = { enable = true },
      })
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {desc = 'Toggle file tree'})
    end,
  },

  -- Oil (버퍼 기반 파일 관리)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = false,
        view_options = {
          show_hidden = true,
        },
      })
      vim.keymap.set('n', '-', ':Oil<CR>', {desc = 'Open parent directory'})
    end,
  },

  -- Aerial (심볼 아웃라인)
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp", "markdown", "man" },
        layout = {
          min_width = 30,
          default_direction = "right",
        },
        show_guides = true,
      })
      vim.keymap.set('n', '<leader>o', ':AerialToggle<CR>', {desc = 'Toggle symbol outline'})
      vim.keymap.set('n', '[a', ':AerialPrev<CR>', {desc = 'Previous symbol'})
      vim.keymap.set('n', ']a', ':AerialNext<CR>', {desc = 'Next symbol'})
    end,
  },
}
