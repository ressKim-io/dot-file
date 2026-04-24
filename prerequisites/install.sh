#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Prerequisites 전체 설치"
echo "=========================================="
echo ""
echo "다음 도구들을 설치합니다:"
echo "   0. 기본 도구: curl, wget, git, gnupg (최초 설치 시)"
echo "   1. 런타임: Go, Node.js, Python"
echo "   2. Docker"
echo "   3. Kubernetes 도구: kubectl, helm, k9s, stern"
echo "   4. DevOps 도구: terraform, opentofu, jq, yq, yamllint, hadolint"
echo "   5. 모던 CLI: fzf, bat, eza, zoxide, git-delta, direnv, pipx, Nerd Font"
echo ""
echo "⏱️  예상 시간: 10-20분"
echo ""

read -p "계속하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "설치를 취소했습니다."
  exit 0
fi

echo ""

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ========================================
# 0. Bootstrap: 기본 도구 설치 (최초 설치 시 필수)
# ========================================

echo ""
echo "=========================================="
echo "STEP 0/5: 기본 도구 확인 및 설치"
echo "=========================================="
echo ""

# OS 감지
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "✅ 감지된 OS: $MACHINE"
echo ""

# sudo 권한 확인 (Linux만)
if [ "$MACHINE" = "Linux" ]; then
  if ! command -v sudo &> /dev/null; then
    echo "❌ sudo가 설치되어 있지 않습니다."
    echo "   root로 로그인하여 다음을 실행하세요:"
    echo "   apt-get update && apt-get install -y sudo"
    echo "   usermod -aG sudo \$USER"
    exit 1
  fi

  # sudo 테스트 (비밀번호 필요 시 요청)
  if ! sudo -n true 2>/dev/null; then
    echo "📝 sudo 권한이 필요합니다. 비밀번호를 입력해주세요."
    sudo -v || { echo "❌ sudo 권한을 얻을 수 없습니다."; exit 1; }
  fi
fi

# 기본 도구 설치 함수
install_basic_tools() {
  echo "📦 기본 도구 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    # Mac: Homebrew 확인
    if ! command -v brew &> /dev/null; then
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      echo ""
      echo "Homebrew 설치 (터미널에서 실행):"
      echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      echo ""
      exit 1
    fi

    # curl, wget, git 설치
    for tool in curl wget git; do
      if ! command -v $tool &> /dev/null; then
        echo "   📥 $tool 설치 중..."
        brew install $tool
      fi
    done

  elif [ "$MACHINE" = "Linux" ]; then
    # Linux: 패키지 매니저 감지 및 설치
    if command -v apt-get &> /dev/null; then
      echo "   📥 apt-get으로 기본 도구 설치 중..."
      sudo apt-get update -qq
      sudo apt-get install -y \
        curl \
        wget \
        git \
        gnupg \
        lsb-release \
        ca-certificates \
        software-properties-common \
        apt-transport-https \
        2>/dev/null || sudo apt-get install -y curl wget git gnupg lsb-release ca-certificates

    elif command -v yum &> /dev/null; then
      echo "   📥 yum으로 기본 도구 설치 중..."
      sudo yum install -y \
        curl \
        wget \
        git \
        gnupg2 \
        redhat-lsb-core \
        ca-certificates

    elif command -v dnf &> /dev/null; then
      echo "   📥 dnf로 기본 도구 설치 중..."
      sudo dnf install -y \
        curl \
        wget \
        git \
        gnupg2 \
        redhat-lsb-core \
        ca-certificates

    elif command -v pacman &> /dev/null; then
      echo "   📥 pacman으로 기본 도구 설치 중..."
      sudo pacman -Sy --noconfirm --needed \
        curl \
        wget \
        git \
        gnupg \
        lsb-release \
        ca-certificates

    elif command -v zypper &> /dev/null; then
      echo "   📥 zypper로 기본 도구 설치 중..."
      sudo zypper install -y \
        curl \
        wget \
        git \
        gpg2 \
        lsb-release \
        ca-certificates

    else
      echo "❌ 지원하지 않는 패키지 매니저입니다."
      echo "   수동으로 curl, wget, git, gnupg, lsb-release를 설치해주세요."
      exit 1
    fi
  fi
}

