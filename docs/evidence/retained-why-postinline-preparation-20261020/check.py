"""Focused new R58 finite/source correspondence check; no predecessor replay."""
import json,platform,time
from inventory import HERE,REPO,CASES,read,identity,inventory,drivers
from compose import compose,unit
from audit_sources import audit

def normalized(x):return json.loads(json.dumps(x))

def controls():
    # Equal visible mass alone cannot eliminate the hidden-map charge.
    small=unit(99,8,6,1,5,7);large=unit(99,8,106,1,5,7)
    assert large['term_and_opening_entries']>small['term_and_opening_entries']
    # Goal seed images need their separate V, even though the context has V=1.
    goal=unit(99,8,6,6,5,7)
    assert goal['free_variable_scan_entries']>small['free_variable_scan_entries']
    # A key can be removed and later reinserted by an earlier declaration.
    # Bound propagation by recorded entries, not distinct keys.
    closure={};writes=removals=0
    for event in [('record',1,{2}),('use',1,None),('record',1,{3}),('use',1,None)]:
        action,key,value=event
        if action=='record':closure[key]=value;writes+=1
        else:
            pending={key}
            while pending:
                nxt=set()
                for x in pending:
                    if x in closure:nxt.update(closure.pop(x));removals+=1
                pending=nxt
    assert removals==writes==2 # greater than one distinct recorded key
    # Separate stage maxima may overcharge the same escaped episode. They do
    # not justify allocating independent additional episodes to those stages.
    episodes=[(3,1,8),(2,9,4)]
    assert max(map(sum,episodes))<=sum(max(e[i] for e in episodes) for i in range(3))
    return 4

def main():
    start=time.monotonic();inputs=read(HERE/'inputs.json')
    for path,pin in inputs['files'].items():assert identity((REPO/path).read_bytes())==pin,path
    rows=[]
    for c in CASES:
        x=normalized(inventory(c));assert x==read(HERE/f'{c}-inventory.json'),c
        rows.append(x)
    driver=normalized(drivers());assert driver==read(HERE/'driver-inventory.json')
    source=audit();assert source==read(HERE/'source-witnesses.json')
    result=compose(rows,driver);assert result==read(HERE/'result.json')
    assert not result['budgets']['fresh_stage_escape_allowance']
    assert all(result['remaining'].values())
    print(json.dumps(dict(status='PASS',platform=platform.system(),machine=platform.machine(),
        elapsed_seconds=time.monotonic()-start,pinned_files=len(inputs['files']),
        new_inventories=len(rows),singleton_nonrecursive_logic_bodies=sum(len(r['no_recursive_singleton_bodies']) for r in rows),
        ordinary_registered_root_driver_pairs=354,preparation_episodes_upper=364,
        source_files=len(source['files']),source_excerpts=sum(len(f['excerpts']) for f in source['files'].values()),
        controls=controls(),native_runs=0,solver_runs=0,proof_runs=0,predecessor_checkers_replayed=0,
        source_arguments_machine_checked=False),sort_keys=True,indent=2))

if __name__=='__main__':main()
