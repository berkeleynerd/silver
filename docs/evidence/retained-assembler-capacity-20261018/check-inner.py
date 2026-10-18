#!/usr/bin/env python3
"""Reconcile the selected GAS parser/writer allocation inventory offline."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
base = json.loads((root / 'source-manifest.json').read_text())
extra = json.loads((root / 'inner-source-manifest.json').read_text())
assert extra['commit'] == base['commit']
sources = {}
for manifest, name in [(base, 'sources.tar.gz'), (extra, 'inner-sources.tar.gz')]:
    with tarfile.open(root / name) as archive:
        assert set(archive.getnames()) == {r['path'] for r in manifest['files']}
        for row in manifest['files']:
            assert row['path'] not in sources
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes']
            assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
            sources[row['path']] = raw.decode()
for row in extra['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']

make = sources['gas/Makefile.am']
c_files = ['gas/' + n for n in re.findall(r'\b[\w-]+\.c\b', re.search(
    r'GAS_CFILES = \\\n(.*?)(?=\n\w|\n#)', make, re.S).group(1))]
c_files += ['gas/config/tc-i386.c', 'gas/config/obj-elf.c',
            'gas/config/tc-i386-ginsn.c', 'gas/config/tc-i386-intel.c']
h_files = ['gas/' + n for n in re.findall(r'\b[\w-]+\.h\b', re.search(
    r'HFILES = \\\n(.*?)(?=\n#)', make, re.S).group(1))]
h_files += ['gas/config/tc-i386.h', 'gas/config/obj-elf.h',
            'gas/config/te-linux.h', 'gas/config/obj-elf-attr.h']
assert c_files == extra['scanned_c_modules']
assert h_files == extra['scanned_gas_headers']
assert (len(c_files), len(h_files)) == (40, 37)
inventory = json.loads((root / 'inner-allocation-inventory.json').read_text())
actual = []
for path in c_files + h_files:
    for line, text in enumerate(sources[path].split('\n'), 1):
        for match in re.finditer(inventory['pattern'], text):
            actual.append({'path': path, 'line': line,
                           'allocator': match.group(0).split('(')[0].strip(),
                           'text': text.strip()})
expected = []
for row in inventory['sites']:
    assert row['family'] in inventory['families']
    expected.append({k: v for k, v in row.items() if k != 'family'})
assert actual == expected
assert len(actual) == 264
assert not any(row['allocator'] == 'alloca' for row in actual)

# These checks retain key guards and allocator indirections. The companion
# handwritten dispatch argument, not their lexical presence, establishes scope.
anchors = {
    'gas/as.h': ['#define obstack_chunk_alloc xmalloc', '#define xfree free'],
    'gas/hash.h': ['table->alloc_f (1, sizeof (*tuple))',
                   'htab_create_alloc (16, hash_string_tuple, eq_string_tuple,'],
    'gas/as.c': ['debug_info_type debug_type = DEBUG_UNSPECIFIED;'],
    'gas/read.c': ['(*pop->poc_handler) (pop->poc_val);',
                   'assemble_one (s);', 'fb_label_instance_inc (temp);'],
    'gas/config/tc-i386.c': ['static int intel_syntax = 0;',
                            '#include "tc-i386-ginsn.c"',
                            '#include "tc-i386-intel.c"',
                            'if (info->subseg == now_subseg)\n    return;'],
    'gas/dwarf2dbg.c': ['s_file (0);', 'debug_type != DEBUG_DWARF2'],
    'gas/depend.c': ['if (dep_file == NULL)'],
    'gas/write.c': ['if (size == 0)\n    return;', 'char buf[256];',
                    'if (flag_compress_debug != COMPRESS_DEBUG_NONE)'],
    'gas/compress-debug.c': ['ZSTD_createCCtx ();', 'deflateInit (&strm, Z_DEFAULT_COMPRESSION);'],
    'gas/ecoff.c': ['#ifdef ECOFF_DEBUGGING'],
    'gas/literal.c': ['#ifdef NEED_LITERAL_POOL'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)
for helper in ['str_hash_find_n', 'notes_memdup0']:
    assert all(not re.search(r'\b' + helper + r'\s*\(', sources[path])
               for path in c_files)
copy_callers = [path for path in c_files if re.search(r'\bxmemdup0\s*\(', sources[path])]
assert copy_callers == ['gas/dwarf2dbg.c', 'gas/listing.c', 'gas/macro.c']
concat_callers = [path for path in c_files
                  if path != 'gas/symbols.c' and re.search(r'\bnotes_concat\s*\(', sources[path])]
assert concat_callers == ['gas/dw2gencfi.c', 'gas/stabs.c']

inv = json.loads((root / 'invocation-check-results.json').read_text())
event = json.loads((root / 'event-check-results.json').read_text())
assert inv['assembler_argc_including_argv0'] == 5
assert inv['copied_output_name_bytes_including_NUL'] == 9
assert event['assembly_file_bytes_upper'] == 7410 < 32768
assert (inv['notes_raw_request_upper'], inv['notes_chunk_request_upper'],
        inv['selected_output_BFD_alloc_size_upper']) == (65528, 65769, 32065)
counts = Counter(inventory['families'][row['family']]['disposition']
                 for row in inventory['sites'])
result = {
    'scope': 'Selected null Main GAS-owned parser/writer dynamic allocation coverage',
    'binutils_commit': base['commit'],
    'existing_source_identities_checked': len(base['files']),
    'supplementary_source_identities_checked': len(extra['files']),
    'prior_result_identities_checked': len(extra['reused_results']),
    'GAS_C_modules_reviewed': len(c_files),
    'GAS_headers_reviewed': len(h_files),
    'lexical_allocation_wrapper_and_declaration_occurrences': len(actual),
    'lexical_occurrences_by_disposition': dict(sorted(counts.items())),
    'new_selected_dynamic_allocation_families': 0,
    'unchanged_notes_raw_request_upper': 65528,
    'unchanged_notes_chunk_request_upper': 65769,
    'unchanged_symbol_hash_pointer_array_upper': 16312,
    'unchanged_parser_scratch_request_upper': 67,
    'unchanged_fragment_and_frchain_chunk_upper': 4064,
    'initial_input_scrub_buffer_request': 65539,
    'selected_input_bytes_upper': 7410,
    'reused_BFD_lifetime_counter_upper': 32065,
    'reused_ELF_object_bytes_upper': 14352,
    'selected_GAS_owned_parser_writer_dynamic_request_inventory_complete': True,
    'coverage_basis': 'Handwritten selected dispatch, exclusion and callback review; lexical census and anchors are not C semantic verification',
    'remaining_interfaces': [
        'Earlier BFD object/backing transfers; no fresh exhaustive BFD internal-call proof',
        'Host allocation success, pointer placement, stack, stdio, locale and diagnostics',
        'Selected source/configuration-to-installed-tool premise and controlled invocation environment',
        'Compiler, binder, fixed-library and final-link phase composition',
    ],
    'complete_retained_tool_capacity': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
