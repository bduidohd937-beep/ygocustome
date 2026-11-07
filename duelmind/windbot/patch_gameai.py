"""Patch WindBot ExecutorBase with a neutral decision hook.

The ExecutorBase assembly cannot reference deck executors in the WindBot EXE.
Virtual methods on Executor preserve assembly direction and native fallback.
"""
from pathlib import Path
import sys

MAIN_ANCHOR = "            CheckSurrender();\n            foreach (CardExecutor exec in Executor.Executors)"
MAIN_NEW = """            CheckSurrender();
            MainPhaseAction duelMindAction = Executor.TryDecideMainPhase(main);
            if (duelMindAction != null)
                return duelMindAction;
            foreach (CardExecutor exec in Executor.Executors)"""

CHAIN_ANCHOR = "            Executor.OnSelectChain(cards);\n            foreach (CardExecutor exec in Executor.Executors)"
CHAIN_NEW = """            Executor.OnSelectChain(cards);
            int duelMindChain = Executor.TryDecideChain(cards, forced);
            if (duelMindChain >= -1)
                return duelMindChain;
            foreach (CardExecutor exec in Executor.Executors)"""

EXEC_ANCHOR = "        public virtual IList<ClientCard> OnSelectCard(IList<ClientCard> cards, int min, int max, long hint, bool cancelable)"
EXEC_NEW = """        // Opt-in strategy bridge: only specialized deck executors override these.
        // The default -2 / null means normal WindBot behavior.
        public virtual MainPhaseAction TryDecideMainPhase(MainPhase main)
        {
            return null;
        }

        public virtual int TryDecideChain(IList<ClientCard> cards, bool forced)
        {
            return -2;
        }

""" + EXEC_ANCHOR


def replace_once(source, old, new):
    if source.count(old) != 1:
        raise RuntimeError("Unsafe WindBot source layout: anchor count != 1")
    return source.replace(old, new, 1)


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: patch_gameai.py <windbot-root>")
    root = Path(sys.argv[1]) / "ExecutorBase" / "Game"
    game_path = root / "GameAI.cs"
    executor_path = root / "AI" / "Executor.cs"

    game = game_path.read_text(encoding="utf-8-sig")
    executor = executor_path.read_text(encoding="utf-8-sig")

    if "Executor.TryDecideMainPhase(main)" not in game:
        game = replace_once(game, MAIN_ANCHOR, MAIN_NEW)
        game = replace_once(game, CHAIN_ANCHOR, CHAIN_NEW)
    if "public virtual MainPhaseAction TryDecideMainPhase" not in executor:
        executor = replace_once(executor, EXEC_ANCHOR, EXEC_NEW)

    if "Executor.TryDecideChain(cards, forced)" not in game:
        raise RuntimeError("Chain bridge missing")
    if "public virtual int TryDecideChain" not in executor:
        raise RuntimeError("Executor virtual chain hook missing")

    game_path.write_text(game, encoding="utf-8")
    executor_path.write_text(executor, encoding="utf-8")
    print("DUELMIND: ExecutorBase virtual hooks + GameAI bridge installed")


if __name__ == "__main__":
    main()
