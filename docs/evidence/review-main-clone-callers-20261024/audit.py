#!/usr/bin/env python3
"""New finite clone-caller audit; no author/predecessor checker replay.

Independently lex retained corpus bytes and exercise fresh scoped maps at the
already accepted bridge boundary. The report supplies the source argument.
"""
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import re
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT/'docs/evidence/retained-main-construction-demand-20261024/clone-callers'
FREEZE = 'b5cfa9c1a501eefdd5db89670ca60ccbc399e036'
CHECKS = Counter()


def check(ok, label):
    assert ok, label
    CHECKS[label] += 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def identities():
    inputs = {}
    files = sorted(PACKET.iterdir()) + [ROOT/'docs/research/retained-main-construction-demand.md']
    for p in files:
        if not p.is_file():
            continue
        rel = str(p.relative_to(ROOT))
        data = subprocess.check_output(['git','show',FREEZE+':'+rel],cwd=ROOT)
        check(data == p.read_bytes(), 'exact author freeze')
        inputs[rel] = sha(data)
    manifest = json.loads((PACKET/'identity.json').read_text())
    for p in manifest['providers']:
        check(sha((ROOT/p['path']).read_bytes()) == p['sha256'], 'provider identity')
    for archive in manifest['archives']:
        p = ROOT/archive['path']
        check(sha(p.read_bytes()) == archive['sha256'], 'archive identity')
        with tarfile.open(p) as tar:
            for row in archive['files']:
                data = tar.extractfile(row['path']).read()
                check(sha(data) == row['sha256'], 'complete source identity')
                lines = data.decode().splitlines()
                for span in row.get('spans',[]):
                    source = '\n'.join(lines[span['first']-1:span['last']])+'\n'
                    check(sha(source.encode()) == span['sha256'], 'source span identity')
                    for anchor in span['anchors']:
                        check(anchor in source, 'source anchor')
    return inputs


def lex(source):
    """Independent scanner: nested comments, escaped strings and attributes."""
    out = []
    i, line = 0, 1
    while i < len(source):
        start, start_line = i, line
        if source[i].isspace():
            line += source[i] == '\n'
            i += 1
            continue
        if source.startswith('(*)',i):
            out.extend((ch,line,i+n) for n,ch in enumerate('(*)'))
            i += 3
            continue
        if source.startswith('(*',i):
            depth = 1
            i += 2
            while depth:
                assert i < len(source), 'unterminated comment'
                if source.startswith('(*)',i):
                    i += 3
                elif source.startswith('(*',i):
                    depth += 1; i += 2
                elif source.startswith('*)',i):
                    depth -= 1; i += 2
                else:
                    line += source[i] == '\n'; i += 1
            continue
        if source[i] == '"':
            i += 1
            while source[i] != '"':
                if source[i] == '\\':
                    i += 2
                else:
                    line += source[i] == '\n'; i += 1
            i += 1
            out.append(('<string>',start_line,start))
            continue
        if source.startswith('[@',i):
            end = source.index(']',i)+1
            line += source[i:end].count('\n')
            i = end
            out.append(('<attribute>',start_line,start))
            continue
        word = re.match(r"[A-Za-z_][A-Za-z_0-9']*",source[i:])
        if word:
            i += len(word[0]); out.append((word[0],start_line,start))
        else:
            i += 1; out.append((source[start:i],start_line,start))
    return out


