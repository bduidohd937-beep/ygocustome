"""DUELMIND V1: deterministic strategy over engine-provided legal actions.

This module deliberately does not generate game actions. A trusted EDOPro adapter
must enumerate the exact legal choices and execute the returned action_id.
"""
from __future__ import annotations
from typing import Any
import json

ISOBAR = {
    "argen": 210000201, "rain": 210000202, "bolt": 210000203,
    "sol": 210000204, "nova": 210000205, "zephyr": 210000206,
    "hawk": 210000207, "bastion": 210000208, "tempest": 210000209,
    "field": 210000210, "front": 210000211, "journal": 210000212,
    "alert": 210000213, "cirrus": 210000214, "nimbus": 210000215,
    "storm_boundary": 210000216,
}
KINDS = {
    "activate", "normal_summon", "special_summon", "xyz_summon",
    "set", "attack", "change_position", "pass", "end_phase",
    "choose", "chain", "select_card", "battle_phase",
}
MAX_CHOICES = 512


class InvalidObservation(ValueError):
    pass


def _integer(v: Any, default: int = 0) -> int:
    return v if type(v) is int else default


def validate(obs: dict) -> list[dict]:
    if not isinstance(obs, dict):
        raise InvalidObservation("Observation must be an object")
    choices = obs.get("legal_actions")
    if not isinstance(choices, list) or not 1 <= len(choices) <= MAX_CHOICES:
        raise InvalidObservation("legal_actions must contain 1-512 choices")
    seen = set()
    for item in choices:
        if not isinstance(item, dict):
            raise InvalidObservation("Each choice must be an object")
        aid, kind = item.get("action_id"), item.get("kind")
        if not isinstance(aid, str) or not 1 <= len(aid) <= 128 or aid in seen:
            raise InvalidObservation("Invalid or duplicate action_id")
        if kind not in KINDS:
            raise InvalidObservation("Unknown action kind")
        seen.add(aid)
    return choices


