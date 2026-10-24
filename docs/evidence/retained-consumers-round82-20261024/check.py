"""Reconcile #194 accepted inputs; do not replay the component audit."""
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
START = time.perf_counter()


def read(p):
    return json.loads(p.read_text())


def sha(data):
    return hashlib.sha256(data).hexdigest()


def check(row, path=None):
    data = (ROOT / (path or row['path'])).read_bytes()
    assert sha(data) == row['sha256'], row
    if 'bytes' in row:
        assert len(data) == row['bytes'], row


frozen = {}
for component in read(HERE / 'inputs.json')['components']:
    for path in component['paths']:
        data = (ROOT / path).read_bytes()
        expected = subprocess.check_output(['git', 'show', f"{component['freeze']}:{path}"], cwd=ROOT)
        assert data == expected, path
        frozen[path] = sha(data)
review = ROOT / 'docs/evidence/review-required-report-consumers-20261024'
audit = read(review / 'audit.json')
assert audit['returncode'] == 0 and not audit['stderr']
assert audit['matches_author_result_except_elapsed'] is True
assert sha((review / 'check-result.json').read_bytes()) == audit['result_sha256']
for row in audit['frozen_files']:
    check(row)
for row in audit['pinned_inputs']['files']:
    check(row)
packet = ROOT / 'docs/evidence/retained-required-report-consumers-20261024'
original, rerun = read(packet / 'result.json'), read(review / 'check-result.json')
original.pop('elapsed_seconds')
rerun.pop('elapsed_seconds')
assert original == rerun
repositories = [row for row in read(packet / 'source-manifest.json')['files'] if 'repository_path' in row]
for row in repositories:
    check(row, row['repository_path'])
native = read(ROOT / 'docs/evidence/retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native:
    check(row)
disposition = read(review / 'review.json')
assert disposition['final_author_commit'] == audit['frozen_author_commit']
assert {r['issue'] for r in disposition['findings']} == {203, 204, 205}
assert all(r['status'] == 'repaired' for r in disposition['findings'])
result = dict(status='pass', frozen_files=frozen,
              provider_inputs=len(audit['pinned_inputs']['files']),
              current_silver_snapshots=len(repositories),
              unchanged_native_source_pins=len(native),
              author_review_results_equal_except_elapsed=True,
              issue194_conditional_scope_accepted=True, complete_issue119=False,
              component_checker_replays=0, native_compiler_prover_runs=0,
              elapsed_seconds=time.perf_counter()-START)
(HERE / 'integration-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}, indent=2))
