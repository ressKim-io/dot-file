# Neovim IDE 사용법

> Leader 키 = `Space`

## 설치 후 필수 설정

### Nerd Font (아이콘 표시)
install.sh가 JetBrainsMono Nerd Font를 자동 설치합니다.
**터미널 앱에서 폰트를 직접 변경해야 합니다:**

- **iTerm2**: Preferences > Profiles > Text > Font → `JetBrainsMono Nerd Font`
- **Terminal.app**: 환경설정 > 프로파일 > 텍스트 > 서체 변경
- **WezTerm**: `font = wezterm.font("JetBrainsMono Nerd Font")`
- **Alacritty**: `font.normal.family: "JetBrainsMono Nerd Font"`

### 상태 점검
```
:checkhealth        # 전체 건강 상태 확인
:Mason              # LSP/린터/포매터 설치 상태
:ConformInfo        # 포매터 상태 확인
:Lazy               # 플러그인 관리
```

---

## 종료 방법

| 키 | 동작 |
|---|---|
| `Space q` | 현재 창 닫기 |
| `Space Q` | 전체 강제 종료 |
| `Space wq` | 저장 후 닫기 |
| `Space qa` | 모든 창 닫기 |
| `:q` | Vim 기본 종료 |
| `:qa!` | 저장 안하고 강제 종료 |
| `ZZ` | 저장 후 종료 (Vim 기본) |
| `ZQ` | 저장 안하고 종료 (Vim 기본) |

**떠다니는 창(floating window)에 갇혔을 때**: `Esc` 또는 `q`로 닫기
**터미널 모드에서 나가기**: `Ctrl+\` (toggleterm 토글)

---

## 파일 탐색 & 검색

| 키 | 동작 |
|---|---|
| `Space ff` | 파일 이름으로 검색 (Telescope) |
| `Space fg` | 파일 내용 검색 (live grep) |
| `Space fb` | 열린 버퍼 목록 |
| `Space fh` | 도움말 검색 |
| `Space fr` | 최근 파일 (frecency) |
| `Space fd` | 전체 진단 결과 |
| `Space fs` | 현재 파일 심볼 목록 |
| `Space e` | 파일 트리 열기/닫기 (NvimTree) |
| `-` | 상위 디렉토리 열기 (Oil) |
| `Space o` | 심볼 아웃라인 (Aerial) |

---

## 버퍼 (탭) 이동

| 키 | 동작 |
|---|---|
| `Tab` | 다음 버퍼 |
| `Shift+Tab` | 이전 버퍼 |
| `Space bd` | 버퍼 닫기 |

---

## 창(Window) 이동

| 키 | 동작 |
|---|---|
| `Ctrl+h` | 왼쪽 창 |
| `Ctrl+j` | 아래 창 |
| `Ctrl+k` | 위쪽 창 |
| `Ctrl+l` | 오른쪽 창 |

---

## 코드 편집

| 키 | 모드 | 동작 |
|---|---|---|
| `Alt+j` | Normal/Visual | 줄을 아래로 이동 |
| `Alt+k` | Normal/Visual | 줄을 위로 이동 |
| `<` / `>` | Visual | 들여쓰기 (선택 유지) |
| `Space a` | Normal | 전체 선택 |
| `Space s` | Normal | 커서 위 단어 바꾸기 |
| `s` | Normal | Flash 점프 (빠른 이동) |
| `S` | Normal | Flash Treesitter 선택 |
| `Ctrl+\` | Normal | 터미널 토글 (float) |

### Surround (감싸기)
- `ysaw"` : 단어를 `"`로 감싸기
- `ds"` : `"` 제거
- `cs"'` : `"`를 `'`로 변경

---

## LSP (자동완성/코드분석)

| 키 | 동작 |
|---|---|
| `gd` | 정의로 이동 |
| `gD` | 선언으로 이동 |
| `gi` | 구현으로 이동 |
| `gt` | 타입 정의로 이동 |
| `K` | 문서 팝업 |
| `gr` | 참조 목록 |
| `Space rn` | 이름 변경 (rename) |
| `Space ca` | 코드 액션 |
| `Space lf` | 포맷팅 |
| `[d` / `]d` | 이전/다음 진단 |

### 자동완성 (blink.cmp)
| 키 | 동작 |
|---|---|
| `Enter` | 선택 항목 적용 |
| `Tab` / `Shift+Tab` | 다음/이전 항목 |
| `Ctrl+Space` | 자동완성 수동 호출 |
| `Ctrl+e` | 자동완성 닫기 |
| `Ctrl+d` / `Ctrl+u` | 문서 스크롤 |

### 설치된 LSP 서버
gopls(Go), pyright(Python), ts_ls(TypeScript), terraformls(Terraform),
yamlls(YAML), bashls(Bash), dockerls(Docker), lua_ls(Lua)

---

## Git

| 키 | 동작 |
|---|---|
| `Space gg` | LazyGit 열기 |
| `Space gd` | Diffview 열기 |
| `Space gh` | 파일 히스토리 |
| `Space gc` | Diffview 닫기 |
| `]c` / `[c` | 다음/이전 hunk |
| `Space hs` | hunk 스테이지 |
| `Space hr` | hunk 리셋 |
| `Space hp` | hunk 미리보기 |
| `Space gb` | 현재 줄 git blame |

---

## 디버깅 (DAP)

