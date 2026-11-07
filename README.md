# YGOCUSTOM — EDOPro Custom Cards

EDOPro용 오리지널 유희왕 테마와 Lua 카드 스크립트 개발 저장소입니다.

## 시작하기
1. `cards/cards.json`에 카드 정보를 기록합니다.
2. `expansions/script/c<ID>.lua`에 효과를 구현합니다.
3. `python tools/build_cdb.py` 실행하여 `expansions/ygocustom.cdb` 생성.
4. [설치 및 테스트 가이드](docs/EDOPRO_SETUP.md)를 따라 EDOPro에서 테스트합니다.

현재 포함된 `210000001`은 개발 환경 검증용 **샘플 카드**입니다. 윤회기사 및 기타 실제 테마 카드 효과를 임의로 구현한 것이 아닙니다.

## 구조
- `cards/cards.json`: 카드 메타데이터 원본
- `expansions/script/`: EDOPro Lua 스크립트
- `expansions/pics/`: 그림 파일 위치
- `tools/build_cdb.py`: 카드 데이터베이스 생성기
- `tests/`: 정적 검사
- `docs/`: 설치, 개발 규칙, 테마 설계 문서

참고: [Project Ignis CardScripts](https://github.com/ProjectIgnis/CardScripts), [Scrapi Book](https://projectignis.github.io/scrapi-book/)
