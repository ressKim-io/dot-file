-- lua/plugins/testing.lua
-- neotest + Go/Python 어댑터

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang"),
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
          }),
        },
        status = {
          virtual_text = true,
        },
        output = {
          open_on_run = true,
        },
      })

      local map = vim.keymap.set
      map('n', '<leader>tn', function() require("neotest").run.run() end, {desc = 'Run nearest test'})
      map('n', '<leader>tF', function() require("neotest").run.run(vim.fn.expand("%")) end, {desc = 'Run file tests'})
      map('n', '<leader>ts', function() require("neotest").summary.toggle() end, {desc = 'Toggle test summary'})
      map('n', '<leader>to', function() require("neotest").output.open({ enter_on_open = true }) end, {desc = 'Test output'})
      map('n', '<leader>tP', function() require("neotest").output_panel.toggle() end, {desc = 'Toggle output panel'})
      map('n', '<leader>td', function() require("neotest").run.run({strategy = "dap"}) end, {desc = 'Debug nearest test'})
    end,
  },
}
