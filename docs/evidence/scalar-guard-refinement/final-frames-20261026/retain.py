"""Retain/check existing final frame evidence only. Launches no validators."""
from collections import Counter
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = Path('/home/canto/src/github.com/berkeleynerd/silver')
CANONICAL = ROOT / 'tmp/scalar-guard-refinement'
FRAME = ROOT / 'tmp/guard-native-frames-final'
SHAPES = FRAME / 'shape-results-20261026T073915Z'
REGISTRY = ROOT / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs'
EXPECTED = '956eff6874727f95fcb1ede29b537705f96bf916d05483d1813198aeb0f1ea74'
RUN_IDS = ('20261026T073737-a27ed2ad48a6', '20261026T073838-e2c59da5cc8d',
           '20261026T073915-30f6eea23d83')
LOGICAL_DESTINATION = 'docs/evidence/scalar-guard-refinement/final-frames-20261026'
if not __debug__:
    raise RuntimeError('Retention requires assertions; do not run Python with -O')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def dump(value):
    return (json.dumps(value, indent=2, sort_keys=True) + '\n').encode()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=CANONICAL)


index = {}
retained_sources = {}


def retain(name, data, source=None):
    target = HERE / (name + '.gz')
    target.parent.mkdir(parents=True, exist_ok=True)
    packed = gzip.compress(data, mtime=0)
    target.write_bytes(packed)
    row = {'path': str(target.relative_to(HERE)), 'bytes': len(data),
           'sha256': sha(data), 'compressed_sha256': sha(packed)}
    if source is not None:
        row['source_path'] = str(source)
        retained_sources[str(Path(source))] = name
    index[name] = row


def retain_file(name, path):
    retain(name, path.read_bytes(), source=path)


started_utc = datetime.now(timezone.utc).isoformat()
assert sha((FRAME / 'src/silver_output_profile.adb').read_bytes()) == EXPECTED
snapshot = json.loads((FRAME / 'input-snapshot.json').read_text())
assert len(snapshot) == 134 and sum(name.startswith('src/') for name in snapshot) == 132
for name, expected in snapshot.items():
    assert sha((FRAME / name).read_bytes()) == expected, name
    retain_file(name, FRAME / name)
retain_file('input-snapshot.json', FRAME / 'input-snapshot.json')

# Bind the entire selected native source set to current authoritative bytes.
# Compare HEAD separately: final integration can occur after the frozen runs
# and before retention, so preserve the actual comparison without assuming dirt.
tracked = git('ls-files', 'src').decode().splitlines()
assert len(tracked) == 129 and tracked
head = git('rev-parse', 'HEAD').decode().strip()
source_rows = {}
head_differences = {}
for name in tracked:
    canonical = sha((CANONICAL / name).read_bytes())
    frozen = sha((FRAME / name).read_bytes())
    assert canonical == frozen, name
    committed = sha(git('show', head + ':' + name))
    source_rows[name] = frozen
    if committed != frozen:
        head_differences[name] = {'head_sha256': committed, 'selected_sha256': frozen}
assert set(head_differences) <= {'src/silver_output_profile.adb'}, head_differences
source_comparison = {'canonical_path': str(CANONICAL), 'head_at_capture': head,
                     'comparison': ('All129 tracked source files match canonical worktree and HEAD at retention; no source differences.'
                                    if not head_differences else
                                    'All129 tracked source files match selected canonical worktree bytes; source differences from HEAD at retention are explicit.'),
                     'matched': len(source_rows), 'mismatches': [], 'sha256': source_rows,
                     'head_source_differences': head_differences,
                     'dirty_status_at_capture': git('status', '--short', '--untracked-files=no').decode()}
retain('source-comparison.json', dump(source_comparison))
retain('source-change-from-frame-snapshot.patch', git('diff', '042998ad3a', '--', 'src'))

for path in sorted((FRAME / 'obj').glob('*.su')):
    retain_file('obj/' + path.name, path)
assert len(list((FRAME / 'obj').glob('*.su'))) == 28
for name in ('silver_output_profile.s', 'b__silver.adb'):
    retain_file('obj/' + name, FRAME / 'obj' / name)
for name in ('run-admission.py', 'run-shapes.py', 'build.log', 'admission.log',
             'shapes.log', 'admission-summary.json'):
    retain_file(name, FRAME / name)
for path in sorted(SHAPES.iterdir()):
    if path.is_file():
        retain_file('shape-results/' + path.name, path)

