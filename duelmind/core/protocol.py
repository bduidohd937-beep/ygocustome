"""Opt-in V2 envelope; V1 results remain byte-for-byte structurally compatible."""
import hashlib
import json
from .contracts import InvalidObservation, validate


def state_hash(obs):
    payload = json.dumps(obs.get('public_state', {}), sort_keys=True,
                         separators=(',', ':'), ensure_ascii=True)
    return hashlib.sha256(payload.encode()).hexdigest()


def prepare(obs):
    if not isinstance(obs, dict):
        raise InvalidObservation('Observation must be an object')
    version = obs.get('protocol_version', 1)
    if type(version) is not int or version not in (1, 2):
        raise InvalidObservation('Unsupported protocol_version')
    if version == 1:
        return obs
    validate(obs)
    for field in ('duel_id', 'profile_id', 'decision_point'):
        if not isinstance(obs.get(field), str) or not obs[field]:
            raise InvalidObservation('V2 requires ' + field)
    normalized = dict(obs)
    normalized['deck_profile'] = obs['profile_id']
    return normalized


def finish(obs, result):
    if obs.get('protocol_version', 1) == 1:
        return result
    chosen = next((a for a in obs['legal_actions']
                   if a['action_id'] == result.get('action_id')), None)
    if chosen is None:
        raise InvalidObservation('Profile returned an illegal action')
    state = obs.get('public_state') or {}
    return dict(result, protocol='duelmind.v2', protocol_version=2,
                duel_id=obs['duel_id'], profile_id=obs['profile_id'],
                turn=state.get('turn', 'unknown'), phase=state.get('phase', 'unknown'),
                decision_point=obs['decision_point'],
                effect_identifier=('unknown' if obs.get('card_baseline') else
                                   chosen.get('effect_profile', 'unknown')),
                legal_actions=obs['legal_actions'], selected_action=chosen['action_id'],
                state_hash=state_hash(obs),
                post_action_observation={'status': 'unknown',
                                         'reason': 'not_collected_by_adapter'},
                actual_result='unobserved_before_execution')
