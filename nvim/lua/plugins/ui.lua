-- lua/plugins/ui.lua
-- noice, lualine, bufferline, dropbar, notify, dressing, themes

return {
  -- ========================================
  -- 테마
  -- ========================================

  -- Tokyo Night (일반 작업용)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
    end,
  },

  -- Catppuccin (개인 프로젝트용)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 999,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
      })
    end,
  },

  -- Gruvbox (프로덕션/경고용)
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 998,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
      })
    end,
  },

  -- Rose Pine (낮 시간대용)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 997,
    config = function()
      require("rose-pine").setup({
        variant = "main",
      })
    end,
  },

  -- ========================================
  -- UI 강화
  -- ========================================

  -- Noice (커맨드라인/메시지/알림 UI 혁신)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- Notify (알림 시스템)
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        timeout = 3000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })
      vim.notify = require("notify")
    end,
  },

  -- Dressing (select/input UI 개선)
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Lualine (상태바)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Dropbar (브레드크럼 네비게이션)
  {
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "center",
            }
          },
        },
      })
    end,
  },

  -- 들여쓰기 가이드
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- ========================================
  -- 테마 자동 전환 (production safety)
  -- ========================================

  -- 테마 선택 로직은 init.lua에서 VimEnter 후 실행
}
