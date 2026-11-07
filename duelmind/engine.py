"""DUELMIND V1: deterministic strategy over engine-provided legal actions.

This module deliberately does not generate game actions. A trusted EDOPro adapter
must enumerate the exact legal choices and execute the returned action_id.
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Any
import json

ISOBAR = {
    "argen": 210000201, "rain": 210000202, "bolt": 210000203,
    "sol": 210000204, "nova": 210000205, "zephyr": 210000206,
    "hawk": 210000207, "bastion": 210000208, "tempest": 210000209,
    "field": 210000210, "front": 210000211, "journal": 210000212,
    "alert": 210000213,
}
KINDS = {
    "activate", "normal_summon", "special_summon", "xyz_summon",
    "set", "attack", "change_position", "pass", "end_phase",
    "choose", "chain", "select_card",
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
    weather = str(state.get("weather", "none")).lower()
    going_first = bool(state.get("going_first", False))
    opp_monsters = max(0, _integer(state.get("opponent_monster_count")))
    own_monsters = max(0, _integer(state.get("own_monster_count")))
    hand_count = max(0, _integer(state.get("hand_count")))
    enemy_threat = max(0, _integer(state.get("opponent_threat"), 0))
    kind = action["kind"]
    cid = _integer(action.get("card_id"))
    target = action.get("target") or {}
    if not isinstance(target, dict):
        target = {}
    reasons: list[str] = []
    value = {
        "normal_summon": 35, "special_summon": 32, "xyz_summon": 40,
        "activate": 25, "chain": -15, "attack": 20, "set": 13,
        "change_position": 5, "select_card": 0, "choose": 0,
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
