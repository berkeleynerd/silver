#!/usr/bin/env python3
"""Replay the retained bundled producer GCC setup event stream; execute no compiler/prover."""
import argparse
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import struct

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--ada', type=Path, required=True)
parser.add_argument('--gnat1', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
bundle = root / 'fixed-gcc-prefix-witness'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def read_json(path):
    return json.loads(path.read_text())

for row in read_json(bundle / 'manifest.json')['files']:
    raw = (bundle / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
for row in read_json(bundle / 'raw-compressed-files.json'):
    raw = gzip.decompress((bundle / row['path']).read_bytes())
    assert len(raw) == row['raw_bytes'] and digest(raw) == row['raw_sha256'], row['path']
source_files = set()
for name in ['fixed-gcc-prefix-source-identity.json', 'fixed-root-source-identity.json']:
    identity = read_json(root / name)
    assert identity['commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    for row in identity['files']:
        path = args.gcc_root / row['path']
        if not path.exists() and row['path'].startswith('gcc/ada/'):
            path = args.ada / row['path'].removeprefix('gcc/ada/')
        raw = path.read_bytes()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
        source_files.add(row['path'])

mapping = read_json(bundle / 'executable-map.json')
binary = args.gnat1.read_bytes()
assert digest(binary) == mapping['binary_sha256']
assert binary[:6] == b'\x7fELF\x02\x01'
assert struct.unpack_from('<H', binary, 16)[0] == mapping['ELF_type'] == 2
offset = struct.unpack_from('<Q', binary, 32)[0]
size, count = struct.unpack_from('<HH', binary, 54)
segments = []
for i in range(count):
    kind, flags, pos, address, physical, file_size, mem_size, align = struct.unpack_from(
        '<IIQQQQQQ', binary, offset + i * size)
    if kind == 1:
        segments.append({'offset': pos, 'address': address,
                         'file_bytes': file_size, 'memory_bytes': mem_size})
assert segments == mapping['load_segments']

def executable_bytes(address, length):
    for segment in segments:
        if segment['address'] <= address and address + length <= segment['address'] + segment['file_bytes']:
            pos = segment['offset'] + address - segment['address']
            return binary[pos:pos + length]
    raise AssertionError(hex(address))

allowed_pcs = {}
for row in mapping['sites']:
    raw = bytes.fromhex(row['instruction_bytes'])
    address = int(row['address'], 16)
    assert executable_bytes(address, len(raw)) == raw
    assert int(row['post_instruction_pc'], 16) == address + len(raw)
    allowed_pcs.setdefault(row['counter'], set()).add(row['post_instruction_pc'])

identity = read_json(bundle / 'capture-identity.json')
summary = read_json(bundle / 'counter-summary.json')
raw = gzip.decompress((bundle / 'counter-events.jsonl.gz').read_bytes())
assert len(raw) == identity['raw_event_bytes'] and digest(raw) == identity['raw_event_sha256']
events = [json.loads(line) for line in raw.split(b'\n') if line]
assert len(events) == identity['raw_event_records'] == 47707
assert summary['completed'] and not summary['failures']
assert not summary['unexpected_collections'] and not summary['new_threads']
state = {}
for name, spec in summary['specs'].items():
    initial = spec['initial']
    state[name] = {'initial': initial, 'current': initial, 'peak': initial,
                   'minimum': initial, 'events': 0, 'positive_sum': 0,
                   'negative_sum': 0, 'positive_events': 0, 'negative_events': 0,
                   'largest_increment': 0}
phases = summary['phases']
assert [p['phase'] for p in phases] == ['frontend_exec_before_initialization',
    'gigi_entry', 'builtins_entry', 'builtins_return', 'before_main_translation']
assert [p['pc'] for p in phases[1:]] == ['0x9a84e0', '0x97c670', '0x9a905e', '0x9a93d9']
assert all(p['threads'] == 1 for p in phases)
phase_index = 0
histogram = Counter()
sites = Counter()

def verify_phase(index):
    phase = phases[index]
    assert phase['values'] == {name: data['current'] for name, data in state.items()}
    assert phase['events'] == {name: data['events'] for name, data in state.items()}

verify_phase(phase_index)
phase_index += 1
for index, event in enumerate(events, 1):
    name = event['counter']
    data = state[name]
    new, old, delta = event['new'], event['old'], event['delta']
    assert old == data['current'] and delta == new - old
    assert event['pc'] in allowed_pcs[name], event
    if name == 'ggc_bytes':
        assert delta > 0 and 0 <= new < 2 ** 64
        histogram[delta] += 1
    elif name == 'decl_uid':
        assert delta == 1 and 0 <= new < 2 ** 31
    elif name == 'type_uid':
        assert delta in (1, -1) and 1 <= new < 2 ** 32
    else:
        assert name == 'debug_decl_uid' and delta == -1 and -(2 ** 31) <= new < 0
    sites[name, event['pc']] += 1
    data['current'] = new
    data['events'] += 1
    data['peak'] = max(data['peak'], new)
    data['minimum'] = min(data['minimum'], new)
    data['positive_sum'] += max(delta, 0)
    data['negative_sum'] += max(-delta, 0)
    data['positive_events'] += int(delta > 0)
    data['negative_events'] += int(delta < 0)
    data['largest_increment'] = max(data['largest_increment'], delta)
    if phase_index < len(phases) and index == sum(phases[phase_index]['events'].values()):
        verify_phase(phase_index)
        phase_index += 1
assert phase_index == len(phases)
assert state == summary['counters']
assert state['ggc_bytes']['positive_sum'] == 3318768
assert state['ggc_bytes']['positive_events'] == 39257
assert state['decl_uid']['positive_events'] == 5832
assert state['type_uid']['positive_events'] == 2277
assert state['type_uid']['negative_events'] == 341
assert state['type_uid']['peak'] == 1938
assert state['debug_decl_uid']['events'] == 0
assert gzip.decompress((bundle / 'watchpoints.txt.gz').read_bytes()).decode().count('hw watchpoint') == 4

plan = read_json(bundle / 'invocation.json')
frontend = read_json(bundle / 'frontend-exec.json')
initial = plan['environment']
actual = frontend['environment']
assert len(initial) == 7 and len(actual) == 10
assert all(actual[k] == v for k, v in initial.items())
assert set(actual) - set(initial) == {'GCC_EXEC_PREFIX', 'COLLECT_GCC', 'COLLECT_GCC_OPTIONS'}
assert actual['COLLECT_GCC'] == plan['argv'][0]
assert actual['GCC_EXEC_PREFIX'] == str(Path(plan['argv'][0]).resolve().parent) + '/../lib/gcc/'
assert 'LD_LIBRARY_PATH' not in actual
assert frontend['executable'] == plan['gnat1']
assert len(frontend['argv']) == 23
expected_options = [plan['argv'][1], *plan['argv'][4:16], *plan['argv'][17:], '-mtune=generic', '-march=x86-64']
assert actual['COLLECT_GCC_OPTIONS'] == ' '.join("'" + value + "'" for value in expected_options)
assert read_json(bundle / 'dumpspecs.json')['returncode'] == 0
assert read_json(bundle / 'result.json')['returncode'] == 0
assert not read_json(bundle / 'result.json')['timed_out']
assert identity['intentional_driver_killed_message'] in (bundle / 'probe.log').read_text()
result = {
    'scope': identity['scope'], 'managed_run_id': identity['managed_run_id'],
    'source_files_verified': len(source_files), 'gnat1_sha256': digest(binary),
    'event_records_replayed': len(events), 'hardware_write_watchpoints': 4,
    'source_operation_site_counts': [{'counter': k[0], 'pc': k[1], 'events': v}
                                    for k, v in sorted(sites.items())],
    'rounded_GGC_allocation_histogram': [{'bytes': k, 'events': v}
                                       for k, v in sorted(histogram.items())],
    'counters': state, 'phase_snapshots_verified': len(phases),
    'frontend_environment_entries': len(actual),
    'counter_wrap_or_reset': False, 'collection_or_new_thread_observed': False,
    'executed_compiler_or_prover_during_replay': False,
    'universal_sample_only_claim': False, 'whole_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'events_replayed': len(events), 'source_files_verified': len(source_files),
                  'GGC_events': 39257, 'type_increments': 2277, 'type_rollbacks': 341}))
