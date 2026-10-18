#!/usr/bin/env python3
"""Check selected null-function CFI source/storage arithmetic offline."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'cfi-storage-source-identity.json').read_text())
digest = lambda raw: hashlib.sha256(raw).hexdigest()
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
row = identity['reused_identity']
raw = (root / row['path']).read_bytes()
assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
retained = json.loads(raw)
row = retained['headers_archive']
raw = (root / row['path']).read_bytes()
assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
headers = {}
with tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz') as archive:
    for row in retained['selected_headers']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
        headers[row['path']] = raw.decode()
assert '#define NUM_POLY_INT_COEFFS 1' in headers['insn-modes.h']
assert 'gen_rtx_MEM (Pmode, stack_pointer_rtx)' in headers['config/i386/i386.h']
assert headers['tm.h'].index('config/i386/att.h') < headers['tm.h'].index('config/elfos.h')
label_headers = [p for p, s in headers.items()
                 if re.search(r'^#define ASM_GENERATE_INTERNAL_LABEL', s, re.M)]
assert set(label_headers) == {'config/i386/att.h', 'config/elfos.h'}

cfi = sources['gcc/dwarf2cfi.cc']
assert 'dst->reg_save = vec_safe_copy (src->reg_save);' in cfi
assert 'trace_info.create (16);' in cfi
assert 'new hash_table<trace_info_hasher> (trace_info.length ())' in cfi
assert 'char label[20];' in cfi
assert 'initial_return_save (INCOMING_RETURN_ADDR_RTX);' in cfi
assert 'vec_safe_push (fde_vec, fde);' in sources['gcc/dwarf2out.cc']
assert 'else if (alloc < 16)' in sources['gcc/vec.cc']
assert 'alloc = alloc * 2;' in sources['gcc/vec.cc']
assert 'new_vec->embedded_init (len, len);' in sources['gcc/vec.h']

align8 = lambda n: (n + 7) // 8 * 8
cfa = align8(8 + 8 + 8 + 1)
row = align8(cfa + 8 + 8 + 1 + 3 + 4)
trace = align8(3 * 8 + 4 * 8 + 8 + 2 * cfa + 8 + 4 + 3)
fde = align8(9 * 8 + 4 + 4 + 8 + 4 * 4 + 4)
assert (cfa, row, trace, fde) == (32, 56, 144, 112)
primes = [int(x) for x in re.findall(r'\{\s*(\d+), 0x', sources['gcc/hash-table.cc'])]
trace_hash_prime = min(p for p in primes if p >= 6)
assert trace_hash_prime == 7
# Before the final of six insertions only five entries exist: no expansion.
assert 5 * 4 < trace_hash_prime * 3

# Rounding only adds capacity. Three allocations suffice for <=10 pushes:
# unrounded minima4,8,16. Any growing allocation starts at capacity<=9,
# doubles to<=18, requests<=152, and rounds to no more than256 bytes.
minimum_capacities = [4, 8, 16]
assert minimum_capacities[-1] >= 10
assert 8 + 2 * 9 * 8 == 152
events = {'CFI_objects': 12, 'row_objects': 12, 'row_save_vectors': 12,
          'CIE_vector': 1, 'FDE_object': 1, 'global_FDE_vector': 1,
          'FDE_CFI_vector_allocations_upper': 3, 'incoming_return_address_MEM': 1}
assert sum(events.values()) == 43
result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'retained_installed_headers_verified': len(headers),
    'premises': {'emitted_functions': 1, 'CFI_objects_upper': 12,
                 'CFI_rows_upper': 12, 'trace_count_upper': 6,
                 'register_columns': [6, 7, 16],
                 'reg_save_length': 17, 'no_location_expressions': True,
                 'linear_fallthrough_traces_scanned_once': True},
    'individual_raw_object_bytes': {'CFI': 24, 'CFA_location': cfa,
                                    'CFI_row': row, 'FDE': fde, 'trace': trace},
    'GGC_vector_bounds': {
        'row_save': {'count': 12, 'length': 17, 'raw_bytes': 144,
                     'rounded_bytes_upper': 256, 'later_growth_events': 0},
        'CIE': {'length_upper': 2, 'initial_raw_bytes': 40,
                'rounded_bytes_upper': 64, 'allocations_upper': 1},
        'global_FDE': {'length': 1, 'initial_raw_bytes': 40,
                       'rounded_bytes_upper': 64, 'allocations_upper': 1},
        'FDE_CFI': {'length_upper': 10, 'allocations_upper': 3,
                    'each_raw_request_upper': 152, 'rounded_bytes_upper': 256}},
    'ordinary_storage': {
        'trace_vector': {'capacity': 16, 'raw_bytes': 8 + 16 * trace},
        'trace_hash': {'wrapper_bytes': 48, 'backbone_slots': 7,
                        'backbone_bytes': 56, 'growth_events': 0},
        'trace_worklist': {'maximum_length': 1, 'capacity': 4, 'raw_bytes': 40},
        'queued_reg_saves': {'maximum_length': 1, 'capacity': 4, 'raw_bytes': 104},
        'regs_saved_in_regs_backing_requests': 0,
        'CFI_labels': {'count_upper': 5, 'bytes_each_including_NUL': 8,
                       'stack_buffer_bytes': 20}},
    'excluded_GGC_constructors': ['location-expression nodes', 'copy_cfa objects',
                                   'cie_return_save record'],
    'additional_disjoint_GGC_event_bounds': events,
    'additional_disjoint_GGC_events_total': sum(events.values()),
    'CFI_chain_notes_already_charged_in_RTL_packet': 10,
    'final_unwind_emission_and_unit_helpers_included': False,
    'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'source_files': len(sources), 'headers': len(headers),
                  'additional_GGC_events': sum(events.values()),
                  'whole_native_capacity_established': False}))
