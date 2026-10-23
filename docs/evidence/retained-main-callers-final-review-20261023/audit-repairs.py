#!/usr/bin/env python3
"""Independent changed-seam checks; reuse unchanged original source evidence."""
import argparse
from collections import Counter
from dataclasses import replace
import gzip
import hashlib
import itertools
import json
from pathlib import Path
import platform
import subprocess
import sys
import tarfile
import time

p=argparse.ArgumentParser();p.add_argument('root',type=Path);a=p.parse_args()
started=time.monotonic()
rel='docs/evidence/retained-main-callers-profile-20261023/'
packet=a.root/rel
sys.path.insert(0,str(packet))
import body, callers, source as s, typed  # noqa: E402
count=0
def check(test,msg):
    global count
    assert test,msg
    count+=1
def sha(data):return hashlib.sha256(data).hexdigest()
def old(path):
    return subprocess.check_output(['git','show','4a4d15cd02c2104ee46ef89479677833194c0ce1:'+path],cwd=a.root)
def walk(t):
    yield t
    for x in t['args']:yield from walk(x)
def native(n):
    return (n.op,n.ty,n.key,n.domain,n.symbol_identifier,tuple(native(x) for x in n.args))
def calls(n):
    return ([n.key] if n.op=='call' else [])+[v for child in n.args for v in calls(child)]

original=json.loads(old(rel+'identity.json'))
current=json.loads((packet/'identity.json').read_text())
check(original['providers']==current['providers'],'accepted providers unchanged')
check(original['sources']==current['sources'],'complete source inventory unchanged')
check(sha(old(rel+'sources.tar.gz'))==sha((packet/'sources.tar.gz').read_bytes()),'source archive unchanged')
check(original['spans']==current['spans'][:len(original['spans'])],'original spans unchanged')
new_spans=current['spans'][len(original['spans']):]
check(len(new_spans)==6,'six reviewed source additions')
with tarfile.open(packet/'sources.tar.gz') as archive:
    for span in new_spans:
        lines=archive.extractfile(span['path']).read().splitlines(keepends=True)
        check(sha(b''.join(lines[span['first']-1:span['last']]))==span['sha256'],span['claim'])

scalar_records=[]
for overflow,target,domain in itertools.product((False,True),(False,True),('prog','term')):
    f=s.Fold();f.register(s.Object('N','int',True))
    expression=s.Value('+',(s.Value('name',key='N'),s.Value('integer',key='1')),
        overflow_symbol='Base.range_check' if overflow else None,
        expected_range_symbol='Narrow.range_check' if target else None)
    n,_=f.value(expression,domain)
    seen=calls(n)
    check(seen.count('Int.+')==1,'operator child retained once')
    check(seen.count('Base.range_check')==int(overflow and domain=='prog'),'overflow guard')
    check(seen.count('Narrow.range_check')==int(target and domain=='prog'),'expected check guard')
    if overflow and target and domain=='prog':
        check(n.key=='Narrow.range_check' and n.args[0].key=='Base.range_check','target outside overflow')
    scalar_records.append(dict(overflow=overflow,target=target,domain=domain,calls=seen))
f=s.Fold();f.register(s.Object('N','int',True))
symbol='Common.range_check'
expression=s.Value('neg',(s.Value('name',key='N'),),overflow_symbol=symbol,expected_range_symbol=symbol)
n,_=f.value(expression)
dr=typed.Derivation(f.signatures,f.apis);dr.walk(body.project(n,f.signatures))
contracts=[c for c in dr.contract_uses if c['symbol']==symbol]
check(len(contracts)==2 and len({c['site'] for c in contracts})==2,'same symbol, two contracts')
check(len({tuple(c['actuals']) for c in contracts})==2,'same symbol, two actual-definition slots')

