"""Local-only JSONL decision server for DUELMIND WindBot bridge.

Run from repository root:
    python duelmind/server.py
The server has no access to game memory; caller supplies only permitted choices.
"""
import argparse
import json
import socketserver
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from engine import decide, InvalidObservation

MAX_BYTES = 65536


class Handler(socketserver.StreamRequestHandler):
    def handle(self):
        self.request.settimeout(1.5)
        line = self.rfile.readline(MAX_BYTES + 1)
        if not line or len(line) > MAX_BYTES or not line.endswith(b"\n"):
            self._reply({"protocol": "duelmind.v1", "error": "Invalid request length"})
            return
        try:
            observation = json.loads(line.decode("utf-8"))
            result = decide(observation)
        except (InvalidObservation, ValueError, UnicodeError, TypeError) as error:
            result = {"protocol": "duelmind.v1", "error": str(error)}
        self._reply(result)
        if "action_id" in result:
            print("[DUELMIND] selected={} score={} reason={}".format(result["action_id"], result.get("score"), result.get("reason")), flush=True)
        else:
            print("[DUELMIND] rejected request: {}".format(result.get("error")), flush=True)

    def _reply(self, payload):
        try:
            self.wfile.write((json.dumps(payload, ensure_ascii=False) + "\n").encode("utf-8"))
            self.wfile.flush()
        except (ConnectionError, OSError):
            pass


class LocalServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--port", type=int, default=28741)
    args = p.parse_args()
    if not 1024 <= args.port <= 65535:
        p.error("port must be between 1024 and 65535")
    with LocalServer(("127.0.0.1", args.port), Handler) as srv:
        print(f"DUELMIND V1 ready: 127.0.0.1:{args.port}", flush=True)
        try:
            srv.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
