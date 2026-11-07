from __future__ import annotations

from typing import Any

from .base import DeckProfile


OCEAN_TALE = {
    "marina": 210000301, "marin": 210000302, "belu": 210000303,
    "leviathan": 210000304, "barka": 210000305, "arca": 210000306,
    "link1": 210000307, "link2": 210000308, "adventure": 210000309,
    "treasure": 210000310, "calm_wave": 210000311, "rough_wave": 210000312,
    "battlefield": 210000313,
}
OCEAN_TALE_CARD_IDS = frozenset(OCEAN_TALE.values())
OCEAN_TALE_NAMES = {
    OCEAN_TALE["marina"]: "오션 테일 - 소녀 마리나",
    OCEAN_TALE["marin"]: "오션 테일 - 마린",
    OCEAN_TALE["belu"]: "오션 테일 - 고래 벨루",
    OCEAN_TALE["leviathan"]: "심해의 적 - 레비아탄",
    OCEAN_TALE["barka"]: "오션 테일 - 고대왕 고래 바르카",
    OCEAN_TALE["arca"]: "오션 테일 - 영해왕 고래 아르카",
    OCEAN_TALE["link1"]: "오션 테일 - 바다와 소녀",
    OCEAN_TALE["link2"]: "오션 테일 - 고래와 소녀",
    OCEAN_TALE["adventure"]: "오션 테일 - 모험의 시작",
    OCEAN_TALE["treasure"]: "오션 테일 - 보물 탐색",
    OCEAN_TALE["calm_wave"]: "오션 테일 - 잔잔한 파도",
    OCEAN_TALE["rough_wave"]: "오션 테일 - 거센 파도",
    OCEAN_TALE["battlefield"]: "오션 테일 - 결전의 장",
}

OCEANTALE_PROFILE = DeckProfile(
    profile_id="ocean_tale", display_name="오션 테일", implemented=True,
    card_ids=OCEAN_TALE_CARD_IDS, strategy_version="v4.1",
)

DEFAULT_WEIGHTS = {
    "immediate_gain": 1.0, "follow_up": 1.0, "interaction": 1.0,
    "resource_preservation": 1.0, "board_persistence": 1.0,
    "win_contribution": 1.0,
}


def _validate(observation: dict[str, Any]) -> list[dict[str, Any]]:
    actions = observation.get("legal_actions")
    if not isinstance(actions, list) or not 1 <= len(actions) <= 512:
        raise ValueError("legal_actions must contain 1-512 choices")
    seen: set[str] = set()
    for action in actions:
        if not isinstance(action, dict):
            raise ValueError("Each choice must be an object")
        action_id = action.get("action_id")
        if not isinstance(action_id, str) or not 1 <= len(action_id) <= 128 or action_id in seen:
            raise ValueError("Invalid or duplicate action_id")
        seen.add(action_id)
    return actions


def card_name(card_id: Any) -> str:
    try:
        return OCEAN_TALE_NAMES.get(int(card_id), "알 수 없는 카드")
    except (TypeError, ValueError):
        return "알 수 없는 카드"


def effect_identifier(action: dict[str, Any]) -> str:
    supplied = action.get("effect_profile")
    if isinstance(supplied, str) and supplied:
        return supplied
    return "{}:{}:{}".format(action.get("kind", "unknown"), action.get("card_id", 0),
                             action.get("activation_index", -1))


def _state(observation: dict[str, Any]) -> dict[str, Any]:
    value = observation.get("public_state")
    return value if isinstance(value, dict) else {}


def _integer(value: Any) -> int:
    return value if isinstance(value, int) and not isinstance(value, bool) else 0


def _goal(state: dict[str, Any]) -> str:
    if _integer(state.get("opponent_leviathan_count")) > 0:
        return "finish_leviathan_raid"
    if _integer(state.get("opponent_monster_count")) > 0:
        return "raid_and_remove_leviathan"
    if not state.get("own_field_spell"):
        return "establish_battlefield"
    return "establish_link_and_ritual"


