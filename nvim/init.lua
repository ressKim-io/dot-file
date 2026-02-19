-- ~/.config/nvim/init.lua
-- DevOps 친화적 Neovim IDE 설정 (모듈 구조)

-- ============================================================================
-- 기본 설정 로드
-- ============================================================================
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.devops")

-- ============================================================================
-- 패키지 매니저 (lazy.nvim) 부트스트랩
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 플러그인 로드 (lua/plugins/ 전체 자동 로드)
-- ============================================================================
require("lazy").setup({
  { import = "plugins" },
}, {
  install = { colorscheme = { "tokyonight", "haiku" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ============================================================================
-- 상황별 테마 자동 변경 (실무 DevOps)
-- ============================================================================

-- WSL 여부는 세션 중 변하지 않으므로 1회만 검사
local _is_wsl_cached = nil
local function is_wsl()
  if _is_wsl_cached ~= nil then return _is_wsl_cached end
  local handle = io.popen("uname -r 2>/dev/null")
  if not handle then _is_wsl_cached = false; return false end
  local result = handle:read("*a")
  handle:close()
  _is_wsl_cached = (result:match("microsoft") or result:match("WSL")) and true or false
  return _is_wsl_cached
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

-- git branch 캐시 (디렉토리별, DirChanged/FocusGained에서만 갱신)
local _git_branch_cache = nil
local function refresh_git_branch()
  local handle = io.popen("git branch --show-current 2>/dev/null")
  if not handle then _git_branch_cache = nil; return end
  local branch = handle:read("*a"):gsub("\n", "")
  handle:close()
  _git_branch_cache = branch ~= "" and branch or nil
end

local function select_theme()
  local hour = get_current_hour()

  -- 우선순위 1: 프로덕션 디렉토리
  if is_production_dir() then
    vim.cmd("colorscheme gruvbox")
    vim.notify("PRODUCTION MODE - Be careful!", vim.log.levels.WARN)
    return
  end

  -- 우선순위 2: main/master 브랜치
  if _git_branch_cache == "main" or _git_branch_cache == "master" then
    vim.cmd("colorscheme gruvbox")
    vim.notify("Main branch - Production code!", vim.log.levels.WARN)
    return
  end

  -- 우선순위 3: 호스트별 (WSL vs Mac)
  if is_wsl() then
    vim.cmd("colorscheme tokyonight-storm")
    return
  end

  -- 우선순위 4: 시간대별
  if hour >= 9 and hour < 18 then
    vim.cmd("colorscheme rose-pine")
  else
    if is_dev_dir() then
      vim.cmd("colorscheme catppuccin")
    else
      vim.cmd("colorscheme tokyonight")
    end
  end
end

-- 초기 테마 설정
refresh_git_branch()
select_theme()

-- 디렉토리 변경 시 브랜치 갱신 + 테마 변경
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    refresh_git_branch()
    select_theme()
  end,
})

-- 포커스 복귀 시에만 브랜치 갱신 (BufEnter 제거 - 성능)
vim.api.nvim_create_autocmd("FocusGained", {
  pattern = "*",
  callback = function()
    refresh_git_branch()
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
  vim.notify("Theme: " .. themes[next_idx])
end, {desc = 'Toggle theme'})
