-- lua/config/keymaps.lua
-- 일반 키맵 (플러그인 무관)

local map = vim.keymap.set

-- 검색 하이라이트 제거
map('n', '<Esc>', ':noh<CR>', {silent = true})

-- 버퍼 이동
map('n', '<leader>bn', ':bnext<CR>', {desc = 'Next buffer'})
map('n', '<leader>bp', ':bprevious<CR>', {desc = 'Previous buffer'})
map('n', '<leader>bd', ':bdelete<CR>', {desc = 'Delete buffer'})
map('n', '<Tab>', ':bnext<CR>', {silent = true})
map('n', '<S-Tab>', ':bprevious<CR>', {silent = true})

-- 창 이동
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- 저장/종료
map('n', '<leader>w', ':w<CR>', {desc = 'Save'})
map('n', '<leader>q', ':q<CR>', {desc = 'Quit'})
map('n', '<leader>wq', ':wq<CR>', {desc = 'Save and Quit'})
map('n', '<leader>wa', ':wa<CR>', {desc = 'Save all'})

-- 빠른 종료
map('n', '<leader>qa', ':qa<CR>', {desc = 'Quit all'})
map('n', '<leader>Q', ':qa!<CR>', {desc = 'Force quit all'})

-- Visual 모드에서 들여쓰기 유지
map('v', '<', '<gv')
map('v', '>', '>gv')

-- 라인 이동
map('n', '<A-j>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')
map('v', '<A-j>', ":m '>+1<CR>gv=gv")
map('v', '<A-k>', ":m '<-2<CR>gv=gv")

-- 더 나은 paste
map('v', 'p', '"_dP')

-- 전체 선택
map('n', '<leader>a', 'ggVG', {desc = 'Select all'})

-- 빠른 replace
map('n', '<leader>s', ':%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>', {desc = 'Replace word'})
