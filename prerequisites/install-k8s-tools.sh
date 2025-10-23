#!/bin/bash

set -e

echo "=========================================="
echo "☸️  Kubernetes 도구 설치 (kubectl, helm)"
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
# 1. kubectl 설치
# ========================================

echo "=========================================="
echo "📦 kubectl 설치"
echo "=========================================="
echo ""

if command -v kubectl &> /dev/null; then
  KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | awk '{print $3}' || kubectl version --client -o json 2>/dev/null | grep gitVersion | awk -F'"' '{print $4}')
  echo "✅ kubectl 이미 설치됨: $KUBECTL_VERSION"
else
  echo "📥 최신 kubectl 버전 확인 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      echo "✅ Homebrew로 kubectl 설치 중..."
      brew install kubectl
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # 최신 stable 버전 자동 감지
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    echo "📥 kubectl $KUBECTL_VERSION 다운로드 중..."

    cd /tmp
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

    # 체크섬 검증
    echo "🔍 체크섬 검증 중..."
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

    # 설치
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl kubectl.sha256

    echo "✅ kubectl 설치 완료: $(kubectl version --client --short 2>/dev/null || echo $KUBECTL_VERSION)"
  fi
fi

echo ""

# ========================================
# 2. Helm 설치
# ========================================

echo "=========================================="
echo "📦 Helm 설치"
echo "=========================================="
echo ""

if command -v helm &> /dev/null; then
  HELM_VERSION=$(helm version --short)
  echo "✅ Helm 이미 설치됨: $HELM_VERSION"
else
  echo "📥 최신 Helm 버전 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      echo "✅ Homebrew로 Helm 설치 중..."
      brew install helm
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # 공식 설치 스크립트 사용
    echo "📥 Helm 공식 설치 스크립트 실행 중..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    echo "✅ Helm 설치 완료: $(helm version --short)"
  fi
fi

echo ""

# ========================================
# 3. kubectx + kubens 설치 (선택)
# ========================================

echo "=========================================="
echo "📦 kubectx + kubens 설치 (선택사항)"
echo "=========================================="
echo ""

if command -v kubectx &> /dev/null && command -v kubens &> /dev/null; then
  echo "✅ kubectx + kubens 이미 설치됨"
else
  read -p "kubectx + kubens를 설치하시겠습니까? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [ "$MACHINE" = "Mac" ]; then
      if command -v brew &> /dev/null; then
        echo "✅ Homebrew로 kubectx + kubens 설치 중..."
        brew install kubectx
      fi
    elif [ "$MACHINE" = "Linux" ]; then
      echo "📥 kubectx + kubens 다운로드 중..."

      # kubectx
      sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /usr/local/bin/kubectx
      sudo chmod +x /usr/local/bin/kubectx

      # kubens
      sudo curl -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /usr/local/bin/kubens
      sudo chmod +x /usr/local/bin/kubens

      echo "✅ kubectx + kubens 설치 완료"
    fi

    echo ""
    echo "💡 Tip:"
    echo "   - kubectx: 컨텍스트 빠른 전환"
    echo "   - kubens: 네임스페이스 빠른 전환"
    echo "   - 자세한 사용법은 ~/dotfiles/kubectx/README.md 참고"
  fi
fi

echo ""
echo "=========================================="
echo "✅ Kubernetes 도구 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 도구:"
command -v kubectl &> /dev/null && echo "   - kubectl: $(kubectl version --client --short 2>/dev/null | awk '{print $3}' || kubectl version --client -o json 2>/dev/null | grep gitVersion | awk -F'"' '{print $4}')"
command -v helm &> /dev/null && echo "   - helm: $(helm version --short)"
command -v kubectx &> /dev/null && echo "   - kubectx: $(kubectx --version 2>/dev/null || echo 'installed')"
command -v kubens &> /dev/null && echo "   - kubens: $(kubens --version 2>/dev/null || echo 'installed')"
echo ""
echo "🧪 테스트:"
echo "   kubectl version --client"
echo "   helm version"
echo ""
echo "💡 다음 단계:"
echo "   - kubectl 설정: ~/dotfiles/kubectl/install.sh"
echo "   - kubectx 설정: ~/dotfiles/kubectx/install.sh"
echo ""
