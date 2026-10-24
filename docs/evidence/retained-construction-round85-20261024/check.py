"""Reconcile R85 exact reviewed inputs without replaying component checks."""
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


def check(row, base=ROOT):
    raw = (base / row['path']).read_bytes()
    assert sha(raw) == row['sha256'], row['path']
    if 'bytes' in row:
        assert len(raw) == row['bytes'], row['path']


frozen = {}
for item in read(HERE / 'inputs.json')['components']:
    for path in item['paths']:
        raw = (ROOT / path).read_bytes()
        original = subprocess.check_output(['git', 'show', f"{item['freeze']}:{path}"], cwd=ROOT)
        assert raw == original, path
        frozen[path] = sha(raw)

evidence = ROOT / 'docs/evidence'
main = read(evidence / 'retained-main-construction-demand-20261024/identity.json')
check(main['archive'])
for row in main['providers']:
    check(row)
main_result = read(evidence / 'retained-main-construction-demand-20261024/result.json')
assert main_result['status'] == 'pass' and main_result['assertions'] == 1110
assert main_result['complete_source_to_vc_storage'] is False
main_review = read(evidence / 'review-main-construction-demand-20261024/receipt.json')
assert main_review['status'] == 'accepted_bounded_repaired_theorem'
assert main_review['actual_clone_map_attachment'] is False
for path, expected in main_review['exact_final_inputs'].items():
    check(dict(path=path, sha256=expected))
main_audit = read(evidence / 'review-main-construction-demand-20261024/audit-result.json')
assert main_audit['status'] == 'pass' and main_audit['assertions'] == 1446
assert main_audit['author_or_predecessor_checker_replays'] == main_audit['native_runs'] == 0

native_packet = evidence / 'retained-general-native-capacity-20261024/dynamic-helpers'
native_inputs = read(native_packet / 'inputs.json')['files']
for row in native_inputs:
    check(row)
native_sources = read(native_packet / 'source-manifest.json')
for row in native_sources['archives']:
    check(row, native_packet)
native_result = read(native_packet / 'current.json')
assert native_result['status'] == 'pass'
assert native_result['scoped_annotation_transfer_closed'] is True
assert native_result['source_derived_dynamic_height_closed'] is False
assert native_result['dynamic_F_closed'] is False
native_review = read(evidence / 'review-native-dynamic-helpers-20261024/current.json')
assert native_review['status'] == 'pass'
for row in native_review['bound_inputs']:
    check(row)
assert native_review['author_checker_replays'] == native_review['predecessor_checker_replays'] == 0
assert native_review['native_compiler_prover_runs'] == 0

native_pins = read(evidence / 'retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native_pins:
    check(row)

result = dict(
    status='pass', frozen_files=frozen,
    Main_source_archives=1, Main_providers=len(main['providers']),
    native_dependencies=len(native_inputs), native_archives=len(native_sources['archives']),
    main_review_inputs=len(main_review['exact_final_inputs']),
    native_review_inputs=len(native_review['bound_inputs']),
    unchanged_native_source_pins=len(native_pins),
    issue211_repair_accepted=True,
    complete_Main_caller_storage=False, source_derived_dynamic_F_closed=False,
    complete_issue119=False, component_checker_replays=0,
    native_compiler_prover_Lean_runs=0, elapsed_seconds=time.perf_counter()-START,
)
(HERE / 'integration-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}, indent=2))
