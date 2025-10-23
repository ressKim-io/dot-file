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

echo "✅ 감지된 OS: $MACHINE"
echo ""

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
    # HashiCorp GPG 키 추가
    echo "🔑 HashiCorp GPG 키 추가 중..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    # HashiCorp 리포지토리 추가
    echo "📦 HashiCorp 리포지토리 추가 중..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    # Terraform 설치
    echo "📥 Terraform 설치 중..."
    sudo apt-get update
    sudo apt-get install -y terraform

    echo "✅ Terraform 설치 완료: $(terraform --version | head -n 1)"
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
    # 최신 버전 자동 감지
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "📥 yq v${YQ_VERSION} 다운로드 중..."

    sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
    sudo chmod +x /usr/local/bin/yq

    echo "✅ yq 설치 완료: $(yq --version)"
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
    elif command -v pip3 &> /dev/null; then
      pip3 install --user yamllint
    else
      echo "⚠️  yamllint 설치 실패: apt-get 또는 pip3가 필요합니다."
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
    # 최신 버전 자동 감지
    HADOLINT_VERSION=$(curl -s https://api.github.com/repos/hadolint/hadolint/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    echo "📥 hadolint v${HADOLINT_VERSION} 다운로드 중..."

    sudo wget -qO /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64"
    sudo chmod +x /usr/local/bin/hadolint

    echo "✅ hadolint 설치 완료: $(hadolint --version)"
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
      sudo apt-get install -y wget apt-transport-https gnupg lsb-release
      wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
      echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
      sudo apt-get update
      sudo apt-get install -y trivy
    fi
    echo "✅ trivy 설치 완료"
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
