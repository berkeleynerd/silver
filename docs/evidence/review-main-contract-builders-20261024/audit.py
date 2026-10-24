#!/usr/bin/env python3
"""Independent request-partition audit; no checker mains or native tools.

The author builders are the system under test, not the specification oracle.
Source inventories, expected ownership and the failing-prefix example are
derived here. No author or predecessor checker module is imported.
"""
from collections import Counter
from functools import lru_cache
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
PACKET = ROOT/'docs/evidence/retained-main-construction-demand-20261024/contract-builders'
FREEZE = '49c18b7ef37967c8b6f486721fd006d61857a8fb'
COUNTS = Counter()


def check(ok, family):
    assert ok, family
    COUNTS[family] += 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def identities():
    inputs = {}
    for p in sorted(PACKET.iterdir()) + [ROOT/'docs/research/retained-main-construction-demand.md']:
        if not p.is_file():
            continue
        rel = str(p.relative_to(ROOT))
        expected = subprocess.check_output(['git','show',FREEZE+':'+rel],cwd=ROOT)
        check(expected == p.read_bytes(), 'exact author freeze')
        inputs[rel] = sha(expected)
    manifest = json.loads((PACKET/'identity.json').read_text())
    for p in manifest['providers']:
        check(sha((ROOT/p['path']).read_bytes()) == p['sha256'], 'provider identity')
    sources = {}
    for archive in manifest['archives']:
        path = ROOT/archive['path']
        check(sha(path.read_bytes()) == archive['sha256'], 'archive identity')
        with tarfile.open(path) as t:
            for row in archive['files']:
                data = t.extractfile(row['path']).read()
                check(sha(data) == row['sha256'], 'complete source identity')
                sources[row['path']] = data.decode()
                lines = data.decode().splitlines()
                for span in row['spans']:
                    text = '\n'.join(lines[span['first']-1:span['last']])+'\n'
                    check(sha(text.encode()) == span['sha256'], 'source span identity')
                    for anchor in span['anchors']:
                        check(anchor in text, 'source anchor')
    return inputs, sources


def lex(src):
    """Reviewer scanner; comments, quoted strings and attributes are opaque."""
    i = 0
    out = []
    while i < len(src):
        if src[i].isspace():
            i += 1
        elif src.startswith('(*)',i):
            out.extend(['(','*',')']); i += 3
        elif src.startswith('(*',i):
            depth = 1; i += 2
            while depth:
                assert i < len(src)
                if src.startswith('(*)',i): i += 3
                elif src.startswith('(*',i): depth += 1; i += 2
                elif src.startswith('*)',i): depth -= 1; i += 2
                else: i += 1
        elif src[i] == '"':
            i += 1
            while src[i] != '"':
                i += 2 if src[i] == '\\' else 1
            i += 1; out.append('<string>')
        elif src.startswith('[@',i):
            i = src.index(']',i)+1; out.append('<attribute>')
        else:
            m = re.match(r"[A-Za-z_][A-Za-z_0-9']*",src[i:])
            token = m[0] if m else src[i]
            out.append(token); i += len(token)
    return out


def inventory():
    graph = json.loads((ROOT/'docs/evidence/retained-producer-import-context-20261018/result.json').read_text())
    actual = json.loads((PACKET/'sites.json').read_text())
    main = {'ada__model.Static_Discrete','ada__model.Dynamic_Discrete','ada__model.Rep_Proj_Int',
            'ada__model.Constr_Array','ada__model.Unconstr_Array','_gnatprove_standard.Array__1'}
    closure = set(main)
    todo = list(main)
    while todo:
        for s in graph['modules'][todo.pop()]['statements']:
            if s['kind'] == 'clone' and s['target'] not in closure:
                closure.add(s['target']); todo.append(s['target'])
    check(closure == set(actual['main_clone_ancestor_inventory']), 'eleven-module clone ancestry')
    fixed = {s['target'] for m in graph['modules'].values() for s in m['statements'] if s['kind']=='clone'}
    check((fixed | main)-closure == set(actual['other_fixed_clone_origins_remaining']), 'all remaining origins explicit')
    definitions = set()
    with tarfile.open(ROOT/'docs/evidence/retained-producer-import-context-20261018/sources.tar.gz') as tar:
        for module in sorted(closure):
            filekey, name = module.rsplit('.',1)
            path = graph['files'][filekey]['path']
            src = tar.extractfile(path).read().decode()
            tokens = lex(src)
            starts = [i for i,t in enumerate(tokens) if t in {'module','theory'}]
            begin = next(i for i in starts if tokens[i+1] == name)
            end = next((i for i in starts if i > begin),len(tokens))
            ts = tokens[begin:end]
            check(not {'old','at','raises','exception','ghost',"'"} & set(ts), 'whole-origin exclusion tokens')
            for i,t in enumerate(ts):
                if t == 'let':
                    check(ts[i+1]=='function', 'only explicit function definitions')
                    definitions.add((module,ts[i+2]))
    check(definitions == {('ada__model.Index_Type','first'),('ada__model.Index_Type','last'),
                         ('ada__model.Unconstr_Array','to_array'),('ada__model.Unconstr_Array','of_array')},
          'four origin executable definitions')
    return {'ancestors':len(closure),'remaining_origins':len((fixed|main)-closure),'definitions':sorted(definitions)}


