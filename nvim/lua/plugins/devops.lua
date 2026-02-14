-- lua/plugins/devops.lua
-- DevOps 특화 플러그인: terraform, helm, kubectl, yaml, schemastore, etc.

return {
  -- YAML path 표시
  {
    "cuducos/yaml.nvim",
    ft = { "yaml" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      vim.keymap.set('n', '<leader>ky', ':lua require("yaml_nvim").view()<CR>', {desc = 'YAML path'})
    end,
  },

  -- Helm 지원
  {
    "towolf/vim-helm",
    ft = "helm",
  },

  -- Terraform 고급 기능 (conform.nvim이 포맷 담당하므로 auto_fmt 비활성화)
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "hcl" },
    config = function()
      vim.g.terraform_fmt_on_save = 0
      vim.g.terraform_align = 1
      vim.g.terraform_fold_sections = 1
    end,
  },

  -- Kubectl UI (native binary는 cargo 설치 후 :KubectlBuild로 빌드)
  {
    "ramilito/kubectl.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("kubectl").setup()
      vim.keymap.set('n', '<leader>kk', ':lua require("kubectl").open()<CR>', {desc = 'Open kubectl UI'})
    end,
  },

  -- JSON/YAML 스키마
  { "b0o/schemastore.nvim" },

  -- TODO/FIXME/NOTE 하이라이트
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({
        keywords = {
          FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        },
      })
      vim.keymap.set('n', '<leader>ft', ':TodoTelescope<CR>', {desc = 'Find TODOs'})
    end,
  },

  -- Trouble (진단 목록)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
      vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', {desc = 'Diagnostics'})
      vim.keymap.set('n', '<leader>xw', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', {desc = 'Buffer Diagnostics'})
    end,
  },

  -- Which-key (키맵 가이드)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Markdown 미리보기
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && npm install",
    config = function()
      vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', {desc = 'Markdown Preview'})
    end,
  },
}
