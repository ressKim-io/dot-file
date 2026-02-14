-- lua/plugins/formatting.lua
-- conform.nvim (포매터) + nvim-lint (린터)

return {
  -- Conform (포매터)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go = { "goimports", "gofumpt" },
          python = { "black", "isort" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          terraform = { "terraform_fmt" },
          tf = { "terraform_fmt" },
          hcl = { "terraform_fmt" },
          bash = { "shfmt" },
          sh = { "shfmt" },
          lua = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
      })
    end,
  },

  -- Nvim-lint (린터)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        go = { "golangcilint" },
        python = { "ruff" },
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        dockerfile = { "hadolint" },
        yaml = { "yamllint" },
        terraform = { "tflint" },
      }

      -- BufWritePost 이벤트에서 자동 lint
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          local ok, l = pcall(require, "lint")
          if ok then
            l.try_lint()
          end
        end,
      })
    end,
  },
}
