# kubectx + kubens 설치

Kubernetes 컨텍스트와 네임스페이스를 빠르게 전환하는 도구입니다.

---

## ✨ 이 도구로 할 수 있는 것

### 컨텍스트 빠른 전환 (kubectx)
```bash
# Before
kubectl config get-contexts
kubectl config use-context my-cluster

# After
kubectx                    # 컨텍스트 목록
kubectx my-cluster         # 즉시 전환
kubectx -                  # 이전 컨텍스트로 돌아가기
```

### 네임스페이스 빠른 전환 (kubens)
```bash
# Before
kubectl get namespaces
kubectl config set-context --current --namespace=production

# After
kubens                     # 네임스페이스 목록
kubens production          # 즉시 전환
kubens -                   # 이전 네임스페이스로 돌아가기
```

### 실무 시나리오
```bash
# 개발 → 스테이징 → 프로덕션 빠른 이동
kubectx dev-cluster
kubens development
kgp                        # dev 환경 확인

kubectx staging-cluster
kubens staging
kgp                        # staging 환경 확인

kubectx prod-cluster
kubens production
kgp                        # prod 환경 확인
```

**효과:** 컨텍스트/네임스페이스 전환 5초 → 1초

---

## 🚀 빠른 설치

### 자동 설치 (권장)
```bash
./install.sh
```

설치 스크립트가 자동으로:
- ✅ OS 감지 (Mac/Linux)
- ✅ kubectx 설치
- ✅ kubens 설치
- ✅ PATH 설정

---

## 📋 수동 설치

### macOS
```bash
# Homebrew로 설치
brew install kubectx

# 확인
kubectx --version
kubens --version
```

### Linux (Ubuntu/Debian/WSL)
```bash
# 1. 다운로드
sudo git clone https://github.com/ahmetb/kubectx.git /opt/kubectx

# 2. 심볼릭 링크 생성
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# 3. 실행 권한 부여
sudo chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

# 4. 확인
kubectx --version
kubens --version
```

---

## 🧪 설치 확인

```bash
# 1. 버전 확인
kubectx --version
kubens --version

# 2. 컨텍스트 목록
kubectx

# 3. 네임스페이스 목록
kubens
```

---

## 📚 사용법

### kubectx (컨텍스트 관리)

#### 목록 조회
```bash
kubectx                    # 전체 컨텍스트 목록 (현재 표시됨)
```

#### 전환
```bash
kubectx my-cluster         # my-cluster로 전환
kubectx -                  # 이전 컨텍스트로 돌아가기
```

#### 이름 변경
```bash
kubectx new-name=old-name  # 컨텍스트 이름 변경
```

#### 삭제
```bash
kubectx -d my-cluster      # 컨텍스트 삭제
```

---

### kubens (네임스페이스 관리)

#### 목록 조회
```bash
kubens                     # 전체 네임스페이스 목록 (현재 표시됨)
```

#### 전환
```bash
kubens production          # production 네임스페이스로 전환
kubens -                   # 이전 네임스페이스로 돌아가기
```

---

## 💡 추천 설정

### alias 추가 (더 짧게)
```bash
# zsh
echo "alias kx='kubectx'" >> ~/.zshrc
echo "alias kn='kubens'" >> ~/.zshrc
source ~/.zshrc

# bash
echo "alias kx='kubectx'" >> ~/.bashrc
echo "alias kn='kubens'" >> ~/.bashrc
source ~/.bashrc
```

### 사용 예시
```bash
kx                         # 컨텍스트 목록
kx prod                    # prod 전환
kn                         # 네임스페이스 목록
kn default                 # default 전환
```

---

## 🎯 실무 활용 팁

### 1. 프롬프트에 현재 컨텍스트 표시
```bash
# zsh (oh-my-zsh 사용 시)
# ~/.zshrc에 추가
plugins=(... kubectl)

# 또는 수동 추가
function kube_ps1() {
  echo "$(kubectx -c):$(kubens -c)"
}

PROMPT='$(kube_ps1) $ '
```

### 2. 실수 방지 (프로덕션)
```bash
# 프로덕션 전환 시 확인
function kubectx_safe() {
  if [[ "$1" == *"prod"* ]]; then
    read "?⚠️  프로덕션으로 전환합니다. 계속? (y/N): " confirm
    [[ "$confirm" == "y" ]] && kubectx "$1"
  else
    kubectx "$1"
  fi
}

alias kx=kubectx_safe
```

### 3. 빠른 환경 전환 함수
```bash
# 개발 환경
function dev() {
  kubectx dev-cluster
  kubens development
  echo "✅ Dev 환경으로 전환"
}

# 스테이징 환경
function stg() {
  kubectx staging-cluster
  kubens staging
  echo "✅ Staging 환경으로 전환"
}

# 프로덕션 환경 (확인 포함)
function prod() {
  read "?⚠️  프로덕션으로 전환합니다. 계속? (y/N): " confirm
  if [[ "$confirm" == "y" ]]; then
    kubectx prod-cluster
    kubens production
    echo "✅ Production 환경으로 전환"
  fi
}
```

---

## 🔧 트러블슈팅

### "command not found: kubectx"
```bash
# PATH 확인
echo $PATH | grep /usr/local/bin

# 심볼릭 링크 확인 (Linux)
ls -la /usr/local/bin/kubectx
ls -la /usr/local/bin/kubens

# 없으면 다시 생성
sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
```

### 권한 에러
```bash
# 실행 권한 부여
sudo chmod +x /usr/local/bin/kubectx
sudo chmod +x /usr/local/bin/kubens
```

### Mac에서 Homebrew 없음
```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 재시도
brew install kubectx
```

---

## 📦 관련 도구

### fzf (fuzzy finder)
kubectx/kubens와 함께 사용하면 더욱 강력합니다.

```bash
# 설치
brew install fzf           # Mac
sudo apt install fzf       # Linux

# 사용
kubectx [Tab]              # 인터랙티브 선택
kubens [Tab]               # 인터랙티브 선택
```

---

## 📝 업데이트 내역

- 2024.10.15: 초기 버전 생성
- Mac/Linux 자동 설치 지원
- 실무 활용 팁 추가

---

## 🔗 참고 링크

- GitHub: https://github.com/ahmetb/kubectx
- 공식 문서: https://github.com/ahmetb/kubectx#installation
