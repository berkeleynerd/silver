"""Compose the new printer vector with retained R61 preparation demand once."""
import importlib.util
import json
from pathlib import Path
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def compose():
    base = EV / 'retained-why-shared-demand-20261020'
    sys.path.insert(0, str(base))
    spec = importlib.util.spec_from_file_location('r62_shared_join', base / 'compose.py')
    shared = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(shared)
    previous = json.loads((EV / 'retained-printer-pause-round61-20261023/composition-result.json').read_text())
    printer = json.loads((EV / 'retained-why-printer-demand-20261023/result.json').read_text())
    residuals = {row['case']: dict(row['caller_supplied_residuals'])
                 for row in previous['cases']}
    assert len(residuals) == len(printer['cases']) == 5
    for row in printer['cases']:
        assert set(residuals[row['case']]) == {'later_preparation'}
        residuals[row['case']]['solver_request_printers'] = row['process_vector']
    result = shared.compose(residuals, escape=2)
    result['scope'] = 'R61 accepted preparation plus R62 selected printer six-owner demand'
    result['second_episode_multiplier'] = False
    for row in result['cases']:
        assert row['known_and_supplied_operands_fit']
        assert set(row['missing_residual_contracts']) == {
            'lookup_library_constructors', 'other_callbacks_and_shutdown'}
        assert not row['actual_whole_process_headroom']
        assert not row['complete_six_owner_numeric_input']
    assert not result['whole_pipeline_capacity']
    return result


if __name__ == '__main__':
    started = time.perf_counter()
    result = compose()
    result['new_composition_seconds'] = time.perf_counter() - started
    (HERE / 'composition-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({
        'cases': len(result['cases']),
        'all_known_operands_fit': True,
        'missing_vectors_per_process': 2,
        'whole_pipeline_capacity': False,
        'elapsed_seconds': result['new_composition_seconds']}))
