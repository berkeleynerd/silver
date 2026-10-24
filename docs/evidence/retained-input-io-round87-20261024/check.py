"""Reconcile R87 reviewed inputs without replaying semantic/component audits."""
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
for component in inputs['components']:
    for path in component['paths']:
        raw = (ROOT / path).read_bytes()
        expected = subprocess.check_output(
            ['git', 'show', f"{component['freeze']}:{path}"], cwd=ROOT)
        assert raw == expected, path
        frozen[path] = sha(raw)

bound = 0
for binding in inputs['bindings']:
    rows = read(ROOT / binding['path'])
    for key in binding['keys']:
        rows = rows[key]
    if binding.get('kind') == 'map':
        rows = [dict(path=k, sha256=v) for k,v in rows.items()]
    elif binding.get('kind') == 'map_records':
        rows = [dict(path=k, **v) for k,v in rows.items()]
    elif binding.get('kind') == 'single':
        rows = [rows]
    for row in rows:
        check(row, ROOT / binding.get('base', '.'))
        bound += 1

E = ROOT / 'docs/evidence'
native = read(E / 'retained-general-native-capacity-20261024/input-fold/current.json')
assert native['status'] == 'pass'
assert native['H_Input_upper'] == 6 and native['Q_Input'] == '30Ba'
assert native['selected_bounds_template_subcall_closed'] is True
assert native['complete_native_capacity_result'] is False
nreview = read(E / 'review-native-input-envelope-20261024/current.json')
assert nreview['status'] == 'pass'
assert nreview['author_checker_replays'] == nreview['predecessor_checker_replays'] == 0
assert nreview['compiler_native_prover_runs'] == 0
config = read(E / 'retained-fixed-report-native-inputs-20261024/result.json')
assert config['status'] == 'pass'
assert config['version_bytes'] == 10 and config['native_max_path'] == 4096
assert config['observed_page_size'] == 4096
assert config['complete_path_join'] is False
io = read(E / 'retained-fixed-report-composition-20261024/bodies/result.json')
assert io['source_counts_bound'] is True
assert io['whole_process_capacity_bound'] is False
assert io['whole_fixed_report_composition_complete'] is False
assert io['budget_renewed'] is False
assert io['interval']['path_bytes_upper'] == 607
assert config['native_max_path'] <= io['interval']['native_max_path_upper']
assert 0 < config['observed_page_size'] <= io['interval']['native_page_size_upper']
prefix = read(E / 'retained-fixed-report-composition-20261024/bodies/source-manifest.json')['accepted_research_prefix']
assert sha((ROOT / prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
joint = read(E / 'review-fixed-io-configuration-20261024/result.json')
assert joint['status'].startswith('PASS')
assert joint['complete_common_path'] is False
assert joint['gnat2why_owner_attachment'] is False
assert joint['author_checker_runs'] == joint['predecessor_checker_runs'] == 0
assert joint['compiler_prover_runs'] == joint['selected_target_executions'] == 0
assert joint['libc_service_queries'] == 0
assert joint['io_endpoints']['607']['failed_guards'] == []
assert joint['io_endpoints']['608']['failed_guards'] == ['unbounded_alignment_intermediates']

pins = read(E / 'retained-literal-native-completion-20261019/inputs.json')['repository']
for row in pins:
    check(row)
result = dict(status='pass', frozen_files=frozen,
              provider_and_review_bindings=bound, unchanged_native_pins=len(pins),
              component_checker_replays=0, target_binary_executions=0,
              compiler_prover_Lean_runs=0, libc_service_queries=0,
              complete_native_capacity=False, complete_fixed_reports=False,
              complete_issue119=False, elapsed_seconds=time.perf_counter()-START)
(HERE / 'integration-result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='frozen_files'},indent=2))
