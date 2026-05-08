#!/bin/bash

set -e

echo "=========================================="
echo "🚀 tmux 설정 시작"
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
# 1. tmux 설치 확인 / 설치
# ========================================

if command -v tmux &> /dev/null; then
  echo "✅ tmux 이미 설치됨: $(tmux -V)"
else
  echo "📦 tmux 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install tmux
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      echo "   먼저 https://brew.sh 에서 Homebrew를 설치하세요."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y tmux
    elif command -v yum &> /dev/null; then
      sudo yum install -y tmux
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y tmux
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm tmux
    else
      echo "❌ 패키지 매니저를 찾을 수 없습니다. tmux를 수동으로 설치하세요."
      exit 1
    fi
  fi

  echo "✅ tmux 설치 완료: $(tmux -V)"
fi

echo ""

# ========================================
# 2. TPM (Tmux Plugin Manager) 설치
# ========================================

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
  echo "✅ TPM 이미 설치됨"
else
  echo "📦 TPM (Tmux Plugin Manager) 설치 중..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo "✅ TPM 설치 완료"
fi

echo ""

# ========================================
# 3. .tmux.conf 복사 (백업 후)
# ========================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMUX_CONF="$HOME/.tmux.conf"
SOURCE_CONF="$SCRIPT_DIR/.tmux.conf"

if [ -f "$TMUX_CONF" ] || [ -L "$TMUX_CONF" ]; then
  BACKUP_FILE="${TMUX_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$TMUX_CONF" "$BACKUP_FILE" 2>/dev/null || true
  echo "💾 기존 .tmux.conf 백업: $BACKUP_FILE"
fi

cp "$SOURCE_CONF" "$TMUX_CONF"
echo "✅ .tmux.conf 설치 완료: $TMUX_CONF"
echo ""

# ========================================
# 4. 플러그인 자동 설치 (TPM 비대화형 호출)
# ========================================

echo "📦 tmux 플러그인 설치 중 (tmux-sensible/yank/resurrect/continuum)..."
"$TPM_DIR/bin/install_plugins" 2>/dev/null || {
  echo "⚠️  플러그인 자동 설치 실패. 수동으로 tmux 안에서 'prefix + I' 누르세요."
}
echo ""

# ========================================
# 5. 안내
# ========================================

echo "=========================================="
echo "✅ tmux 설치 완료!"
echo "=========================================="
echo ""
echo "🔑 핵심 키바인딩 (prefix = Ctrl-a):"
echo "   prefix + |    : 수직 분할"
echo "   prefix + -    : 수평 분할"
echo "   prefix + h/j/k/l : 페인 이동 (vim 스타일)"
echo "   prefix + H/J/K/L : 페인 리사이즈 (반복 가능)"
echo "   prefix + r    : 설정 리로드"
echo "   prefix + I    : 플러그인 설치"
echo "   prefix + U    : 플러그인 업데이트"
echo "   prefix + [    : copy mode (v로 선택, y로 복사)"
echo ""
echo "🚀 시작:"
echo "   tmux                 # 새 세션 시작"
echo "   tmux new -s work     # 'work' 세션 시작"
echo "   tmux a               # 마지막 세션에 attach"
echo ""
echo "💡 세션 영속성 (resurrect/continuum):"
echo "   prefix + Ctrl-s      : 세션 저장"
echo "   prefix + Ctrl-r      : 세션 복원"
echo "   continuum이 15분마다 자동 저장합니다."
echo ""
echo "📝 자세한 내용: tmux/README.md"
echo ""
