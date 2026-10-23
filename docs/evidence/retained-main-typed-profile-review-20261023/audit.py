"""Independent exact-freeze contract/signature audit; no author code imports.

Numeric lexical evaluation follows the native tree with an explicit lexical
environment. Coefficients are recovered by unit-coordinate perturbations,
independently of the author's symbolic affine substitution implementation.
"""
from collections import Counter
from pathlib import Path
import hashlib
import json
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT/'docs/evidence/retained-main-typed-profile-20261023'
CHECKS = 0
ARCHIVES = {}
CONTEXT_NODES = 0
SIGNATURE_USES = Counter()
TREE_NODES = 0


def check(ok, message):
    global CHECKS
    CHECKS += 1
    if not ok:
        raise AssertionError(message)


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads(path.read_bytes())


def archive(path):
    path = Path(path)
    if path not in ARCHIVES:
        with tarfile.open(path) as source:
            members = source.getmembers()
            check(len({m.name for m in members}) == len(members), 'unique archive members')
            ARCHIVES[path] = {m.name: source.extractfile(m).read()
                              for m in members if m.isfile()}
    return ARCHIVES[path]


def qname(x):
    check(x[0] == 'W_NAME', 'native name schema')
    return '.'.join(str(s) for s in ([x[5][3], x[5][4]] if x[5] else [])
                    + [x[4], x[3]] if s)


def ident(x):
    check(x[0] == 'W_IDENTIFIER', 'native identifier schema')
    return qname(x[3])


def ty(x):
    if x is None:
        return None
    check(x[0] == 'W_TYPE', 'native type schema')
    return qname(x[4])


def strip(x):
    while x[0] in ('W_LABEL', 'W_LOC_LABEL'):
        x = x[4]
    return x


def native_cost(x, weights):
    x = strip(x)
    tag = x[0]
    if tag == 'W_IDENTIFIER':
        return weights.get(ident(x), 1)
    if tag in ('W_LITERAL', 'W_INTEGER_CONSTANT'):
        return 1
    if tag == 'W_CALL':
        return 1 + sum(native_cost(a, weights) for a in x[4] or [])
    if tag == 'W_DEREF':
        return 1 + native_cost(x[3], weights)
    if tag == 'W_CONNECTION':
        children = [x[3], x[5]] + (x[6] or [])
        return len(children)-1 + sum(native_cost(a, weights) for a in children)
    if tag == 'W_NOT':
        return 1 + native_cost(x[3], weights)
    if tag == 'W_CONDITIONAL':
        check(not x[5], 'selected contracts have no elsif list')
        return 1 + native_cost(x[3], weights) + native_cost(x[4], weights) + (native_cost(x[6], weights) if x[6] else 1)
    if tag == 'W_BINDING':
        definition = native_cost(x[4], weights)
        return 1 + definition + native_cost(x[5], weights | {ident(x[3]): definition})
    if tag == 'W_UNIVERSAL_QUANTIF':
        check(not x[5], 'selected quantifiers have no triggers')
        return 1 + native_cost(x[6], weights | {ident(b[3]): 1 for b in x[3]})
    raise AssertionError('uncovered native lexical constructor '+tag)


def native_result_split(x):
    x = strip(x)
    if x[0] == 'W_CALL' and ident(x[3]) == '=' and len(x[4]) == 2:
        lhs, rhs = map(strip, x[4])
        if lhs[0] == 'W_IDENTIFIER' and ident(lhs) == 'result':
            check(native_cost(rhs, {'result':2}) == native_cost(rhs, {}), 'selected extracted definition is result-free')
            return rhs, ['W_LITERAL',0,3,0,None]
    if x[0] == 'W_CONNECTION' and x[4] in (1,5):
        found = native_result_split(x[3])
        if found:
            definition, residual = found
            replaced = list(x)
            replaced[3] = residual
            return definition, replaced
    return None


