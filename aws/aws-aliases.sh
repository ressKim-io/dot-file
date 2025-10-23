#!/bin/bash
# AWS CLI 생산성 단축어 및 함수

# ========================================
# ☁️  AWS CLI Shortcuts
# ========================================

# 기본 정보 확인
alias awswho='aws sts get-caller-identity'
alias awsregion='aws configure get region'

# EC2 관리 (⭐⭐⭐ 가장 많이 씀)
alias ec2ls='aws ec2 describe-instances \
  --query "Reservations[].Instances[].[Tags[?Key==\`Name\`].Value|[0],InstanceId,State.Name,InstanceType,PublicIpAddress]" \
  --output table'

alias ec2running='aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].[Tags[?Key==\`Name\`].Value|[0],InstanceId,PublicIpAddress]" \
  --output table'

# IPv4 비용 감사 (⭐⭐⭐ 돈 새는 곳 찾기)
alias eip-unused='aws ec2 describe-addresses \
  --query "Addresses[?AssociationId==\`null\`].[PublicIp,AllocationId]" \
  --output table'

# EBS 고아 볼륨 (⭐⭐ 비용 절감)
alias ebs-orphan='aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query "Volumes[].[VolumeId,Size,State,CreateTime]" \
  --output table'

# 보안 그룹 전체 조회
alias sg-list='aws ec2 describe-security-groups \
  --query "SecurityGroups[].[GroupId,GroupName,VpcId]" \
  --output table'

# ========================================
# ☁️  AWS CLI Functions (인자 받아야 할 때)
# ========================================

# EC2 삭제 (확인 메시지 포함)
ec2rm() {
  if [ -z "$1" ]; then
    echo "Usage: ec2rm <instance-id>"
    return 1
  fi

  echo "🔍 Instance Info:"
  aws ec2 describe-instances \
    --instance-ids "$1" \
    --query 'Reservations[0].Instances[0].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name]' \
    --output table

  echo -n "❓ Delete this instance? (y/N): "
  read answer
  if [ "$answer" = "y" ]; then
    aws ec2 terminate-instances --instance-ids "$1"
    echo "✅ Termination initiated for $1"
  else
    echo "❌ Cancelled"
  fi
}

# EC2 SSH 접속 (Public IP 자동 추출)
ec2ssh() {
  if [ -z "$1" ]; then
    echo "Usage: ec2ssh <instance-id> [key-path]"
    return 1
  fi

  local instance_id="$1"
  local key_path="${2:-~/.ssh/aws-key.pem}"  # 기본값

  local ip=$(aws ec2 describe-instances \
    --instance-ids "$instance_id" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

  if [ "$ip" = "None" ] || [ -z "$ip" ]; then
    echo "❌ No public IP found for $instance_id"
    return 1
  fi

  echo "🔗 Connecting to $ip..."
  ssh -i "$key_path" ec2-user@"$ip"
}

# 월간 비용 리포트 (⭐⭐⭐ 팀장님이 좋아함)
aws-cost() {
  local start_date=$(date -u +%Y-%m-01)
  local end_date=$(date -u +%Y-%m-%d)

  echo "📊 AWS Cost Report ($start_date ~ $end_date)"
  aws ce get-cost-and-usage \
    --time-period Start="$start_date",End="$end_date" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --output table
}

# 특정 태그로 EC2 검색 (⭐⭐ 실무에서 많이 씀)
ec2find() {
  if [ -z "$1" ]; then
    echo "Usage: ec2find <tag-value>"
    echo "Example: ec2find prod"
    return 1
  fi

  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*$1*" \
    --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name,PublicIpAddress]' \
    --output table
}

# ========================================
# ☁️  AWS Scripts PATH
# ========================================
export PATH="$HOME/aws-scripts/ec2:$PATH"
export PATH="$HOME/aws-scripts/cost:$PATH"
export PATH="$HOME/aws-scripts/security:$PATH"
