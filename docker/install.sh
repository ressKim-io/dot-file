#!/bin/bash

set -e

echo "=========================================="
echo "🐳 Docker 셸 단축어 설치"
echo "=========================================="
echo ""

# ========================================
# 1. Docker 설치 확인
# ========================================

if ! command -v docker &> /dev/null; then
  echo "❌ Docker가 설치되어 있지 않습니다."
  echo "   먼저 prerequisites/install-docker.sh를 실행하세요:"
  echo "     cd ../prerequisites && ./install-docker.sh"
  exit 1
fi

echo "✅ Docker 확인 완료: $(docker --version)"

if docker compose version &> /dev/null; then
  echo "✅ Docker Compose v2 확인: $(docker compose version --short 2>/dev/null || echo 'installed')"
else
  echo "⚠️  Docker Compose v2가 감지되지 않았습니다. dc 단축어가 동작하지 않을 수 있습니다."
fi
echo ""

# ========================================
# 2. 셸 감지
# ========================================

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ "$CURRENT_SHELL" = "bash" ]; then
  RC_FILE="$HOME/.bashrc"
else
  echo "❌ 지원하지 않는 쉘($CURRENT_SHELL). 수동 source:"
  echo "   source $(cd "$(dirname "$0")" && pwd)/docker-aliases.sh"
  exit 1
fi

echo "✅ 감지된 쉘: $CURRENT_SHELL ($RC_FILE)"
echo ""

# ========================================
# 3. .zshrc / .bashrc에 source 라인 추가
# ========================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ALIAS_FILE="$SCRIPT_DIR/docker-aliases.sh"
ALIAS_LINE="[ -f \"$ALIAS_FILE\" ] && source \"$ALIAS_FILE\""

if grep -q "docker-aliases.sh" "$RC_FILE"; then
  echo "✅ docker-aliases.sh가 이미 $RC_FILE에 등록되어 있습니다."
else
  BACKUP_RC="${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$RC_FILE" "$BACKUP_RC"
  echo "💾 $RC_FILE 백업: $BACKUP_RC"
  {
    echo ""
    echo "# ========================================"
    echo "# Docker 셸 단축어 (d/dc/dps 등)"
    echo "# ========================================"
    echo "$ALIAS_LINE"
  } >> "$RC_FILE"
  echo "✅ docker-aliases.sh를 $RC_FILE에 등록했습니다."
fi

echo ""
echo "=========================================="
echo "✅ Docker 모듈 설치 완료!"
echo "=========================================="
echo ""
echo "🔑 핵심 단축어:"
echo "   d / dps / dpsa / di      : docker / ps / ps -a / images"
echo "   dex <c>                  : docker exec -it"
echo "   dl <c> / dlf <c>         : logs / logs -f --tail=200"
echo "   dsh <c>                  : 컨테이너 진입 (bash 우선, sh fallback)"
echo "   dc / dcup / dcdown       : docker compose / up -d / down"
echo "   dclf                     : compose logs -f --tail=200"
echo "   drmall / drmidangling    : 컨테이너/이미지 일괄 정리 (확인 포함)"
echo "   ddisk / dprune / dprunea : 디스크 사용량 / 정리 / 전체 정리"
echo "   ddive <img>              : 이미지 레이어 분석 (dive 필요)"
echo ""
echo "🔄 즉시 적용:"
echo "   source $RC_FILE"
echo ""
echo "💡 lazydocker 사용 권장 (TUI):"
echo "   lazydocker"
echo ""
