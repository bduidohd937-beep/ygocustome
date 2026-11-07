# 카드 개발 규칙

1. 카드 효과 텍스트를 먼저 확정한다. 미확정 윤회기사 효과를 추측해서 구현하지 않는다.
2. 9자리 고유 ID를 할당하고 `cards/cards.json`에 등록한다.
3. 효과 몬스터는 `expansions/script/c<ID>.lua` 스크립트를 추가한다.
4. `python tools/build_cdb.py`로 .cdb를 재생성한다.
5. `python -m unittest discover -s tests`로 기초 검사를 진행한다.
6. EDOPro에서 발동 조건, 대상, 체인, 1턴 제한, 제외 및 귀환, 싱크로 소환을 실제 테스트한다.

`tests/`의 검사는 파일 일치성과 메타데이터를 확인할 뿐 EDOPro 엔진 검증을 대신하지 않는다.

Lua 기준: Project Ignis CardScripts (Lua 5.3)
https://github.com/ProjectIgnis/CardScripts
