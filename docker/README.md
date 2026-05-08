# docker - 셸 단축어 + 정리 함수

자주 쓰는 docker / docker compose 명령을 짧게. 위험한 작업은 확인 메시지를 거치도록 함수로 감쌉니다.

> Docker 자체는 `prerequisites/install-docker.sh`에서 설치됩니다. 이 모듈은 셸 통합만 담당합니다.

---

## 🚀 빠른 시작

```bash
cd ~/dotfiles/docker
./install.sh
source ~/.zshrc        # 또는 ~/.bashrc
```

---

## ⌨️ 단축어 표

### 기본 / 조회
| alias | 명령 |
|-------|------|
| `d` | `docker` |
| `dps` / `dpsa` | `docker ps` / `ps -a` |
| `di` | `docker images` |
| `dst` | `docker stats` |
| `dinfo` / `dversion` | `docker info` / `version` |

### 컨테이너 라이프사이클
| alias | 명령 |
|-------|------|
| `dr` / `drd` | `docker run` / `run -d` |
| `drm` / `drmf` | `docker rm` / `rm -f` |
| `dstart` / `dstop` / `dres` | `start` / `stop` / `restart` |

### 로그 / 진입
| alias | 명령 |
|-------|------|
| `dl <c>` | `docker logs <c>` |
| `dlf <c>` | `docker logs -f --tail=200 <c>` |
| `dex <c> <cmd>` | `docker exec -it <c> <cmd>` |
| `dsh <c>` | 컨테이너 진입 (bash 우선, sh fallback) |

### 이미지
| alias | 명령 |
|-------|------|
| `dpull` / `dpush` | `docker pull` / `push` |
| `drmi` | `docker rmi` |
| `dbuild` / `dbuildt <tag>` | `docker build` / `build -t` |

### 네트워크 / 볼륨
| alias | 명령 |
|-------|------|
| `dnet` / `dnetls` | `docker network` / `network ls` |
| `dvol` / `dvolls` | `docker volume` / `volume ls` |

### 시스템 / 정리
| alias | 명령 | 비고 |
|-------|------|------|
| `dprune` | `docker system prune` | 안전 (정지된 컨테이너/dangling 이미지) |
| `dprunea` | `docker system prune -a --volumes` | 전체 정리, 주의 |

### Docker Compose v2
| alias | 명령 |
|-------|------|
| `dc` | `docker compose` |
| `dcup` / `dcdown` | `compose up -d` / `down` |
| `dcps` | `compose ps` |
| `dcl <svc>` / `dclf <svc>` | `logs` / `logs -f --tail=200` |
| `dcb` / `dcr` / `dcpull` | `build` / `restart` / `pull` |
| `dcconfig` | `compose config` (합성 설정 검증) |

---

## 🛠️ 함수

### 안전 정리 (확인 포함)
| 함수 | 동작 |
|------|------|
| `drmall` | 모든 컨테이너 강제 삭제 (목록 표시 후 y/N 확인) |
| `drmidangling` | dangling 이미지 일괄 삭제 |
| `ddisk` | `docker system df` + 정리 명령 안내 |

### 진단 / 분석
| 함수 | 동작 |
|------|------|
| `dsh <c>` | bash 우선, 실패 시 sh로 컨테이너 진입 |
| `dip <c>` | 컨테이너 IP 주소 출력 |
| `ddive <img>` | dive로 이미지 레이어 분석 (dive 필요) |

---

## 🤝 다른 도구와의 통합

| 도구 | 위치 | 용도 |
|------|------|------|
| **lazydocker** | `prerequisites/install-modern-cli.sh` (Tier A) | TUI로 컨테이너/이미지/볼륨 한눈에 |
| **dive** | `prerequisites/install-modern-cli.sh` (Tier A) | 이미지 레이어 분석 (`ddive` 함수에 연동) |
| **trivy** | `prerequisites/install-devops-tools.sh` | 이미지 보안 스캔 |
| **hadolint** | `prerequisites/install-devops-tools.sh` | Dockerfile 린팅 |

---

## 🆘 트러블슈팅

**`dc`가 동작하지 않습니다 (compose v1 환경)**
- 이 모듈은 Docker Compose **v2** (`docker compose`)를 가정합니다.
- v1 (`docker-compose`) 사용자라면: `alias dc='docker-compose'`로 직접 추가하세요.

**Mac에서 `drmall`이 너무 느려요**
- Docker Desktop의 가상화 레이어 때문입니다. 실제 운영에서는 `dprunea`로 한 번에 정리하는 게 빠릅니다.

**셸 alias가 적용 안 돼요**
- 새 셸 시작 또는 `source ~/.zshrc`
- 등록 확인: `grep docker-aliases.sh ~/.zshrc`

**Permission denied (Linux)**
- docker 그룹에 사용자 추가 필요:
  ```bash
  sudo usermod -aG docker $USER
  newgrp docker          # 또는 재로그인
  ```

---

## 📁 파일 구조

```
docker/
├── install.sh              # 설치/등록 스크립트
├── docker-aliases.sh       # 셸 alias + 함수 (.zshrc에서 source)
└── README.md
```
