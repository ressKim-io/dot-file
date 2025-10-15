#!/bin/bash

set -e

echo "=========================================="
echo "🚀 kubectl 생산성 설정 시작"
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

# kubectl 설치 확인
if ! command -v kubectl &> /dev/null; then
  echo "❌ kubectl이 설치되어 있지 않습니다."
  echo ""
  echo "설치 가이드:"
  echo "  https://kubernetes.io/docs/tasks/tools/"
  exit 1
fi

echo "✅ kubectl 확인 완료"
echo ""

# bash-completion 확인 (bash만)
if [ "$SHELL_TYPE" = "bash" ]; then
  if ! dpkg -l 2>/dev/null | grep -q bash-completion && ! rpm -q bash-completion &> /dev/null; then
    echo "📦 bash-completion이 필요합니다."
    echo ""
    read -p "bash-completion을 설치하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y bash-completion
      elif command -v yum &> /dev/null; then
        sudo yum install -y bash-completion
      else
        echo "❌ 패키지 매니저를 찾을 수 없습니다."
        echo "   수동으로 bash-completion을 설치해주세요."
        exit 1
      fi
    else
      echo "❌ bash-completion 없이는 자동완성이 작동하지 않을 수 있습니다."
      exit 1
    fi
  fi
  echo "✅ bash-completion 확인 완료"
  echo ""
fi

# 백업
BACKUP_FILE="${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$RC_FILE" "$BACKUP_FILE"
echo "💾 백업 완료: $BACKUP_FILE"
echo ""

# 이미 설정되어 있는지 확인
if grep -q "kubectl completion" "$RC_FILE"; then
  echo "⚠️  이미 kubectl 설정이 존재합니다."
  echo ""
  read -p "덮어쓰시겠습니까? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 설치 취소"
    exit 1
  fi
  # 기존 설정 제거
  sed -i.bak '/# kubectl 생산성 설정/,/# ========================================$/d' "$RC_FILE"
fi

# 설정 추가
echo "📝 설정 파일에 추가 중..."
cat >> "$RC_FILE" << 'EOF'

# ========================================
# kubectl 생산성 설정
# ========================================

EOF

if [ "$SHELL_TYPE" = "zsh" ]; then
  cat >> "$RC_FILE" << 'EOF'
# kubectl 자동완성
source <(kubectl completion zsh)

EOF
else
  cat >> "$RC_FILE" << 'EOF'
# kubectl 자동완성
source <(kubectl completion bash)

EOF
fi

cat >> "$RC_FILE" << 'EOF'
# kubectl alias
alias k=kubectl
complete -F __start_kubectl k

# 확장 alias
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kdel='kubectl delete'

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
echo "   k version"
echo "   k get p[Tab]  # 자동완성 확인"
echo ""

# 적용 여부 확인
read -p "지금 바로 적용하시겠습니까? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  if [ "$SHELL_TYPE" = "zsh" ]; then
    echo "✅ 적용 중..."
    exec zsh
  else
    echo "✅ 적용 중..."
    exec bash
  fi
fi
