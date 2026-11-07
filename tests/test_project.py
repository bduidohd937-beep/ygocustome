import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

class TestCardProject(unittest.TestCase):
    def test_unique_ids_and_scripts(self):
        cards = json.loads((ROOT / "cards/cards.json").read_text(encoding="utf-8"))
        ids = [card["id"] for card in cards]
        self.assertEqual(len(ids), len(set(ids)))
        for card in cards:
            self.assertIsInstance(card["id"], int)
            self.assertGreater(card["id"], 0)
            script = ROOT / "expansions" / "script" / f"c{card['id']}.lua"
            self.assertTrue(script.is_file(), str(script))

if __name__ == "__main__":
    unittest.main()
