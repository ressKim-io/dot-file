-- lua/plugins/lsp.lua
-- mason.nvim + mason-lspconfig + lspconfig

return {
  -- Mason: LSP/DAP/Linter/Formatter 설치 관리
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "o",
            package_pending = ">",
            package_uninstalled = "x",
          },
        },
      })
    end,
  },

  -- Mason-LSPConfig: mason과 lspconfig 연동
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "pyright",
          "ts_ls",
          "terraformls",
          "yamlls",
          "bashls",
          "dockerls",
          "lua_ls",
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "b0o/schemastore.nvim",
    },
    config = function()
      -- LSP 키맵 설정 (LspAttach 이벤트 사용)
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf, noremap = true, silent = true }
          local function o(desc) return vim.tbl_extend('force', opts, {desc = desc}) end

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o('Go to definition'))
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, o('Go to declaration'))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, o('Go to implementation'))
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, o('Go to type definition'))
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, o('Hover documentation'))
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, o('Rename'))
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, o('Code action'))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, o('References'))
          vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, o('Format'))
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, o('Previous diagnostic'))
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, o('Next diagnostic'))
        end,
      })

      -- 진단 표시 설정
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "~" },
        signs = true,
        underline = true,
        update_in_insert = false,
        float = { border = "rounded" },
      })

      -- 서버별 설정 (nvim 0.11+)
      vim.lsp.config('gopls', {})
      vim.lsp.config('pyright', {})
      vim.lsp.config('ts_ls', {})
      vim.lsp.config('terraformls', {})
      vim.lsp.config('bashls', {})
      vim.lsp.config('dockerls', {})
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })
      -- schemastore.nvim 연동 + DevOps 커스텀 스키마
      local schemas = require("schemastore").yaml.schemas()
      -- DevOps 커스텀 스키마 추가
      schemas["kubernetes"] = {
        "*.k8s.yaml", "k8s/**/*.yaml", "kubernetes/**/*.yaml",
        "deploy*.yaml", "deployment*.yaml", "service*.yaml",
        "ingress*.yaml", "configmap*.yaml", "secret*.yaml",
      }
      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemas = schemas,
            format = { enable = true },
            validate = true,
            completion = true,
            hover = true,
          },
        },
      })

      -- LSP 서버 활성화
      vim.lsp.enable({
        'gopls', 'pyright', 'ts_ls', 'terraformls',
        'yamlls', 'bashls', 'dockerls', 'lua_ls',
      })
    end,
  },
}
