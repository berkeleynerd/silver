"""Actual six-owner request charges for the selected SMTv2 printer cut.

Consumes accepted JSON dimensions, not their generating programs. The source
argument and syntax-origin companion supply the interpretation of these terms.
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EV = HERE.parent


def calculate():
    prep = json.loads((EV / 'retained-why-printer-entry-20261020/result.json').read_text())
    cases = []
    for row in prep['cases']:
        name = row['case']
        dims = row['dimensions']
        inv = json.loads((EV / 'retained-why-postinline-preparation-20261020' / (name + '-inventory.json')).read_text())
        s, p, h = dims['S'], dims['P'], dims['task_nodes']
        a = inv['signature_maxima']['arity']
        t = inv['signature_maxima']['type_nodes']
        e = row['episodes_upper']
        assert e == 3 * row['registered_roots'] + 2
        assert a <= p and min(s, p, h, t) > 0
        # The syntax companion bounds all opening scans and definition
        # formals by 2P+A. Add two possible constructor field lists, A+1 each.
        # General case subject/wildcard constructors are outside this family.
        ident = h * (2*p + 3*a + 2)
        # The attached syntax family has no active %v placeholder, so its
        # lazy get_type_arguments/type-mismatch constructor is never called.
        ty = 0
        per = {
            'Ident': {'increments': ident, 'requests': 0},
            'Decl.Hsdecl': {'increments': 0, 'requests': 0},
            'Ty.Hsty': {'increments': ty, 'requests': ty},
            'Theory.Hstdecl': {'increments': 0, 'requests': 0},
            'Task.Hstask': {'increments': 0, 'requests': 0},
            'Task.Stdecl.Hcpt': {'increments': 0, 'requests': 0}}
        process = {owner: {k: e*v for k, v in charge.items()}
                   for owner, charge in per.items()}
        assert all(v < 2**62 for charge in process.values() for v in charge.values())
        cases.append({'case': name, 'registered_roots': row['registered_roots'],
                      'episodes_upper': e,
                      'dimensions': {'S': s, 'P': p, 'H': h, 'A': a, 'T': t},
                      'per_episode_vector': per, 'process_vector': process,
                      'failed_prefixes_included': True,
                      'ordinary_print_tree_visits_per_formula_upper': 2*s,
                      'native_counter_demands_fit_in_isolation': True})
    return {'scope': 'Driver.print_task_prepared through normal return or escaping exception; selected SMTv2 family',
            'cases': cases, 'same_process_global_escape_upper': 2,
            'save_entering_callbacks_upper': 2, 'saves_upper': 3,
            'allowance_renewed_for_printing': False,
            'source_argument_machine_checked': False,
            'whole_process_headroom': False, 'whole_capacity_rule': False,
            'aggregate_RAM_gate': False,
            'excludes': ['other callbacks and later exception rendering',
                         'attribute tags and local printer/map backing',
                         'formatted request bytes and formatter/Buffer operands',
                         'whole-process six-owner composition and other mutable owners']}


if __name__ == '__main__':
    result = calculate()
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    for c in result['cases']:
        print(c['case'], c['process_vector']['Ident']['increments'],
              c['process_vector']['Ty.Hsty']['increments'])
