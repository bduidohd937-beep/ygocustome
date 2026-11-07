from __future__ import annotations

from typing import Any

from ..profiles.registry import DECK_NAME_TO_PROFILE


def profile_payload(deck_name: str) -> dict[str, str]:
    """Return an explicit profile payload; never infer Isobar from card IDs."""
    return {
        "deck_name": deck_name,
        "deck_profile": DECK_NAME_TO_PROFILE.get(deck_name, "unknown"),
    }


def add_profile(observation: dict[str, Any], deck_name: str) -> dict[str, Any]:
    result = dict(observation)
    result.update(profile_payload(deck_name))
    return result
