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
# 1. Neovim 설치
# ========================================

if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "✅ Neovim 이미 설치됨: $NVIM_VERSION"
else
  echo "📦 Neovim 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install neovim
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y neovim
    # RHEL/CentOS/Fedora
    elif command -v yum &> /dev/null; then
      sudo yum install -y neovim
    # Arch Linux
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm neovim
    else
      echo "❌ 지원하지 않는 패키지 매니저입니다."
      echo "   https://github.com/neovim/neovim/releases 에서 수동 설치해주세요."
      exit 1
    fi
  fi

  echo "✅ Neovim 설치 완료"
fi

echo ""

# ========================================
# 2. 설정 파일 복사
# ========================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# 기존 설정 백업
if [ -d "$NVIM_CONFIG_DIR" ]; then
  BACKUP_DIR="$NVIM_CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
  echo "💾 기존 설정 백업: $BACKUP_DIR"
  mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi

# 디렉토리 생성
mkdir -p "$NVIM_CONFIG_DIR"

# 설정 파일 복사
echo "📝 설정 파일 복사 중..."
cp "$SCRIPT_DIR/init.lua" "$NVIM_CONFIG_DIR/"

if [ -f "$SCRIPT_DIR/lazy-lock.json" ]; then
  cp "$SCRIPT_DIR/lazy-lock.json" "$NVIM_CONFIG_DIR/"
fi

echo "✅ 설정 파일 복사 완료"
echo ""

# ========================================
# 3. LSP 서버 설치 (선택)
# ========================================

echo "=========================================="
echo "📦 LSP 서버 설치 (선택사항)"
echo "=========================================="
echo ""

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
      sudo npm install -g pyright
      echo "✅ pyright 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 pyright를 건너뜁니다."
    fi
  fi

  # TypeScript/JavaScript
  if [[ "$lsp_choice" == *"3"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 typescript-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      sudo npm install -g typescript-language-server typescript
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
    elif command -v apt-get &> /dev/null; then
      echo "⚠️  Terraform LS는 수동 설치가 필요합니다."
      echo "   https://github.com/hashicorp/terraform-ls/releases"
    fi
    echo "✅ terraform-ls 설치 완료 (또는 건너뜀)"
  fi

  # YAML
  if [[ "$lsp_choice" == *"5"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 yaml-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      sudo npm install -g yaml-language-server
      echo "✅ yamlls 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 yamlls를 건너뜁니다."
    fi
  fi

  # Bash
  if [[ "$lsp_choice" == *"6"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 bash-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      sudo npm install -g bash-language-server
      echo "✅ bashls 설치 완료"
    else
      echo "⚠️  npm이 설치되지 않아 bashls를 건너뜁니다."
    fi
  fi

  # Docker
  if [[ "$lsp_choice" == *"7"* ]] || [[ "$lsp_choice" == *"8"* ]] || [[ "$lsp_choice" == *"all"* ]]; then
    echo "📦 dockerfile-language-server 설치 중..."
    if command -v npm &> /dev/null; then
      sudo npm install -g dockerfile-language-server-nodejs
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
# 4. 플러그인 자동 설치
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
  echo "   플러그인 설치가 완료되면 :qa로 종료하세요."
  sleep 2
  nvim +qall
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
echo "🧪 테스트:"
echo "   nvim"
echo ""
