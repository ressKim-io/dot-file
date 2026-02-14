#!/bin/bash

set -e

echo "=========================================="
echo "🔧 런타임 설치 (Go, Node.js, Python)"
echo "=========================================="
echo ""

# 필수 도구 체크
check_prerequisites() {
  local missing=""
  for cmd in curl git; do
    if ! command -v $cmd &> /dev/null; then
      missing="$missing $cmd"
    fi
  done
  if [ -n "$missing" ]; then
    echo "❌ 필수 도구가 없습니다:$missing"
    echo ""
    echo "💡 해결 방법:"
    echo "   1. prerequisites/install.sh를 먼저 실행하세요 (권장)"
    echo "      cd prerequisites && ./install.sh"
    echo ""
    echo "   2. 또는 수동 설치:"
    echo "      Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y curl git"
    echo "      CentOS/RHEL:   sudo yum install -y curl git"
    echo "      Mac:           brew install curl git"
    exit 1
  fi
}

check_prerequisites

# Fallback 버전 (API 실패 시 사용)
FALLBACK_NVM_VERSION="v0.40.4"
FALLBACK_GO_VERSION="go1.26.0"

# OS 감지
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

# 아키텍처 감지
ARCH=$(uname -m)
case $ARCH in
  x86_64) ARCH_SUFFIX="amd64" ;;
  aarch64|arm64) ARCH_SUFFIX="arm64" ;;
  *) ARCH_SUFFIX="amd64" ;;
esac

echo "✅ 감지된 OS: $MACHINE ($ARCH)"
echo ""

# ========================================
# 1. Go 설치
# ========================================

echo "=========================================="
echo "📦 Go 설치"
echo "=========================================="
echo ""

if command -v go &> /dev/null; then
  GO_VERSION=$(go version)
  echo "✅ Go 이미 설치됨: $GO_VERSION"
