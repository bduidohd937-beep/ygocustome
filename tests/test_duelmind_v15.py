"""DUELMIND V1.5 regression scenarios based on actual Isobar Lua effects.

All observations contain ONLY legal actions offered by the host.
These are synthetic unit tests, not evidence of a complete EDOPro match.
"""
import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("duelmind_v15", ROOT / "duelmind" / "engine.py")
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)


def decision(actions, **state):
    return engine.decide({"public_state": state, "legal_actions": actions})


def a(key, kind, card_id=0, location="", controller=0, target=None):
    return {
        "action_id": key, "kind": kind,
        "card_id": card_id, "location": location,
        "controller": controller, "target": target or {},
    }


class IsobarV15Tactics(unittest.TestCase):
    def test_field_spell_before_normal_summon(self):
        result = decision([
            a("argen", "normal_summon", 210000201, "hand"),
            a("station", "activate", 210000210, "hand"),
            a("end", "end_phase"),
        ], own_field_spell=False, hand_ids=[210000201, 210000210], hand_count=5)
        self.assertEqual(result["action_id"], "station")

    def test_hand_rain_ignition_counts_as_extension(self):
        result = decision([
            a("set", "set", 210000213, "hand"),
            a("rain", "activate", 210000202, "hand"),
            a("end", "end_phase"),
        ], own_field_spell=True, own_level4_count=1, hand_ids=[210000202])
        self.assertEqual(result["action_id"], "rain")

    def test_hand_nova_ignition_counts_as_extension(self):
        result = decision([
            a("normal", "normal_summon", 210000204, "hand"),
            a("nova", "activate", 210000205, "hand"),
        ], own_field_spell=True, own_level4_count=1, hand_ids=[210000205])
        self.assertEqual(result["action_id"], "nova")

    def test_first_turn_bastion_before_wasting_spell(self):
        result = decision([
            a("xyz", "xyz_summon", 210000208, "extra"),
            a("front", "activate", 210000211, "hand"),
            a("set", "set", 210000213, "hand"),
        ], going_first=True, own_field_spell=True, own_monster_count=2,
            own_level4_count=2, opponent_monster_count=0)
        self.assertEqual(result["action_id"], "xyz")

    def test_second_turn_tempest_bounce(self):
        result = decision([
            a("storm", "xyz_summon", 210000209, "extra"),
            a("bastion", "xyz_summon", 210000208, "extra"),
        ], going_first=False, opponent_monster_count=2, own_monster_count=3)
        self.assertEqual(result["action_id"], "storm")

    def test_battle_before_set_when_ready(self):
        result = decision([
            a("set", "set", 210000213, "hand"),
            a("battle", "battle_phase"),
            a("end", "end_phase"),
        ], own_monster_count=2, opponent_monster_count=0)
        self.assertEqual(result["action_id"], "battle")

    def test_pass_self_chain_even_when_enemy_monster_exists(self):
        result = decision([
            a("chain", "chain", 210000208, "monsterzone"),
            a("pass", "pass"),
        ], chain_from_opponent=False, opponent_monster_count=3, opponent_threat=1)
        self.assertEqual(result["action_id"], "pass")

    def test_negate_opponent_monster_chain(self):
        result = decision([
            a("chain", "chain", 210000208, "monsterzone"),
            a("pass", "pass"),
        ], chain_from_opponent=True, chain_card_is_monster=True,
           opponent_monster_count=1, opponent_threat=2)
        self.assertEqual(result["action_id"], "chain")

    def test_no_arbitrary_unknown_chain(self):
        result = decision([
            a("chain", "chain", 12345678, "spellzone"),
            a("pass", "pass"),
        ], chain_from_opponent=True, opponent_threat=2)
        self.assertEqual(result["action_id"], "pass")

    def test_search_field_spell_first_when_missing(self):
        result = decision([
            a("argen", "select_card", 210000201, "deck"),
            a("station", "select_card", 210000210, "deck"),
        ], own_field_spell=False, hand_ids=[210000204])
        self.assertEqual(result["action_id"], "station")

    def test_choose_faceup_large_enemy_threat(self):
        result = decision([
            a("small", "select_card", 11111, "monsterzone", controller=1,
              target={"is_faceup": True, "attack": 500}),
            a("big", "select_card", 22222, "monsterzone", controller=1,
              target={"is_faceup": True, "attack": 3000}),
        ], opponent_monster_count=2)
        self.assertEqual(result["action_id"], "big")

    def test_never_returns_unoffered_choice(self):
        result = decision([
            a("only", "end_phase"),
        ])
        self.assertEqual(result["action_id"], "only")

    def test_v2_cirrus_is_preferred_to_ending_without_field(self):
        result = decision([
            a("cirrus", "special_summon", 210000214, "hand"),
            a("end", "end_phase"),
        ], own_field_spell=False, own_monster_count=0,
           hand_ids=[210000214], hand_count=1)
        self.assertEqual(result["action_id"], "cirrus")

    def test_v2_storm_boundary_is_used_for_backrow_threat(self):
        result = decision([
            a("boundary", "activate", 210000216, "hand"),
            a("end", "end_phase"),
        ], own_field_spell=True, own_monster_count=1,
           opponent_monster_count=2, opponent_threat=1)
        self.assertEqual(result["action_id"], "boundary")


if __name__ == "__main__":
    unittest.main()
