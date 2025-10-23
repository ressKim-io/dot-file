syntax on "구문 강조
set hlsearch "검색어 하이라이팅
set nu "줄번호
set autoindent "자동 들여쓰기
set paste "붙여넣기 계단현상 없애기

"theme 변경
colorscheme gruvbox 

call plug#begin('~/.vim/plugged')
  Plug 'preservim/nerdtree'
call plug#end()

" -------------
" vim-go setting
" -------------
filetype plugin indent on 

" vim-Plug Plugin List
call plug#begin('~/.vim/plugged')

" 자동완성을 해주는 Plugin이다. 많은 Launguge를 지원하고 :CoCInstall coc-<lang> 으로 지원되는 Languge 설치가 가능
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 유명한 플러그인들
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'

" Vim-go를 사용하기 위한 Plugin
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" 나만의 자동 완성을 만들수 있는 Plugin 이다. 
Plug 'SirVer/ultisnips'

" 편의
Plug 'milkypostman/vim-togglelist'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'mhinz/vim-startify'

" preview를 해주는 유용한 plugin
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fzf 사용시 꼭 설치하고 ~/.fzf 에 들어가서 ./install --all 하자
Plug 'junegunn/fzf.vim'

" Initialize plugin system
call plug#end()

" 저장할 때 자동으로 formatting 및 import from https://johngrib.github.io/
let g:go_fmt_command = "goimports"
let g:go_list_type = "quickfix"
let g:go_addtags_transform = "camelcase"

let g:go_autodetect_gopath = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_operators = 1
let g:go_auto_type_info = 1
let g:go_auto_sameids = 1

" quickfix 이동 및 open/close from https://johngrib.github.io/
nnoremap <C-n> :cnext<CR>
nnoremap <C-p> :cprevious<CR>
nnoremap <LocalLeader>q :call ToggleQuickfixList()<CR>

" 테스트 커버리지 검사 및 색깔 표시 토글 from https://johngrib.github.io/
nnoremap <LocalLeader>c :GoCoverageToggle<CR>

" 자주 쓰는 기능들 from https://johngrib.github.io/
autocmd FileType go nnoremap <Tab>b :GoBuild<CR>
autocmd FileType go nnoremap <Tab>r :GoRun<CR>
autocmd FileType go nnoremap <Tab><Tab>r :GoRun %<CR>
 
autocmd FileType go nnoremap <Tab>t :GoTest<CR>
autocmd FileType go nnoremap <Tab><Tab>t :GoTestFunc<CR>
autocmd FileType go nnoremap <Tab>c :GoCoverageToggle<CR>
