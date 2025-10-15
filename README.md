# 🛠️ My Dotfiles

개인 개발 환경 설정 모음입니다.

---

## 📁 디렉토리 구조

```
dotfiles/
├── README.md                    # 이 파일
├── kubectl/                     # ✅ kubectl 생산성 설정
│   ├── README.md
│   ├── install.sh              # 자동 설치 (zsh/bash)
│   └── aliases                 # alias 목록
├── kubectx/                     # ✅ kubectx + kubens
│   ├── README.md
│   └── install.sh              # 자동 설치 (Mac/Linux)
├── docker/                      # (예정) Docker 관련 설정
├── git/                         # (예정) Git 설정
│   └── .gitconfig
├── vim/                         # (예정) Vim 설정
├── tmux/                        # (예정) Tmux 설정
├── aws/                         # (예정) AWS CLI 설정
└── scripts/                     # (예정) 유틸리티 스크립트
```

---

## 🚀 빠른 시작

### kubectl 설정 (현재 사용 가능)
```bash
cd kubectl
./install.sh
```

자세한 내용은 [kubectl/README.md](kubectl/README.md) 참고

### kubectx + kubens (현재 사용 가능)
```bash
cd kubectx
./install.sh
```

자세한 내용은 [kubectx/README.md](kubectx/README.md) 참고

---

## ✅ 완료된 설정

### kubectl
- ✅ kubectl 자동완성 (Tab)
- ✅ `k` alias 및 단축 명령어
- ✅ zsh/bash 자동 감지

### kubectx + kubens
- ✅ 컨텍스트 빠른 전환
- ✅ 네임스페이스 빠른 전환
- ✅ Mac/Linux 자동 설치

---

## 📋 예정된 설정

### docker (예정)
- Docker Compose alias
- 자주 쓰는 Docker 명령어 단축

### git (예정)
- Git 글로벌 설정
- Git alias (gst, gco, gp 등)

### vim (예정)
- 기본 vim 설정
- 플러그인 관리

### tmux (예정)
- Tmux 설정
- 단축키 커스터마이징

### aws (예정)
- AWS CLI 프로파일 관리
- 자주 쓰는 명령어 alias

### scripts (예정)
- 개발 환경 초기화 스크립트
- 유틸리티 함수들

---

## 🔧 사용 환경

- **OS**: macOS, Linux (Ubuntu/WSL)
- **Shell**: zsh, bash
- **최종 업데이트**: 2024.10

---

## 📝 업데이트 내역

- 2024.10.15: kubectx + kubens 설치 스크립트 추가
- 2024.10.15: kubectl 설정 추가
- 2024.10.15: 레포지토리 초기 생성

---

## 📚 참고

각 디렉토리의 README.md에서 상세한 설명을 확인할 수 있습니다.
