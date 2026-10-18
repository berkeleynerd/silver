#!/usr/bin/env python3
"""Reconcile the selected null compiler's assembly-line/event ceiling offline."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'event-gcc-source-manifest.json').read_text())
sources = {}
for row in manifest['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in manifest['reused_results']:
    raw = (root.parent / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
binutils = json.loads((root / 'source-manifest.json').read_text())
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in binutils['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes']
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
        sources[row['path']] = raw.decode()

def lines(path, lo, hi):
    return '\n'.join(sources[path].split('\n')[lo-1:hi])

anchors = {
    'gcc/final.cc': ['app_on = 0;', 'if (app_on)',
                     'if (*templ == 0)\n    return;', "putc ('\\n', asm_out_file);"],
    'gcc/varasm.cc': ['switch_to_section (function_section (decl), decl);',
                      'switch_to_section (function_section (decl)); /* need to switch back */',
                      'else if (in_section == new_section)\n    return;',
                      'fputs (ASM_APP_OFF, asm_out_file);'],
    'gcc/dwarf2out.cc': ['if (dwarf2out_do_cfi_asm ())\n    return;',
                         'switch_to_section (fnsec);',
                         'fprintf (asm_out_file, "\\t.cfi_startproc\\n");',
                         'fprintf (asm_out_file, "\\t.cfi_endproc\\n");'],
    'gcc/config/gnu-user.h': ['#define ASM_APP_OFF "#NO_APP\\n"'],
    'gcc/target.def': ['(post_cfi_startproc,', 'hook_void_FILEptr_tree)'],
    'gas/input-scrub.c': ['logical_input_line = -1u;', 'physical_input_line = 0;',
                          'if (logical_input_line != -1u)\n    ++logical_input_line;'],
    'gas/read.c': ['new_logical_line_flags (s, -1, 1);'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)
for path in manifest['selected_target_headers'] + ['gcc/config/i386/i386.cc']:
    assert not re.search(r'^\s*#\s*define\s+TARGET_ASM_POST_CFI_STARTPROC\b',
                         sources[path], re.M)
property_body = lines('gcc/config/i386/gnu-property.cc', 29, 57)
assert property_body.count('fprintf (') == 12
assert property_body.count('\\n') == 12
assert property_body.count('ASM_OUTPUT_ALIGN (') == 3
assert property_body.count('switch_to_section (') == 1
assert lines('gcc/config/i386/gnu-property.cc', 60, 132).count('emit_gnu_property (') == 3

gas = json.loads((root / 'check-results.json').read_text())
backend = json.loads((root.parent / 'retained-backend-gigi-20261018'
                     / 'check-results.json').read_text())['arithmetic']
instructions = gas['selected_instructions']['ordinary_instruction_count']
assert instructions == backend['null_final_location_nop_ceiling'] + 4 == 22
labels = gas['selected_GAS_symbols_and_fixups']['GAS_symbol_creation_rows'][
    'compiler_named_and_numeric_labels']
assert labels == 3+5+2+1+3*5 == 26
cie_rules, function_rules, advances = backend['null_CFI_CIE_function_and_location_advance_object_ceilings']
assert (cie_rules, function_rules, advances) == (2, 5, 5)
rows = {
    'file_directive': 1,
    'optional_initial_NO_APP': 1,
    'function_section_selection_calls': 3,
    'GNU_stack_section': 1,
    'ident_directive': 1,
    'function_alignment_global_type_size': 4,
    'all_compiler_label_definitions_including_property_labels': labels,
    'positive_machine_instruction_lines': instructions,
    'CFI_function_rules_plus_start_end': function_rules+2,
    'three_property_notes_including_recharged_labels': 3*(12+3+1),
}
line_count = sum(rows.values())
assert line_count == 114
ident_bytes = gas['selected_unit_emission']['configured_ident_bytes_example']
assert ident_bytes == 29
line_bytes = max(64, ident_bytes+10)
assembly_bytes = line_count*(line_bytes+1)
assert assembly_bytes == 7410 < 32768
result = {
    'scope': 'Selected null Main complete assembly-line/event interface',
    'gcc_commit': manifest['commit'],
    'gcc_source_identities_checked': len(manifest['files']),
    'binutils_source_identities_checked': len(binutils['files']),
    'line_count_rows': rows,
    'compiler_emitted_lines_upper': line_count,
    'compiler_emitted_nonempty_statement_events_upper': line_count,
    'property_labels_deliberately_charged_twice': 15,
    'maximum_line_bytes_excluding_LF': line_bytes,
    'assembly_file_bytes_upper': assembly_bytes,
    'GAS_physical_line_counter_including_spare_sentinel_upper': line_count+1,
    'GAS_logical_line_counter_remains_disabled': True,
    'fixed_CIE_rules_are_not_compiler_directives': cie_rules,
    'all_compiler_lines_end_in_LF': True,
    'one_statement_or_label_per_selected_line': True,
    'required_premises': [
        'Prior complete selected null graph, RTL/CFI shape and effective no-debug/no-instrumentation options',
        'Configured identifier length 29 and the prior 64-byte line/name/counter bound',
        'No user assembly, macros, includes, line directives, section partitions, constants or external operands',
        'Selected GAS CFI route, empty target post-CFI hook and direct unit-output exclusions',
    ],
    'complete_inner_parser_and_writer_allocation_inventory': False,
    'complete_capacity_result': False,
    'native_execution': False,
    'reachability_basis': 'Handwritten output-path coverage; source anchors and arithmetic are not C semantic verification',
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
