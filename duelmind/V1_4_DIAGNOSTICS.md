# DUELMIND V1.4 — Isobar set-and-end troubleshooting

## Identified defect and status
V1.3 Windows package shipped `WindBot/ygocustom.cdb` but its `Program.InitDatas()` did not explicitly load that file.
The EDOPro client having card data is not proof the separate WindBot process loaded the same custom DB.
This is a **confirmed configuration defect**; whether it fully caused the observed set/end loop must still be verified in live EDOPro.

## V1.4 fix
- `patch_windbot_db.py` edits upstream WindBot `Program.cs` before compilation to load `ygocustom.cdb` from the bot executable directory.
- The build workflow applies this patch and ships the CDB beside the executable.
- `DuelmindIsobarExecutor.cs` writes runtime diagnostics to `%TEMP%\duelmind-windbot.log`:
  * `DUELMIND executor activated` — custom executor was actually instantiated
  * `main phase hook invoked` — EDOPro is calling the custom hook
  * `python decision requested` — C# is attempting the local TCP call
  * `python accepted selected index=...` — Python response accepted
  * `python connection failed: ...` — fallback to native WindBot is occurring

## Reproduce and verify
1. Close EDOPro **completely** before replacing the WindBot binary.
2. Download and install the V1.4 Windows build from the relevant GitHub Actions run. Keep a full backup of the old WindBot folder.
3. Start Python from `feat/duelmind-v1-3-main-chain` or V1.4 branch:
   `python duelmind/server.py`.
4. Play against `DUELMIND - Isobar`.
5. After the turn, inspect:
   ```powershell
   if (Test-Path "$env:TEMP\duelmind-windbot.log") {
       Get-Content "$env:TEMP\duelmind-windbot.log" -Tail 50
   } else {
       Write-Host "No DUELMIND runtime log: wrong executable or bot not loaded?"
   }
   Get-CimInstance Win32_Process -Filter "name = 'WindBot.exe'" |
       Select-Object ProcessId, ExecutablePath, CommandLine | Format-List
   ```
6. If Python prints no decisions and there is no executor log, EDOPro may be launching a different WindBot executable, or still running an old process.
7. If the log says `main phase hook invoked` and `python connection failed`, investigate port 28741/firewall.
8. If logs show `python accepted...` but set/end still happens, inspect EDOPro duel replay and engine choices for remaining strategy bugs.

## Important
- A successful Windows build is **not** a successful duel. No full real-client match completed in CI.
- This version does not modify EDOPro card effects or custom images.
- The Python engine remains deterministic, not a GPT realtime connection.
