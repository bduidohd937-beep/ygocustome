"""Immutable, versioned card facts. Lua is preserved, not interpreted as prose."""
from functools import lru_cache
import hashlib
import json
from pathlib import Path

BASELINE_ID = "isobar-v2.0.2-49a0643"
ASSET_ROOT = Path(__file__).resolve().parents[1] / "assets" / "isobar-v2.0.2"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def verify_assets(root: Path = ASSET_ROOT) -> dict:
    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    if manifest["baseline_id"] != BASELINE_ID:
        raise ValueError("Unsupported card baseline")
    for name, expected in manifest["files"].items():
        path = (root / name).resolve()
        if not path.is_relative_to(root.resolve()) or sha256(path.read_bytes()) != expected:
            raise ValueError("Card asset hash mismatch: " + name)
    return manifest


@lru_cache(maxsize=1)
def cards() -> dict[int, dict]:
    verify_assets()
    return {c["id"]: c for c in json.loads((ASSET_ROOT / "cards.json").read_text(encoding="utf-8"))}


def runtime_observation(obs: dict) -> dict:
    """Prevent legacy semantic labels from asserting rules of the deployed snapshot.

    Most deployed effects omit SetDescription. A raw description (often zero)
    cannot uniquely identify a Lua registration; keep the server action ordinal.
    The legacy heuristic still ranks cards, without claiming a simulated outcome.
    """
    if obs.get("card_baseline") != BASELINE_ID:
        raise ValueError("Unsupported card baseline")
    result = dict(obs)
    actions = []
    for action in obs["legal_actions"]:
        copy = dict(action)
        copy.pop("verified_evaluation", None)
        copy.pop("trusted_hints", None)
        copy["effect_profile"] = "runtime_effect_unverified"
        actions.append(copy)
    result["legal_actions"] = actions
    return result


def annotate_runtime(result: dict, obs: dict) -> dict:
    known = cards()
    output = dict(result)
    output["card_baseline"] = BASELINE_ID
    output["rules_source_commit"] = "49a0643ca322cc6ea393631c59190c20a0e82a28"
    output["chosen_path"] = ["effect_path_not_verified"]
    output["expected_resource_change"] = {"status": "not_derived_before_resolution"}
    output["reason"] = "기존 카드별 휴리스틱; 실제 효과는 고정 Lua와 코어가 판정"
    output["candidates"] = [dict(c, card_name=known.get(c["card_id"], {}).get("name", c["card_name"]),
                                    reasons=["legacy_card_heuristic_not_a_rules_prediction"])
                            for c in result.get("candidates", [])]
    output["major_alternatives"] = []
    return output
