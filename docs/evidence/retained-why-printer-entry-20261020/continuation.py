"""New printer-entry projections; no transformation or predecessor-checker replay.

The potential is a structural upper bound, not an execution of simplification.
Source transfer obligations are stated in the companion research note.
"""
from pathlib import Path
from collections import Counter
import gzip
import importlib.util
import json
import sys

HERE = Path(__file__).resolve().parent
EV = HERE.parent
R51 = EV / 'retained-why-preinline-prefix-20261020'
R56 = EV / 'retained-why-fixed-inline-family-20261020'
sys.path.insert(0, str(R56))
spec = importlib.util.spec_from_file_location('printer_origin_family', R56 / 'family_model.py')
fm = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fm)
sys.path.pop(0)
CASES = ['put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid']


def read(p):
    return json.loads(p.read_text())


def project(case):
    graph = json.loads(gzip.decompress((R51 / (case + '-graph.json.gz')).read_bytes()))
    typed = read(R56 / (case + '-types.json'))
    family = read(R56 / (case + '-family.json'))
    inventory = read(HERE / (case + '-inventory.json'))
    model = fm.Family(graph, typed['types'])
    decls = {d['declaration']: d for d in graph['declarations']}

    def epsilon_parents(term):
        result = []
        def walk(t, parent=None):
            kind, key, ty, attrs, children, bound, pats = model.nodes[t]
            if kind == 'eps':
                pk, head, _, _, _, _, _ = model.nodes[parent]
                assert pk == 'app' and graph['symbols'][str(head)]['name'] == 'infix <='
                definition, = [d for d in graph['declarations'] if head in d['definition_symbols']]
                index, = definition['raw_root_indexes']
                ax = model.open(index)
                assert model.nodes[ax][0] == 'quant'
                eq = model.nodes[ax][4][0]
                body = model.nodes[eq][4][-1]
                assert model.nodes[body][:2] == ('binop', 1)
                result.append({'parent_head': head, 'parent_name': 'infix <=',
                               'definition': definition['declaration'],
                               'body_root': ['binop', 1], 'trivial_inline_eligible': False})
            for child in children:
                walk(child, t)
        walk(term)
        return result

    # Every original let is retained AND its value is made available at every
    # use. This dominates arbitrary partial expansion, including dead values.
    def potential(t, env):
        kind, key, ty, attrs, children, bound, pats = model.nodes[t]
        if kind == 'var':
            return env.get(key, 1)
        if kind == 'let':
            value = potential(children[0], env)
            nested = dict(env)
            nested[bound[0][0]] = value
            return 1 + value + potential(children[1], nested)
        return 1 + sum(potential(c, {v: n for v, n in env.items() if v not in scope})
                       for c, scope in zip(children, model.child_scopes(model.nodes[t])))

    routes = {}
    for route in ['raw', 'ce']:
        observations = {r['goal']: r for r in inventory['routes'][route]}
        rows = []
        for r in family['stages'][route]['roots']:
            d = decls[graph['raw_task_declaration_sequences'][str(r['task'])][-1]]
            index, = d['candidate_root_indexes' if route == 'ce' else 'raw_root_indexes']
            term = model.open(index)
            obs = observations[r['goal']]
            assert not obs['counts'].get('case', 0)
            for special in obs['binding_bearing_let_values']:
                assert special['value'] == [10, 1, 0, 4]
                assert special['body'][1:3] == [0, 0]
                assert special['value_tree']['kind'] == 'let'
                # The inner let has no binding-bearing descendants.
                assert all(not x['bound'] for x in special['value_tree']['children'])
            p = potential(term, {})
            assert p >= model.dimensions(term)[0]
            rows.append({
                'goal': r['goal'], 'root_index': r['root_index'],
                'formula': index, 'partial_let_potential_before_inline': p,
                'optional_inline_partial_let_potential_upper': 5 * p,
                'goal_mass_after_inline_upper': r['goal_output'][0],
                'goal_bound_slots_after_inline_upper': r['goal_output'][1],
                'candidate_saved_entries_upper': r['candidate_storage']['delayed_map_entries_upper'],
                'candidate_saved_image_nodes_upper': r['candidate_storage']['seed_value_nodes_upper'],
                'binding_bearing_value_body_bound_slots': [x['body'][1] for x in obs['binding_bearing_let_values']],
                'epsilon_occurrences': len(obs['eps']),
                'epsilon_parents': epsilon_parents(term),
            })
        routes[route] = rows
    inductives = []
    for pointer, d in typed['declarations'].items():
        if d['kind'] == 4:
            names = [graph['symbols'][str(h)]['name'] for h in d['heads']]
            assert names == ['acc']
            inductives.append({'declaration': int(pointer), 'heads': d['heads'],
                               'head_names': names, 'clause_heads': d['clauses']})
    assert len(inductives) == (1 if case in ['put-line', 'put'] else 0)
    context_epsilon_parents = []
    if case == 'first-or-default':
        # Inspect every raw context input, including exact old saved fields
        # already covered by R57; context raw declaration membership is fixed.
        any_root = family['stages']['raw']['roots'][0]
        context_decls = graph['raw_task_declaration_sequences'][str(any_root['task'])][:-1]
        for pointer in context_decls:
            if pointer in decls:
                for index in decls[pointer]['raw_root_indexes']:
                    context_epsilon_parents.extend(epsilon_parents(model.open(index)))
        assert len(context_epsilon_parents) == 1
    return {'case': case, 'registered_roots': family['registered_roots'],
            'routes': routes, 'inductives': inductives,
            'context_epsilon_parents': context_epsilon_parents,
            'transform_replay': False, 'predecessor_checker_replay': False}


if __name__ == '__main__':
    result = {'cases': [project(case) for case in CASES],
              'projection_only': True, 'source_transfer_machine_checked': False}
    (HERE / 'continuation-projection.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    for c in result['cases']:
        rows = sum(c['routes'].values(), [])
        print(c['case'], 'roots', c['registered_roots'],
              'potential', max(r['optional_inline_partial_let_potential_upper'] for r in rows),
              'special goals', sorted({r['goal'] for r in rows if r['binding_bearing_value_body_bound_slots']}))
