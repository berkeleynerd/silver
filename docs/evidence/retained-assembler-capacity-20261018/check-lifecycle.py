#!/usr/bin/env python3
"""Reconcile GAS predefinitions and adjacent entry/exit paths without native tools."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--record-excerpts', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'source-manifest.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(row['path'] for row in manifest['files'])
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes']
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
        sources[row['path']] = raw.decode()


def lines(name, low, high):
    return '\n'.join(sources[name].split('\n')[low-1:high])


ranges = {
    'gas/as.c': [(50, 59), (70, 75), (132, 132), (705, 711),
                 (1203, 1220), (1254, 1295), (1304, 1349),
                 (1363, 1447), (1457, 1465), (1502, 1587)],
    'gas/as.h': [(344, 344)],
    'gas/symbols.c': [(330, 424), (714, 719), (1805, 1823)],
    'gas/config/obj-elf.c': [(2076, 2098), (2467, 2494), (2989, 3036)],
    'gas/config/tc-i386.c': [(3644, 3655), (3744, 3779)],
    'gas/config/tc-i386.h': [(240, 242)],
    'gas/listing.c': [(285, 295), (1426, 1472)],
    'gas/cond.c': [(547, 565)],
    'gas/codeview.c': [(620, 632)],
    'gas/read.c': [(253, 302), (947, 1036)],
    'gas/input-file.c': [(79, 95)],
    'gas/input-scrub.c': [(141, 169), (243, 275)],
    'gas/app.c': [(169, 269), (307, 326)],
    'gas/remap.c': [(73, 85)],
    'gas/depend.c': [(57, 74), (183, 190)],
    'gas/output-file.c': [(33, 53), (69, 124)],
    'libiberty/argv.c': [(359, 396)],
    'libiberty/xasprintf.c': [(41, 51)],
    'libiberty/xvasprintf.c': [(48, 61)],
    'libiberty/vprintf-support.c': [(40, 68), (117, 119), (157, 159)],
    'bfd/bfd.c': [(818, 829), (1962, 1969)],
    'bfd/targets.c': [(1473, 1497), (1551, 1586)],
    'bfd/cache.c': [(556, 591)],
}
excerpts = ['# GAS predefinition and entry/exit source excerpts\n\nLiteral LF numbering.\n']
for name, spans in ranges.items():
    source_lines = sources[name].split('\n')
    for low, high in spans:
        assert 1 <= low <= high <= len(source_lines)
        excerpts.append(f'\n## {name}:{low}–{high}\n\n```text\n')
        excerpts.extend(f'{n}: {source_lines[n-1].expandtabs(8)}'.rstrip()+'\n'
                        for n in range(low, high+1))
        excerpts.append('```\n')
excerpts = ''.join(excerpts)
if args.record_excerpts:
    (root / 'lifecycle-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'lifecycle-source-excerpts.md').read_text() == excerpts

anchors = {
    'gas/as.c': ['char *name = xasprintf ("GAS(%s)", tmpl);',
                 'if (flag_strip_local_absolute < 0)',
                 's = symbol_create (name, absolute_section, &zero_address_frag, val);',
                 'int listing;', 'static char *listing_filename = NULL;'],
    'gas/as.h': ['COMMON int flag_strip_local_absolute;'],
    'gas/symbols.c': ['symbolP->bsym = bfd_make_empty_symbol (stdoutput);',
                      'symbol_clear_list_pointers (symbolP);',
                      'htab_insert (sy_hash, symbolP, 1);',
                      'if (entry->sy.flags.local_symbol)\n    resolve_symbol_value (&entry->sy);'],
    'libiberty/xasprintf.c': ['buf = xvasprintf (fmt, ap);'],
    'libiberty/xvasprintf.c': [
        'int total_width = libiberty_vprintf_buffer_size (format, args);',
        'result = (char *) xmalloc (total_width);'],
    'libiberty/vprintf-support.c': [
        'int total_width = strlen (format) + 1;', 'total_width += 30;',
        'total_width += strlen (va_arg (ap, char *));'],
    'libiberty/argv.c': ["if (filename[0] != '@')\n\tcontinue;"],
    'gas/read.c': ['if (!startswith (s, "APP") || !is_end_of_line (s[3]))'],
    'gas/listing.c': ['if (listing == 0)\n    return;',
                      'if (listing & LISTING_LISTING)', 'if (listing & LISTING_SYMBOLS)'],
    'gas/depend.c': ['if (dep_file == NULL)\n    return;'],
    'gas/output-file.c': ['bfd_openw (name, TARGET_FORMAT)', 'stdoutput = NULL;'],
    'bfd/bfd.c': ['free (_bfd_error_buf);', '_bfd_error_buf = NULL;'],
    'bfd/cache.c': ['++open_files;'],
}
for name, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)
assert 'symbol_append' not in lines('gas/symbols.c', 405, 424)
assert 'symbol_append' in lines('gas/symbols.c', 330, 339)
assert 'symbol_append' not in lines('gas/symbols.c', 714, 719)
assert not re.search(r'\b(?:x?malloc|x?calloc|x?realloc|XNEW\w*|notes_alloc)\s*\(',
                     sources['bfd/cache.c'])
assert lines('gas/codeview.c', 622, 625).endswith('codeview_finish (void)\n{\n}')
templates = re.findall(r'predefine_symbol \("([^"]+)"', sources['gas/as.c'])
assert templates == ['version', 'date']
format_string = 'GAS(%s)'
format_request = {s: len(format_string)+1+30+len(s) for s in templates}
preserved_names = {s: len('GAS('+s+')')+1 for s in templates}
assert format_request == {'version': 45, 'date': 42}
assert preserved_names == {'version': 13, 'date': 10}

gas = json.loads((root / 'check-results.json').read_text())
symbols = gas['selected_GAS_symbols_and_fixups']
assert symbols['GAS_symbol_objects'] == 90
assert symbols['GAS_output_chain_symbols_upper'] == 88
assert symbols['BFD_symbol_allocations_through_GAS'] == 104
assert symbols['maximum_symbol_pointer_array_bytes'] == 704
invocation = json.loads((root / 'invocation-check-results.json').read_text())
assert invocation['derived_assembler_argv'] == [
    'AS_PATH', '--64', '-o', 'main~1.o', 'ASSEMBLY_TEMP_PATH']
assert invocation['selected_output_BFD_alloc_size_upper'] == 32065
assert max(format_request.values()) <= max(
    invocation['named_parser_heap_request_bytes_upper'].values()) == 67
obj = json.loads((root / 'object-check-results.json').read_text())
assert obj['outgoing_symbol_entries_including_null'] == 98
assert obj['object_file_bytes_upper'] == 14352

result = {
    'scope': 'Selected GAS predefinitions and adjacent entry/exit allocation routes',
    'complete_sources_verified': len(sources),
    'predefined_template_strings': templates,
    'predefined_temporary_format_requests_bytes': format_request,
    'predefined_retained_name_requests_bytes': preserved_names,
    'predefined_GAS_full_objects_upper': 2,
    'predefined_BFD_objects_upper': 2,
    'predefined_output_chain_objects_selected': 0,
    'corrected_allocated_GAS_symbol_objects_upper': 90,
    'corrected_allocated_BFD_symbol_objects_upper': 104,
    'unchanged_output_chain_symbols_upper': 88,
    'unchanged_serialized_ELF_symbols_upper': 98,
    'unchanged_object_bytes_upper': 14352,
    'corrected_later_BFD_main_arena_raw_bytes_upper': 23608,
    'corrected_BFD_lifetime_raw_bytes_upper': 'P+32056',
    'corrected_indexed_BFD_lifetime_raw_bytes_upper': 32065,
    'supersedes_finding_125': {
        'allocated_GAS': 88, 'allocated_BFD': 102,
        'later_BFD_main_arena_raw_bytes': 23352,
        'BFD_lifetime_raw_bytes': 'P+31800',
        'indexed_BFD_lifetime_raw_bytes': 31809,
    },
    'reachability_basis': 'Manual selected-argv/stream and target argument in the research record; source checks are not a C semantic proof',
    'complete_inner_parser_and_writer_call_inventory': False,
    'complete_emitted_line_or_event_count': False,
    'libc_locale_stdio_allocator_internals_expanded': False,
    'whole_assembler_or_retained_tool_capacity_complete': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
