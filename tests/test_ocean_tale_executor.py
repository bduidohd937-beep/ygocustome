import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class OceanTaleExecutorTests(unittest.TestCase):
    def test_executor_registration_and_profile(self):
        source = (ROOT / "duelmind" / "windbot" / "DuelmindOceanTaleExecutor.cs").read_text(encoding="utf-8")
        self.assertIn('[Deck("DuelmindOceanTale", "AI_DuelmindOceanTale")]', source)
        self.assertIn('private const string DeckProfile = "ocean_tale";', source)
        for card_id in range(210000301, 210000314):
            self.assertIn(str(card_id), source)

    def test_standalone_project_references_installed_windbot_api(self):
        project = (ROOT / "duelmind" / "windbot" / "DuelmindOceanTaleExecutor.csproj").read_text(encoding="utf-8")
        self.assertIn("$(EDOPRO_ROOT)\\WindBot\\WindBot.dll", project)
        self.assertIn("$(EDOPRO_ROOT)\\WindBot\\ExecutorBase.dll", project)


if __name__ == "__main__":
    unittest.main()
