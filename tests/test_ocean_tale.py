import json
import sqlite3
import unittest
from pathlib import Path

try:
    from luaparser import ast
except ImportError:
    ast = None


ROOT = Path(__file__).resolve().parents[1]
OCEAN_IDS = list(range(210000301, 210000314))


class OceanTaleCardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cards = json.loads((ROOT / "cards" / "cards.json").read_text(encoding="utf-8"))
        cls.cards = {card["id"]: card for card in cards if card["id"] in OCEAN_IDS}

    def test_thirteen_cards_and_unique_ids(self):
        all_cards = json.loads((ROOT / "cards" / "cards.json").read_text(encoding="utf-8"))
        ids = [card["id"] for card in all_cards]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertEqual(sorted(self.cards), OCEAN_IDS)
        self.assertEqual(len(self.cards), 13)

    def test_setcode_and_metadata(self):
        for card_id, card in self.cards.items():
            with self.subTest(card_id=card_id):
                self.assertTrue(card["desc"])
                self.assertTrue((ROOT / "expansions" / "script" / f"c{card_id}.lua").is_file())
                if card_id == 210000304:
                    self.assertEqual(card["setcode"], 0)
                else:
                    self.assertEqual(card["setcode"], 0x1DF2)
        self.assertEqual(self.cards[210000304]["atk"], 3500)
        self.assertEqual(self.cards[210000306]["level"], 11)
        self.assertTrue(self.cards[210000307]["type"] & 0x4000000)
        self.assertTrue(self.cards[210000309]["type"] & 0x80)

    def test_v41_balance_values_are_present(self):
        self.assertIn("500 LP", self.cards[210000304]["desc"])
        self.assertIn("× 500 데미지", self.cards[210000304]["desc"])
        self.assertIn("500 데미지", self.cards[210000313]["desc"])
        self.assertIn("공격력은 600 올리고", self.cards[210000313]["desc"])

    def test_generated_cdb_contains_all_ocean_tale_ids(self):
        with sqlite3.connect(ROOT / "expansions" / "ygocustom.cdb") as db:
            rows = db.execute(
                "select id from datas where id between 210000301 and 210000313 order by id"
            ).fetchall()
        self.assertEqual([row[0] for row in rows], OCEAN_IDS)

    def test_scripts_load_shared_library_and_use_v41_ids(self):
        for card_id in OCEAN_IDS:
            source = (ROOT / "expansions" / "script" / f"c{card_id}.lua").read_text(encoding="utf-8")
            with self.subTest(card_id=card_id):
                self.assertIn('Duel.LoadScript("ocean_tale_v41.lua")', source)
                self.assertIn("local ot=OceanTaleV41", source)
        helper = (ROOT / "expansions" / "script" / "ocean_tale_v41.lua").read_text(encoding="utf-8")
        self.assertIn("ot.SET=0x1df2", helper)
        self.assertIn("ot.LEVIATHAN=210000304", helper)

    def test_test_deck_has_40_main_and_15_extra(self):
        lines = (ROOT / "cards" / "Ocean_Tale_V4_1_test.ydk").read_text(encoding="utf-8").splitlines()
        section = None
        main = []
        extra = []
        for line in lines:
            if line == "#main":
                section = main
            elif line == "#extra":
                section = extra
            elif line.startswith("#") or line == "!side":
                section = None
            elif section is not None and line.strip().isdigit():
                section.append(int(line))
        self.assertEqual(len(main), 40)
        self.assertEqual(len(extra), 15)
        self.assertTrue(set(OCEAN_IDS).issuperset(set(main) & set(OCEAN_IDS)))

    @unittest.skipUnless(ast is not None, "luaparser is not installed")
    def test_new_lua_scripts_parse(self):
        files = sorted((ROOT / "expansions" / "script").glob("c2100003*.lua"))
        files.append(ROOT / "expansions" / "script" / "ocean_tale_v41.lua")
        for path in files:
            with self.subTest(path=path.name):
                ast.parse(path.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
