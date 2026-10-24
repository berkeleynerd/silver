"""Reconcile R84 reviewed inputs; no component checker or native replay."""
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


def check(row, commit=None):
    data = git_bytes(commit, row['path']) if commit else (ROOT / row['path']).read_bytes()
    assert sha(data) == row['sha256'], row['path']
    if 'bytes' in row:
        assert len(data) == row['bytes'], row['path']


frozen = {}
for component in read(HERE / 'inputs.json')['components']:
    for path in component['paths']:
        data = (ROOT / path).read_bytes()
        assert data == git_bytes(component['freeze'], path), path
        frozen[path] = sha(data)

evidence = ROOT / 'docs/evidence'
helper = read(evidence / 'review-native-helper-joins-20261024/result.json')
assert helper['status'] == 'pass'
assert helper['export_matches_author_except_clock_and_elapsed']
for row in helper['frozen_author_files']:
    check(row)
for row in helper['preserved_historical_files']:
    check(row, row['commit'])
check(helper['additional_source']['archive'])
assert helper['current_repaired_general_C'] == [9, 83, 42, 12]
assert helper['current_classified_C'] == [35, 188, 150, 12]

entry = read(evidence / 'review-main-entry-capacity-20261024/result.json')
assert entry['status'] == 'pass' and entry['export_matches_author_except_elapsed']
for row in entry['frozen_author_files']:
    check(row)
identity = read(evidence / 'retained-main-entry-capacity-20261024/identity.json')
for row in identity['archives'] + identity['providers']:
    check(row)

native_time = read(evidence / 'review-reported-time-native-20261024/result.json')
assert native_time['status'] == 'pass' and native_time['issue208_repair_verified']
for path, expected in native_time['frozen_files'].items():
    check(dict(path=path, sha256=expected))
assert sha((evidence / 'review-reported-time-native-20261024/audit.py').read_bytes()) == native_time['audit_sha256']
native_identity = read(evidence / 'retained-reported-time-native-20261024/native-supplement.json')
check(dict(path=native_identity['target'], **native_identity['target_identity']))

source_inputs = read(evidence / 'retained-reported-time-capacity-20261024/inputs.json')
for path, row in source_inputs['files'].items():
    check(dict(path=path, **row))

source_review = read(evidence / 'review-reported-time-capacity-20261024/result.json')
assert source_review['status'] == 'pass'
assert source_review['reviewed_commit'] == 'fd19cd4c3c4847795b04a2a194bf49ce52eacfc5'
assert sha((evidence / 'review-reported-time-capacity-20261024/audit.py').read_bytes()) == source_review['audit_sha256']
for field in ('frozen_author_files', 'accepted_native_provider_files'):
    for path, row in source_review[field].items():
        check(dict(path=path, **row))
assert source_review['startup_minor_words_added'] == 91752681
assert source_review['maximum_minor_words'] == 227274405
assert source_review['maximum_managed_static_carrier_words'] == 237953393
assert source_review['abandoned_parse_words'] == 798
assert source_review['queued_only_words'] == 7
assert source_review['author_checker_runs'] == source_review['predecessor_checker_runs'] == 0
assert source_review['native_target_runs'] == 0
timing_packet = evidence / 'retained-reported-time-capacity-20261024'
unchanged_repair_outputs = ('entry-extension.json', 'baseline-entry-projection.json',
                            'recipe.json', 'result.json')
for name in unchanged_repair_outputs:
    path = (timing_packet / name).relative_to(ROOT).as_posix()
    assert (ROOT / path).read_bytes() == git_bytes('ae33d531d9', path), path

native_pins = read(evidence / 'retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native_pins:
    check(row)

result = dict(
    status='pass', frozen_files=frozen,
    native_helper_historical_inputs=len(helper['preserved_historical_files']),
    entry_archives=len(identity['archives']), entry_providers=len(identity['providers']),
    timing_source_inputs=len(source_inputs['files']),
    timing_review_provider_files=len(source_review['accepted_native_provider_files']),
    unchanged_repair_outputs=list(unchanged_repair_outputs),
    timing_native_target_unchanged=True,
    unchanged_native_source_pins=len(native_pins),
    issue208_repair_accepted=True, issue209_repair_accepted=True,
    issue210_repairs_accepted=True,
    issue201_complete=False, issue202_complete=False, issue119_complete=False,
    component_checker_replays=0, native_compiler_prover_lean_runs=0,
    elapsed_seconds=time.perf_counter()-START,
)
(HERE / 'integration-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}, indent=2))
