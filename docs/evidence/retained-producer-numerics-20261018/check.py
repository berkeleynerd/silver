#!/usr/bin/env python3
"""Decode retained numeric bytes and reconcile evidence; starts no native tool."""
from pathlib import Path
import hashlib,json,struct,tarfile
root=Path(__file__).resolve().parent
repo=root.parents[2]
manifest=json.loads((root/'manifest.json').read_text())
archive=root/manifest['archive']
assert hashlib.sha256(archive.read_bytes()).hexdigest()==manifest['sha256']
with tarfile.open(archive) as t:
    files={m.name:t.extractfile(m).read() for m in t if m.isfile()}
assert files.keys()==manifest['members'].keys()
for name,want in manifest['members'].items():
    assert len(files[name])==want['size'],name
    assert hashlib.sha256(files[name]).hexdigest()==want['sha256'],name

def j(name):return json.loads(files[name])
summary=json.loads((root/'summary.json').read_text())
scratch=Path('/tmp/silver-producer-numeric-fields-20261018')
for row in j('probe/inputs.json'):
    rel=Path(row['copy']).relative_to(scratch)
    assert hashlib.sha256(files['probe/'+str(rel)]).hexdigest()==row['sha256']
    if rel.parts[0]=='library-src':
        assert files['probe/'+str(rel)]==(repo/'src'/rel.name).read_bytes()
assert b'WHY_NUMERIC_LAYOUT ' in files['probe/static-layout.txt']
assert b'VERIFIED_NUMERIC_LAYOUT ' in files['probe/verify-layout.txt']
phases=['before_standard','after_standard','before_symbol_free']
max_width=max_digits=fields_total=0
witness_found=False
for row in summary['cases']:
    c=row['case'];result=j('probe/'+c+'/result.json')
    assert result['debugger_exit']==result['false_backend_calls']==0
    assert result['producer_sha256']==summary['producer_sha256']=='343682de485bb151e1817615acebab5b185504efdf2b082f1647cd41a14241f1'
    assert result['snapshots']==row['snapshots']
    assert [x['phase'] for x in result['snapshots']]==phases
    log=files['probe/'+c+'/probe.log'].decode()
    assert 'Traceback' not in log and 'UNEXPECTED_RESULT_COLLECTION' not in log
    assert [json.loads(x.removeprefix('NUMERIC_SNAPSHOT ')) for x in log.splitlines() if x.startswith('NUMERIC_SNAPSHOT ')]==result['snapshots']
    opts=j('probe/'+c+'/options.json')
    assert opts['global_gen_mode'] is False
    assert all(x['why3_args']==['/usr/bin/false'] for x in opts['file_specific'].values())
    for phase,brief in zip(phases,result['snapshots']):
        s=j('probe/'+c+'/numeric-'+phase+'.json')
        assert s['phase']==phase
        values={};digit_lengths=[]
        for code,x in s['uints'].items():
            code=int(code);assert code==x['code']
            if x['representation']=='direct':
                assert -2099999999<=code<=-1026290943
                value=code-(-2100000000+32768)
            else:
                assert s['tables']['uintp__uints']['first']<=code<=s['tables']['uintp__uints']['last']
                n,loc=struct.unpack('<ii',bytes.fromhex(x['entry_hex']))
                assert n==x['length'] and loc==x['loc']
                ds=struct.unpack('<'+'i'*n,bytes.fromhex(x['digits_hex']))
                assert list(ds)==x['digits']
                assert 0<abs(ds[0])<32768 and all(0<=d<32768 for d in ds[1:])
                assert 0<=loc<=loc+n-1<=s['tables']['uintp__udigits']['last']
                unsigned=sum(abs(v)*32768**(n-i-1) for i,v in enumerate(ds))
                value=unsigned if ds[0]>0 else -unsigned
                digit_lengths.append(n)
            assert str(value)==x['value']
            assert len(str(value))==x['decimal_image_length']
            values[code]=value
            witness_found |= str(value)==summary['maximum_value_witness']
        for code,x in s['ureals'].items():
            assert int(code)==x['code']
            num,den,base,negative=struct.unpack('<iiiB3x',bytes.fromhex(x['entry_hex']))
            assert (num,den,base,negative)==(x['num'],x['den'],x['rbase'],x['negative'])
            assert values[num]>=0 and values[den]!=0 and base>=0 and negative in (0,1)
            # Den is an exponent when base is nonzero; no rational expansion.
            if base==0:assert values[den]>0
        referenced_uints=set();referenced_ureals=set()
        for f in s['numeric_fields']:
            assert 0<f['node']<=s['nodes']
            kind=next(k for k,v in s['layout']['kinds'].items() if v==f['kind'])
            assert any(name==f['field'] and typ==f['type'] for name,offset,typ in s['layout']['numeric_fields'][kind])
            if f['type']=='uintp__uint':
                assert f['code'] in values;referenced_uints.add(f['code'])
            else:
                assert f['type']=='urealp__ureal'
                ur=s['ureals'][str(f['code'])];referenced_ureals.add(f['code'])
                referenced_uints.update((ur['num'],ur['den']))
        assert referenced_uints==set(values)
        assert referenced_ureals==set(map(int,s['ureals']))
        width=max((len(str(v)) for v in values.values()),default=0)
        digits=max(digit_lengths,default=0)
        assert width==s['maximum_decimal_image_length']==brief['maximum_decimal_image_length']
        assert digits==s['maximum_digit_length']==brief['maximum_digit_length']
        assert brief['numeric_fields']==len(s['numeric_fields'])
        assert brief['uints']==len(values) and brief['ureals']==len(s['ureals'])
        assert width==(0 if phase=='before_standard' else 40)
        max_width=max(max_width,width);max_digits=max(max_digits,digits)
        fields_total+=len(s['numeric_fields'])
    events=[json.loads(x) for x in files['managed/'+row['run_id']+'/events.jsonl'].splitlines()]
    assert events[-1]['outcome']=='success'
    prepared=next(x for x in events if x['event']=='prepared')['inputs']['inputs_sha256']
    for path,digest in prepared.items():
        if path.startswith(str(scratch)+'/'):
            member='probe/'+str(Path(path).relative_to(scratch))
            assert hashlib.sha256(files[member]).hexdigest()==digest,(c,member)
assert len(summary['cases'])==summary['native_subprocesses']==6
assert max_width==summary['maximum_decimal_image_length']==40
assert max_digits==summary['maximum_indirect_digit_length']==9
assert witness_found and summary['backend_calls']==summary['proof_runs']==0
print(json.dumps({'verified_cases':6,'verified_snapshots':18,'numeric_field_observations':fields_total,'fixed_decimal_image_bound':40,'maximum_indirect_digits':9,'native_tool_executions_by_checker':0}))
