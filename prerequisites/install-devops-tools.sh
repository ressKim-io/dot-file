#!/bin/bash

set -e

echo "=========================================="
echo "🔧 DevOps 도구 설치"
echo "   (terraform, jq, yq, yamllint, hadolint)"
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
  x86_64) ARCH_SUFFIX="amd64"; ARCH_SUFFIX_HADOLINT="x86_64" ;;
  aarch64|arm64) ARCH_SUFFIX="arm64"; ARCH_SUFFIX_HADOLINT="arm64" ;;
  *) ARCH_SUFFIX="amd64"; ARCH_SUFFIX_HADOLINT="x86_64" ;;
esac

echo "✅ 감지된 OS: $MACHINE ($ARCH)"
echo ""

# Fallback 버전 (API 실패 시 사용)
FALLBACK_YQ_VERSION="4.52.2"
FALLBACK_HADOLINT_VERSION="2.14.0"

# Linux에서 필수 도구 체크 및 설치
if [ "$MACHINE" = "Linux" ]; then
  MISSING_TOOLS=""
  command -v curl &> /dev/null || MISSING_TOOLS="$MISSING_TOOLS curl"
  command -v wget &> /dev/null || MISSING_TOOLS="$MISSING_TOOLS wget"
  command -v gpg &> /dev/null || MISSING_TOOLS="$MISSING_TOOLS gnupg"

  if [ -n "$MISSING_TOOLS" ]; then
    echo "📦 필수 도구 설치 중:$MISSING_TOOLS"
    if command -v apt-get &> /dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y curl wget gnupg lsb-release ca-certificates 2>/dev/null || true
    elif command -v yum &> /dev/null; then
      sudo yum install -y curl wget gnupg2 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y curl wget gnupg2 2>/dev/null || true
    fi
  fi
fi

# 배포판 코드명 가져오기 (lsb_release 또는 /etc/os-release)
get_distro_codename() {
  if command -v lsb_release &> /dev/null; then
    lsb_release -cs
  elif [ -f /etc/os-release ]; then
    . /etc/os-release && echo "$VERSION_CODENAME"
  else
    echo "unknown"
  fi
}

# HashiCorp apt 저장소가 지원하는 코드명으로 매핑 (미지원 신규 배포판은 가장 가까운 LTS로 fallback)
# HashiCorp 공식 지원: focal, jammy, noble, bullseye, bookworm
map_to_hashicorp_codename() {
  local codename="$1"
  case "$codename" in
    focal|jammy|noble|bullseye|bookworm)
      echo "$codename"
      ;;
    # Ubuntu 신버전 (oracular, plucky, questing 등) → noble (24.04 LTS)로 매핑
    oracular|plucky|questing|resolute)
      echo "noble"
      ;;
    # Debian trixie (13) 등 신버전 → bookworm으로 매핑
    trixie|forky)
      echo "bookworm"
      ;;
    *)
      # 알 수 없는 경우 가장 보수적인 jammy로 fallback
      echo "jammy"
      ;;
  esac
}

# ========================================
# 1. Terraform 설치
# ========================================

echo "=========================================="
echo "📦 Terraform 설치"
echo "=========================================="
echo ""

if command -v terraform &> /dev/null; then
  TERRAFORM_VERSION=$(terraform --version | head -n 1)
  echo "✅ Terraform 이미 설치됨: $TERRAFORM_VERSION"
else
  echo "📥 최신 Terraform 버전 확인 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      echo "✅ Homebrew로 Terraform 설치 중..."
      brew tap hashicorp/tap
      brew install hashicorp/tap/terraform
    else
      echo "❌ Homebrew가 설치되어 있지 않습니다."
      exit 1
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      # HashiCorp GPG 키 추가
      echo "🔑 HashiCorp GPG 키 추가 중..."
      if ! wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null; then
        # wget 실패 시 curl 사용
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      fi

      # HashiCorp 리포지토리 추가
      echo "📦 HashiCorp 리포지토리 추가 중..."
      RAW_CODENAME=$(get_distro_codename)
      HC_CODENAME=$(map_to_hashicorp_codename "$RAW_CODENAME")
      if [ "$HC_CODENAME" != "$RAW_CODENAME" ]; then
        echo "ℹ️  $RAW_CODENAME은 HashiCorp 공식 지원 목록에 없어 $HC_CODENAME 패키지를 사용합니다."
      fi
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $HC_CODENAME main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

      # Terraform 설치
      echo "📥 Terraform 설치 중..."
      sudo apt-get update
      sudo apt-get install -y terraform

      echo "✅ Terraform 설치 완료: $(terraform --version | head -n 1)"
    elif command -v yum &> /dev/null; then
      # RHEL/CentOS용 설치
      echo "📦 HashiCorp 리포지토리 추가 중..."
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum install -y terraform
      echo "✅ Terraform 설치 완료: $(terraform --version | head -n 1)"
    elif command -v dnf &> /dev/null; then
      # Fedora용 설치
      echo "📦 HashiCorp 리포지토리 추가 중..."
      sudo dnf install -y dnf-plugins-core
      sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
      sudo dnf install -y terraform
      echo "✅ Terraform 설치 완료: $(terraform --version | head -n 1)"
    else
      echo "⚠️  Terraform 자동 설치를 지원하지 않는 배포판입니다."
      echo "   수동 설치: https://developer.hashicorp.com/terraform/downloads"
    fi
  fi
