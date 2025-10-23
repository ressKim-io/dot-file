-- ~/.config/nvim/init.lua
-- 최소한의 DevOps 친화적 Neovim 설정

-- ============================================================================
-- 기본 설정
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 300
vim.opt.clipboard = "unnamedplus"

-- 백업 및 스왑 파일
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Undo 히스토리 영구 저장
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- 숨김 파일 무시
vim.opt.wildignore = {
  "*.swp", "*.bak", "*.pyc", "*.class",
  "*/.git/*", "*/.hg/*", "*/.svn/*",
  "*/node_modules/*", "*/vendor/*",
  "*.o", "*.obj", "*.exe", "*.so", "*.dll"
}

-- 더 나은 diff
vim.opt.diffopt:append("vertical,algorithm:patience")

-- 더 나은 completion
vim.opt.completeopt = {"menu", "menuone", "noselect"}

-- 숨김 버퍼 허용
vim.opt.hidden = true

-- 마우스 지원
vim.opt.mouse = "a"

vim.g.mapleader = " "

-- ============================================================================
-- 패키지 매니저 설치 (lazy.nvim)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 플러그인 설정
-- ============================================================================
require("lazy").setup({
  -- LSP 기본 설정
  {
    "neovim/nvim-lspconfig",
    config = function()
      local servers = {
        gopls = {},
        pyright = {},
        ts_ls = {},
        terraformls = {},
        tflint = {},
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                -- Kubernetes
                kubernetes = {
                  "*.k8s.yaml",
                  "k8s/**/*.yaml",
                  "kubernetes/**/*.yaml",
                  "deploy*.yaml",
                  "deployment*.yaml",
                  "service*.yaml",
                  "ingress*.yaml",
                  "configmap*.yaml",
                  "secret*.yaml",
                },
                -- Helm
                ["https://json.schemastore.org/helmfile"] = "helmfile*.yaml",
                ["https://json.schemastore.org/chart"] = "Chart.yaml",
                ["https://json.schemastore.org/helmvalues"] = "values*.yaml",
                -- ArgoCD
                ["https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/crds/application-crd.yaml"] = {
                  "argocd/application*.yaml",
                  "**/argo*/application*.yaml",
                },
                ["https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/crds/appproject-crd.yaml"] = {
                  "argocd/appproject*.yaml",
                  "**/argo*/appproject*.yaml",
                },
                -- CI/CD
                ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.yml",
                -- Docker
                ["http://json.schemastore.org/docker-compose"] = {
                  "docker-compose*.yml",
                  "docker-compose*.yaml",
                  "compose*.yml",
                  "compose*.yaml",
                },
                -- Kustomize
                ["https://json.schemastore.org/kustomization"] = "kustomization.yaml",
              },
              format = {
                enable = true,
              },
              validate = true,
              completion = true,
              hover = true,
            },
          }
        },
        bashls = {},
        dockerls = {},
      }

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
      
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, {desc = 'Go to definition'}))
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, {desc = 'Hover documentation'}))
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, {desc = 'Rename'}))
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, {desc = 'Code action'}))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, {desc = 'References'}))
        end,
      })
    end
  },

  -- 자동완성
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      })
    end
  },

  -- 파일 탐색/검색 (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = 'Find files'})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = 'Live grep'})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc = 'Buffers'})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = 'Help'})
    end
  },

  -- 파일 트리
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {desc = 'Toggle file tree'})
    end
  },

  -- Git 통합
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end
  },

  -- 터미널
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup{
        direction = 'float',
        open_mapping = [[<c-\>]],
      }
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "go", "python", "javascript", "typescript", "java",
          "lua", "bash", "yaml", "json", "hcl", "dockerfile"
        },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end
  },

  -- Terraform
  {
    "hashivim/vim-terraform",
    ft = {"terraform", "hcl"},
    config = function()
      vim.g.terraform_fmt_on_save = 1
      vim.g.terraform_align = 1
    end
  },

  -- ========================================
  -- 🎨 여러 테마 동시 설치 (실무 DevOps)
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
    end
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
    end
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
    end
  },

  -- Rose Pine (낮 시간대용)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 997,
    config = function()
      require("rose-pine").setup({
        variant = "main",  -- dawn(밝음), main, moon(어두움)
      })
    end
  },

  -- Git Fugitive
  {
    "tpope/vim-fugitive",
  },

  -- 주석
  {
    "tpope/vim-commentary",
  },

  -- 에러/경고
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
      vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', {desc = 'Diagnostics'})
      vim.keymap.set('n', '<leader>xw', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', {desc = 'Buffer Diagnostics'})
    end
  },

  -- 키맵 가이드
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end
  },

  -- Git Blame 인라인 표시
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
        },
      })
    end
  },

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
    end
  },

  -- 자동 페어
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  },

  -- Surround (cs"')
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end
  },

  -- 들여쓰기 가이드
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end
  },

  -- 최근 파일
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = {"nvim-telescope/telescope.nvim"},
    config = function()
      require("telescope").load_extension("frecency")
      vim.keymap.set('n', '<leader>fr', ':Telescope frecency<CR>', {desc = 'Recent files'})
    end
  },

  -- 버퍼 관리 개선
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
        }
      })
    end
  },

  -- JSON/JSONC 지원 향상
  {
    "b0o/schemastore.nvim",
  },

  -- Markdown 미리보기
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', {desc = 'Markdown Preview'})
    end
  },

  -- ========================================
  -- ☸️  Cloud Native / DevOps 도구
  -- ========================================

  -- Kubernetes YAML 지원 강화
  {
    "cuducos/yaml.nvim",
    ft = {"yaml"},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      -- Quick key to get current YAML path
      vim.keymap.set('n', '<leader>ky', ':lua require("yaml_nvim").view()<CR>', {desc = 'YAML path'})
    end
  },

  -- Helm 지원
  {
    "towolf/vim-helm",
    ft = "helm",
  },

  -- REST API 테스트 (curl 대체)
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "http",
    config = function()
      require("rest-nvim").setup({
        result_split_horizontal = false,
        result_split_in_place = false,
        skip_ssl_verification = false,
        encode_url = true,
        highlight = {
          enabled = true,
          timeout = 150,
        },
      })
      vim.keymap.set('n', '<leader>rr', ':lua require("rest-nvim").run()<CR>', {desc = 'Run REST request'})
      vim.keymap.set('n', '<leader>rl', ':lua require("rest-nvim").last()<CR>', {desc = 'Run last REST'})
    end
  },

  -- Terraform 고급 기능
  {
    "hashivim/vim-terraform",
    ft = {"terraform", "hcl"},
    config = function()
      vim.g.terraform_fmt_on_save = 1
      vim.g.terraform_align = 1
      vim.g.terraform_fold_sections = 1
    end
  },

  -- Dockerfile 린팅 (hadolint)
  {
    "hadolint/hadolint",
    ft = "dockerfile",
  },

  -- 환경변수 하이라이트
  {
    "ErichDonGubler/dotenv.nvim",
    config = function()
      require('dotenv').setup()
    end
  },

  -- Git 고급 기능 (Diffview)
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', {desc = 'Git Diff'})
      vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory<CR>', {desc = 'Git History'})
      vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', {desc = 'Close Diffview'})
    end
  },

  -- HTTP 파일 문법 강조
  {
    "rest-nvim/rest.nvim",
  },

  -- Kubernetes 리소스 미리보기 (선택적 - kubectl 필요)
  {
    "ramilito/kubectl.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("kubectl").setup()
      vim.keymap.set('n', '<leader>kk', ':lua require("kubectl").open()<CR>', {desc = 'Open kubectl UI'})
    end
  },

})

