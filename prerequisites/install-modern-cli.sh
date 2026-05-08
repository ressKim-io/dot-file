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
    DELTA_VERSION=$(get_latest_github_tag "dandavison/delta" "0.19.2")
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
# 8. ripgrep (빠른 grep 대체)
# ========================================
echo "=========================================="
echo "📦 ripgrep 설치 (빠른 grep 대체)"
echo "=========================================="

if command -v rg &> /dev/null; then
  echo "✅ ripgrep 이미 설치됨: $(rg --version | head -n 1 | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install ripgrep
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get install -y ripgrep
    fi
  fi
  command -v rg &> /dev/null && echo "✅ ripgrep 설치 완료"
fi
echo ""

# ========================================
# 9. fd (사용자 친화적 find 대체)
# ========================================
echo "=========================================="
echo "📦 fd 설치 (사용자 친화적 find 대체)"
echo "=========================================="

if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
  echo "✅ fd 이미 설치됨"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install fd
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      # Ubuntu/Debian에서는 'fdfind'로 설치됨 - fd 심볼릭 링크 생성
      sudo apt-get install -y fd-find
      if ! command -v fd &> /dev/null && command -v fdfind &> /dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        echo "ℹ️  Ubuntu는 fdfind으로 설치되어 ~/.local/bin/fd 심볼릭 링크를 생성했습니다."
      fi
    fi
  fi
fi
echo ""

# ========================================
# 10. lazygit (Git TUI)
# ========================================
echo "=========================================="
echo "📦 lazygit 설치 (Git TUI)"
echo "=========================================="

if command -v lazygit &> /dev/null; then
  echo "✅ lazygit 이미 설치됨: $(lazygit --version | head -n 1 | awk -F'version=' '{print $2}' | awk -F',' '{print $1}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install lazygit
  elif [ "$MACHINE" = "Linux" ]; then
    case "$(uname -m)" in
      x86_64) LG_ARCH="x86_64" ;;
      aarch64|arm64) LG_ARCH="arm64" ;;
      *) LG_ARCH="x86_64" ;;
    esac
    LG_VERSION=$(get_latest_github_tag "jesseduffield/lazygit" "0.61.1")
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz" -o "$TMPDIR/lazygit.tar.gz"; then
      tar -xzf "$TMPDIR/lazygit.tar.gz" -C "$TMPDIR" lazygit
      sudo install -m 0755 "$TMPDIR/lazygit" /usr/local/bin/lazygit
      echo "✅ lazygit 설치 완료: $LG_VERSION"
    else
      echo "⚠️  lazygit 다운로드 실패"
    fi
    rm -rf "$TMPDIR"
  fi
fi
echo ""

# ========================================
# 11. lazydocker (Docker TUI)
# ========================================
echo "=========================================="
echo "📦 lazydocker 설치 (Docker TUI)"
echo "=========================================="

if command -v lazydocker &> /dev/null; then
  echo "✅ lazydocker 이미 설치됨"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install lazydocker
  elif [ "$MACHINE" = "Linux" ]; then
    case "$(uname -m)" in
      x86_64) LD_ARCH="x86_64" ;;
      aarch64|arm64) LD_ARCH="arm64" ;;
      *) LD_ARCH="x86_64" ;;
    esac
    LD_VERSION=$(get_latest_github_tag "jesseduffield/lazydocker" "0.25.2")
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/v${LD_VERSION}/lazydocker_${LD_VERSION}_Linux_${LD_ARCH}.tar.gz" -o "$TMPDIR/lazydocker.tar.gz"; then
      tar -xzf "$TMPDIR/lazydocker.tar.gz" -C "$TMPDIR" lazydocker
      sudo install -m 0755 "$TMPDIR/lazydocker" /usr/local/bin/lazydocker
      echo "✅ lazydocker 설치 완료: $LD_VERSION"
    else
      echo "⚠️  lazydocker 다운로드 실패"
    fi
    rm -rf "$TMPDIR"
  fi
fi
echo ""

# ========================================
# 12. dive (Docker 이미지 레이어 분석)
# ========================================
echo "=========================================="
echo "📦 dive 설치 (Docker 이미지 레이어 분석)"
echo "=========================================="

if command -v dive &> /dev/null; then
  echo "✅ dive 이미 설치됨: $(dive --version 2>/dev/null | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install dive
  elif [ "$MACHINE" = "Linux" ]; then
    DIVE_ARCH=$(get_arch_generic)
    DIVE_VERSION=$(get_latest_github_tag "wagoodman/dive" "0.13.1")
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_${DIVE_ARCH}.tar.gz" -o "$TMPDIR/dive.tar.gz"; then
      tar -xzf "$TMPDIR/dive.tar.gz" -C "$TMPDIR" dive
      sudo install -m 0755 "$TMPDIR/dive" /usr/local/bin/dive
      echo "✅ dive 설치 완료: $DIVE_VERSION"
    else
      echo "⚠️  dive 다운로드 실패"
    fi
    rm -rf "$TMPDIR"
  fi
fi
echo ""