# 필수 도구 체크 함수
check_basic_tools() {
  local missing=""

  for tool in curl wget git; do
    if ! command -v $tool &> /dev/null; then
      missing="$missing $tool"
    fi
  done

  # Linux 추가 체크
  if [ "$MACHINE" = "Linux" ]; then
    if ! command -v gpg &> /dev/null; then
      missing="$missing gnupg"
    fi
    # lsb_release는 선택사항 (없으면 대체 방법 사용)
  fi

  if [ -n "$missing" ]; then
    echo "   ⚠️  누락된 도구:$missing"
    return 1
  fi
  return 0
}

# 기본 도구 체크 및 설치
if check_basic_tools; then
  echo "✅ 기본 도구 확인 완료 (curl, wget, git, gnupg)"
else
  echo "⚠️  일부 기본 도구가 없습니다. 설치를 시작합니다..."
  install_basic_tools

  # 재확인
  if check_basic_tools; then
    echo "✅ 기본 도구 설치 완료"
  else
    echo "❌ 기본 도구 설치 실패. 수동으로 설치해주세요:"
    echo "   Ubuntu/Debian: sudo apt-get install curl wget git gnupg lsb-release"
    echo "   CentOS/RHEL:   sudo yum install curl wget git gnupg2"
    echo "   Fedora:        sudo dnf install curl wget git gnupg2"
    exit 1
  fi
fi

echo ""

# ========================================
# 1. 런타임 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 1/5: 런타임 설치"
echo "=========================================="
echo ""

if [ -f "$SCRIPT_DIR/install-runtimes.sh" ]; then
  bash "$SCRIPT_DIR/install-runtimes.sh"
else
  echo "❌ install-runtimes.sh를 찾을 수 없습니다."
  exit 1
fi

# ========================================
# 2. Docker 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 2/5: Docker 설치"
echo "=========================================="
echo ""

read -p "Docker를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-docker.sh" ]; then
    bash "$SCRIPT_DIR/install-docker.sh"
  else
    echo "❌ install-docker.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  Docker 설치를 건너뜁니다."
fi

# ========================================
# 3. Kubernetes 도구 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 3/5: Kubernetes 도구 설치"
echo "=========================================="
echo ""

read -p "Kubernetes 도구 (kubectl, helm)를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-k8s-tools.sh" ]; then
    bash "$SCRIPT_DIR/install-k8s-tools.sh"
  else
    echo "❌ install-k8s-tools.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  Kubernetes 도구 설치를 건너뜁니다."
fi

# ========================================
# 4. DevOps 도구 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 4/5: DevOps 도구 설치"
echo "=========================================="
echo ""

read -p "DevOps 도구 (terraform, jq, yq 등)를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-devops-tools.sh" ]; then
    bash "$SCRIPT_DIR/install-devops-tools.sh"
  else
    echo "❌ install-devops-tools.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  DevOps 도구 설치를 건너뜁니다."
fi

# ========================================
# 5. 모던 CLI 도구 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 5/5: 모던 CLI 도구 설치"
echo "=========================================="
echo ""

read -p "모던 CLI (fzf, bat, eza, zoxide, delta, direnv, pipx, Nerd Font)를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-modern-cli.sh" ]; then
    bash "$SCRIPT_DIR/install-modern-cli.sh"
  else
    echo "❌ install-modern-cli.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  모던 CLI 도구 설치를 건너뜁니다."
fi

# ========================================
# 설치 완료
# ========================================

echo ""
echo "=========================================="
echo "✅ Prerequisites 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 도구 확인:"
echo ""

