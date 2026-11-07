"""Patch WindBot Program.InitDatas to load DUELMIND's custom card DB.

The previous installer packaged ygocustom.cdb but did not ensure the WindBot
process loaded it. EDOPro's own card DB does NOT automatically imply WindBot
can look up custom cards. Fail closed if upstream source layout changes.
"""
from pathlib import Path
import sys

ANCHOR = '            if (!loadedone)\n            {\n                Logger.WriteErrorLine("Can\'t find cards database file.");'
PATCH = '''            // DUELMIND: load our custom card metadata explicitly.
            // The EDOPro client and WindBot use separate card DB loaders.
            string customDb = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ygocustom.cdb");
            if (File.Exists(customDb))
            {
                try
                {
                    NamedCardsManager.LoadDatabase(customDb);
                    loadedone = true;
                    Logger.WriteLine("DUELMIND custom card database loaded: " + customDb);
                }
                catch (Exception ex)
                {
                    Logger.WriteErrorLine("DUELMIND custom card database FAILED: " + ex);
                }
            }
            else
            {
                Logger.WriteErrorLine("DUELMIND custom card database NOT FOUND: " + customDb);
            }

''' + ANCHOR

def patch(root: Path):
    f = root / "Program.cs"
    src = f.read_text(encoding="utf-8-sig")
    if "DUELMIND custom card database loaded" in src:
        print("Database patch already present")
        return
    if src.count(ANCHOR) != 1:
        raise RuntimeError("WindBot Program.cs layout changed; aborting patch")
    f.write_text(src.replace(ANCHOR, PATCH), encoding="utf-8")
    print("DUELMIND DB loader installed")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: patch_windbot_db.py <WindBot-source-root>")
    patch(Path(sys.argv[1]))
