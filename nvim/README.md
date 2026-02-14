# Neovim Cloud Native DevOps IDE

Cloud Native/DevOps/Platform Engineering에 특화된 Neovim IDE 설정.
디버깅, 테스트 러너, 리팩토링, 코드 네비게이션, 모던 UI까지 갖춘 완전체 설정입니다.

---

## 특징

### IDE 핵심 기능
- **blink.cmp**: Rust 기반 고성능 자동완성 엔진
- **Mason**: LSP/DAP/린터/포맷터 자동 설치 및 관리
- **nvim-dap**: Go, Python, JS/TS 디버거 (브레이크포인트, 변수 확인, 스텝 실행)
- **neotest**: Go, Python 테스트 러너 (개별/파일 단위 실행, DAP 연동)
- **conform.nvim**: 저장 시 자동 포맷 (goimports, black, prettier, shfmt 등)
- **nvim-lint**: 자동 린팅 (golangci-lint, ruff, shellcheck, hadolint, yamllint)
- **Treesitter**: 22개 언어 구문 분석 + 점진적 선택
- **Aerial**: 심볼 아웃라인 (Structure 패널)
- **Refactoring**: Extract Function/Variable, Inline Variable

### Cloud Native / Kubernetes
- **YAML 스키마**: Kubernetes, Helm, ArgoCD, Kustomize, Docker Compose, GitHub Actions
- **kubectl 통합**: apply, delete, get, describe 빠른 실행
- **kubectl UI**: nvim 안에서 리소스 관리
- **Helm**: template 미리보기, lint
- **YAML path 확인**: 현재 위치의 YAML 경로 표시

### Container / IaC
- **Terraform**: fmt, validate, plan + LSP 자동완성 + tflint
- **Dockerfile**: LSP 자동완성 + hadolint 린팅
- **Docker Compose**: up/down 빠른 실행

### DevOps 도구
- **JSON/YAML 변환**: 선택 영역 즉시 변환
- **Base64 인코딩/디코딩**: Secret 관리
- **Git 통합**: LazyGit, Diffview, Gitsigns, Git Conflict 시각화
- **grug-far**: 프로젝트 전체 검색/치환

### 모던 UI
- **Noice**: 커맨드라인/메시지/알림 UI
- **Lualine**: 상태바 (mode, branch, diff, diagnostics, LSP)
- **Dropbar**: 브레드크럼 네비게이션
- **Bufferline**: 탭 스타일 버퍼 관리
- **Flash**: 빠른 점프 + Treesitter 선택

### 프로덕션 안전
- 프로덕션 디렉토리/main 브랜치에서 Gruvbox 경고 테마 자동 적용
- 시간대별 테마 자동 전환

---

## 파일 구조

```
nvim/
├── init.lua                    # 엔트리 포인트 (lazy.nvim 부트스트랩 + 테마)
├── lua/
│   ├── config/
│   │   ├── options.lua         # vim.opt 설정
│   │   ├── keymaps.lua         # 일반 키맵
│   │   ├── autocmds.lua        # 자동 명령
│   │   └── devops.lua          # DevOps 유틸리티 함수 & 키맵
│   └── plugins/
│       ├── lsp.lua             # mason + mason-lspconfig + lspconfig
│       ├── completion.lua      # blink.cmp + friendly-snippets
│       ├── dap.lua             # nvim-dap + dap-ui + Go/Python/JS 어댑터
│       ├── telescope.lua       # telescope + frecency
│       ├── treesitter.lua      # treesitter + 22개 파서
│       ├── git.lua             # gitsigns, diffview, lazygit, git-conflict, fugitive
│       ├── editor.lua          # surround, autopairs, flash, commentary, refactoring
│       ├── ui.lua              # noice, lualine, bufferline, dropbar, notify, 테마
│       ├── navigation.lua      # nvim-tree, oil, aerial
│       ├── testing.lua         # neotest + Go/Python 어댑터
│       ├── formatting.lua      # conform.nvim + nvim-lint
│       └── devops.lua          # terraform, helm, kubectl, yaml, schemastore
├── install.sh
└── lazy-lock.json
```

---

## 설치

```bash
./install.sh
```

자동으로:
1. Neovim 0.11+ 설치/업그레이드
2. 모듈 구조 설정 파일 복사
3. 필수 도구 설치 (ripgrep, fd, lazygit, shellcheck, shfmt)
4. 플러그인 설치 (lazy.nvim)
5. Mason이 LSP 서버, DAP 어댑터, 린터, 포맷터 자동 설치

