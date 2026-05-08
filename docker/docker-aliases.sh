#!/bin/bash
# Docker / Docker Compose 셸 단축어 및 함수

# ========================================
# 기본
# ========================================
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dst='docker stats'

# ========================================
# 컨테이너 라이프사이클
# ========================================
alias dr='docker run'
alias drd='docker run -d'
alias drm='docker rm'
alias drmf='docker rm -f'           # 강제 삭제 (실행 중도)
alias dstart='docker start'
alias dstop='docker stop'
alias dres='docker restart'

# ========================================
# 로그 / exec
# ========================================
alias dl='docker logs'
alias dlf='docker logs -f --tail=200'
alias dex='docker exec -it'

# ========================================
# 이미지
# ========================================
alias dpull='docker pull'
alias dpush='docker push'
alias drmi='docker rmi'
alias dbuild='docker build'
alias dbuildt='docker build -t'

# ========================================
# 네트워크 / 볼륨
# ========================================
alias dnet='docker network'
alias dvol='docker volume'
alias dnetls='docker network ls'
alias dvolls='docker volume ls'

# ========================================
# 시스템 / 정리
# ========================================
alias dprune='docker system prune'
alias dprunea='docker system prune -a --volumes'    # 전체 정리 (주의)
alias dinfo='docker info'
alias dversion='docker version'

# ========================================
# Docker Compose (v2: docker compose)
# ========================================
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dcps='docker compose ps'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f --tail=200'
alias dcb='docker compose build'
alias dcr='docker compose restart'
alias dcpull='docker compose pull'
alias dcconfig='docker compose config'              # 합성 설정 검증

# ========================================
# 함수
# ========================================

# 컨테이너 안으로 진입 (bash 우선, 없으면 sh)
dsh() {
  if [ -z "$1" ]; then
    echo "사용법: dsh <container_id_or_name>"
    return 1
  fi
  docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
}

# 모든 컨테이너 제거 (확인 후)
drmall() {
  local count
  count=$(docker ps -aq | wc -l | tr -d ' ')
  if [ "$count" = "0" ]; then
    echo "삭제할 컨테이너가 없습니다."
    return 0
  fi
  echo "⚠️  $count개 컨테이너를 모두 삭제합니다."
  docker ps -a --format "  - {{.Names}} ({{.Status}})"
  read -r -p "정말 삭제하시겠습니까? (y/N): " confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    docker rm -f "$(docker ps -aq)"
    echo "✅ 삭제 완료"
  else
    echo "❌ 취소"
  fi
}

# dangling 이미지 제거
drmidangling() {
  local dangling
  dangling=$(docker images -f "dangling=true" -q)
  if [ -z "$dangling" ]; then
    echo "dangling 이미지가 없습니다."
    return 0
  fi
  echo "$dangling" | xargs docker rmi
}

# 컨테이너 IP 조회
dip() {
  if [ -z "$1" ]; then
    echo "사용법: dip <container_id_or_name>"
    return 1
  fi
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

# 이미지 레이어 분석 (dive 설치 시)
ddive() {
  if ! command -v dive &> /dev/null; then
    echo "❌ dive가 설치되어 있지 않습니다. prerequisites/install-modern-cli.sh 참고."
    return 1
  fi
  if [ -z "$1" ]; then
    echo "사용법: ddive <image>"
    return 1
  fi
  dive "$1"
}

# 디스크 사용량 요약
ddisk() {
  docker system df
  echo ""
  echo "💡 정리: dprune (안전) | dprunea (전체, 주의)"
}