-- ============================================================================
-- 🎯 상황별 테마 자동 변경 (실무 DevOps)
-- ============================================================================

-- 헬퍼 함수들
local function is_wsl()
  local handle = io.popen("uname -r")
  local result = handle:read("*a")
  handle:close()
  return result:match("microsoft") or result:match("WSL")
end

local function get_current_hour()
  return tonumber(os.date("%H"))
end

local function is_production_dir()
  local cwd = vim.fn.getcwd()
  return cwd:match("/production") or 
         cwd:match("/prod") or 
         cwd:match("/aws%-infra") or
         cwd:match("/terraform%-prod")
end

local function is_dev_dir()
  local cwd = vim.fn.getcwd()
  return cwd:match("/dev") or 
         cwd:match("/development") or
         cwd:match("/test")
end

local function get_git_branch()
  local handle = io.popen("git branch --show-current 2>/dev/null")
  if not handle then return nil end
  local branch = handle:read("*a"):gsub("\n", "")
  handle:close()
  return branch ~= "" and branch or nil
end

-- 테마 선택 로직
local function select_theme()
  local hour = get_current_hour()
  local branch = get_git_branch()
  
  -- ⭐⭐⭐ 우선순위 1: 프로덕션 디렉토리 (가장 중요!)
  if is_production_dir() then
    vim.cmd("colorscheme gruvbox")
    print("⚠️  PRODUCTION MODE - Be careful!")
    return
  end
  
  -- ⭐⭐⭐ 우선순위 2: main/master 브랜치 (실수 방지)
  if branch == "main" or branch == "master" then
    vim.cmd("colorscheme gruvbox")
    print("⚠️  Main branch - Production code!")
    return
  end
  
  -- ⭐⭐⭐ 우선순위 3: 호스트별 (WSL vs Mac)
  if is_wsl() then
    vim.cmd("colorscheme tokyonight-storm")  -- WSL은 조금 어두운 톤
    return
  end
  
  -- ⭐⭐ 우선순위 4: 시간대별 (낮/밤)
  if hour >= 9 and hour < 18 then
    -- 낮 시간대 (9시-18시)
    vim.cmd("colorscheme rose-pine")  -- 밝은 테마
  else
    -- 밤 시간대 (18시-9시)
    if is_dev_dir() then
      vim.cmd("colorscheme catppuccin")  -- 개발 디렉토리
    else
      vim.cmd("colorscheme tokyonight")  -- 기본
    end
  end
