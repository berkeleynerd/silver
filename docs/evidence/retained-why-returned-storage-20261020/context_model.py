"""New context-only feature and storage projection over accepted R51/R56 bytes.

Imports the accepted graph/weighted algebra as a library, never a predecessor
checker. It computes no goals and does not repeat the R56 aggregate calculation.
"""
from pathlib import Path
from functools import lru_cache
import gzip, hashlib, importlib.util, json, re, sys

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
R56 = HERE.parent / 'retained-why-fixed-inline-family-20261020'
R51 = HERE.parent / 'retained-why-preinline-prefix-20261020'
sys.path.insert(0, str(R56))
# The imported module itself imports its own project.py. Load before this file is
# exposed under that short name by clients.
spec = importlib.util.spec_from_file_location('r57_family', R56 / 'family_model.py')
family = importlib.util.module_from_spec(spec)
spec.loader.exec_module(family)
sys.path.pop(0)  # Restore this packet's module precedence for its own audit/compose.
CASES = ['put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid']

def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

class Context(family.Family):
    def replace(self, *args):
        self.depth = getattr(self, 'depth', 0) + 1
        out = super().replace(*args)
        self.depth -= 1
        if not self.depth:
            self.output = out
        return out


def calculate(case):
    graph = json.loads(gzip.decompress((R51 / f'{case}-graph.json.gz').read_bytes()))
    types = json.loads((R56 / f'{case}-types.json').read_text())
    frozen = json.loads(gzip.decompress((R56 / f'{case}-details.json.gz').read_bytes()))
    family_result = json.loads((R56 / f'{case}-family.json').read_text())
    metadata = json.loads((HERE.parent/'retained-why-parallel-symbol-exclusion-20261020'/f'{case}-metadata.json').read_text())
    removed = {r['old_pointer']: r['name'] for r in metadata['selected_symbols']['remove_prop']}
    by_decl = {d['declaration']: d for d in graph['declarations']}
    sequences = list(graph['raw_task_declaration_sequences'].values())
    context = sequences[0][:-1]
    assert all(s[:-1] == context for s in sequences)
    keys = [p for p in context if by_decl[p]['kind'] in (3, 4, 5)]
    prop_rows={r['old_prsymbol']:r for r in metadata['raw_prop_roots']}
    axiom_heads=[dict(prsymbol=by_decl[p]['symbol'],attributes=prop_rows[by_decl[p]['symbol']]['prsymbol_attrs']) for p in keys if by_decl[p]['kind']==5]
    assert all(r['attributes'] != ['introduced'] for r in axiom_heads)
    assert not metadata['selected_symbols']['introduced_prsymbol']
    declared_identifiers = sorted({i for p in keys for i in types['declarations'][str(p)]['news']})
    declared_names = [dict(identifier=i,name=types['identifiers'][str(i)]['name']) for i in declared_identifiers]
    assert all(r['name'] != 'identity_def' for r in declared_names)
    result = dict(case=case, original_context_keys=len(keys), axiom_heads=axiom_heads,
                  declared_names=declared_names, stages={})
    for route in ('raw', 'ce'):
        m = Context(graph, types['types'])
        features, outputs = [], []

        def tree(t):
            k, key, ty, attrs, ch, bound, patterns = m.nodes[t]
            if k == 'app':
                key = dict(symbol=key, name=graph['symbols'][str(key)]['name'])
            elif k == 'var':
                key = dict(variable=key, name=m.variables[key][1]['name'])
            return dict(kind=k, key=key, type=ty, attributes=sorted(attrs),
                        bindings=bound, patterns=patterns,
                        children=[tree(c) for c in ch])

        def feature_walk(t, decl, path=()):
            node = m.nodes[t]
            k, _, _, _, children, bound, patterns = node
            if k in ('let', 'eps', 'case'):
                row = dict(declaration=decl['declaration'], declaration_kind=decl['kind'],
                           path=path, kind=k, dimensions=m.dimensions(t),
                           children_dimensions=[m.dimensions(c) for c in children],
                           free_occurrences=sum(n for _, n in m.free(t)), tree=tree(t))
                if k == 'case':
                    assert decl['kind'] == 3 and not path
                    assert len(patterns) == 2 and all(p[0] == 1 for p in patterns)
                    assert all(not b for b in bound)
                    assert m.dimensions(children[0]) == (1, 0, 0, 0)
                    assert all(m.dimensions(c)[1:3] == (0, 0) for c in children)
                    row['class'] = 'isolated_two_nullary_branches_leaf_scrutinee'
                elif k == 'let':
                    assert m.dimensions(children[0])[1:3] == (0, 0)
                    body = m.nodes[children[1]]
                    if body[0] == 'let':
                        assert m.nodes[body[4][0]][0] == 'var'
                        assert m.nodes[body[4][0]][1] == bound[0][0]
                        assert m.dimensions(body[4][1])[1:3] == (0, 0)
                        assert sum(n for v, n in m.free(body[4][1]) if v == body[5][0][0]) == 2
                        row['class'] = 'one_inner_leaf_let_then_binder_free_body'
                    else:
                        assert m.dimensions(children[1])[1:3] == (0, 0)
                        row['class'] = 'binder_free_value_and_body'
                else:
                    assert not m.free(t)
                    if case in ('put', 'put-line'):
                        assert m.dimensions(t) == (13, 3, 0, 5)
                        assert removed[decl['symbol']] in ('ult_wf','ugt_wf','slt_wf','sgt_wf')
                        row['class'] = 'removed_wf_axiom_closed_lambda'
                        row['removed_prsymbol'] = decl['symbol']
                        row['removed_name'] = removed[decl['symbol']]
                    else:
                        assert case == 'first-or-default'
                        assert m.dimensions(t) == (9, 1, 0, 5)
                        assert m.dimensions(children[0])[1:3] == (0, 0)
                        body = m.nodes[children[0]]
                        assert body[0] == 'binop' and body[1] == 0
                        left, right = [m.nodes[x] for x in body[4]]
                        assert left[0] == right[0] == 'app'
                        witness = left[4][1]
                        assert m.nodes[left[4][0]][0] == 'var'
                        assert m.nodes[left[4][0]][1] == bound[0][0]
                        assert not m.free(witness) and m.dimensions(witness) == (2, 0, 0, 2)
                        assert m.dimensions(body[4][1]) == (3, 0, 0, 2)
                        row['class'] = 'closed_binder_free_witness_and_property'
                features.append(row)
            for i, child in enumerate(children):
                feature_walk(child, decl, path + (i,))

        for dp in keys:
            d = by_decl[dp]
            if route == 'ce' and d['dropped']:
                continue
            m.declaration(d, route)
            feature_walk(m.output, d)
            outputs.append(dict(declaration=dp, dimension=m.dimensions(m.output),
                                formal_arity=m.rows[-1]['arity']))
        # Check the reused accepted semantic relation; do not recalculate goals.
        assert json.loads(json.dumps(m.rows)) == frozen[route]['context_rows']
        assert sum(f['kind'] == 'case' for f in features) == 6
        assert sum(f['kind'] == 'eps' for f in features) == {'put-line':4,'put':4,'first-or-default':1,'is-message':0,'input-is-valid':0}[case]
        roots = [p for dp in keys for p in by_decl[dp][
            'seed_root_indexes' if route == 'ce' else 'raw_root_indexes']
            if not (route == 'ce' and by_decl[dp]['dropped'])]
        seed = Context(graph, types['types'])
        profile = seed.stored_profile(roots)
        seen_terms, seen_bindings, variables, symbols = set(), set(), set(), set()
        def stored(p):
            if p in seen_terms:
                return
            seen_terms.add(p)
            t = graph['terms'][p]; k, a = t['kind'], t['args']; bs = []
            if k == 'var':
                variables.add(a[0]); ch = []
            elif k == 'app':
                symbols.add(a[0]); ch = a[1]
            elif k == 'bin': ch = a[1:]
            elif k in ('if', 'not'): ch = a
            elif k == 'let': ch = [a[0]]; bs = [a[1]]
            elif k == 'quant': ch = []; bs = [a[1]]
            elif k == 'eps': ch = []; bs = [a[0]]
            elif k == 'case':
                ch = [a[0]]; bs = [b for _, b in a[1]]
                symbols.update(pat[1][0] for pat, _ in a[1])
            else: ch = []
            for bi in bs:
                seen_bindings.add(bi); b = graph['bindings'][bi]
                variables.update(b['variables'])
                variables.update(map(int, b['free_variables']))
                variables.update(map(int, b['saved']))
                ch = list(ch) + [b['body']] + list(b['saved'].values()) + [x for group in b['triggers'] for x in group]
            for child in ch: stored(child)
        for p in roots: stored(p)
        saved_images = [p for b in seen_bindings for p in graph['bindings'][b]['saved'].values()]
        assert all(graph['terms'][p]['kind'] == 'var' for p in saved_images)
        assert profile['value_nodes'] == 1 and not profile['nonleaf_keys']
        all_types = [types['types'][str(graph['terms'][p]['type'])] for p in seen_terms if graph['terms'][p]['type'] is not None]
        all_types += [types['types'][str(graph['variables'][str(v)]['type'])] for v in variables]
        for s in symbols:
            sig = types['signatures'][str(s)]
            all_types += sig['args'] + ([] if sig['result'] is None else [sig['result']])
        max_key_entries = max([len(graph['bindings'][b]['saved']) for b in seen_bindings] + [0])
        result['stages'][route] = dict(
            context_roots=outputs, features=features,
            seed_storage=dict(**profile, maximum_binding_saved_entries=max_key_entries,
                all_saved_images_are_variables=True,
                inspected_terms=len(seen_terms), inspected_bindings=len(seen_bindings),
                inspected_variables_including_dead_keys=len(variables), inspected_symbols=len(symbols),
                all_term_variable_key_value_signature_type_mass_max=max(map(family.type_size,all_types)),
                signature_arity_max=max(len(types['signatures'][str(s)]['args']) for s in symbols)),
            original_context_formula_mass_max=family_result['stages'][route]['context']['maximum_reconstructed_formula_mass_upper'],
            bound_plus_formal_slots_max=max(x['dimension'][1]+x['formal_arity'] for x in outputs))
    return result


