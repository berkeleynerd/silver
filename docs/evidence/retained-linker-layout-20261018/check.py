"""Offline identity/arithmetic replay for selected ELF section/header bounds."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = json.loads((root / 'sources.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
    for row in manifest['files']:
        data = archive.extractfile(row['path']).read()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
        sources[row['path']] = data.decode()
inputs = json.loads((root / 'inputs.json').read_text())
for row in inputs:
    data = (repo / row['path']).read_bytes()
    assert len(data) == row['bytes'] and sha(data) == row['sha256']

# These anchors pin the reviewed control flow; they are not a C proof.
anchors = {
    'bfd/elflink.c': [
        'if (htab->sgot != NULL)',
        'if (htab->dynamic_sections_created)',
        'elf_section_data (sec)->sreloc = reloc_sec;',
        '|| (o->flags & SEC_RELOC) == 0',
        '|| o->reloc_count == 0',
        'bfd_get_section_by_name (abfd, ".tcommon")',
    ],
    'bfd/elfxx-x86.c': ['_bfd_elf_make_dynamic_reloc_section',
                        '".plt.got"', '".plt.sec"', '".rela.tls"'],
    'bfd/elf64-x86-64.c': ['"LARGE_COMMON"', '"COMMON"',
                          'elf_x86_64_additional_program_headers'],
    'bfd/section.c': ['/* Section already exists.  */'],
    'ld/ldlang.c': ['lang_init_start_stop (void)',
                   'lang_init_startof_sizeof (void)',
                   'lang_place_orphans (void)',
                   'bfd_make_section_anyway_with_flags (link_info.output_bfd,'],
    'bfd/elf.c': ['section_number = 1;',
                  'd->this_idx = section_number++;',
                  'd->rel.idx = section_number++;',
                  'd->rela.idx = section_number++;',
                  'entry->ndx = section_number++;',
                  'if (section_number >= SHN_LORESERVE)',
                  'off += i_ehdrp->e_shnum * i_ehdrp->e_shentsize;',
                  'elf_program_header_size (abfd) = count * bed->s->sizeof_phdr;'],
    'bfd/elfcode.h': ['if (i_ehdrp->e_phnum >= PN_XNUM)',
                      'i_shdrp[0]->sh_info = i_ehdrp->e_phnum;',
                      'i_shdrp[0]->sh_size = i_ehdrp->e_shnum;'],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
assert re.search(r'#define\s+SHN_LORESERVE\s+\(-0x100u\)',
                 sources['include/elf/internal.h'])
assert re.search(r'#define\s+ELF_MAXPAGESIZE\s+0x1000',
                 sources['bfd/elf64-x86-64.c'])
assert 'elf_backend_modify_segment_map' not in sources['bfd/elf64-x86-64.c']
assert re.search(r'#define\s+elf_backend_modify_segment_map\s+0',
                 sources['bfd/elfxx-target.h'])
external = sources['include/elf/external.h']
widths = {}
for name in ['Ehdr', 'Shdr', 'Phdr']:
    body = re.search(r'typedef struct\s*\{([^}]+)\}\s*Elf64_External_' + name,
                     external, re.S).group(1)
    widths[name] = sum(map(int, re.findall(r'\[\s*(\d+)\s*\]', body)))
assert widths == {'Ehdr': 64, 'Shdr': 64, 'Phdr': 56}

script_path = 'docs/evidence/retained-link-inputs-20261018/link-script/installed-elf_x86_64.xdc'
script = (repo / script_path).read_text()
stripped = re.sub(r'/\*.*?\*/', '', script, flags=re.S)
declarations = re.findall(r'^\s*(\.[\w.\-]+|/DISCARD/)\s+[^\n{};]*:',
                          stripped, flags=re.M)
assert declarations.count('/DISCARD/') == 1
declarations.remove('/DISCARD/')
assert len(declarations) == 93
assert not re.search(r'\b(?:PHDRS|MEMORY|OVERLAY|INSERT)\b', stripped)

inventory = json.loads((repo / 'docs/evidence/retained-link-inputs-20261018/inventory.json').read_text())
fixed = inventory['summary']
loader = next(f['elf'] for f in inventory['files']
              if f['path'] == '/lib64/ld-linux-x86-64.so.2')
# Eight additional loader processings are the prior selected-input derivation,
# not inferred from this inventory or from a link execution.
Pfixed = fixed['fixed_elf_occurrences'] + 8
Qfixed = fixed['weighted_fixed_sums']['sections'] + 8 * loader['sections']
assert (Pfixed, Qfixed) == (1481, 36433)
main = json.loads((repo / 'docs/evidence/retained-assembler-capacity-20261018/object-check-results.json').read_text())
Qmain = main['section_headers_including_null']
assert Qmain == 22
families = json.loads((root / 'section-families.json').read_text())
C = sum(r['bound'] for r in families['constant_families'])
assert C == 35
assert families['per_input_elf_occurrence']['bound'] == 3
assert families['per_input_header_record']['bound'] == 1
I0 = 2 * (Qfixed + Qmain) + 3 * (Pfixed + 1) + C
S0 = I0 + len(declarations)
assert (I0, S0) == (77391, 77484)
N0 = 3 * S0 + 5
T0 = 3 * S0 + 13
assert N0 == 232457 and T0 == 232465
U32 = (1 << 32) - 1
# Source e_shnum*e_shentsize is unsigned-int arithmetic, before file_ptr add.
Nlimit = U32 // widths['Shdr']
assert Nlimit == 67108863
assert Nlimit < (1 << 32) - 256
assert N0 * 64 == 14877248 and T0 * 56 == 13018040
# Polynomial substitution in the prior dynamic-symbol transfer, not samples.
assert 285 + 2 * 35 + 2 * (35 + 93) == 611
assert 24 + 2 * 2 + 2 * 2 == 32
assert 2 * 3 + 2 * 3 == 12

result = {
    'scope': 'Selected LP64 ELF64 PIE section/header transfer; symbolic binder',
    'source_files_verified': len(sources),
    'prior_input_identities_verified': len(inputs),
    'fixed_processed_ELF_occurrences': Pfixed,
    'fixed_header_record_passes': Qfixed,
    'main_header_records': Qmain,
    'script_output_section_declarations': len(declarations),
    'script_output_section_names': declarations,
    'constant_synthetic_input_section_union': C,
    'formulae': {
        'Q': '36433 + Qmain + Qbinder',
        'P': '1481 + Pmain + Pbinder',
        'input_chains_and_Qin': 'I = 2*Q + 3*P + 35',
        'output_BFD_sections_and_Qout': 'S = I + 93',
        'ELF_section_headers_including_null': 'N <= 3*S + 5',
        'actual_and_reserved_program_headers': 'T <= 3*S + 13',
        'dynamic_symbol_join': 'D <= 611 + 44*R + 32*Q + 12*P + 13*V',
        'Main_substituted_I': '77391 + 2*Qbinder + 3*Pbinder',
        'Main_substituted_S': '77484 + 2*Qbinder + 3*Pbinder',
        'Main_substituted_N': '232457 + 6*Qbinder + 9*Pbinder',
        'Main_substituted_T': '232465 + 6*Qbinder + 9*Pbinder',
    },
    'external_ELF64_record_bytes': widths,
    'section_header_trailer_unsigned_product_count_limit': Nlimit,
    'zero_binder_polynomial_terms_not_complete_program_bounds': {
        'section_header_bytes': N0 * 64,
        'program_header_bytes': T0 * 56,
    },
    'whole_file_virtual_layout_or_relocation_reach_established': False,
    'binder_object_projection_established': False,
    'complete_retained_tool_capacity': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in [
    'source_files_verified', 'prior_input_identities_verified',
    'script_output_section_declarations', 'constant_synthetic_input_section_union',
    'complete_retained_tool_capacity', 'native_execution']}))
