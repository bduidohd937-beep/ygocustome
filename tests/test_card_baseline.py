import copy
import json
from pathlib import Path
import tempfile
import unittest

from duelmind.core.knowledge import ASSET_ROOT, BASELINE_ID, cards, verify_assets
from duelmind.engine import decide


class CardBaselineTests(unittest.TestCase):
    def test_all_sixteen_assets_and_metadata_are_pinned(self):
        m = verify_assets()
        self.assertEqual(sorted(cards()), list(range(210000201, 210000217)))
        self.assertEqual(len([p for p in m["files"] if p.endswith(".lua")]), 17)
        self.assertEqual(m["source_commit"], "49a0643ca322cc6ea393631c59190c20a0e82a28")

    def test_changed_asset_fails_closed(self):
        import shutil
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "snapshot"
            shutil.copytree(ASSET_ROOT, root)
            (root / "script/c210000209.lua").write_text("-- altered", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "hash mismatch"):
                verify_assets(root)

    def test_runtime_does_not_reuse_obsolete_effect_claims(self):
        obs = {"protocol_version": 2, "duel_id": "test", "profile_id": "isobar",
               "decision_point": "main", "card_baseline": BASELINE_ID,
               "legal_actions": [{"action_id": "a", "kind": "activate", "card_id": 210000209,
                                  "effect_profile": "tempest_effect_2_target_bounce"}]}
        original = copy.deepcopy(obs)
        result = decide(obs)
        self.assertEqual(obs, original)
        self.assertEqual(result["card_baseline"], BASELINE_ID)
        self.assertEqual(result["chosen_path"], ["effect_path_not_verified"])
        self.assertNotIn("overlay", result["expected_resource_change"])
        self.assertEqual(result["effect_identifier"], "unknown")

    def test_no_rule_changes_are_hidden_in_snapshot(self):
        m = verify_assets()
        self.assertFalse(m["semantic_equivalence_to_design_certified"])
        self.assertTrue(m["unresolved_text_implementation_differences"])
        self.assertEqual(cards()[210000214]["name"], "흑철기상청 - 이소바르 시러스")