shapes = json.loads((SHAPES / 'summary.json').read_text())
assert shapes['run_id'] == RUN_IDS[2]
assert shapes['stack_kib'] == 8192 and len(shapes['results']) == 20
assert all(row['expected'] == row['status'] for row in shapes['results'])
assert Counter((row['bytes'], row['status']) for row in shapes['results']) == Counter({(4096, 0): 10, (4097, 2): 10})
shape_inputs = shapes['inputs_sha256']
assert len(shape_inputs) == 183 and shape_inputs
for name, expected in shape_inputs.items():
    assert sha(Path(name).read_bytes()) == expected, name
for path in sorted({Path(row['source']) for row in shapes['results']}):
    retain_file('shape-inputs/' + path.name, path)
fixtures = Path(shapes['results'][0]['source']).parent
retain_file('shape-inputs/shapes.json', fixtures / 'shapes.json')

admission = json.loads((FRAME / 'admission-summary.json').read_text())
assert (admission['tests'], admission['cases'], admission['failures'], admission['errors']) == (18, 105, 0, 0)
assert admission['source_sha256'] == EXPECTED
binary_sha = sha((FRAME / 'bin/silver').read_bytes())
assert admission['executable_sha256'] == binary_sha

# Retain every non-binary source/script/configuration input captured by the
# managed build/admission checks. Tool and executable identities stay as hashes.
runs = []
for position, run_id in enumerate(RUN_IDS):
    directory = REGISTRY / run_id
    raw = (directory / 'events.jsonl').read_bytes()
    events = [json.loads(line) for line in raw.splitlines()]
    starts = [e for e in events if e['event'] == 'started']
    finishes = [e for e in events if e['event'] == 'finished']
    assert len(starts) == len(finishes) == 1
    start, finish = starts[0], finishes[0]
    assert all(e['run_id'] == run_id for e in events)
    assert finish['outcome'] == 'success' and finish['returncode'] in (0, None)
    assert datetime.fromisoformat(start['utc']) < datetime.fromisoformat(finish['utc'])
    assert Path(start['worktree']['resolved']) == (CANONICAL if position < 2 else ROOT)
    if position < 2:
        prepared = [e for e in events if e['event'] == 'prepared']
        assert len(prepared) == 1
        capture = prepared[0]
        inputs = capture['inputs']['inputs_sha256']
        commands = [e['command'] for e in events if e['event'] == 'command']
        assert commands
    else:
        capture = start
        inputs = capture['inputs']['sha256']
        assert inputs == shape_inputs
        commands = [start['command']]
    assert inputs
    comparisons = {}
    for name, expected in inputs.items():
        path = Path(name)
        actual = sha(path.read_bytes())
        assert actual == expected, name
        if path.is_relative_to(CANONICAL / 'scripts'):
            retain_file('run-inputs/scripts/' + path.name, path)
        elif path.is_relative_to(CANONICAL / 'tests'):
            retain_file('run-inputs/tests/' + path.name, path)
        elif path == CANONICAL / '.silver/linux-x86_64/toolchain/alire.toml':
            retain_file('run-inputs/toolchain/alire.toml', path)
        comparisons[name] = {'captured_sha256': expected, 'current_sha256': actual,
                             'retained_record': retained_sources.get(name),
                             'retention': 'snapshot' if name in retained_sources else 'hash identity only; binary/tool not replicated'}
    assert len(comparisons) == (146 if position == 0 else 194 if position == 1 else 183)
    frozen_source_inputs = {name: digest for name, digest in inputs.items()
                            if Path(name).is_relative_to(FRAME / 'src')}
    assert len(frozen_source_inputs) == 132
    assert {Path(name).name: digest for name, digest in frozen_source_inputs.items()} == {
        Path(name).name: digest for name, digest in snapshot.items() if name.startswith('src/')}
    retain('runs/' + run_id + '/input-comparison.json', dump({
        'run_id': run_id, 'matched': len(comparisons), 'mismatches': [],
        'frozen_source_files_matched': 132, 'inputs': comparisons}))
    retain_file('runs/' + run_id + '/events.jsonl', directory / 'events.jsonl')
    if (directory / 'native.log').exists():
        retain_file('runs/' + run_id + '/native.log', directory / 'native.log')
    runs.append({'run_id': run_id, 'kind': start['kind'], 'worktree': start['worktree'],
                 'workers': start['workers'], 'resources': start['resources'],
                 'input_capture_event': capture['event'], 'input_capture_utc': capture['utc'],
                 'inputs_matched': len(comparisons), 'frozen_source_files_matched': 132,
                 'invocation_command': start['command'], 'effective_commands': commands,
                 'started_utc': start['utc'], 'finished_utc': finish['utc'],
                 'duration_seconds': finish['duration_seconds'],
                 'outcome': finish['outcome'], 'returncode': finish['returncode']})

