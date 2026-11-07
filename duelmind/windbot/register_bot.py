"""Insert DUELMIND into WindBot's UI bot list without altering other entries."""
import json
import sys
from pathlib import Path

ENTRY = {"name": "DUELMIND - Isobar", "deck": "DuelmindIsobar", "difficulty": 2, "masterRules": [5]}

def register(path: Path):
    bots = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(bots, list):
        raise ValueError("Expected bots.json to be an array")
    bots = [bot for bot in bots if bot.get("name") != ENTRY["name"]]
    bots.append(ENTRY)
    path.write_text(json.dumps(bots, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(bots)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: register_bot.py <WindBot/bots.json>")
    print("Registered DUELMIND - Isobar; bots:", register(Path(sys.argv[1])))
