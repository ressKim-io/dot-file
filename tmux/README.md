# tmux - 터미널 멀티플렉서 설정

vim 친화적이고 합리적인 기본값을 가진 tmux 설정. TPM(Tmux Plugin Manager)과 핵심 플러그인 4종을 함께 구성합니다.

---

## 🚀 빠른 시작

```bash
cd ~/dotfiles/tmux
./install.sh
```

설치 후:

```bash
tmux                # 새 세션 시작
tmux new -s work    # 이름 있는 세션 시작
tmux a              # 마지막 세션에 attach
```

---

## ⌨️ 주요 키바인딩

**Prefix는 `Ctrl-a`** (기본 `Ctrl-b`에서 변경 — 한 손 접근성).

### 페인/윈도우 조작
| 키 | 동작 |
|----|------|
| `prefix + \|` | 수직 분할 (현재 경로 유지) |
| `prefix + -` | 수평 분할 (현재 경로 유지) |
| `prefix + h/j/k/l` | vim 스타일 페인 이동 |
| `prefix + H/J/K/L` | 페인 리사이즈 (5칸씩, 반복 가능) |
| `prefix + N / M` | 이전/다음 윈도우 |
| `prefix + c` | 새 윈도우 (현재 경로) |
| `prefix + r` | 설정 리로드 |

### Copy mode (vi 키)
| 키 | 동작 |
|----|------|
| `prefix + [` | copy mode 진입 |
| `v` | 선택 시작 |
| `y` | 선택 영역 복사 후 종료 |
| `q` | copy mode 종료 |

### TPM 플러그인 관리
| 키 | 동작 |
|----|------|
| `prefix + I` | 플러그인 설치 |
| `prefix + U` | 플러그인 업데이트 |
| `prefix + alt+u` | 미사용 플러그인 제거 |

---

## 🔌 포함 플러그인

| 플러그인 | 역할 |
|---------|------|
| `tpm` | 플러그인 매니저 |
| `tmux-sensible` | 합리적 기본값 모음 |
| `tmux-yank` | OS 클립보드로 yank (Mac/X11/Wayland 자동 감지) |
| `tmux-resurrect` | `prefix + Ctrl-s` 저장 / `prefix + Ctrl-r` 복원 |
| `tmux-continuum` | 15분마다 자동 저장 |

resurrect는 vim/nvim 세션과 페인 내용까지 복원합니다.

---

## 🎨 상태바

- **좌측**: 세션 이름
- **우측**: 현재 `kubectl` 컨텍스트 (있을 때만) + 시각

kubectl 컨텍스트는 `kubectl config current-context` 출력을 그대로 표시합니다. 컨텍스트 자동 전환은 `kubectx` 모듈 참고.

---

## 📐 기본값

- 인덱스 1-base (윈도우/페인 모두)
- 마우스 활성화
- 스크롤백 50,000줄
- truecolor 활성화 (`tmux-256color` + `Tc` override)
- ESC 지연 10ms (vim 친화)

---

## 🔄 설정 리로드

설정을 수정하면:

```bash
# tmux 안에서
prefix + r       # ✅ tmux.conf reloaded 메시지 표시
```

또는 새 셸에서:

```bash
tmux source-file ~/.tmux.conf
```

---

## 🆘 트러블슈팅

**Prefix 입력이 너무 느려요**
- `Ctrl-a`로 변경됐습니다. 기본 `Ctrl-b`보다 빠릅니다.

**Truecolor가 어색합니다**
- 터미널 에뮬레이터(WezTerm, Alacritty, iTerm2 등)가 `xterm-256color`로 인식되어야 합니다.
- 확인: `tmux info | grep Tc` → `Tc: (flag) true`

**플러그인이 동작하지 않습니다**
- `prefix + I`로 수동 설치하세요.
- TPM 디렉토리 확인: `ls ~/.tmux/plugins/tpm`

**resurrect 복원이 안 됩니다**
- `~/.tmux/resurrect/last` 심볼릭 링크 존재 확인
- 페인 내용 복원은 활성화돼 있지만 외부 프로세스(서버/REPL)는 복원되지 않습니다.

---

## 📁 파일 구조

```
tmux/
├── install.sh    # tmux + TPM + 플러그인 자동 설치
├── .tmux.conf    # 메인 설정 (홈으로 복사됨)
└── README.md
```

설치 시 기존 `~/.tmux.conf`가 있으면 `~/.tmux.conf.backup.YYYYMMDD_HHMMSS` 형식으로 백업됩니다.