def context(x, expected, signatures):
    global CONTEXT_NODES
    CONTEXT_NODES += 1
    x = strip(x)
    tag = x[0]
    if tag in ('W_IDENTIFIER', 'W_INTEGER_CONSTANT'):
        actual = 'value'
    elif tag == 'W_LITERAL':
        actual = 'prop' if x[2] == 3 else 'value'
    elif tag in ('W_CALL', 'W_DEREF'):
        symbol = ident(x[3]) if tag == 'W_CALL' else ty(x[4])+'__content'
        args = (x[4] or []) if tag == 'W_CALL' else [x[3]]
        check(symbol in signatures, 'every selected callable has a source signature')
        sig = signatures[symbol]
        check(len(args) == sig['arity'], 'saturated selected application '+symbol)
        SIGNATURE_USES[symbol] += 1
        for arg in args:
            context(arg, 'value', signatures)
        actual = sig['result_sort']
    elif tag == 'W_CONNECTION':
        check(x[4] in (0, 1, 2, 3, 4, 5), 'ordinary connector family')
        for arg in [x[3], x[5]] + (x[6] or []):
            context(arg, 'prop', signatures)
        actual = 'prop'
    elif tag == 'W_NOT':
        context(x[3], 'prop', signatures)
        actual = 'prop'
    elif tag == 'W_CONDITIONAL':
        check(not x[5], 'no selected conditional elsif')
        context(x[3], 'prop', signatures)
        context(x[4], expected, signatures)
        if x[6]:
            context(x[6], expected, signatures)
        else:
            check(expected == 'prop', 'absent term else defaults to True')
        actual = expected
    elif tag == 'W_BINDING':
        context(x[4], 'value', signatures)
        context(x[5], expected, signatures)
        actual = expected
    elif tag == 'W_UNIVERSAL_QUANTIF':
        check(not x[5], 'no selected quantifier triggers')
        context(x[6], 'prop', signatures)
        actual = 'prop'
    else:
        raise AssertionError('uncovered selected context '+tag)
    check(actual == expected, 'no implicit Boolean/proposition crossing at '+tag)


def compare_tree(x, t, env, effects, formals, binders, seen):
    global TREE_NODES
    TREE_NODES += 1
    x = strip(x)
    tag = x[0]
    args = []
    extra = {}
    body_env = env
    if tag == 'W_IDENTIFIER':
        spelling = ident(x)
        check(' ' not in spelling, 'no embedded application spelling')
        if spelling in env or spelling in effects:
            op = 'var'
            extra = {'key': env.get(spelling, spelling),
                     'type': effects.get(spelling, ty(x[4]) if x[4] else formals.get(spelling))}
        else:
            op = 'constant'
            extra = {'symbol': spelling, 'type': ty(x[4])}
    elif tag == 'W_INTEGER_CONSTANT':
        op, extra = 'integer', {'value': x[3], 'type': 'int'}
    elif tag == 'W_LITERAL':
        op, extra = 'truth', {'value': x[3], 'domain': x[2], 'type': 'bool'}
    elif tag == 'W_CALL':
        op, args = 'application', x[4] or []
        extra = {'symbol': ident(x[3]), 'domain': x[2], 'type': ty(x[5])}
    elif tag == 'W_DEREF':
        op, args = 'projection', [x[3]]
        extra = {'symbol': ty(x[4])+'__content'}
    elif tag == 'W_CONNECTION':
        op, args = 'connection', [x[3], x[5]] + (x[6] or [])
        extra = {'connector': x[4]}
    elif tag == 'W_NOT':
        op, args = 'not', [x[3]]
    elif tag == 'W_CONDITIONAL':
        check(not x[5] and x[6] is not None, 'selected condition has explicit else')
        op, args = 'if', [x[3], x[4], x[6]]
    elif tag == 'W_BINDING':
        op, args = 'let', [x[4], x[5]]
        key = t['binder']
        spelling = ident(x[3])
        check(key not in seen and binders[key] == {'spelling': spelling, 'type': ty(x[3][4])}, 'fresh binder identity and declared type')
        seen.add(key)
        extra = {'binder': key}
        body_env = env | {spelling: key}
    elif tag == 'W_UNIVERSAL_QUANTIF':
        check(not x[5], 'projection retains trigger-free quantifier')
        op, args = 'forall', [x[6]]
        check(len(t['binders']) == len(x[3]), 'all quantifier binders retained')
        updates = {}
        for raw, key in zip(x[3], t['binders']):
            spelling = ident(raw[3])
            check(key not in seen and binders[key] == {'spelling': spelling, 'type': ty(raw[4])}, 'fresh quantifier identity and type')
            seen.add(key)
            updates[spelling] = key
        extra = {'binders': t['binders']}
        body_env = env | updates
    else:
        raise AssertionError('uncovered native projection '+tag)
    check(t == {'op': op, 'args': t['args'], **extra}, 'exact projected constructor fields')
    check(len(t['args']) == len(args), 'all projected children retained')
    for i, (raw, child) in enumerate(zip(args, t['args'])):
        child_env = body_env if op == 'forall' or op == 'let' and i == 1 else env
        compare_tree(raw, child, child_env, effects, formals, binders, seen)


