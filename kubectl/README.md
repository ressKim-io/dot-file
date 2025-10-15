# kubectl 생산성 설정

kubectl 명령어를 빠르게 사용하기 위한 alias 및 자동완성 설정입니다.

---

## ✨ 이 설정으로 할 수 있는 것

### 타이핑 절약
```bash
# Before
kubectl get pods
kubectl get pods --all-namespaces
kubectl describe pod my-app
kubectl logs my-app -f
kubectl exec -it my-app -- /bin/bash

# After (50% 절약)
kgp
kgpa
kdp my-app
klf my-app
kex my-app -- /bin/bash
```

### 자동완성 (Tab 키)
```bash
k get p[Tab]           # → pods
k get pods -n [Tab]    # → 네임스페이스 목록
k logs my-[Tab]        # → my-로 시작하는 pod 이름들
```

### 실시간 모니터링
```bash
kgpw                   # Pod 상태 실시간 확인 (watch)
klf pod-name           # 로그 실시간 스트리밍
```

### 빠른 리소스 조회
```bash
kg all                 # 모든 리소스 한번에
kgpwide                # Pod IP, Node 정보 포함
kga                    # namespace의 모든 리소스
```

**효과:** 하루 타이핑 500회 → 250회 (50% 절감)

---

## 🚀 빠른 설치

### 자동 설치 (권장)
```bash
./install.sh
```

설치 스크립트가 자동으로:
- ✅ 현재 쉘 감지 (zsh/bash)
- ✅ kubectl 자동완성 설정
- ✅ alias 추가
- ✅ 기존 설정 백업

---

## 📋 수동 설치

### zsh 사용자
```bash
cat >> ~/.zshrc << 'EOF'

# kubectl 자동완성
source <(kubectl completion zsh)

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

EOF

source ~/.zshrc
```

### bash 사용자 (WSL/Ubuntu)
```bash
# bash-completion 설치 (필요시)
sudo apt-get install -y bash-completion

cat >> ~/.bashrc << 'EOF'

# kubectl 자동완성
source <(kubectl completion bash)

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

EOF

source ~/.bashrc
```

---

## 🧪 설치 확인

```bash
# 1. alias 확인
k version

# 2. 자동완성 확인 (Tab 키)
k get p[Tab]  # "pods"로 자동완성되면 성공

# 3. 단축 명령어 확인
kgp           # kubectl get pods
kg svc        # kubectl get svc
kl pod-name   # kubectl logs pod-name
```

---

## 📚 단축키 목록

| 단축키 | 원본 명령어 | 설명 |
|--------|------------|------|
| `k` | `kubectl` | 기본 명령어 |
| `kg` | `kubectl get` | 리소스 조회 |
| `kd` | `kubectl describe` | 리소스 상세 정보 |
| `kl` | `kubectl logs` | 로그 확인 |
| `kex` | `kubectl exec -it` | 컨테이너 접속 |
| `kgp` | `kubectl get pods` | Pod 목록 |
| `kgpa` | `kubectl get pods -A` | 전체 네임스페이스 Pod |
| `kgs` | `kubectl get svc` | Service 목록 |
| `kgd` | `kubectl get deploy` | Deployment 목록 |
| `kdel` | `kubectl delete` | 리소스 삭제 |

---

## 💡 사용 예시

### Before
```bash
kubectl get pods
kubectl logs my-app-deployment-5d8f7c9b4d-xkqpw -f
kubectl describe pod my-app-deployment-5d8f7c9b4d-xkqpw
```

### After
```bash
kgp
kl my-app[Tab] -f          # Tab으로 자동완성
kd pod my-app[Tab]
```

---

## 🔧 트러블슈팅

### 자동완성이 작동하지 않을 때

#### zsh
```bash
# ~/.zshrc 맨 위에 추가
autoload -Uz compinit && compinit

# 쉘 재시작
exec zsh
```

#### bash
```bash
# 쉘 재시작
exec bash

# 또는 수동 재로드
source ~/.bashrc
```

### kubectl이 설치되지 않았을 때
```bash
# kubectl 설치 확인
kubectl version --client

# 설치되지 않았다면:
# https://kubernetes.io/docs/tasks/tools/
```

### "command not found: k" 에러
```bash
# 설정 파일 재로드
source ~/.zshrc   # zsh
source ~/.bashrc  # bash
```

---

## 📦 전체 alias 파일

전체 alias 목록은 [aliases](aliases) 파일을 참고하세요.

---

## 🎯 추가 권장 도구

### k9s (Kubernetes TUI)
```bash
# macOS
brew install k9s

# Linux
curl -sS https://webinstall.dev/k9s | bash
```

### kubectx + kubens
```bash
# macOS
brew install kubectx

# Linux (수동 설치)
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
```

---

## 📝 업데이트 내역

- 2024.10.15: 초기 버전 생성
- zsh/bash 자동 감지 지원
- 기본 alias 10개 추가
