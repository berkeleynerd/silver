#!/usr/bin/env python3
"""Reconcile fixed RTL setup source/layout inputs; execute no native tool."""
import argparse
from collections import Counter
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', required=True, type=Path)
parser.add_argument('--gnat1', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'rtl-setup-source-identity.json').read_text())
digest = lambda raw: hashlib.sha256(raw).hexdigest()
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
archive = identity['headers_archive']
raw = (root / archive['path']).read_bytes()
assert len(raw) == archive['bytes'] and digest(raw) == archive['sha256']
headers = {}
with tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz') as bundle:
    for row in identity['selected_headers']:
        raw = bundle.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
        headers[row['path']] = raw.decode()
assert not any(re.search(r'^\s*#\s*define\s+INIT_EXPANDERS\b', h, re.M)
               for h in headers.values())
assert '#define OVERRIDE_ABI_FORMAT(FNDECL) ix86_call_abi_override (FNDECL)' in headers['config/i386/i386.h']
for name in re.findall(r'# include "([^"]+)"', headers['tm.h']):
    assert name in headers

binary = args.gnat1.read_bytes()
assert digest(binary) == identity['binary']['sha256']
assert binary[:6] == b'\x7fELF\x02\x01'
offset = struct.unpack_from('<Q', binary, 32)[0]
entry_size, count = struct.unpack_from('<HH', binary, 54)
segments = [struct.unpack_from('<IIQQQQQQ', binary, offset + i * entry_size)
            for i in range(count)]

def at(address, length):
    for kind, flags, pos, start, physical, size, memory, alignment in segments:
        if kind == 1 and start <= address and address + length <= start + size:
            return binary[pos + address - start:pos + address - start + length]
    raise AssertionError(hex(address))

for row in identity['allocation_immediates']:
    raw = bytes.fromhex(row['hex'])
    assert at(int(row['address'], 16), len(raw)) == raw
    assert raw[0] == 0xbf and int.from_bytes(raw[1:], 'little') == row['request']
dis = identity['disassembly']
raw = gzip.decompress((root / dis['path']).read_bytes())
assert len(raw) == dis['raw_bytes'] and digest(raw) == dis['raw_sha256']
# Check every retained instruction fragment, including continuation lines,
# against the installed ELF, independently of its rendered symbol labels.
instruction_fragments = 0
for address, encoded in re.findall(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)', raw.decode(), re.M):
    code = bytes.fromhex(encoded)
    assert at(int(address, 16), len(code)) == code
    instruction_fragments += 1

modes = re.findall(r'^  (E_\w+mode),', headers['insn-modes.h'], re.M)
assert len(modes) == len(set(modes)) == 124
def mode_class(name):
    low, high = [re.search(r'\b' + side + '_MODE_' + name + r' = (E_\w+mode)',
                           headers['insn-modes.h'])[1] for side in ['MIN', 'MAX']]
    return modes[modes.index(low):modes.index(high) + 1]
integers = mode_class('INT')
assert integers == ['E_QImode', 'E_HImode', 'E_SImode', 'E_DImode',
                    'E_TImode', 'E_OImode', 'E_XImode']
hard_registers = int(re.search(r'#define FIRST_PSEUDO_REG (\d+)', headers['insn-constants.h'])[1])
regclasses = re.search(r'enum reg_class\s*\{(.*?)LIM_REG_CLASSES', headers['config/i386/i386.h'], re.S)[1]
regclasses = re.sub(r'/\*.*?\*/', '', regclasses, flags=re.S)
classes = [s.strip() for s in regclasses.split(',') if s.strip()]
operands = int(re.search(r'#define MAX_RECOG_OPERANDS (\d+)', headers['insn-config.h'])[1])
insn_codes = int(re.search(r'NUM_INSN_CODES = (\d+)', headers['insn-codes.h'])[1])
assert (hard_registers, len(classes), operands, insn_codes) == (92, 34, 30, 15169)

# A source-shape check keeps the claimed context exclusion next to its source
# pin. It supplements the prose call/path argument, not a general C++ proof.
fn = sources['gcc/function.cc']
assert 'if (!in_dummy_function)\n    {' in fn
assert 'pop_cfun ();\n  in_dummy_function = false;' in fn
assert 'push_dummy_function (false);\n  prepare_function_start ();' in fn
assert 'return fndecl ? ix86_function_type_abi (TREE_TYPE (fndecl)) : ix86_abi;' in sources['gcc/config/i386/i386.cc']
assert 'ira_init_once ();' in sources['gcc/toplev.cc']
assert 'if (!ira_use_lra_p)\n    init_reload ();' in sources['gcc/toplev.cc']
assert 'gen_rtx_SET (op0, op1)' in sources['gcc/config/i386/i386-expand.cc']
assert 'long long scratch[32];' in sources['gcc/sort.cc']
assert 'size_t bufsz = (n / 2) * size;' in sources['gcc/sort.cc']

