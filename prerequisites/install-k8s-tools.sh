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

# 아키텍처 감지
ARCH=$(uname -m)
case $ARCH in
  x86_64) ARCH_SUFFIX="amd64" ;;
  aarch64|arm64) ARCH_SUFFIX="arm64" ;;
  *) ARCH_SUFFIX="amd64" ;;
esac

echo "✅ 감지된 OS: $MACHINE ($ARCH)"
echo ""

# Fallback 버전 (API 실패 시 사용)
FALLBACK_KUBECTL_VERSION="v1.36.0"

# 필수 도구 체크 및 설치
if [ "$MACHINE" = "Linux" ]; then
  if ! command -v curl &> /dev/null; then
    echo "📦 curl 설치 중..."
    if command -v apt-get &> /dev/null; then
      sudo apt-get update -qq && sudo apt-get install -y curl
    elif command -v yum &> /dev/null; then
      sudo yum install -y curl
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y curl
    else
      echo "❌ curl이 필요합니다. 먼저 설치해주세요."
      exit 1
    fi
  fi
fi

# ========================================
# 1. kubectl 설치
# ========================================

echo "=========================================="
echo "📦 kubectl 설치"
echo "=========================================="
echo ""

if command -v kubectl &> /dev/null; then
  KUBECTL_VERSION=$(kubectl version --client -o json 2>/dev/null | grep gitVersion | awk -F'"' '{print $4}')
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
    # 최신 stable 버전 자동 감지 (실패 시 fallback 사용)
    KUBECTL_VERSION=$(curl -L -s --connect-timeout 10 https://dl.k8s.io/release/stable.txt)
    if [ -z "$KUBECTL_VERSION" ] || [[ ! "$KUBECTL_VERSION" =~ ^v ]]; then
      echo "⚠️  kubectl 버전 확인 실패, fallback 버전 사용: $FALLBACK_KUBECTL_VERSION"
      KUBECTL_VERSION="$FALLBACK_KUBECTL_VERSION"
    fi
    echo "📥 kubectl $KUBECTL_VERSION 다운로드 중..."

    cd /tmp
    if ! curl -LO --fail "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH_SUFFIX}/kubectl"; then
      echo "❌ kubectl 다운로드 실패"
      echo "   수동 설치: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
      exit 1
    fi
    curl -LO --fail "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH_SUFFIX}/kubectl.sha256"

    # 체크섬 검증
    echo "🔍 체크섬 검증 중..."
    if ! echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check; then
      echo "❌ 체크섬 검증 실패"
      rm -f kubectl kubectl.sha256
      exit 1
    fi

    # 설치
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl kubectl.sha256

    echo "✅ kubectl 설치 완료: $(kubectl version --client -o json 2>/dev/null | grep gitVersion | awk -F'\"' '{print $4}' || echo $KUBECTL_VERSION)"
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
    if ! curl --fail https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; then
      echo "❌ Helm 설치 실패"
      echo "   수동 설치: https://helm.sh/docs/intro/install/"
      exit 1
    fi

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

# ========================================
# 4. k9s 설치 (터미널 Kubernetes UI)
# ========================================

echo "=========================================="
echo "📦 k9s 설치 (Kubernetes 터미널 UI)"
echo "=========================================="
echo ""

if command -v k9s &> /dev/null; then
  echo "✅ k9s 이미 설치됨: $(k9s version -s 2>/dev/null | head -n 1 || echo installed)"
else
  echo "📥 k9s 설치 중..."
  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install k9s
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    ARCH=$(uname -m)
    case $ARCH in
      x86_64) K9S_ARCH="amd64" ;;
      aarch64|arm64) K9S_ARCH="arm64" ;;
      *) K9S_ARCH="amd64" ;;
    esac
    K9S_VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | sed -E 's/.*"(v[^"]+)".*/\1/')
    [ -z "$K9S_VERSION" ] && K9S_VERSION="v0.50.9"
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${K9S_ARCH}.tar.gz" -o "$TMPDIR/k9s.tar.gz"; then
      tar -xzf "$TMPDIR/k9s.tar.gz" -C "$TMPDIR"
      sudo install -m 0755 "$TMPDIR/k9s" /usr/local/bin/k9s
      echo "✅ k9s 설치 완료: $K9S_VERSION"
    else
      echo "⚠️  k9s 다운로드 실패, 수동 설치가 필요합니다."
    fi
    rm -rf "$TMPDIR"
  fi
fi

echo ""

# ========================================
# 5. stern 설치 (다중 Pod 로그 tail)
# ========================================

echo "=========================================="
echo "📦 stern 설치 (다중 Pod 로그 tail)"
echo "=========================================="
echo ""

if command -v stern &> /dev/null; then
  echo "✅ stern 이미 설치됨"
else
  echo "📥 stern 설치 중..."
  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install stern
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    ARCH=$(uname -m)
    case $ARCH in
      x86_64) STERN_ARCH="amd64" ;;
      aarch64|arm64) STERN_ARCH="arm64" ;;
      *) STERN_ARCH="amd64" ;;
    esac
    STERN_VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/stern/stern/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    [ -z "$STERN_VERSION" ] && STERN_VERSION="1.32.0"
    TMPDIR=$(mktemp -d)
    if curl -fsSL "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_${STERN_ARCH}.tar.gz" -o "$TMPDIR/stern.tar.gz"; then
      tar -xzf "$TMPDIR/stern.tar.gz" -C "$TMPDIR"
      sudo install -m 0755 "$TMPDIR/stern" /usr/local/bin/stern
      echo "✅ stern 설치 완료: v$STERN_VERSION"
    else
      echo "⚠️  stern 다운로드 실패, 수동 설치가 필요합니다."
    fi
    rm -rf "$TMPDIR"
  fi
fi

echo ""
echo "=========================================="
echo "✅ Kubernetes 도구 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 도구:"
command -v kubectl &> /dev/null && echo "   - kubectl: $(kubectl version --client -o json 2>/dev/null | grep gitVersion | awk -F'"' '{print $4}')"
command -v helm &> /dev/null && echo "   - helm: $(helm version --short)"
command -v kubectx &> /dev/null && echo "   - kubectx: $(kubectx --version 2>/dev/null || echo 'installed')"
command -v kubens &> /dev/null && echo "   - kubens: $(kubens --version 2>/dev/null || echo 'installed')"
command -v k9s &> /dev/null && echo "   - k9s: installed"
command -v stern &> /dev/null && echo "   - stern: installed"
echo ""
echo "🧪 테스트:"
echo "   kubectl version --client"
echo "   helm version"
echo ""
echo "💡 다음 단계:"
echo "   - kubectl 설정: ~/dotfiles/kubectl/install.sh"
echo "   - kubectx 설정: ~/dotfiles/kubectx/install.sh"
echo ""
