#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Vim 설정 시작"
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
# 1. Vim 설치 확인
# ========================================

if command -v vim &> /dev/null; then
  VIM_VERSION=$(vim --version | head -n 1)
  echo "✅ Vim 이미 설치됨: $VIM_VERSION"
else
  echo "📦 Vim 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    # Mac에는 기본 설치되어 있음
    echo "✅ Vim이 기본 설치되어 있습니다."
  elif [ "$MACHINE" = "Linux" ]; then
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y vim
    # RHEL/CentOS/Fedora
    elif command -v yum &> /dev/null; then
      sudo yum install -y vim
    # Arch Linux
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm vim
    fi
  fi

  echo "✅ Vim 설치 완료"
fi

echo ""

# ========================================
# 2. vim-plug 설치
# ========================================

VIMPLUG_FILE="$HOME/.vim/autoload/plug.vim"

if [ -f "$VIMPLUG_FILE" ]; then
  echo "✅ vim-plug 이미 설치됨"
else
  echo "📦 vim-plug 설치 중..."
  curl -fLo "$VIMPLUG_FILE" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  echo "✅ vim-plug 설치 완료"
fi

echo ""

# ========================================
# 3. .vimrc 복사
# ========================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VIMRC_FILE="$HOME/.vimrc"

# 기존 설정 백업
if [ -f "$VIMRC_FILE" ]; then
  BACKUP_FILE="${VIMRC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "💾 기존 .vimrc 백업: $BACKUP_FILE"
  mv "$VIMRC_FILE" "$BACKUP_FILE"
fi

# 설정 파일 복사
echo "📝 .vimrc 복사 중..."
cp "$SCRIPT_DIR/.vimrc" "$VIMRC_FILE"

echo "✅ .vimrc 복사 완료"
echo ""

# ========================================
# 4. 플러그인 설치
# ========================================

echo "=========================================="
echo "🔌 플러그인 설치"
echo "=========================================="
echo ""

read -p "Vim 플러그인을 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  echo "✅ 플러그인 설치 중..."
  echo "   (시간이 좀 걸릴 수 있습니다...)"
  vim +PlugInstall +qall
  echo "✅ 플러그인 설치 완료"
fi

echo ""

# ========================================
# 5. Go 개발 환경 (선택)
# ========================================

echo "=========================================="
echo "📦 Go 개발 환경 설정 (선택사항)"
echo "=========================================="
echo ""

read -p "vim-go 바이너리를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if command -v go &> /dev/null; then
    echo "✅ Go가 설치되어 있습니다. vim-go 바이너리 설치 중..."
    vim +GoUpdateBinaries +qall
    echo "✅ vim-go 설치 완료"
  else
    echo "⚠️  Go가 설치되지 않았습니다."
    echo "   vim-go는 Go 설치 후 :GoUpdateBinaries로 설치하세요."
  fi
fi

echo ""
echo "=========================================="
echo "✅ 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 내용:"
echo "   - Vim"
echo "   - vim-plug (플러그인 관리자)"
echo "   - .vimrc (Go 개발 특화)"
echo "   - 플러그인 (CoC, vim-go, fzf, NERDTree 등)"
echo ""
echo "🎯 주요 기능:"
echo "   - Go 개발 환경 (vim-go)"
echo "   - 자동완성 (CoC)"
echo "   - 파일 검색 (fzf)"
echo "   - 파일 트리 (NERDTree)"
echo "   - Git 통합 (vim-fugitive)"
echo ""
echo "💡 Tip:"
echo "   - Tab으로 빌드: <Tab>b"
echo "   - Tab으로 실행: <Tab>r"
echo "   - Tab으로 테스트: <Tab>t"
echo "   - CoC 설치: :CoCInstall coc-go coc-python"
echo ""
echo "🧪 테스트:"
echo "   vim"
echo ""
