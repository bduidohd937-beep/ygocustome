import unittest
from pathlib import Path

try:
    from luaparser import ast
except ImportError:  # pragma: no cover - reported as a skipped environment check
    ast = None

ROOT = Path(__file__).resolve().parents[1]
LUA_FILES = [ROOT / "expansions" / "script" / f"c{card_id}.lua"
             for card_id in range(210000201, 210000217)]
LUA_FILES.append(ROOT / "expansions" / "script" / "isobar.lua")


@unittest.skipIf(ast is None, "luaparser is not installed")
class LuaSyntaxTests(unittest.TestCase):
    def test_all_isobar_scripts_parse(self):
        for path in LUA_FILES:
            with self.subTest(script=path.name):
                ast.parse(path.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
