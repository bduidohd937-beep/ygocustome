# DUELMIND V1 — 이소바르 전략 엔진 / EDOPro 연동 명세

상태: **1단계 판단 엔진 구현됨, 2단계 실제 EDOPro 브리지 미구현**.
이 프로젝트는 독립 AI가 아니라 게임의 합법적 선택지를 입력받아 행동을 고르는 자동 플레이어를 목표로 한다.

## 현재 구현 범위

- `duelmind/engine.py`: 표준 Python 3.10+만 사용하는 결정론적 이소바르 전략 엔진.
- `tests/test_duelmind.py`: 초동 카드 우선순위, 선공 스톰바스티온, 행동 ID 제약, 중복 거부, 표준입출력 테스트.
- 이소바르 카드 ID `210000201`~`210000213` 인식.
- 인간이 작성한 카드 효과 문구에서 임의로 적법성을 판단하지 않는다.
- EDOPro 어댑터가 제공한 `legal_actions`만 평가하고 그중 하나의 `action_id`를 반환한다.
- 서치/소환/전투/효과 발동 선택의 휴리스틱 우선순위 평가.
- **아직 EDOPro에 접속하거나 로컬 게임을 직접 조작하지 않는다.**

## 실행

레포 루트 PowerShell에서:

```powershell
python -m unittest discover -s tests -v
'{"public_state":{"going_first":true,"weather":"sun"},"legal_actions":[{"action_id":"x1","kind":"normal_summon","card_id":210000201},{"action_id":"x2","kind":"end_phase"}]}' | python duelmind/engine.py
```

출력 예: `{"protocol":"duelmind.v1","action_id":"x1", ...}`.
이 결과는 **모의 행동 입력에 대한 AI 판단**이며, 실제 EDOPro 듀얼 실행 기록이 아니다.

## EDOPro 브리지 규약 (구현 예정)

이소바르를 조작하는 클라이언트 측 브리지 (예: WindBot 포크 또는 독립 EDOPro 프로토콜 클라이언트)는 한 결정 지점마다 다음을 수행한다.

1. EDOPro 서버에서 게임 메시지 수신. 공개된 필드 및 현재 AI가 알 수 있는 자신의 패/덱 정보를 구성.
2. 코어가 제시한 **정확한 합법 행동 후보**를 `legal_actions`로 열거하고, 각 후보에 변조 불가능한 `action_id` 배정.
3. `duelmind/engine.py`로 JSON 1줄 전달. 비공개 상대 패 및 덱 순서 등 AI에게 허용되지 않은 정보 절대 전달하지 않음.
4. 반환된 `action_id`가 현재 선택 집합에 실제로 포함되는지 다시 검증.
5. 브리지가 원래의 EDOPro 응답 코드를 선택하여 송신. 시간 초과·오류 시 서버가 허용하는 기본 행동을 선택.

예시 관측값:

```json
{
  "protocol": "duelmind.v1",
  "public_state": {
    "phase": "main1",
    "going_first": true,
    "weather": "sun",
    "own_monster_count": 1,
    "opponent_monster_count": 0,
    "hand_count": 4,
    "opponent_threat": 0
  },
  "legal_actions": [
    {"action_id":"normal:0","kind":"normal_summon","card_id":210000201},
    {"action_id":"special:1","kind":"special_summon","card_id":210000205},
    {"action_id":"end","kind":"end_phase"}
  ]
}
```

`action_id`는 브리지의 후보 목록 안에서만 의미가 있으며, 엔진은 임의의 새로운 액션을 생성해서는 안 된다.

## 연동 방식 선택 근거
- EDOPro 공식 클라이언트는 전용 YGOPro 코어를 사용한다.
- ProjectIgnis WindBot-Ignite는 EDOPro 네트워크 프로토콜용 가상 플레이어지만 덱별 실행기(executor)가 필요하며 저장소는 2023년 보관 상태이다.
- 기존 유사 프로젝트 ygo-agent는 자체 헤드리스 호스트와 모델 백엔드를 제공하지만 초기 기능상 일부 마스터 룰/화면 제한을 기술하고 있다. 이 저장소의 코드를 검증 없이 즉시 사용하는 대신 프로토콜·호환성 조사를 우선한다.
- WindBot 소스 코드를 복사해 사용할 경우 AGPL-3.0 호환 의무를 확인해야 한다.

## V1 목표 세분화

- [x] 이소바르 카드 DB + Lua 스크립트 (기존 PR #4)
- [x] 후보 행동의 선택을 수행하는 결정론적 전략 엔진
- [x] 순수 Python 단위 테스트와 표준입출력 JSON 프로토콜
- [ ] EDOPro 네트워크/게임 이벤트 브리지: 실제 액션 후보 ID 목록 수집
- [ ] 이소바르 전용 행동별 효과 발동·대상·엑시즈 소재 선택의 세부 정책
- [ ] 브리지와 AI의 한 게임 전체 통합 실행 테스트
- [ ] 플레이 로그, 리플레이, 승률 기반 전략 보정
- [ ] GPT/LLM 전략 레이어는 이후 별도 기능으로 연결; API 키는 저장소에 커밋하지 않는다

## 사용자 환경

- Windows EDOPro 경로: `C:\Users\bduid\Games\EDOPro\ProjectIgnis`.
- 카드 이미지 및 효과 Lua는 이 경로에 설치되어 있음(사용자 스크린샷 기준).
- 데이터 수정 시 기존 데스파이어와 윤회기사 자산 보존.
