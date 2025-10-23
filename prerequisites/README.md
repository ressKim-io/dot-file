# Prerequisites - 필수 프로그램 설치

다른 dotfiles 모듈을 사용하기 전에 **먼저 설치해야 하는 필수 프로그램들**입니다.

---

## 📦 설치되는 도구들

### 🔧 런타임 & 언어
- **Go** (최신 stable 버전)
  - gopls LSP 서버용
  - yq, kubectl 등 Go 도구 빌드용
- **Node.js + npm** (LTS 버전, nvm 사용)
  - 대부분의 LSP 서버용 (pyright, yaml-language-server 등)
  - 프론트엔드 개발
- **Python3 + pip**
  - pyright LSP
  - 각종 CLI 도구

### 🐳 컨테이너
- **Docker**
  - Mac: Docker Desktop
  - Linux: Docker Engine + Docker Compose

### ☸️ Kubernetes 도구
- **kubectl** (최신 stable 버전)
  - Kubernetes CLI
- **helm** (최신 버전)
  - Kubernetes 패키지 관리자
- **kubectx + kubens** (선택사항)
  - 컨텍스트/네임스페이스 빠른 전환

### 🔧 DevOps 도구
- **terraform** (HashiCorp 공식)
  - Infrastructure as Code
- **jq** - JSON 파싱
- **yq** - YAML 파싱 (Go 버전)
- **yamllint** - YAML 린터
- **hadolint** - Dockerfile 린터
- **tflint** (선택사항) - Terraform 린터
- **trivy** (선택사항) - 보안 스캐너

---

## 🚀 설치 방법

### 전체 자동 설치 (추천)

```bash
cd ~/dotfiles/prerequisites
./install.sh
```

모든 도구를 대화형으로 설치합니다. 필요 없는 도구는 건너뛸 수 있습니다.

### 개별 설치

필요한 카테고리만 선택적으로 설치:

```bash
# 1. 런타임만 (필수!)
./install-runtimes.sh

# 2. Docker만
./install-docker.sh

# 3. Kubernetes 도구만
./install-k8s-tools.sh

# 4. DevOps 도구만
./install-devops-tools.sh
```

---

## ✅ 지원 플랫폼

- **macOS** (Homebrew 필요)
- **Linux**
  - Ubuntu/Debian (apt-get)
  - RHEL/CentOS/Fedora (yum)
  - Arch Linux (pacman)

---

## 📋 설치 전 준비사항

### macOS

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Linux (Ubuntu/Debian)

```bash
# 기본 패키지 업데이트
sudo apt-get update
sudo apt-get install -y curl wget git build-essential
```

---

## 🎯 설치 전략

### 최신 버전 자동 감지

각 스크립트는 공식 소스에서 **최신 stable 버전을 자동으로 감지**합니다:

- **Go**: `https://go.dev/VERSION?m=text`
- **Node.js**: nvm을 통해 LTS 자동 설치
- **kubectl**: `https://dl.k8s.io/release/stable.txt`
- **Helm**: 공식 설치 스크립트 (항상 최신)
- **yq, hadolint**: GitHub Releases API 사용

### 공식 설치 방법 사용

- **asdf 같은 버전 관리자 없이** 각 도구의 공식 설치 방법 사용
- 단순하고 안정적
- 추가 레이어 없음

---

## 💡 설치 후 확인

### 런타임 확인

```bash
go version
node --version
npm --version
python3 --version
pip3 --version
```

### Docker 확인

```bash
docker --version
docker run hello-world
```

### Kubernetes 도구 확인

```bash
kubectl version --client
helm version
kubectx --version  # 설치한 경우
```

### DevOps 도구 확인

```bash
terraform --version
echo '{"name":"test"}' | jq '.name'
echo 'name: test' | yq '.name'
yamllint --version
hadolint --version
```

---

## 🔧 트러블슈팅

### PATH 인식 안됨

```bash
# zsh 사용 시
source ~/.zshrc

# bash 사용 시
source ~/.bashrc

# 또는 새 터미널 열기
```

### Go PATH 설정

```bash
# .zshrc 또는 .bashrc에 추가됨
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
```

### Node.js nvm 로드 안됨

```bash
# .zshrc 또는 .bashrc에 다음이 있는지 확인
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### Docker 실행 안됨 (Linux)

```bash
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 로그아웃 후 다시 로그인 또는
newgrp docker

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker
```

### Terraform GPG 오류 (Ubuntu)

```bash
# GPG 키 재설치
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

---

## 📚 각 도구의 용도

### 왜 이 도구들이 필요한가?

**런타임 (Go, Node.js, Python)**
- nvim의 LSP 서버들이 이 런타임들로 작성되어 있음
- gopls (Go), pyright (Node.js), terraform-ls (Go) 등
- 없으면 nvim에서 자동완성, 에러 검증 등이 작동하지 않음

**Docker**
- 컨테이너 빌드 및 실행
- nvim에서 Docker 명령어 실행 (docker build, docker compose 등)

**kubectl, helm**
- Kubernetes 클러스터 관리
- nvim에서 kubectl apply, helm template 등 실행

**terraform, jq, yq**
- IaC 관리 및 데이터 파싱
- nvim에서 terraform fmt/validate/plan 실행
- JSON/YAML 변환 기능

**yamllint, hadolint**
- YAML, Dockerfile 린팅
- nvim에서 실시간 에러 검증

---

## 🎯 다음 단계

prerequisites 설치 후, dotfiles 모듈들을 **이 순서대로** 설치하세요:

```bash
# 1. Zsh (최우선!)
cd ~/dotfiles/zsh && ./install.sh

# 2. kubectl 설정
cd ~/dotfiles/kubectl && ./install.sh

# 3. kubectx + kubens
cd ~/dotfiles/kubectx && ./install.sh

# 4. Neovim (DevOps 특화)
cd ~/dotfiles/nvim && ./install.sh

# 5. 선택사항
cd ~/dotfiles/aws && ./install.sh   # AWS CLI 사용 시
cd ~/dotfiles/vim && ./install.sh   # Vim 사용 시
```

---

## 📝 업데이트

- **2024.10.23**: 초기 버전 생성
  - 런타임 (Go, Node.js, Python) 자동 설치
  - Docker 자동 설치 (Mac/Linux)
  - Kubernetes 도구 (kubectl, helm)
  - DevOps 도구 (terraform, jq, yq, yamllint, hadolint)
  - 최신 버전 자동 감지
  - 공식 설치 방법 사용

---

## 💡 왜 asdf를 사용하지 않나요?

asdf는 훌륭한 버전 관리자이지만, 이 dotfiles에서는 **공식 설치 방법**을 선택했습니다:

**장점:**
- ✅ 단순함 - 추가 레이어 없음
- ✅ 안정성 - 각 도구의 공식 방법
- ✅ 최신 버전 - GitHub API로 자동 감지
- ✅ 의존성 없음 - asdf 자체 문제 걱정 안함

**단점:**
- ❌ 버전 고정 어려움 (프로젝트별)
- ❌ 통합 관리 불가

하지만 대부분의 경우 **최신 stable 버전**이면 충분하고, 프로젝트별 버전 관리가 필요하면 Docker를 사용하세요.

---

## 🤝 기여

버그나 개선사항이 있으면 이슈를 올려주세요!