def inventory():
    prior = json.loads((ROOT/'docs/evidence/retained-producer-import-context-20261018/result.json').read_text())
    expected = json.loads((PACKET/'inventory.json').read_text())
    fixed = {s['target'] for m in prior['modules'].values() for s in m['statements'] if s['kind']=='clone'}
    main = {'ada__model.Static_Discrete','ada__model.Dynamic_Discrete','ada__model.Rep_Proj_Int',
            'ada__model.Constr_Array','ada__model.Unconstr_Array','_gnatprove_standard.Array__1'}
    origins = fixed | main
    closure = set(origins)
    pending = list(origins)
    while pending:
        current = pending.pop()
        if current not in prior['modules']:
            check(current == 'why3.WellFounded.WellFounded', 'only reviewed builtin is outside corpus')
            continue
        for s in prior['modules'][current]['statements']:
            if s['target'] not in closure:
                closure.add(s['target']); pending.append(s['target'])
    check(len(fixed)==64 and len(origins)==69, 'origin set from accepted dependency graph')
    check(origins == set(expected['all_origins']), 'independent origin equality')
    check(closure == set(expected['dependency_closure']) and len(closure)==97, 'independent dependency closure')
    with tarfile.open(ROOT/'docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz') as tar:
        pmodule = tar.extractfile('src/mlw/pmodule.ml').read().decode().splitlines()
    builtin = '\n'.join(pmodule[411:473])+'\n'
    check('t_forall_close [var_r;var_x]' in builtin and
          'Decl.make_ls_defn ps_wf [var_r] f' in builtin and
          'create_pure_decl (Decl.create_ind_decl' in builtin and
          'create_pure_decl (Decl.create_logic_decl' in builtin,
          'WellFounded source has closed pure declaration constructors')
    objects, refinements, candidates, modules = {}, {}, {}, {}
    with tarfile.open(ROOT/'docs/evidence/retained-producer-import-context-20261018/sources.tar.gz') as tar:
        for filekey, row in prior['files'].items():
            source = tar.extractfile(row['path']).read().decode()
            tokens = lex(source)
            heads = [i for i,(tok,_,pos) in enumerate(tokens)
                     if tok in {'module','theory'} and (pos == 0 or source[pos-1]=='\n')]
            for index, begin in enumerate(heads):
                end = heads[index+1] if index+1<len(heads) else len(tokens)
                ts = tokens[begin:end]
                key = filekey+'.'+ts[1][0]
                check(ts[2][0] != ':' and ts[2][1]>ts[1][1], 'module interface absent')
                modules[key] = ts
                for j,(token,ln,_) in enumerate(ts):
                    if token not in {'val','let'}:
                        continue
                    at = j+1
                    while ts[at][0] in {'ghost','partial','<attribute>'}:
                        at += 1
                    if ts[at][0] in {'function','predicate','constant','lemma','rec','exception'}:
                        continue
                    check(ts[at][0] != 'ref', 'no unclassified reference declaration')
                    if ts[at][0] == '(':
                        close = at+1
                        while ts[close][0] != ')':
                            close += 1
                        name = ''.join(x[0] for x in ts[at:close+1]); at = close+1
                    else:
                        name = ts[at][0]; at += 1
                    while ts[at][0] == '<attribute>':
                        at += 1
                    follow = ts[at][0]
                    if token == 'val' and follow == ':':
                        objects.setdefault(key,[]).append({'name':name,'line':ln})
                    elif token == 'val' and follow == '=':
                        check(ts[j-1][0] in {',','with'}, 'val equality is clone refinement')
                        refinements.setdefault(key,[]).append({'name':name,'line':ln})
                    elif token == 'let' and follow in {':','='}:
                        eq = at
                        while ts[eq][0] != '=':
                            eq += 1
                        stop = eq+1
                        while ts[stop][0] not in {'in','let','end','module','theory','axiom','val','function','predicate','lemma'}:
                            stop += 1
                        if key in closure:
                            check(ts[stop][0] == 'in', 'nullary let has its own lexical continuation')
                        candidates.setdefault(key,[]).append((name,ln,ts[stop][0]))
    check(set(modules)==set(prior['modules']), 'complete independent module inventory')
    check(objects == expected['global_objects'], 'independent four-global classification')
    check(refinements == expected['routine_refinements'], 'independent three-refinement classification')
    check(not origins & objects.keys(), 'all origins lack top-level program objects')
    check('mach.int.Random63' not in closure, 'random state excluded from dependency closure')
    state = {'__HEAP','no__return','spark__branch'}
    for key in closure & modules.keys():
        words = [x[0] for x in modules[key]]
        if key == '_gnatprove_standard.Main':
            check(all(words.count(s)==1 for s in state), 'standard state occurs only at declarations')
        else:
            check(not state.intersection(words), 'dependency has no foreign state reference')
    for key in origins:
        words = {x[0] for x in modules[key]}
        check(not words.intersection({'rec','while','for','try','raise','exception','invariant','by'}), 'origin excludes recursive loop exception invariant witness syntax')
        actual = [(c['name'],c['line'],'in') for c in expected['origin_inventory'][key]['plain_let_candidates']]
        check(candidates.get(key,[]) == actual, 'independent per-origin lexical let classification')
    count = sum(len(candidates.get(key,[])) for key in origins)
    check(count==26, 'all 26 lexical candidates accounted for')
    return {'origins':69,'dependency_modules':97,'lexical_candidates':count,
            'global_objects':objects,'routine_refinements':refinements,
            'module_count':len(modules),
            'extra_source_review':{'path':'src/mlw/pmodule.ml','first':412,'last':473,
                                   'sha256':sha(builtin.encode()),
                                   'builtin':'why3.WellFounded.WellFounded'}}


