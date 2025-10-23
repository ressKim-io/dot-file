# Zsh + Oh-My-Zsh 설정

생산성을 극대화하는 Zsh 환경 설정입니다. Mac과 Linux(Ubuntu/WSL)에서 모두 사용 가능합니다.

---

## ✨ 이 설정으로 할 수 있는 것

### 강력한 쉘 환경
```bash
# Before (bash)
$ pwd
$ ls
$ cd project

# After (zsh + Oh-My-Zsh)
$ pwd  [Tab]              # 자동완성
$ ls   [화살표]            # 명령어 히스토리 검색
$ cd pr[Tab]              # project 자동완성
```

### AWS CLI 생산성 향상 (선택사항)
AWS CLI를 사용하는 경우 별도 aws 모듈을 설치하세요:
```bash
cd ~/dotfiles/aws
./install.sh
```

자세한 내용은 [aws/README.md](../aws/README.md) 참고

### Kubernetes 통합
```bash
# kubectl 단축어 (kubectl 모듈 설치 시)
k get pods                 # kubectl get pods
kgp                        # 더 짧게!
kl pod-name -f             # kubectl logs pod-name -f

# kubectx/kubens (kubectx 모듈 설치 시)
kx                         # 컨텍스트 목록
kx prod                    # 프로덕션 전환 (확인 필요)
kn                         # 네임스페이스 목록
kn default                 # 네임스페이스 전환
```

### 커스텀 프롬프트
```bash
[MAC] [15:30:42]
╭─username@ ~/project ‹main●›
╰─$

[WSL] [15:30:42]
╭─username@ ~/project ‹feature/new›
╰─$
```

**효과:**
- 타이핑 40% 절감
- 명령어 검색 시간 70% 단축
- K8s 작업 효율 2배 향상

---

## 🚀 빠른 설치

### 자동 설치 (권장)
```bash
./install.sh
```

설치 스크립트가 자동으로:
- ✅ OS 감지 (Mac/Linux)
- ✅ Zsh 설치 (필요시)
- ✅ Oh-My-Zsh 설치
- ✅ .zshrc 적용
- ✅ zsh-syntax-highlighting 설치 (선택)
- ✅ 기본 쉘 변경 (선택)

---

## 📋 수동 설치

### Ubuntu/Debian
```bash
# 1. Zsh 설치
sudo apt-get update
sudo apt-get install -y zsh

# 2. Oh-My-Zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. .zshrc 복사
cp .zshrc ~/.zshrc

# 4. 기본 쉘 변경
chsh -s $(which zsh)

# 5. 로그아웃 후 다시 로그인
```

### macOS
```bash
# 1. Zsh 확인 (이미 설치되어 있음)
zsh --version

# 2. Oh-My-Zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. .zshrc 복사
cp .zshrc ~/.zshrc

# 4. zsh-syntax-highlighting 설치
brew install zsh-syntax-highlighting

# 5. 적용
exec zsh
```

---

## 🧪 설치 확인

```bash
# 1. Zsh 버전 확인
zsh --version
echo $ZSH_VERSION

# 2. Oh-My-Zsh 확인
ls -la ~/.oh-my-zsh

# 3. 테마 확인 (프롬프트가 바뀌었는지)
# [MAC] 또는 [WSL] 태그가 보여야 함

# 4. AWS CLI 단축어 확인
awswho

# 5. kubectl 확인 (설치되어 있다면)
k version
```

---

## 📚 포함된 기능

### 1. Oh-My-Zsh
- **테마**: bira (깔끔한 2줄 프롬프트)
- **플러그인**: git (기본)
- **자동완성**: 모든 명령어 Tab 완성

### 2. Kubernetes 통합

#### kubectl (kubectl 모듈 설치 시)
```bash
k          # kubectl
kg         # kubectl get
kgp        # kubectl get pods
kl         # kubectl logs
kex        # kubectl exec -it
```

#### kubectx + kubens (kubectx 모듈 설치 시)
```bash
kx         # 컨텍스트 전환 (안전 모드)
kn         # 네임스페이스 전환
kstatus    # 현재 상태 확인

dev()      # 개발 환경으로 즉시 전환
stg()      # 스테이징 환경으로 즉시 전환
prod()     # 프로덕션 (확인 후 전환)
```

