"""Deck-independent legal action validation."""
from typing import Any
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
