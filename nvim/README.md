# Neovim Cloud Native DevOps 설정

**VSCode 대신 Neovim!** Cloud Native/DevOps 환경에 특화된 완전체 설정입니다.

---

## ✨ 특징

### ☸️  Cloud Native / Kubernetes
- ✅ **YAML 스키마**: Kubernetes, Helm, ArgoCD, Kustomize
- ✅ **kubectl 통합**: apply, delete, get, describe 빠른 실행
- ✅ **Helm**: template 미리보기, lint
- ✅ **kubectl UI**: nvim 안에서 리소스 관리
- ✅ **YAML path 확인**: 현재 위치의 YAML 경로 표시

### 🐳 Container / IaC
- ✅ **Terraform**: fmt, validate, plan 자동 실행
- ✅ **Dockerfile**: hadolint 린팅
- ✅ **Docker Compose**: up/down 빠른 실행
- ✅ **환경변수**: .env 파일 하이라이트

### 🔧 DevOps 도구
- ✅ **REST API 테스트**: curl 대신 .http 파일로 테스트
- ✅ **JSON/YAML 변환**: 선택 영역 즉시 변환
- ✅ **Base64 인코딩/디코딩**: Secret 관리
- ✅ **Git Diffview**: 변경사항 시각화

### 🎯 기본 기능
- ✅ **LSP**: Go, Python, Terraform, YAML, Bash, Docker
- ✅ **프로덕션 안전**: 디렉토리별 자동 테마 변경
- ✅ **Git**: Blame 인라인, 브랜치 감지
- ✅ **자동 포맷**: on save (Go, Python, Lua, Rust)
- ✅ **TODO 관리**: 프로젝트 전체 TODO/FIXME 검색
- ✅ **생산성**: Telescope, NvimTree, 버퍼라인, 자동 페어

---

## 🚀 설치

```bash
./install.sh
```

자동으로:
- Neovim 설치
- 설정 파일 복사
- LSP 서버 설치 (선택)
- 플러그인 설치

---

## ⌨️  주요 단축키

**Leader 키: Space**

### 파일 & 검색
| 단축키 | 기능 |
|--------|------|
| `<leader>ff` | 파일 검색 |
| `<leader>fg` | 텍스트 검색 (Grep) |
| `<leader>fr` | 최근 파일 |
| `<leader>ft` | TODO/FIXME 검색 |
| `<leader>e` | 파일 트리 토글 |

### 버퍼 & 창
| 단축키 | 기능 |
|--------|------|
| `Tab` / `Shift+Tab` | 다음/이전 버퍼 |
| `<leader>bd` | 버퍼 삭제 |
| `Ctrl+h/j/k/l` | 창 이동 |

### LSP
| 단축키 | 기능 |
|--------|------|
| `gd` | 정의로 이동 |
| `K` | 문서 보기 |
| `<leader>rn` | 이름 변경 |
| `<leader>ca` | 코드 액션 |
| `gr` | 참조 찾기 |

### Git
| 단축키 | 기능 |
|--------|------|
| `<leader>gb` | Git blame 현재 줄 |

### 편집
| 단축키 | 기능 |
|--------|------|
| `cs"'` | " 를 ' 로 변경 (Surround) |
| `<Alt+j/k>` | 라인 위/아래 이동 |
| `<leader>s` | 단어 치환 |
| `<leader>a` | 전체 선택 |

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
| `<leader>du` | Docker compose up |
| `<leader>dd` | Docker compose down |

### JSON/YAML/Base64 (Visual 모드)
| 단축키 | 기능 |
|--------|------|
| `<leader>jy` | JSON → YAML |
| `<leader>yj` | YAML → JSON |
| `<leader>jf` | JSON 포맷팅 |
| `<leader>be` | Base64 인코딩 |
| `<leader>bd` | Base64 디코딩 |
| `<leader>yv` | YAML 검증 |

### REST API
| 단축키 | 기능 |
|--------|------|
| `<leader>rr` | REST 요청 실행 (.http 파일) |
| `<leader>rl` | 마지막 요청 재실행 |

### 유틸리티
| 단축키 | 기능 |
|--------|------|
| `<leader>x` | 현재 파일 빠른 실행 (sh/py/js/go) |
| `<leader>yp` | 파일 경로 복사 |
| `<leader>yr` | 상대 경로 복사 |
| `<leader>mp` | Markdown 미리보기 |
| `<leader>tt` | 테마 변경 |
| `<Ctrl+\>` | 터미널 토글 |
| `<leader>w` | 저장 |
| `<leader>q` | 종료 |

---

## 🎯 실무 활용

### Kubernetes 워크플로우
```bash
# 1. deployment.yaml 편집
nvim deployment.yaml

# 2. LSP가 자동으로 Kubernetes 스키마 로드
#    → 자동완성, 에러 검증

# 3. 현재 파일 바로 적용
<leader>ka  # kubectl apply -f deployment.yaml

# 4. Pod 상태 확인
<leader>kk  # kubectl UI 열기

# 5. 리소스 빠른 조회
커서를 "nginx" 위에 놓고
<leader>kg  # kubectl get nginx
```