def source_bindings(manifest):
    retained = archive(PACKET/'sources.tar.gz')
    check(identity((PACKET/'sources.tar.gz').read_bytes())['sha256'] == manifest['source_archive_sha256'], 'author complete source archive identity')
    check(set(retained) == {r['path'] for r in manifest['source_members']}, 'complete retained source member manifest')
    attached = {}
    for row in manifest['source_members']:
        raw = retained[row['path']]
        check(identity(raw) == {k: row[k] for k in ('bytes', 'sha256')}, 'complete source member identity')
        provider = Path(row['provider'])
        original = provider.read_bytes() if provider.is_absolute() else archive(ROOT/provider)[row['path']]
        check(raw == original, 'reattach source to exact provider '+row['path'])
        attached[row['path']] = identity(raw)
    return retained, attached


def producer_control_audit(retained):
    def full(suffix):
        matches = [(p,b) for p,b in retained.items() if p.endswith('/'+suffix)]
        check(len(matches) == 1, 'complete named producer/control source '+suffix)
        return matches[0][0], matches[0][1].decode()
    spans = {}
    selections = {
        'gnat_ast_to_ptree.ml': [(337,383),(495,537),(984,1009),(1011,1157),(1209,1225)],
        'typing.ml': [(331,471),(720,763)],
        'dterm.ml': [(606,712)],
        'gnat2why-subprograms.adb': [(7614,8447)],
        'flow_utility.adb': [(2659,2674)],
        'flow_generated_globals-phase_2.adb': [(1562,1584),(4793,4875)],
        'flow_generated_globals-phase_1.adb': [(593,611)],
        'flow_generated_globals-partial.adb': [(522,534)],
        'a-textio.ads': [(758,771)],
        'a-textio.adb': [(46,58)]}
    for suffix, ranges in selections.items():
        path, source = full(suffix)
        lines = source.splitlines(keepends=True)
        spans[path] = []
        for start,end in ranges:
            check(1 <= start <= end <= len(lines), 'strict complete-source control span')
            spans[path].append({'start':start,'end':end,'identity':identity(''.join(lines[start-1:end]).encode())})
    _, partial = full('flow_generated_globals-partial.adb')
    guard = ''.join(partial.splitlines(keepends=True)[521:534])
    for text in ['No (SPARK_Pragma (Body_Entity (E)))',
                 'Get_SPARK_Mode_From_Annotation (SPARK_Pragma (Body_Entity (E)))',
                 '= Opt.On', 'GG_Register_State_Refinement (E);']:
        check(text in guard, 'explicit body-mode guard on full refinement registration')
    _, phase1 = full('flow_generated_globals-phase_1.adb')
    _, phase2 = full('flow_generated_globals-phase_2.adb')
    check(phase1.count('New_GG_Line (EK_State_Map);') == 1, 'single complete-refinement record producer')
    check(phase2.count('State_Comp_Map.Insert') == 1, 'single complete-refinement map insertion')
    spark = archive(ROOT/'docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz')
    calls = []
    for path, data in spark.items():
        if path.startswith('spark-source/src/') and path.endswith('.adb'):
            for line,text in enumerate(data.decode().splitlines(),1):
                if re.search(r'^\s*GG_Register_State_Refinement\s*\(',text):
                    calls.append({'member':path,'line':line,'text':text.strip()})
    check(calls == [{'member':'spark-source/src/flow/flow_generated_globals-partial.adb','line':533,'text':'GG_Register_State_Refinement (E);'}], 'complete SPARK-source registration caller inventory')
    _, body = full('a-textio.adb')
    check('SPARK_Mode => Off,' in ''.join(body.splitlines(keepends=True)[45:58]) and 'Refined_State =>' in body, 'runtime refinement exists but explicit body Off excludes registration')
    _, spec = full('a-textio.ads')
    constituents = re.findall(r'\b(Standard_In|Standard_Out|Standard_Err|Current_In|Current_Out|Current_Err)\s*:\s*aliased File_Type[^;]*?Part_Of\s*=>\s*File_System;',spec,re.S)
    check(set(constituents) == {'Standard_In','Standard_Out','Standard_Err','Current_In','Current_Out','Current_Err'} and len(constituents) == 6, 'six complete-source Part_Of constituents')
    check('Expanded.Insert (Magic_String_Id (State));' in phase2 and 'State_Part_Map.Contains (State)' in phase2, 'residual state retained after Part_Of expansion')
    return spans, calls


