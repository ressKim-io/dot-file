#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Zsh + Oh-My-Zsh 설치 시작"
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

# ========================================
# 1. Zsh 설치
# ========================================

if command -v zsh &> /dev/null; then
  ZSH_VERSION=$(zsh --version | cut -d' ' -f2)
  echo "✅ Zsh 이미 설치됨: $ZSH_VERSION"
else
  echo "📦 Zsh 설치 중..."

  if [ "$MACHINE" = "Linux" ]; then
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y zsh
    # RHEL/CentOS/Fedora
    elif command -v yum &> /dev/null; then
      sudo yum install -y zsh
    # Arch Linux
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm zsh
    else
      echo "❌ 지원하지 않는 패키지 매니저입니다."
      echo "   수동으로 zsh를 설치해주세요."
      exit 1
    fi
  elif [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install zsh
    else
      echo "⚠️  Mac에서는 zsh가 기본 설치되어 있습니다."
    fi
  fi

  echo "✅ Zsh 설치 완료"
fi

echo ""

# ========================================
# 2. Oh-My-Zsh 설치
# ========================================

if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "✅ Oh-My-Zsh 이미 설치됨"
  echo ""
  read -p "재설치하시겠습니까? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  기존 Oh-My-Zsh 제거 중..."
    rm -rf "$HOME/.oh-my-zsh"
  else
    echo "⏭️  Oh-My-Zsh 설치 건너뛰기"
    SKIP_OMZ=true
  fi
fi

if [ "$SKIP_OMZ" != "true" ]; then
  echo "📦 Oh-My-Zsh 설치 중..."
  echo ""

  # Oh-My-Zsh 설치 (unattended mode)
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo ""
  echo "✅ Oh-My-Zsh 설치 완료"
fi

echo ""

# ========================================
# 3. .zshrc 백업 및 적용
# ========================================

BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$BACKUP_FILE"
  echo "💾 기존 .zshrc 백업: $BACKUP_FILE"
fi

echo "📝 새로운 .zshrc 복사 중..."
cp "$(dirname "$0")/.zshrc" "$HOME/.zshrc"

echo "✅ .zshrc 적용 완료"
echo ""

# ========================================
# 4. 추가 도구 설치 (선택)
# ========================================

echo "=========================================="
echo "📦 추가 도구 설치 (선택사항)"
echo "=========================================="
echo ""

# zsh-syntax-highlighting (Mac)
if [ "$MACHINE" = "Mac" ]; then
  if ! brew list zsh-syntax-highlighting &> /dev/null; then
    read -p "zsh-syntax-highlighting을 설치하시겠습니까? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      brew install zsh-syntax-highlighting
      echo "✅ zsh-syntax-highlighting 설치 완료"
    fi
  else
    echo "✅ zsh-syntax-highlighting 이미 설치됨"
  fi
fi

# zsh-syntax-highlighting (Linux)
if [ "$MACHINE" = "Linux" ]; then
  ZSH_SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

  if [ ! -d "$ZSH_SYNTAX_DIR" ]; then
    read -p "zsh-syntax-highlighting을 설치하시겠습니까? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_DIR"
      echo "✅ zsh-syntax-highlighting 설치 완료"
      echo ""
      echo "⚠️  .zshrc에 다음 줄을 추가해주세요:"
      echo "   source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
  else
    echo "✅ zsh-syntax-highlighting 이미 설치됨"
  fi
fi

echo ""

# ========================================
# 5. 기본 쉘 변경
# ========================================

CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(which zsh)

echo "=========================================="
echo "🔧 기본 쉘 설정"
echo "=========================================="
echo ""
echo "현재 기본 쉘: $CURRENT_SHELL"
echo "Zsh 경로: $ZSH_PATH"
echo ""

if [ "$CURRENT_SHELL" != "zsh" ]; then
  read -p "기본 쉘을 zsh로 변경하시겠습니까? (Y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # /etc/shells에 zsh 경로 추가 (없는 경우)
    if ! grep -q "$ZSH_PATH" /etc/shells; then
      echo "📝 /etc/shells에 zsh 경로 추가 중..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    # 기본 쉘 변경
    chsh -s "$ZSH_PATH"
    echo "✅ 기본 쉘이 zsh로 변경되었습니다."
    echo "⚠️  변경사항을 적용하려면 로그아웃 후 다시 로그인해주세요."
  fi
else
  echo "✅ 이미 zsh가 기본 쉘입니다."
fi

echo ""
echo "=========================================="
echo "✅ 설치 완료!"
echo "=========================================="
echo ""
echo "🔄 다음 명령어로 즉시 적용:"
echo "   exec zsh"
echo ""
echo "📚 설치된 내용:"
echo "   - Zsh"
echo "   - Oh-My-Zsh"
echo "   - .zshrc (AWS CLI, kubectl, kubectx 설정 포함)"
echo ""
echo "🧪 테스트:"
echo "   zsh --version"
echo "   echo \$ZSH_VERSION"
echo ""
echo "💡 Tip: 기본 쉘을 변경하지 않았다면 'exec zsh'로 전환 가능"
echo ""

# 즉시 적용 여부 확인
read -p "지금 바로 zsh로 전환하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  echo "✅ Zsh 실행 중..."
  exec zsh
fi
