# YGOCUSTOM — EDOPro Custom Cards

EDOPro용 오리지널 유희왕 테마와 Lua 카드 스크립트 개발 저장소입니다.

## 시작하기
1. `cards/cards.json`에 카드 정보를 기록합니다.
2. `expansions/script/c<ID>.lua`에 효과를 구현합니다.
3. `python tools/build_cdb.py` 실행하여 `expansions/ygocustom.cdb` 생성.
4. [설치 및 테스트 가이드](docs/EDOPRO_SETUP.md)를 따라 EDOPro에서 테스트합니다.

## 구현된 테마
- [데스파이어 볼트 V2.0 — 10장 카드 효과 및 밸런스 조정](docs/themes/deathfire-volt-v2.md)
- 해당 카드의 Lua 파일은 `expansions/script/c210000101.lua` ~ `c210000110.lua`에서 확인할 수 있습니다.
- GitHub Actions에서 Lua 문법 검사 및 `.cdb` 빌드를 수행합니다. EDOPro 실제 듀얼 테스트는 별도로 필요합니다.

현재 포함된 `210000001`은 개발 환경 검증용 **샘플 카드**입니다. 윤회기사 및 기타 실제 테마 카드 효과를 임의로 구현한 것이 아닙니다.

## 구조
- `cards/cards.json`: 카드 메타데이터 원본
- `expansions/script/`: EDOPro Lua 스크립트
- `expansions/pics/`: 그림 파일 위치
- `tools/build_cdb.py`: 카드 데이터베이스 생성기
- `tests/`: 정적 검사
- `docs/`: 설치, 개발 규칙, 테마 설계 문서

참고: [Project Ignis CardScripts](https://github.com/ProjectIgnis/CardScripts), [Scrapi Book](https://projectignis.github.io/scrapi-book/)
