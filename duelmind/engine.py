"""Compatibility API for deck-independent dispatch."""
from __future__ import annotations
import json
try:
    from duelmind.profiles.isobar_policy import *
    from duelmind.profiles.isobar_policy import _decide_isobar, _integer
    from duelmind.core.contracts import InvalidObservation, validate
    from duelmind.core.protocol import prepare, finish
except ImportError:
    from profiles.isobar_policy import *
    from profiles.isobar_policy import _decide_isobar, _integer
    from core.contracts import InvalidObservation, validate
    from core.protocol import prepare, finish

try:
    from duelmind.core.universal import decide_unsupported
    from duelmind.profiles.registry import get_profile, profile_id_from_observation
    from duelmind.profiles.oceantale import decide_ocean_tale
    from duelmind.core.knowledge import runtime_observation, annotate_runtime
except ImportError:  # Direct script execution keeps the V2.2 server compatible.
    from core.universal import decide_unsupported
    from profiles.registry import get_profile, profile_id_from_observation
    from profiles.oceantale import decide_ocean_tale
    from core.knowledge import runtime_observation, annotate_runtime


def _dispatch(obs: dict, config: dict[str, float] | None = None) -> dict:
    """Dispatch an observation to an explicit deck profile.

    Requests from older V2.2 adapters omit ``deck_profile``.  They retain the
    established Isobar behavior for compatibility.  New adapters must send an
    explicit profile; unknown or unimplemented decks receive only the safe
    generic fallback and are never inferred from card IDs.
    """
    profile_id = profile_id_from_observation(obs)
    if profile_id is None:
        result = _decide_isobar(obs, config)
        result["profile_id"] = "isobar"
        result["profile_status"] = "legacy_compatibility"
        return result

    profile = get_profile(profile_id)
    if profile.profile_id == "isobar":
        if obs.get("card_baseline"):
            result = annotate_runtime(_decide_isobar(runtime_observation(obs), config), obs)
        else:
            result = _decide_isobar(obs, config)
        result["profile_id"] = "isobar"
        result["profile_status"] = "supported"
        return result
    if profile.profile_id == "ocean_tale":
        return decide_ocean_tale(obs, config)
    return decide_unsupported(obs, profile)


def decide(obs: dict, config: dict | None = None) -> dict:
    normalized = prepare(obs)
    return finish(obs, _dispatch(normalized, config))


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