end

-- 초기 테마 설정
select_theme()

-- 디렉토리 변경 시 자동으로 테마 변경
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    select_theme()
  end,
})

-- Git 브랜치 변경 감지 (파일 저장/읽기 시 체크)
vim.api.nvim_create_autocmd({"BufEnter", "FocusGained"}, {
  pattern = "*",
  callback = function()
    select_theme()
  end,
})

-- 수동 테마 변경 단축키
vim.keymap.set('n', '<leader>tt', function()
  local themes = {"tokyonight", "catppuccin", "gruvbox", "rose-pine"}
  local current = vim.g.colors_name
  local current_idx = 1
  
  for i, theme in ipairs(themes) do
    if theme == current then
      current_idx = i
      break
    end
  end
  
  local next_idx = (current_idx % #themes) + 1
  vim.cmd("colorscheme " .. themes[next_idx])
  print("Theme: " .. themes[next_idx])
end, {desc = 'Toggle theme'})

-- ============================================================================
-- 추가 키맵
-- ============================================================================
vim.keymap.set('n', '<Esc>', ':noh<CR>', {silent = true})

-- 버퍼 이동
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', {desc = 'Next buffer'})
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', {desc = 'Previous buffer'})
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', {desc = 'Delete buffer'})
vim.keymap.set('n', '<Tab>', ':bnext<CR>', {silent = true})
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', {silent = true})

-- 창 이동
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- 저장/종료
vim.keymap.set('n', '<leader>w', ':w<CR>', {desc = 'Save'})
vim.keymap.set('n', '<leader>q', ':q<CR>', {desc = 'Quit'})
vim.keymap.set('n', '<leader>wq', ':wq<CR>', {desc = 'Save and Quit'})
vim.keymap.set('n', '<leader>wa', ':wa<CR>', {desc = 'Save all'})

-- 빠른 종료
vim.keymap.set('n', '<leader>qa', ':qa<CR>', {desc = 'Quit all'})
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', {desc = 'Force quit all'})

-- Visual 모드에서 들여쓰기 유지
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- 라인 이동
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")

-- 더 나은 paste
vim.keymap.set('v', 'p', '"_dP')

-- 전체 선택
vim.keymap.set('n', '<leader>a', 'ggVG', {desc = 'Select all'})

-- 빠른 replace
vim.keymap.set('n', '<leader>s', ':%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>', {desc = 'Replace word'})

-- ============================================================================
-- 언어별 설정
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end
})

-- ============================================================================
-- 자동 명령
-- ============================================================================

-- 저장 시 trailing whitespace 제거
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end
})

-- 파일 저장 시 자동 포맷 (특정 파일 타입)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.go", "*.lua", "*.rs", "*.py"},
  callback = function()
    vim.lsp.buf.format({ async = false })
  end
})

-- 마지막 편집 위치로 이동
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end
})

-- Undo 디렉토리 자동 생성
local undo_dir = vim.fn.stdpath("data") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end

-- ============================================================================
-- 유틸리티 함수
-- ============================================================================

-- 현재 파일의 전체 경로 복사
vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, {desc = 'Copy file path'})

-- 현재 파일의 상대 경로 복사
vim.keymap.set('n', '<leader>yr', function()
  local path = vim.fn.expand('%:.')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, {desc = 'Copy relative path'})

-- Git blame 현재 줄
vim.keymap.set('n', '<leader>gb', function()
  local file = vim.fn.expand('%')
  local line = vim.fn.line('.')
  local cmd = string.format('git blame -L %d,%d %s', line, line, file)
  local result = vim.fn.system(cmd)
  print(result)
end, {desc = 'Git blame line'})

