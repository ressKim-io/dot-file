# 🛠️ My Dotfiles

개인 개발 환경 설정 모음입니다.

---

## 📁 디렉토리 구조

```
dotfiles/
├── README.md                    # 이 파일
├── zsh/                         # ✅ Zsh + Oh-My-Zsh 설정
│   ├── README.md
│   ├── install.sh              # 자동 설치 (Mac/Ubuntu)
│   └── .zshrc                  # K8s 통합 설정
├── kubectl/                     # ✅ kubectl 생산성 설정
│   ├── README.md
│   ├── install.sh              # 자동 설치 (zsh/bash)
│   └── aliases                 # alias 목록
├── kubectx/                     # ✅ kubectx + kubens
│   ├── README.md
│   └── install.sh              # 자동 설치 (Mac/Linux)
├── aws/                         # ✅ AWS CLI 생산성 설정
│   ├── README.md
│   ├── install.sh              # 자동 설치 (zsh/bash)
│   └── aws-aliases.sh          # 단축어/함수
├── nvim/                        # ✅ Neovim DevOps 설정
│   ├── README.md
│   ├── install.sh              # 자동 설치 + LSP
│   ├── init.lua                # 설정 파일
│   └── lazy-lock.json          # 플러그인 버전 고정
├── vim/                         # ✅ Vim Go 개발 설정
│   ├── README.md
│   ├── install.sh              # 자동 설치 + 플러그인
│   └── .vimrc                  # 설정 파일
├── git/                         # (예정) Git 설정
├── tmux/                        # (예정) Tmux 설정
└── docker/                      # (예정) Docker 관련 설정
```

---

## 🚀 빠른 시작

### 권장 설치 순서

#### 1. Zsh 설정 (최우선!)
```bash
cd zsh
./install.sh
```

쉘 환경을 먼저 설정해야 다른 도구들이 제대로 작동합니다.
자세한 내용은 [zsh/README.md](zsh/README.md) 참고

#### 2. kubectl 설정
```bash
cd kubectl
./install.sh
```

Kubernetes CLI 생산성 향상
자세한 내용은 [kubectl/README.md](kubectl/README.md) 참고

#### 3. kubectx + kubens
```bash
cd kubectx
./install.sh
```

컨텍스트/네임스페이스 빠른 전환
자세한 내용은 [kubectx/README.md](kubectx/README.md) 참고

#### 4. AWS CLI 설정 (선택사항)
```bash
cd aws
./install.sh
```

AWS CLI를 사용하는 경우만 설치
자세한 내용은 [aws/README.md](aws/README.md) 참고

### 한 번에 설치
```bash
# 순서대로 설치 (AWS는 선택)
cd ~/dotfiles
cd zsh && ./install.sh && cd ..
cd kubectl && ./install.sh && cd ..
cd kubectx && ./install.sh && cd ..
cd aws && ./install.sh && cd ..  # 선택사항
```

---

## ✅ 완료된 설정

### zsh
- ✅ Zsh + Oh-My-Zsh 자동 설치
- ✅ kubectl/kubectx 통합
- ✅ Mac/WSL 자동 분기
- ✅ 커스텀 프롬프트 (Git 브랜치 표시)
- ✅ zsh-syntax-highlighting 지원

### kubectl
- ✅ kubectl 자동완성 (Tab)
- ✅ `k` alias 및 단축 명령어
- ✅ zsh/bash 자동 감지

### kubectx + kubens
- ✅ 컨텍스트 빠른 전환
- ✅ 네임스페이스 빠른 전환
- ✅ Mac/Linux 자동 설치

### aws (선택사항)
- ✅ AWS CLI 단축어 20+ 개
- ✅ EC2 관리 (ls, ssh, rm, find)
- ✅ 비용 최적화 (eip-unused, ebs-orphan, cost)
- ✅ 안전한 삭제 (확인 메시지)

### nvim
- ✅ DevOps 특화 Neovim 설정
- ✅ LSP (Go, Python, Terraform, YAML, Bash, Docker)
- ✅ 프로덕션 안전 기능 (자동 테마 변경)
- ✅ Telescope, NvimTree, Git 통합
- ✅ 4가지 테마 자동 전환

### vim
- ✅ Go 개발 환경
- ✅ CoC, vim-go 플러그인
- ✅ fzf, NERDTree
- ✅ 레거시 서버 대응

---

## 📋 예정된 설정

### git (예정)
- Git 글로벌 설정
- Git alias (gst, gco, gp 등)

### tmux (예정)
- Tmux 설정
- 단축키 커스터마이징

### docker (우선순위 낮음)
- Docker Compose alias
- 자주 쓰는 Docker 명령어 단축

---

## 🔧 사용 환경

- **OS**: macOS, Linux (Ubuntu/WSL)
- **Shell**: zsh, bash
- **최종 업데이트**: 2024.10

---

## 📝 업데이트 내역

- 2024.10.23: nvim, vim 모듈 추가 (DevOps 특화, Go 개발)
- 2024.10.23: aws 모듈 추가 (zsh에서 분리, 선택적 설치)
- 2024.10.23: zsh 설정 추가 (K8s 통합, Mac/WSL 분기)
- 2024.10.15: kubectx + kubens 설치 스크립트 추가
- 2024.10.15: kubectl 설정 추가
- 2024.10.15: 레포지토리 초기 생성

---

## 📚 참고

각 디렉토리의 README.md에서 상세한 설명을 확인할 수 있습니다.
