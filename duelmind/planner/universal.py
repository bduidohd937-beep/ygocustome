"""Conservative planning contracts for profiles without verified card rules."""
from __future__ import annotations

from typing import Any

try:
    from ..profiles.base import DeckProfile
except ImportError:  # Supports direct script execution through the legacy server.
    from profiles.base import DeckProfile


def goal_for_profile(profile: DeckProfile, observation: dict[str, Any]) -> str:
    """Return only a goal that is justified by the registered profile.

    Unimplemented profiles must never receive a fabricated combo goal.  The
    implemented Isobar planner remains in ``engine.py`` for V2.2 compatibility
    until its strategy rules are migrated into a dedicated profile module.
    """
    if not profile.implemented:
        return "safe_generic_fallback"
    return "profile_specific_planner_pending"
