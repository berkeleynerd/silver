#!/usr/bin/env python3
"""Reconcile selected null DF/LRA backing; never execute native compilation."""
import argparse
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
identity = json.loads((root / 'df-backing-source-identity.json').read_text())
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
assert '#define CHECKING_P 0' in headers['auto-host.h']
assert '#define GATHER_STATISTICS 0' in headers['auto-host.h']
assert '#define FIRST_PSEUDO_REG 92' in headers['insn-constants.h']
assert '#define MAX_RECOG_OPERANDS 30' in headers['insn-config.h']
assert '#define MAX_DUP_OPERANDS 14' in headers['insn-config.h']

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


dis = identity['disassembly']
packed = (root / dis['path']).read_bytes()
assert len(packed) == dis['bytes'] and digest(packed) == dis['sha256']
raw = gzip.decompress(packed)
assert len(raw) == dis['raw_bytes'] and digest(raw) == dis['raw_sha256']
fragments = 0
for address, encoded in re.findall(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)', raw.decode(), re.M):
    code = bytes.fromhex(encoded)
    assert at(int(address, 16), len(code)) == code
    fragments += 1

# Installed allocation paths confirm source layout arithmetic. The prose
# supplies the field-layout and selected call-path argument; pins alone do not.
assert at(0x11634f3, 8) == bytes.fromhex('48 8d 3c c0 48 c1 e7 04')  # 9 * 16
assert at(0x11845a7, 8) == bytes.fromhex('48 8d 3c c0 48 c1 e7 03')  # 9 * 8
assert at(0xe5ee29, 5) == bytes.fromhex('bf 00 01 00 00')  # scan data 256
assert at(0xe5ee33, 5) == bytes.fromhex('bf 88 00 00 00')  # pool wrapper 136
assert at(0xdaf041, 5) == bytes.fromhex('be 00 00 01 00')  # bitmap chunk 65536
assert at(0x26b053a, 7) == bytes.fromhex('8d 3c dd 08 00 00 00')  # 8 + 8W

scan = sources['gcc/df-scan.cc']
assert 'new_size += new_size / 4;' in scan
assert 'unsigned int new_size = get_max_uid () + 1;' in scan
assert 'DF_REF_ORDER (this_ref) = df->ref_order++;' in scan
assert 'hardreg->mw_order = df->ref_order++;' in scan
assert '/* Skip over the DF_SCAN problem. */' in sources['gcc/df-core.cc']
assert '#define MAX_ALIAS_LOOP_PASSES 10' in sources['gcc/alias.cc']
assert 'while (changed && ++pass < MAX_ALIAS_LOOP_PASSES);' in sources['gcc/alias.cc']
assert 'if (! have_referenced_pseudos)' in sources['gcc/lra-lives.cc']
assert 'reg_info_size = max_reg_num () * 3 / 2 + 1;' in sources['gcc/lra.cc']
assert 'if (n_operands == 0)\n    return 0;' in sources['gcc/recog.cc']
assert 'static const size_t block_size = 64 * 1024;' in sources['gcc/memory-block.h']
assert 'if (size == 0)\n    size = 1;' in sources['libiberty/xmalloc.c']
assert 'if (nelem == 0 || elsize == 0)\n    nelem = elsize = 1;' in sources['libiberty/xmalloc.c']

