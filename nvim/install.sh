#!/bin/bash

set -e

echo "=========================================="
echo "Neovim IDE 설정 시작"
echo "=========================================="
echo ""

# OS 감지
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "감지된 OS: $MACHINE"
echo ""

# ========================================
# 1. Neovim 설치 (0.11+ 필수)
# ========================================

echo "=========================================="
echo " 1. Neovim 설치 (0.11+ 필수)"
echo "=========================================="

REQUIRED_NVIM_VERSION="0.11.0"

check_nvim_version() {
  if command -v nvim &> /dev/null; then
    CURRENT_VERSION=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$CURRENT_VERSION" ]; then
      if printf '%s\n' "$REQUIRED_NVIM_VERSION" "$CURRENT_VERSION" | sort -V | head -n1 | grep -q "^${REQUIRED_NVIM_VERSION}$"; then
        return 0
      fi
    fi
  fi
  return 1
}

install_neovim_linux() {
  echo "Neovim 최신 버전 설치 중 (AppImage)..."

  ARCH=$(uname -m)
  case $ARCH in
    x86_64) NVIM_ARCH="linux-x86_64" ;;
    aarch64|arm64) NVIM_ARCH="linux-arm64" ;;
    *)
      echo "지원하지 않는 아키텍처: $ARCH"
      echo "https://github.com/neovim/neovim/releases 에서 수동 설치해주세요."
      exit 1
      ;;
  esac

  if command -v nvim &> /dev/null; then
    NVIM_PATH=$(which nvim)
    if [ -f "$NVIM_PATH" ]; then
      sudo rm -f "$NVIM_PATH" 2>/dev/null || true
    fi
  fi

  NVIM_APPIMAGE="nvim-${NVIM_ARCH}.appimage"
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  echo "  다운로드 중: $NVIM_APPIMAGE"
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_APPIMAGE}"
  chmod u+x "$NVIM_APPIMAGE"

  if ./"$NVIM_APPIMAGE" --version &> /dev/null; then
    sudo mv "$NVIM_APPIMAGE" /usr/local/bin/nvim
    echo "Neovim AppImage 설치 완료"
  else
    echo "AppImage 직접 실행 불가. 압축 해제 방식으로 설치..."
    ./"$NVIM_APPIMAGE" --appimage-extract > /dev/null 2>&1
    sudo rm -rf /opt/neovim 2>/dev/null || true
    sudo mv squashfs-root /opt/neovim
    sudo ln -sf /opt/neovim/usr/bin/nvim /usr/local/bin/nvim
    echo "Neovim 압축 해제 설치 완료"
  fi

  cd - > /dev/null
  rm -rf "$TEMP_DIR"
}

if check_nvim_version; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "Neovim 이미 설치됨: $NVIM_VERSION"
else
  if command -v nvim &> /dev/null; then
    CURRENT=$(nvim --version | head -n 1)
    echo "현재 Neovim 버전이 너무 낮습니다: $CURRENT"
    echo "0.11+ 버전으로 업그레이드합니다..."
  else
    echo "Neovim 설치 중..."
  fi

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install neovim || brew upgrade neovim
    else
      echo "Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    install_neovim_linux
  fi

  if check_nvim_version; then
    echo "Neovim 설치 완료: $(nvim --version | head -n 1)"
  else
    echo "Neovim 0.11+ 설치에 실패했습니다."
    exit 1
  fi
fi

echo ""

# ========================================
# 2. 설정 파일 복사 (모듈 구조)
# ========================================

echo "=========================================="
echo " 2. 설정 파일 복사"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# 기존 설정 백업
if [ -d "$NVIM_CONFIG_DIR" ]; then
  BACKUP_DIR="${NVIM_CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "기존 설정 백업: $BACKUP_DIR"
  mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi

# 디렉토리 구조 생성
mkdir -p "$NVIM_CONFIG_DIR/lua/config"
mkdir -p "$NVIM_CONFIG_DIR/lua/plugins"

# init.lua 복사
if [ -f "$SCRIPT_DIR/init.lua" ]; then
  cp "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/"
else
  echo "init.lua 파일을 찾을 수 없습니다."
  exit 1
fi

# lua/config/ 복사
if [ -d "$SCRIPT_DIR/lua/config" ]; then
  cp "$SCRIPT_DIR/lua/config/"*.lua "$NVIM_CONFIG_DIR/lua/config/"
  echo "config 모듈 복사 완료"
