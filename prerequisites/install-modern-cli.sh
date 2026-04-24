#!/bin/bash
# 모던 CLI 도구 설치 (fzf, bat, eza, zoxide, git-delta, direnv, pipx, Nerd Font)
# 이 스크립트는 install.sh에서 자동 호출되며, 단독 실행도 가능합니다.

set -e

echo "=========================================="
echo "🎨 모던 CLI 도구 설치"
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
# 유틸: GitHub 릴리스에서 최신 버전 가져오기
# ========================================
get_latest_github_tag() {
  local repo="$1"
  local fallback="$2"
  local tag
  tag=$(curl -s --connect-timeout 10 "https://api.github.com/repos/${repo}/releases/latest" \
    | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
  echo "${tag:-$fallback}"
}

get_arch_generic() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) echo "amd64" ;;
  esac
}

# ========================================
# 1. pipx (PEP 668 대응 Python 도구 관리자)
# ========================================
echo "=========================================="
echo "📦 pipx 설치"
echo "=========================================="

if command -v pipx &> /dev/null; then
  echo "✅ pipx 이미 설치됨: $(pipx --version)"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install pipx && pipx ensurepath || true
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get install -y pipx && pipx ensurepath || true
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y pipx && pipx ensurepath || true
    fi
  fi
  command -v pipx &> /dev/null && echo "✅ pipx 설치 완료"
fi
echo ""

# ========================================
# 2. fzf (퍼지 파인더)
# ========================================
echo "=========================================="
echo "📦 fzf 설치 (퍼지 파인더)"
echo "=========================================="

if command -v fzf &> /dev/null; then
  echo "✅ fzf 이미 설치됨: $(fzf --version | awk '{print $1}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install fzf && yes | $(brew --prefix)/opt/fzf/install --no-bash --no-fish 2>/dev/null || true
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      # Ubuntu 22.04+ 는 apt로 fzf 제공 (구버전이지만 동작)
      sudo apt-get install -y fzf || {
        # apt에 없으면 git 설치
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all --no-bash --no-fish
      }
    fi
  fi
  command -v fzf &> /dev/null && echo "✅ fzf 설치 완료"
fi
echo ""

# ========================================
# 3. bat (cat + 하이라이팅)
# ========================================
echo "=========================================="
echo "📦 bat 설치 (cat + syntax highlight)"
echo "=========================================="

if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
  echo "✅ bat 이미 설치됨"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install bat
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      # Ubuntu/Debian에서는 'batcat'으로 설치됨 - bat 심볼릭 링크 생성
      sudo apt-get install -y bat
      if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        echo "ℹ️  Ubuntu는 batcat으로 설치되어 ~/.local/bin/bat 심볼릭 링크를 생성했습니다."
      fi
    fi
  fi
fi
echo ""

# ========================================
# 4. eza (ls 대체)
# ========================================
echo "=========================================="
echo "📦 eza 설치 (ls 현대화)"
echo "=========================================="

if command -v eza &> /dev/null; then
  echo "✅ eza 이미 설치됨: $(eza --version | head -n 1 | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install eza
  elif [ "$MACHINE" = "Linux" ]; then
    # Ubuntu 24.04+ 는 apt에 eza 있음, 그 이하는 eza 공식 저장소 추가
    if apt-cache show eza &> /dev/null; then
      sudo apt-get install -y eza
    elif command -v apt-get &> /dev/null; then
      echo "📦 eza 공식 apt 저장소 추가 중..."
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt-get update
      sudo apt-get install -y eza
    fi
  fi
  command -v eza &> /dev/null && echo "✅ eza 설치 완료"
fi
echo ""

# ========================================
# 5. zoxide (cd 대체, 빈도 기반 이동)
# ========================================
echo "=========================================="
echo "📦 zoxide 설치 (스마트 cd)"
echo "=========================================="

if command -v zoxide &> /dev/null; then
  echo "✅ zoxide 이미 설치됨: $(zoxide --version | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install zoxide
  elif [ "$MACHINE" = "Linux" ]; then
    # 공식 설치 스크립트 (shell init까지 자동 처리됨)
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir /usr/local/bin 2>/dev/null || \
      curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sudo sh -s -- --bin-dir /usr/local/bin
  fi
  command -v zoxide &> /dev/null && echo "✅ zoxide 설치 완료"
fi
echo ""

