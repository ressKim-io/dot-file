#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Neovim 설정 시작"
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
# 1. Neovim 설치 (0.11+ 필수)
# ========================================

echo "=========================================="
echo " 1. Neovim 설치 (0.11+ 필수)"
echo "=========================================="

REQUIRED_NVIM_VERSION="0.11.0"

# 버전 비교 함수
check_nvim_version() {
  if command -v nvim &> /dev/null; then
    CURRENT_VERSION=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$CURRENT_VERSION" ]; then
      # 버전 비교 (0.11.0 이상 필요)
      if printf '%s\n' "$REQUIRED_NVIM_VERSION" "$CURRENT_VERSION" | sort -V | head -n1 | grep -q "^${REQUIRED_NVIM_VERSION}$"; then
        return 0  # 버전 충분
      fi
    fi
  fi
  return 1  # 설치/업그레이드 필요
}

install_neovim_linux() {
  echo "📦 Neovim 최신 버전 설치 중 (AppImage)..."

  # 아키텍처 감지
  ARCH=$(uname -m)
  case $ARCH in
    x86_64) NVIM_ARCH="linux-x86_64" ;;
    aarch64|arm64) NVIM_ARCH="linux-arm64" ;;
    *)
      echo "❌ 지원하지 않는 아키텍처: $ARCH"
      echo "   https://github.com/neovim/neovim/releases 에서 수동 설치해주세요."
      exit 1
      ;;
  esac

  # 기존 nvim 제거 (있다면)
  if command -v nvim &> /dev/null; then
    NVIM_PATH=$(which nvim)
    if [ -f "$NVIM_PATH" ]; then
      sudo rm -f "$NVIM_PATH" 2>/dev/null || true
    fi
  fi

  # AppImage 다운로드 및 설치
  NVIM_APPIMAGE="nvim-${NVIM_ARCH}.appimage"
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  echo "   다운로드 중: $NVIM_APPIMAGE"
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_APPIMAGE}"
  chmod u+x "$NVIM_APPIMAGE"

  # AppImage 실행 테스트
  if ./"$NVIM_APPIMAGE" --version &> /dev/null; then
    # AppImage 직접 설치
    sudo mv "$NVIM_APPIMAGE" /usr/local/bin/nvim
    echo "✅ Neovim AppImage 설치 완료"
  else
    # FUSE 없는 환경: 압축 해제 방식
    echo "⚠️  AppImage 직접 실행 불가. 압축 해제 방식으로 설치..."
    ./"$NVIM_APPIMAGE" --appimage-extract > /dev/null 2>&1
    sudo rm -rf /opt/neovim 2>/dev/null || true
    sudo mv squashfs-root /opt/neovim
    sudo ln -sf /opt/neovim/usr/bin/nvim /usr/local/bin/nvim
    echo "✅ Neovim 압축 해제 설치 완료"
  fi

  cd - > /dev/null
  rm -rf "$TEMP_DIR"
}

if check_nvim_version; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "✅ Neovim 이미 설치됨: $NVIM_VERSION"
else
  if command -v nvim &> /dev/null; then
    CURRENT=$(nvim --version | head -n 1)
    echo "⚠️  현재 Neovim 버전이 너무 낮습니다: $CURRENT"
    echo "   0.11+ 버전으로 업그레이드합니다..."
  else
    echo "📦 Neovim 설치 중..."
  fi

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install neovim || brew upgrade neovim
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    install_neovim_linux
  fi

  # 설치 확인
  if check_nvim_version; then
    echo "✅ Neovim 설치 완료: $(nvim --version | head -n 1)"
  else
    echo "❌ Neovim 0.11+ 설치에 실패했습니다."
    exit 1
  fi
fi

echo ""

# ========================================
# 2. 설정 파일 복사
# ========================================

echo "=========================================="
echo " 2. 설정 파일 복사"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# 기존 설정 백업
if [ -d "$NVIM_CONFIG_DIR" ]; then
  BACKUP_DIR="${NVIM_CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "💾 기존 설정 백업: $BACKUP_DIR"
  mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi

# 디렉토리 생성
mkdir -p "$NVIM_CONFIG_DIR"

# 설정 파일 복사
echo "📝 설정 파일 복사 중..."
if [ -f "$SCRIPT_DIR/init.lua" ]; then
  cp "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/"
else
  echo "❌ init.lua 파일을 찾을 수 없습니다."
  echo "   현재 디렉토리: $SCRIPT_DIR"
  exit 1
fi

# 플러그인 경로 자동 수정
echo "🔧 플러그인 경로 수정 중..."