# 런타임
echo "🔧 런타임:"
command -v go &> /dev/null && echo "   ✅ Go: $(go version | awk '{print $3}')" || echo "   ❌ Go: 설치 안됨"
command -v node &> /dev/null && echo "   ✅ Node.js: $(node --version)" || echo "   ❌ Node.js: 설치 안됨"
command -v npm &> /dev/null && echo "   ✅ npm: $(npm --version)" || echo "   ❌ npm: 설치 안됨"
command -v python3 &> /dev/null && echo "   ✅ Python3: $(python3 --version | awk '{print $2}')" || echo "   ❌ Python3: 설치 안됨"

echo ""

# 컨테이너
echo "🐳 컨테이너:"
command -v docker &> /dev/null && echo "   ✅ Docker: $(docker --version | awk '{print $3}' | sed 's/,//')" || echo "   ❌ Docker: 설치 안됨"

echo ""

# Kubernetes
echo "☸️  Kubernetes:"
command -v kubectl &> /dev/null && echo "   ✅ kubectl: $(kubectl version --client -o json 2>/dev/null | grep gitVersion | awk -F'\"' '{print $4}' || echo 'installed')" || echo "   ❌ kubectl: 설치 안됨"
command -v helm &> /dev/null && echo "   ✅ helm: $(helm version --short 2>/dev/null | awk '{print $1}')" || echo "   ❌ helm: 설치 안됨"
command -v k9s &> /dev/null && echo "   ✅ k9s: installed"
command -v stern &> /dev/null && echo "   ✅ stern: installed"

echo ""

# DevOps 도구
echo "🔧 DevOps:"
command -v terraform &> /dev/null && echo "   ✅ terraform: $(terraform --version | head -n 1 | awk '{print $2}')" || echo "   ❌ terraform: 설치 안됨"
command -v tofu &> /dev/null && echo "   ✅ opentofu: $(tofu --version | head -n 1 | awk '{print $2}')"
command -v jq &> /dev/null && echo "   ✅ jq: $(jq --version)" || echo "   ❌ jq: 설치 안됨"
command -v yq &> /dev/null && echo "   ✅ yq: $(yq --version 2>&1 | head -n 1 | awk '{print $3}')" || echo "   ❌ yq: 설치 안됨"
command -v yamllint &> /dev/null && echo "   ✅ yamllint: $(yamllint --version | awk '{print $2}')" || echo "   ❌ yamllint: 설치 안됨"
command -v hadolint &> /dev/null && echo "   ✅ hadolint: installed" || echo "   ❌ hadolint: 설치 안됨"

echo ""

# 모던 CLI
echo "🎨 모던 CLI:"
command -v fzf    &> /dev/null && echo "   ✅ fzf"
(command -v bat &> /dev/null || command -v batcat &> /dev/null) && echo "   ✅ bat"
command -v eza    &> /dev/null && echo "   ✅ eza"
command -v zoxide &> /dev/null && echo "   ✅ zoxide"
command -v delta  &> /dev/null && echo "   ✅ git-delta"
command -v direnv &> /dev/null && echo "   ✅ direnv"
command -v pipx   &> /dev/null && echo "   ✅ pipx"

echo ""
echo "=========================================="
echo "🎯 다음 단계"
echo "=========================================="
echo ""
echo "1. 새 터미널을 열거나 다음 명령어 실행:"
echo "   source ~/.zshrc  (또는 ~/.bashrc)"
echo ""
echo "2. dotfiles 모듈 설치 (권장 순서):"
echo "   cd ~/dotfiles/zsh && ./install.sh"
echo "   cd ~/dotfiles/kubectl && ./install.sh"
echo "   cd ~/dotfiles/kubectx && ./install.sh"
echo "   cd ~/dotfiles/nvim && ./install.sh"
echo ""
echo "3. 선택적 설치:"
echo "   cd ~/dotfiles/aws && ./install.sh     # AWS CLI 사용 시"
echo "   cd ~/dotfiles/vim && ./install.sh     # Vim 사용 시"
echo ""
echo "📚 자세한 내용:"
echo "   ~/dotfiles/README.md"
echo ""
