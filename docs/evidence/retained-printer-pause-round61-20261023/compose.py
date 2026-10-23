"""Join the accepted printer-entry demand once with the R60 six-owner API."""
import importlib.util
import json
from pathlib import Path
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def compose():
    base = ROOT / 'docs/evidence/retained-why-shared-demand-20261020'
    sys.path.insert(0, str(base))
    spec = importlib.util.spec_from_file_location('r61_shared_join', base / 'compose.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    packet = json.loads((ROOT / 'docs/evidence/retained-why-printer-entry-20261020/result.json').read_text())
    residuals = {}
    for case in packet['cases']:
        d = case['process_demands']
        residuals[case['case']] = {'later_preparation': module.vector(
            ident=d['direct_Ident_registrations'],
            decl=d['logical_decl_constructor_requests'],
            ty=d['type_hashcons_requests'],
            td=d['tdecl_constructor_requests'],
            task=d['task_add_requests'],
            hcpt=64*d['task_add_requests'])}
    result = module.compose(residuals, escape=2)
    result['printer_entry_freeze'] = '366beba68251ece3483193f8104c39391f8c46ef'
    result['preparation_vector_independently_reviewed'] = True
    result['second_episode_multiplier'] = False
    for case in result['cases']:
        assert case['known_and_supplied_operands_fit']
        assert set(case['missing_residual_contracts']) == {
            'lookup_library_constructors', 'solver_request_printers',
            'other_callbacks_and_shutdown'}
        assert not case['actual_whole_process_headroom']
    assert not result['whole_pipeline_capacity']
    return result


if __name__ == '__main__':
    start = time.perf_counter()
    result = compose()
    result['new_composition_seconds'] = time.perf_counter() - start
    (HERE / 'composition-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'cases': len(result['cases']),
                      'all_known_operands_fit': True,
                      'missing_vectors_per_process': 3,
                      'whole_pipeline_capacity': False,
                      'elapsed_seconds': result['new_composition_seconds']}))
