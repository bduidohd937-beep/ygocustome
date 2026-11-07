"""Apply the minimal guarded GameAI integration to a WindBot checkout.

Fail closed if upstream source changes instead of silently patching the wrong place.
"""
from pathlib import Path
import sys

MAIN_ANCHOR = "            CheckSurrender();\n            foreach (CardExecutor exec in Executor.Executors)"
MAIN_NEW = """            CheckSurrender();
            var duelMindMain = Executor as WindBot.Game.AI.Decks.DuelmindIsobarExecutor;
            if (duelMindMain != null)
            {
                MainPhaseAction choice = duelMindMain.TryDecideMainPhase(main);
                if (choice != null)
                    return choice;
            }
            foreach (CardExecutor exec in Executor.Executors)"""

CHAIN_ANCHOR = "            Executor.OnSelectChain(cards);\n            foreach (CardExecutor exec in Executor.Executors)"
CHAIN_NEW = """            Executor.OnSelectChain(cards);
            var duelMindChain = Executor as WindBot.Game.AI.Decks.DuelmindIsobarExecutor;
            if (duelMindChain != null)
            {
                int chosenChain = duelMindChain.TryDecideChain(cards, forced);
                if (chosenChain >= -1)
                    return chosenChain;
            }
            foreach (CardExecutor exec in Executor.Executors)"""


def replace_exact(content: str, old: str, new: str) -> str:
    if content.count(old) != 1:
        raise RuntimeError("Expected unique GameAI anchor; refusing unsafe patch")
    return content.replace(old, new, 1)


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: patch_gameai.py <windbot-root>")
    target = Path(sys.argv[1]) / "ExecutorBase" / "Game" / "GameAI.cs"
    text = target.read_text(encoding="utf-8-sig")
    if "duelMindMain.TryDecideMainPhase" in text:
        if "duelMindChain.TryDecideChain" not in text:
            raise RuntimeError("Partial GameAI patch detected")
        print("DUELMIND GameAI patch already installed")
        return
    text = replace_exact(text, MAIN_ANCHOR, MAIN_NEW)
    text = replace_exact(text, CHAIN_ANCHOR, CHAIN_NEW)
    target.write_text(text, encoding="utf-8")
    print("DUELMIND: connected main-phase and chain decision hooks")


if __name__ == "__main__":
    main()
