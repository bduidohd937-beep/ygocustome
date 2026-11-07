from __future__ import annotations

from typing import Any

from .base import DeckProfile
from .isobar import ISOBAR_PROFILE
from .oceantale import OCEANTALE_PROFILE

UNKNOWN_PROFILE = DeckProfile(
    profile_id="unknown",
    display_name="알 수 없는 덱",
    implemented=False,
    required_inputs=("WindBot 덱 이름 또는 명시적 profile_id",),
)

PROFILES: dict[str, DeckProfile] = {
    ISOBAR_PROFILE.profile_id: ISOBAR_PROFILE,
    OCEANTALE_PROFILE.profile_id: OCEANTALE_PROFILE,
    UNKNOWN_PROFILE.profile_id: UNKNOWN_PROFILE,
}

DECK_NAME_TO_PROFILE = {
    "DuelmindIsobar": "isobar",
    "AI_DuelmindIsobar": "isobar",
    "OceanTale": "ocean_tale",
    "AI_OceanTale": "ocean_tale",
}


def get_profile(profile_id: str | None) -> DeckProfile:
    return PROFILES.get(profile_id or "unknown", UNKNOWN_PROFILE)


def profile_id_from_observation(obs: dict[str, Any]) -> str | None:
    profile_id = obs.get("deck_profile")
    if profile_id is None:
        deck_name = obs.get("deck_name")
        if isinstance(deck_name, str):
            return DECK_NAME_TO_PROFILE.get(deck_name, "unknown")
        state = obs.get("public_state") or {}
        if isinstance(state, dict):
            profile_id = state.get("deck_profile")
            if profile_id is None:
                deck_name = state.get("deck_name")
                if isinstance(deck_name, str):
                    return DECK_NAME_TO_PROFILE.get(deck_name, "unknown")
    return profile_id if isinstance(profile_id, str) else None