fi

echo ""

# ========================================
# 1.5. OpenTofu 설치 (Terraform 오픈소스 포크)
# ========================================

echo "=========================================="
echo "📦 OpenTofu 설치 (Terraform 오픈소스 포크)"
echo "=========================================="
echo ""

if command -v tofu &> /dev/null; then
  echo "✅ OpenTofu 이미 설치됨: $(tofu --version | head -n 1)"
else
  echo "📥 OpenTofu 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install opentofu
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # OpenTofu 공식 설치 스크립트 (가장 신뢰할 수 있음)
    TMPSCRIPT=$(mktemp)
    if curl -fsSL https://get.opentofu.org/install-opentofu.sh -o "$TMPSCRIPT"; then
      chmod +x "$TMPSCRIPT"
      # 설치 방식: standalone (deb/rpm 의존성 피함)
      if "$TMPSCRIPT" --install-method standalone --install-path /usr/local/bin --skip-verify 2>/dev/null; then
        echo "✅ OpenTofu 설치 완료: $(tofu --version | head -n 1)"
      else
        # 폴백: GitHub 릴리스 직접 다운로드
        ARCH=$(uname -m)
        case $ARCH in
          x86_64) TOFU_ARCH="amd64" ;;
          aarch64|arm64) TOFU_ARCH="arm64" ;;
          *) TOFU_ARCH="amd64" ;;
        esac
        TOFU_VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/opentofu/opentofu/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        [ -z "$TOFU_VERSION" ] && TOFU_VERSION="1.10.6"
        TMPDIR=$(mktemp -d)
        if curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${TOFU_ARCH}.zip" -o "$TMPDIR/tofu.zip"; then
          (cd "$TMPDIR" && unzip -qo tofu.zip && sudo install -m 0755 tofu /usr/local/bin/tofu)
          echo "✅ OpenTofu 설치 완료: v$TOFU_VERSION"
        fi
        rm -rf "$TMPDIR"
      fi
    fi
    rm -f "$TMPSCRIPT"
  fi
fi

echo ""

# ========================================
# 2. jq 설치 (JSON 파싱)
# ========================================

echo "=========================================="
echo "📦 jq 설치 (JSON 파싱)"
echo "=========================================="
echo ""

if command -v jq &> /dev/null; then
  JQ_VERSION=$(jq --version)
  echo "✅ jq 이미 설치됨: $JQ_VERSION"
else
  echo "📥 jq 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install jq
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y jq
    elif command -v yum &> /dev/null; then
      sudo yum install -y jq
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm jq
    fi
  fi

  echo "✅ jq 설치 완료: $(jq --version)"
fi

echo ""

# ========================================
# 3. yq 설치 (YAML 파싱)
# ========================================

echo "=========================================="
echo "📦 yq 설치 (YAML 파싱)"
echo "=========================================="
echo ""

if command -v yq &> /dev/null; then
  YQ_VERSION=$(yq --version 2>&1 | head -n 1)
  echo "✅ yq 이미 설치됨: $YQ_VERSION"
else
  echo "📥 최신 yq 버전 확인 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      echo "✅ Homebrew로 yq 설치 중..."
      brew install yq
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # 최신 버전 자동 감지 (실패 시 fallback 사용)
    YQ_VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -z "$YQ_VERSION" ]; then
      echo "⚠️  yq 버전 확인 실패, fallback 버전 사용: $FALLBACK_YQ_VERSION"
      YQ_VERSION="$FALLBACK_YQ_VERSION"
    fi
    echo "📥 yq v${YQ_VERSION} 다운로드 중..."

    if ! sudo curl -L --fail -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH_SUFFIX}"; then
      echo "❌ yq 다운로드 실패"
      echo "   수동 설치: https://github.com/mikefarah/yq#install"
    else
      sudo chmod +x /usr/local/bin/yq
      echo "✅ yq 설치 완료: $(yq --version)"
    fi
  fi
fi

echo ""

# ========================================
# 4. yamllint 설치 (YAML 린터)
# ========================================

echo "=========================================="
echo "📦 yamllint 설치 (YAML 린터)"
echo "=========================================="
echo ""

if command -v yamllint &> /dev/null; then
  YAMLLINT_VERSION=$(yamllint --version)
  echo "✅ yamllint 이미 설치됨: $YAMLLINT_VERSION"