R, U, B, H, LRA_U = 99, 53, 12, 92, 27
reg_slots = R + R // 4
insn_slots = U + 1 + (U + 1) // 4
block_slots = B + 1 + (B + 1) // 4
simple_bitmap = lambda n: 8 + 8 * ((n + 63) // 64)
sparse_set = lambda n: 40 + (n - 1) * 2 * 4
heap_pointer_vector = lambda n: 8 + n * 8
pool_block = 65536
pool_sizes = {'df_base_ref': 64, 'df_artificial_ref': 72,
              'df_regular_ref': 72, 'df_insn_info': 48,
              'df_reg_info': 16, 'df_mw_hardreg': 32,
              'lra_insn_recog_data': 80}
pool_counts = {name: (pool_block - 8) // size
               for name, size in pool_sizes.items()}
assert pool_counts['df_reg_info'] >= 3 * R
assert pool_counts['lra_insn_recog_data'] >= 10
primes = [int(n) for n in re.findall(r'\{\s*(\d+), 0x', sources['libiberty/hashtab.c'])]
invariant_prime = min(p for p in primes if p >= 100)
assert invariant_prime == 127

result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'installed_headers_verified': len(headers),
    'instruction_fragments_verified': fragments,
    'backend_interface_premises': {
        'registers': R, 'first_unused_uid': U, 'block_index_slots': B,
        'lra_first_unused_uid': LRA_U, 'lra_live_real_insns': 10,
        'lra_instruction_patterns': ['CONST_INT 0', 'UNSPEC_VOLATILE [CONST_INT 0]'],
        'lra_referenced_pseudos': 0,
        'these_are_source_shape_inputs_not_observations': True,
    },
    'df_each_scan_generation': {
        'scan_generations': 2,
        'register_slots': reg_slots,
        'register_pointer_arrays': {'count': 3, 'each_bytes': reg_slots * 8},
        'register_count_arrays': {'count': 4, 'each_bytes': reg_slots * 4},
        'insn_slots': insn_slots, 'insn_pointer_bytes': insn_slots * 8,
        'block_slots': block_slots, 'scan_block_bytes': block_slots * 16,
        'LR_block_bytes': block_slots * 4 * 32,
        'scan_problem_bytes': 256,
        'allocator_wrappers': {'count': 6, 'each_bytes': 136},
        'scan_bitmap_initial_chunks': {'count': 2, 'each_bytes': pool_block},
        'reg_pool_objects_bound': 3 * R,
        'reg_pool_blocks_bound': 1,
        'hard_regs_live_count_bytes': H * 4,
        'hard_regs_live_count_created_once_per_df_instance': True,
    },
    'alias_selected_pre_LRA_call': {
        'maximum_iterations': 10,
        'no_SET_or_REG_NOALIAS_on_selected_chain': True,
        'unique_id_peak': 1,
        'reg_known_value_raw_request': heap_pointer_vector(98 - H),
        'reg_known_value_GGC_rounded_upper': 64,
        'reg_base_value_raw_request': heap_pointer_vector(98),
        'reg_base_value_GGC_rounded_upper': 1024,
        'known_equiv_bitmap_bytes': simple_bitmap(98 - H),
        'seen_bitmap_bytes': simple_bitmap(98),
        'new_base_pointer_array_bytes': 98 * 8,
        'reverse_postorder_array_bytes_bound': B * 4,
        'CFG_traversal_helpers_not_included': True,
    },
    'lra_selected_local_requests': {
        'reg_info_entries': R * 3 // 2 + 1,
        'reg_info_each_bytes': 144,
        'reg_info_array_bytes': (R * 3 // 2 + 1) * 144,
        'last_reg_value_after_initialization': R * 3 // 2 + 1,
        'live_solver_block_array_bytes_bound': B * 72,
        'live_solver_populated_bitmap_elements': 2,
        'live_points': 0,
        'constraint_pointer_vector_bytes_bound': heap_pointer_vector(LRA_U),
        'constraint_bitmap_bytes': simple_bitmap(LRA_U),
        'recog_pointer_array_bytes_bound': (LRA_U * 3 // 2) * 8,
        'static_recog_records': {'count_bound': 2, 'each_bytes': 40},
        'recog_pool_blocks_bound': 1,
        'operand_dup_arg_arrays_or_operand_alternatives': 0,
        'insn_reg_pool_objects': 0,
        'invariant_vector_bytes': heap_pointer_vector(100),
        'invariant_hash': {'wrapper_bytes': 112, 'slots': invariant_prime,
                           'backbone_bytes': invariant_prime * 8},
        'invariant_allocator_wrapper_bytes': 136,
        'inheritance_usage_array_bytes_bound': R * 24,
        'assignment_sparse_sets': {'count': 3, 'each_bytes': sparse_set(R)},
        'assignment_int_arrays': {'count': 6, 'each_bytes': R * 4},
        'assignment_thread_array_bytes': R * 12,
        'assignment_empty_arrays': {'count': 3, 'each_library_bytes': 1},
        'assignment_bitmap_initial_chunks': {'count': 2, 'each_bytes': pool_block},
    },
    'pool_backing': {'individual_block_bytes': pool_block,
                     'header_bytes': 8,
                     'typed_object_sizes': pool_sizes,
                     'objects_per_block': pool_counts},
    'unresolved_whole_function_inputs': [
        'A: DF analysis/optional-problem invocations and solver scratch lifetimes',
        'C_bb: total artificial-reference block collections including entry/exit updates',
        'C_ref: instruction/REG_NOTE reference creations including deferred rescans',
        'C_mw: multiword hard-register descriptor creations',
        'F_peak and bitmap_addend: DF ref-table backing and signed resize intermediates',
        'IRA root/cost/color/emit and register-class/equivalence helper requests',
        'LRA equivalence/elimination helpers and shared reg_obstack incoming demand',
        'real-function startup and later RTL/regnote/CFI/unit-emission GGC events',
    ],
    'whole_native_capacity_established': False,
    'aggregate_memory_gate': False,
    'compiler_or_prover_executed_by_reconciler': False,
}
assert (reg_slots, insn_slots, block_slots) == (123, 67, 16)
assert result['lra_selected_local_requests']['reg_info_array_bytes'] == 21456
assert sparse_set(R) == 824
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'source_files': len(sources), 'headers': len(headers),
                  'instruction_fragments': fragments,
                  'whole_native_capacity_established': False}))
