# git - 글로벌 설정 + 셸 단축어

합리적인 git 글로벌 기본값과 자주 쓰는 셸 단축어 모음. delta가 설치되어 있으면 syntax-highlight pager로 자동 통합합니다.

---

## 🚀 빠른 시작

```bash
cd ~/dotfiles/git
./install.sh
```

설치 후:

```bash
source ~/.zshrc      # 또는 ~/.bashrc
gst                  # git status (셸 alias)
git lg               # graph + oneline 로그 (git alias)
git aliases          # 등록된 git alias 전체 목록
```

---

## 🔧 적용되는 글로벌 설정

### 핵심 동작
| 키 | 값 | 효과 |
|----|----|------|
| `init.defaultBranch` | `main` | 새 저장소 기본 브랜치 |
| `pull.rebase` | `true` | `git pull` = rebase (히스토리 선형) |
| `rebase.autoStash` | `true` | rebase 시 워킹 디렉토리 자동 stash |
| `push.autoSetupRemote` | `true` | 첫 push 시 upstream 자동 설정 |
| `push.followTags` | `true` | push 시 annotated 태그도 함께 |
| `fetch.prune` / `pruneTags` | `true` | 원격에서 삭제된 브랜치/태그 자동 정리 |
| `rerere.enabled` | `true` | 같은 충돌 자동 해결 학습 |
| `branch.sort` | `-committerdate` | 최근 작업 브랜치가 위에 |

### diff / merge
| 키 | 값 |
|----|----|
| `diff.algorithm` | `histogram` |
| `diff.colorMoved` | `zebra` (delta 활성화 시 `default`) |
| `merge.conflictStyle` | `zdiff3` (3-way diff, 더 명확한 충돌 표시) |

### delta 통합 (자동 감지)
delta가 설치된 경우 다음을 자동 적용:
- `core.pager = delta`
- `interactive.diffFilter = "delta --color-only"`
- `delta.navigate = true` (n/N으로 hunk 이동)
- `delta.line-numbers = true`
- `delta.syntax-theme = "Dracula"`

side-by-side는 기본 off. 필요 시:
```bash
git config --global delta.side-by-side true
```

### user.name / user.email
**이미 설정되어 있으면 건드리지 않습니다.** 비어 있을 때만 안내 메시지를 출력합니다.

---

## ⌨️ git alias (서브커맨드)

| alias | 풀이 |
|-------|------|
| `git st` | `status -sb` |
| `git co` | `checkout` |
| `git br` | `branch` |
| `git ci` | `commit` |
| `git last` | `log -1 HEAD --stat` |
| `git unstage` | `restore --staged` |
| `git lg` | `log --oneline --graph --decorate -20` |
| `git lga` | `log --oneline --graph --decorate --all -30` |
| `git amend` | `commit --amend --no-edit` |
| `git fixup <sha>` | `commit --fixup <sha>` |
| `git aliases` | 등록된 alias 전체 목록 |

---

## ⌨️ 셸 alias (`git-aliases.sh`)

설치 시 `~/.zshrc` (또는 `~/.bashrc`)에 source 라인이 추가됩니다.

### 기본
| alias | 명령 |
|-------|------|
| `g` | `git` |
| `gst` | `git status` |
| `gss` | `git status -s` |

### 브랜치
| alias | 명령 |
|-------|------|
| `gb` / `gba` | `git branch` / `branch -a` |
| `gco` / `gcb` | `git checkout` / `checkout -b` |
| `gsw` / `gswc` | `git switch` / `switch -c` |

### diff / log
| alias | 명령 |
|-------|------|
| `gd` / `gds` | `git diff` / `diff --staged` |
| `gl` / `gla` | 최근 20개 / 전체 30개 graph 로그 |
| `glast` | `git log -1 HEAD --stat` |

### staging / commit
| alias | 명령 |
|-------|------|
| `ga` / `gap` | `git add` / `add -p` |
| `gcm "msg"` | `git commit -m` |
| `gca` / `gcan` | `commit --amend` / `--amend --no-edit` |
| `gun` | `git restore --staged` |

### remote / sync
| alias | 명령 | 비고 |
|-------|------|------|
| `gp` | `git push` | |
| `gpf` | `git push --force-with-lease` | `--force` 대체, 협업 안전 |
| `gpu` | 현재 브랜치를 origin에 push (-u 자동) | 함수 |
| `gpl` | `git pull` | |
| `gf` / `gfa` | `git fetch` / `fetch --all --prune` | |

### rebase / stash
| alias | 명령 |
|-------|------|
| `grb` / `grbi` | `git rebase` / `rebase -i` |
| `grbc` / `grba` | `rebase --continue` / `--abort` |
| `gsta` / `gstp` / `gstl` | stash / stash pop / stash list |

### 함수
| 함수 | 동작 |
|------|------|
| `gcurrent` | 현재 브랜치 이름 출력 |
| `gpu` | 현재 브랜치를 origin에 upstream 자동 설정 push |
| `gmain` | main 또는 master 자동 감지 후 체크아웃 |
| `gprune` | main/master에 머지된 로컬 브랜치 일괄 삭제 |

---

## 🆘 트러블슈팅

**설정을 되돌리고 싶어요**
- 설치 시 `~/.gitconfig.backup.YYYYMMDD_HHMMSS`를 만듭니다.
- `cp ~/.gitconfig.backup.* ~/.gitconfig`

**delta pager가 어색해요**
```bash
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
```

**pull.rebase=true가 마음에 안 들어요**
```bash
git config --global pull.rebase false        # merge로
git config --global pull.ff only             # ff-only로
```

**셸 alias가 적용 안 돼요**
- 새 셸 시작 또는 `source ~/.zshrc` 실행
- 등록 확인: `grep git-aliases.sh ~/.zshrc`

---

## 📁 파일 구조

```
git/
├── install.sh           # 설정 적용 스크립트
├── git-aliases.sh       # 셸 alias (.zshrc에서 source)
└── README.md
```