else
  echo "📥 yamllint 설치 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      brew install yamllint
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y yamllint
    elif command -v pipx &> /dev/null; then
      pipx install yamllint
    elif command -v pip3 &> /dev/null; then
      # Ubuntu 24.04+는 PEP 668로 pip3 install --user이 차단됨
      # pipx가 없으면 pipx 설치를 시도하고, 실패 시에만 최후 수단으로 --break-system-packages 사용
      if command -v apt-get &> /dev/null; then
        sudo apt-get install -y pipx && pipx install yamllint
      else
        echo "⚠️  pipx가 없어 pip3 --break-system-packages로 설치합니다."
        pip3 install --user --break-system-packages yamllint 2>/dev/null || pip3 install --user yamllint
      fi
    else
      echo "⚠️  yamllint 설치 실패: apt-get 또는 pipx가 필요합니다."
    fi
  fi

  if command -v yamllint &> /dev/null; then
    echo "✅ yamllint 설치 완료: $(yamllint --version)"
  fi
fi

echo ""

# ========================================
# 5. hadolint 설치 (Dockerfile 린터)
# ========================================

echo "=========================================="
echo "📦 hadolint 설치 (Dockerfile 린터)"
echo "=========================================="
echo ""

if command -v hadolint &> /dev/null; then
  HADOLINT_VERSION=$(hadolint --version | head -n 1)
  echo "✅ hadolint 이미 설치됨: $HADOLINT_VERSION"
else
  echo "📥 최신 hadolint 버전 확인 중..."

  if [ "$MACHINE" = "Mac" ]; then
    if command -v brew &> /dev/null; then
      echo "✅ Homebrew로 hadolint 설치 중..."
      brew install hadolint
    fi
  elif [ "$MACHINE" = "Linux" ]; then
    # 최신 버전 자동 감지 (실패 시 fallback 사용)
    HADOLINT_VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/hadolint/hadolint/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -z "$HADOLINT_VERSION" ]; then
      echo "⚠️  hadolint 버전 확인 실패, fallback 버전 사용: $FALLBACK_HADOLINT_VERSION"
      HADOLINT_VERSION="$FALLBACK_HADOLINT_VERSION"
    fi
    echo "📥 hadolint v${HADOLINT_VERSION} 다운로드 중..."

    if ! sudo curl -L --fail -o /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-${ARCH_SUFFIX_HADOLINT}"; then
      echo "❌ hadolint 다운로드 실패"
      echo "   수동 설치: https://github.com/hadolint/hadolint#install"
    else
      sudo chmod +x /usr/local/bin/hadolint
      echo "✅ hadolint 설치 완료: $(hadolint --version)"
    fi
  fi
fi

echo ""

# ========================================
# 6. 추가 도구 (선택)
# ========================================

echo "=========================================="
echo "📦 추가 도구 설치 (선택사항)"
echo "=========================================="
echo ""

read -p "추가 DevOps 도구를 설치하시겠습니까? (tflint, trivy) (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # tflint (Terraform 린터)
  if ! command -v tflint &> /dev/null; then
    echo "📥 tflint 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
      brew install tflint
    elif [ "$MACHINE" = "Linux" ]; then
      curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    fi
    echo "✅ tflint 설치 완료"
  else
    echo "✅ tflint 이미 설치됨"
  fi

  # trivy (보안 스캐너)
  if ! command -v trivy &> /dev/null; then
    echo "📥 trivy 설치 중..."
    if [ "$MACHINE" = "Mac" ]; then
      brew install aquasecurity/trivy/trivy
    elif [ "$MACHINE" = "Linux" ]; then
      if command -v apt-get &> /dev/null; then
        sudo apt-get install -y wget apt-transport-https gnupg 2>/dev/null || true
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor --yes -o /usr/share/keyrings/trivy.gpg
        # 주의: Trivy repo는 distro 코드명이 아닌 "generic"을 사용함 (공식 문서 기준)
        # tee -a로 append하면 재실행 시 중복되므로 tee로 overwrite
        echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y trivy
      else
        echo "⚠️  trivy 자동 설치는 Ubuntu/Debian에서만 지원됩니다."
        echo "   수동 설치: https://trivy.dev/docs/latest/getting-started/installation/"
      fi
    fi
    if command -v trivy &> /dev/null; then
      echo "✅ trivy 설치 완료"
    fi
  else
    echo "✅ trivy 이미 설치됨"
  fi
fi

echo ""
echo "=========================================="
echo "✅ DevOps 도구 설치 완료!"
echo "=========================================="
echo ""
echo "📚 설치된 도구:"
command -v terraform &> /dev/null && echo "   - terraform: $(terraform --version | head -n 1 | awk '{print $2}')"
command -v jq &> /dev/null && echo "   - jq: $(jq --version)"
command -v yq &> /dev/null && echo "   - yq: $(yq --version | head -n 1)"
command -v yamllint &> /dev/null && echo "   - yamllint: $(yamllint --version)"
command -v hadolint &> /dev/null && echo "   - hadolint: $(hadolint --version | head -n 1)"
command -v tflint &> /dev/null && echo "   - tflint: $(tflint --version | head -n 1)"
command -v trivy &> /dev/null && echo "   - trivy: $(trivy --version | head -n 1)"
echo ""
echo "🧪 테스트:"
echo "   terraform --version"
echo "   echo '{\"name\":\"test\"}' | jq '.name'"
echo "   echo 'name: test' | yq '.name'"
echo "   yamllint --version"
echo "   hadolint --version"
echo ""
