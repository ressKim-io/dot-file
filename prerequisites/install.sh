#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Prerequisites 전체 설치"
echo "=========================================="
echo ""
echo "다음 도구들을 설치합니다:"
echo "   1. 런타임: Go, Node.js, Python"
echo "   2. Docker"
echo "   3. Kubernetes 도구: kubectl, helm"
echo "   4. DevOps 도구: terraform, jq, yq, yamllint, hadolint"
echo ""
echo "⏱️  예상 시간: 10-20분"
echo ""

read -p "계속하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "설치를 취소했습니다."
  exit 0
fi

echo ""

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ========================================
# 1. 런타임 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 1/4: 런타임 설치"
echo "=========================================="
echo ""

if [ -f "$SCRIPT_DIR/install-runtimes.sh" ]; then
  bash "$SCRIPT_DIR/install-runtimes.sh"
else
  echo "❌ install-runtimes.sh를 찾을 수 없습니다."
  exit 1
fi

# ========================================
# 2. Docker 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 2/4: Docker 설치"
echo "=========================================="
echo ""

read -p "Docker를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-docker.sh" ]; then
    bash "$SCRIPT_DIR/install-docker.sh"
  else
    echo "❌ install-docker.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  Docker 설치를 건너뜁니다."
fi

# ========================================
# 3. Kubernetes 도구 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 3/4: Kubernetes 도구 설치"
echo "=========================================="
echo ""

read -p "Kubernetes 도구 (kubectl, helm)를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-k8s-tools.sh" ]; then
    bash "$SCRIPT_DIR/install-k8s-tools.sh"
  else
    echo "❌ install-k8s-tools.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  Kubernetes 도구 설치를 건너뜁니다."
fi

# ========================================
# 4. DevOps 도구 설치
# ========================================

echo ""
echo "=========================================="
echo "STEP 4/4: DevOps 도구 설치"
echo "=========================================="
echo ""

read -p "DevOps 도구 (terraform, jq, yq 등)를 설치하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ -f "$SCRIPT_DIR/install-devops-tools.sh" ]; then
    bash "$SCRIPT_DIR/install-devops-tools.sh"
  else
    echo "❌ install-devops-tools.sh를 찾을 수 없습니다."
  fi
else
  echo "⏭️  DevOps 도구 설치를 건너뜁니다."
fi

# ========================================
# 설치 완료
# ========================================

echo ""
echo "=========================================="
echo "✅ Prerequisites 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 도구 확인:"
echo ""

# 런타임
echo "🔧 런타임:"
command -v go &> /dev/null && echo "   ✅ Go: $(go version | awk '{print $3}')" || echo "   ❌ Go: 설치 안됨"
command -v node &> /dev/null && echo "   ✅ Node.js: $(node --version)" || echo "   ❌ Node.js: 설치 안됨"
command -v npm &> /dev/null && echo "   ✅ npm: $(npm --version)" || echo "   ❌ npm: 설치 안됨"
command -v python3 &> /dev/null && echo "   ✅ Python3: $(python3 --version | awk '{print $2}')" || echo "   ❌ Python3: 설치 안됨"

echo ""

# 컨테이너
echo "🐳 컨테이너:"
command -v docker &> /dev/null && echo "   ✅ Docker: $(docker --version | awk '{print $3}' | sed 's/,//')" || echo "   ❌ Docker: 설치 안됨"

echo ""

# Kubernetes
echo "☸️  Kubernetes:"
command -v kubectl &> /dev/null && echo "   ✅ kubectl: $(kubectl version --client --short 2>/dev/null | awk '{print $3}' || echo 'installed')" || echo "   ❌ kubectl: 설치 안됨"
command -v helm &> /dev/null && echo "   ✅ helm: $(helm version --short 2>/dev/null | awk '{print $1}')" || echo "   ❌ helm: 설치 안됨"

echo ""

# DevOps 도구
echo "🔧 DevOps:"
command -v terraform &> /dev/null && echo "   ✅ terraform: $(terraform --version | head -n 1 | awk '{print $2}')" || echo "   ❌ terraform: 설치 안됨"
command -v jq &> /dev/null && echo "   ✅ jq: $(jq --version)" || echo "   ❌ jq: 설치 안됨"
command -v yq &> /dev/null && echo "   ✅ yq: $(yq --version 2>&1 | head -n 1 | awk '{print $3}')" || echo "   ❌ yq: 설치 안됨"
command -v yamllint &> /dev/null && echo "   ✅ yamllint: $(yamllint --version | awk '{print $2}')" || echo "   ❌ yamllint: 설치 안됨"
command -v hadolint &> /dev/null && echo "   ✅ hadolint: installed" || echo "   ❌ hadolint: 설치 안됨"

echo ""
echo "=========================================="
echo "🎯 다음 단계"
echo "=========================================="
echo ""
echo "1. 새 터미널을 열거나 다음 명령어 실행:"
echo "   source ~/.zshrc  (또는 ~/.bashrc)"
echo ""
echo "2. dotfiles 모듈 설치 (권장 순서):"
echo "   cd ~/dotfiles/zsh && ./install.sh"
echo "   cd ~/dotfiles/kubectl && ./install.sh"
echo "   cd ~/dotfiles/kubectx && ./install.sh"
echo "   cd ~/dotfiles/nvim && ./install.sh"
echo ""
echo "3. 선택적 설치:"
echo "   cd ~/dotfiles/aws && ./install.sh     # AWS CLI 사용 시"
echo "   cd ~/dotfiles/vim && ./install.sh     # Vim 사용 시"
echo ""
echo "📚 자세한 내용:"
echo "   ~/dotfiles/README.md"
echo ""
