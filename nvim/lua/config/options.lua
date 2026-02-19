-- lua/config/options.lua
-- vim.opt 기본 설정

vim.g.mapleader = " "

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
-- SSH 원격에서는 OSC 52로 로컬 클립보드 전송, 로컬에서는 시스템 클립보드
if os.getenv("SSH_TTY") then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
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

-- 커서 설정
vim.opt.guicursor = ""
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.virtualedit = "onemore"
vim.opt.whichwrap = "b,s,<,>,[,]"

-- 사인 컬럼 항상 표시 (git/diagnostics 깜빡임 방지)
vim.opt.signcolumn = "yes"

-- 분할 방향
vim.opt.splitbelow = true
vim.opt.splitright = true