# ========================================
# 13. tealdeer (tldr - 빠른 명령어 치트시트)
# ========================================
echo "=========================================="
echo "📦 tealdeer 설치 (tldr - 명령어 치트시트)"
echo "=========================================="

if command -v tldr &> /dev/null; then
  echo "✅ tldr 이미 설치됨"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install tealdeer
  elif [ "$MACHINE" = "Linux" ]; then
    # Ubuntu 24.04+ apt 또는 GitHub Releases binary
    if apt-cache show tealdeer &> /dev/null; then
      sudo apt-get install -y tealdeer
    elif command -v apt-get &> /dev/null; then
      case "$(uname -m)" in
        x86_64) TLDR_ARCH="x86_64-unknown-linux-musl" ;;
        aarch64|arm64) TLDR_ARCH="aarch64-unknown-linux-musl" ;;
        *) TLDR_ARCH="x86_64-unknown-linux-musl" ;;
      esac
      TLDR_VERSION=$(get_latest_github_tag "tealdeer-rs/tealdeer" "1.8.1")
      TMPDIR=$(mktemp -d)
      if curl -fsSL "https://github.com/tealdeer-rs/tealdeer/releases/download/v${TLDR_VERSION}/tealdeer-linux-${TLDR_ARCH}" -o "$TMPDIR/tldr"; then
        sudo install -m 0755 "$TMPDIR/tldr" /usr/local/bin/tldr
        echo "✅ tealdeer 설치 완료: $TLDR_VERSION"
      else
        echo "⚠️  tealdeer 다운로드 실패"
      fi
      rm -rf "$TMPDIR"
    fi
  fi
  command -v tldr &> /dev/null && tldr --update 2>/dev/null || true
fi
echo ""

# ========================================
# 14. starship (모던 cross-shell 프롬프트, opt-in)
# ========================================
# 설치만 하고 .zshrc에는 주석 처리된 init 스니펫만 추가됩니다.
# 활성화하려면 .zshrc 하단의 # eval "$(starship init zsh)" 주석을 풀고,
# 기존 커스텀 PROMPT 블록(MAC/WSL/LINUX 분기)을 주석 처리하세요.
echo "=========================================="
echo "📦 starship 설치 (모던 프롬프트, opt-in)"
echo "=========================================="

if command -v starship &> /dev/null; then
  echo "✅ starship 이미 설치됨: $(starship --version | head -n 1 | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install starship
  elif [ "$MACHINE" = "Linux" ]; then
    # 공식 설치 스크립트 (~/.local/bin 또는 /usr/local/bin)
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir /usr/local/bin 2>/dev/null || \
      curl -sS https://starship.rs/install.sh | sudo sh -s -- -y --bin-dir /usr/local/bin
  fi
  command -v starship &> /dev/null && echo "✅ starship 설치 완료"
  echo "💡 활성화: ~/.zshrc 하단의 starship 블록 주석 해제 (기존 PROMPT 비활성화 필요)"
fi
echo ""

# ========================================
# 15. atuin (SQLite 기반 셸 히스토리 검색, opt-in)
# ========================================
# 설치만 하고 .zshrc에는 주석 처리된 init 스니펫만 추가됩니다.
# 활성화하면 Ctrl+R이 atuin 검색 UI로 대체됩니다 (기본 fzf-history와 충돌 가능).
echo "=========================================="
echo "📦 atuin 설치 (셸 히스토리 검색, opt-in)"
echo "=========================================="

if command -v atuin &> /dev/null; then
  echo "✅ atuin 이미 설치됨: $(atuin --version | awk '{print $2}')"
else
  if [ "$MACHINE" = "Mac" ]; then
    command -v brew &> /dev/null && brew install atuin
  elif [ "$MACHINE" = "Linux" ]; then
    # 공식 설치 스크립트
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --no-modify-path 2>/dev/null || \
      curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  fi
  command -v atuin &> /dev/null && echo "✅ atuin 설치 완료"
  echo "💡 활성화: ~/.zshrc 하단의 atuin 블록 주석 해제 (Ctrl+R 동작 변경됨)"
fi
echo ""

# ========================================
# 16. Nerd Font (JetBrainsMono)
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
command -v rg     &> /dev/null && echo "   ✅ ripgrep"
(command -v fd &> /dev/null || command -v fdfind &> /dev/null) && echo "   ✅ fd"
command -v lazygit &> /dev/null && echo "   ✅ lazygit"
command -v lazydocker &> /dev/null && echo "   ✅ lazydocker"
command -v dive &> /dev/null && echo "   ✅ dive"
command -v tldr &> /dev/null && echo "   ✅ tldr (tealdeer)"
command -v starship &> /dev/null && echo "   ✅ starship (opt-in, .zshrc 주석 해제 필요)"
command -v atuin &> /dev/null && echo "   ✅ atuin (opt-in, .zshrc 주석 해제 필요)"
echo ""
echo "💡 .zshrc에서 이들을 활성화하려면:"
echo "   cd zsh && ./install.sh"
echo ""
