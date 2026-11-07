import unittest
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("duelmind_v13_engine", ROOT / "duelmind" / "engine.py")
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)


class MainPhaseChainDecisionTests(unittest.TestCase):
    def test_main_phase_argen_priority(self):
        obs = {"public_state": {"going_first": True, "hand_count": 5},
            "legal_actions": [
                {"action_id": "0", "kind": "activate", "card_id": 210000211},
                {"action_id": "1", "kind": "normal_summon", "card_id": 210000201},
                {"action_id": "2", "kind": "set", "card_id": 210000213},
            ]}
        self.assertEqual(engine.decide(obs)["action_id"], "1")

    def test_optional_chain_can_pass(self):
        obs = {"public_state": {"opponent_threat": 0},
            "legal_actions": [
                {"action_id": "0", "kind": "chain", "card_id": 14087893},
                {"action_id": "1", "kind": "pass", "card_id": 0}
            ]}
        self.assertEqual(engine.decide(obs)["action_id"], "1")

    def test_chain_stormbastion_when_threat(self):
        obs = {"public_state": {"opponent_threat": 1},
            "legal_actions": [
                {"action_id": "0", "kind": "chain", "card_id": 210000208},
                {"action_id": "1", "kind": "pass", "card_id": 0}
            ]}
        self.assertEqual(engine.decide(obs)["action_id"], "0")

    def test_unknown_chain_passes(self):
        obs = {"public_state": {"opponent_threat": 1},
            "legal_actions": [
                {"action_id": "0", "kind": "chain", "card_id": 12345678},
                {"action_id": "1", "kind": "pass", "card_id": 0}
            ]}
        self.assertEqual(engine.decide(obs)["action_id"], "1")


if __name__ == "__main__":
    unittest.main()