def score(action: dict, obs: dict) -> tuple[int, list[str]]:
    """Heuristic ranking only; does not certify a game action as legal."""
    state = obs.get("public_state") or {}
    if not isinstance(state, dict):
        state = {}
    phase = str(state.get("phase", "")).lower()
    own_field = state.get("own_field_spell") is True
    own_lv4 = max(0, _integer(state.get("own_level4_count")))
    chain_from_opp = state.get("chain_from_opponent") is True
    chain_from_self = state.get("chain_from_opponent") is False
    hand_ids = state.get("hand_ids") if isinstance(state.get("hand_ids"), list) else []
    grave_ids = state.get("grave_ids") if isinstance(state.get("grave_ids"), list) else []
    weather = str(state.get("weather", "none")).lower()
    going_first = bool(state.get("going_first", False))
    opp_monsters = max(0, _integer(state.get("opponent_monster_count")))
    own_monsters = max(0, _integer(state.get("own_monster_count")))
    hand_count = max(0, _integer(state.get("hand_count")))
    enemy_threat = max(0, _integer(state.get("opponent_threat"), 0))
    kind = action["kind"]
    cid = _integer(action.get("card_id"))
    location = str(action.get("location", "")).lower()
    controller = _integer(action.get("controller"), -1)
    target = action.get("target") or {}
    if not isinstance(target, dict):
        target = {}
    reasons: list[str] = []
    value = {
        "normal_summon": 35, "special_summon": 32, "xyz_summon": 40,
        "activate": 25, "chain": -15, "attack": 20, "set": 13,
        "change_position": 5, "select_card": 0, "choose": 0,
        "battle_phase": 22,
        "pass": 5, "end_phase": -45,
    }[kind]

    def bonus(amount: int, reason: str) -> None:
        nonlocal value
        value += amount
        reasons.append(reason)

    if kind == "chain" and enemy_threat > 0 and cid in {
        14558127, 97268402, 10045474, 14087893,
    }:
        bonus(50, "상대 전개에 대한 범용 견제")
    if kind == "chain" and cid == ISOBAR["front"] and enemy_threat > 0:
        bonus(25, "상대 턴 기상 변경")
    if cid == ISOBAR["argen"] and kind in {"normal_summon", "special_summon"}:
        bonus(38, "초동 서치 확보")
    if cid == ISOBAR["field"] and kind == "activate":
        bonus(44 if weather == "none" else 10, "기상 엔진 확보")
    if cid == ISOBAR["journal"] and kind == "activate":
        bonus(33 if hand_count < 5 else 20, "후속 몬스터 확보")
    if cid in {ISOBAR["nova"], ISOBAR["rain"]} and kind == "special_summon":
        bonus(29 if own_monsters == 1 else 11, "랭크 4 전개 보조")
    if cid == ISOBAR["cirrus"] and kind in {"normal_summon", "special_summon"}:
        bonus(55 if not own_field else 38, "시러스로 중앙관측소 또는 이소바르 확보")
    if cid == ISOBAR["nimbus"] and kind == "special_summon":
        bonus(24 if own_field else -20, "기상 변경 후 님버스 확장")
    if cid == ISOBAR["zephyr"] and kind in {"normal_summon", "special_summon"}:
        bonus(23, "묘지 전개 기대")
    if kind in {"xyz_summon", "special_summon"} and cid == ISOBAR["bastion"]:
        bonus(46 if going_first or opp_monsters == 0 else 22, "강우 견제 구축")
    if kind in {"xyz_summon", "special_summon"} and cid == ISOBAR["hawk"]:
        bonus(35 if hand_count < 4 else 18, "장기전 서치 확보")
    if kind in {"xyz_summon", "special_summon"} and cid == ISOBAR["tempest"]:
        bonus(35 if opp_monsters > 0 else 9, "상대 필드 돌파")
    if kind in {"activate", "chain"} and cid == ISOBAR["alert"]:
        bonus(30 + enemy_threat * 10, "위협 효과 견제")
    if kind in {"activate", "chain"} and cid == ISOBAR["bastion"]:
        bonus(20 + enemy_threat * 14, "상대 몬스터 효과 무효")
    if kind in {"activate", "chain"} and cid == ISOBAR["tempest"] and opp_monsters:
        bonus(25, "상대 카드 바운스")
    if kind in {"activate", "chain"} and cid == ISOBAR["storm_boundary"] and opp_monsters:
        bonus(36, "폭풍경계로 상대 마법·함정 돌파")
    if kind == "attack":
        if target.get("winning_attack") is True:
            bonus(150, "확정 킬 공격")
        elif target.get("favorable_battle") is True:
            bonus(18, "유리한 전투")
        elif target.get("risky") is True:
            bonus(-30, "위험한 전투 회피")
    if kind in {"choose", "select_card"}:
        if target.get("advances_win") is True:
            bonus(45, "전략 목표에 부합하는 선택")
        if target.get("high_value") is True:
            bonus(30, "고가치 대상")

    # V1.5 context-aware planner overlay. The engine still decides ONLY among
    # options enumerated by WindBot/EDOPro; no imaginary game actions.
    if kind == "activate" and cid == ISOBAR["field"]:
        if location == "hand" and not own_field:
            bonus(100, "중앙관측소 활성화가 전개의 출발점")
        elif location == "spellzone":
            bonus(45 if ISOBAR["argen"] in hand_ids else -55,
                  "기상 변경은 패 아르젠 전개가 있을 때 우선")
    if kind == "activate" and location == "hand":
        if cid in {ISOBAR["nova"], ISOBAR["rain"]}:
            bonus(95 if own_lv4 == 1 else 65,
                  "패에서 발동하는 특수 소환 효과를 전개로 인식")

    if kind in {"normal_summon", "special_summon"} and cid == ISOBAR["argen"]:
        bonus(50, "아르젠으로 서치 확보")
    if kind == "normal_summon" and cid == ISOBAR["zephyr"]:
        has_ally = any(ISOBAR["argen"] <= c <= ISOBAR["zephyr"] and c != cid for c in grave_ids)
        bonus(63 if has_ally else 12, "제피르의 묘지 소생 확인")
    if kind == "activate" and cid == ISOBAR["journal"]:
        starter_count = sum(ISOBAR["argen"] <= c <= ISOBAR["zephyr"] for c in hand_ids)
        bonus(63 if starter_count <= 1 else 28, "관측일지로 후속 전개 확보")
    if kind in {"special_summon", "xyz_summon"}:
        if cid == ISOBAR["tempest"] and opp_monsters > 0:
            bonus(80, "상대 카드 바운스 가능한 3소재 보스")
        elif cid == ISOBAR["bastion"] and opp_monsters == 0:
            bonus(55, "선공 스톰바스티온 견제")
        elif cid == ISOBAR["hawk"] and hand_count <= 3:
            bonus(50, "솔라 호크로 후속 몬스터 서치")

    if kind == "activate" and location == "monsterzone":
        if cid == ISOBAR["hawk"]:
            bonus(86, "솔라 호크 소재 제거 후 서치")
        if cid == ISOBAR["tempest"]:
            bonus(78 if opp_monsters > 0 else -92, "템페스트 바운스 유효성")
        if cid == ISOBAR["bolt"]:
            bonus(-72, "불필요한 레벨 조정 보류")
    if kind == "activate" and cid == ISOBAR["field"] and not own_field:
        bonus(100, "패의 중앙관측소를 즉시 발동")

    if kind == "activate":
        if cid in {ISOBAR["alert"], 14087893, 10045474} and opp_monsters == 0:
            bonus(-110, "상대 위협이 없을 때 견제 낭비 방지")
        if cid == ISOBAR["front"] and not own_field:
            bonus(-100, "기상 관측소 부재시 사용 보류")

    if kind == "set":
        if cid in {ISOBAR["alert"], 10045474}:
            bonus(26, "상대 턴 견제 카드 세트")
        if cid in {ISOBAR["field"], ISOBAR["journal"]}:
            bonus(-85, "중요한 전개 마법을 세트하지 않음")
    if kind == "end_phase" and any(
        c in hand_ids for c in (
            ISOBAR["field"], ISOBAR["argen"], ISOBAR["journal"],
            ISOBAR["cirrus"], ISOBAR["rain"], ISOBAR["nova"],
        )
    ) and not own_field:
        bonus(-100, "합법적인 초동 카드가 남아 있어 턴 종료 억제")

    if kind == "battle_phase":
        bonus(28 if own_monsters else -65, "전개 후 전투 기회")
    if kind == "end_phase" and own_monsters == 0 and hand_count > 1:
        bonus(-23, "전개 카드가 남았다면 종료 억제")

    if kind == "chain":
        if chain_from_self:
            bonus(-140, "자신의 체인에 무의미한 추가 발동 금지")
        elif chain_from_opp:
            if cid == ISOBAR["bastion"]:
                bonus(118, "상대 효과에 스톰바스티온 무효")
            elif cid in {14558127, 97268402, 10045474}:
                bonus(90, "상대 체인에 패트랩/무효")
            elif cid == ISOBAR["alert"]:
                bonus(85, "상대 체인에 긴급경보")
            elif cid == 14087893:
                bonus(24, "상대 효과에 달의 서")
    if kind == "pass":
        if chain_from_self:
            bonus(45, "자가 체인 보존")
        elif chain_from_opp:
            bonus(-3, "상대 발동에 대응 검토")

    if kind == "select_card":
        if location == "deck" and controller == 0:
            if cid == ISOBAR["field"] and not own_field:
                bonus(110, "중앙관측소 확보")
            elif cid == ISOBAR["argen"]:
                bonus(76 if cid not in hand_ids else 24, "아르젠 확보")
            elif cid in {ISOBAR["nova"], ISOBAR["rain"]}:
                bonus(78 if own_lv4 >= 1 else 38, "랭크 4 전개용 후속")
            elif cid == ISOBAR["zephyr"] and grave_ids:
                bonus(65, "제피르로 묘지 자원 활용")
            elif cid == ISOBAR["journal"]:
                bonus(48, "관측일지 서치")
        elif controller == 1 and target.get("is_faceup") is True:
            atk = max(0, _integer(target.get("attack")))
            bonus(15 + min(35, atk // 80), "공개된 상대 위협 카드 우선")

    # Hints may only be computed by an engine adapter, never from user prose.
    hints = action.get("trusted_hints")
    if isinstance(hints, dict):
        bonus(max(-50, min(50, _integer(hints.get("value_delta")))), "엔진 평가 힌트")
    if not reasons:
        reasons = ["기본 행동 우선순위"]
    return value, reasons


def decide(obs: dict) -> dict:
    actions = validate(obs)
    ranked = sorted(
        ((score(a, obs)[0], -i, a) for i, a in enumerate(actions)),
        key=lambda x: (x[0], x[1]), reverse=True
    )
    best = ranked[0][2]
    val, reasons = score(best, obs)
    return {
        "protocol": "duelmind.v1",
        "action_id": best["action_id"],
        "score": val,
        "reason": "; ".join(reasons),
        "ranked": [{"action_id": a["action_id"], "score": v} for v, _, a in ranked[:5]],
    }


def serve_stdio() -> None:
    """One observation JSON per line => one JSON decision per line."""
    import sys
    for line in sys.stdin:
        try:
            obs = json.loads(line)
            result = decide(obs)
        except (ValueError, TypeError, json.JSONDecodeError) as exc:
            result = {"protocol": "duelmind.v1", "error": str(exc)}
        print(json.dumps(result, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    serve_stdio()
