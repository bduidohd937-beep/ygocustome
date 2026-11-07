# DUELMIND V1.2 — Live WindBot ↔ Python IPC bridge

**Status:** WindBot Windows compilation passed; Python TCP protocol tests passed. Real EDOPro match not yet verified.

## Communication
- WindBot: `DuelmindIsobarExecutor.cs` (native C# executor).
- Decision service: `duelmind/server.py` (stdlib Python only).
- Local socket: TCP `127.0.0.1:28741`, UTF-8, one JSON line in / one JSON line out.
- Per-request timeouts: C# connection 150ms, read/write 200ms. Requests capped at 64 KiB on server.
- Off-host connection intentionally impossible (loopback only).
- Every action is chosen from the exact list of choices supplied by WindBot; response index is revalidated by C# before use.
- Server not started / invalid reply / timeout → existing WindBot `DefaultExecutor` fallback.

## Scope implemented
- `OnSelectCard` when exactly one card must be chosen: sends WindBot's **actually offered** candidates to Python, receives selected candidate index, returns that same card object. Leaves multi-card selections to native WindBot.
- `OnSelectAttacker`: sends available attacking monsters, selects one returned by Python.
- Choice heuristics initially use card IDs and own-side priorities. The bridge is fully connected but deliberately limited in strategic sophistication.
- All other actions (summon, chain, effect activation, XYZ materials, phase transitions) continue using native Isobar WindBot strategy, not Python.
- `duelmind/engine.py` remains deterministic. It is **not** a GPT API model. No API credentials or third-party network services required.

## Start decision server

From Windows PowerShell:

```powershell
$repo = "$HOME\Desktop\ygocustome"
cd $repo
git fetch origin
git switch feat/duelmind-v1-ipc-bridge
git pull --ff-only origin feat/duelmind-v1-ipc-bridge
python -m unittest discover -s tests -v
python duelmind/server.py
```

The final command keeps a console open displaying `DUELMIND V1 ready: 127.0.0.1:28741`. Leave this terminal open while playing.

## Install custom Windows bot
1. From the latest **DUELMIND WindBot Windows build** GitHub Actions run, download artifact `DUELMIND-Isobar-WindBot-Windows`.
2. Close EDOPro, backup the currently installed WindBot directory, then install the `WindBot` folder inside the artifact over EDOPro's WindBot directory.
3. Local EDOPro executable folder: `C:\Users\bduid\Games\EDOPro\ProjectIgnis` (verify actual WindBot subfolder before replacement).
4. EDOPro → Local AI → `DUELMIND - Isobar`.
5. WindBot's custom card DB must be loaded; see notes in `duelmind/windbot/INSTALL.md`.

## Required next verification
- [ ] UI shows DUELMIND - Isobar bot and accepts start duel.
- [ ] Native executor summons or activates Isobar cards.
- [ ] Python receives choice calls through TCP; if EDOPro AI preselects all cards, test relevant hooks with game logs.
- [ ] Duel is fully playable without breaking legal rules.
- [ ] Extend to all legal main-phase and chain choices (requires upstream WindBot GameAI selector integration, separate from native deck callbacks).
- [ ] Build full GPT strategy option with opt-in external API. 

Sources: https://github.com/ProjectIgnis/windbot and its ExecutorBase/Game/AI/Executor.cs, DefaultExecutor.cs, Game/DecksManager.cs (AGPL-3.0-or-later).
