# Neovim 치트시트

> Leader = `Space` | 종료 = `Space q` | 강제종료 = `:qa!`

---

## 프로젝트 열기

```bash
nvim                      # 현재 디렉토리에서 시작
nvim main.go              # 파일 직접 열기
nvim +42 main.go          # 42번째 줄에서 열기
```

---

## 파일 찾기 & 검색

| 키 | 동작 |
|---|---|
| `Space ff` | 파일 이름 검색 |
| `Space fg` | 코드 내용 검색 (grep) |
| `Space fb` | 열린 버퍼 목록 |
| `Space fr` | 최근 파일 |
| `Space ft` | TODO/FIXME 검색 |
| `Space e` | 파일 트리 (사이드바) |
| `-` | 상위 디렉토리 (Oil) |

---

## 코드 읽기 (LSP)

| 키 | 동작 |
|---|---|
| `gd` | 정의로 이동 |
| `gr` | 참조 목록 (누가 쓰는지) |
| `gi` | 구현으로 이동 |
| `gt` | 타입 정의 |
| `K` | 문서 팝업 |
| `Space o` | 함수/클래스 목록 (Aerial) |
| `Space fs` | 심볼 검색 |
| `[d` / `]d` | 이전/다음 에러 |
| `Space xx` | 전체 에러 목록 |

---

## 이동 & 점프

| 키 | 동작 |
|---|---|
| `Ctrl+o` | 이전 위치로 돌아가기 |
| `Ctrl+i` | 다음 위치로 이동 |
| `s` | Flash 점프 (화면 내 빠른 이동) |
| `gg` / `G` | 파일 맨 위/아래 |
| `{` / `}` | 문단 이동 |
| `%` | 괄호 짝 이동 |
| `zz` | 현재 줄 화면 중앙 |
| `*` / `#` | 커서 단어 다음/이전 검색 |
| `/단어` | 검색 (`n`=다음, `N`=이전) |

---

## 버퍼 & 창

| 키 | 동작 |
|---|---|
| `Tab` / `Shift+Tab` | 다음/이전 버퍼 |
| `Space bd` | 버퍼 닫기 |
| `Ctrl+h/j/k/l` | 창 이동 |
| `Ctrl+\` | 터미널 토글 |

---

## 편집

| 키 | 동작 |
|---|---|
| `Space rn` | 이름 변경 (rename) |
| `Space ca` | 코드 액션 |
| `Space lf` | 포맷팅 |
| `Space s` | 커서 단어 바꾸기 |
| `Space sr` | 프로젝트 전체 검색/치환 |
| `Alt+j/k` | 줄 위아래 이동 |
| `<` / `>` | 들여쓰기 (Visual) |

---

## 복사 & 경로

| 키 | 모드 | 동작 |
|---|---|---|
| `yy` | Normal | 현재 줄 복사 |
| `y` | Visual | 선택 영역 복사 |
| `p` | Normal | 붙여넣기 |
| `Space yp` | Normal | 절대 경로 복사 |
| `Space yr` | Normal | 상대 경로 복사 |

---

## Git

| 키 | 동작 |
|---|---|
| `Space gg` | LazyGit |
| `Space gd` | Diff 보기 |
| `Space gh` | 파일 히스토리 |
| `Space gb` | 현재 줄 blame |
| `]c` / `[c` | 다음/이전 변경 hunk |
| `Space hs` | hunk 스테이지 |

---

## 디버깅

| 키 | 동작 |
|---|---|
| `F5` | 디버그 시작 |
| `F9` | 브레이크포인트 |
| `F10` | Step Over |
| `F11` | Step Into |
| `Space du` | 디버그 UI |

---

## 테스트

| 키 | 동작 |
|---|---|
| `Space tn` | 커서 위치 테스트 |
| `Space tF` | 파일 전체 테스트 |
| `Space ts` | 테스트 요약 |
| `Space td` | 디버그 모드 테스트 |

---

## DevOps

| 키 | 동작 |
|---|---|
| `Space ka` | kubectl apply |
| `Space kd` | kubectl delete |
| `Space kk` | kubectl UI |
| `Space tf` | terraform fmt |
| `Space tv` | terraform validate |
| `Space tp` | terraform plan |
| `Space dc` | docker compose up |
| `Space x` | 현재 파일 실행 |

---

## 실전 워크플로우

### 처음 보는 프로젝트 파악

```
Space ff → main.go 열기        # 엔트리포인트 찾기
Space o                        # 함수 목록 훑기
gd                             # 함수 정의 따라가기
gr                             # 누가 호출하는지 확인
Ctrl+o                         # 돌아가기
Space fg → "error" 검색         # 에러 처리 패턴 파악
Space e                        # 디렉토리 구조 확인
```

### 버그 찾기

```
Space fg → 에러 메시지 검색      # 에러 발생 위치 찾기
gd                             # 관련 함수 정의로
Space xx                       # 전체 에러/경고 목록
[d / ]d                        # 에러 사이 이동
```

### 코드 수정 후 검증

```
수정 → 저장 (자동 포맷+린트)
Space tn                       # 테스트 실행
Space gg                       # LazyGit에서 diff 확인 + 커밋
```

### Kubernetes YAML 작업

```
nvim deployment.yaml           # 자동 스키마 검증 + 자동완성
Space ka                       # kubectl apply
Space kk                       # kubectl UI로 상태 확인
```

---

## which-key

`Space` 누르고 0.5초 기다리면 사용 가능한 모든 키맵이 팝업으로 표시됩니다.