inequality=[]
for domain in ('prog','term','pred'):
    outputs=[]
    for expanded in (False,True):
        f=s.Fold()
        for key in ('A','B'):
            shape=s.Shape(key+':type',True,s.Bound('constant','1'),s.Bound('constant','2'),2)
            f.register(s.Object(key,'string',True,shape))
        value=s.Value('string_compare',(s.Value('name',key='A'),s.Value('name',key='B')),key='/=')
        if expanded:value=s.Value('not',(replace(value,key='='),))
        n,_=f.value(value,domain);outputs.append(native(n))
    check(outputs[0]==outputs[1],'raw inequality equals frontend expansion in '+domain)
    if domain=='prog':
        p=typed.lower_booleans(body.project(n,f.signatures))
        check(p.op=='if' and [x.key for x in p.args[1:]]==['bool.False','bool.True'],'typed negation branches')
        check('Boolean.notb' not in calls(n),'no direct fallback in program')
    inequality.append(dict(domain=domain,native=calls(n)))

# Reading the retained output does not regenerate the successful 60 diagrams.
# Verify the changed key correspondence in all of them, not just the null probe.
saved=json.loads(gzip.decompress((packet/'profiles.json.gz').read_bytes()))
sequences=bindings=0
for label,d in saved['diagrams'].items():
    profile=d['profile'];nodes=list(walk(profile['tree']));keys=set(profile['initial_key_superset'])
    cs=Counter(t['op'] for t in nodes)
    seq=[t for t in nodes if t['op']=='sequence'];sequences+=len(seq)
    bind=[t for t in nodes if t['op']=='binding'];bindings+=len(bind)
    check(len({t['key'] for t in seq})==len(seq),label+' sequence scopes distinct')
    for t in seq:
        check(t['key'] in keys,label+' anonymous key in U0')
        check(t['args'][0]['type']=='unit',label+' sequence definition Unit')
        check(t['lowering']==dict(constructor='LDvar',type='unit',definition=t['args'][0]['site'],
            context=t['args'][1]['site']),label+' sequence correspondence')
    for t in bind:check(t['key'] in keys,label+' explicit binder in U0')
    check(profile['counts'].get('program_binding_slots',0)==len(seq)+len(bind),label+' all B')
    check(profile['counts'].get('sequence_binding_slots',0)==len(seq),label+' sequence B subset')
    ac=profile['accounting'];check(ac['U0_upper']==len(keys),label+' U0 actual union')
    check(ac['nv_upper']==cs['if'],label+' condition family')
    check(ac['tr_upper']==cs['application']+cs['unit-cfun']+cs['any'],label+' trace family')
    check(ac['nf_upper']==1+cs['unit-cfun'],label+' function family')
    check(ac['U_upper']==len(keys)+cs['if']+cs['application']+2*cs['unit-cfun']+cs['any']+1+ac['nh'],label+' U sum')
check(len(saved['diagrams'])==60,'complete amended diagram set')
check(len(saved['seams']['review_repairs'])==12,'targeted repair diagrams')

# Independently construct repeated sequences, including a non-Unit result.
f=s.Fold();b=f.b
unit=b.node('unit','unit');inner=b.node('sequence','int',unit,callers.constant(b,5),domain='prog')
outer=b.node('sequence','int',unit,inner,domain='prog')
dr=typed.Derivation(f.signatures,f.apis);tree,*_=dr.walk(body.project(outer,f.signatures))
seq=[t for t in walk(tree) if t['op']=='sequence']
check(len(seq)==2 and len({t['key'] for t in seq})==2,'fresh nested anonymous results')
check(all(t['key'] in dr.keys for t in seq),'nested sequence initial keys')

inputs={str(x.relative_to(a.root)):sha(x.read_bytes()) for x in sorted(packet.iterdir()) if x.is_file()}
print(json.dumps(dict(status='pass',code_diagram_commit='ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c',
    receipt_commit='7ab729be0bfaf393f462f070d9a09af614c87567',checks=count,
    retained_main_diagrams=60,retained_repair_diagrams=12,retained_sequence_occurrences=sequences,
    retained_explicit_bindings=bindings,new_source_spans=6,scalar=scalar_records,inequality=inequality,
    inputs=inputs,platform=platform.platform(),elapsed_seconds=time.monotonic()-started,
    executions='offline Python and Git reads; unchanged source/provider checks and all successful predecessor/native runs reused'),
    indent=2,sort_keys=True))