---

## 주요 단축키

**Leader 키: Space**

### 파일 & 검색
| 단축키 | 기능 |
|--------|------|
| `<leader>ff` | 파일 검색 |
| `<leader>fg` | 텍스트 검색 (Grep) |
| `<leader>fr` | 최근 파일 |
| `<leader>fb` | 열린 버퍼 목록 |
| `<leader>fd` | 진단 목록 |
| `<leader>fs` | 문서 심볼 |
| `<leader>ft` | TODO/FIXME 검색 |
| `<leader>e` | 파일 트리 토글 |
| `-` | Oil 파일 관리자 |
| `<leader>o` | 심볼 아웃라인 (Aerial) |
| `<leader>sr` | 프로젝트 검색/치환 |

### 버퍼 & 창
| 단축키 | 기능 |
|--------|------|
| `Tab` / `Shift+Tab` | 다음/이전 버퍼 |
| `<leader>bd` | 버퍼 삭제 |
| `Ctrl+h/j/k/l` | 창 이동 |
| `<Ctrl+\>` | 터미널 토글 |

### LSP
| 단축키 | 기능 |
|--------|------|
| `gd` | 정의로 이동 |
| `gD` | 선언으로 이동 |
| `gi` | 구현으로 이동 |
| `gt` | 타입 정의로 이동 |
| `gr` | 참조 찾기 |
| `K` | 문서 보기 |
| `<leader>rn` | 이름 변경 |
| `<leader>ca` | 코드 액션 |
| `<leader>lf` | 포맷 |
| `[d` / `]d` | 이전/다음 진단 |