### Helm Chart 개발
```bash
nvim values.yaml

# 1. values 스키마 자동 검증
# 2. Template 미리보기
<leader>ht  # helm template .

# 3. Lint 체크
<leader>hl  # helm lint .
```

### Terraform 워크플로우
```bash
nvim main.tf

# 1. 저장 시 자동 fmt
:w

# 2. Validate
<leader>tv  # terraform validate

# 3. Plan
<leader>tp  # terraform plan
```

### Secret/ConfigMap 관리
```yaml
# secret.yaml 편집
apiVersion: v1
kind: Secret
data:
  password: 선택 후 <leader>be  # Base64 인코딩
```

### REST API 테스트
```http
# api.http 파일 생성
GET https://api.github.com/users/hyeokjun
Authorization: token xxx

###

POST https://api.example.com/users
Content-Type: application/json

{
  "name": "test"
}
```
`<leader>rr` 로 즉시 실행!

### JSON/YAML 변환
```bash
# JSON 선택 후
<leader>jy  # YAML로 변환

# YAML 선택 후
<leader>yj  # JSON으로 변환
```

---

## 📦 LSP 서버 수동 설치

```bash
# Go
go install golang.org/x/tools/gopls@latest

# Python
npm install -g pyright

# TypeScript
npm install -g typescript-language-server typescript

# YAML
npm install -g yaml-language-server

# Bash
npm install -g bash-language-server

# Docker
npm install -g dockerfile-language-server-nodejs

# Terraform (Mac)
brew install terraform-ls tflint
```

---

## 🎨 테마

자동 선택 우선순위:
1. **프로덕션 디렉토리** → Gruvbox (경고)
2. **main/master 브랜치** → Gruvbox (경고)
3. **WSL** → Tokyo Night Storm
4. **낮 시간 (9-18시)** → Rose Pine
5. **밤 시간** → Tokyo Night / Catppuccin

수동 변경: `<leader>tt`

---

## 🔧 트러블슈팅

### LSP가 작동하지 않음
```bash
# Neovim에서 확인
:checkhealth
:LspInfo

# LSP 서버 설치 확인
which gopls
which pyright
```

### 플러그인 오류
```bash
# 플러그인 재설치
rm -rf ~/.local/share/nvim
nvim
# 자동으로 재설치됨
```

---

## 💡 추가된 생산성 기능

### 자동 기능
- ✅ 저장 시 trailing whitespace 자동 제거
- ✅ Go/Python/Lua/Rust 자동 포맷 on save
- ✅ 마지막 편집 위치 자동 복원
- ✅ Undo 히스토리 영구 저장

### TODO 관리
```go
// TODO: 이 함수 리팩토링 필요
// FIXME: 버그 수정 필요
// NOTE: 중요한 주의사항
// HACK: 임시 해결책
// PERF: 성능 최적화 필요
```
`<leader>ft`로 프로젝트 전체 TODO 검색

### Git Blame
코드 위에 커밋 정보가 자동으로 표시됨:
```
혁준 • 2 days ago • feat: add new feature
def my_function():
    pass
```

---

## 📦 필수 도구 설치

nvim 외에 다음 도구들이 필요합니다:

```bash
# macOS
brew install jq yq yamllint hadolint kubectl helm terraform

# Ubuntu/Debian
sudo apt-get install jq yamllint

# yq (Go 버전)
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# hadolint (Docker 린터)
sudo wget -qO /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
sudo chmod +x /usr/local/bin/hadolint
```

---

## 💡 VSCode vs Neovim

### 왜 Neovim?
- ✅ **초고속**: 메모리 사용량 1/10, 시작 속도 10배
- ✅ **SSH 원격**: 서버에서 바로 편집
- ✅ **터미널 통합**: kubectl, helm, terraform 즉시 실행
- ✅ **경량**: Electron 없음
- ✅ **커스터마이징**: 모든 것을 Lua로 제어

### 이 설정의 장점
- ✅ Kubernetes YAML 자동완성/검증
- ✅ kubectl 명령어 nvim 안에서 실행
- ✅ Helm/Terraform/Docker 통합
- ✅ REST API 테스트 (Postman 필요 없음)
- ✅ JSON/YAML/Base64 즉시 변환
- ✅ Git diff 시각화

---

## 📝 업데이트

- 2024.10.23: **Cloud Native 풀셋 추가!** (Kubernetes, Helm, Terraform, Docker, REST API)
- 2024.10.23: 생산성 기능 대폭 추가 (TODO, 자동 포맷, Git blame 등)
- 2024.10.23: 초기 버전 생성
- DevOps 특화 LSP 설정
- 프로덕션 안전 기능
- 4가지 테마 자동 전환

---

## 🎉 최종 정리

**총 37개 플러그인, 945줄 설정**
- 기본 편집기 기능 ✅
- Cloud Native/DevOps 도구 ✅
- Kubernetes/Helm/Terraform 통합 ✅
- REST API 테스트 ✅
- JSON/YAML/Base64 유틸리티 ✅

**VSCode를 완전히 대체 가능합니다!** 🚀
