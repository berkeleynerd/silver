"""Reconcile accepted R83 evidence; no component or native replay."""
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


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git_bytes(commit, path):
    return subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT)


def check(row, commit=None):
    data = git_bytes(commit, row['path']) if commit else (ROOT / row['path']).read_bytes()
    assert digest(data) == row['sha256'], row
    if 'bytes' in row:
        assert len(data) == row['bytes'], row


frozen = {}
for component in read(HERE / 'inputs.json')['components']:
    for path in component['paths']:
        data = (ROOT / path).read_bytes()
        assert data == git_bytes(component['freeze'], path), path
        frozen[path] = digest(data)

native_packet = ROOT / 'docs/evidence/retained-general-native-capacity-20261024'
native_review = ROOT / 'docs/evidence/review-general-native-capacity-20261024'
audit = read(native_review / 'audit.json')
assert audit['status'] == 'pass'
assert audit['current_export_matches_author_except_elapsed'] is True
for row in audit['frozen_inputs']:
    check(row)
historical = read(native_packet / 'inputs.json')['inputs']
for row in historical:
    check(row, audit['reviewed_kernel_commit'])
repair_inputs = read(native_packet / 'string-pack-source-manifest.json')['historical_inputs']
for row in repair_inputs:
    check(row)
author = read(native_packet / 'string-pack-current.json')
review = read(native_review / 'repair-check-result.json')
author.pop('offline_elapsed_seconds')
review.pop('offline_elapsed_seconds')
assert author == review
assert author['current_Main_overlay_required'] is True
assert author['original_generator_and_evidence_preserved'] is True

main_packet = ROOT / 'docs/evidence/retained-main-why-storage-20261024'
main_review = ROOT / 'docs/evidence/review-main-why-storage-20261024'
main = read(main_review / 'result.json')
assert main['status'] == 'pass' and main['assertions'] == 1272
assert digest((main_review / 'audit.py').read_bytes()) == main['audit_sha256']
for path, sha in main['author_inputs_sha256'].items():
    check({'path': path, 'sha256': sha})
identity = read(main_packet / 'identity.json')
for row in identity['archives'] + identity['providers']:
    check(row)

native = read(ROOT / 'docs/evidence/retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native:
    check(row)

result = dict(
    status='pass', frozen_files=frozen,
    native_kernel_historical_inputs=len(historical),
    repaired_frontend_historical_inputs=len(repair_inputs),
    repair_export_matches_review_except_elapsed=True,
    main_archives=len(identity['archives']), main_providers=len(identity['providers']),
    unchanged_native_source_pins=len(native),
    issue207_repair_accepted=True, issue201_complete=False,
    issue202_complete=False, issue119_complete=False,
    component_checker_replays=0, native_compiler_prover_lean_runs=0,
    elapsed_seconds=time.perf_counter()-START,
)
(HERE / 'integration-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}, indent=2))
