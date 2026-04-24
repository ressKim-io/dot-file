#!/bin/bash

set -e

echo "=========================================="
echo "🚀 kubectx + kubens 설치 시작"
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

# kubectl 설치 확인
if ! command -v kubectl &> /dev/null; then
  echo "❌ kubectl이 설치되어 있지 않습니다."
  echo "   kubectx는 kubectl이 필요합니다."
  echo ""
  echo "설치 가이드:"
  echo "  https://kubernetes.io/docs/tasks/tools/"
  exit 1
fi

echo "✅ kubectl 확인 완료"
echo ""

# Mac 설치
if [ "$MACHINE" = "Mac" ]; then
  echo "📦 Homebrew로 설치 시작..."
  
  if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew가 설치되어 있지 않습니다."
    echo ""
    echo "Homebrew 설치:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
  fi
  
  echo "✅ Homebrew 확인 완료"
  echo ""
  
  # kubectx 설치
  if command -v kubectx &> /dev/null; then
    echo "⚠️  kubectx가 이미 설치되어 있습니다."
    # 구버전 kubectx는 --version을 지원하지 않아 set -e에서 abort되므로 fallback
    kubectx --version 2>/dev/null || echo "   (version 정보 없음)"
    echo ""
    read -p "다시 설치하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "✅ 설치 완료 (기존 버전 유지)"
      exit 0
    fi
  fi
  
  echo "📦 설치 중..."
  brew install kubectx
  
  echo ""
  echo "✅ 설치 완료!"
  echo ""
  echo "설치된 도구:"
  echo "  - kubectx: $(which kubectx)"
  echo "  - kubens:  $(which kubens)"
  
# Linux 설치
elif [ "$MACHINE" = "Linux" ]; then
  echo "📦 수동 설치 시작..."

  # 사용자 홈 디렉토리에 설치 (보안 향상)
  INSTALL_DIR="$HOME/.kubectx"
  BIN_DIR="/usr/local/bin"

  # 기존 설치 확인 (prerequisites로 이미 /usr/local/bin에 직접 설치된 경우 포함)
  if [ -d "$INSTALL_DIR" ] || command -v kubectx &> /dev/null; then
    if [ -d "$INSTALL_DIR" ]; then
      echo "⚠️  $INSTALL_DIR 가 이미 존재합니다."
    else
      echo "⚠️  kubectx가 이미 $(which kubectx)에 설치되어 있습니다 (prerequisites로 설치된 것으로 추정)."
    fi
    echo ""
    read -p "다시 설치하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "✅ 설치 취소"
      exit 0
    fi
    echo "🗑️  기존 설치 제거 중..."
    rm -rf "$INSTALL_DIR"
    sudo rm -f "$BIN_DIR/kubectx" "$BIN_DIR/kubens"
  fi

  # Git 확인
  if ! command -v git &> /dev/null; then
    echo "❌ git이 설치되어 있지 않습니다."
    echo ""
    read -p "git을 설치하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git
      elif command -v yum &> /dev/null; then
        sudo yum install -y git
      else
        echo "❌ 패키지 매니저를 찾을 수 없습니다."
        echo "   수동으로 git을 설치해주세요."
        exit 1
      fi
    else
      exit 1
    fi
  fi

  echo "📦 다운로드 중..."
  # 사용자 권한으로 클론 (보안 향상)
  git clone https://github.com/ahmetb/kubectx.git "$INSTALL_DIR"

  echo "🔗 심볼릭 링크 생성 중..."
  sudo ln -sf "$INSTALL_DIR/kubectx" "$BIN_DIR/kubectx"
  sudo ln -sf "$INSTALL_DIR/kubens" "$BIN_DIR/kubens"

  echo ""
  echo "✅ 설치 완료!"
  echo ""
  echo "설치 위치:"
  echo "  - 소스:    $INSTALL_DIR"
  echo "  - kubectx: $BIN_DIR/kubectx"
  echo "  - kubens:  $BIN_DIR/kubens"
  
else
  echo "❌ 지원하지 않는 OS입니다: $MACHINE"
  exit 1
fi

echo ""
echo "=========================================="
echo "🧪 설치 확인"
echo "=========================================="
echo ""

# 설치 확인
if command -v kubectx &> /dev/null && command -v kubens &> /dev/null; then
  echo "✅ kubectx 설치 확인:"
  kubectx --version 2>/dev/null || kubectx -h | head -n 1
  echo ""
  
  echo "✅ kubens 설치 확인:"
  kubens --version 2>/dev/null || kubens -h | head -n 1
  echo ""
  
  echo "=========================================="
  echo "🎉 모든 설치 완료!"
  echo "=========================================="
  echo ""
  echo "📚 사용법:"
  echo "  kubectx              # 컨텍스트 목록"
  echo "  kubectx my-cluster   # 컨텍스트 전환"
  echo "  kubens               # 네임스페이스 목록"
  echo "  kubens default       # 네임스페이스 전환"
  echo ""
  echo "💡 Tip: alias 추가 (선택)"
  echo "  echo 'alias kx=kubectx' >> ~/.zshrc"
  echo "  echo 'alias kn=kubens' >> ~/.bashrc"
  
else
  echo "❌ 설치 실패"
  echo "   PATH에 kubectx/kubens가 없습니다."
  exit 1
fi