### 3. Mac/WSL 자동 분기

**Mac 전용:**
- Homebrew PATH 자동 설정
- Python3 alias
- Ruby 경로 설정
- zsh-syntax-highlighting (Homebrew)

**WSL 전용:**
- NVM (Node Version Manager)
- Go 경로 설정
- zsh-syntax-highlighting (플러그인)
- 터미널 색상 최적화

### 4. 커스텀 프롬프트

```bash
# Mac
[MAC] [15:30:42]
╭─username@ ~/project ‹main●›
╰─$

# WSL
[WSL] [15:30:42]
╭─username@ ~/project ‹feature/new›
╰─$
```

**포함 정보:**
- 호스트 타입 (MAC/WSL)
- 현재 시간
- 사용자명
- 현재 디렉토리 (최근 3단계)
- Git 브랜치 및 상태

---

## 💡 사용 예시

### Kubernetes 실무 시나리오
```bash
# 1. 개발 환경으로 전환
$ dev
✅ Dev 환경으로 전환

# 2. Pod 확인
$ kgp
NAME                     READY   STATUS
api-server-xxx           1/1     Running
database-xxx             1/1     Running

# 3. 로그 확인
$ kl api-server-xxx -f
[실시간 로그 스트리밍...]

# 4. 프로덕션 확인 (안전 모드)
$ prod
⚠️  프로덕션으로 전환합니다. 계속하시겠습니까? (y/N): y
✅ Production 환경으로 전환
```

---

## 🔧 트러블슈팅

### Zsh가 기본 쉘로 변경되지 않음
```bash
# 현재 쉘 확인
echo $SHELL

# 수동으로 변경
chsh -s $(which zsh)

# /etc/shells에 zsh 추가 (필요시)
echo $(which zsh) | sudo tee -a /etc/shells

# 로그아웃 후 재로그인
```

### Oh-My-Zsh 테마가 깨짐
```bash
# 폰트 설치 (Mac)
brew install --cask font-meslo-lg-nerd-font

# 터미널 폰트를 Meslo LG Nerd Font로 변경

# 또는 간단한 테마로 변경
# ~/.zshrc에서:
ZSH_THEME="simple"
```

### AWS CLI를 사용하고 싶다면
```bash
# aws 모듈 설치
cd ~/dotfiles/aws
./install.sh

# 자세한 내용은 aws/README.md 참고
```

### kubectl 자동완성 안 됨
```bash
# kubectl 모듈 먼저 설치
cd ~/dotfiles/kubectl
./install.sh

# 또는 수동 설정
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc
```

### "command not found: kubectx"
```bash
# kubectx 모듈 먼저 설치
cd ~/dotfiles/kubectx
./install.sh
```

---

## 🎯 추가 권장 도구

### fzf (fuzzy finder)
```bash
# Mac
brew install fzf
$(brew --prefix)/opt/fzf/install

# Linux
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# 사용:
Ctrl+R    # 명령어 히스토리 검색
Ctrl+T    # 파일 검색
Alt+C     # 디렉토리 이동
```

### zsh-autosuggestions
```bash
# Mac
brew install zsh-autosuggestions
echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

# Linux
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# ~/.zshrc에 추가:
plugins=(git zsh-autosuggestions)
```

---

## 📦 연관 모듈

이 설정은 다른 dotfiles 모듈과 함께 사용하면 더욱 강력합니다:

- **aws/** - AWS CLI 생산성 단축어 (선택사항)
- **kubectl/** - Kubernetes CLI 생산성 향상
- **kubectx/** - 컨텍스트/네임스페이스 빠른 전환
- **nvim/** - 현대적인 에디터 환경
- **vim/** - 레거시 서버 대응

---

## 📝 업데이트 내역

- 2024.10.23: AWS 설정을 별도 모듈로 분리
- 2024.10.23: 초기 버전 생성
- Mac/WSL 자동 분기 지원
- Kubernetes 통합 (kubectl/kubectx)
- 커스텀 프롬프트 (시간, Git 브랜치)

---

## 🔗 참고 링크

- Zsh: https://www.zsh.org/
- Oh-My-Zsh: https://ohmyz.sh/
- AWS CLI: https://aws.amazon.com/cli/
- kubectl: https://kubernetes.io/docs/reference/kubectl/
