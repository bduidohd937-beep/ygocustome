import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SETCODE = 0x1df1
FIRST, LAST = 210000201, 210000213


class IsobarDatabaseTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        all_cards = json.loads((ROOT / "cards" / "cards.json").read_text(encoding="utf-8"))
        cls.cards = [card for card in all_cards if FIRST <= card["id"] <= LAST]

    def test_exact_card_count_and_passcodes(self):
        self.assertEqual([card["id"] for card in self.cards], list(range(FIRST, LAST + 1)))
        self.assertEqual(len(self.cards), 13)

    def test_archetype_and_script_paths(self):
        for card in self.cards:
            with self.subTest(id=card["id"]):
                self.assertEqual(card["setcode"], SETCODE)
                self.assertTrue(card["desc"])
                self.assertTrue((ROOT / "expansions" / "script" / f"c{card['id']}.lua").is_file())
        self.assertTrue((ROOT / "expansions" / "script" / "isobar.lua").is_file())

    def test_monsters_and_xyz_ranks(self):
        for card in self.cards[:9]:
            self.assertEqual(card["race"], 0x20)   # machine
            self.assertEqual(card["attribute"], 0x8)  # wind
        for card in self.cards[6:9]:
            self.assertTrue(card["type"] & 0x800000)  # xyz
            self.assertEqual(card["level"], 4)
        for card in self.cards[:6]:
            self.assertEqual(card["type"], 0x21)
            self.assertEqual(card["level"], 4)

    def test_spell_trap_types(self):
        expected = [0x80002, 0x10002, 0x2, 0x4]
        self.assertEqual([card["type"] for card in self.cards[9:]], expected)


if __name__ == "__main__":
    unittest.main()