| 키 | 동작 |
|---|---|
| `F5` | 디버그 시작/계속 |
| `F9` | 브레이크포인트 토글 |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift+F11` | Step Out |
| `Space du` | 디버그 UI 토글 |
| `Space dB` | 조건부 브레이크포인트 |
| `Space dr` | REPL 열기 |
| `Space dl` | 마지막 디버그 재실행 |

지원 언어: Go(Delve), Python(debugpy), JavaScript/TypeScript(pwa-node)

---

## 테스트 (Neotest)

| 키 | 동작 |
|---|---|
| `Space tn` | 커서 위치 테스트 실행 |
| `Space tF` | 현재 파일 전체 테스트 |
| `Space ts` | 테스트 요약 패널 |
| `Space to` | 테스트 출력 보기 |
| `Space tP` | 출력 패널 토글 |
| `Space td` | 디버그 모드로 테스트 |

---

## DevOps 단축키

### Kubernetes
| 키 | 동작 |
|---|---|
| `Space ka` | kubectl apply 현재 파일 |
| `Space kd` | kubectl delete 현재 파일 |
| `Space kD` | kubectl describe (커서 단어) |
| `Space kg` | kubectl get (커서 단어) |
| `Space kk` | kubectl UI 열기 |

### Helm
| 키 | 동작 |
|---|---|
| `Space ht` | helm template |
| `Space hl` | helm lint |

### Terraform
| 키 | 동작 |
|---|---|
| `Space tf` | terraform fmt |
| `Space tv` | terraform validate |
| `Space tp` | terraform plan |

### Docker
| 키 | 동작 |
|---|---|
| `Space db` | docker build (이미지 이름 입력) |
| `Space dc` | docker compose up -d |
| `Space dC` | docker compose down |

### 유틸리티
| 키 | 모드 | 동작 |
|---|---|---|
| `Space yp` | Normal | 절대 경로 복사 |
| `Space yr` | Normal | 상대 경로 복사 |
| `Space be` | Visual | Base64 인코딩 |
| `Space bd` | Visual | Base64 디코딩 |
| `Space jy` | Visual | JSON → YAML |
| `Space yj` | Visual | YAML → JSON |
| `Space jf` | Normal/Visual | JSON 포맷팅 |
| `Space yv` | Normal | YAML 검증 |
| `Space x` | Normal | 현재 파일 실행 (sh/py/js/go) |

---

## 검색 & 치환

| 키 | 동작 |
|---|---|
| `Space sr` | 프로젝트 전체 검색/치환 (grug-far) |
| `Space s` | 커서 단어 바꾸기 (파일 내) |
| `Space ft` | TODO/FIXME/NOTE 검색 |

---

## 진단 & 문제

| 키 | 동작 |
|---|---|
| `Space xx` | 전체 진단 목록 (Trouble) |
| `Space xw` | 현재 버퍼 진단 |

---

## 세션 관리

| 키 | 동작 |
|---|---|
| `Space ps` | 현재 디렉토리 세션 복원 |
| `Space pS` | 세션 선택 |
| `Space pl` | 마지막 세션 복원 |
| `Space pd` | 세션 저장 중지 |

---

## 리팩토링

| 키 | 모드 | 동작 |
|---|---|---|
| `Space re` | Visual | 함수 추출 |
| `Space rv` | Visual | 변수 추출 |
| `Space ri` | Normal | 변수 인라인 |

---

## 테마

현재 상황에 따라 자동 적용:
- **프로덕션 디렉토리** (`/prod`, `/production` 등): Gruvbox (경고 표시)
- **main/master 브랜치**: Gruvbox (경고 표시)
- **WSL**: Tokyo Night Storm
- **낮 (09~18시)**: Rose Pine
- **밤 + dev 디렉토리**: Catppuccin
- **밤 + 기타**: Tokyo Night

| 키 | 동작 |
|---|---|
| `Space tt` | 테마 수동 순환 변경 |

---

## 자동 포맷 (저장 시)

| 언어 | 포매터 |
|---|---|
| Go | goimports + gofumpt |
| Python | black + isort |
| JS/TS/JSON/YAML/MD | prettier |
| Terraform/HCL | terraform_fmt |
| Bash/Shell | shfmt |
| Lua | stylua |

---

## 자동 린팅

| 언어 | 린터 |
|---|---|
| Go | golangci-lint |
| Python | ruff |
| Bash/Shell | shellcheck |
| Dockerfile | hadolint |
| YAML | yamllint |
| Terraform | tflint |

---

## which-key

아무 키 조합의 첫 키를 누르고 기다리면 (500ms) 사용 가능한 키맵 목록이 팝업으로 표시됩니다.
예: `Space`를 누르고 기다리면 모든 Leader 키맵을 볼 수 있습니다.

---

## 트러블슈팅

### 아이콘이 ? 로 보일 때
1. Nerd Font 설치: `cd nvim && ./install.sh` (Nerd Font 자동 설치)
2. 터미널 폰트를 `JetBrainsMono Nerd Font`로 변경
3. 터미널 재시작

### 화면에서 나갈 수 없을 때
- `Esc` 여러 번 → `Space q` 또는 `:q`
- 터미널 모드: `Ctrl+\`로 토글
- 최후의 수단: `:qa!` (저장 없이 전체 종료)

### 플러그인 에러
```vim
:Lazy sync          " 플러그인 재설치/업데이트
:Lazy clean         " 사용하지 않는 플러그인 삭제
:Lazy health        " 플러그인 건강 상태
```

### LSP가 동작하지 않을 때
```vim
:Mason              " LSP 서버 설치 상태 확인
:LspInfo            " 현재 활성 LSP 확인
:LspLog             " LSP 로그 확인
```
