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
            self.assertTrue(card['name'].strip())
            self.assertTrue(card.get('desc', '').strip())
            script = ROOT / "expansions" / "script" / f"c{card['id']}.lua"
            self.assertTrue(script.is_file(), str(script))

    def test_deathfire_cards(self):
        cards = json.loads((ROOT / 'cards/cards.json').read_text(encoding='utf-8'))
        deathfire = [card for card in cards if 210000101 <= card['id'] <= 210000110]
        self.assertEqual(len(deathfire), 10)
        self.assertTrue(all(card['setcode'] == 0x1df0 for card in deathfire))
        self.assertEqual([c['id'] for c in deathfire], list(range(210000101, 210000111)))

if __name__ == "__main__":
    unittest.main()
