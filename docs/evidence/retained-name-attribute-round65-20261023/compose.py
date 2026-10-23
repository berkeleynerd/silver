"""Join retained six-owner arithmetic with the candidate Hsattr lifetime bound.

This is an input/owner join, not a replay of either component checker or a
proof of their source contracts. Independent acceptance is recorded separately.
"""
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
EV = HERE.parent
CASES = {'put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid'}
SIX = {'Ident', 'Decl.Hsdecl', 'Ty.Hsty', 'Theory.Hstdecl',
       'Task.Hstask', 'Task.Stdecl.Hcpt'}


def compose():
    providers = {}

    def read(relative):
        data = (EV / relative).read_bytes()
        providers[relative] = {'bytes': len(data),
                               'sha256': hashlib.sha256(data).hexdigest()}
        return json.loads(data)

    six = read('retained-six-owner-round63-20261023/candidate-composition-result.json')
    acceptance = read('retained-six-owner-round63-20261023/integration-result.json')
    attr = read('retained-why-hsattr-demand-20261023/result.json')
    assert acceptance['new_source_contracts_independently_accepted']
    assert six['budgets'] == {
        'per_process_escape': 2, 'save_entering_callbacks_upper': 2,
        'saves_upper': 3, 'allowance_renewed_at_stage_boundary': False}
    assert attr['budgets'] == {
        'escape': 2, 'save_entering_callbacks': 2, 'saves': 3,
        'renewed_at_stage_or_owner_boundary': False}
    arows = {r['case']: r for r in attr['cases']}
    assert set(arows) == {r['case'] for r in six['cases']} == CASES
    assert len(attr['cases']) == len(six['cases']) == len(CASES)
    rows = []
    for s in six['cases']:
        a = arows[s['case']]
        assert s['attachment']['prospective_route'] == 'combined quiet/timeless/J12/logging'
        assert s['attachment']['target_cut'] == 'registration before preparation'
        assert a['target_cut'] == 'prospective combined quiet/timeless/J12/logging registration'
        assert a['retained_j12_pid'] == s['attachment']['retained_j12_pid']
        assert a['registered_roots'] == s['demand']['registered_roots']
        assert a['episodes_upper'] == s['demand']['preparation_episodes_upper']
        assert a['episodes_upper'] == 3 * a['registered_roots'] + 2
        assert s['missing_residual_contracts'] == []
        assert s['complete_six_owner_numeric_input']
        assert set(s['conditional_transfers']) == SIX
        assert all(r['native_operands_fit'] for r in s['conditional_transfers'].values())
        assert a['lifetime_requests_and_increments_upper'] == (
            a['prefix_requests_upper'] + sum(a['suffix_requests'].values()))
        q = a['lifetime_requests_and_increments_upper']
        outer = a['backing']['individual_outer_array_length_upper']
        bucket = a['backing']['individual_bucket_length_upper']
        limits = six['native_limits']
        assert q <= (1 << 62) - 1
        assert 3 * max(outer, bucket) + 6 <= (1 << 62) - 1
        assert outer <= limits['max_array_length']
        assert bucket + 2 <= limits['max_ephemeron_keys']
        assert a['native_owner_operands_fit']
        owners = dict(s['conditional_transfers'])
        owners['Ident.Hsattr'] = {'counter': a['counter'], 'backing': a['backing'],
                                 'native_operands_fit': True}
        rows.append({
            'case': s['case'], 'retained_j12_pid': a['retained_j12_pid'],
            'registered_roots': a['registered_roots'],
            'episodes_upper': a['episodes_upper'],
            'conditional_transfers': owners,
            'complete_seven_named_owner_input': True,
            'all_seven_named_owner_operands_fit': True,
            'Hsattr_lifetime_from_empty_attached_once': True,
            'source_join_pending_independent_review': True,
            'actual_whole_process_headroom': False,
        })
    return {
        'scope': 'Seven named shared owners under retained source contracts; candidate Hsattr join',
        'inputs': providers, 'cases': rows, 'budgets': six['budgets'],
        'six_owner_numerical_results_reused': True,
        'Hsattr_numerical_results_reused': True,
        'second_episode_multiplier': False,
        'source_join_pending_independent_review': True,
        'all_mutable_owners_closed': False,
        'attribute_bytes_and_locations_closed': False,
        'actual_whole_process_headroom': False,
        'whole_capacity_rule_complete': False,
        'aggregate_RAM_gate': False,
        'component_checker_replays': 0, 'native_runs': 0,
    }


if __name__ == '__main__':
    started = time.perf_counter()
    result = compose()
    result['elapsed_seconds'] = time.perf_counter() - started
    (HERE / 'composition-result.json').write_text(
        json.dumps(result, indent=2) + '\n')
    print(json.dumps({'cases': len(result['cases']),
                      'all_seven_named_owner_operands_fit': True,
                      'source_join_pending_independent_review': True,
                      'whole_capacity_rule_complete': False,
                      'elapsed_seconds': result['elapsed_seconds']}))
