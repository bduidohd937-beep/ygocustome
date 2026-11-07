import json
import tempfile
import unittest
from pathlib import Path

from duelmind import engine


def action(key, kind, card_id=0, location="", evaluation=None):
    value = {
        "action_id": key,
        "kind": kind,
        "card_id": card_id,
        "location": location,
        "controller": 0,
        "target": {},
    }
    if evaluation is not None:
        value["verified_evaluation"] = evaluation
    return value


class DuelmindV21DecisionTests(unittest.TestCase):
    def test_executor_has_trace_and_legal_fallback_hooks(self):
        source = (Path(__file__).resolve().parents[1] / "duelmind" / "windbot"
                  / "DuelmindIsobarExecutor.cs").read_text(encoding="utf-8")
        self.assertIn("duelmind-decisions.jsonl", source)
        self.assertIn("python_connection_failed", source)
        self.assertIn("FindFallbackIndex", source)
        self.assertIn("VerifiedEvaluation", source)

    def test_decision_trace_contains_every_legal_candidate(self):
        result = engine.decide({
            "public_state": {
                "turn": 1,
                "phase": "main1",
                "own_field_spell": False,
                "hand_ids": [210000210, 210000201],
                "hand_count": 2,
            },
            "legal_actions": [
                action("station", "activate", 210000210, "hand"),
                action("argen", "normal_summon", 210000201, "hand"),
                action("end", "end_phase"),
            ],
        })
        self.assertEqual(result["action_id"], "station")
        self.assertEqual(result["candidate_count"], 3)
        self.assertEqual([item["action_id"] for item in result["candidates"]],
                         ["station", "argen", "end"])
        self.assertEqual(result["candidates"][0]["card_name"], "흑철기상청 - 중앙관측소")
        self.assertTrue(result["candidates"][0]["reasons"])

    def test_verified_strategy_weights_can_change_a_tie(self):
        obs = {
            "public_state": {"hand_count": 4},
            "legal_actions": [
                action("resource", "activate", 210000212, "hand",
                       {"resource_preservation": 10}),
                action("pressure", "activate", 210000216, "hand",
                       {"interaction": 10}),
            ],
        }
        result = engine.decide(obs, {
            **engine.DEFAULT_WEIGHTS,
            "resource_preservation": 3.0,
            "interaction": 0.0,
        })
        self.assertEqual(result["action_id"], "resource")

    def test_unverified_future_state_is_not_used(self):
        result = engine.decide({
            "public_state": {"hand_count": 1},
            "legal_actions": [
                action("plain", "pass"),
                {**action("imaginary", "end_phase"),
                 "future_state": {"wins_next_turn": True}},
            ],
        })
        self.assertEqual(result["action_id"], "plain")

    def test_strategy_config_is_bounded_and_optional(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "strategy.json"
            path.write_text(json.dumps({"weights": {
                "follow_up": 99,
                "interaction": -5,
                "unknown": 2,
            }}), encoding="utf-8")
            config = engine.load_strategy_config(path)
        self.assertEqual(config["follow_up"], 3.0)
        self.assertEqual(config["interaction"], 0.0)
        self.assertNotIn("unknown", config)


if __name__ == "__main__":
    unittest.main()