def signatures_audit(raw, selected):
    sigs = read(HERE/'selected-signatures.json')['symbols']
    theories = {t[4]: t for t in raw['theory_declarations']}
    direct = {511: ('Array__Int__Standard__character.bool_eq', 2),
              1638: ('Standard__string___axiom.dynamic_invariant', 3),
              1762: ('Silver_arguments__input_is_valid___logic_fun.input_is_valid', 2),
              1854: ('Silver_arguments__first_or_default___logic_fun.first_or_default', 2),
              1872: ('Silver_arguments__first_or_default___logic_fun.first_or_default__function_guard', 3),
              2761: ('Silver_io__Twritten_countS___axiom.dynamic_invariant', 3),
              2956: ('Silver_io__Twritten_bytesS___axiom.dynamic_invariant', 3)}
    found = set()
    for theory in theories.values():
        for d in theory[3] or []:
            if d[0] == 'W_FUNCTION_DECL' and d[1] in direct:
                symbol, domain = direct[d[1]]
                check(theory[4]+'.'+ident(d[3]) == symbol and d[2] == domain, 'direct signature declaration identity')
                check(len(d[4] or []) == sigs[symbol]['arity'], 'direct signature arity')
                check(sigs[symbol]['result_sort'] == ('prop' if domain == 3 else 'value'), 'converter-selected logical result sort')
                found.add(d[1])
    check(found == set(direct), 'all selected direct signatures attached')
    for name, target in [('Silver_arguments__input_is_valid', 'Silver_arguments__input_is_valid___logic_fun'), ('Silver_io__put__T6s', 'Standard__string'), ('Silver_io__put_line__T4s', 'Standard__string')]:
        check(any(d[0] == 'W_INCLUDE_DECLARATION' and d[3][4] == target and d[5] == 1 for d in theories[name][6] or []), 'native logical export '+name)
    for theory, clone_id, module in [('Standard__string',1176,'Unconstr_Array'), ('Standard__character___rep',439,'Rep_Proj_Int'), ('Array__Int__Standard__character',473,'Array__1')]:
        check(any(d[0] == 'W_CLONE_DECLARATION' and d[1] == clone_id and d[3][4] == module for d in theories[theory][3]), 'selected imported signature clone')
    sources = archive(ROOT/'docs/evidence/retained-producer-main-types-20261018/sources.tar.gz')
    anchors = {'installed/share/spark/theories/_gnatprove_standard.mlw': [
        'type int__ref  = { mutable int__content', 'type bool__ref = { mutable bool__content',
        'type map__ref = { mutable map__content', 'val function get map I1.t : component_type',
        'val function slice map I1.t I1.t : map'],
        'installed/share/spark/theories/ada__model.mlw': [
        'function to_rep t : rep_type', 'clone export Rep_Proj_Base with', 'type rep_type = int',
        'let function to_array [@rewrite:to_array] (a : __t) : map',
        'let function of_array [@rewrite:of_array] (a : map) (f l : index_rep_type) : __t',
        'function first [@name:First]', 'function last [@name:Last]', 'function length (a : __t) : int'],
        'installed/libexec/spark/share/why3/theories/int.mlw': [
        'val function  (+)  int int : int', 'let predicate (<=) (x y : int)']}
    for member, strings in anchors.items():
        source = sources[member].decode()
        for text in strings:
            check(text in source, 'reviewed complete imported signature source anchor')
    for d in selected.values():
        context(d[6], 'prop', sigs)
        context(d[7], 'prop', sigs)
    check(set(SIGNATURE_USES) == set(sigs), 'complete selected 29-symbol use coverage')
    return dict(SIGNATURE_USES)