def maps_and_callers():
    b = load('accepted_bridge',PACKET.parent/'bridge.py')
    c = load('clone_callers_model',PACKET/'callers.py')
    k = b.k
    integer = b.Ty('int')
    original = [k.Var(i,integer) for i in range(1,40)]
    current = 1000
    counts = Counter()

    def fresh_mapping(sm, variables):
        nonlocal current
        result = dict(sm)
        for v in variables:
            current += 1; result[v] = k.Var(current,integer)
        return result

    def formula(free, saved=False):
        bound = original[-1]
        f = k.close('forall',(bound,),k.node('app',*(k.var(v) for v in free),k.var(bound),symbol='R'),k.Ledger(1000))
        if saved:
            old = original[-2]
            f = k.close('forall',(bound,),k.node('app',k.var(old),symbol='P'),k.Ledger(1000))
            f = k.subst({old:k.var(free[0])},f,k.Ledger(1000))
        return f

    for _ in range(30):
        outer = {}
        args = fresh_mapping(outer,original[:2])
        oldies = fresh_mapping(args,original[2:4])
        local = fresh_mapping(oldies,original[4:5])
        branch = fresh_mapping(local,original[5:7])
        routine = fresh_mapping(local,original[7:8])
        for sm,free in [(args,original[:2]),(oldies,original[:4]),(local,original[:5]),
                        (branch,original[:7]),(routine,original[:5]+original[7:8])]:
            for stored in (False,True):
                term = formula(free,stored)
                b.require_generic_map_premise(term,sm)
                check(True,'fresh lexical history satisfies accepted root premise')
                check(all(v.tag>1000 for v in sm.values()),'all targets postdate complete origin')
                counts['root_premises'] += 1
        check(not outer and len(args)==2 and len(local)==5,'inner lexical maps do not escape declarations')
        # Actual native sm_save_olds reverses a current->old relation. Each
        # old source was created once in its label table, then freshly cloned.
        new_old_to_current={oldies[original[2]]:args[original[0]],oldies[original[3]]:args[original[1]]}
        reverse={n:o for o,n in new_old_to_current.items()}
        check(reverse[args[original[0]]]==oldies[original[2]] and len(reverse)==2,'oldie reversal recovers distinct allocated targets')
    term = formula(original[:1])
    try:
        b.require_generic_map_premise(term,{})
    except ValueError:
        check(True,'foreign free variable would violate empty inherited map')
    else:
        raise AssertionError('foreign variable was incorrectly covered')

    N,S=c.Node,c.Spec
    # Exact direct sites from native constructor rows, with a changed output
    # record family at the second clone boundary. No ancestor-weight reuse.
    first=N('scope',(N('Dlogic',roots=4),N('Dind',roots=3),N('Dprop'),
        N('Dprop',selected=False),N('refined_val',spec=S(2,1,(2,))),
        N('LDsym',(N('Cfun',(N('let',(N('LDvar',(N('pure'),)),N('if',(N('assert'),N('Capp'),N('Capp'))))),),S(1,2,(1,))),))))
    check(c.fold(first)==Counter(clone_term=19,clone_cty=2,direct_c_app=3),'direct source-site count including comparisons and refinement')
    second=N('scope',(N('Dprop'),N('clone_metadata'),N('use'),
        N('LDsym',(N('Cany',spec=S(1,0)),))))
    check(c.fold(second)==Counter(clone_term=2,clone_cty=1),'later clone counts transformed output records')
    try:
        c.fold(N('unknown'))
    except ValueError:
        check(True,'unknown caller family is not zero cost')
    else:
        raise AssertionError('unknown constructor accepted')
    counts['fresh_targets']=current-1000
    return dict(counts)


def main():
    started=time.monotonic()
    inputs=identities()
    corpus=inventory()
    histories=maps_and_callers()
    check(all(sha((ROOT/p).read_bytes())==h for p,h in inputs.items()),'author inputs unchanged')
    result={'status':'pass','reviewed_commit':FREEZE,'assertions':sum(CHECKS.values()),
            'families':dict(CHECKS),'independent_inventory':corpus,'scope_histories':histories,
            'elapsed_seconds':time.monotonic()-started,'host':platform.platform(),
            'author_or_predecessor_checker_replays':0,'native_runs':0,
            'machine_checked_universal_proof':False,'complete_native_bytes':False,
            'complete_source_to_vc_storage':False,'inputs':inputs}
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='inputs'},indent=2))


if __name__=='__main__':
    main()
