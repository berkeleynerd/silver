#!/usr/bin/env python3
"""Reconcile source-derived null RTL constructor/storage bounds offline."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', required=True, type=Path)
parser.add_argument('--gnat1', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'rtl-constructors-source-identity.json').read_text())
digest = lambda raw: hashlib.sha256(raw).hexdigest()
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
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


row = identity['rtx_size_table']
raw = at(int(row['address'], 16), row['bytes'])
assert digest(raw) == row['sha256']
codes = re.findall(r'^DEF_RTL_EXPR\((\w+),\s*"[^"]*",\s*("[^"]*"|\w+)',
                   sources['gcc/rtl.def'].split('#ifdef GENERATOR_FILE')[0], re.M)
codes = [(name, fmt.strip(chr(34))) for name, fmt in codes]
assert len(codes) == len(raw) == 154
sizes = {}
for name, entry in row['selected'].items():
    assert codes[entry['index']] == (name, entry['format'])
    assert raw[entry['index']] == entry['bytes']
    # LP64 header8, rtunion8; REG uses its separate16-byte reg_info.
    expected = 8 + (16 if name == 'REG' else len(entry['format']) * 8)
    assert expected == entry['bytes']
    sizes[name] = expected

# Path-selection arguments are in the report; these guards only tie the
# checked counts to the corresponding retained source definitions.
fn = sources['gcc/function.cc']
emit = sources['gcc/emit-rtl.cc']
x86 = sources['gcc/config/i386/i386.cc']
assert 'prologue_insn_hash = NULL;' in fn and 'epilogue_insn_hash = NULL;' in fn
assert 'hash_table<insn_cache_hasher>::create_ggc (17)' in fn
assert 'if (!flag_split_stack' in fn
assert 'if (crtl->shrink_wrapped_separate)' in fn
assert 'case SIMPLE_RETURN:\n      return simple_return_rtx;' in emit
assert 'MEM_ATTRS (rt) = 0;' in emit
assert 'if (reg_rtx_no < old_size)\n    return;' in emit
assert 'if (count != frame->expensive_count)' in x86
assert 'ix86_emit_restore_reg_using_pop (hard_frame_pointer_rtx);' in x86
assert 'r = gen_rtx_EXPR_LIST ((machine_mode) kind, val, next);' in sources['gcc/lists.cc']
assert 'x = gen_rtx_PLUS (mode, x, gen_int_mode (c, mode));' in sources['gcc/explow.cc']
assert 'fprintf (file, "  start_sequence ();\\n");' in sources['gcc/genemit.cc']

chain = {'CODE_LABEL': 3, 'NOTE': 25, 'INSN': 22, 'JUMP_INSN': 1, 'BARRIER': 1}
assert sum(chain.values()) == 52
frame_patterns = {'PRE_DEC': 1, 'POST_INC': 1, 'MEM': 2, 'SET': 3}
assert sum(frame_patterns.values()) == 7
frame_notes = {'PLUS': 1, 'EXPR_LIST': 2}
assert sum(frame_notes.values()) == 3
primes = [int(x) for x in re.findall(r'\{\s*(\d+), 0x', sources['gcc/hash-table.cc'])]
hash_prime = min(p for p in primes if p >= 17)
assert hash_prime == 31 and 2 * 4 < hash_prime * 3
events = {'all_phase_chain': 52, 'blockage_pattern_and_rtvec': 6,
          'LRA_unused_pseudo': 1, 'frame_patterns': 7, 'frame_regnotes_and_data': 3,
          'cold_frame_sequence_stacks': 5, 'frame_hash_wrappers_and_backbones': 4}
assert sum(events.values()) == 78
result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'installed_rtx_size_entries_verified': len(sizes),
    'premises': {
        'backend_final_chain_bound': 52,
        'machine_shape': ['push RBP', 'move RSP to RBP', 'pop RBP', 'simple_return'],
        'other_patterns': ['cached const0 nops', 'operand-free blockage'],
        'new_dynamic_pseudos': 1,
        'local_stack_slots': 0,
        'separate_shrink_wrap_split_stack_or_profile': False,
        'construction_of_frame_sequences_repeated': False,
    },
    'RTL_raw_object_sizes': sizes,
    'instruction_chain': {
        'cumulative_counts': chain,
        'GGC_events_bound': 52,
        'maximum_individual_raw_bytes': max(sizes[k] for k in chain),
        'includes_CFI_and_CFI_label_NOTEs': 10,
        'location_strings_and_nonchain_CFI_objects_included': False,
    },
    'blockage': {'UNSPEC_VOLATILE_nodes': 3, 'one_element_rtvecs': 3,
                 'individual_rtvec_bytes': 16, 'includes_two_unsharing_copies': True},
    'LRA_unused_pseudo': {'number': 98, 'individual_raw_bytes': sizes['REG'],
                          'register_array_growth_events': 0, 'register_array_capacity': 198},
    'selected_target_frame_layout': {
        'local_allocation_bytes': 0, 'return_address_bytes': 8,
        'saved_frame_pointer_bytes': 8,
        'frame_offsets_before_prologue': [16, 16, 16, 16, 16],
        'frame_size_or_offset_dynamic_heap_requests': 0,
        'expensive_function_query_reached': False,
        'xlogue_and_realign_helpers_reached': False,
        'elimination_offsets': [16, 0, 16, 0],
        'initial_elimination_hook_allocations': 0,
    },
    'frame_patterns': frame_patterns,
    'frame_regnotes_and_data_upper': frame_notes,
    'frame_MEM_attribute_objects': 0,
    'new_CONST_INT_or_SIMPLE_RETURN_objects': 0,
    'frame_sequence_stacks': {'calls': 5, 'maximum_nesting': 3,
                               'cold_GGC_events_bound': 5, 'individual_raw_bytes': 24},
    'frame_instruction_hashes': {'tables': 2, 'entries_each': 2,
                                'wrapper_bytes_each': 48,
                                'backbone_slots_each': hash_prime,
                                'backbone_bytes_each': hash_prime * 8,
                                'growth_events': 0},
    'additional_disjoint_GGC_event_bounds': events,
    'additional_disjoint_GGC_events_total': sum(events.values()),
    'generic_RTL_helpers_CFI_objects_and_unit_emission_remain_separate': True,
    'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'source_files': len(sources), 'installed_rtx_sizes': len(sizes),
                  'additional_GGC_events': sum(events.values()),
                  'whole_native_capacity_established': False}))
