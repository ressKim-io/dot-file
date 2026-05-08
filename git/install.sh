#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Git 글로벌 설정 시작"
echo "=========================================="
echo ""

# ========================================
# 1. git 설치 확인
# ========================================

if ! command -v git &> /dev/null; then
  echo "❌ git이 설치되어 있지 않습니다. prerequisites/install.sh를 먼저 실행하세요."
  exit 1
fi

echo "✅ git 확인 완료: $(git --version)"
echo ""

# ========================================
# 2. 백업
# ========================================

GITCONFIG="$HOME/.gitconfig"
if [ -f "$GITCONFIG" ]; then
  BACKUP_FILE="${GITCONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$GITCONFIG" "$BACKUP_FILE"
  echo "💾 .gitconfig 백업: $BACKUP_FILE"
fi

# ========================================
# 3. user.name / user.email 확인 (없을 때만 안내)
# ========================================

GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
  echo ""
  echo "⚠️  user.name 또는 user.email이 설정되어 있지 않습니다."
  echo "   다음 명령으로 직접 설정하세요:"
  echo "     git config --global user.name \"Your Name\""
  echo "     git config --global user.email \"you@example.com\""
  echo ""
else
  echo "✅ 기존 ID 보존: $GIT_USER_NAME <$GIT_USER_EMAIL>"
fi
echo ""

# ========================================
# 4. 글로벌 설정 적용
# ========================================

echo "📝 글로벌 git config 적용 중..."

# --- 기본 동작 ---
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global push.autoSetupRemote true
git config --global push.followTags true
git config --global fetch.prune true
git config --global fetch.pruneTags true

# --- diff / merge ---
git config --global diff.algorithm histogram
git config --global diff.colorMoved zebra
git config --global merge.conflictStyle zdiff3
git config --global rerere.enabled true     # 같은 충돌 자동 해결 학습

# --- branch / log ---
git config --global branch.sort -committerdate
git config --global log.date iso

# --- color ---
git config --global color.ui auto

# --- 에디터 (nvim > vim 우선) ---
if command -v nvim &> /dev/null; then
  git config --global core.editor nvim
elif command -v vim &> /dev/null; then
  git config --global core.editor vim
fi

# --- delta pager 통합 (delta가 설치된 경우만) ---
if command -v delta &> /dev/null; then
  echo "✅ delta 감지됨 — pager로 설정"
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  git config --global delta.side-by-side false
  git config --global delta.syntax-theme "Dracula"
  git config --global merge.conflictstyle zdiff3
  git config --global diff.colorMoved default
fi

# ========================================
# 5. git alias (서브커맨드)
# ========================================

echo "📝 git alias 등록 중..."
git config --global alias.st "status -sb"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.unstage "restore --staged"
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global alias.lga "log --oneline --graph --decorate --all -30"
git config --global alias.amend "commit --amend --no-edit"
git config --global alias.fixup "commit --fixup"
git config --global alias.aliases "config --get-regexp ^alias\\."

echo "✅ git config 적용 완료"
echo ""

# ========================================
# 6. 셸 alias 통합 (.zshrc / .bashrc)
# ========================================

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ "$CURRENT_SHELL" = "bash" ]; then
  RC_FILE="$HOME/.bashrc"
else
  echo "⚠️  지원하지 않는 쉘($CURRENT_SHELL). 셸 alias는 수동으로 source 하세요:"
  echo "   source $(cd "$(dirname "$0")" && pwd)/git-aliases.sh"
  RC_FILE=""
fi

if [ -n "$RC_FILE" ] && [ -f "$RC_FILE" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ALIAS_LINE="[ -f \"$SCRIPT_DIR/git-aliases.sh\" ] && source \"$SCRIPT_DIR/git-aliases.sh\""

  if grep -q "git-aliases.sh" "$RC_FILE"; then
    echo "✅ git-aliases.sh가 이미 $RC_FILE에 등록되어 있습니다."
  else
    BACKUP_RC="${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$RC_FILE" "$BACKUP_RC"
    echo "💾 $RC_FILE 백업: $BACKUP_RC"
    {
      echo ""
      echo "# ========================================"
      echo "# Git 셸 alias (gst/gco/gp 등)"
      echo "# ========================================"
      echo "$ALIAS_LINE"
    } >> "$RC_FILE"
    echo "✅ git-aliases.sh를 $RC_FILE에 등록했습니다."
  fi
fi

echo ""
echo "=========================================="
echo "✅ Git 모듈 설치 완료!"
echo "=========================================="
echo ""
echo "🔍 적용된 핵심 설정:"
echo "   - init.defaultBranch = main"
echo "   - pull.rebase = true (rebase 모드)"
echo "   - rebase.autoStash = true"
echo "   - push.autoSetupRemote = true"
echo "   - fetch.prune = true (자동 정리)"
echo "   - rerere.enabled = true (충돌 학습)"
echo "   - merge.conflictStyle = zdiff3"
command -v delta &> /dev/null && echo "   - core.pager = delta (syntax-highlight)"
echo ""
echo "🧪 테스트:"
echo "   git aliases       # 등록된 git alias 목록"
echo "   git lg            # graph + oneline 로그"
echo "   gst               # 셸에서 status (새 셸 또는 source 후)"
echo ""
echo "🔄 셸 alias 즉시 적용:"
[ -n "$RC_FILE" ] && echo "   source $RC_FILE"
echo ""