### 디버거 (DAP)
| 단축키 | 기능 |
|--------|------|
| `F5` | 계속 실행 |
| `F9` | 브레이크포인트 토글 |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift+F11` | Step Out |
| `<leader>du` | DAP UI 토글 |
| `<leader>dB` | 조건부 브레이크포인트 |
| `<leader>dr` | REPL 열기 |
| `<leader>dl` | 마지막 디버그 재실행 |

### 테스트 (Neotest)
| 단축키 | 기능 |
|--------|------|
| `<leader>tn` | 가장 가까운 테스트 실행 |
| `<leader>tF` | 파일 전체 테스트 실행 |
| `<leader>ts` | 테스트 요약 패널 |
| `<leader>to` | 테스트 출력 |
| `<leader>td` | 디버그 모드로 테스트 |

### Git
| 단축키 | 기능 |
|--------|------|
| `<leader>gg` | LazyGit 열기 |
| `<leader>gd` | Git Diff 열기 |
| `<leader>gh` | Git 파일 히스토리 |
| `<leader>gc` | Diffview 닫기 |
| `<leader>gb` | Git blame 현재 줄 |
| `<leader>hs` | Hunk stage |
| `<leader>hr` | Hunk reset |
| `<leader>hp` | Hunk preview |
| `]c` / `[c` | 다음/이전 hunk |

### 편집
| 단축키 | 기능 |
|--------|------|
| `s` | Flash 점프 |
| `S` | Flash Treesitter 선택 |
| `cs"'` | " 를 ' 로 변경 (Surround) |
| `<Alt+j/k>` | 라인 위/아래 이동 |
| `<leader>s` | 단어 치환 |
| `<leader>a` | 전체 선택 |
| `<leader>re` | Extract Function (visual) |
| `<leader>rv` | Extract Variable (visual) |
| `<leader>ri` | Inline Variable |

### 세션
| 단축키 | 기능 |
|--------|------|
| `<leader>ps` | 세션 복원 |
| `<leader>pS` | 세션 선택 |
| `<leader>pl` | 마지막 세션 복원 |

### Kubernetes
| 단축키 | 기능 |
|--------|------|
| `<leader>ka` | kubectl apply 현재 파일 |
| `<leader>kd` | kubectl delete 현재 파일 |
| `<leader>kg` | kubectl get (커서 위 리소스) |
| `<leader>kD` | kubectl describe (커서 위 리소스) |
| `<leader>kk` | kubectl UI 열기 |
| `<leader>ky` | YAML 경로 확인 |

### Helm
| 단축키 | 기능 |
|--------|------|
| `<leader>ht` | Helm template 미리보기 |
| `<leader>hl` | Helm lint |

### Terraform
| 단축키 | 기능 |
|--------|------|
| `<leader>tf` | Terraform fmt |
| `<leader>tv` | Terraform validate |
| `<leader>tp` | Terraform plan |

### Docker
| 단축키 | 기능 |
|--------|------|
| `<leader>db` | Docker build |
| `<leader>dc` | Docker compose up |
| `<leader>dC` | Docker compose down |

### JSON/YAML/Base64
| 단축키 | 모드 | 기능 |
|--------|------|------|
| `<leader>jy` | Visual | JSON -> YAML |
| `<leader>yj` | Visual | YAML -> JSON |
| `<leader>jf` | Normal/Visual | JSON 포맷팅 |
| `<leader>be` | Visual | Base64 인코딩 |
| `<leader>bd` | Visual | Base64 디코딩 |
| `<leader>yv` | Normal | YAML 검증 |

### 유틸리티
| 단축키 | 기능 |
|--------|------|
| `<leader>x` | 현재 파일 빠른 실행 (sh/py/js/go) |
| `<leader>yp` | 파일 전체 경로 복사 |
| `<leader>yr` | 상대 경로 복사 |
| `<leader>mp` | Markdown 미리보기 |
| `<leader>tt` | 테마 변경 |
| `<leader>xx` | 진단 목록 (Trouble) |
| `<leader>w` | 저장 |
| `<leader>q` | 종료 |

---

## LSP 서버 (Mason 자동 관리)

Mason이 아래 서버를 자동 설치합니다:

| 서버 | 언어 |
|------|------|
| gopls | Go |
| pyright | Python |
| ts_ls | TypeScript/JavaScript |
| terraformls | Terraform |
| tflint | Terraform Lint |
| yamlls | YAML (K8s/Helm/ArgoCD 스키마 포함) |
| bashls | Bash |
| dockerls | Dockerfile |
| lua_ls | Lua |

수동 관리: `:Mason` 명령으로 UI 열기

---

## 포맷터 & 린터

### 포맷터 (conform.nvim - 저장 시 자동 실행)
| 언어 | 포맷터 |
|------|--------|
| Go | goimports, gofumpt |
| Python | black, isort |
| JS/TS/JSON/YAML/MD | prettier |
| Terraform | terraform_fmt |
| Bash/sh | shfmt |
| Lua | stylua |

### 린터 (nvim-lint - 저장 시 자동 실행)
| 언어 | 린터 |
|------|------|
| Go | golangci-lint |
| Python | ruff |
| Bash/sh | shellcheck |
| Dockerfile | hadolint |
| YAML | yamllint |
| Terraform | tflint |

포매터 상태 확인: `:ConformInfo`

---

## 테마

자동 선택 우선순위:
1. **프로덕션 디렉토리** (`/production`, `/prod`) -> Gruvbox (경고)
2. **main/master 브랜치** -> Gruvbox (경고)
3. **WSL** -> Tokyo Night Storm
4. **낮 시간 (9-18시)** -> Rose Pine
5. **밤 시간** -> Tokyo Night (기본) / Catppuccin (dev 디렉토리)

수동 변경: `<leader>tt`

---

## 트러블슈팅

### 전체 상태 확인
```vim
:checkhealth
```

### LSP 문제
```vim
:LspInfo        " 연결된 LSP 서버 확인
:Mason          " LSP/DAP/린터/포맷터 관리
```

### 포맷터/린터 문제
```vim
:ConformInfo    " 포매터 상태 확인
```

### 플러그인 재설치
```bash
rm -rf ~/.local/share/nvim
nvim             # lazy.nvim이 자동 재설치
```

### 디버거 어댑터 확인
```vim
:Mason           " DAP 어댑터 설치 상태
" Go: delve (자동)
" Python: debugpy (자동)
" JS/TS: js-debug-adapter (Mason에서 수동 설치)
```

---

## 필수 외부 도구

```bash
# macOS
brew install jq yq yamllint hadolint kubectl helm terraform lazygit shellcheck shfmt

# Ubuntu/Debian
sudo apt-get install jq yamllint shellcheck

# yq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# hadolint
sudo wget -qO /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
sudo chmod +x /usr/local/bin/hadolint
```

---

## 검증

```bash
# 1. 플러그인 설치 확인
nvim --headless "+Lazy! sync" +qa

# 2. nvim 실행 후
:checkhealth           # 전체 상태
:Mason                 # LSP/DAP 설치 상태
:LspInfo               # LSP 연결 확인
:ConformInfo           # 포매터 상태

# 3. 기능 테스트
<leader>ff             # 파일 검색
<leader>gg             # LazyGit
<leader>o              # 심볼 아웃라인
F9 -> F5               # 디버거
<leader>tn             # 테스트 실행
```
