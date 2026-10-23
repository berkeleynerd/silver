#!/usr/bin/env python3
"""Read-only offline probes of author freeze 4a4d15; no native execution.

Run with that freeze checked out as the input root. These probes expose review
findings; they do not establish the source induction by sampled executions.
"""
import argparse
import dataclasses
import hashlib
import json
from pathlib import Path
import platform
import sys
import tarfile
import time

p = argparse.ArgumentParser()
p.add_argument('root', type=Path)
a = p.parse_args()
started = time.monotonic()
packet = a.root / 'docs/evidence/retained-main-callers-profile-20261023'
sys.path.insert(0, str(packet))
import body, callers, source as s, typed  # noqa: E402

checks = 0
def require(test, message):
    global checks
    assert test, message
    checks += 1

def sha(data):
    return hashlib.sha256(data).hexdigest()

m = json.loads((packet / 'identity.json').read_text())
for d in m['providers']:
    require(sha((a.root / d['path']).read_bytes()) == d['sha256'], d['path'])
with tarfile.open(packet / 'sources.tar.gz') as archive:
    require(set(archive.getnames()) == {d['path'] for d in m['sources']}, 'members')
    for d in m['sources']:
        data = archive.extractfile(d['path']).read()
        require(len(data) == d['bytes'] and sha(data) == d['sha256'], d['path'])
        with tarfile.open(a.root / d['provider']) as upstream:
            require(data == upstream.extractfile(d['provider_member']).read(), 'correspondence')
    for d in m['spans']:
        lines = archive.extractfile(d['path']).read().splitlines(keepends=True)
        require(sha(b''.join(lines[d['first']-1:d['last']])) == d['sha256'], d['claim'])

def profile(declarations, statements):
    f = s.Fold()
    native, expression = f.main(declarations, statements)
    return typed.Derivation(f.signatures, f.apis).main(expression, f.loop_count)

def trees(t):
    yield t
    for child in t['args']:
        yield from trees(child)

n = profile([], [s.Statement('null') for _ in range(7)])
seqs = [t for t in trees(n['tree']) if t['op'] == 'sequence']
require(len(seqs) > 0, 'located null sequence fixture')
require(all(t['key'] == '' for t in seqs), 'original omission reproduced')
require(n['accounting']['U0_upper'] == 1, 'original sequence keys absent')

shape = s.Shape('S:type', True, s.Bound('constant','1'), s.Bound('constant','2'), 2)
lit = s.Value('literal', key='literal', shape=shape)
decls = [s.Declaration(s.Object('S','string',True,shape),lit)]
args = (s.Value('name',key='S'),lit)
raw = s.Value('string_compare',args,key='/=')
expanded = s.Value('not',(s.Value('string_compare',args,key='='),))
def conditional(v):
    return [s.Statement('if',values=(v,),bodies=((s.Statement('null'),),(s.Statement('null'),)))]
raw_p, expanded_p = profile(decls,conditional(raw)), profile(decls,conditional(expanded))
require(any(c['symbol']=='Boolean.notb' for c in raw_p['contracts']), 'original helper fallback')
require(not any(c['symbol']=='Boolean.notb' for c in expanded_p['contracts']), 'actual frontend expansion')
require(expanded_p['counts']['if'] == raw_p['counts']['if'] + 1, 'missing typed conditional')

fields = [f.name for f in dataclasses.fields(s.Value)]
require('range_symbol' in fields and 'overflow_symbol' not in fields, 'original single check index')
scalar = s.Value('+',(s.Value('integer',key='1'),s.Value('integer',key='2')),
                 range_symbol='Standard.Integer.range_check')
f = s.Fold()
native, _ = f.value(scalar)
def native_calls(n):
    return ([n.key] if n.op=='call' else []) + [k for c in n.args for k in native_calls(c)]
require(native_calls(native).count('Standard.Integer.range_check')==1, 'single retained scalar check')

inputs = {}
for path in sorted(packet.iterdir()):
    if path.is_file(): inputs[str(path.relative_to(a.root))] = sha(path.read_bytes())
result = dict(
    input_commit='4a4d15cd02c2104ee46ef89479677833194c0ce1',
    checks=checks, status='three source-review findings reproduced; not accepted',
    provider_count=len(m['providers']), source_files=len(m['sources']), spans=len(m['spans']),
    sequence=dict(retained_sequences=len(seqs), initial_keys=n['initial_key_superset']),
    string_inequality=dict(raw_counts=raw_p['counts'],expanded_counts=expanded_p['counts'],
                           raw_accounting=raw_p['accounting'],expanded_accounting=expanded_p['accounting']),
    scalar=dict(value_fields=fields, calls=native_calls(native)),
    inputs=inputs, platform=platform.platform(), elapsed_seconds=time.monotonic()-started,
    executions='offline Python only; no compiler, prover, target, Lean or predecessor-checker replay')
print(json.dumps(result,indent=2,sort_keys=True))
