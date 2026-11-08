"""Read-only installed-vs-pinned card audit; outputs no installation mutations."""
import argparse
import hashlib
import json
from pathlib import Path
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from duelmind.core.knowledge import ASSET_ROOT, verify_assets


def db_cards(path: Path) -> dict:
    with sqlite3.connect(path.resolve().as_uri() + "?mode=ro", uri=True) as db:
        db.row_factory = sqlite3.Row
        data = {r["id"]: dict(r) for r in db.execute(
            "SELECT * FROM datas WHERE id BETWEEN 210000201 AND 210000216 ORDER BY id")}
        for r in db.execute("SELECT * FROM texts WHERE id BETWEEN 210000201 AND 210000216 ORDER BY id"):
            if r["id"] in data:
                data[r["id"]].update(dict(r))
        return data


def audit(edopro: Path) -> dict:
    manifest = verify_assets()
    pinned = json.loads((ASSET_ROOT / "cards.json").read_text(encoding="utf-8"))
    current = db_cards(edopro / "expansions/ygocustom.cdb")
    bot = db_cards(edopro / "WindBot/ygocustom.cdb")
    old = db_cards(ROOT / "expansions/ygocustom.cdb")
    checks = []
    for c in pinned:
        cid = c["id"]
        expected = {k: c.get(k, 0) for k in ("id", "ot", "alias", "setcode", "type", "atk", "def", "level", "race", "attribute", "category")}
        expected.update(name=c["name"], desc=c["desc"])
        strings = c.get("strings", [])
        expected.update({"str" + str(i + 1): strings[i] if i < len(strings) else "" for i in range(16)})
        script = edopro / f"expansions/script/c{cid}.lua"
        digest = hashlib.sha256(script.read_bytes()).hexdigest() if script.exists() else None
        checks.append({"id": cid, "name": c["name"], "legacy_present": cid in old,
                       "windbot_present": cid in bot,
                       "installed_cdb_matches": expected == current.get(cid),
                       "installed_script_matches": digest == manifest["files"][f"script/c{cid}.lua"],
                       "legacy_changed_fields": [k for k in expected if old.get(cid, {}).get(k) != expected[k]]})
    helper_bytes = (edopro / "expansions/script/isobar.lua").read_bytes()
    helper = hashlib.sha256(helper_bytes).hexdigest()
    helper_content_matches = helper_bytes.replace(b"\r\n", b"\n") == (ASSET_ROOT / "script/isobar.lua").read_bytes().replace(b"\r\n", b"\n")
    return {"baseline_id": manifest["baseline_id"], "cards": checks,
            "helper_matches": helper_content_matches,
            "helper_raw_bytes_match": helper == manifest["files"]["script/isobar.lua"],
            "installed_snapshot_matches": all(c["installed_cdb_matches"] and c["installed_script_matches"] for c in checks)
            and helper_content_matches,
            "actual_engine_load_order_verified": False}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--edopro", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.edopro)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"installed_snapshot_matches": result["installed_snapshot_matches"], "cards": len(result["cards"])}, ensure_ascii=False))
