#!/usr/bin/env python3
"""Verify retained intern-counter observations without launching native tools."""
from pathlib import Path
import hashlib,json,tarfile
root=Path(__file__).resolve().parent
repo=root.parents[3]
manifest=json.loads((root/'manifest.json').read_text())
archive=root/manifest['archive']
assert hashlib.sha256(archive.read_bytes()).hexdigest()==manifest['sha256']
with tarfile.open(archive) as t:
    files={m.name:t.extractfile(m).read() for m in t if m.isfile()}
assert files.keys()==manifest['members'].keys()
for name,expected in manifest['members'].items():
    assert len(files[name])==expected['size'],name
    assert hashlib.sha256(files[name]).hexdigest()==expected['sha256'],name

def j(name):return json.loads(files[name])
summary=json.loads((root/'summary.json').read_text())
inputs=j('probe/inputs.json')
for row in inputs:
    relative=Path(row['copy']).relative_to('/tmp/silver-producer-intern-counters-20261018')
    assert hashlib.sha256(files['probe/'+str(relative)]).hexdigest()==row['sha256']
    if relative.parts[0]=='library-src':
        assert files['probe/'+str(relative)]==(repo/'src'/relative.name).read_bytes()
assert b'VERIFIED_FULL_POOL_LAYOUT' in files['probe/static-layout.txt']
for row in summary['cases']:
    c=row['case'];result=j('probe/'+c+'/result.json')
    assert result['debugger_exit']==0
    assert result['producer_sha256']=='343682de485bb151e1817615acebab5b185504efdf2b082f1647cd41a14241f1'
    assert [x['phase'] for x in result['snapshots']]==['before_standard','after_standard','before_symbol_free']
    assert result['snapshots']==[row['before_standard'],row['after_standard'],row['final']]
    log=files['probe/'+c+'/probe.log'].decode()
    raw=[json.loads(x.removeprefix('INTERN_SNAPSHOT ')) for x in log.splitlines() if x.startswith('INTERN_SNAPSHOT ')]
    assert raw==result['snapshots']
    assert 'Traceback' not in log and 'UNEXPECTED_RESULT_COLLECTION' not in log
    opts=j('probe/'+c+'/options.json')
    assert opts['global_gen_mode'] is False
    assert all(x['why3_args']==['/usr/bin/false'] for x in opts['file_specific'].values())
    for snap in raw:
        assert snap['layout']['pool_record']['calls_to_find']==[56,4]
        assert snap['layout']['pool_record']['total_size']==[64,8]
        assert snap['layout']['pool_record']['size_saved']==[72,8]
        for pool in ['why','entity']:
            p=snap[pool]
            assert p['sum_symbol_lengths']==p['total_size']
            assert p['maximum_symbol_length']==len(p['maximum_symbol_latin1'].encode('latin1'))
            assert p['distinct_nonempty_symbols']<=p['calls_to_find']<(1<<31)
            assert p['maximum_symbol_length']<=p['total_size']<(1<<63)
            assert p['size_saved']<(1<<63)
    for pool in ['why','entity']:
        assert [x[pool]['calls_to_find'] for x in raw]==sorted(x[pool]['calls_to_find'] for x in raw)
    assert raw[0]['why']['calls_to_find']==790
    assert raw[1]['why']['calls_to_find']==2592
    events=[json.loads(x) for x in files['managed/'+row['run_id']+'/events.jsonl'].splitlines()]
    assert events[-1]['outcome']=='success'
    prepared=next(x for x in events if x['event']=='prepared')['inputs']['inputs_sha256']
    for path,digest in prepared.items():
        if path.startswith('/tmp/silver-producer-intern-counters-20261018/'):
            member='probe/'+str(Path(path).relative_to('/tmp/silver-producer-intern-counters-20261018'))
            assert hashlib.sha256(files[member]).hexdigest()==digest,(c,member)
assert summary['why_post_standard_delta_sum']==sum(x['final']['why']['calls_to_find']-2592 for x in summary['cases'][:5])==3495
assert summary['why_fixed_additive_allowance']==2592+3495==6087
assert summary['common_five_complete_witness_sum']==sum(x['final']['entity']['calls_to_find'] for x in summary['cases'][:5])==13398
assert len(summary['managed_runs'])==10
assert sum(x['outcome']=='success' for x in summary['managed_runs'])==9
assert sum(x['outcome']=='failure' for x in summary['managed_runs'])==1
print(json.dumps({'verified_cases':len(summary['cases']),'why_fixed_allowance':6087,'managed_runs':10,'native_tool_executions_by_checker':0}))
