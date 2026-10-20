"""Read-only check of new R56 projections, arithmetic and exact source bytes."""
from pathlib import Path
import gzip,json,platform,time
from project import HERE,REPO,CASES,identity,project
from family_model import calculate,Family
from compose import compose
from audit_sources import audit

def controls():
    # Weighted max and repeated-formal control on an independent tiny term:
    # a sum-of-alternatives bug or loss of formal multiplicity must not pass.
    m=Family(dict(symbols={},variables={},terms=[],bindings=[]),{})
    ty=('a',17,());m.variables[1]=(ty,{})
    v=m.make('var',1,ty,());c=m.make('const',(0,0),ty,())
    twice=m.make('app',23,ty,(),[v,v]);choice=m.choice([v,twice])
    assert m.linear(choice,(1,))==((1,0,0,1),(2,))
    assert m.dimensions(choice)==(3,0,0,1)
    substituted=m.substitute(twice,{1:c},{})
    assert m.dimensions(substituted)==(3,0,0,1)
    try:m.match_type(('a',1,()),('a',2,()),{})
    except AssertionError:pass
    else:raise AssertionError('mismatched type accepted')
    return 4

def main():
    started=time.monotonic();inputs=json.loads((HERE/'inputs.json').read_text())
    for path,pin in inputs['files'].items():assert identity((REPO/path).read_bytes())==pin,path
    witnesses=audit();assert witnesses==json.loads((HERE/'source-witnesses.json').read_text())
    families=[];projected=[];checks=0
    for case in CASES:
        p=project(case);assert p==json.loads((HERE/f'{case}-types.json').read_text());projected.append(p)
        f,d=calculate(case);f=json.loads(json.dumps(f));d=json.loads(json.dumps(d))
        assert f==json.loads((HERE/f'{case}-family.json').read_text())
        assert d==json.loads(gzip.decompress((HERE/f'{case}-details.json.gz').read_bytes()))
        families.append(f)
        checks+=sum(s['seed_opened_shape_checks'] for s in f['stages'].values())
    result=compose(families);assert result==json.loads((HERE/'result.json').read_text())
    assert result['registered_roots']==118 and result['nontrivial_registered_roots']==116
    assert result['ordinary_root_driver_pairs']==354 and result['first_inline_episodes_all_five_processes_upper']==364
    assert result['all_five_processes']['Ident']==792911
    input_ce=families[-1]['stages']['ce']['roots'][0]
    assert input_ce['Ident']['total']==1145 and input_ce['kernel']['fresh_Ident']==235
    assert input_ce['kernel']['type_instantiation_requests']==669
    assert all(result['open'].values()) and not result['budgets']['stage_receives_new_escape_allowance']
    finite=[result['all_five_processes']['Ident']]+list(result['all_five_processes']['kernel'].values())+list(result['all_five_processes']['candidate_operations'].values())
    assert all(0<=n<(1<<62) for n in finite)
    output=dict(status='PASS',platform=platform.system(),machine=platform.machine(),
        elapsed_seconds=time.monotonic()-started,pinned_inputs=len(inputs['files']),
        source_files=len(witnesses['files']),source_excerpts=sum(len(x['excerpts']) for x in witnesses['files'].values()),
        initial_logic_ind_keys=sum(len(p['initial_logic_ind_projection']['same_key_objects']) for p in projected),
        registered_root_joins=118,root_route_calculations=236,CE_seed_shape_checks=checks,
        controls=controls(),new_native_runs=0,predecessor_checkers_replayed=0,
        source_arguments_machine_checked=False)
    print(json.dumps(output,sort_keys=True,indent=2))

if __name__=='__main__':main()