-- ============================================================================
-- ☸️  Cloud Native / DevOps 유틸리티 함수
-- ============================================================================

-- Base64 인코딩/디코딩
vim.keymap.set('v', '<leader>be', function()
  vim.cmd("'<,'>!base64")
end, {desc = 'Base64 encode'})

vim.keymap.set('v', '<leader>bd', function()
  vim.cmd("'<,'>!base64 -d")
end, {desc = 'Base64 decode'})

-- JSON <-> YAML 변환
vim.keymap.set('v', '<leader>jy', function()
  vim.cmd("'<,'>!yq eval -P")
end, {desc = 'JSON to YAML'})

vim.keymap.set('v', '<leader>yj', function()
  vim.cmd("'<,'>!yq eval -o=json")
end, {desc = 'YAML to JSON'})

-- JSON 포맷팅
vim.keymap.set('v', '<leader>jf', function()
  vim.cmd("'<,'>!jq .")
end, {desc = 'JSON format'})

vim.keymap.set('n', '<leader>jf', function()
  vim.cmd("%!jq .")
end, {desc = 'JSON format (whole file)'})

-- YAML 검증
vim.keymap.set('n', '<leader>yv', function()
  local file = vim.fn.expand('%')
  local result = vim.fn.system('yamllint ' .. file)
  if vim.v.shell_error == 0 then
    print('✅ YAML is valid')
  else
    print('❌ YAML validation failed:\n' .. result)
  end
end, {desc = 'Validate YAML'})

-- Kubernetes kubectl apply 현재 파일
vim.keymap.set('n', '<leader>ka', function()
  local file = vim.fn.expand('%')
  vim.cmd('!kubectl apply -f ' .. file)
end, {desc = 'kubectl apply current file'})

-- Kubernetes kubectl delete 현재 파일
vim.keymap.set('n', '<leader>kd', function()
  local file = vim.fn.expand('%')
  vim.cmd('!kubectl delete -f ' .. file)
end, {desc = 'kubectl delete current file'})

-- Kubernetes 리소스 describe (현재 커서 위치의 이름)
vim.keymap.set('n', '<leader>kD', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('!kubectl describe ' .. word)
end, {desc = 'kubectl describe'})

-- Kubernetes 리소스 get (현재 커서 위치의 이름)
vim.keymap.set('n', '<leader>kg', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('!kubectl get ' .. word)
end, {desc = 'kubectl get'})

-- Helm template 미리보기
vim.keymap.set('n', '<leader>ht', function()
  local cwd = vim.fn.getcwd()
  vim.cmd('!helm template ' .. cwd)
end, {desc = 'Helm template preview'})

-- Helm lint
vim.keymap.set('n', '<leader>hl', function()
  local cwd = vim.fn.getcwd()
  vim.cmd('!helm lint ' .. cwd)
end, {desc = 'Helm lint'})

-- Terraform fmt 현재 파일
vim.keymap.set('n', '<leader>tf', function()
  local file = vim.fn.expand('%')
  vim.cmd('!terraform fmt ' .. file)
  vim.cmd('e!')
end, {desc = 'Terraform fmt'})

-- Terraform validate
vim.keymap.set('n', '<leader>tv', function()
  vim.cmd('!terraform validate')
end, {desc = 'Terraform validate'})

-- Terraform plan
vim.keymap.set('n', '<leader>tp', function()
  vim.cmd('!terraform plan')
end, {desc = 'Terraform plan'})

-- Docker build (현재 디렉토리의 Dockerfile)
vim.keymap.set('n', '<leader>db', function()
  local name = vim.fn.input('Image name: ')
  if name ~= '' then
    vim.cmd('!docker build -t ' .. name .. ' .')
  end
end, {desc = 'Docker build'})

-- Docker compose up
vim.keymap.set('n', '<leader>du', function()
  vim.cmd('!docker-compose up -d')
end, {desc = 'Docker compose up'})

-- Docker compose down
vim.keymap.set('n', '<leader>dd', function()
  vim.cmd('!docker-compose down')
end, {desc = 'Docker compose down'})

-- 빠른 실행 (현재 파일)
vim.keymap.set('n', '<leader>x', function()
  local file = vim.fn.expand('%')
  local ext = vim.fn.expand('%:e')

  if ext == 'sh' then
    vim.cmd('!bash ' .. file)
  elseif ext == 'py' then
    vim.cmd('!python ' .. file)
  elseif ext == 'js' then
    vim.cmd('!node ' .. file)
  elseif ext == 'go' then
    vim.cmd('!go run ' .. file)
  else
    print('Unsupported file type: ' .. ext)
  end
end, {desc = 'Quick run current file'})