def _score(action: dict[str, Any], state: dict[str, Any], weights: dict[str, float]) -> tuple[int, list[str]]:
    kind = action.get("kind", "")
    try:
        card_id = int(action.get("card_id", 0))
    except (TypeError, ValueError):
        card_id = 0
    score = 0
    reasons: list[str] = []

    def bonus(amount: int, reason: str) -> None:
        nonlocal score
        score += amount
        reasons.append(reason)

    if kind in {"pass", "end_phase"}:
        bonus(-20 if state.get("opponent_monster_count") else 0, "남은 합법 전개 검토")
    elif card_id == OCEAN_TALE["treasure"]:
        bonus(75, "핵심 오션 테일 카드 서치")
    elif card_id == OCEAN_TALE["marina"]:
        bonus(68, "마법 서치 초동")
    elif card_id == OCEAN_TALE["marin"]:
        bonus(64, "패/묘지 특수 소환 및 상급 서치")
    elif card_id == OCEAN_TALE["belu"]:
        bonus(52, "마리나 연계 특수 소환 및 자원 회수")
    elif card_id == OCEAN_TALE["calm_wave"]:
        bonus(62, "레벨 5 이하 덱 특수 소환")
    elif card_id == OCEAN_TALE["adventure"]:
        bonus(72, "검증된 의식 전개 시작")
    elif card_id == OCEAN_TALE["link1"]:
        bonus(70, "링크 1 서치와 묘지 소생")
    elif card_id == OCEAN_TALE["link2"]:
        bonus(78, "링크 2 자원 회수와 레비아탄 레이드")
    elif card_id == OCEAN_TALE["barka"]:
        bonus(82, "바르카로 레비아탄을 상대 필드에 호출")
    elif card_id == OCEAN_TALE["arca"]:
        bonus(90 if _integer(state.get("opponent_leviathan_count")) else 35,
              "레비아탄 토벌 후 3회 공격 피니시")
    elif card_id == OCEAN_TALE["battlefield"]:
        bonus(58, "결전의 장으로 후속 속공 마법 확보")
    elif card_id == OCEAN_TALE["rough_wave"]:
        bonus(38, "전투 강화와 상대 효과 내성")
    elif card_id == OCEAN_TALE["leviathan"]:
        bonus(45, "레비아탄의 오션 테일 서치")

    if kind in {"link_summon", "ritual_summon", "extra_summon"}:
        bonus(18, "엑스트라/의식 전개 행동")
    if state.get("opponent_monster_count") and card_id in {
        OCEAN_TALE["barka"], OCEAN_TALE["link2"], OCEAN_TALE["arca"],
    }:
        bonus(24, "상대 위협에 대한 레이드 대응")
    if state.get("own_field_spell") and card_id == OCEAN_TALE["battlefield"]:
        bonus(-25, "이미 결전의 장이 있어 중복 발동을 회피")
    if _integer(state.get("hand_count")) <= 1 and card_id == OCEAN_TALE["link2"]:
        bonus(-12, "링크 2 무효 비용으로 남길 패 부족")

    evaluation = action.get("verified_evaluation")
    if isinstance(evaluation, dict):
        labels = {
            "immediate_gain": "즉시 이득", "follow_up": "후속 전개",
            "interaction": "상대 견제력", "resource_preservation": "자원 보존",
            "board_persistence": "필드 지속성", "win_contribution": "승리 기여도",
        }
        for key, label in labels.items():
            value = evaluation.get(key)
            if isinstance(value, (int, float)) and value == value:
                score += round(max(-50.0, min(50.0, float(value))) * weights.get(key, 1.0))
                reasons.append(label + " 평가")
    if not reasons:
        reasons.append("기본 합법 행동 우선순위")
    return score, reasons


def _path(action: dict[str, Any]) -> list[str]:
    return {
        OCEAN_TALE["marina"]: ["summon_marina", "search_ocean_tale_spell"],
        OCEAN_TALE["marin"]: ["special_summon_marin", "search_level_5_ocean_tale"],
        OCEAN_TALE["link1"]: ["link_summon_link1", "search_and_revive"],
        OCEAN_TALE["link2"]: ["link_summon_link2", "recover_and_prepare_raid"],
        OCEAN_TALE["adventure"]: ["ritual_summon", "evaluate_material_and_follow_up"],
        OCEAN_TALE["barka"]: ["summon_barka", "summon_leviathan_to_opponent"],
        OCEAN_TALE["arca"]: ["summon_arca", "remove_leviathan", "three_attacks"],
    }.get(action.get("card_id"), ["execute_offered_action"])


def _resource_change(action: dict[str, Any]) -> dict[str, str]:
    cid = action.get("card_id")
    if cid in {OCEAN_TALE["treasure"], OCEAN_TALE["marina"], OCEAN_TALE["marin"]}:
        return {"hand": "+1 searched card", "follow_up": "ocean_tale_resource"}
    if cid in {OCEAN_TALE["link1"], OCEAN_TALE["link2"]}:
        return {"field": "+1 link monster", "grave": "may be revived/recovered"}
    if cid in {OCEAN_TALE["barka"], OCEAN_TALE["arca"]}:
        return {"field": "+1 ritual monster", "opponent_field": "leviathan raid state if legal"}
    return {"status": "profile_rule_based_estimate"}


def decide_ocean_tale(observation: dict[str, Any], config: dict[str, float] | None = None) -> dict[str, Any]:
    actions = _validate(observation)
    state = _state(observation)
    weights = config or DEFAULT_WEIGHTS
    ranked = []
    for index, action in enumerate(actions):
        value, reasons = _score(action, state, weights)
        ranked.append((value, -index, action, reasons))
    ranked.sort(key=lambda item: (item[0], item[1]), reverse=True)
    best_value, _, best, best_reasons = ranked[0]
    candidates = []
    for rank, (value, _, action, reasons) in enumerate(ranked, 1):
        candidates.append({
            "rank": rank, "action_id": action["action_id"], "kind": action.get("kind", "unknown"),
            "card_id": action.get("card_id", 0), "card_name": card_name(action.get("card_id", 0)),
            "location": action.get("location", ""), "effect_identifier": effect_identifier(action),
            "activation_index": action.get("activation_index"), "score": value, "reasons": reasons,
        })
    return {
        "protocol": "duelmind.v1", "profile_id": "ocean_tale", "profile_status": "supported",
        "action_id": best["action_id"], "score": best_value, "reason": "; ".join(best_reasons),
        "fallback": False, "candidate_count": len(candidates), "candidates": candidates,
        "ranked": [{"action_id": item["action_id"], "score": item["score"]} for item in candidates[:5]],
        "strategy_goal": _goal(state), "chosen_path": _path(best),
        "major_alternatives": [
            {"action_id": item["action_id"], "score": item["score"], "reason": "; ".join(item["reasons"])}
            for item in candidates[1:4]
        ],
        "expected_resource_change": _resource_change(best),
        "actual_result": "unobserved_before_execution",
        "plan_change_reason": "no_post_action_observation_received",
    }