@lru_cache(None)
def trees(keys):
    if not keys: return (None,)
    return tuple((keys[i],l,r) for i in range(len(keys))
                 for l in trees(keys[:i]) for r in trees(keys[i+1:]))


def submap(a,b,pairs,temporaries):
    if a is None: return True
    if b is None: return False
    x,l,r = a; y,s,t = b
    check((x,y) not in pairs, 'submap disjoint comparison rectangles')
    pairs.add((x,y))
    if x==y: return submap(l,s,pairs,temporaries) and submap(r,t,pairs,temporaries)
    temporaries.append(1)
    if x<y: return submap((x,l,None),s,pairs,temporaries) and submap(r,b,pairs,temporaries)
    return submap((x,None,r),t,pairs,temporaries) and submap(l,b,pairs,temporaries)


def diagrams(sources):
    sp = importlib.util.spec_from_file_location('reviewed_contract_builders',PACKET/'builders.py')
    c = importlib.util.module_from_spec(sp); sys.modules[sp.name]=c; sp.loader.exec_module(c)
    k, Ty = c.k, c.Ty
    INT, BOOL, UNIT = Ty('int'), Ty('bool'), c.UNIT
    formal = c.PV(k.Var(1,INT)); actual = c.PV(k.Var(2,INT))
    # Projection is occurrence-based, independent of repeated shared types.
    def occurrences(t): return 1+sum(occurrences(x) for x in t.args)
    types = [INT,UNIT,Ty('arrow',(INT,INT)),Ty('pair',(Ty('arrow',(INT,BOOL)),INT))]
    for ty in types:
        d = c.Demand(10000,20000,30000)
        out = c.create_cty((),(),(),c.Effect(),ty,{},d)
        check(d.owner_requests['Hsty']==occurrences(ty), 'empty-post occurrence projection')
        check(not d.owner_requests['Hsity'] and not d.kernel.ident_increments, 'create has no Hsity or Ident')
        check(out.result==ty and not out.effect.reads, 'empty contract result')
    # External effects survive; formal reads are removed only from final cty.
    for n in range(1,13):
        fields = [c.Field(100+i,INT) for i in range(n)]
        regs = [c.Region(200+i,Ty('r'+str(i)),(fields[i],)) for i in range(n)]
        pvs = tuple(c.PV(k.Var(300+i,r.ty),r) for i,r in enumerate(regs))
        registry = {v.var:v for v in pvs+(formal,)}
        eff = c.Effect(frozenset(pvs),{r:frozenset({f}) for r,f in zip(regs,fields)},covers=frozenset(regs))
        d = c.Demand(10000,20000,30000)
        ct = c.create_cty((formal,),(),(),eff,UNIT,registry,d)
        check(ct.effect==eff, 'external read/write/covers survive flat create')
        check(ct.freeze==frozenset(regs), 'freeze preserves actual region identities')
        applied = c.c_app(ct,(actual,),UNIT,d)
        check(applied.effect.reads==frozenset(pvs+(actual,)), 'actual read added without losing external state')
        check(applied.effect.writes==eff.writes and applied.freeze==ct.freeze, 'same application retains write/freeze maps')
        check(d.owner_requests==Counter(Hsty=1), 'same application adds no type owner request')
    # Dead saved images and unused quantifier types must be walked.
    arrow = Ty('arrow',(INT,BOOL))
    image = k.node('const',ty=arrow)
    body = k.Term('forall',binding=k.Binding((k.Var(500,arrow),),k.node('true'),
                       ((k.node('const',ty=INT),),),{}, {k.Var(501,arrow):image}))
    q = k.Term('eps',binding=k.Binding((k.Var(502,UNIT),),body,(),{},{}),ty=UNIT)
    d = c.Demand(10000)
    c.create_cty((),(),(q,),c.Effect(),UNIT,{},d)
    check(d.calls['t_gen_fold']==5, 'stored body trigger and dead image traversal')
    check(d.calls['ty_v_fold']==8, 'explicit unused quantifier type traversal')
    # Repeated Unit construction must continue the single incoming histories.
    d = c.Demand(10000,20000,30000)
    ct = c.Contract((),(),(q,),c.Effect(),UNIT)
    for i in range(1,25):
        out = c.c_app(ct,(),UNIT,d,unit=True)
        export = d.export()
        check(export['owner_endpoints_upper']=={'Ident':10000+i,'Hsty':20000+2*i,'Hsity':30000+i}, 'cumulative Unit owners')
        check(d.calls['cty_apply_return_original']==i and not d.calls['cty_spec_root'], 'Unit discarded application remains before replacement')
        check(d.records['discarded_rho_preid']==i and d.memo_reads['fs_tuple_ids.mem']==i, 'discarded rho and tuple lookup')
    record = c.Demand()
    c.c_app(c.Contract((formal,),(),(),c.Effect(),INT),(actual,),INT,record,constructor_one=True)
    check(record.memo_reads['fs_tuple_ids.mem']==1 and not record.owner_requests, 'ordinary record probes tuple memo')
    # A first mismatching actual exposes omitted map work. We do not execute
    # OCaml: the report explains why source argument order needs an envelope.
    bad = c.PV(k.Var(3,BOOL))
    failed = c.Demand(10000)
    try: c.apply_same(c.Contract((formal,),(),(),c.Effect(),INT),(bad,),INT,failed)
    except c.SourceFailure: pass
    else: raise AssertionError('expected type mismatch')
    check(not failed.map_events and failed.kernel.map_bytes_upper==0, 'R1 first mismatch exports zero map work')
    ity = sources['src/mlw/ity.ml']
    dexpr = sources['src/mlw/dexpr.ml']
    check('apply gh same (match_v isb u v) (vsb_add vsb u v) ul vl' in ity, 'R1 source arguments have no sequential let')
    check('if vs_equal u v.pv_vs then vsb else Mvs.add u v vsb' in ity, 'R1 candidate add constructs nonidentity map')
    check('let app s cl = try Expr.c_app s vl al res :: cl with' in dexpr and '| TypeMismatch _ -> cl' in dexpr,
          'R1 overload mismatch continues later candidates')
    submap_cases = 0
    for n in range(5):
        for m in range(5):
            for a in trees(tuple(range(n))):
                for b in trees(tuple(range(1,m+1))):
                    pairs, tmp = set(),[]
                    result = submap(a,b,pairs,tmp)
                    check(result==(set(range(n))<=set(range(1,m+1))), 'submap logical result')
                    check(len(tmp)<=len(pairs)<=n*m, 'submap temporary-node product bound')
                    submap_cases += 1
    return {'unit_entries':24,'external_state_diagrams':12,'submap_cases':submap_cases,
            'R1':{'model_first_mismatch_map_events':failed.map_events,
                  'model_map_bytes_upper':failed.kernel.map_bytes_upper,
                  'source_possible_prior_nonidentity_Mvs_add':1,
                  'native_evaluation_order_executed':False}}


def main():
    start = time.monotonic()
    inputs, sources = identities()
    inv = inventory()
    ds = diagrams(sources)
    result = {'status':'pass; material finding R1 reproduced','author_commit':FREEZE,
              'assertions':sum(COUNTS.values()),'families':dict(COUNTS),
              'elapsed_seconds':time.monotonic()-start,'host':platform.platform(),
              'inputs':inputs,'inventory':inv,'diagrams':ds,
              'native_runs':0,'author_checker_runs':0,'predecessor_checker_runs':0}
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__=='__main__': main()