# ========================================
# 6. git-delta (diff 뷰어)
# ========================================
echo "=========================================="
echo "📦 git-delta 설치 (diff 뷰어)"
echo "=========================================="

if command -v delta &> /dev/null; then
  echo "✅ git-delta 이미 설치됨: $(delta --version | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install git-delta
  elif [ "$MACHINE" = "Linux" ]; then
    ARCH=$(get_arch_generic)
    DELTA_VERSION=$(get_latest_github_tag "dandavison/delta" "0.18.2")
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-$(uname -m)-unknown-linux-gnu.tar.gz" -o "$TMPDIR/delta.tar.gz"; then
      tar -xzf "$TMPDIR/delta.tar.gz" -C "$TMPDIR"
      DELTA_BIN=$(find "$TMPDIR" -type f -name delta | head -n 1)
      [ -n "$DELTA_BIN" ] && sudo install -m 0755 "$DELTA_BIN" /usr/local/bin/delta
      echo "✅ git-delta 설치 완료: $DELTA_VERSION"
    else
      echo "⚠️  git-delta 다운로드 실패"
    fi
    rm -rf "$TMPDIR"
  fi
fi
echo ""

# ========================================
# 7. direnv (프로젝트별 환경변수 자동 로드)
# ========================================
echo "=========================================="
echo "📦 direnv 설치 (프로젝트별 env 자동 로드)"
echo "=========================================="

if command -v direnv &> /dev/null; then
  echo "✅ direnv 이미 설치됨: $(direnv version)"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install direnv
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get install -y direnv || {
        # apt 패키지가 너무 오래된 경우 공식 설치 스크립트 사용
        curl -sfL https://direnv.net/install.sh | sudo bash
      }
    fi
  fi
  command -v direnv &> /dev/null && echo "✅ direnv 설치 완료"
fi
echo ""

# ========================================
# 8. Nerd Font (JetBrainsMono)
# ========================================
echo "=========================================="
echo "🔤 Nerd Font 설치 (JetBrainsMono)"
echo "=========================================="

install_nerd_font() {
  local FONT_NAME="JetBrainsMono"
  local FONT_DIR

  if [ "$MACHINE" = "Mac" ]; then
    FONT_DIR="$HOME/Library/Fonts"
  else
    FONT_DIR="$HOME/.local/share/fonts"
  fi

  mkdir -p "$FONT_DIR"

  if ls "$FONT_DIR"/*${FONT_NAME}*Nerd* 1>/dev/null 2>&1; then
    echo "✅ Nerd Font 이미 설치됨 ($FONT_NAME)"
    return 0
  fi

  echo "📥 $FONT_NAME Nerd Font 다운로드 중..."
  TMPDIR=$(mktemp -d)
  if curl -fsSL -o "$TMPDIR/font.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"; then
    unzip -qo "$TMPDIR/font.zip" -d "$TMPDIR/fonts"
    find "$TMPDIR/fonts" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
    find "$TMPDIR/fonts" -name "*.otf" -exec cp {} "$FONT_DIR/" \;
    if [ "$MACHINE" = "Linux" ] && command -v fc-cache &> /dev/null; then
      fc-cache -fv "$FONT_DIR" > /dev/null 2>&1 || true
    fi
    echo "✅ $FONT_NAME Nerd Font 설치 완료"
    echo "   터미널 폰트를 'JetBrainsMono Nerd Font'로 변경하세요."
  else
    echo "⚠️  Nerd Font 다운로드 실패 (https://www.nerdfonts.com/font-downloads 수동 설치)"
  fi
  rm -rf "$TMPDIR"
}

install_nerd_font
echo ""

echo "=========================================="
echo "✅ 모던 CLI 도구 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 도구:"
command -v pipx   &> /dev/null && echo "   ✅ pipx"
command -v fzf    &> /dev/null && echo "   ✅ fzf"
(command -v bat &> /dev/null || command -v batcat &> /dev/null) && echo "   ✅ bat"
command -v eza    &> /dev/null && echo "   ✅ eza"
command -v zoxide &> /dev/null && echo "   ✅ zoxide"
command -v delta  &> /dev/null && echo "   ✅ git-delta"
command -v direnv &> /dev/null && echo "   ✅ direnv"
echo ""
echo "💡 .zshrc에서 이들을 활성화하려면:"
echo "   cd zsh && ./install.sh"
echo ""
