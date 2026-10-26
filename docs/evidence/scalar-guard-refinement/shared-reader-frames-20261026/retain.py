"""Retain/check existing evidence only; never launches a validation runner."""
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
ROOT = Path('/home/canto/src/github.com/berkeleynerd/silver')
FRAME = ROOT / 'tmp/guard-frame-check'
SHAPES = FRAME / 'shape-results-20261026T033623Z'
SOURCE = '042998ad3a'
EXPECTED = '0b4c95feb685491236c4880597f557eac2283d22420e5a54f39995238de03ccb'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=REPO)


def dump(value):
    return (json.dumps(value, indent=2, sort_keys=True) + '\n').encode()


index = {}


def retain(name, data):
    target = HERE / (name + '.gz')
    target.parent.mkdir(parents=True, exist_ok=True)
    packed = gzip.compress(data, mtime=0)
    target.write_bytes(packed)
    index[name] = {'path': str(target.relative_to(HERE)), 'bytes': len(data),
                   'sha256': sha(data), 'compressed_sha256': sha(packed)}


summary = json.loads((SHAPES / 'summary.json').read_text())
assert summary['stack_kib'] == 8192
assert len(summary['results']) == 20
assert all(r['status'] == r['expected'] for r in summary['results'])
assert {r['bytes'] for r in summary['results']} == {4096, 4097}
for path, expected in summary['inputs_sha256'].items():
    assert sha(Path(path).read_bytes()) == expected, path
assert sha((FRAME / 'src/silver_output_profile.adb').read_bytes()) == EXPECTED
admission = json.loads((FRAME / 'admission-summary.json').read_text())
assert (admission['cases'], admission['tests'], admission['failures'], admission['errors']) == (105, 18, 0, 0)
assert admission['source_sha256'] == EXPECTED
assert admission['executable_sha256'] == sha((FRAME / 'bin/silver').read_bytes())

source_rows = {}
for path in git('ls-tree', '-r', '--name-only', SOURCE, 'src').decode().splitlines():
    committed = sha(git('show', SOURCE + ':' + path))
    actual = sha((FRAME / path).read_bytes())
    assert committed == actual, path
    source_rows[path] = actual
assert len(source_rows) == 129
retain('source-comparison.json', dump({'source_commit': git('rev-parse', SOURCE).decode().strip(),
       'matched': len(source_rows), 'mismatches': [], 'sha256': source_rows}))
retain('source-change-from-reviewed.patch', git('diff', '7c403a063e', SOURCE, '--', 'src'))

for path in sorted((FRAME / 'src').iterdir()):
    if path.is_file():
        retain('src/' + path.name, path.read_bytes())
for pattern in ['*.s', '*.su', 'b__silver.adb']:
    for path in sorted((FRAME / 'obj').glob(pattern)):
        retain('obj/' + path.name, path.read_bytes())
for name in ['probe.gpr', 'containers.gpr', 'run-admission.py', 'run-shapes.py',
             'build-shared-reader.log', 'admission-shared-reader.log', 'admission-summary.json',
             'shapes-shared-reader.log', 'shapes-shared-reader-retry.log',
             'shared-reader-frame-diff.json', 'primary-accounting-draft.md']:
    retain(name, (FRAME / name).read_bytes())
retain('historical-pre-helper-inputs.json', (FRAME / 'inputs.json').read_bytes())
retain('review/guard-frame-account-review.md',
       (ROOT / 'tmp/scalar-guards-model-author/tmp/guard-frame-account-review.md').read_bytes())
for path in sorted(SHAPES.iterdir()):
    if path.is_file():
        retain('shape-results/' + path.name, path.read_bytes())
for path in sorted({Path(r['source']) for r in summary['results']}):
    retain('shape-inputs/' + path.name, path.read_bytes())
manifest = Path(summary['results'][0]['source']).parent / 'shapes.json'
retain('shape-inputs/shapes.json', manifest.read_bytes())

runs = []
run_root = ROOT / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs'
for run_id in ['20261026T033412-b6260b5bebde', '20261026T033529-091e794133d5', summary['run_id']]:
    events = (run_root / run_id / 'events.jsonl').read_bytes()
    rows = [json.loads(row) for row in events.splitlines()]
    assert rows[0]['event'] == 'started' and rows[-1]['event'] == 'finished'
    assert rows[-1]['outcome'] == 'success'
    retain('runs/' + run_id + '/events.jsonl', events)
    log = run_root / run_id / 'native.log'
    if log.exists():
        retain('runs/' + run_id + '/native.log', log.read_bytes())
    runs.append({'run_id': run_id, 'command': rows[0]['command'],
                 'started_utc': rows[0]['utc'], 'finished_utc': rows[-1]['utc'],
                 'duration_seconds': rows[-1]['duration_seconds'], 'outcome': rows[-1]['outcome']})


def frames(text):
    result = {}
    for line in text.splitlines():
        fields = line.split('\t')
        if len(fields) == 3:
            name = fields[0].rsplit(':', 1)[-1]
            result.setdefault(name, []).append([int(fields[1]), fields[2]])
    return result


