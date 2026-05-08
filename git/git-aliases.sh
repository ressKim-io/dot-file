#!/bin/bash
# git 셸 단축어 및 함수

# ========================================
# git 셸 단축어 (aliases.sh)
# ========================================
# .zshrc / .bashrc 에서 source 하여 사용합니다.
# 짧은 명령어로 자주 쓰는 git 워크플로를 빠르게 실행합니다.

# --- 기본 ---
alias g='git'
alias gst='git status'
alias gss='git status -s'        # short status

# --- 브랜치 ---
alias gb='git branch'
alias gba='git branch -a'         # 원격 포함
alias gco='git checkout'
alias gcb='git checkout -b'       # 새 브랜치 생성+체크아웃
alias gsw='git switch'
alias gswc='git switch -c'

# --- diff/log ---
alias gd='git diff'
alias gds='git diff --staged'     # staged 영역
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -30'
alias glast='git log -1 HEAD --stat'

# --- staging/commit ---
alias ga='git add'
alias gap='git add -p'            # patch 단위
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gun='git restore --staged'  # unstage

# --- remote / sync ---
alias gp='git push'
alias gpf='git push --force-with-lease'  # 안전한 force (--force 대체)
alias gpl='git pull'
alias gf='git fetch'
alias gfa='git fetch --all --prune'

# --- rebase / merge ---
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

# --- stash ---
alias gsta='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# --- 정리 ---
alias gclean='git clean -fd'      # untracked 파일 삭제 (주의)

# --- 함수: 현재 브랜치 이름 출력 ---
gcurrent() {
  git rev-parse --abbrev-ref HEAD
}

# --- 함수: 현재 브랜치를 origin으로 push (upstream 자동 설정) ---
gpu() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push -u origin "$branch"
}

# --- 함수: main/master 브랜치 자동 감지 + 체크아웃 ---
gmain() {
  if git show-ref --verify --quiet refs/heads/main; then
    git checkout main
  elif git show-ref --verify --quiet refs/heads/master; then
    git checkout master
  else
    echo "main/master 브랜치가 없습니다."
    return 1
  fi
}

# --- 함수: 머지된 로컬 브랜치 일괄 삭제 (main/master 제외) ---
gprune() {
  local default_branch
  if git show-ref --verify --quiet refs/heads/main; then
    default_branch="main"
  else
    default_branch="master"
  fi
  git branch --merged "$default_branch" \
    | grep -v -E "^\*|^\s*${default_branch}\s*$" \
    | xargs -n 1 git branch -d 2>/dev/null
  echo "✅ ${default_branch}에 머지된 로컬 브랜치 정리 완료"
}
