"""Process-scoped six-owner residual for the attached J12 callback family.

The source argument establishes zero effects only after other named components
are removed. This API never supplies any of the other residual categories.
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent
CASES = ('put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid')
OWNERS = ('Ident', 'Decl.Hsdecl', 'Ty.Hsty', 'Theory.Hstdecl',
          'Task.Hstask', 'Task.Stdecl.Hcpt')
CATEGORY = 'other_callbacks_and_shutdown'


def residuals(*, escape=2):
    """Return case -> category -> vector, already scoped to the whole process.

    The caller retains the pinned source/control premises. `escape` is the same
    global parameter consumed by shared-demand, not a new per-component budget.
    """
    if type(escape) is not int or not 0 <= escape <= 2:
        raise ValueError('one process-global integer escape budget in 0..2')
    return {case: {CATEGORY: {owner: {'increments': 0, 'requests': 0}
                             for owner in OWNERS}} for case in CASES}


def calculate(*, escape=2):
    exported = residuals(escape=escape)
    rows = []
    for case in CASES:
        path = EVIDENCE / 'retained-why-fixed-inline-family-20261020' / (case + '-family.json')
        family = json.loads(path.read_text())
        n = family['registered_roots']
        assert n == len(family['stages']['raw']['roots'])
        rows.append({'case': case, 'registered_roots': n,
                     'same_process_preparation_episode_upper': 3*n + escape,
                     'target_cut': 'combined quiet/timeless/J12/logging registration',
                     'process_vector': exported[case][CATEGORY],
                     'failed_prefixes_included': True})
    return {'category': CATEGORY, 'cases': rows, 'residuals': exported,
            'component_source_argument': 'candidate pending independent review',
            'component_input_complete_under_named_premises': True,
            'component_missing_inputs': [],
            'scope': 'post-registration scheduling, ordinary response callbacks, exception rendering, save residual and shutdown',
            'budgets': {'process_global_escape': escape,
                        'save_entering_callbacks_upper': 2, 'saves_upper': 3,
                        'allowance_renewed_at_component_boundary': False},
            'save_binders_imported_by_shared_demand_not_recharged': True,
            'source_argument_machine_checked': False,
            'whole_process_headroom': False, 'whole_capacity_rule': False,
            'aggregate_RAM_gate': False,
            'other_residual_inputs_not_supplied': [
                'lookup_library_constructors', 'later_preparation',
                'solver_request_printers'],
            'predecessor_checker_replays': 0, 'native_runs': 0,
            'captures': 0, 'solver_runs': 0, 'proof_runs': 0}


if __name__ == '__main__':
    print(json.dumps(calculate(), indent=2, sort_keys=True))
