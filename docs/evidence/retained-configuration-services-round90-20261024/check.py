"""Reconcile exact R90 inputs; do not replay semantic/component audits."""
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
START = time.perf_counter()


def read(path):
    return json.loads(path.read_text())


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def git_file(commit, path):
    return subprocess.check_output(['git','show',f'{commit}:{path}'],cwd=ROOT)


inputs = read(HERE/'inputs.json')
frozen = {}
for component in inputs['components']:
    for path in component['paths']:
        raw = (ROOT/path).read_bytes()
        assert raw == git_file(component['freeze'],path), path
        frozen[path] = sha(raw)

bound = 0
for binding in inputs['bindings']:
    rows = read(ROOT/binding['path'])
    for key in binding['keys']:
        rows = rows[key]
    if binding.get('kind') == 'map':
        rows = [dict(path=key,sha256=value) for key,value in rows.items()]
    elif binding.get('kind') == 'map_records':
        rows = [dict(path=key,**value) for key,value in rows.items()]
    elif binding.get('kind') == 'single':
        rows = [rows]
    elif binding.get('kind') == 'identity':
        rows = [dict(path=rows['path'], **rows['identity'])]
    for row in rows:
        if 'commit' in binding:
            raw = git_file(binding['commit'],row['path'])
        else:
            raw = (ROOT/binding.get('base','.')/row['path']).read_bytes()
        assert sha(raw) == row['sha256'], row['path']
        if 'bytes' in row:
            assert len(raw) == row['bytes'], row['path']
        bound += 1

# Reviewer verdicts, failure dispositions and explicit incomplete interfaces
# are retained inputs, not substitutes for replaying or extending their proofs.
for check in inputs['expectations']:
    value = read(ROOT/check['path'])
    for key in check['keys']:
        value = value[key]
    assert value == check['value'], check

for item in inputs.get('prefixes',[]):
    prefix = read(ROOT/item['manifest'])
    for key in item['keys']:
        prefix = prefix[key]
    assert sha((ROOT/prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
pins = read(ROOT/'docs/evidence/retained-literal-native-completion-20261019/inputs.json')['repository']
for row in pins:
    assert sha((ROOT/row['path']).read_bytes()) == row['sha256'], row['path']

result = dict(status='pass',frozen_files=frozen,provider_review_bindings=bound,
    unchanged_native_pins=len(pins),component_checker_replays=0,
    compiler_prover_Lean_runs=0,target_binary_executions=0,libc_service_queries=0,
    complete_native_capacity=False,complete_Main_capacity=False,
    complete_fixed_reports=False,complete_issue119=False,
    elapsed_seconds=time.perf_counter()-START)
(HERE/'integration-result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='frozen_files'},indent=2))
