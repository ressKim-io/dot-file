#!/bin/bash

set -e

echo "=========================================="
echo "🐳 Docker 설치"
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

# Linux에서 필수 도구 체크 및 설치
if [ "$MACHINE" = "Linux" ]; then
  # 패키지 매니저로 기본 도구 설치 (없으면)
  if ! command -v curl &> /dev/null || ! command -v gpg &> /dev/null; then
    echo "📦 Docker 설치에 필요한 기본 도구 설치 중..."
    if command -v apt-get &> /dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y curl gnupg ca-certificates lsb-release 2>/dev/null || true
    elif command -v yum &> /dev/null; then
      sudo yum install -y curl gnupg2 ca-certificates 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y curl gnupg2 ca-certificates 2>/dev/null || true
    fi
  fi
fi

# ========================================
# Docker 설치 확인
# ========================================

if command -v docker &> /dev/null; then
  DOCKER_VERSION=$(docker --version)
  echo "✅ Docker 이미 설치됨: $DOCKER_VERSION"

  # Docker 서비스 상태 확인
  if docker info &> /dev/null; then
    echo "✅ Docker 서비스 실행 중"
  else
    echo "⚠️  Docker가 설치되어 있지만 실행되지 않았습니다."
    echo "   Mac: Docker Desktop을 실행하세요."
    echo "   Linux: sudo systemctl start docker"
  fi

  exit 0
fi

# ========================================
# Docker 설치
# ========================================

if [ "$MACHINE" = "Mac" ]; then
  echo "=========================================="
  echo "📥 Docker Desktop for Mac 설치"
  echo "=========================================="
  echo ""

  if command -v brew &> /dev/null; then
    echo "✅ Homebrew로 Docker Desktop 설치 중..."
    brew install --cask docker

    echo ""
    echo "=========================================="
    echo "✅ Docker Desktop 설치 완료!"
    echo "=========================================="
    echo ""
    echo "💡 다음 단계:"
    echo "   1. Applications 폴더에서 Docker.app을 실행하세요."
    echo "   2. Docker가 시작될 때까지 기다리세요 (상단바 고래 아이콘 확인)."
    echo "   3. 터미널에서 'docker --version'으로 확인하세요."
    echo ""
  else
    echo "❌ Homebrew가 설치되어 있지 않습니다."
    echo ""
    echo "수동 설치:"
    echo "   1. https://www.docker.com/products/docker-desktop/ 방문"
    echo "   2. Docker Desktop for Mac (Apple Silicon 또는 Intel) 다운로드"
    echo "   3. .dmg 파일 실행 후 Applications 폴더로 드래그"
    echo ""
    exit 1
  fi

elif [ "$MACHINE" = "Linux" ]; then
  echo "=========================================="
  echo "📥 Docker Engine for Linux 설치"
  echo "=========================================="
  echo ""

  # Ubuntu/Debian
  if command -v apt-get &> /dev/null; then
    echo "✅ Ubuntu/Debian 감지됨"
    echo ""

    # 기존 Docker 제거
    echo "📦 기존 Docker 패키지 제거 중..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # 의존성 설치
    echo "📦 의존성 설치 중..."
    sudo apt-get update
    sudo apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

    # Docker GPG 키 추가
    echo "🔑 Docker GPG 키 추가 중..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Docker 리포지토리 추가
    echo "📦 Docker 리포지토리 추가 중..."
    # lsb_release가 없을 경우 /etc/os-release에서 읽기
    if command -v lsb_release &> /dev/null; then
      DISTRO_CODENAME=$(lsb_release -cs)
    elif [ -f /etc/os-release ]; then
      DISTRO_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
    else
      echo "❌ 배포판 코드명을 확인할 수 없습니다."
      exit 1
    fi
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $DISTRO_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Docker 설치
    echo "📥 Docker Engine 설치 중..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Docker 서비스 시작
    echo "🚀 Docker 서비스 시작 중..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # 현재 사용자를 docker 그룹에 추가
    echo "👤 현재 사용자를 docker 그룹에 추가 중..."
    sudo usermod -aG docker $USER

    echo ""
    echo "=========================================="
    echo "✅ Docker 설치 완료!"
    echo "=========================================="
    echo ""
    echo "📚 설치된 버전:"
    docker --version
    echo ""
    echo "💡 중요:"
    echo "   - 로그아웃 후 다시 로그인하거나 다음 명령어 실행:"
    echo "     newgrp docker"
    echo "   - 그 후 'docker run hello-world'로 테스트하세요."
    echo ""

  # RHEL/CentOS/Fedora
  elif command -v yum &> /dev/null; then
    echo "✅ RHEL/CentOS/Fedora 감지됨"
    echo ""

    # 기존 Docker 제거
    echo "📦 기존 Docker 패키지 제거 중..."
    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true

    # 의존성 설치
    echo "📦 의존성 설치 중..."
    sudo yum install -y yum-utils

    # Docker 리포지토리 추가
    echo "📦 Docker 리포지토리 추가 중..."
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Docker 설치
    echo "📥 Docker Engine 설치 중..."
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Docker 서비스 시작
    echo "🚀 Docker 서비스 시작 중..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # 현재 사용자를 docker 그룹에 추가
    echo "👤 현재 사용자를 docker 그룹에 추가 중..."
    sudo usermod -aG docker $USER

    echo ""
    echo "=========================================="
    echo "✅ Docker 설치 완료!"
    echo "=========================================="
    echo ""
    echo "📚 설치된 버전:"
    docker --version
    echo ""
    echo "💡 중요:"
    echo "   - 로그아웃 후 다시 로그인하거나 다음 명령어 실행:"
    echo "     newgrp docker"
    echo "   - 그 후 'docker run hello-world'로 테스트하세요."
    echo ""

  else
    echo "❌ 지원하지 않는 Linux 배포판입니다."
    echo ""
    echo "수동 설치:"
    echo "   https://docs.docker.com/engine/install/"
    echo ""
    exit 1
  fi
fi
