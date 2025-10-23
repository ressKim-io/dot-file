# Vim Go 개발 환경

레거시 서버 및 Go 개발을 위한 Vim 설정입니다.

---

## ✨ 특징

- ✅ Go 개발 특화 (vim-go)
- ✅ 자동완성 (CoC)
- ✅ 파일 검색 (fzf)
- ✅ 파일 트리 (NERDTree)
- ✅ Git 통합 (vim-fugitive)
- ✅ Gruvbox 테마

---

## 🚀 설치

```bash
./install.sh
```

자동으로:
- Vim 설치 (필요시)
- vim-plug 설치
- .vimrc 복사
- 플러그인 설치
- vim-go 바이너리 설치 (선택)

---

## ⌨️  주요 단축키

### Go 개발
| 단축키 | 기능 |
|--------|------|
| `<Tab>b` | GoBuild |
| `<Tab>r` | GoRun |
| `<Tab><Tab>r` | GoRun % (현재 파일) |
| `<Tab>t` | GoTest |
| `<Tab><Tab>t` | GoTestFunc (현재 함수) |
| `<Tab>c` | GoCoverageToggle |
| `<Ctrl+n>` | 다음 quickfix |
| `<Ctrl+p>` | 이전 quickfix |

### 일반
- `<Ctrl+p>`: fzf 파일 검색
- `:NERDTree`: 파일 트리

---

## 📦 플러그인

- **vim-go**: Go 개발 환경
- **CoC**: 자동완성 (LSP)
- **fzf**: 퍼지 파일 검색
- **NERDTree**: 파일 탐색기
- **vim-airline**: 상태바
- **vim-fugitive**: Git 통합
- **tagbar**: 태그 바
- **UltiSnips**: 스니펫

---

## 🔧 CoC 설정

```vim
# Vim에서
:CoCInstall coc-go
:CoCInstall coc-python
:CoCInstall coc-json
```

---

## 💡 사용 예시

### Go 개발
```bash
vim main.go

# 파일 안에서
<Tab>b      # 빌드
<Tab>r      # 실행
<Tab>t      # 테스트
```

---

## 📝 업데이트

- 2024.10.23: 초기 버전 생성
- Go 개발 환경
- CoC 자동완성
