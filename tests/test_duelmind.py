import importlib.util
import json
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "duelmind" / "engine.py"
spec = importlib.util.spec_from_file_location("duelmind_engine", MODULE_PATH)
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)


class DecisionEngineTests(unittest.TestCase):
    def test_argen_is_preferred_as_opening(self):
        obs = {
            "public_state": {"phase": "main1", "weather": "none", "going_first": True},
            "legal_actions": [
                {"action_id": "pass", "kind": "end_phase"},
                {"action_id": "summon-bolt", "kind": "normal_summon", "card_id": 210000203},
                {"action_id": "summon-argen", "kind": "normal_summon", "card_id": 210000201},
            ],
        }
        self.assertEqual(engine.decide(obs)["action_id"], "summon-argen")

    def test_bastion_preferred_on_empty_enemy_field(self):
        obs = {
            "public_state": {"going_first": True, "opponent_monster_count": 0},
            "legal_actions": [
                {"action_id": "hawk", "kind": "xyz_summon", "card_id": 210000207},
                {"action_id": "bastion", "kind": "xyz_summon", "card_id": 210000208},
                {"action_id": "tempest", "kind": "xyz_summon", "card_id": 210000209},
            ],
        }
        self.assertEqual(engine.decide(obs)["action_id"], "bastion")

    def test_choice_never_invented(self):
        obs = {"legal_actions": [{"action_id": "sole", "kind": "pass"}]}
        result = engine.decide(obs)
        self.assertEqual(result["action_id"], "sole")

    def test_duplicate_action_ids_rejected(self):
        obs = {"legal_actions": [
            {"action_id": "same", "kind": "pass"},
            {"action_id": "same", "kind": "activate"},
        ]}
        with self.assertRaises(engine.InvalidObservation):
            engine.decide(obs)

    def test_invalid_action_kind_rejected(self):
        with self.assertRaises(engine.InvalidObservation):
            engine.decide({"legal_actions": [{"action_id": "1", "kind": "cheat"}]})

    def test_tie_break_is_stable(self):
        obs = {"legal_actions": [
            {"action_id": "a", "kind": "set"},
            {"action_id": "b", "kind": "set"},
        ]}
        self.assertEqual(engine.decide(obs)["action_id"], "a")

    def test_stdio_protocol(self):
        payload = json.dumps({"legal_actions": [{"action_id": "end", "kind": "end_phase"}]}) + "\n"
        proc = subprocess.run(
            [sys.executable, str(MODULE_PATH)], input=payload, text=True,
            capture_output=True, check=True, timeout=10
        )
        response = json.loads(proc.stdout.strip())
        self.assertEqual(response["action_id"], "end")
        self.assertNotIn("error", response)


if __name__ == "__main__":
    unittest.main()
