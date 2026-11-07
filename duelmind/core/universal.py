from __future__ import annotations

from typing import Any

try:
    from ..profiles.base import DeckProfile
    from ..planner.universal import goal_for_profile
except ImportError:  # Supports ``python duelmind/engine.py`` and legacy loaders.
    from profiles.base import DeckProfile
    from planner.universal import goal_for_profile


def _card_name(action: dict[str, Any]) -> str:
    value = action.get("card_name")
    return value if isinstance(value, str) and value else "알 수 없는 카드"


def _validate_actions(actions: Any) -> list[dict[str, Any]]:
    if not isinstance(actions, list) or not 1 <= len(actions) <= 512:
        raise ValueError("legal_actions must contain 1-512 choices")
    seen: set[str] = set()
    for action in actions:
        if not isinstance(action, dict):
            raise ValueError("Each choice must be an object")
        action_id = action.get("action_id")
        if not isinstance(action_id, str) or not 1 <= len(action_id) <= 128:
            raise ValueError("Invalid action_id")
        if action_id in seen:
            raise ValueError("Invalid or duplicate action_id")
        seen.add(action_id)
    return actions


def _safe_action(actions: list[dict[str, Any]]) -> dict[str, Any]:
    for preferred in ("pass", "end_phase"):
        for action in actions:
            if action.get("kind") == preferred:
                return action
    return actions[0]


def decide_unsupported(obs: dict[str, Any], profile: DeckProfile) -> dict[str, Any]:
    actions = _validate_actions(obs.get("legal_actions"))
    chosen = _safe_action(actions)
    strategy_goal = goal_for_profile(profile, obs)
    candidates = [
        {
            "rank": index,
            "action_id": action["action_id"],
            "kind": action.get("kind", "unknown"),
            "card_id": action.get("card_id", 0),
            "card_name": _card_name(action),
            "score": 0,
            "reasons": ["범용 안전 fallback"],
        }
        for index, action in enumerate(actions, 1)
    ]
    return {
        "protocol": "duelmind.v1",
        "profile_id": profile.profile_id,
        "profile_status": "unimplemented" if not profile.implemented else "supported",
        "action_id": chosen["action_id"],
        "score": 0,
        "reason": "덱별 전략 프로필이 없어 합법적인 안전 fallback을 선택",
        "fallback": True,
        "fallback_reason": "unsupported_deck_profile",
        "candidate_count": len(candidates),
        "candidates": candidates,
        "ranked": [{"action_id": item["action_id"], "score": 0}
                    for item in candidates[:5]],
        "strategy_goal": strategy_goal,
        "chosen_path": ["no_deck_specific_plan"],
        "major_alternatives": [],
        "expected_resource_change": {"status": "not_derived_for_unsupported_profile"},
        "actual_result": "unobserved_before_execution",
        "plan_change_reason": "unsupported_profile_no_plan_created",
        "required_inputs": profile.required_inputs,
    }
