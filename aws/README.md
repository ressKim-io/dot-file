# AWS CLI 생산성 설정

AWS CLI 작업을 빠르게 수행하기 위한 단축어 및 함수 모음입니다.

---

## ✨ 이 설정으로 할 수 있는 것

### 타이핑 절약
```bash
# Before
aws sts get-caller-identity
aws ec2 describe-instances --query "..." --output table

# After (90% 절약)
awswho
ec2ls
```

### 비용 절감
```bash
# 사용하지 않는 Elastic IP 찾기 (월 $3.6씩 낭비!)
eip-unused

# 연결 안 된 EBS 볼륨 찾기
ebs-orphan

# 월간 비용 리포트
aws-cost
```

### 실무 시나리오
```bash
# EC2 관리
ec2ls                  # 모든 인스턴스 목록
ec2running             # 실행 중인 것만
ec2find prod           # 태그로 검색
ec2ssh i-xxx           # SSH 자동 접속
ec2rm i-xxx            # 안전하게 삭제 (확인 포함)

# 보안 점검
sg-list                # 보안 그룹 목록
```

**효과:** AWS 작업 시간 60% 단축, 비용 누수 조기 발견

---

## 🚀 빠른 설치

### 자동 설치 (권장)
```bash
./install.sh
```

설치 스크립트가 자동으로:
- ✅ 쉘 감지 (zsh/bash)
- ✅ AWS CLI 설치 확인
- ✅ aws-aliases.sh 경로 설정
- ✅ 기존 설정 백업
- ✅ .zshrc 또는 .bashrc에 자동 로드 추가

---

## 📋 수동 설치

### zsh 사용자
```bash
# ~/.zshrc에 추가
echo 'source ~/dotfiles/aws/aws-aliases.sh' >> ~/.zshrc
source ~/.zshrc
```

### bash 사용자
```bash
# ~/.bashrc에 추가
echo 'source ~/dotfiles/aws/aws-aliases.sh' >> ~/.bashrc
source ~/.bashrc
```

---

## 🧪 설치 확인

```bash
# 1. AWS CLI 설치 확인
aws --version

# 2. AWS 계정 확인
awswho

# 3. EC2 목록 (권한 있는 경우)
ec2ls
```

---

## 📚 명령어 목록

### 기본 정보

| 명령어 | 원본 | 설명 |
|--------|------|------|
| `awswho` | `aws sts get-caller-identity` | 현재 AWS 계정/사용자 |
| `awsregion` | `aws configure get region` | 현재 리전 |

### EC2 관리

| 명령어 | 설명 |
|--------|------|
| `ec2ls` | 모든 EC2 인스턴스 목록 (이름, ID, 상태, 타입, IP) |
| `ec2running` | 실행 중인 인스턴스만 |
| `ec2find <tag>` | 태그로 검색 (예: `ec2find prod`) |
| `ec2ssh <id> [key]` | SSH 자동 접속 (IP 자동 추출) |
| `ec2rm <id>` | 안전하게 삭제 (확인 메시지 포함) |

### 비용 최적화

| 명령어 | 설명 | 절감 효과 |
|--------|------|----------|
| `eip-unused` | 사용 안 하는 Elastic IP | 월 $3.6/개 |
| `ebs-orphan` | 연결 안 된 EBS 볼륨 | 월 $0.1/GB |
| `aws-cost` | 이번 달 비용 리포트 | - |

### 보안/네트워크

| 명령어 | 설명 |
|--------|------|
| `sg-list` | 보안 그룹 목록 |

---

## 💡 사용 예시

### 1. 현재 계정 확인
```bash
$ awswho
{
  "UserId": "AIDACKCEVSQ6C2EXAMPLE",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/DevOps"
}
```

### 2. EC2 목록 조회
```bash
$ ec2ls
---------------------------------------------------------------
|                    DescribeInstances                        |
+---------------+------------------+----------+--------+------+
| prod-web-01   | i-0123456789abc  | running  | t3.m  | 54.. |
| prod-web-02   | i-9876543210xyz  | running  | t3.m  | 54.. |
| dev-api-01    | i-abcdef123456   | stopped  | t3.s  | None |
+---------------+------------------+----------+--------+------+
```

### 3. 특정 태그로 검색
```bash
$ ec2find prod
---------------------------------------------------------------
| prod-web-01   | i-0123456789abc  | running  | 54.123.45.67 |
| prod-web-02   | i-9876543210xyz  | running  | 54.123.45.68 |
---------------------------------------------------------------
```