# macOS와 Linux 모두 호환되는 sed 사용
if [ "$MACHINE" = "Mac" ]; then
  # macOS의 경우
  sed -i '' \
    -e 's|"ellisonleao/dotenv\.nvim"|"SergioRibera/dotenv.nvim"|g' \
    -e 's|"rest\.nvim/rest\.nvim"|"rest-nvim/rest.nvim"|g' \
    "$NVIM_CONFIG_DIR/init.lua"
else
  # Linux의 경우
  sed -i \
    -e 's|"ellisonleao/dotenv\.nvim"|"SergioRibera/dotenv.nvim"|g' \
    -e 's|"rest\.nvim/rest\.nvim"|"rest-nvim/rest.nvim"|g' \
    "$NVIM_CONFIG_DIR/init.lua"
fi

echo "✅ 플러그인 경로 수정 완료"

if [ -f "$SCRIPT_DIR/lazy-lock.json" ]; then
  cp "$SCRIPT_DIR/lazy-lock.json" "$NVIM_CONFIG_DIR/"
fi

echo "✅ 설정 파일 복사 완료"
echo ""

# ========================================
# 3. 커서 문제 해결을 위한 터미널 설정
# ========================================

echo "🔧 터미널 커서 설정 수정 중..."

# 현재 쉘 설정 파일 확인
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# 터미널 타입 설정 추가 (중복 방지)
if ! grep -q "export TERM=" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Neovim 커서 문제 해결" >> "$SHELL_RC"
    echo "export TERM=xterm-256color" >> "$SHELL_RC"
fi

# TMUX 사용자를 위한 설정
if [ -f "$HOME/.tmux.conf" ]; then
    if ! grep -q "set -g default-terminal" "$HOME/.tmux.conf"; then
        echo "" >> "$HOME/.tmux.conf"
        echo "# Neovim 커서 문제 해결" >> "$HOME/.tmux.conf"
        echo "set -g default-terminal \"screen-256color\"" >> "$HOME/.tmux.conf"
        echo "set -s escape-time 0" >> "$HOME/.tmux.conf"
    fi
fi

echo "✅ 터미널 설정 완료"
echo ""

# lazy 캐시 정리
echo "🧹 캐시 정리 중..."
rm -rf "$HOME/.local/share/nvim/lazy/dotenv.nvim" 2>/dev/null || true
rm -rf "$HOME/.local/share/nvim/lazy/rest.nvim" 2>/dev/null || true
rm -rf "$HOME/.local/share/nvim/lazy/rest-nvim" 2>/dev/null || true
rm -rf "$HOME/.local/state/nvim/lazy" 2>/dev/null || true
echo "✅ 캐시 정리 완료"
echo ""

# ========================================
# 4. 필수 종속성 설치
# ========================================

echo "📦 필수 종속성 확인 및 설치..."

# ripgrep 설치 (Telescope에 필요)
if ! command -v rg &> /dev/null; then
    echo "  - ripgrep 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install ripgrep
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y ripgrep
    elif command -v yum &> /dev/null; then
        sudo yum install -y ripgrep
    fi
fi

# fd 설치 (Telescope에 필요)
if ! command -v fd &> /dev/null; then
    echo "  - fd 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
        brew install fd
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y fd-find
        # Ubuntu/Debian에서는 fd-find로 설치되므로 심볼릭 링크 생성
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
    fi
fi

# Node.js/npm 설치 확인
if ! command -v npm &> /dev/null; then
    echo "⚠️  npm이 설치되어 있지 않습니다."
    echo "   LSP 서버 설치를 위해 Node.js를 설치하는 것을 권장합니다."
    echo "   설치: https://nodejs.org/"
fi

echo "✅ 필수 종속성 설치 완료"
echo ""

# ========================================
# 5. LSP 서버 설치 (선택)
# ========================================

echo "=========================================="
echo "📦 LSP 서버 설치 (선택사항)"
echo "=========================================="
echo ""

