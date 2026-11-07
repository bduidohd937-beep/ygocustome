#!/usr/bin/env python3
"""Build an EDOPro SQLite card database from cards/cards.json."""
import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "cards" / "cards.json"
OUTPUT = ROOT / "expansions" / "ygocustom.cdb"

DATA_COLUMNS = ("id", "ot", "alias", "setcode", "type", "atk", "def",
                "level", "race", "attribute", "category")


def build():
    cards = json.loads(SOURCE.read_text(encoding="utf-8"))
    ids = [int(card["id"]) for card in cards]
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate card IDs in cards/cards.json")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    if OUTPUT.exists():
        OUTPUT.unlink()
    with sqlite3.connect(OUTPUT) as db:
        db.execute("""CREATE TABLE datas (
            id integer primary key, ot integer, alias integer, setcode integer,
            type integer, atk integer, def integer, level integer,
            race integer, attribute integer, category integer)""")
        db.execute("""CREATE TABLE texts (
            id integer primary key, name text, desc text,
            str1 text, str2 text, str3 text, str4 text,
            str5 text, str6 text, str7 text, str8 text,
            str9 text, str10 text, str11 text, str12 text,
            str13 text, str14 text, str15 text, str16 text)""")
        for card in cards:
            card_id = int(card["id"])
            if card_id <= 0:
                raise ValueError(f"Invalid card ID: {card_id}")
            values = [card_id] + [int(card.get(k, 0)) for k in DATA_COLUMNS[1:]]
            db.execute("INSERT INTO datas VALUES (" + ",".join(["?"]*11) + ")", values)
            strings = card.get("strings", [])
            if len(strings) > 16:
                raise ValueError(f"Too many description strings for {card_id}")
            db.execute("INSERT INTO texts VALUES (" + ",".join(["?"]*19) + ")",
                       [card_id, card["name"], card.get("desc", "")] +
                       list(strings) + [""]*(16-len(strings)))
    print(f"Built {OUTPUT} ({len(cards)} cards)")


if __name__ == "__main__":
    build()
