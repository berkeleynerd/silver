"""Reconcile exact R86 author/review inputs; do not replay component checks."""
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


def check(row, base=ROOT):
    raw = (base / row['path']).read_bytes()
    assert sha(raw) == row['sha256'], row['path']
    if 'bytes' in row:
        assert len(raw) == row['bytes'], row['path']


inputs = read(HERE / 'inputs.json')
frozen = {}
for item in inputs['components']:
    for path in item['paths']:
        raw = (ROOT / path).read_bytes()
        original = subprocess.check_output(
            ['git', 'show', f"{item['freeze']}:{path}"], cwd=ROOT)
        assert raw == original, path
        frozen[path] = sha(raw)

bound = 0
for manifest in inputs['bindings']:
    rows = read(ROOT / manifest['path'])
    for key in manifest['keys']:
        rows = rows[key]
    if manifest.get('kind') == 'map':
        rows = [dict(path=k, sha256=v) for k, v in rows.items()]
    elif manifest.get('kind') == 'single':
        rows = [rows]
    for row in rows:
        check(row, ROOT / manifest.get('base', '.'))
        bound += 1

E = ROOT / 'docs/evidence'
image = read(E / 'retained-general-native-capacity-20261024/fold-envelope/current.json')
assert image['status'] == 'pass'
assert image['H_Image_upper'] == 3 and image['Q_Image'] == '10Ia'
assert image['helper_plus_annotation']['raw_caller_bytes'] == '808Is+16336Ia'
image_review = read(E / 'review-native-image-envelope-20261024/current.json')
assert image_review['status'] == 'pass'
assert image_review['reviewed_author_commit'] == inputs['components'][0]['freeze']
assert image_review['author_checker_replays'] == 0
assert image_review['predecessor_checker_replays'] == 0
assert image_review['compiler_native_prover_runs'] == 0

callers = read(E / 'retained-main-construction-demand-20261024/clone-callers/result.json')
assert callers['status'] == 'pass' and callers['assertions'] == 674
assert callers['actual_frontier_clone_map_attachment'] is True
assert callers['complete_source_to_initial_vc_storage'] is False
assert callers['complete_native_bytes'] is False
caller_review = read(E / 'review-main-clone-callers-20261024/receipt.json')
assert caller_review['status'] == 'accepted_bounded_clone_map_and_direct_caller_attachment'
assert caller_review['material_author_findings'] == []
assert caller_review['actual_frontier_clone_map_attachment'] is True
assert caller_review['complete_native_bytes'] is False
assert caller_review['author_or_predecessor_checker_replays'] == 0
assert caller_review['native_runs'] == 0

fixed = read(E / 'retained-fixed-report-composition-20261024/result.json')
assert fixed['source_counts_bound'] is True
assert fixed['concrete_paths_and_native_services_bound'] is False
assert fixed['whole_fixed_report_composition_complete'] is False
for row in fixed['specification_processes'].values():
    assert row['interval_writer']['sufficient'] is True
    assert row['interval_reader']['all_guards'] is True
fixed_review = read(E / 'review-fixed-report-composition-20261024/result.json')
assert fixed_review['status'].startswith('PASS:')
assert fixed_review['author_checker_runs'] == 0
assert fixed_review['predecessor_checker_runs'] == 0
assert fixed_review['native_or_prover_runs'] == 0

# Exact reviewer receipts are bound above. Their acceptance and remaining scope
# are recorded in README.md; no old finite audit is invoked during integration.
native_pins = read(E / 'retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native_pins:
    check(row)

result = dict(
    status='pass', frozen_files=frozen, provider_and_review_bindings=bound,
    unchanged_native_source_pins=len(native_pins),
    Image_source_height_and_annotation_attached=True,
    actual_frontier_clone_map_and_direct_callers_attached=True,
    fixed_specification_report_source_domains_attached=True,
    complete_native_compilation_capacity=False,
    complete_Main_storage_capacity=False,
    complete_fixed_report_composition=False,
    complete_issue119=False,
    component_checker_replays=0, native_compiler_prover_Lean_runs=0,
    elapsed_seconds=time.perf_counter()-START,
)
(HERE / 'integration-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}, indent=2))
