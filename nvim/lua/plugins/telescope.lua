-- lua/plugins/telescope.lua
-- telescope + frecency

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-frecency.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "vendor/" },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { preview_width = 0.55 },
          },
        },
      })

      telescope.load_extension("frecency")

      local map = vim.keymap.set
      map('n', '<leader>ff', builtin.find_files, {desc = 'Find files'})
      map('n', '<leader>fg', builtin.live_grep, {desc = 'Live grep'})
      map('n', '<leader>fb', builtin.buffers, {desc = 'Buffers'})
      map('n', '<leader>fh', builtin.help_tags, {desc = 'Help'})
      map('n', '<leader>fr', ':Telescope frecency<CR>', {desc = 'Recent files'})
      map('n', '<leader>fd', builtin.diagnostics, {desc = 'Diagnostics'})
      map('n', '<leader>fs', builtin.lsp_document_symbols, {desc = 'Document symbols'})
    end,
  },
}