else
  echo "📥 최신 Go 버전 확인 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      echo "✅ Homebrew로 Go 설치 중..."
      brew install go
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      echo "   https://brew.sh 에서 Homebrew를 먼저 설치해주세요."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # 최신 버전 자동 감지 (실패 시 fallback 사용)
    GO_VERSION=$(curl -s --connect-timeout 10 https://go.dev/VERSION?m=text | head -n1)
    if [ -z "$GO_VERSION" ] || [[ ! "$GO_VERSION" =~ ^go ]]; then
      echo "⚠️  Go 버전 확인 실패, fallback 버전 사용: $FALLBACK_GO_VERSION"
      GO_VERSION="$FALLBACK_GO_VERSION"
    fi
    echo "📥 Go $GO_VERSION 다운로드 중..."

    cd /tmp
    GO_ARCHIVE="${GO_VERSION}.linux-${ARCH_SUFFIX}.tar.gz"
    if ! curl -LO --fail "https://go.dev/dl/${GO_ARCHIVE}"; then
      echo "❌ Go 다운로드 실패"
      echo "   수동 설치: https://go.dev/dl/"
      exit 1
    fi

    # 기존 설치 제거 및 설치
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${GO_ARCHIVE}"
    rm "${GO_ARCHIVE}"

    # PATH 설정 (zshrc 또는 bashrc)
    if [ -f "$HOME/.zshrc" ]; then
      if ! grep -q "/usr/local/go/bin" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# Go" >> "$HOME/.zshrc"
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.zshrc"
        echo 'export PATH=$PATH:$HOME/go/bin' >> "$HOME/.zshrc"
      fi
    elif [ -f "$HOME/.bashrc" ]; then
      if ! grep -q "/usr/local/go/bin" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Go" >> "$HOME/.bashrc"
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
        echo 'export PATH=$PATH:$HOME/go/bin' >> "$HOME/.bashrc"
      fi
    fi

    # 현재 세션에서 PATH 설정
    export PATH=$PATH:/usr/local/go/bin
    export PATH=$PATH:$HOME/go/bin

    echo "✅ Go 설치 완료: $(go version)"
  fi
fi

echo ""

# ========================================
# 2. Node.js 설치 (nvm 사용)
# ========================================

echo "=========================================="
echo "📦 Node.js 설치 (nvm)"
echo "=========================================="
echo ""

if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  echo "✅ Node.js 이미 설치됨: $NODE_VERSION"
else
  echo "📥 nvm 설치 중..."

  # nvm 설치 확인
  if [ ! -d "$HOME/.nvm" ]; then
    # 최신 nvm 버전 자동 감지 (실패 시 fallback 사용)
    NVM_VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$NVM_VERSION" ] || [[ ! "$NVM_VERSION" =~ ^v ]]; then
      echo "⚠️  NVM 버전 확인 실패, fallback 버전 사용: $FALLBACK_NVM_VERSION"
      NVM_VERSION="$FALLBACK_NVM_VERSION"
    fi
    echo "📥 nvm $NVM_VERSION 설치 중..."

    if ! curl -o- --fail "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash; then
      echo "❌ nvm 설치 실패"
      echo "   수동 설치: https://github.com/nvm-sh/nvm#installing-and-updating"
      exit 1
    fi

    echo "✅ nvm 설치 완료"
  else
    echo "✅ nvm 이미 설치됨"
  fi

  # nvm 로드 (여러 번 시도)
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # nvm 명령어 확인
  if ! command -v nvm &> /dev/null; then
    echo "   nvm 로딩 재시도 중..."
    sleep 2
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi

  if ! command -v nvm &> /dev/null; then
    echo "❌ nvm 로드 실패. 터미널을 재시작한 후 다시 시도해주세요."
    exit 1
  fi

  # Node.js LTS 설치
  echo "📥 Node.js LTS 설치 중..."
  nvm install --lts
  nvm use --lts

  NODE_VERSION=$(node --version)
  NPM_VERSION=$(npm --version)
  echo "✅ Node.js 설치 완료: $NODE_VERSION"
  echo "✅ npm 버전: $NPM_VERSION"
fi

echo ""

# ========================================
# 3. Python3 & pip 설치
# ========================================

echo "=========================================="
echo "📦 Python3 & pip 설치"
echo "=========================================="
echo ""

if command -v python3 &> /dev/null; then
  PYTHON_VERSION=$(python3 --version)
  echo "✅ Python3 이미 설치됨: $PYTHON_VERSION"
else
  echo "📥 Python3 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install python3
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y python3 python3-pip python3-venv
    elif command -v yum &> /dev/null; then
      sudo yum install -y python3 python3-pip
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm python python-pip
    fi
  fi

  echo "✅ Python3 설치 완료: $(python3 --version)"
fi

# pip 확인
if command -v pip3 &> /dev/null; then
  PIP_VERSION=$(pip3 --version)
  echo "✅ pip3 이미 설치됨: $PIP_VERSION"
else
  echo "📥 pip3 설치 중..."

  if [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get install -y python3-pip
    elif command -v yum &> /dev/null; then
      sudo yum install -y python3-pip
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y python3-pip
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm python-pip
    else
      echo "⚠️  pip3 자동 설치 실패. 수동으로 설치해주세요."
    fi
  fi

  if command -v pip3 &> /dev/null; then
    echo "✅ pip3 설치 완료"
  fi
fi

echo ""
echo "=========================================="
echo "✅ 런타임 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 버전:"
command -v go &> /dev/null && echo "   - Go: $(go version | awk '{print $3}')"
command -v node &> /dev/null && echo "   - Node.js: $(node --version)"
command -v npm &> /dev/null && echo "   - npm: $(npm --version)"
command -v python3 &> /dev/null && echo "   - Python3: $(python3 --version | awk '{print $2}')"
command -v pip3 &> /dev/null && echo "   - pip3: $(pip3 --version | awk '{print $2}')"
echo ""
echo "💡 주의:"
echo "   - 새 터미널을 열거나 'source ~/.zshrc' (또는 ~/.bashrc)를 실행하세요."
echo "   - Go: /usr/local/go/bin 과 ~/go/bin 이 PATH에 추가되었습니다."
echo "   - Node.js: nvm을 사용하여 설치되었습니다."
echo ""
