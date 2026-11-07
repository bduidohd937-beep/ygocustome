# DUELMIND Isobar — WindBot 실제 플레이어 V1 (Windows)

## 구성
- `DuelmindIsobarExecutor.cs`: EDOPro에서 로컬 봇이 사용하는 WindBot C# 실행기.
- `AI_DuelmindIsobar.ydk`: 메인 40장, 엑스트라 15장.
- `register_bot.py`: 기존 WindBot `bots.json`에 `DUELMIND - Isobar` 등록.
- Github Actions `DUELMIND WindBot Windows build`: WindBot Ignite 소스를 내려받고 위 3개 구성 요소를 넣어 Windows 실행 파일을 빌드한다.
- 게임 판정은 EDOPro가 수행. 현재 C# 실행기는 **휴리스틱 전략**이며 이전 Python `duelmind/engine.py`와 실시간 통신하거나 GPT API를 호출하지 않는다.

## 설치 원칙
**EDOPro를 종료하고 설치.** 기존 WindBot 실행 파일 및 bots.json을 백업한 다음 교체한다. 데스파이어/이소바르 Lua와 카드 이미지, `ygocustom.cdb`는 기존 설치를 유지한다. 다른 기존 봇을 쓰는 경우 새 빌드가 프로그램과 맞지 않을 수 있으므로 필요하면 백업본을 복원한다.

EDOPro 경로: `C:\Users\bduid\Games\EDOPro\ProjectIgnis`

1. GitHub Actions의 `DUELMIND-Isobar-WindBot-Windows` 아티팩트를 내려받아 압축을 풀어둔다.
2. 새 번들 내부 `WindBot/` 폴더에 실행 파일, `bots.json`, `Decks/AI_DuelmindIsobar.ydk`가 있는지 확인한다.
3. 아래 명령에서 `$src`에 압축을 풀어둔 **WindBot 폴더** 경로를 입력한다.

```powershell
$ErrorActionPreference = "Stop"
$EDO = "C:\Users\bduid\Games\EDOPro\ProjectIgnis"
$src = "$HOME\Downloads\DUELMIND-Isobar-WindBot-Windows\WindBot"
$dst = Join-Path $EDO "WindBot"
if (!(Test-Path (Join-Path $src "bots.json"))) { throw "압축 해제한 WindBot 폴더를 찾을 수 없음" }
if (!(Test-Path $EDO)) { throw "EDOPro 폴더 없음" }
if (Test-Path $dst) {
    $backup = "$dst.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item $dst $backup -Recurse -Force
    Write-Host "백업: $backup"
}
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item "$src\*" $dst -Recurse -Force
Write-Host "설치 완료. EDOPro 재시작 후 로컬 AI → DUELMIND - Isobar 선택"
```

**주의:** EDOPro 설치판의 WindBot 폴더명이 다르거나 bots.json 경로가 달라질 수 있다. 기존 폴더를 확인한 뒤 설치한다. 자동 시작이 안 되면 복원하고 실행 로그를 수집한다.

## 커스텀 카드 인식
- 일반 EDOPro는 `expansions/ygocustom.cdb`로 카드 데이터를 읽는다.
- WindBot이 같은 카드 정보를 별도 로드하도록 **WindBot 시작 인자의 DbPath / DbPaths 구성을 확인해야 한다**. 이는 EDOPro 로컬 AI 실행 방식과 버전에 의존한다.
- 이 빌드 아티팩트에는 `WindBot/ygocustom.cdb`도 넣었으나, 파일이 있다는 사실만으로 해당 DB가 자동 로드되지는 않는다.

## 완료/미완료 구분
- ✅ 이소바르 전용 C# 실행기 작성 / 전용 YDK 생성 / WindBot 봇 메뉴 등록 스크립트
- ✅ GitHub Actions에서 Windows 빌드 시도 및 산출물 배포 구성
- ❌ 실제 사용자 EDOPro UI에서 듀얼 입장 및 한 판 완주 검증 전
- ❌ Python DUELMIND 엔진과 WindBot 실시간 IPC 연결 전
- ❌ GPT 전략 레이어 및 리플레이 학습 전

## 근거
WindBot Ignite upstream: https://github.com/ProjectIgnis/windbot (AGPL-3.0-or-later)
