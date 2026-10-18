#!/usr/bin/env python3
"""Check selected GAS shared-backing arithmetic offline; execute no native tools."""
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

ranges = {
    'gas/as.c': [(630, 640), (1160, 1176), (1325, 1335)],
    'gas/subsegs.h': [(45, 111)],
    'gas/subsegs.c': [(35, 40), (70, 97), (131, 145)],
    'gas/dw2gencfi.h': [(77, 94), (115, 235)],
    'gas/dw2gencfi.c': [(366, 400), (430, 434), (2256, 2275)],
    'gas/gen-sframe.h': [(59, 153)],
    'gas/gen-sframe.c': [(591, 627), (1070, 1075)],
    'gas/symbols.c': [(245, 303)],
    'gas/hash.h': [(25, 32), (56, 64), (96, 117)],
    'gas/read.c': [(252, 260), (6341, 6371)],
    'gas/config/obj-elf.c': [(203, 215), (503, 516), (575, 639),
                           (1071, 1124), (1415, 1430)],
    'gas/config/tc-i386.h': [(289, 306)],
    'gas/config/tc-i386.c': [(18799, 18829)],
    'gas/output-file.c': [(56, 95)],
    'include/obstack.h': [(156, 198), (314, 358)],
    'libiberty/obstack.c': [(114, 150), (187, 235)],
}
excerpts = ['# Selected GAS shared-backing source excerpts\n\nLiteral LF numbering.\n']
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
    (root / 'backing-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'backing-source-excerpts.md').read_text() == excerpts

anchors = {
    'gas/as.c': ['new_argv = notes_alloc (sizeof (char *) * (old_argc + 1));',
                 'out_file_name = notes_strdup (optarg);',
                 'obstack_begin (&notes, chunksize);'],
    'gas/subsegs.c': ['obstack_begin (&frchains, chunksize);',
                      'seginfo = obstack_alloc (&notes, sizeof (*seginfo));',
                      'newP = obstack_alloc (&frchains, sizeof (frchainS));'],
    'gas/dw2gencfi.c': ['struct fde_entry *fde = notes_calloc (1, sizeof (*fde));',
                       'notes_calloc (1, sizeof (struct frch_cfi_data));',
                       'struct cfi_insn_data *insn = notes_calloc (1, sizeof (*insn));',
                       'cie = XNEW (struct cie_entry);'],
    'gas/gen-sframe.c': ['XCNEW (struct sframe_row_entry)',
                        'XCNEW (struct sframe_func_entry)',
                        'XCNEW (struct sframe_xlate_ctx)'],
    'gas/config/tc-i386.c': ['if (info->subseg == now_subseg)\n    return;'],
    'gas/output-file.c': ['obstack_ptr_grow (&notes, &frchp->frch_obstack);',
                          'obstack_ptr_grow (&notes, NULL);',
                          'obs = obstack_finish (&notes);'],
    'gas/hash.h': ['NULL, notes_calloc, NULL);',
                   'string_tuple_t *tuple = table->alloc_f (1, sizeof (*tuple));'],
    'libiberty/obstack.c': ['size_t sum1 = obj_size + length;',
                           'size_t sum2 = sum1 + h->alignment_mask;',
                           'size_t new_size = sum2 + (obj_size >> 3) + 100;',
                           'if (new_size < h->chunk_size)\n    new_size = h->chunk_size;'],
}
for name, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)
for macro in ['tc_fde_entry_extras', 'tc_cie_entry_extras', 'NEED_LITERAL_POOL',
              'TARGET_MULTIPLE_EH_FRAME_SECTIONS', 'tc_cfi_reloc_for_encoding']:
    assert not re.search(r'^\s*#\s*define\s+' + macro + r'\b',
                         sources['gas/config/tc-i386.h'], re.M)

# Count inputs and conservative ABI ceilings are justified by the companion
# source derivations, not inferred from a native run or proved by these anchors.
previous = json.loads((root / 'check-results.json').read_text())
assert previous['selected_GAS_symbols_and_fixups']['maximum_relocation_pointer_slots'] == 281
ptr = 8
chain_count = 13
raw = {
    'frchain': (13, 192), 'segment_info': (13, 128),
    'CFI_instruction': (12, 96), 'FDE': (1, 224),
    'frchain_CFI_state': (1, 32), 'CIE': (1, 128),
    'SFrame_row': (6, 128), 'SFrame_function': (1, 64),
    'SFrame_context': (1, 64), 'SFrame_FDE_symbol_array': (1, 8),
}
# A deliberately loose per-field LP64 accounting checks the declared ceilings.
layout_sums = {
    'frchain': 8*8 + 8 + 88,
    'segment_info': 5*8 + 8 + 8 + 40,
    'CFI_instruction': 2*8 + 8 + (8+40),
    'FDE': 9*8 + 8 + 2*40 + 5*8,
    'frchain_CFI_state': 4*8,
    'CIE': 4*8 + 3*8 + 40,
    'SFrame_row': 3*8 + 3*8 + 5*8 + 6*4,
    'SFrame_function': 3*8 + 2*8,
    'SFrame_context': 5*8 + 2*8,
    'SFrame_FDE_symbol_array': 8,
}
for name, bound in layout_sums.items():
    assert bound <= raw[name][1], (name, bound)

chunk = 4064
alignment_mask = 15
frchains_space = 32+chain_count*(raw['frchain'][1]+alignment_mask)
assert frchains_space == 2723 and frchains_space < chunk
partial = (chain_count+1)*ptr
overhead = partial+alignment_mask+(partial >> 3)+100
assert partial == 112 and overhead == 241
argc, output_path_bytes = 5, len('main.o')+1
q = max(281*ptr, ptr*(argc+1), output_path_bytes)
assert argc < 2**31-1 and q == 2248

result = {
    'scope': 'Selected GAS common backing and frame requests; fixed startup/BFD inventory remains open',
    'source_files_verified': len(sources),
    'selected_LP64_raw_request_ceilings': {
        name: {'count_upper': count, 'bytes_per_request_upper': size}
        for name, (count, size) in raw.items()
    },
    'frchains_initial_chunk_bytes': chunk,
    'frchains_space_with_alignment_upper': frchains_space,
    'frchains_extra_chunks': 0,
    'conditional_directive_initial_chunk_bytes': chunk,
    'conditional_directive_objects': 0,
    'notes_existing_prefix_at_growth_entry_upper': partial,
    'notes_raw_request_contract': 'Q=max(2248,8*(A+1),P,H)',
    'notes_chunk_contract': 'max(4064,Q+241)<=PTRDIFF_MAX; 0<=A<INT_MAX',
    'descriptor_example_inputs': {'argc': argc, 'output_path_bytes_including_NUL': output_path_bytes},
    'descriptor_example_notes_Q': 'max(2248,H)',
    'hash_request_input_H_bounded_by_this_checker': False,
    'production_phase_argument_path_join_complete': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