powers = {2 ** k for k in range(7, 64)}
shifts = set(range(65, 128))
wide_shifts = {8, 16, 32, 64, 128, 256}
cold_values = powers | shifts | {v for v in wide_shifts if v > 64}
assert len(cold_values) == 120
rows = {row['object']: row['request'] for row in identity['allocation_immediates']}
rows.update({'exception_vector_pre_rounding_each': 8 + 4 * 8,
             'pseudo_pointer_vector': (hard_registers + 5 + 101) * 8,
             'pseudo_alignment_vector': hard_registers + 5 + 101,
             'constant_pool_hash_entries': 31 * 8,
             'cold_temp_hash_entries': 61 * 8,
             'sequence_stack': 3 * 8})
assert rows['pseudo_pointer_vector'] == 1584
result = {
    'scope': 'First target RTL setup of selected Linux generic x86-64 O0 compile class',
    'source_files_verified': len(sources), 'selected_headers_verified': len(headers),
    'instruction_fragments_verified': instruction_fragments,
    'gnat1_sha256': digest(binary),
    'machine_modes': len(modes), 'hard_registers': hard_registers,
    'register_classes': len(classes), 'max_recog_operands': operands,
    'instruction_codes': insn_codes, 'integer_modes': integers,
    'fixed_object_raw_requests': rows,
    'cold_cost_constant_candidates': len(cold_values),
    'cold_sequence_stack_events_bound': 10,
    'maximum_sequence_nesting': 2,
    'synthetic_SI_move_SETs': 6, 'synthetic_SI_move_INSNs': 6,
    'IRA_move_matrix_request_count_bound': 3 * len(modes),
    'IRA_move_matrix_individual_bytes': 2 * len(classes) ** 2,
    'IRA_cost_vector_request_count': 2 * operands + 2,
    'IRA_cost_vector_individual_bound': 4 * len(classes) + 4,
    'IRA_sort_scratch_needed_bound': len(classes) // 2 * 4,
    'IRA_sort_scratch_available': 32 * 8,
    'incoming_main_UIDs_are_not_fixed_constants': True,
    'shared_const_int_hash_backing_requires_full_incoming_demand': True,
    'cfun_stack_requires_incoming_demand_plus_one': True,
    'whole_native_capacity_established': False,
    'compiler_or_prover_executed_by_reconciler': False,
}

