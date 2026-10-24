"""New finite clone-origin/global-state inventory over retained source bytes.

Reuse only the accepted comment masker/tokenizer and retained import result;
never call that checker's main. This is a focused source inventory, not a
WhyML parser or a native typed-value capture.
"""
import importlib.util
import json
from pathlib import Path
import re
import sys
import tarfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
OLD = ROOT/'docs/evidence/retained-producer-import-context-20261018'
sp = importlib.util.spec_from_file_location('retained_import_lexer', OLD/'check.py')
lexer = importlib.util.module_from_spec(sp)
sp.loader.exec_module(lexer)

MAIN_ORIGINS = {
    '_gnatprove_standard.Array__1', 'ada__model.Static_Discrete',
    'ada__model.Dynamic_Discrete', 'ada__model.Rep_Proj_Int',
    'ada__model.Constr_Array', 'ada__model.Unconstr_Array',
}
LOGICAL = {'function', 'predicate', 'constant', 'lemma'}
MAIN_STATE = {'__HEAP', 'no__return', 'spark__branch'}


def head(tokens, i):
    """Classify this corpus's val/let head, retaining every unclassified case."""
    j = i+1
    if tokens[j][0] == 'ghost':
        j += 1
    if tokens[j][0] in LOGICAL | {'rec'}:
        return 'logical_or_recursive', j, None
    if tokens[j][0] == 'exception':
        return 'local_exception', j, None
    if tokens[j][0] == 'ref':
        raise ValueError('unclassified ref binding head')
    if tokens[j][0] == '(':
        end = j+1
        while tokens[end][0] != ')':
            end += 1
        name = ''.join(x for x,_ in tokens[j:end+1])
        j = end+1
    else:
        name = tokens[j][0]
        if not lexer.IDENT.fullmatch(name):
            raise ValueError(('unclassified binding name', name))
        j += 1
    while tokens[j][0].startswith('[@'):
        j += 1
    return 'ordinary', j, name


