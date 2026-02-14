-- lua/plugins/git.lua
-- gitsigns, diffview, lazygit, git-conflict, fugitive

return {
  -- Git Blame 인라인 표시
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map('n', ']c', function() gs.nav_hunk('next') end, {desc = 'Next hunk'})
          map('n', '[c', function() gs.nav_hunk('prev') end, {desc = 'Previous hunk'})
          map('n', '<leader>hs', gs.stage_hunk, {desc = 'Stage hunk'})
          map('n', '<leader>hr', gs.reset_hunk, {desc = 'Reset hunk'})
          map('n', '<leader>hp', gs.preview_hunk, {desc = 'Preview hunk'})
        end,
      })
    end,
  },

  -- Diffview
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', {desc = 'Git Diff'})
      vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory<CR>', {desc = 'Git History'})
      vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', {desc = 'Close Diffview'})
    end,
  },

  -- Git Fugitive
  { "tpope/vim-fugitive" },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', {desc = 'LazyGit'})
    end,
  },

  -- Git Conflict
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup({
        default_mappings = true,
      })
    end,
  },
}
