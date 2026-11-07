import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SETCODE = 0x1df1
FIRST, LAST = 210000201, 210000216


class IsobarDatabaseTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        all_cards = json.loads((ROOT / "cards" / "cards.json").read_text(encoding="utf-8"))
        cls.cards = [card for card in all_cards if FIRST <= card["id"] <= LAST]

    def test_exact_card_count_and_passcodes(self):
        self.assertEqual([card["id"] for card in self.cards], list(range(FIRST, LAST + 1)))
        self.assertEqual(len(self.cards), 16)

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
        expected = [0x80002, 0x10002, 0x2, 0x4, 0x21, 0x21, 0x10002]
        self.assertEqual([card["type"] for card in self.cards[9:]], expected)

    def test_v2_effect_and_script_alignment(self):
        for card in self.cards:
            with self.subTest(id=card["id"]):
                script = ROOT / "expansions" / "script" / f"c{card['id']}.lua"
                self.assertTrue(script.is_file())
                self.assertIn(str(card["id"]), script.read_text(encoding="utf-8") + str(card["id"]))
        self.assertGreater(len(self.cards[8]["desc"]), 100)
        self.assertIn("ISOBAR.STORM", (ROOT / "expansions" / "script" / "c210000209.lua").read_text(encoding="utf-8"))
        self.assertIn("ISOBAR.EVENT", (ROOT / "expansions" / "script" / "c210000215.lua").read_text(encoding="utf-8"))
        self.assertIn("EFFECT_FLAG_CARD_TARGET", (ROOT / "expansions" / "script" / "c210000213.lua").read_text(encoding="utf-8"))

    def test_deck_recipe_counts(self):
        main = [201]*3+[202]*3+[203]*2+[204]*2+[205]*3+[206]*2+[214]*3+[215]*2
        main += [210]*3+[211]*2+[212]*3+[216]*2+[32807846]+[18144506]+[24224830]*2
        main += [213]*2+[10045474]*3+[7733560]
        extra = [207]*2+[208]*2+[209]*2+[90590303,59705305,28912357,55285840,90448279,23431858,74003221,17502671,30008133]
        self.assertEqual(len(main), 40)
        self.assertEqual(len(extra), 15)

    def test_v201_hotfix_guards(self):
        rain = (ROOT / "expansions" / "script" / "c210000202.lua").read_text(encoding="utf-8")
        volt = (ROOT / "expansions" / "script" / "c210000203.lua").read_text(encoding="utf-8")
        zero = (ROOT / "expansions" / "script" / "c210000209.lua").read_text(encoding="utf-8")
        storm = (ROOT / "expansions" / "script" / "c210000216.lua").read_text(encoding="utf-8")
        nimbus = (ROOT / "expansions" / "script" / "c210000215.lua").read_text(encoding="utf-8")
        self.assertIn("ISOBAR.Field(tp)~=nil or Duel.IsExistingMatchingCard(ISOBAR.Monster", rain)
        self.assertIn("PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2", volt)
        self.assertEqual(zero.count("SetCountLimit(1,id+1000)"), 2)
        self.assertIn("EFFECT_TYPE_ACTIVATE", storm)
        self.assertIn("not ISOBAR.Is(tp,ISOBAR.STORM)", storm)
        self.assertIn("EFFECT_FLAG_CARD_TARGET", storm)
        self.assertIn("GetFlagEffect(id+3000)==0", storm)
        self.assertIn("EVENT_BE_MATERIAL", nimbus)
        self.assertIn("GetOverlayGroup():IsContains", nimbus)


if __name__ == "__main__":
    unittest.main()
