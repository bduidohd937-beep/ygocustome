# EDOPro 설치 및 테스트

## 카드 구성
- 데이터베이스: `expansions/ygocustom.cdb` (빌드 결과)
- Lua 스크립트: `expansions/script/c<카드ID>.lua`
- 카드 그림(선택): `expansions/pics/<카드ID>.jpg` 또는 `.png`

**카드 ID**가 데이터베이스, Lua 파일, 이미지에서 정확히 같아야 합니다.

## 설치
1. Python 3으로 `python tools/build_cdb.py` 실행.
2. 생성된 `expansions/ygocustom.cdb`를 EDOPro 설치 폴더의 `expansions`에 복사.
3. `expansions/script/` 안의 Lua 파일을 EDOPro의 `expansions/script/`에 복사.
4. 카드 이미지가 있다면 `expansions/pics/` 안의 그림을 EDOPro의 `expansions/pics/`에 복사.
5. EDOPro를 재시작하고 카드 검색, 소환 및 효과 발동을 테스트.

테스트 카드: `210000001`, 일반 소환 성공 시 1장 드로우 (1턴에 1번).

참고: https://projectignis.github.io/scrapi-book/getting-started/setup.html
