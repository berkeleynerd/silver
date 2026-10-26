"""Verify retained package bytes/correspondence only; no validators launched."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
if not __debug__:
    raise RuntimeError('Package verification requires assertions; do not run Python with -O')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def unpack(name):
    return gzip.decompress((HERE / (name + '.gz')).read_bytes())


manifest = json.loads((HERE / 'PACKAGE-MANIFEST.json').read_text())
actual_files = {str(path.relative_to(HERE)) for path in HERE.rglob('*')
                if path.is_file() and path.name != 'PACKAGE-MANIFEST.json'}
assert actual_files == set(manifest['files'])
for name, expected in manifest['files'].items():
    data = (HERE / name).read_bytes()
    assert len(data) == expected['bytes'] and sha(data) == expected['sha256'], name

validation = json.loads((HERE / 'validation.json').read_text())
index_data = (HERE / 'retention-index.json.gz').read_bytes()
assert sha(index_data) == validation['index_sha256']
assert sha(gzip.decompress(index_data)) == validation['index_uncompressed_sha256']
index = json.loads(gzip.decompress(index_data))
assert len(index) == validation['retained_gzip_records'] == 304
for name, row in index.items():
    packed = (HERE / row['path']).read_bytes()
    assert sha(packed) == row['compressed_sha256'], name
    data = gzip.decompress(packed)
    assert sha(data) == row['sha256'] and len(data) == row['bytes'], name

source = json.loads(unpack('source-comparison.json'))
assert source['matched'] == 129 and len(source['sha256']) == 129
assert source['mismatches'] == []
for name, expected in source['sha256'].items():
    assert index[name]['sha256'] == expected, name
assert index['src/silver_output_profile.adb']['sha256'] == validation['source_sha256']

for run in validation['runs']:
    run_id = run['run_id']
    events = [json.loads(line) for line in unpack('runs/' + run_id + '/events.jsonl').splitlines()]
    starts = [e for e in events if e['event'] == 'started']
    finishes = [e for e in events if e['event'] == 'finished']
    assert len(starts) == len(finishes) == 1
    start, finish = starts[0], finishes[0]
    assert all(e['run_id'] == run_id for e in events)
    assert finish['outcome'] == run['outcome'] == 'success'
    assert finish['returncode'] in (None, 0)
    assert finish['utc'] == run['finished_utc'] and start['utc'] == run['started_utc']
    assert start['command'] == run['invocation_command']
    capture = next(e for e in events if e['event'] == run['input_capture_event'])
    inputs = capture['inputs'].get('inputs_sha256', capture['inputs'].get('sha256'))
    comparison = json.loads(unpack('runs/' + run_id + '/input-comparison.json'))
    assert inputs and len(inputs) == run['inputs_matched'] == comparison['matched']
    assert comparison['mismatches'] == []
    assert set(comparison['inputs']) == set(inputs)
    source_count = 0
    for name, expected in inputs.items():
        row = comparison['inputs'][name]
        assert expected == row['captured_sha256'] == row['current_sha256'], name
        if row['retained_record'] is not None:
            assert index[row['retained_record']]['sha256'] == expected, name
        if '/guard-native-frames-final/src/' in name:
            source_count += 1
            assert index['src/' + Path(name).name]['sha256'] == expected
    assert source_count == run['frozen_source_files_matched'] == 132

admission = json.loads(unpack('admission-summary.json'))
assert admission == validation['admission']
assert (admission['tests'], admission['cases'], admission['failures'], admission['errors']) == (18, 105, 0, 0)
assert admission['source_sha256'] == validation['source_sha256']
assert admission['executable_sha256'] == validation['executable_sha256']
shapes = json.loads(unpack('shape-results/summary.json'))
assert shapes['run_id'] == validation['shapes']['run_id']
assert shapes['stack_kib'] == 8192 and len(shapes['results']) == 20
assert len(shapes['inputs_sha256']) == 183
assert all(row['status'] == row['expected'] for row in shapes['results'])
comparison = json.loads(unpack('fresh-frame-comparison.json'))
assert comparison['candidate_sha256'] == validation['source_sha256']
assert comparison['secondary_calls']['old_allocate_sites'] == comparison['secondary_calls']['new_allocate_sites'] == 64
assert comparison['secondary_calls']['allocation_site_counts_equal_by_source_function']
assert comparison['material_lifetime_change']['new_body_tail_mark_or_release_calls'] == []
print(json.dumps({'package_files_verified': len(manifest['files']),
                  'gzip_payloads_verified': len(index), 'source_files_matched': 129,
                  'run_inputs_matched': [run['inputs_matched'] for run in validation['runs']],
                  'admission_cases': admission['cases'], 'shape_cases': len(shapes['results']),
                  'status': 'retention integrity/correspondence verified; no validators run'}, indent=2))