### 4. SSH 자동 접속
```bash
$ ec2ssh i-0123456789abc ~/.ssh/prod-key.pem
🔗 Connecting to 54.123.45.67...
[ec2-user@prod-web-01 ~]$
```

### 5. 비용 누수 찾기
```bash
$ eip-unused
---------------------------------------
| 54.123.99.99  | eipalloc-0abc123  |  # 사용 안 하는데 월 $3.6 낭비!
| 54.123.88.88  | eipalloc-0def456  |
---------------------------------------

$ ebs-orphan
-----------------------------------------------------------
| vol-0123abc  | 100 GB  | available  | 2024-01-15    |  # 월 $10 낭비!
| vol-0456def  | 50 GB   | available  | 2024-02-20    |
-----------------------------------------------------------
```

### 6. 월간 비용 확인
```bash
$ aws-cost
📊 AWS Cost Report (2024-10-01 ~ 2024-10-23)
--------------------------
| Cost | $1,234.56 USD  |
--------------------------
```

### 7. 안전한 인스턴스 삭제
```bash
$ ec2rm i-0123456789abc
🔍 Instance Info:
-----------------------------------------
| prod-web-01 | i-0123456789abc | running |
-----------------------------------------
❓ Delete this instance? (y/N): y
✅ Termination initiated for i-0123456789abc
```

---

## 🎯 실무 활용 팁

### 1. 매주 월요일 비용 체크
```bash
# cron 등록 (매주 월요일 9시)
0 9 * * 1 /usr/bin/bash -c "source ~/dotfiles/aws/aws-aliases.sh && eip-unused && ebs-orphan"
```

### 2. 인스턴스 이름으로 빠르게 SSH
```bash
# 1. 이름으로 검색
ec2find my-app

# 2. ID 복사
# 3. 접속
ec2ssh i-xxx
```

### 3. 비용 리포트 자동화
```bash
# 매월 1일 Slack 알림
aws-cost | mail -s "AWS Monthly Cost" team@company.com
```

### 4. 프로덕션 안전 장치 추가
```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
ec2rm() {
  if [[ "$1" == *"prod"* ]]; then
    echo "❌ 프로덕션 인스턴스는 이 명령어로 삭제할 수 없습니다."
    return 1
  fi
  # 원본 함수 실행
  $(which ec2rm) "$@"
}
```

---

## 🔧 트러블슈팅

### "command not found: awswho"
```bash
# 설정 파일 재로드
source ~/.zshrc   # zsh
source ~/.bashrc  # bash

# aws-aliases.sh 경로 확인
cat ~/.zshrc | grep aws-aliases
```

### AWS CLI가 설치되지 않음
```bash
# macOS
brew install awscli

# Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 확인
aws --version
```

### AWS CLI 설정 안 됨
```bash
# AWS 자격 증명 설정
aws configure

# 또는 환경 변수
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=ap-northeast-2
```

### 권한 에러
```bash
# IAM 정책 확인
# - EC2: ec2:Describe*, ec2:TerminateInstances
# - Cost Explorer: ce:GetCostAndUsage
# - STS: sts:GetCallerIdentity
```

---

## 📦 추가 스크립트 경로

설정에서 다음 경로를 자동으로 추가합니다:
```bash
$HOME/aws-scripts/ec2/
$HOME/aws-scripts/cost/
$HOME/aws-scripts/security/
```

여기에 커스텀 스크립트를 추가하면 바로 사용 가능합니다.

---

## 🎯 추가 권장 도구

### aws-vault (자격 증명 관리)
```bash
# macOS
brew install aws-vault

# 사용
aws-vault exec production -- awswho
```

### awslogs (CloudWatch Logs)
```bash
pip install awslogs

# 사용
awslogs get /aws/lambda/my-function --watch
```

### aws-shell (인터랙티브 쉘)
```bash
pip install aws-shell

# 사용
aws-shell
```

---

## 📝 업데이트 내역

- 2024.10.23: 초기 버전 생성 (zsh 모듈에서 분리)
- EC2 관리 단축어 10개
- 비용 최적화 명령어 3개
- 실무 활용 예시 추가

---

## 🔗 참고 링크

- AWS CLI: https://aws.amazon.com/cli/
- AWS CLI 명령어 레퍼런스: https://docs.aws.amazon.com/cli/
- Cost Explorer: https://aws.amazon.com/aws-cost-management/aws-cost-explorer/
