"""Join candidate library/callback inputs with accepted R62 shared demand.

Numerical input completeness is conditional on each supplied source contract;
independent review and all other owner/operand coverage remain separate.
"""
import importlib.util
import json
from pathlib import Path
import sys
import time

HERE = Path(__file__).resolve().parent
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def compose():
    base = EV / 'retained-why-shared-demand-20261020'
    sys.path.insert(0, str(base))
    spec = importlib.util.spec_from_file_location('r63_shared_join', base / 'compose.py')
    shared = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(shared)
    previous = read(EV / 'retained-printer-demand-round62-20261023/composition-result.json')
    library = read(EV / 'retained-why-library-constructors-20261023/result.json')
    callbacks = read(EV / 'retained-why-callback-demand-20261023/result.json')
    residuals = {row['case']: dict(row['caller_supplied_residuals'])
                 for row in previous['cases']}
    assert len(residuals) == len(library['cases']) == len(callbacks['cases']) == 5
    assert library['global_escape_upper'] == callbacks['budgets']['process_global_escape'] == 2
    for row in library['cases']:
        assert row['lookup_vector_complete']
        residuals[row['case']]['lookup_library_constructors'] = row['lookup_vector']
    for row in callbacks['cases']:
        residuals[row['case']]['other_callbacks_and_shutdown'] = row['process_vector']
    result = shared.compose(residuals, escape=2)
    result['scope'] = 'Complete numerical input to six-owner transfer; candidate library/callback contracts pending review'
    result['new_source_contracts_independently_accepted'] = False
    result['second_episode_multiplier'] = False
    for row in result['cases']:
        assert row['missing_residual_contracts'] == []
        assert row['complete_six_owner_numeric_input']
        assert row['six_owner_capacity_conditional_on_supplied_contracts']
        assert not row['actual_whole_process_headroom']
    assert not result['whole_pipeline_capacity']
    return result


if __name__ == '__main__':
    started = time.perf_counter()
    result = compose()
    result['new_composition_seconds'] = time.perf_counter() - started
    (HERE / 'candidate-composition-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'cases': len(result['cases']), 'all_supplied_operands_fit': True,
                      'missing_numeric_vectors_per_process': 0,
                      'source_contract_review_pending': True,
                      'whole_pipeline_capacity': False,
                      'elapsed_seconds': result['new_composition_seconds']}))