old = frames(gzip.decompress((HERE.parent / 'native-frames-20261026/silver_output_profile.su.gz').read_bytes()).decode())
new = frames((FRAME / 'obj/silver_output_profile.su').read_text())
changes = [[name, old.get(name), new.get(name)] for name in sorted(old.keys() | new.keys()) if old.get(name) != new.get(name)]
assert changes == json.loads((FRAME / 'shared-reader-frame-diff.json').read_text())
recursive = {'Read_Primary_Into': 336, 'Read_Relation_Into': 576, 'Read_Condition_Into': 304,
             'Read_Chain_Into': 464, 'Read_Body': 304, 'Body_Tail': 416,
             'Statement_Body': 256, 'Loop_Body': 29184, 'Conditional_Body': 416,
             'Alternative_Body': 368}
assert all(sum(row[0] for row in new[name]) == amount for name, amount in recursive.items())
scalar = frames((FRAME / 'obj/silver_scalar_expressions.su').read_text())
scalar_max = sum(sum(row[0] for row in scalar[name]) for name in ['Read_Expression', 'Read_Group', 'Read_Compound'])
assert scalar_max == 1456
call_sites = []
function = ''
for line_number, line in enumerate((FRAME / 'obj/silver_output_profile.s').read_text().splitlines(), 1):
    match = re.search(r'\s*\.type\s+([^,]+),\s*@function', line)
    if match:
        function = match[1]
    if 'call\tsystem__secondary_stack__ss_' in line:
        call_sites.append({'assembly_line': line_number, 'function': function, 'call': line.strip()})
retain('secondary-call-sites.json', dump(call_sites))

# Enumerate the conditional candidate expression, without claiming frame coverage.
best = (0, None)
for b in range(342):
    dp = [(0, (0, 0, 0))] * 2049
    for budget in range(1, 2049):
        candidates = [dp[budget - 1]]
        for cost, value, slot in [(6, 3500 + 96*b, 0), (3, 2000 + 32*b, 1), (1, 1600, 2)]:
            if budget >= cost:
                old_value, counts = dp[budget - cost]
                counts = list(counts); counts[slot] += 1
                candidates.append((old_value + value, tuple(counts)))
        dp[budget] = max(candidates)
    for loops in range(b + 1):
        declarations = b - loops
        remaining = 4096 - 12*declarations - 22*loops
        if remaining >= 0:
            extra, counts = dp[remaining // 2]
            value = 524288 + (31000 + 32*b)*loops + extra
            if value > best[0]:
                best = (value, {'D': declarations, 'L': loops, 'B': b,
                                'I': counts[0], 'C': counts[1], 'P': counts[2]})
assert best[0] == 7400560
payload = max(((8*b + 48) * (4*(4096 - 12*b) + 15) // 5, b) for b in range(342))
assert payload == (2320464, 168)
retain('accounting-checks.json', dump({'fixed_frame_sums': recursive, 'scalar_recursive_max': scalar_max,
       'conditional_primary_candidate': {'bytes': best[0], 'counts': best[1],
        'scope': 'Arithmetic only; owner coverage and nonrecursive allowance not certified.'},
       'conditional_secondary_payload': {'bytes': payload[0], 'B': payload[1],
        'scope': 'Successful-parse object payload only; conditional allocation-site/rounding assumptions, no allocator sufficiency.'}}))
packed_index = gzip.compress(dump(index), mtime=0)
(HERE / 'retention-index.json.gz').write_bytes(packed_index)
for name, record in index.items():
    packed = (HERE / record['path']).read_bytes()
    assert sha(packed) == record['compressed_sha256'], name
    unpacked = gzip.decompress(packed)
    assert sha(unpacked) == record['sha256'] and len(unpacked) == record['bytes'], name
(HERE / 'validation.json').write_bytes(dump({'source_commit': git('rev-parse', SOURCE).decode().strip(),
       'native_host': 'linux-x86_64', 'source_files_matched': 129, 'shape_input_hashes_verified': len(summary['inputs_sha256']),
       'assembly_files_retained': len(list((FRAME / 'obj').glob('*.s'))),
       'stack_usage_files_retained': len(list((FRAME / 'obj').glob('*.su'))),
       'retained_gzip_records': len(index), 'index_sha256': sha(packed_index),
       'runs': runs, 'admission': admission,
       'shapes': {'passed': 20, 'stack_kib': 8192, 'admitted_4096': 10, 'rejected_4097': 10},
       'historical_inputs_notice': 'historical-pre-helper-inputs.json predates shared helper; use source-comparison.json and shape-results/summary.json for this snapshot.',
       'limits': 'Retained build, admission and parser-shape observations; feature-local conditional frame/payload accounting. No application proof, complete source-correspondence proof, universal 8 MiB certificate, malformed-prefix capacity or external allocator proof.'}))
print(json.dumps({'retained_records': len(index), 'source_matches': 129, 'shape_input_hashes_verified': len(summary['inputs_sha256']), 'index_verified': True}))
