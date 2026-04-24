# ========================================
# 🎨 Oh My Zsh 설정
# ========================================

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# ========================================
# 🖥️  호스트 체크 함수
# ========================================
is_mac() {
    [[ "$(uname -s)" == "Darwin" ]]
}

is_wsl() {
    [[ $(uname -r) == *"microsoft"* ]] || [[ $(uname -r) == *"WSL"* ]]
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]] && ! is_wsl
}

# ========================================
# 🎨 테마 설정
# ========================================
ZSH_THEME="bira"  # Mac/Linux 공통

# ========================================
# 📦 플러그인 설정
# ========================================
plugins=(git)

source $ZSH/oh-my-zsh.sh

# ========================================
# 🖥️  Mac 전용 설정
# ========================================
if is_mac; then
    # zsh-syntax-highlighting (Mac Homebrew)
    # Apple Silicon (M1/M2/M3)
    if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    # Intel Mac
    elif [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi

    # Homebrew paths (Apple Silicon and Intel)
    if [ -d /opt/homebrew/bin ]; then
        export PATH=/opt/homebrew/bin:$PATH
        export HOMEBREW_PREFIX="/opt/homebrew"
    elif [ -d /usr/local/Homebrew ]; then
        export PATH=/usr/local/bin:$PATH
        export HOMEBREW_PREFIX="/usr/local"
    fi

    # python alias (경로 자동 감지)
    if [ -f "$HOMEBREW_PREFIX/bin/python3" ]; then
        alias python="$HOMEBREW_PREFIX/bin/python3"
        alias py="$HOMEBREW_PREFIX/bin/python3"
    fi

    # Ruby (Mac Homebrew)
    if [ -d "$HOMEBREW_PREFIX/opt/ruby/bin" ]; then
        export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
    fi

    # Ruby gems
    if command -v gem > /dev/null 2>&1; then
      export PATH="$(gem env home)/bin:$PATH"
    fi
fi

# ========================================
# 🪟 WSL 전용 설정
# ========================================
if is_wsl; then
    # zsh-syntax-highlighting (Linux)
    ZSH_SYNTAX_LINUX="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [ -f "$ZSH_SYNTAX_LINUX" ]; then
        source "$ZSH_SYNTAX_LINUX"
    fi

    # NVM (Node Version Manager)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Go 설정 (prerequisites는 /usr/local/go에 설치, apt는 /usr/lib/go에 설치)
    if [ -d "/usr/local/go" ]; then
        export GOROOT=/usr/local/go
    elif [ -d "/usr/lib/go" ]; then
        export GOROOT=/usr/lib/go
    fi
    export GOPATH=$HOME/go
    if [ -n "$GOROOT" ]; then
        export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    fi
    export PATH="$PATH:$HOME/.local/bin"

    # WSL 터미널 색상 보정
    export TERM=xterm-256color
fi

# ========================================
# 🐧 Linux 전용 설정
# ========================================
if is_linux; then
    # zsh-syntax-highlighting (Linux)
    ZSH_SYNTAX_LINUX="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [ -f "$ZSH_SYNTAX_LINUX" ]; then
        source "$ZSH_SYNTAX_LINUX"
    fi

    # NVM (Node Version Manager)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Go 설정 (prerequisites에서 설치한 경우)
    if [ -d "/usr/local/go" ]; then
        export PATH=$PATH:/usr/local/go/bin
        export PATH=$PATH:$HOME/go/bin
    fi

    export PATH="$PATH:$HOME/.local/bin"

    # Linux 터미널 색상 설정
    export TERM=xterm-256color
fi

# ========================================
# 🔧 공통 설정 (Mac & Linux 모두)
# ========================================

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Ubuntu apt로 설치된 fzf는 /usr/share/doc/fzf/examples/ 에 키바인딩 있음
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh

# ========================================
# 🎨 모던 CLI 도구 (설치된 경우에만 활성화)
# ========================================

# zoxide: cd 대체 (z <dir>, zi 인터랙티브)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# eza: ls 대체 (아이콘/git 상태 지원)
if command -v eza &> /dev/null; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git'
  alias la='eza -la --icons=auto --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi

# bat: cat 대체 (Ubuntu는 batcat 이름)
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
elif command -v batcat &> /dev/null; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
fi

# git-delta: git 설치 시 pager로 등록되어 있지 않으면 ~/.gitconfig에 추가 권장
# (자동 수정은 하지 않고, 명령어만 안내)
# git config --global core.pager "delta"
# git config --global delta.syntax-theme "Dracula"

# direnv: 프로젝트별 .envrc 자동 로드
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# pipx 로컬 bin 경로
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# 호스트 이름 제거
unset HOST

# ========================================
# ☁️  AWS CLI 설정 (선택사항)
# ========================================
# AWS CLI를 사용하는 경우 aws 모듈을 설치하세요:
# cd ~/dotfiles/aws && ./install.sh
#
# 또는 수동 로드:
# AWS_ALIASES="$HOME/dotfiles/aws/aws-aliases.sh"
# [ -f "$AWS_ALIASES" ] && source "$AWS_ALIASES"

# ========================================
# ☸️  Kubernetes 설정 (kubectl/kubectx)
# ========================================
# 참고: kubectl/kubectx 모듈을 설치하면 자동으로 추가됩니다.
#
# 수동 설치 시:
# cd ~/dotfiles/kubectl && ./install.sh
# cd ~/dotfiles/kubectx && ./install.sh

# kubectl 자동완성 (kubectl 설치 시 주석 해제)
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
  alias k=kubectl
  complete -F __start_kubectl k

  # kubectl alias
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kl='kubectl logs'
  alias kex='kubectl exec -it'
  alias kgp='kubectl get pods'
  alias kgpa='kubectl get pods --all-namespaces'
  alias kgs='kubectl get svc'
  alias kgd='kubectl get deploy'
  alias kdel='kubectl delete'
fi

# stern (다중 Pod 로그 tail)
if command -v stern &> /dev/null; then
  alias ks='stern'  # ks <pod-prefix>
fi

# kubectx + kubens (설치 시 주석 해제)
if command -v kubectx &> /dev/null && command -v kubens &> /dev/null; then
  alias kx='kubectx'
  alias kn='kubens'

  # 빠른 환경 전환 함수
  function dev() {
    kubectx dev-cluster
    kubens development
    echo "✅ Dev 환경으로 전환"
  }

  function stg() {
    kubectx staging-cluster
    kubens staging
    echo "✅ Staging 환경으로 전환"
  }

  function prod() {
    read -p "⚠️  프로덕션으로 전환합니다. 계속하시겠습니까? (y/N): " confirm
    if [[ "$confirm" == "y" ]]; then
      kubectx prod-cluster
      kubens production
      echo "✅ Production 환경으로 전환"
    else
      echo "❌ 취소됨"
    fi
  }

  # 안전한 컨텍스트 전환
  function kubectx_safe() {
    if [[ "$1" == *"prod"* ]] || [[ "$1" == *"production"* ]]; then
      read -p "⚠️  프로덕션으로 전환합니다. 계속하시겠습니까? (y/N): " confirm
      if [[ "$confirm" == "y" ]]; then
        kubectx "$1"
      else
        echo "❌ 취소됨"
      fi
    else
      kubectx "$1"
    fi
  }

  # kx를 안전 버전으로 대체
  alias kx=kubectx_safe

  # 현재 상태 확인
  function kube_status() {
    echo "Context:   $(kubectx -c)"
    echo "Namespace: $(kubens -c)"
  }

  alias kstatus=kube_status
fi

# ========================================
# 🎨 프롬프트 커스터마이징
# ========================================

if is_mac; then
    PROMPT='%{$fg_bold[cyan]%}[MAC]%{$reset_color%} %{$fg[cyan]%}[%*]%{$reset_color%}
╭─%{$fg[cyan]%}%n%{$reset_color%}@ %{$fg[green]%}%3~%{$reset_color%}$(git_prompt_info)
╰─%(!.#.$) '
elif is_wsl; then
    PROMPT='%{$fg_bold[yellow]%}[WSL]%{$reset_color%} %{$fg[cyan]%}[%*]%{$reset_color%}
╭─%{$fg[cyan]%}%n%{$reset_color%}@ %{$fg[green]%}%3~%{$reset_color%}$(git_prompt_info)
╰─%(!.#.$) '
elif is_linux; then
    PROMPT='%{$fg_bold[green]%}[LINUX]%{$reset_color%} %{$fg[cyan]%}[%*]%{$reset_color%}
╭─%{$fg[cyan]%}%n%{$reset_color%}@ %{$fg[green]%}%3~%{$reset_color%}$(git_prompt_info)
╰─%(!.#.$) '
else
    # Fallback (알 수 없는 환경)
    PROMPT='%{$fg[cyan]%}[%*]%{$reset_color%}
╭─%{$fg[cyan]%}%n%{$reset_color%}@ %{$fg[green]%}%3~%{$reset_color%}$(git_prompt_info)
╰─%(!.#.$) '
fi

ZSH_THEME_GIT_PROMPT_PREFIX=" ‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="›"
ZSH_THEME_GIT_PROMPT_DIRTY="●"
ZSH_THEME_GIT_PROMPT_CLEAN=""
