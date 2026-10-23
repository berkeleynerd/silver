"""Review frozen shared-demand JSON and formulas, without importing any checker."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import time

HERE=Path(__file__).resolve().parent
ROOT=Path(sys.argv[1])
FREEZE=sys.argv[2]
PACKET=ROOT/'docs/evidence/retained-why-shared-demand-20261020'

def ident(b):return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def read(p):return json.loads(p.read_text())
def main():
    started=time.perf_counter();checks=0
    paths=['docs/research/retained-why-shared-demand.md']
    paths+=subprocess.check_output(['git','ls-tree','-r','--name-only',FREEZE,'docs/evidence/retained-why-shared-demand-20261020'],cwd=ROOT,text=True).splitlines()
    frozen={}
    for p in paths:
        b=subprocess.check_output(['git','show',f'{FREEZE}:{p}'],cwd=ROOT)
        assert b==(ROOT/p).read_bytes(),p
        frozen[p]=ident(b);checks+=1
    manifest=read(PACKET/'inputs.json')
    for p,i in manifest['files'].items():
        assert ident((ROOT/p).read_bytes())==i,p;checks+=1
    for p,i in manifest['local_data'].items():
        assert ident((PACKET/p).read_bytes())==i,p;checks+=1
    for w in read(PACKET/'source-witnesses.json'):
        with tarfile.open(ROOT/w['archive']) as t:b=t.extractfile(w['member']).read()
        assert ident(b)==w['identity'];checks+=1
        ls=b.decode().splitlines()
        for ex in w['excerpts']:
            assert '\n'.join(ls[ex['first']-1:ex['last']])==ex['text'];checks+=1
    r=read(PACKET/'result.json')
    assert r['budgets']=={'per_process_escape':2,'save_entering_callbacks_upper':2,'saves_upper':3,'allowance_renewed_at_stage_boundary':False};checks+=1
    residuals={'lookup_library_constructors','later_preparation','solver_request_printers','other_callbacks_and_shutdown'}
    for row in r['cases']:
        state=row['attachment']['owners'];parts=row['demand']['components'];known=row['known_demand']
        assert set(row['missing_residual_contracts'])==residuals
        assert not row['complete_six_owner_numeric_input'] and not row['actual_whole_process_headroom']
        assert not row['through_R58_complete_including_lookup'];checks+=3
        for name,d in known.items():
            for field in ('increments','requests'):
                assert d[field]==sum(p[name][field] for p in parts.values());checks+=1
            s=state[name];out=row['conditional_transfers'][name]
            assert out['counter']['final_upper']==s['counter']+d['increments'];checks+=1
            if name=='Ident':continue
            q=out['backing']
            if name=='Task.Stdecl.Hcpt':
                n=s['bucket_nodes']+d['requests'];a=max(s['outer_length'],4*n)
                assert q['stored_entries_upper']==n
                assert q['individual_array_length_upper']==a
                assert q['single_bucket_chain_cells_upper']==n
                assert q['old_plus_new_array_slots_upper']==2*a
                assert 2*a<=min((1<<62)-1,(1<<54)-1);checks+=5
            else:
                n=s['allocated_key_slots']+d['requests']
                a=max(s['outer_length'],3*s['outer_length']//2+3,3*n+3)
                b=max(s['maximum_bucket_length'],3*n//2+3)
                assert q['live_entries_upper']==n
                assert q['individual_outer_array_length_upper']==a
                assert q['individual_bucket_length_upper']==b
                assert 3*max(a,b)+6<=(1<<62)-1
                assert a<=(1<<54)-1 and b+2<=(1<<54)-3;checks+=5
    assert not r['whole_pipeline_capacity'] and not r['actual_whole_process_headroom'];checks+=1
    result={'status':'pass','freeze':FREEZE,'exact_inputs':frozen,'focused_checks':checks,
            'elapsed_seconds':time.perf_counter()-started,'native_runs':0,'predecessor_replays':0,
            'author_checker_replayed':False,'limits':'Checks recorded arithmetic and exact inputs, not source-proof universality or omitted demand.'}
    (HERE/'shared-audit-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='exact_inputs'},indent=2))
if __name__=='__main__':main()
