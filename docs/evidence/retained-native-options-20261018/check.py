#!/usr/bin/env python3
"""Reconcile retained native-option evidence without rerunning a tool."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
identity = json.loads((HERE / 'identity.json').read_text())
archive = HERE / 'artifacts.tar.gz'
assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['archive_sha256']
data = {}
with tarfile.open(archive) as tar:
    assert sorted(tar.getnames()) == sorted(r['path'] for r in identity['artifacts'])
    for row in identity['artifacts']:
        value = tar.extractfile(row['path']).read()
        assert len(value) == row['bytes'], row['path']
        assert hashlib.sha256(value).hexdigest() == row['sha256'], row['path']
        data[row['path']] = value
assert data['result.json'] == (HERE / 'result.json').read_bytes()
results = json.loads(data['result.json'])
assert len(results) == 6
for result in results:
    prefix = result['case'] + '-' + result['variant'] + '/'
    src = data[prefix + 'src/main.adb']
    assert len(src) == result['source_bytes']
    assert hashlib.sha256(src).hexdigest() == result['source_sha256']
    assert result['build_exit'] == result['run_exit'] == 0
    assert data[prefix + 'run.stdout'].decode() == result['stdout']
    assert data[prefix + 'run.stderr'] == b''
    ali = data[prefix + 'obj/main.ali']
    lines = ali.split(b'\n')
    assert len(ali) == result['ali_bytes']
    assert max(map(len, lines)) + 1 == result['longest_ali_record_including_lf']
    assert sum(line.startswith(b'X ') for line in lines) == result['xref_headers']
    assert [line.decode() for line in lines if line.startswith(b'A ')] == result['stored_switch_records']
    log = data[prefix + 'build.stdout'].decode()
    binder = [line for line in log.split('\n') if 'bin/gcc ' in line and ' b__main.adb ' in line]
    assert len(binder) == 1
    if result['variant'] == 'proposed':
        assert result['xref_headers'] == 0
        assert ' -Wno-free-nonheap-object ' in binder[0]
        assert ' -gnatx ' not in binder[0]
    else:
        assert result['xref_headers'] > 0
for case in ('null', 'literal', 'long_name'):
    a, b = [row for row in results if row['case'] == case]
    assert a['source_sha256'] == b['source_sha256']
    assert a['stdout'] == b['stdout']
events = [json.loads(line) for line in data['managed/events.jsonl'].decode().split('\n') if line]
assert events[-1]['event'] == 'finished'
assert events[-1]['outcome'] == 'success'
assert events[-1]['duration_seconds'] == identity['duration_seconds']
print('Verified 102 retained files, six successful builds/runs, ALI differences and binder switch propagation')
