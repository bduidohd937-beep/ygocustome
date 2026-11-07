import json
import socket
import threading
import unittest
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("duelmind_server", ROOT / "duelmind" / "server.py")
import sys
sys.path.insert(0, str(ROOT / "duelmind"))
servermod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(servermod)


class BridgeProtocolTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = servermod.LocalServer(("127.0.0.1", 0), servermod.Handler)
        cls.port = cls.server.server_address[1]
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=3)

    def ask(self, data):
        with socket.create_connection(("127.0.0.1", self.port), timeout=2) as sock:
            sock.settimeout(2)
            sock.sendall(json.dumps(data).encode("utf-8") + b"\n")
            buf = b""
            while not buf.endswith(b"\n"):
                part = sock.recv(65536)
                if not part:
                    break
                buf += part
            return json.loads(buf)

    def test_select_from_exact_offered_cards(self):
        result = self.ask({
            "public_state": {"phase": "main1"},
            "legal_actions": [
                {"action_id": "0", "kind": "select_card", "card_id": 210000203,
                 "target": {"high_value": False}},
                {"action_id": "1", "kind": "select_card", "card_id": 210000201,
                 "target": {"high_value": True}}
            ]
        })
        self.assertEqual(result["action_id"], "1")
        self.assertIn("score", result)

    def test_invalid_duplicate_ids_rejected(self):
        reply = self.ask({"legal_actions": [
            {"action_id": "x", "kind": "pass"},
            {"action_id": "x", "kind": "pass"}]})
        self.assertIn("error", reply)

    def test_never_generates_card_not_in_candidates(self):
        result = self.ask({"legal_actions": [
            {"action_id": "only", "kind": "select_card", "card_id": 210000203}]})
        self.assertEqual(result["action_id"], "only")


if __name__ == "__main__":
    unittest.main()
