#!/bin/bash

set -e

echo "=========================================="
echo "☁️  AWS CLI 생산성 설정 시작"
echo "=========================================="
echo ""

# 쉘 감지
CURRENT_SHELL=$(basename "$SHELL")

if [ "$CURRENT_SHELL" = "zsh" ]; then
  SHELL_TYPE="zsh"
  RC_FILE="$HOME/.zshrc"
elif [ "$CURRENT_SHELL" = "bash" ]; then
  SHELL_TYPE="bash"
  RC_FILE="$HOME/.bashrc"
else
  echo "❌ 지원하지 않는 쉘입니다."
  echo "   지원 쉘: zsh, bash"
  echo "   현재 쉘: $CURRENT_SHELL"
  exit 1
fi

echo "✅ 감지된 쉘: $SHELL_TYPE"
echo "✅ 설정 파일: $RC_FILE"
echo ""

# AWS CLI 설치 확인
if ! command -v aws &> /dev/null; then
  echo "⚠️  AWS CLI가 설치되어 있지 않습니다."
  echo ""
  echo "AWS CLI 설치 가이드:"
  echo "  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  echo ""
  read -p "AWS CLI 없이 설정만 진행하시겠습니까? (Y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "❌ 설치 취소"
    exit 1
  fi
else
  AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1)
  echo "✅ AWS CLI 확인 완료: $AWS_VERSION"
fi

echo ""

# aws-aliases.sh 경로 설정
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AWS_ALIASES_FILE="$SCRIPT_DIR/aws-aliases.sh"

if [ ! -f "$AWS_ALIASES_FILE" ]; then
  echo "❌ aws-aliases.sh 파일을 찾을 수 없습니다."
  echo "   경로: $AWS_ALIASES_FILE"
  exit 1
fi

echo "✅ AWS aliases 파일 확인: $AWS_ALIASES_FILE"
echo ""

# 백업
BACKUP_FILE="${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$RC_FILE" "$BACKUP_FILE"
echo "💾 백업 완료: $BACKUP_FILE"
echo ""

# 이미 설정되어 있는지 확인
if grep -q "AWS CLI 생산성 설정" "$RC_FILE"; then
  echo "⚠️  이미 AWS CLI 설정이 존재합니다."
  echo ""
  read -p "덮어쓰시겠습니까? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 설치 취소"
    exit 1
  fi
  # 기존 설정 제거
  sed -i.bak '/# AWS CLI 생산성 설정/,/# ========================================$/d' "$RC_FILE"
fi

# 설정 추가
echo "📝 설정 파일에 추가 중..."
cat >> "$RC_FILE" << EOF

# ========================================
# AWS CLI 생산성 설정
# ========================================
if [ -f "$AWS_ALIASES_FILE" ]; then
  source "$AWS_ALIASES_FILE"
fi
# ========================================
EOF

echo ""
echo "=========================================="
echo "✅ 설치 완료!"
echo "=========================================="
echo ""
echo "🔄 다음 명령어로 적용:"
echo "   source $RC_FILE"
echo ""
echo "🧪 테스트:"
echo "   awswho          # AWS 계정 확인"
echo "   ec2ls           # EC2 목록"
echo "   eip-unused      # 사용 안 하는 EIP"
echo ""
echo "📚 전체 명령어 목록:"
echo "   cat $AWS_ALIASES_FILE"
echo ""

# 적용 여부 확인
read -p "지금 바로 적용하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  echo "✅ 적용 중..."
  if [ "$SHELL_TYPE" = "zsh" ]; then
    exec zsh
  else
    exec bash
  fi
fi