bundle = root / 'fixed-rtl-setup-witness'
manifest = json.loads((bundle / 'manifest.json').read_text())
for row in manifest['files']:
    raw = (bundle / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
capture = json.loads((bundle / 'capture-identity.json').read_text())
for row in capture['raw_compressed_files']:
    raw = gzip.decompress((bundle / row['archive']).read_bytes())
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
mapping = json.loads((root / 'fixed-gcc-prefix-witness/executable-map.json').read_text())
assert mapping['binary_sha256'] == digest(binary)
allowed = {}
for row in mapping['sites']:
    raw = bytes.fromhex(row['instruction_bytes'])
    address = int(row['address'], 16)
    assert at(address, len(raw)) == raw
    assert int(row['post_instruction_pc'], 16) == address + len(raw)
    allowed.setdefault(row['counter'], set()).add(row['post_instruction_pc'])
summary = json.loads((bundle / 'counter-summary.json').read_text())
assert summary['completed'] and not summary['failures']
assert not summary['new_threads'] and not summary['unexpected_collections']
assert summary['initial_rtl_initialized'] == 0
assert summary['initial_target_specific_initialized'] is False
assert summary['initial_timer_pointer'] == '0x0'
phases = summary['phases']
phase_events = [0, 0, 124, 129, 129, 140, 216, 285, 303, 310, 310, 310, 310]
assert [p['events']['ggc_bytes'] for p in phases] == phase_events
assert len(phases) == 13 and all(p['threads'] == 1 for p in phases)
assert phases[0]['phase'] == 'initialize_rtl_entry' and phases[0]['pc'] == '0x1358170'
assert phases[-1]['phase'] == 'initialize_rtl_return' and phases[-1]['pc'] == '0xf76b69'
assert (bundle / 'probe.log').read_text().count('RTL_COMPLETE ') == 1
watches = gzip.decompress((bundle / 'watchpoints.txt.gz').read_bytes()).decode()
assert watches.count('hw watchpoint') == 4
events = [json.loads(line) for line in gzip.decompress(
    (bundle / 'counter-events.jsonl.gz').read_bytes()).split(b'\n') if line]
assert len(events) == 310
state = {name: data['initial'] for name, data in summary['specs'].items()}
initial = dict(state)
histogram = Counter()
values_at_event = {0: dict(state)}
for index, event in enumerate(events, 1):
    name = event['counter']
    assert event['pc'] in allowed[name]
    assert event['old'] == state[name]
    assert event['new'] - event['old'] == event['delta']
    assert name == 'ggc_bytes' and event['delta'] > 0
    assert 0 <= event['new'] < 2 ** 64
    state[name] = event['new']
    histogram[event['delta']] += 1
    values_at_event[index] = dict(state)
for phase in phases:
    assert phase['values'] == values_at_event[phase['events']['ggc_bytes']]
    assert all(n == 'ggc_bytes' or v == 0 for n, v in phase['events'].items())
for name, final in state.items():
    data = summary['counters'][name]
    assert data['initial'] == initial[name] and data['current'] == final
    assert data['peak'] == final and data['minimum'] == initial[name]
    assert data['positive_sum'] == final - initial[name]
    assert data['negative_sum'] == data['negative_events'] == 0
    assert data['events'] == data['positive_events'] == (310 if name == 'ggc_bytes' else 0)
    assert data['largest_increment'] == (max(histogram) if name == 'ggc_bytes' else 0)
assert state['ggc_bytes'] - initial['ggc_bytes'] == 13120
assert max(histogram) == 2048
plan = json.loads((bundle / 'invocation.json').read_text())
frontend = json.loads((bundle / 'frontend-exec.json').read_text())
assert len(plan['environment']) == 7 and len(frontend['environment']) == 10
assert set(frontend['environment']) - set(plan['environment']) == {
    'GCC_EXEC_PREFIX', 'COLLECT_GCC', 'COLLECT_GCC_OPTIONS'}
assert all(frontend['environment'][k] == v for k, v in plan['environment'].items())
assert 'LD_LIBRARY_PATH' not in frontend['environment']
assert frontend['executable'] == plan['gnat1'] and frontend['threads'] == 1
assert plan['gnat1_sha256'] == digest(binary)

# Source decomposition of the captured GGC events. The fixed direct RTL
# constructors exclude constants, the sequence cache and shared hash growth.
direct_rtl = 124 + 5 + 18 + 5 + 4 + 12 + 7
dummy_objects = 11
assert direct_rtl == 175
assert direct_rtl + dummy_objects + len(cold_values) + 2 + 2 == len(events)
# After at most one incoming cleanup/growth, every further hash expansion
# requires an intervening inserted value: expansion leaves load <= 1/2 and
# clears deleted slots. No collection/deletion occurs inside setup.
hash_expansions_bound = len(cold_values) + 1
setup_events_bound = direct_rtl + dummy_objects + len(cold_values) + 10 + hash_expansions_bound
assert setup_events_bound == 437
result['lifetime_witness'] = {
    'managed_run_id': capture['managed_run_id'],
    'debugger_elapsed_seconds': capture['debugger_elapsed_seconds'],
    'elapsed_includes_startup_before_interval': True,
    'initial_observed_values': initial, 'final_observed_values': state,
    'GGC_lifetime_events': len(events), 'GGC_rounded_bytes': 13120,
    'largest_observed_increment': 2048,
    'rounded_size_histogram': dict(sorted(histogram.items())),
    'normal_and_debug_declaration_UID_changes': 0, 'type_UID_changes': 0,
    'collections_and_new_threads': 0, 'complete_compilation': False,
}
result['source_event_envelope'] = {
    'direct_RTL_objects': direct_rtl, 'dummy_GGC_objects': dummy_objects,
    'cold_cost_constants': len(cold_values), 'cold_sequence_objects': 10,
    'shared_hash_expansions': hash_expansions_bound,
    'GGC_events_bound': setup_events_bound,
    'shared_hash_individual_backing_still_requires_full_incoming_demand': True,
    'event_count_is_not_a_RAM_bound': True,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified', 'selected_headers_verified',
    'instruction_fragments_verified', 'cold_cost_constant_candidates', 'whole_native_capacity_established']}))