def without_comments(text):
    """Why driver comments nest; quoted strings and escapes are not comments."""
    out=[];i=0;depth=0;quoted=False
    while i<len(text):
        if depth:
            if text.startswith('(*)',i):i+=3  # Lexlib.comment's multiplication special case.
            elif text.startswith('(*',i):depth+=1;i+=2
            elif text.startswith('*)',i):depth-=1;i+=2
            else:
                if text[i]=='\n':out.append('\n')
                i+=1
        elif quoted:
            out.append(text[i])
            if text[i]=='\\':
                assert i+1<len(text)
                out.append(text[i+1]);i+=2
            else:
                if text[i]=='"':quoted=False
                i+=1
        elif text.startswith('(*)',i):
            out.append('(*)');i+=3  # driver_lexer emits LEFTPAR then the operator.
        elif text.startswith('(*',i):
            out.append(' ');depth=1;i+=2
        else:
            out.append(text[i])
            if text[i]=='"':quoted=True
            i+=1
    assert not depth and not quoted,'unterminated driver comment/string'
    return ''.join(out)


def driver_connection():
    folder = HERE.parent/'retained-solver-request-bytes-20261020'
    inputs = json.loads((folder/'driver-inputs.json').read_text())
    def active(name):
        text=(folder/'drivers'/name).read_text()
        assert identity(text.encode())==inputs[name]['identity']
        return without_comments(text)
    def closure(name,seen=None):
        seen=set() if seen is None else seen
        if name in seen:return seen
        seen.add(name)
        for child in inputs[name]['imports']:closure(child,seen)
        return seen
    drivers={n:sorted(closure(n)) for n in ['z3_gnatprove.drv','cvc5_gnatprove.drv','alt_ergo_gnatprove_smt2.drv']}
    assert all('smt-libv2.gen' in names for names in drivers.values())
    common=active('smt-libv2.gen')
    directives=[line.strip() for line in common.splitlines() if 'encoding:ignore_polymorphism' in line or re.search(r'remove prop [us][lg]t_wf',line)]
    required = ['meta "encoding:ignore_polymorphism_ls" predicate (=)',
                'meta "encoding:ignore_polymorphism_ts" type (->)',
                'meta "encoding:ignore_polymorphism_ls" function (@)',
                'meta "encoding:ignore_polymorphism_ls" function ite']
    assert all(line in directives for line in required)
    assert len([x for x in directives if x.startswith('remove')])==4
    # This supplementary lexical census is paired with the source loader argument;
    # it is not a raw-memory observation of CVC5's drv_meta.
    for names in drivers.values():
        for name in names:
            assert not re.search(r'\b(?:well_founded|acc)\b',active(name)),name
    return dict(driver_closures=drivers, common_file='smt-libv2.gen',
                common_directives=directives, required_ignore_directives=required,
                no_explicit_wf_component_keep_in_driver_closure=True,
                native_CVC5_metadata_projected=False, source_loader_connection_machine_checked=False)

if __name__=='__main__':
    for case in CASES:
        data=calculate(case)
        (HERE/f'{case}-context.json').write_text(json.dumps(data,sort_keys=True,indent=2)+'\n')
        print(case, {s:(v['bound_plus_formal_slots_max'],v['seed_storage']['maximum_binding_saved_entries'],v['seed_storage']['value_nodes']) for s,v in data['stages'].items()})
    (HERE/'driver-connection.json').write_text(json.dumps(driver_connection(),sort_keys=True,indent=2)+'\n')