# npm 캐시 권한 문제 해결
if command -v npm &> /dev/null; then
  echo "🔧 npm 캐시 권한 확인 중..."
  NPM_CACHE_DIR="$HOME/.npm"
  if [ -d "$NPM_CACHE_DIR" ]; then
    # 현재 사용자의 UID와 GID 가져오기
    USER_ID=$(id -u)
    GROUP_ID=$(id -g)

    # npm 캐시 디렉토리의 소유자 확인
    if [ "$MACHINE" = "Mac" ]; then
      CACHE_OWNER=$(stat -f "%u" "$NPM_CACHE_DIR" 2>/dev/null || echo "unknown")
    else
      CACHE_OWNER=$(stat -c "%u" "$NPM_CACHE_DIR" 2>/dev/null || echo "unknown")
    fi

    # 소유자가 다르면 수정
    if [ "$CACHE_OWNER" != "$USER_ID" ] && [ "$CACHE_OWNER" != "unknown" ]; then
      echo "  npm 캐시 권한 수정 중..."
      sudo chown -R "$USER_ID:$GROUP_ID" "$NPM_CACHE_DIR"
      echo "✅ npm 캐시 권한 수정 완료"
    fi
  fi

  # npm prefix 설정 (글로벌 패키지를 사용자 디렉토리에 설치)
  NPM_PREFIX="$HOME/.npm-global"
  if [ ! -d "$NPM_PREFIX" ]; then
    mkdir -p "$NPM_PREFIX"
    npm config set prefix "$NPM_PREFIX"

    # PATH에 추가
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
      echo "  ⚠️  PATH 업데이트됨. 터미널을 재시작하거나 'source $SHELL_RC' 실행하세요."
    fi
  fi
fi

