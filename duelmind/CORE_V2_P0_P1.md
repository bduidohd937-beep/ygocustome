# DUELMIND CORE V2 P0/P1 — 2026-11-08

## 작업 기준과 보존

기준 bfa1110d6dcaa67a58c0ddbfa95e2bb87d400a99에서 별도 worktree
`duelmind-core-v2`, 브랜치 `feat/duelmind-core-v2`를 생성했다.
원래 worktree의 Ocean Tale 관련 수정 4개, .runtime, 신규 테스트는 보존했다.
설치본, Lua, CDB, 덱, 28741 서버는 변경하지 않았다.

## 구현

- core/contracts.py: 기존 합법 행동 검증과 오류 형식 그대로 이동.
- profiles/isobar_policy.py: 카드 ID, 이름, 점수, 목표, 전개 규칙을 그대로 이동.
- engine.py: 기존 public API 재노출 및 프로필 디스패치. 기존 import/직접 실행 유지.
- core/protocol.py: opt-in 정수 protocol_version=2; 생략/1은 기존 응답 유지.
- C# Executor는 기존 Isobar 전용 어댑터로 유지. 공통 C# 어댑터 추출은 P2.
  기존 C# fallback 우선순위와 AddExecutor 등록은 변경하지 않았다.

## V2 초안 계약

요청: protocol_version=2, duel_id(어댑터 발급 문자열), profile_id,
decision_point, public_state, legal_actions.
public_state의 turn/phase 미수집 시 unknown. 기존 deck_profile 대신 profile_id로
프로필을 명시하며 V2에서는 누락을 거부한다. 기존 프로필 점수는 그대로 적용한다.

응답: 기존 action_id/score/ranked에 protocol_version, duel_id, turn, phase,
profile_id, decision_point, effect_identifier, legal_actions, selected_action,
state_hash, post_action_observation 추가. selected_action은 action_id 문자열이다.
state_hash는 전달받은 public_state의 정렬된 JSON SHA256이며 전체 엔진 상태 해시가 아니다.
effect_profile이 없으면 효과 식별은 unknown이다.
post_action_observation은 현재 {status: unknown, reason: not_collected_by_adapter}.
요청자가 성공을 주장해도 효과 해결 성공으로 승격하지 않는다.
이 단계는 V2 서버 지원이며 실제 C# 클라이언트의 V2 전환은 아직 하지 않았다.

잘못된 요청은 오류로 반환한다. 합법 후보가 없는 경우 안전한 행동을 만들어낼 수 없다.
미지원 프로필은 제공된 후보 중 기존 generic fallback을 사용한다.
서버 연결 실패/시간 초과에 대한 C# fallback은 기존 구현을 보존했다.

## 검증 방법

원래 39개: `python -m unittest tests.test_duelmind tests.test_duelmind_bridge tests.test_duelmind_main_chain tests.test_duelmind_v15 tests.test_duelmind_v21 tests.test_isobar`
전체: `python -m unittest discover -s tests`
최종 결과: 66개 통과, 0개 실패. 기준 전체 58개에 신규 8개를 추가했다.
원래 지정된 39개도 분리 전 모두 통과했다. golden 12건과 합성 256건은
고정 커밋 대비 전체 응답 동일성 검사를 통과했다.
환경 PYTHONDONTWRITEBYTECODE=1. 신규 golden 12건은 기존 JSONL의 observation을
필드 허용 목록으로 축약하고 baseline 실행으로 기대값을 생성했다.
사용자명/환경 경로/시간/세션은 포함하지 않는다. 원래 로그 전체 재현은 아니다.
추가로 git show bfa1110:duelmind/engine.py를 메모리에서 실행해 12건 및
16카드×4행동×4기상=256개 합성 입력의 전체 응답을 비교한다.

임시 OS 할당 포트에서 V1/V2 TCP 왕복, 잘못된 JSON 거부 확인.
응답 없는 peer의 socket timeout 테스트는 Python 호출자 수준이며 C# 런타임
timeout/fallback 통합 검증은 미실행이다. 실제 28741 서버는 사용하지 않는다.

C# 빌드: EDOPRO_ROOT를 설치 경로로 지정하고 dotnet build
duelmind/windbot/DuelmindIsobarExecutor.csproj. BaseOutputPath와
BaseIntermediateOutputPath는 TEMP의 고유 디렉터리로 지정했다.
결과: .NET 8 빌드 성공, 경고 0, 오류 0. DLL 배포하지 않았다.

## 미검증 및 P2

실제 듀얼, 효과 해결 관측, 날씨 전달, C# V2 요청, 복수 소재/대상 선택은 미검증/미지원.
P2 첫 작업은 BASELINE_MISMATCHES.md의 설치본/기준 커밋 계보 확인이다.
카드 동작 변경 승인 없이 카드 구현을 바꾸지 않는다.
그 뒤 공통 C# 어댑터와 Isobar fallback 분리, duel_id/상태 해시 전달,
실행 전후 관측 연결, 대상/소재 콜백 확장을 진행한다.