else
  echo "lua/config/ 디렉토리를 찾을 수 없습니다."
  exit 1
fi

# lua/plugins/ 복사
if [ -d "$SCRIPT_DIR/lua/plugins" ]; then
  cp "$SCRIPT_DIR/lua/plugins/"*.lua "$NVIM_CONFIG_DIR/lua/plugins/"
  echo "plugins 모듈 복사 완료"
else
  echo "lua/plugins/ 디렉토리를 찾을 수 없습니다."
  exit 1
fi

# lazy-lock.json 복사
if [ -f "$SCRIPT_DIR/lazy-lock.json" ]; then
  cp "$SCRIPT_DIR/lazy-lock.json" "$NVIM_CONFIG_DIR/"
fi

echo "설정 파일 복사 완료"
echo ""

# ========================================
# 3. 터미널 커서 설정
# ========================================

echo "터미널 커서 설정 수정 중..."

if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

if ! grep -q "export TERM=" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Neovim 커서 문제 해결" >> "$SHELL_RC"
    echo "export TERM=xterm-256color" >> "$SHELL_RC"
fi

if [ -f "$HOME/.tmux.conf" ]; then
    if ! grep -q "set -g default-terminal" "$HOME/.tmux.conf"; then
        echo "" >> "$HOME/.tmux.conf"
        echo "# Neovim 커서 문제 해결" >> "$HOME/.tmux.conf"
        echo "set -g default-terminal \"screen-256color\"" >> "$HOME/.tmux.conf"
        echo "set -s escape-time 0" >> "$HOME/.tmux.conf"
    fi
fi

echo "터미널 설정 완료"
echo ""

# ========================================
# 4. 필수 종속성 설치
# ========================================

echo "=========================================="
echo " 3. 필수 종속성 설치"
echo "=========================================="

# ripgrep (Telescope)
if ! command -v rg &> /dev/null; then
    echo "  ripgrep 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install ripgrep
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y ripgrep
    elif command -v yum &> /dev/null; then
        sudo yum install -y ripgrep
    fi
fi

# fd (Telescope)
if ! command -v fd &> /dev/null; then
    echo "  fd 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install fd
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y fd-find
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
    fi
fi

# lazygit
if ! command -v lazygit &> /dev/null; then
    echo "  lazygit 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install lazygit
    elif [ "$MACHINE" = "Linux" ]; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' 2>/dev/null || echo "0.44.1")
        LG_ARCH=$(uname -m)
        case $LG_ARCH in
          x86_64) LG_ARCH="x86_64" ;;
          aarch64|arm64) LG_ARCH="arm64" ;;
        esac
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit lazygit.tar.gz
        echo "  lazygit 설치 완료"
    fi
fi

# shellcheck
if ! command -v shellcheck &> /dev/null; then
    echo "  shellcheck 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install shellcheck
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y shellcheck
    fi
fi

# shfmt
if ! command -v shfmt &> /dev/null; then
    echo "  shfmt 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install shfmt
    elif command -v go &> /dev/null; then
        go install mvdan.cc/sh/v3/cmd/shfmt@latest
    fi
fi

# Node.js/npm 확인
if ! command -v npm &> /dev/null; then
    echo ""
    echo "npm이 설치되어 있지 않습니다."
    echo "LSP 서버 설치를 위해 Node.js를 설치하는 것을 권장합니다."
fi

echo "필수 종속성 설치 완료"
echo ""

# ========================================
# 5. npm 설정
# ========================================

