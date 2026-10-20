"""Focused read-only R57 context/storage/type and source-correspondence check."""
import json,platform,time
from context_model import HERE, REPO, CASES, calculate, driver_connection, identity, without_comments
from audit_sources import audit
from compose import compose

def controls():
    # Equality of the opened body does not bound dead saved entries. Our bound
    # must depend on the producer budget even when the visible body is constant.
    visible=('true',)
    a=dict(body=visible,saved={})
    b=dict(body=visible,saved={i:('var',1000+i) for i in range(37)})
    assert a['body']==b['body'] and len(a['saved'])!=len(b['saved'])
    # Composition of variable images preserves one-node mass, including dead
    # entries. A nonleaf input is deliberately outside this inductive class.
    def rename(saved,sub):
        assert all(t[0]=='var' for t in saved.values())
        assert all(t[0]=='var' for t in sub.values())
        return {key:sub.get(t[1],t) for key,t in saved.items()}
    assert rename({7:('var',8),9:('var',10)},{8:('var',11)})=={7:('var',11),9:('var',10)}
    try:rename({7:('app',8,9)},{})
    except AssertionError:pass
    else:raise AssertionError('nonleaf hidden image accepted')
    # A substitution has at most P newly retained keys after the source's
    # free-variable restriction, independently of its incoming dead map size.
    free={3,5,7};large={i:('var',1000+i) for i in range(100)}
    assert len({v:t for v,t in large.items() if v in free})==len(free)==3
    # SMT multiplication text is inside a string, not a comment; comments nest.
    assert without_comments('syntax "(* %1 %2)" (* outer (* nested *) done *) meta ite') == 'syntax "(* %1 %2)"   meta ite'
    assert without_comments('syntax function (*) "(* %1 %2)" (* (*) nested (*x*) *) meta ite') == 'syntax function (*) "(* %1 %2)"   meta ite'
    return 6

def main():
    start=time.monotonic()
    inputs=json.loads((HERE/'inputs.json').read_text())
    for path,pin in inputs['files'].items():
        assert identity((REPO/path).read_bytes())==pin,path
    contexts=[]
    for case in CASES:
        actual=json.loads(json.dumps(calculate(case)))
        assert actual==json.loads((HERE/f'{case}-context.json').read_text()),case
        contexts.append(actual)
    assert driver_connection()==json.loads((HERE/'driver-connection.json').read_text())
    source=audit();assert source==json.loads((HERE/'source-witnesses.json').read_text())
    result=compose(contexts);assert result==json.loads((HERE/'result.json').read_text())
    assert all(not s['seed_storage']['nonleaf_keys'] for c in contexts for s in c['stages'].values())
    assert not result['episodes']['fresh_stage_escape_allowance']
    assert all(result['remaining'].values())
    print(json.dumps(dict(status='PASS',platform=platform.system(),machine=platform.machine(),
        elapsed_seconds=time.monotonic()-start,pinned_files=len(inputs['files']),
        original_context_keys=sum(c['original_context_keys'] for c in contexts),
        context_route_calculations=10,
        context_feature_occurrences=sum(len(s['features']) for c in contexts for s in c['stages'].values()),
        source_files=len(source['files']),source_excerpts=sum(len(f['excerpts']) for f in source['files'].values()),
        controls=controls(),native_runs=0,solver_runs=0,proof_runs=0,
        predecessor_checkers_replayed=0,source_theorem_machine_checked=False),sort_keys=True,indent=2))

if __name__=='__main__':main()