comparison_path = HERE.parent / 'fresh-frame-comparison.json'
comparison = json.loads(comparison_path.read_text())
assert comparison['candidate_sha256'] == EXPECTED
assert comparison['secondary_calls']['old_allocate_sites'] == comparison['secondary_calls']['new_allocate_sites'] == 64
assert comparison['secondary_calls']['allocation_site_counts_equal_by_source_function']
assert comparison['material_lifetime_change']['new_body_tail_mark_or_release_calls'] == []
assert comparison['snapshot_mismatches'] == []
assert comparison['admission']['binary_matches_current'] and comparison['admission']['source_matches_current']
assert comparison['shapes']['input_mismatches'] == [] and comparison['shapes']['all_expected_statuses']
retain_file('fresh-frame-comparison.json', comparison_path)
retain_file('compare-fresh-frames.py', HERE.parent / 'compare-fresh-frames.py')
retain('secondary-call-sites.json', dump(comparison['secondary_calls']['new']))

packed_index = gzip.compress(dump(index), mtime=0)
(HERE / 'retention-index.json.gz').write_bytes(packed_index)
for name, row in index.items():
    packed = (HERE / row['path']).read_bytes()
    assert sha(packed) == row['compressed_sha256'], name
    unpacked = gzip.decompress(packed)
    assert len(unpacked) == row['bytes'] and sha(unpacked) == row['sha256'], name
validation = {
    'schema_version': 1, 'logical_destination': LOGICAL_DESTINATION,
    'retention_started_utc': started_utc,
    'retention_completed_utc': datetime.now(timezone.utc).isoformat(),
    'selected_model': 'GPT-6.1 Sol', 'selected_effort': 'Extra High',
    'runtime_settings': 'not independently exposed', 'token_cost_evidence': 'unavailable',
    'native_host': 'linux-x86_64', 'source_sha256': EXPECTED,
    'executable_sha256': binary_sha, 'source_files_matched': len(source_rows),
    'generated_source_files_retained': 3, 'snapshot_files_checked': len(snapshot),
    'head_at_capture': head, 'head_source_differences': head_differences,
    'shape_input_hashes_verified': len(shape_inputs),
    'stack_usage_files_retained': 28, 'parser_assembly_files_retained': 1,
    'retained_gzip_records': len(index), 'index_sha256': sha(packed_index),
    'index_uncompressed_sha256': sha(dump(index)), 'index_verified': True,
    'runs': runs, 'admission': admission,
    'shapes': {'run_id': RUN_IDS[2], 'passed': 20, 'stack_kib': 8192,
               'admitted_4096': 10, 'rejected_4097': 10},
    'frame_changes': {'Body_Tail': {'before': 416, 'after': 368},
                      'Bare_Target': {'before': 240, 'after': 256},
                      'other_nine_listed_recursive_sums': 'unchanged'},
    'lifetime_supersession': 'Final Body_Tail has no former local secondary mark/release pair; prior completed-sibling release claim does not apply to this exact build.',
    'allocation_sites': {'before': 64, 'after': 64, 'per_source_function_counts_equal': True},
    'conditional_count_applicability': 'Prior total successful-body payload count S(B)*(4N+6L+9J+4E+3) counts all allocations, including formerly released results. Source/site-count assumptions remain applicable; unchanged site inventory is not a new universal allocation proof.',
    'limits': ['Retention and read-only comparison only; no validator launched by this thread.',
               'Scratch compiler frame build, admission-only tests and recognizer boundary shapes, not application proof/build execution.',
               'No complete native compiler proof or complete Lean/source checkpoint claimed.',
               'No universal8MiB certificate, malformed-prefix total capacity, external allocator sufficiency, allocator-metadata bound or all-route primary bound.',
               'Conditional payload arithmetic still depends on successful-parse source/site counting and rounding assumptions.',
               'Original source/build/test/parser observations and prior evidence remain preserved.',
               'Executable/tool bytes not copied; their captured/current SHA identities are retained.']}
(HERE / 'validation.json').write_bytes(dump(validation))
print(json.dumps({'retained_gzip_records': len(index), 'source_matches': 129,
                  'build_inputs_matched': runs[0]['inputs_matched'],
                  'admission_inputs_matched': runs[1]['inputs_matched'],
                  'shape_inputs_matched': runs[2]['inputs_matched'],
                  'index_sha256': sha(packed_index), 'validation_sha256': sha(dump(validation)),
                  'index_verified': True}, indent=2))