read -p "LSP 서버를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then

  echo "설치할 LSP 서버를 선택하세요 (쉼표로 구분):"
  echo "1. Go (gopls)"
  echo "2. Python (pyright)"
  echo "3. TypeScript/JavaScript (ts_ls)"
  echo "4. Terraform (terraformls, tflint)"
  echo "5. YAML (yamlls)"
  echo "6. Bash (bashls)"
  echo "7. Docker (dockerls)"
  echo "8. All (모두 설치)"
  echo ""
  read -p "선택 (1,2,3 or 8): " lsp_choice

  # npm 명령어 설정 (sudo 없이 사용자 디렉토리에 설치)
  NPM_CMD="npm"
  if [ -d "$HOME/.npm-global" ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
  fi

  # Go
  if [[ "$lsp_choice" == *"1"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 gopls 설치 중..."
    if command -v go &> /dev/null; then
      go install golang.org/x/tools/gopls@latest
      echo "✅ gopls 설치 완료"
    else
      echo "⚠️  Go가 설치되지 않아 gopls를 건너뜁니다."
    fi
  fi

  # Python
  if [[ "$lsp_choice" == *"2"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 pyright 설치 중..."
    if command -v npm &> /dev/null; then
      $NPM_CMD install -g pyright
      echo "✅ pyright 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 pyright를 건너뜁니다."
    fi
  fi

  # TypeScript/JavaScript
  if [[ "$lsp_choice" == *"3"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 typescript-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      $NPM_CMD install -g typescript-language-server typescript
      echo "✅ ts_ls 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 ts_ls를 건너뜁니다."
    fi
  fi

  # Terraform
  if [[ "$lsp_choice" == *"4"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 terraform-ls 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
      brew install terraform-ls tflint
      echo "✅ terraform-ls 설치 완료"
    elif [ "$MACHINE" = "Linux" ]; then
      # terraform-ls 바이너리 직접 설치
      # 동적으로 최신 버전 가져오기
      TERRAFORM_LS_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform-ls/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
      if [ -z "$TERRAFORM_LS_VERSION" ]; then
        TERRAFORM_LS_VERSION="0.38.3"  # fallback
      fi
      # 아키텍처 감지
      TF_ARCH=$(uname -m)
      case $TF_ARCH in
        x86_64) TF_ARCH_SUFFIX="amd64" ;;
        aarch64|arm64) TF_ARCH_SUFFIX="arm64" ;;
        *) TF_ARCH_SUFFIX="amd64" ;;
      esac

      TEMP_DIR=$(mktemp -d)
      cd "$TEMP_DIR"
      curl -LO "https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TF_ARCH_SUFFIX}.zip"
      unzip "terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TF_ARCH_SUFFIX}.zip"
      sudo mv terraform-ls /usr/local/bin/
      cd - > /dev/null
      rm -rf "$TEMP_DIR"
      echo "✅ terraform-ls ${TERRAFORM_LS_VERSION} 설치 완료"
    fi
  fi

  # YAML
  if [[ "$lsp_choice" == *"5"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 yaml-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      $NPM_CMD install -g yaml-language-server
      echo "✅ yamlls 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 yamlls를 건너뜁니다."
    fi
  fi

  # Bash
  if [[ "$lsp_choice" == *"6"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 bash-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      $NPM_CMD install -g bash-language-server
      echo "✅ bashls 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 bashls를 건너뜁니다."
    fi
  fi

  # Docker
  if [[ "$lsp_choice" == *"7"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 dockerfile-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      $NPM_CMD install -g dockerfile-language-server-nodejs
      echo "✅ dockerls 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 dockerls를 건너뜁니다."
    fi
  fi

  echo ""
  echo "✅ LSP 서버 설치 완료"
else
  echo "⏭️  LSP 서버 설치 건너뛰기"
fi

echo ""

# ========================================
# 6. 플러그인 자동 설치
# ========================================

echo "=========================================="
echo "🔌 플러그인 설치"
echo "=========================================="
echo ""

echo "Neovim을 처음 실행하면 lazy.nvim이 자동으로 플러그인을 설치합니다."
echo ""

read -p "지금 Neovim을 실행하여 플러그인을 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  echo "✅ Neovim 실행 중..."
  echo "   플러그인 설치가 완료되면 자동으로 종료됩니다."
  sleep 2
  nvim --headless "+Lazy! sync" +qa
  echo "✅ 플러그인 설치 완료"
fi

echo ""
echo "=========================================="
echo "✅ 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 내용:"
echo "   - Neovim"
echo "   - DevOps 특화 설정 (init.lua)"
echo "   - 필수 종속성 (ripgrep, fd)"
echo "   - LSP 서버 (선택)"
echo "   - 플러그인 (lazy.nvim)"
echo ""
echo "🎯 주요 기능:"
echo "   - LSP (자동완성, 정의로 이동, 에러 표시)"
echo "   - Telescope (파일 검색: <leader>ff)"
echo "   - NvimTree (파일 트리: <leader>e)"
echo "   - Git 통합 (Gitsigns)"
echo "   - 터미널 (Ctrl+\)"
echo "   - 테마 전환 (<leader>tt)"
echo ""
echo "💡 Tip:"
echo "   - Leader 키는 Space입니다"
echo "   - :checkhealth로 설정 확인"
echo "   - 프로덕션 디렉토리에서는 자동으로 Gruvbox 테마 적용"
echo ""
echo "⚠️  커서 문제 해결:"
echo "   - 터미널을 재시작하거나 'source $SHELL_RC' 실행"
echo "   - TMUX 사용 중이라면 TMUX도 재시작"
echo "   - 여전히 문제가 있다면 init.lua에 다음 설정 추가:"
echo "     vim.opt.guicursor = ''"
echo ""
echo "🧪 테스트:"
echo "   nvim"
echo ""

# ========================================
# 7. 커서 문제 해결을 위한 init.lua 패치
# ========================================

# init.lua에 커서 관련 설정 추가
if [ -f "$NVIM_CONFIG_DIR/init.lua" ]; then
    # 커서 설정이 없으면 추가
    if ! grep -q "guicursor" "$NVIM_CONFIG_DIR/init.lua"; then
        cat >> "$NVIM_CONFIG_DIR/init.lua" << 'EOF'

-- 커서 위치 문제 해결
vim.opt.guicursor = ""
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.virtualedit = "onemore"
vim.opt.whichwrap = "b,s,<,>,[,]"

-- 터미널에서 더 나은 성능
if vim.fn.has('nvim') == 1 then
  vim.opt.termguicolors = true
end
EOF
        echo "✅ 커서 설정이 init.lua에 추가되었습니다."
    fi
fi

# 현재 터미널 환경 확인
echo ""
echo "🔍 현재 환경:"
echo "   TERM: $TERM"
echo "   SHELL: $SHELL"
if [ -n "$TMUX" ]; then
    echo "   TMUX: 실행 중"
fi
echo ""

# 추가 문제 해결 안내
echo "❓ 추가 문제 해결:"
echo "   1. 커서 문제가 지속되면:"
echo "      - 다른 터미널 에뮬레이터 시도 (Alacritty, Kitty 등)"
echo "      - SSH 연결인 경우 로컬 터미널 설정 확인"
echo ""
echo "   2. 플러그인이 제대로 로드되지 않으면:"
echo "      - nvim 실행 후 :Lazy 명령으로 수동 설치"
echo "      - :checkhealth lazy 로 문제 확인"
echo ""
echo "   3. LSP가 작동하지 않으면:"
echo "      - :LspInfo 로 상태 확인"
echo "      - :Mason 으로 LSP 서버 추가 설치"
echo ""

# 설치 로그 저장
LOG_FILE="$HOME/.config/nvim/install.log"
echo "설치 완료: $(date)" > "$LOG_FILE"
echo "OS: $MACHINE" >> "$LOG_FILE"
echo "Neovim: $(nvim --version | head -n 1)" >> "$LOG_FILE"
echo "설치된 LSP: $lsp_choice" >> "$LOG_FILE"

echo "📄 설치 로그: $LOG_FILE"
echo ""
echo "🎉 모든 설정이 완료되었습니다!"
echo "   터미널을 재시작한 후 nvim을 실행해보세요."
echo ""