if command -v npm &> /dev/null; then
  echo "npm 캐시 권한 확인 중..."
  NPM_CACHE_DIR="$HOME/.npm"
  if [ -d "$NPM_CACHE_DIR" ]; then
    USER_ID=$(id -u)
    GROUP_ID=$(id -g)

    if [ "$MACHINE" = "Mac" ]; then
      CACHE_OWNER=$(stat -f "%u" "$NPM_CACHE_DIR" 2>/dev/null || echo "unknown")
    else
      CACHE_OWNER=$(stat -c "%u" "$NPM_CACHE_DIR" 2>/dev/null || echo "unknown")
    fi

    if [ "$CACHE_OWNER" != "$USER_ID" ] && [ "$CACHE_OWNER" != "unknown" ]; then
      echo "  npm 캐시 권한 수정 중..."
      sudo chown -R "$USER_ID:$GROUP_ID" "$NPM_CACHE_DIR"
      echo "  npm 캐시 권한 수정 완료"
    fi
  fi

  NPM_PREFIX="$HOME/.npm-global"
  if [ ! -d "$NPM_PREFIX" ]; then
    mkdir -p "$NPM_PREFIX"
    npm config set prefix "$NPM_PREFIX"

    if [ -n "$ZSH_VERSION" ]; then
      SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
      SHELL_RC="$HOME/.bashrc"
    else
      SHELL_RC="$HOME/.profile"
    fi

    if ! grep -q "npm-global/bin" "$SHELL_RC" 2>/dev/null; then
      echo "" >> "$SHELL_RC"
      echo "# npm global packages" >> "$SHELL_RC"
      echo "export PATH=\"$NPM_PREFIX/bin:\$PATH\"" >> "$SHELL_RC"
      echo "  PATH 업데이트됨. 터미널을 재시작하거나 'source $SHELL_RC' 실행하세요."
    fi
  fi
fi

echo ""

# ========================================
# 6. 플러그인 설치
# ========================================

echo "=========================================="
echo " 4. 플러그인 설치"
echo "=========================================="
echo ""

echo "Neovim을 처음 실행하면 lazy.nvim이 자동으로 플러그인을 설치합니다."
echo "Mason이 LSP 서버, DAP 어댑터, 린터, 포맷터를 자동 관리합니다."
echo ""

read -p "지금 Neovim을 실행하여 플러그인을 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  echo "Neovim 실행 중... 플러그인 설치가 완료되면 자동으로 종료됩니다."
  sleep 2
  nvim --headless "+Lazy! sync" +qa
  echo "플러그인 설치 완료"
fi

echo ""
echo "=========================================="
echo "설치 완료!"
echo "=========================================="
echo ""
echo "설치된 내용:"
echo "  - Neovim (0.11+)"
echo "  - 모듈 구조 설정 (init.lua + lua/config/ + lua/plugins/)"
echo "  - 필수 종속성 (ripgrep, fd, lazygit, shellcheck, shfmt)"
echo ""
echo "주요 기능:"
echo "  - LSP (자동완성, 정의로 이동, 에러 표시) - Mason 자동 관리"
echo "  - blink.cmp (빠른 자동완성 엔진)"
echo "  - Telescope (파일 검색: <leader>ff)"
echo "  - NvimTree (파일 트리: <leader>e)"
echo "  - Oil (버퍼 파일 관리: -)"
echo "  - Aerial (심볼 아웃라인: <leader>o)"
echo "  - DAP (디버거: F5, F9, F10, F11)"
echo "  - Neotest (테스트 러너: <leader>tn)"
echo "  - LazyGit (<leader>gg)"
echo "  - conform.nvim (자동 포맷) + nvim-lint (린팅)"
echo "  - Flash (빠른 점프: s)"
echo "  - Noice (모던 UI)"
echo "  - Git 통합 (gitsigns, diffview, git-conflict)"
echo "  - 테마 전환 (<leader>tt)"
echo ""
echo "Tip:"
echo "  - Leader 키는 Space입니다"
echo "  - :checkhealth 로 설정 확인"
echo "  - :Mason 으로 LSP/DAP/린터/포맷터 관리"
echo "  - :ConformInfo 로 포매터 상태 확인"
echo "  - 프로덕션 디렉토리에서는 자동으로 Gruvbox 테마 적용"
echo ""
echo "테스트:"
echo "  nvim"
echo ""

# 설치 로그 저장
LOG_FILE="$HOME/.config/nvim/install.log"
echo "설치 완료: $(date)" > "$LOG_FILE"
echo "OS: $MACHINE" >> "$LOG_FILE"
echo "Neovim: $(nvim --version | head -n 1)" >> "$LOG_FILE"
echo "구조: 모듈 (init.lua + lua/config/ + lua/plugins/)" >> "$LOG_FILE"

echo "설치 로그: $LOG_FILE"
echo ""
echo "모든 설정이 완료되었습니다!"
echo "터미널을 재시작한 후 nvim을 실행해보세요."
echo ""
