import unittest

from duelmind import engine
from duelmind.adapters.windbot import add_profile, profile_payload
from duelmind.profiles.registry import get_profile, profile_id_from_observation


def action(action_id, kind, card_id=0):
    return {"action_id": action_id, "kind": kind, "card_id": card_id}


class DuelmindV3ProfileTests(unittest.TestCase):
    def test_explicit_isobar_profile_preserves_v22_strategy(self):
        result = engine.decide({
            "deck_profile": "isobar",
            "public_state": {"own_field_spell": False, "hand_count": 2},
            "legal_actions": [
                action("station", "activate", 210000210),
                action("end", "end_phase"),
            ],
        })
        self.assertEqual(result["action_id"], "station")
        self.assertEqual(result["profile_id"], "isobar")
        self.assertEqual(result["profile_status"], "supported")

    def test_ocean_tale_is_registered_and_supported(self):
        profile = get_profile("ocean_tale")
        self.assertTrue(profile.implemented)
        self.assertEqual(profile.strategy_version, "v4.1")
        result = engine.decide({
            "deck_profile": "ocean_tale",
            "legal_actions": [
                action("activate", "activate", 210000310),
                action("end", "end_phase"),
            ],
        })
        self.assertEqual(result["action_id"], "activate")
        self.assertEqual(result["profile_status"], "supported")
        self.assertEqual(result["strategy_goal"], "establish_battlefield")
        self.assertFalse(result["fallback"])

    def test_ocean_tale_raid_and_finisher_priorities(self):
        raid = engine.decide({
            "deck_profile": "ocean_tale",
            "public_state": {"opponent_monster_count": 1, "opponent_leviathan_count": 1},
            "legal_actions": [
                action("arca", "special_summon", 210000306),
                action("end", "end_phase"),
            ],
        })
        self.assertEqual(raid["action_id"], "arca")
        self.assertEqual(raid["strategy_goal"], "finish_leviathan_raid")
        self.assertEqual(raid["chosen_path"][-1], "three_attacks")

    def test_ocean_tale_profile_does_not_invent_actions(self):
        result = engine.decide({
            "deck_profile": "ocean_tale",
            "legal_actions": [action("only", "end_phase", 210000304)],
        })
        self.assertEqual(result["action_id"], "only")
        self.assertEqual(result["candidate_count"], 1)

    def test_unknown_profile_never_falls_back_to_isobar(self):
        result = engine.decide({
            "deck_profile": "unknown",
            "legal_actions": [
                action("station", "activate", 210000210),
                action("pass", "pass"),
            ],
        })
        self.assertEqual(result["action_id"], "pass")
        self.assertEqual(result["profile_id"], "unknown")
        self.assertTrue(result["fallback"])

    def test_legacy_observation_keeps_isobar_compatibility(self):
        result = engine.decide({
            "legal_actions": [
                action("argen", "normal_summon", 210000201),
                action("end", "end_phase"),
            ],
        })
        self.assertEqual(result["action_id"], "argen")
        self.assertEqual(result["profile_status"], "legacy_compatibility")

    def test_windbot_adapter_emits_explicit_profile(self):
        source = (__import__("pathlib").Path(__file__).resolve().parents[1]
                  / "duelmind" / "windbot" / "DuelmindIsobarExecutor.cs").read_text(encoding="utf-8")
        self.assertIn('"deck_profile"', source)
        self.assertIn('private const string DeckProfile = "isobar";', source)
        self.assertEqual(profile_payload("DuelmindIsobar"), {
            "deck_name": "DuelmindIsobar",
            "deck_profile": "isobar",
        })
        self.assertEqual(profile_payload("not-registered")["deck_profile"], "unknown")
        self.assertEqual(add_profile({"legal_actions": []}, "OceanTale")["deck_profile"],
                         "ocean_tale")

    def test_profile_precedence_is_explicit(self):
        self.assertEqual(profile_id_from_observation({
            "deck_profile": "ocean_tale",
            "public_state": {"deck_name": "DuelmindIsobar"},
        }), "ocean_tale")
        self.assertEqual(profile_id_from_observation({
            "deck_name": "OceanTale",
        }), "ocean_tale")
        self.assertEqual(profile_id_from_observation({
            "public_state": {"deck_name": "DuelmindIsobar"},
        }), "isobar")


if __name__ == "__main__":
    unittest.main()