def collect():
    prior = json.loads((OLD/'result.json').read_text())
    fixed_origins = {s['target'] for m in prior['modules'].values()
                     for s in m['statements'] if s['kind'] == 'clone'}
    origins = fixed_origins | MAIN_ORIGINS
    assert origins <= prior['modules'].keys()
    modules = {}
    with tarfile.open(OLD/'sources.tar.gz') as tar:
        for filekey, row in prior['files'].items():
            source = tar.extractfile(row['path']).read().decode()
            clean = lexer.mask_comments(source)
            starts = list(re.finditer(r'^(?:module|theory)\s+([A-Za-z_][A-Za-z0-9_\']*)', clean, re.M))
            for i, match in enumerate(starts):
                end = starts[i+1].start() if i+1 < len(starts) else len(clean)
                key = filekey+'.'+match[1]
                chunk = source[match.start():end]
                header_end = clean.find('\n',match.end())
                assert not clean[match.end():header_end].strip(), 'module interface header'
                ts = lexer.tokens(chunk)
                assert ts[2][0] != ':', 'multiline module interface header'
                base_line = source[:match.start()].count('\n')
                objects, candidates, heads, refinements = [], [], [], []
                for at, (token, pos) in enumerate(ts):
                    if token not in {'val','let'}:
                        continue
                    kind, after, name = head(ts, at)
                    heads.append({'kind': token, 'classification': kind,
                                  'line': base_line+chunk[:pos].count('\n')+1})
                    if kind != 'ordinary':
                        continue
                    follow = ts[after][0]
                    if token == 'val':
                        if follow == '=':
                            # clone ... with ... val eq = target, ...
                            # This is an instantiation, not a declaration.
                            assert ts[at-1][0] in {',','with'}
                            heads[-1]['classification'] = 'routine_refinement'
                            refinements.append({'name':name,'line':heads[-1]['line']})
                        elif follow == ':':
                            objects.append({'name':name, 'line':heads[-1]['line']})
                        elif follow not in {'(', "'"} and not lexer.IDENT.fullmatch(follow):
                            raise ValueError(('unclassified val arity',key,name,follow))
                    elif follow in {':','='}:
                        eq = after
                        while ts[eq][0] != '=':
                            eq += 1
                        stop = eq+1
                        while ts[stop][0] not in {'in','let','end','module','theory','axiom','val','function','predicate','lemma'}:
                            stop += 1
                        candidates.append({'name':name, 'line':heads[-1]['line'],
                            'ends_at_in_before_new_binding_or_declaration':ts[stop][0]=='in',
                            'initializer_tokens':[x for x,_ in ts[eq+1:stop]],
                            'next_token':ts[stop][0]})
                modules[key] = {'path':row['path'], 'objects':objects,
                                'plain_let_candidates':candidates, 'heads':heads,
                                'routine_refinements':refinements,
                                'tokens':[x for x,_ in ts]}
    assert modules.keys() == prior['modules'].keys()
    closure, todo = set(), list(origins)
    while todo:
        m = todo.pop()
        if m in closure:
            continue
        closure.add(m)
        todo.extend(s['target'] for s in prior['modules'].get(m,{}).get('statements',[]))
    global_objects = {m:v['objects'] for m,v in modules.items() if v['objects']}
    assert global_objects == {
        '_gnatprove_standard.Main':[{'name':'__HEAP','line':26},
            {'name':'no__return','line':39},{'name':'spark__branch','line':88}],
        'mach.int.Random63':[{'name':'s','line':568}],
    }
    assert not origins & global_objects.keys()
    routine_refinements = {m:v['routine_refinements'] for m,v in modules.items()
                          if v['routine_refinements']}
    assert routine_refinements == {
        'set.SetAppInt':[{'name':'eq','line':607}],
        'set.SetAppString':[{'name':'eq','line':663}],
        'set.SetImpInt':[{'name':'eq','line':781}],
    }
    assert 'mach.int.Random63' not in closure
    for m in closure & modules.keys():
        assert all(x['ends_at_in_before_new_binding_or_declaration']
                   for x in modules[m]['plain_let_candidates'])
        if m != '_gnatprove_standard.Main':
            assert not (MAIN_STATE & set(modules[m]['tokens']))
    for m in origins:
        assert not (MAIN_STATE & set(modules[m]['tokens']))
        assert not ({'rec','while','for','try','raise','exception','invariant'} & set(modules[m]['tokens']))
        assert 'by' not in modules[m]['tokens'], 'possible type witness requires classification'
        assert all(x['ends_at_in_before_new_binding_or_declaration']
                   for x in modules[m]['plain_let_candidates'])
    # A use of Main cannot acquire a hidden state-reading callable: the
    # only occurrences in Main itself are the three object declarations.
    for state in MAIN_STATE:
        assert modules['_gnatprove_standard.Main']['tokens'].count(state) == 1
    origin_rows = {m:{k:v for k,v in modules[m].items() if k!='tokens'} for m in sorted(origins)}
    return {'fixed_clone_origins':sorted(fixed_origins),
            'ordinary_main_origins':sorted(MAIN_ORIGINS),
            'all_origins':sorted(origins), 'dependency_closure':sorted(closure),
            'global_objects':global_objects,'origin_inventory':origin_rows,
            'routine_refinements':routine_refinements,
            'origin_plain_let_candidates':sum(len(v['plain_let_candidates']) for v in origin_rows.values()),
            'no_origin_program_globals':True,'no_foreign_state_reference':True,
            'module_interface_headers':0,'program_recursive_loop_exception_or_invariant_tokens_in_origins':0,
            'type_witness_by_tokens_in_origins':0,
            'retained_import_checker_main_executed':False}


if __name__ == '__main__':
    print(json.dumps(collect(),indent=2))
