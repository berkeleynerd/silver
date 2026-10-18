#!/usr/bin/env python3
"""Check indexed GAS argv, named parser requests and relaxation arithmetic offline."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--record-excerpts', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def bundle(manifest_name, archive_name, commit):
    manifest = json.loads((root / manifest_name).read_text())
    assert manifest['commit'] == commit
    result = {}
    with tarfile.open(root / archive_name) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
        for row in manifest['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
            result[row['path']] = raw.decode()
    return result

gas = bundle('source-manifest.json', 'sources.tar.gz',
             '5e56594815854de5eca35c7c04b11705d0f19c02')
gcc = bundle('gcc-invocation-source-manifest.json', 'gcc-invocation-sources.tar.gz',
             '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea')
sources = gas | gcc
identity = json.loads((root / 'indexed-invocation-input-identity.json').read_text())
raw = (root / 'indexed-invocation-input.json').read_bytes()
assert len(raw) == identity['bytes'] and sha(raw) == identity['sha256']
assert identity['commit'].startswith('23f4ed506b')
descriptor = json.loads(raw)
expected = ['-c', '-x', 'ada', '-gnatA', '-gnat2022', '-gnata', '-gnato',
            '-gnatec={configuration}', '-gnatem={mapping}', '{workspace}/main.adb',
            '-o', 'main~1.o', '-gnateI1']
assert descriptor['native_GCC_argv_excluding_executable'] == expected
assert descriptor['native_GCC_argument_count'] == len(expected) == 13
assert descriptor['actual_indexed_config_map_or_full_argv_retained'] is False

ranges = {
    'gcc/gcc.cc': [(712, 722), (981, 999), (1328, 1350), (8354, 8367),
                   (11142, 11163)],
    'gcc/common.opt': [(105, 114)],
    'gcc/config.gcc': [(2123, 2130)],
    'gcc/config/i386/gnu-user64.h': [(34, 53)],
    'gcc/ada/gcc-interface/lang-specs.h': [(35, 52)],
    'gcc/ada/gcc-interface/lang.opt': [(95, 101)],
    'gas/as.c': [(630, 639), (1013, 1020), (1173, 1175), (1425, 1441)],
    'gas/as.h': [(330, 337)],
    'gas/read.c': [(1718, 1785), (2252, 2278), (2454, 2488), (6670, 6729)],
    'gas/config/tc-i386.c': [(2187, 2193), (3333, 3377), (7253, 7257),
                            (13365, 13447), (17049, 17091)],
    'gas/config/obj-elf.c': [(598, 610)],
    'gas/symbols.c': [(216, 216), (959, 989)],
    'gas/expr.c': [(125, 170)],
    'gas/write.c': [(2156, 2184), (2681, 2784), (2834, 2859),
                    (2955, 2995), (3145, 3183)],
    'gas/ehopt.c': [(480, 525)],
    'gas/sframe-opt.c': [(34, 108)],
}
excerpts = ['# Indexed GAS invocation and subsidiary-storage source excerpts\n\nLiteral LF numbering.\n']
for name, spans in ranges.items():
    lines = sources[name].split('\n')
    for low, high in spans:
        assert 1 <= low <= high <= len(lines)
        excerpts.append(f'\n## {name}:{low}–{high}\n\n```text\n')
        excerpts.extend(f'{n}: {lines[n-1].expandtabs(8)}'.rstrip()+'\n'
                        for n in range(low, high+1))
        excerpts.append('```\n')
excerpts = ''.join(excerpts)
if args.record_excerpts:
    (root / 'invocation-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'invocation-source-excerpts.md').read_text() == excerpts

anchors = {
    'gcc/gcc.cc': ['static const char *asm_options =', 'static const char *invoke_as =',
                   'as %(asm_options) %m.s %A', '%a %Y %{c:%W{o*}',
                   'if (debug_info_level > arg)'],
    'gcc/common.opt': ['enum debug_info_levels debug_info_level = DINFO_LEVEL_NONE'],
    'gcc/ada/gcc-interface/lang.opt': ['gnat\nAda AdaWhy AdaSCIL Driver Joined RejectNegative'],
    'gcc/ada/gcc-interface/lang-specs.h': ['%{!gnatc*:%{!gnats*:%(invoke_as)}}'],
    'gcc/config/i386/gnu-user64.h': ['#define SPEC_64 "m16|m32|mx32:;"',
                                   '%{" SPEC_64 ":--64}'],
    'gas/as.c': ['new_argv = notes_alloc (sizeof (char *) * (old_argc + 1));',
                 'out_file_name = notes_strdup (optarg);'],
    'gas/read.c': ['start = XNEWVEC (char, len + 1);'],
    'gas/config/tc-i386.c': ['xstrdup_copy = xstrdup (line);',
                            'char *buf = xstrdup (reg_string), *name;',
                            'copy = xstrdup (suffix_string);',
                            'tmpbuf = XNEWVEC (char, first + second + 2);'],
    'gas/symbols.c': ['int symbols_case_sensitive = 1;'],
    'gas/write.c': ['rsi.pass++;', 'if (!rsi.changed)',
                    'max_iterations = frag_count * frag_count;',
                    'fragP->last_fr_address = fragP->fr_address;'],
    'gas/ehopt.c': ['newsize = eh_frame_estimate_size_before_relax (frag);',
                   'return newsize - oldsize;'],
    'gas/sframe-opt.c': ['newsize = sframe_estimate_size_before_relax (frag);',
                        'return newsize - oldsize;'],
}
for name, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)
assert 'tc_canonicalize_symbol_name' not in gas['gas/config/tc-i386.h']
text_pos = gas['gas/as.c'].index('text_section = subseg_new (TEXT_SECTION_NAME, 0);')
assert text_pos < gas['gas/as.c'].index('data_section = subseg_new (DATA_SECTION_NAME, 0);')

# This is the source-reviewed projection of the exact descriptor through the
# selected specs, not a general GCC specs interpreter or a captured argv.
argv = ['AS_PATH', '--64', '-o', 'main~1.o', 'ASSEMBLY_TEMP_PATH']
a = len(argv)
p = len(argv[3].encode())+1
assert (a, p) == (5, 9)
q = max(65528, 8*(a+1), p)
chunk = max(4064, q+241)
assert q == 65528 and chunk == 65769
assert p+32056 == 32065
requests = {
    'unquoted_symbol_name_copy': 26,
    'instruction_retry_copy': 64+1,
    'register_expression_copy': 64+1,
    'pseudo_suffix_copy': 64+1,
    'GOT_token_scratch': 64+3,
}
assert max(requests.values()) == 67
gas_result = json.loads((root / 'check-results.json').read_text())
assert gas_result['selected_unit_emission']['fragment_bound_at_I_29'] == 924
assert gas_result['selected_unit_emission']['selected_unit_output_payload_bytes'] == '391+I'
assert gas_result['selected_unit_emission']['configured_ident_bytes_example'] == 29
assert 391+29 == 420
fragment_count = 924
max_iterations = fragment_count**2
assert max_iterations == 853776 < 2**64
assert max(chunk, p+32056, max(requests.values())) < 2**63

result = {
    'scope': 'Indexed native Main assembler projection, named scratch sites and selected relaxation arithmetic',
    'Binutils_complete_sources_verified': len(gas),
    'GCC_complete_sources_verified': len(gcc),
    'indexed_descriptor_sha256': identity['sha256'],
    'derived_assembler_argv': argv,
    'assembler_argc_including_argv0': a,
    'copied_output_name_bytes_including_NUL': p,
    'notes_argument_pointer_request_bytes': 8*(a+1),
    'notes_raw_request_upper': q,
    'notes_chunk_request_upper': chunk,
    'selected_output_BFD_alloc_size_upper': p+32056,
    'named_parser_heap_request_bytes_upper': requests,
    'selected_fragment_count_upper': fragment_count,
    'relaxation_iteration_safety_product_upper': max_iterations,
    'selected_inner_relaxation_sweeps_per_section': 1,
    'selected_outer_section_passes_upper': 2,
    'relaxation_allocation_events': 0,
    'fixed_point_basis': 'Manual selected fragment-class and forward text-to-frame dependency argument; checker reconciles source and arithmetic',
    'actual_indexed_argv_captured': False,
    'controlled_environment_and_path_premises_validated_here': False,
    'exhaustive_successful_GAS_BFD_call_inventory_complete': False,
    'whole_assembler_or_retained_tool_capacity_complete': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
