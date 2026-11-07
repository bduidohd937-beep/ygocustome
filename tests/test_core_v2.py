import copy
import json
from pathlib import Path
import socket
import threading
import subprocess
import unittest
from duelmind.engine import decide, InvalidObservation
from duelmind.core.protocol import state_hash
from duelmind.server import LocalServer, Handler

FIXTURES = json.loads((Path(__file__).parent / 'fixtures/core_v2_isobar.json').read_text())


class CoreV2Tests(unittest.TestCase):
    def test_complete_output_against_pinned_commit(self):
        root = Path(__file__).resolve().parents[1]
        source = subprocess.check_output(
            ['git', 'show', 'bfa1110:duelmind/engine.py'], cwd=root).decode('utf-8')
        legacy = {'__file__': str(root/'duelmind/engine.py'), '__name__': 'legacy_baseline'}
        exec(compile(source, 'bfa1110:duelmind/engine.py', 'exec'), legacy)
        observations = [row['observation'] for row in FIXTURES]
        for cid in range(210000201, 210000217):
            for kind in ('activate', 'normal_summon', 'special_summon', 'xyz_summon'):
                for weather in ('unknown', 'sun', 'rain', 'storm'):
                    observations.append({'public_state': {'weather': weather},
                        'legal_actions': [{'action_id':'a', 'kind':kind, 'card_id':cid},
                                          {'action_id':'end', 'kind':'end_phase'}]})
        for obs in observations:
            self.assertEqual(decide(copy.deepcopy(obs)), legacy['decide'](copy.deepcopy(obs)))

    def test_golden_legacy_scores_and_order(self):
        self.assertEqual(len(FIXTURES), 12)
        for row in FIXTURES:
            with self.subTest(row=row['expected']['action_id']):
                got = decide(copy.deepcopy(row['observation']))
                self.assertEqual({k:got[k] for k in row['expected']}, row['expected'])
                self.assertEqual(got, decide(copy.deepcopy(row['observation'])))

    def test_v2_same_choice_unknown_outcome(self):
        for row in FIXTURES:
            obs = dict(row['observation'], protocol_version=2, profile_id='isobar',
                       duel_id='fixture', decision_point='main')
            result = decide(obs)
            self.assertEqual(result['selected_action'], row['expected']['action_id'])
            self.assertEqual(result['state_hash'], state_hash(obs))
            self.assertEqual(result['post_action_observation']['status'], 'unknown')
            self.assertEqual(result['actual_result'], 'unobserved_before_execution')

    def test_reject_invalid_request_without_inventing_fallback(self):
        with self.assertRaises(InvalidObservation):
            decide({'legal_actions': []})
        with self.assertRaises(InvalidObservation):
            decide(dict(FIXTURES[0]['observation'], protocol_version=99))

    def test_unsupported_profile_uses_offered_fallback(self):
        obs = {'protocol_version':2, 'duel_id':'fixture', 'profile_id':'missing',
               'decision_point':'chain', 'legal_actions':[
                   {'action_id':'p','kind':'pass'}]}
        result = decide(obs)
        self.assertTrue(result['fallback'])
        self.assertEqual(result['selected_action'], 'p')

    def test_state_hash_key_order(self):
        self.assertEqual(state_hash({'public_state': {'a':1,'b':2}}),
                         state_hash({'public_state': {'b':2,'a':1}}))

    def test_ipc_v1_v2_and_malformed(self):
        with LocalServer(('127.0.0.1', 0), Handler) as srv:
            srv.decision_log = None
            thread = threading.Thread(target=srv.serve_forever, daemon=True)
            thread.start()
            try:
                for version in (1, 2):
                    obs = dict(FIXTURES[0]['observation'])
                    if version == 2:
                        obs.update(protocol_version=2, profile_id='isobar',
                                   duel_id='test', decision_point='main')
                    with socket.create_connection(srv.server_address, timeout=1) as sock:
                        sock.sendall(json.dumps(obs).encode()+b'\n')
                        result = json.loads(sock.makefile('rb').readline())
                    self.assertEqual(result['action_id'], FIXTURES[0]['expected']['action_id'])
                    self.assertEqual(result['protocol'], 'duelmind.v'+str(version))
                with socket.create_connection(srv.server_address, timeout=1) as sock:
                    sock.sendall(b'{bad}\n')
                    self.assertIn('error', json.loads(sock.makefile('rb').readline()))
            finally:
                srv.shutdown()
                thread.join()

    def test_ipc_caller_timeout_is_observable(self):
        # A stalled peer must not be mistaken for a successful action result.
        with socket.socket() as listener:
            listener.bind(('127.0.0.1', 0))
            listener.listen()
            with socket.create_connection(listener.getsockname()) as client:
                peer, _ = listener.accept()
                with peer:
                    client.settimeout(0.03)
                    with self.assertRaises(socket.timeout):
                        client.recv(1)
