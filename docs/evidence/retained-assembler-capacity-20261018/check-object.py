#!/usr/bin/env python3
"""Reconcile selected GAS-to-ELF object layout offline; execute no native tools."""
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
    assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes']
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
        sources[row['path']] = raw.decode()

ranges = {
    'gas/output-file.c': [(34, 54), (70, 107)],
    'bfd/elf.c': [(3535, 3593), (3836, 3884), (4117, 4260),
                  (4527, 4659), (4667, 4793), (6857, 6920),
                  (7008, 7084), (7122, 7298), (7349, 7402),
                  (8723, 8784), (8804, 8850), (9052, 9083),
                  (13485, 13527)],
    'bfd/elfcode.h': [(129, 136), (930, 1083), (1101, 1167), (2053, 2070)],
    'bfd/elf64-x86-64.c': [(6154, 6163), (6348, 6420)],
    'bfd/elfxx-target.h': [(431, 437), (509, 514)],
    'bfd/elf-bfd.h': [(598, 602)],
    'include/elf/external.h': [(69, 84), (124, 136), (163, 171), (222, 227)],
    'include/elf/internal.h': [(100, 120)],
}
excerpts = ['# Selected ELF object writer excerpts\n\nLiteral LF numbering.\n']
for name, spans in ranges.items():
    lines = sources[name].split('\n')
    for low, high in spans:
        assert 1 <= low <= high <= len(lines)
        excerpts.append(f'\n## {name}:{low}–{high}\n\n```text\n')
        excerpts.extend(f'{n}: {lines[n-1].expandtabs(8)}\n' for n in range(low, high+1))
        excerpts.append('```\n')
excerpts = ''.join(excerpts)
if args.record_excerpts:
    (root / 'object-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'object-source-excerpts.md').read_text() == excerpts

external = sources['include/elf/external.h']
sizes = {}
for kind in ['Ehdr', 'Shdr', 'Sym', 'Rela']:
    body = external.split('} Elf64_External_' + kind + ';', 1)[0].rsplit('typedef struct {', 1)[1]
    sizes[kind] = sum(map(int, re.findall(r'unsigned char\s+\w+\[(\d+)\]', body)))
assert sizes == {'Ehdr': 64, 'Shdr': 64, 'Sym': 24, 'Rela': 24}
elf = sources['bfd/elf.c']
code = sources['bfd/elfcode.h']
for fragment in ['section_number = 1;', 'if (section_number >= SHN_LORESERVE)',
                 'i_ehdrp->e_type = ET_REL;', 'i_ehdrp->e_phnum = 0;',
                 'if (abfd->output_has_begun)\n    return true;',
                 'new_syms[i] = sym;', 'sym->udata.i = i + 1;',
                 'symtab_hdr->sh_size = symtab_hdr->sh_entsize * (symcount + 1);',
                 'off += i_ehdrp->e_shnum * i_ehdrp->e_shentsize;']:
    assert fragment in elf, fragment
assert '#define LOG_FILE_ALIGN\t3' in code
assert 'rela_hdr->sh_size = rela_hdr->sh_entsize * sec->reloc_count;' in code
assert 'bfd_set_format (stdoutput, bfd_object);' in sources['gas/output-file.c']
assert 'struct bfd_symbol' not in elf[elf.index('elf_map_symbols ('):elf.index('/* Assign a file position')]
for name in ['elf_backend_begin_write_processing', 'elf_backend_section_processing',
             'elf_backend_final_write_processing', 'elf_backend_name_local_section_symbols']:
    assert not re.search(r'^#define\s+' + name + r'\b', sources['bfd/elf64-x86-64.c'], re.M)

# These inputs are source-derived in retained-assembler-capacity.md. Read the
# companion replay record as a consistency check, not as proof of reachability.
gas = json.loads((root / 'check-results.json').read_text())
unit = gas['selected_unit_emission']
symbols = gas['selected_GAS_symbols_and_fixups']
assert unit['ordinary_GAS_sections'] == 9
assert symbols['GAS_symbol_objects'] == 90
assert symbols['GAS_output_chain_symbols_upper'] == 88
assert symbols['maximum_relocation_pointer_slots'] == 281
ordinary = 9
relocation_sections = ordinary
section_headers = 1+ordinary+relocation_sections+3
symbol_entries = symbols['GAS_output_chain_symbols_upper']+ordinary+1
relocations = 281
symbol_strings = 1+(symbol_entries-1)*26
section_strings = 1+(section_headers-1)*32
padding_events = 24
padding = padding_events*7
ident = 29
payload = 391+ident
file_parts = {
    'ELF_header': sizes['Ehdr'], 'ordinary_payload': payload,
    'symbol_table': symbol_entries*sizes['Sym'],
    'relocations': relocations*sizes['Rela'],
    'symbol_strings': symbol_strings, 'section_strings': section_strings,
    'alignment_padding': padding,
    'section_headers': section_headers*sizes['Shdr'],
}
assert section_headers == 22 and symbol_entries == 98
assert sum(file_parts.values()) == 14352
assert sum(file_parts.values()) < 2**31 and section_headers < 0xff00
assert symbol_strings == 2523 and section_strings == 673
result = {
    'scope': 'Selected null Main ELF object writer; not whole assembler or final link capacity',
    'source_files_verified': len(sources), 'external_ELF64_record_bytes': sizes,
    'ordinary_sections': ordinary, 'relocation_sections_upper': relocation_sections,
    'section_headers_including_null': section_headers, 'program_headers': 0,
    'extended_symbol_index_table': False,
    'outgoing_symbol_entries_including_null': symbol_entries,
    'additional_BFD_symbol_object_constructors_in_mapping': 0,
    'relocations_upper': relocations,
    'symbol_string_table': {'distinct_names_upper': 97, 'name_bytes_excluding_NUL': 25,
                            'unshared_bytes_upper': symbol_strings,
                            'positive_reference_events_upper': 97},
    'section_string_table': {'distinct_names_upper': 21, 'name_bytes_excluding_NUL': 31,
                             'unshared_bytes_upper': section_strings,
                             'positive_reference_events_upper': 42},
    'selected_LP64_individual_metadata_requests_upper': {
        'section_header_pointer_table': 22*8,
        'null_or_relocation_internal_header': 80,
        'relocation_name': 32, 'section_symbol_map': 13*8,
        'reordered_symbol_pointers': 97*8,
        'temporary_internal_symbol_records': 98*40,
        'serialized_symbols': 98*24,
        'serialized_relocations_per_section': 281*24,
        'serialized_section_headers': 22*64,
    },
    'file_alignment_bytes_upper': 8, 'charged_alignment_events': padding_events,
    'selected_ident_bytes': ident, 'object_file_components_upper': file_parts,
    'object_file_bytes_upper': sum(file_parts.values()),
    'whole_BFD_storage_or_final_relocation_reach_established': False,
    'native_tool_executions': 0,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'files': len(sources), 'ELF_sections': section_headers,
                  'symbol_entries': symbol_entries, 'object_bytes': sum(file_parts.values())}))
