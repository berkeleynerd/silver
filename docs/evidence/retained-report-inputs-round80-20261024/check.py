"""Reconcile reviewed #193 inputs without replaying component checks."""
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


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git_bytes(commit, path):
    return subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT)


frozen = {}
for component in read(HERE / 'inputs.json')['components']:
    for path in component['paths']:
        data = (ROOT / path).read_bytes()
        assert data == git_bytes(component['freeze'], path), path
        frozen[path] = sha(data)

review = ROOT / 'docs/evidence/review-producer-report-capacity-20261024'
audit = read(review / 'provenance-audit.json')
assert audit['freeze'] == '20c8f6b75a5761f87309afb3805c2167bf504a3b'
assert audit['returncode'] == 0 and not audit['stderr']
for row in audit['files']:
    assert sha((ROOT / row['path']).read_bytes()) == row['sha256'], row['path']
result = json.loads(audit['stdout'])
assert result['status'] == 'pass' and result['payload_templates'] == 435
assert result['partial_key_seams'] == 6 and result['max_token_suffix_losses'] == 3
assert result['complete_response_provenance'] is False

# Earlier snapshots remain review evidence even where the reviewed option
# correction subsequently changed the incoming note.
historical_review_pins = 0
for commit in read(review / 'incoming-gcc-inputs.json')['commits']:
    for row in commit['files']:
        assert sha(git_bytes(commit['commit'], row['path'])) == row['sha256']
        historical_review_pins += 1

dependencies = {}
for path, key in [
    ('docs/evidence/retained-producer-report-incoming-20261024/identity.json', 'local_sources'),
    ('docs/evidence/retained-producer-frontend-diagnostics-20261024/identity.json', 'prior_artifacts'),
]:
    for name, expected in read(ROOT / path)[key].items():
        actual = sha((ROOT / name).read_bytes())
        assert actual == expected, name
        dependencies[name] = actual

native = read(ROOT / 'docs/evidence/retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native:
    data = (ROOT / row['path']).read_bytes()
    assert sha(data) == row['sha256'], row['path']
    if 'bytes' in row:
        assert len(data) == row['bytes'], row['path']

out = dict(
    status='pass', frozen_files=frozen,
    historical_review_pins=historical_review_pins,
    reconciled_dependencies=dependencies,
    unchanged_native_source_pins=len(native),
    accepted=['incoming report state', 'fixed frontend diagnostic carry',
              'conditional interrupted response identifier provenance'],
    complete_issue193=False, complete_issue119=False,
    component_checker_replays=0, native_compiler_prover_runs=0,
    global_allowance_renewed=False,
    elapsed_seconds=time.perf_counter()-START,
)
(HERE / 'integration-result.json').write_text(json.dumps(out, indent=2)+'\n')
print(json.dumps({key: value for key, value in out.items()
                  if key not in ('frozen_files', 'reconciled_dependencies')}, indent=2))
