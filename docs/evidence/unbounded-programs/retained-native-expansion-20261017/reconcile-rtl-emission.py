#!/usr/bin/env python3
"""Reconcile the selected null RTL schedule and emission backing offline."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'rtl-emission-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in identity['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']

inventory = json.loads((root / 'rtl-schedule-inventory.json').read_text())
schedule = sources['gcc/passes.def']
schedule = schedule[schedule.index('  NEXT_PASS (pass_expand);'):]
generic = re.findall(r'NEXT_PASS \((pass_\w+)', schedule)
target = re.findall(r'INSERT_PASS_(?:AFTER|BEFORE) \(pass_\w+, \d+, (pass_\w+)',
                    sources['gcc/config/i386/i386-passes.def'])
assert len(generic) == inventory['generic_occurrences'] == 98
assert len(target) == inventory['target_insertions'] == 8
for kind, expected in [('generic', generic), ('target_insertion', target)]:
    rows = [row for row in inventory['rows'] if row['kind'] == kind]
    assert [row['name'] for row in rows] == expected
    assert [row['index'] for row in rows] == list(range(len(expected)))
    for row in rows:
        line = sources[row['path']].split('\n')[row['class_line'] - 1]
        assert re.match(r'class ' + row['name'] + r'\s*:', line), row
        assert row['disposition']

anchors = {
    'gcc/final.cc': ['static int insn_counter = 0;', 'insn_counter++;',
                     'label_align.safe_grow_cleared (max_labelno - min_labelno + 1, true);',
                     'uid_shuid = XNEWVEC (int, max_uid);',
                     'insn_lengths = XNEWVEC (int, max_uid);',
                     'varying_length = XCNEWVEC (char, max_uid);',
                     'uid_align = XCNEWVEC (rtx, max_uid);',
                     'if (flag_ipa_stack_alignment',
                     'cgraph_node::rtl_info (current_function_decl)'],
    'gcc/common.opt': ['Common Var(flag_ipa_stack_alignment) Init(1) Optimization'],
    'gcc/cgraph.cc': ['node->rtl = ggc_cleared_alloc<cgraph_rtl_info> ();'],
    'gcc/rtl.h': ['struct GTY(()) cgraph_rtl_info {',
                  'unsigned int preferred_incoming_stack_boundary;',
                  'HARD_REG_SET function_used_regs;'],
    'gcc/insn-addr.h': ['insn_addresses_.create (size);'],
    'gcc/align.h': ['align_flags_tuple levels[2];', '#define MAX_CODE_ALIGN 16'],
    'gcc/dwarf2out.cc': ['if (dwarf2out_do_cfi_asm ())\n    return;',
                        'dup_label = xstrdup (label);',
                        'fde->dw_fde_end = xstrdup (label);',
                        'vec_alloc (*switch_ranges, 16);',
                        'mark_ignored_debug_section (fde, fde->dw_fde_second_begin != NULL);'],
    'gcc/varasm.cc': ['section_htab = hash_table<section_hasher>::create_ggc (31);',
                      'sect = ggc_alloc<section> ();',
                      'sect->named.name = ggc_strdup (name);',
                      'get_section (".note.GNU-stack", flags, NULL)',
                      'tree id = maybe_get_identifier (real_name);'],
    'gcc/config/i386/gnu-property.cc': ['get_section (".note.gnu.property",',
                                      'file_end_indicate_exec_stack ();'],
    'gcc/ada/gcc-interface/trans.cc': [
        'first_global_object_name = ggc_strdup (IDENTIFIER_POINTER (t));'],
    'gcc/dwarf2asm.cc': ['if (!indirect_pool)\n    return;'],
    'gcc/recog.cc': ['auto_sbitmap blocks (last_basic_block_for_fn (cfun));',
                     'return constrain_operands (strict, get_enabled_alternatives (insn));'],
    'gcc/hash-table.h': ['if (insert == INSERT && m_size * 3 <= m_n_elements * 4)'],
}
for path, strings in anchors.items():
    for string in strings:
        assert string in sources[path], (path, string)
# insn_counter has one initializing definition and one modifying statement;
# its remaining reference only formats the value. No earlier function emits.
counter_lines = [line.strip() for line in sources['gcc/final.cc'].split('\n')
                 if 'insn_counter' in line]
assert counter_lines == ['static int insn_counter = 0;', 'insn_counter++;',
                        'fprintf (asm_out_file, "%d", insn_counter);']

align8 = lambda n: (n + 7) // 8 * 8
H = 92
hard_set_bytes = (H + 63) // 64 * 8
cgraph_rtl_info_bytes = align8(4) + hard_set_bytes
assert cgraph_rtl_info_bytes == 24
uid_before_cfi = 43
chain_after_cfi = 52
shortening = {
    'label_alignment_vector': 8 + 4 * (2 * 2 * 4),
    'uid_shuid': uid_before_cfi * 4,
    'insn_lengths': uid_before_cfi * 4,
    'insn_addresses_vector': 8 + uid_before_cfi * 4,
    'varying_length': uid_before_cfi,
    'uid_align': uid_before_cfi * 8,
    'automatic_alignment_table': (16 + 1) * 8,
}
assert shortening == {
    'label_alignment_vector': 72, 'uid_shuid': 172, 'insn_lengths': 172,
    'insn_addresses_vector': 180, 'varying_length': 43, 'uid_align': 344,
    'automatic_alignment_table': 136,
}
switch_ranges_raw = 8 + 16 * 8
assert switch_ranges_raw == 136
section_bytes = max(align8(4) + 2 * 8, align8(4) + 3 * 8,
                    align8(4) + 8)
assert section_bytes == 32
section_names = ['.note.GNU-stack', '.note.gnu.property']
name_bytes = {name: len(name.encode()) + 1 for name in section_names}
assert name_bytes == {'.note.GNU-stack': 16, '.note.gnu.property': 19}
# GCC's ggc_alloc_string special-cases only empty/one-byte decimal strings;
# these names each have one allocation, with no shared identifier insertion.
section_count = len(section_names)
section_hash_capacity = 31
assert section_count * 4 < section_hash_capacity * 3
label_bytes = 2 + 3 + 20 + 1
assert label_bytes == 26 < 40
code_address_bound = 18 + 2 + 3 + 2 + 1
assert code_address_bound == 26
assert chain_after_cfi < (1 << 31) and uid_before_cfi < (1 << 31)
late_events = 1
emission_events = 1 + section_count * 2
known_GGC = 39257 + 437 + 10 + 4 + 2 + 2 + 8 + 10 + 78 + 43 + 100
assert known_GGC == 39951

result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'schedule_occurrences': len(generic) + len(target),
    'schedule_dispositions': dict(Counter(row['disposition']
                                         for row in inventory['rows'])),
    'late_RTL': {'additional_GGC_events_upper': late_events,
                 'cgraph_RTL_info_raw_bytes': cgraph_rtl_info_bytes,
                 'nonmatching_split_simple_bitmap_bits_upper': 12,
                 'nonmatching_split_simple_bitmap_raw_bytes': 16,
                 'remaining_pass_specific_GGC_constructor_residual': 0},
    'emission': {'additional_GGC_events_upper': emission_events,
                 'switch_text_ranges_vector_events_upper': 1,
                 'switch_text_ranges_initial_slots': 16,
                 'switch_text_ranges_raw_bytes_before_GGC_rounding': switch_ranges_raw,
                 'switch_text_ranges_rounded_bytes_upper': 256,
                 'named_section_events_upper': section_count,
                 'named_section_raw_bytes': section_bytes,
                 'section_name_GGC_string_events_upper': section_count,
                 'section_name_raw_bytes': name_bytes,
                 'section_hash_initial_slots': section_hash_capacity,
                 'section_hash_growth_events': 0,
                 'FDE_ordinary_label_requests': 2,
                 'FDE_ordinary_label_bytes_upper_each': label_bytes,
                 'ordinary_shortening_and_alignment_bytes': shortening,
                 'initial_insn_counter': 0,
                 'final_insn_counter_upper': chain_after_cfi,
                 'shortening_address_upper': code_address_bound,
                 'raw_DWARF_unit_emission_selected': False},
    'known_GGC_subtotal': known_GGC + late_events + emission_events,
    'premises': [
        'Selected Linux LP64 O0 null family, H92, selected x86 MD closure',
        'No AVX, CF_BRANCH, patch area, debug, instrumentation, custom attributes or plugins',
        'One emitted Main, empty elaboration not finalized, forced dummy is hard-register declaration',
        'Existing shape/DF/IRA/LRA/CFG/CFI packets, source config and installed headers unchanged',
        'CFI assembler directives enabled and configured personality/encoding support',
        'Selected no-section-attribute null translation and default init_sections hook',
        'Main DECL_RTL and assembler-name construction owned by translation/expansion',
    ],
    'required_remaining_inputs': [
        'Metadata/source path, location and shared identifier/hash corrections',
        'Main gigi/GIMPLE/cgraph/IPA constructors including pending external declarations',
        'Whole-unit symbol finalization and output-order helpers outside selected emission',
        'Shared GGC page/finalizer and non-DF pool retained-count composition',
        'Libc FILE and formatted-output contract; ordinary requests are not GGC events',
        'Independent producer, assembler and linker capacity joins',
    ],
    'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'sources': len(sources), 'schedule_occurrences': len(generic) + len(target),
                  'new_GGC_events_upper': late_events + emission_events,
                  'known_GGC_subtotal': result['known_GGC_subtotal'],
                  'whole_native_capacity_established': False}))
