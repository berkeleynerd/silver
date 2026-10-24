"""Identity-only integration of reviewed #193 components; no provider replay."""
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


def check_row(row, data):
    assert sha(data) == row['sha256'], row
    if 'bytes' in row:
        assert len(data) == row['bytes'], row


frozen = {}
for component in read(HERE / 'inputs.json')['components']:
    for path in component['paths']:
        data = (ROOT / path).read_bytes()
        assert data == git_bytes(component['freeze'], path), path
        frozen[path] = sha(data)

review = ROOT / 'docs/evidence/review-producer-report-capacity-20261024'
historical = 0
report_final = {}
for name, commit_key, rows_key in [
    ('integrated-final-inputs.json', 'final_author_commit', 'final_files'),
    ('projection-correction.json', 'target_author_commit', 'frozen_changed_files'),
    ('statistics-correction.json', 'target_author_commit', 'frozen_changed_files'),
]:
    record = read(review / name)
    for row in record[rows_key]:
        check_row(row, git_bytes(record[commit_key], row['path']))
        report_final[row['path']] = row
        historical += 1
for row in report_final.values():
    check_row(row, (ROOT / row['path']).read_bytes())

terminal = read(review / 'terminal-payload-final-inputs.json')
for row in terminal['final_files']:
    check_row(row, git_bytes(terminal['final_author_commit'], row['path']))
    check_row(row, (ROOT / row['path']).read_bytes())
    historical += 1
assert terminal['finding']['issue'] == 200
assert terminal['finding']['status'] == 'repaired'
assert terminal['finding']['numerical_bounds_changed'] is False
assert terminal['reviewer_checker_runs_after_repair'] == 0
assert terminal['final_193_scope']['board_readiness'].startswith('Scoped #193 can move In review.')

audit_times = {}
for stem in ('integrated', 'terminal-payload'):
    audit = read(review / f'{stem}-audit.json')
    assert audit['returncode'] == 0 and not audit['stderr']
    result_path = review / f'{stem}-check-result.json'
    assert sha(result_path.read_bytes()) == audit['result_sha256']
    expected_status = ('focused checks passed; source attachments remain open'
                       if stem == 'integrated' else 'pass')
    assert read(result_path)['status'] == expected_status
    audit_times[stem] = audit['invocation_elapsed_seconds']

dependencies = {}
for row in read(ROOT / 'docs/evidence/retained-producer-report-capacity-20261024/inputs.json'):
    check_row(row, (ROOT / row['path']).read_bytes())
    dependencies[row['path']] = row['sha256']
for name, row in read(ROOT / 'docs/evidence/retained-producer-error-payload-20261024/inputs.json').items():
    if name.startswith('git:'):
        _, commit, path = name.split(':', 2)
        data = git_bytes(commit, path)
    else:
        data = (ROOT / name).read_bytes()
    check_row(row, data)
    dependencies[name] = row['sha256']

native = read(ROOT / 'docs/evidence/retained-literal-native-completion-20261019/inputs.json')['repository']
for row in native:
    check_row(row, (ROOT / row['path']).read_bytes())

out = dict(
    status='pass', frozen_files=frozen, historical_review_pins=historical,
    reconciled_dependencies=dependencies, unchanged_native_source_pins=len(native),
    retained_review_invocation_seconds=audit_times,
    accepted_scope='Conditional per-unit result/report consumer functions and selected fixed-process terminal error attachment',
    issue193_technical_scope_accepted=True, complete_issue119=False,
    component_checker_replays=0, native_compiler_prover_runs=0,
    global_allowance_renewed=False, elapsed_seconds=time.perf_counter()-START,
)
(HERE / 'integration-result.json').write_text(json.dumps(out, indent=2)+'\n')
print(json.dumps({k: v for k, v in out.items()
                  if k not in ('frozen_files', 'reconciled_dependencies')}, indent=2))