def main():
    start = time.monotonic()
    inputs = read(HERE/'inputs.json')
    for path, expected in inputs['exact_inputs'].items():
        raw = (ROOT/path).read_bytes()
        frozen = subprocess.check_output(['git', 'show', inputs['author_freeze']+':'+path], cwd=ROOT)
        check(raw == frozen and identity(raw) == expected, 'exact author freeze '+path)
    for path, expected in inputs['providers'].items():
        check(identity((ROOT/path).read_bytes()) == expected, 'provider identity '+path)
    manifest = read(PACKET/'identity.json')
    native = archive(PACKET/'retained-main-input.tar.gz')
    check(identity((PACKET/'retained-main-input.tar.gz').read_bytes())['sha256'] == manifest['archive_sha256'], 'retained native archive identity')
    check(set(native) == {r['path'] for r in manifest['members']}, 'all native archive members manifested')
    for row in manifest['members']:
        check(identity(native[row['path']]) == {k:row[k] for k in ('bytes','sha256')}, 'native member identity')
        check(native[row['path']] == (Path(manifest['origin'])/row['path']).read_bytes(), 'complete live retained artifact attachment')
    libraries = [p for p in native if p.startswith('silver_')]
    check(len(libraries) == 6, 'six selected library source files')
    for path in libraries:
        check(native[path] == (ROOT/'src'/path).read_bytes(), 'exact current selected library source '+path)
    source_bytes, source_ids = source_bindings(manifest)
    source_spans, refinement_calls = producer_control_audit(source_bytes)
    raw = json.loads(native['obj/gnatprove/main.gnat-json'])
    authored = read(PACKET/'selected-contracts.json')
    selected = {}
    for theory in raw['theory_declarations']:
        for d in theory[3] or []:
            if d[0] == 'W_FUNCTION_DECL' and d[2] == 4:
                name = ident(d[3])
                if name in authored:
                    check(name not in selected and d[9] is None, 'unique selected abstract program declaration')
                    selected[name] = d
    check(set(selected) == set(authored) == {'input_is_valid','first_or_default','reject','put','put_line'}, 'exact five selected contracts')
    sig_uses = signatures_audit(raw, selected)
    recovered = {}
    for name, d in selected.items():
        a = authored[name]
        formals = {ident(b[3]):ty(b[4]) for b in d[4] or []}
        check(a['formals'] == [[ident(b[3]), ty(b[4])] for b in d[4] or []] and a['result_type'] == ty(d[8]), 'formal/result type correspondence')
        effects = d[5]
        check(effects[0] == 'W_EFFECTS' and not effects[5] and a['native_exceptional_posts'] == 0, 'no selected exceptional posts')
        reads = {ident(v): ty(v[4])+'__ref' for v in effects[3] or []}
        writes = {ident(v): ty(v[4])+'__ref' for v in effects[4] or []}
        check(a['reads'] == reads and a['writes'] == writes, 'actual global-reference types and native effects')
        expected_counts = (0,0) if name in ('input_is_valid','first_or_default') else (7,7) if name == 'reject' else (7,11)
        check((len(reads),len(writes)) == expected_counts, 'selected effects cardinalities')
        check(strip(d[6])[0] == 'W_LITERAL' and strip(d[6])[3] == 0, 'explicit True precondition is still a singleton input')
        variables = set(formals) | {'result'} | set(reads) | set(writes)
        types = formals | {'result': ty(d[8])}
        seen = set()
        recovered[name] = {}
        for label, term in [('pre',d[6]),('post',d[7])]:
            compare_tree(term, a[label], {v:v for v in types}, reads|writes, types, a['binders'], seen)
            base = native_cost(term, {})
            coeff = {v:native_cost(term,{v:2})-base for v in sorted(variables)}
            coeff = {v:c for v,c in coeff.items() if c}
            derived = {'constant':base-sum(coeff.values()), 'coefficients':coeff, 'at_unit_weights':base}
            check(derived == a[label+'_lexical'], 'independent native lexical coefficient evaluation '+name+'/'+label)
            mixed = {v:2+i*3 for i,v in enumerate(sorted(variables))}
            check(native_cost(term,mixed) == derived['constant']+sum(c*mixed[v] for v,c in coeff.items()), 'mixed lexical-weight agreement')
            recovered[name][label] = derived
        check(seen == set(a['binders']), 'all projected binders attached exactly once')
        extracted = native_result_split(d[7])
        if name in ('input_is_valid','first_or_default'):
            check(extracted is not None and a['normal_post_extraction'] is not None, 'selected query result extraction')
            for label, term in zip(('definition','residual'), extracted):
                projection = a['normal_post_extraction']
                compare_tree(term, projection[label], {v:v for v in types}, reads|writes, types, a['binders'], set())
                base = native_cost(term,{})
                coeff = {v:native_cost(term,{v:2})-base for v in sorted(variables)}
                coeff = {v:c for v,c in coeff.items() if c}
                derived = {'constant':base-sum(coeff.values()),'coefficients':coeff,'at_unit_weights':base}
                check(derived == projection[label+'_lexical'], 'independent normal-post extracted '+label+' envelope')
                recovered[name][label] = derived
        else:
            check(extracted is None and a['normal_post_extraction'] is None, 'unit procedure has no result-equality extraction')
    result = {'status':'pass','author_freeze':inputs['author_freeze'],
              'exact_inputs':inputs['exact_inputs'],'providers':inputs['providers'],
              'audit_code_identity':identity(Path(__file__).read_bytes()),
              'reviewed_signature_identity':identity((HERE/'selected-signatures.json').read_bytes()),
              'native_archive_members':{p:identity(b) for p,b in native.items()},
              'complete_source_members':source_ids,'signature_uses':sig_uses,
              'strict_source_spans':source_spans,'refinement_registration_calls':refinement_calls,
              'context_nodes':CONTEXT_NODES,'projection_nodes':TREE_NODES,
              'recovered_contract_profiles':recovered,'checks':CHECKS,
              'elapsed_seconds':time.monotonic()-start,'selected_contracts':5,
              'typed_contract_slice_accepted':True,'numeric_main_U_H_established':False,
              'ordinary_Main_source_emitter_complete':False,'issue_178_complete':False,
              'whole_rule_complete':False,'source_fetches':0,'target_runs':0,
              'compiler_runs':0,'solver_runs':0,'proof_runs':0,'capture_runs':0,
              'author_or_predecessor_checker_runs':0,'finite_tests_are_universal_proof':False}
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('exact_inputs','providers','native_archive_members','complete_source_members','signature_uses','recovered_contract_profiles','strict_source_spans','refinement_registration_calls')},indent=2,sort_keys=True))


if __name__ == '__main__':
    main()
