"""Reconcile the conditional selected ELF file-position transfer."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'sources.json').read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
target = sources['bfd/elfxx-target.h']
for name, value in [('no_page_alias', '0'), ('section_processing', '0'),
                    ('begin_write_processing', '0'),
                    ('final_write_processing', '_bfd_elf_final_write_processing')]:
    macro = 'elf_backend_' + name
    assert re.search(r'#define\s+' + macro + r'\s+' + value, target)
    assert macro not in sources['bfd/elf64-x86-64.c']
anchors = {
    'bfd/elf.c': [
        'off = bed->s->sizeof_ehdr;',
        'if (phdr_load_seg == NULL)\n    off += actual * bed->s->sizeof_phdr;',
        'if (m == phdr_load_seg)\n\toff += actual * bed->s->sizeof_phdr;',
        'off_adjust = vma_page_aligned_bias (p->p_vaddr, off, align * opb);',
        'adjust = p->p_memsz - p->p_filesz;',
        'off -= off_adjust;',
        'elf_next_file_pos (abfd) = off;',
        'offset = BFD_ALIGN (offset, salign);',
        'if (i_shdrp->sh_type != SHT_NOBITS)\n    offset += i_shdrp->sh_size;',
        'off = _bfd_elf_assign_file_position_for_section (hdr, off, true, 0);',
        '_bfd_elf_assign_file_positions_for_non_load (bfd *abfd)',
        'off += i_ehdrp->e_shnum * i_ehdrp->e_shentsize;',
        '_bfd_elf_final_write_processing (bfd *abfd)',
    ],
    'bfd/elflink.c': [
        '_bfd_elf_assign_file_position_for_section (symtab_hdr, off, true, 0);',
        'file_ptr off = symtab_hdr->sh_offset + symtab_hdr->sh_size;',
        'off = _bfd_elf_assign_file_position_for_section (symtab_shndx_hdr,',
        'off = _bfd_elf_assign_file_position_for_section (symstrtab_hdr,',
    ],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
phases = [
    {'phase': 'initial non-load walk', 'payload_coefficient': 1,
     'alignment_N_coefficient': 2, 'alignment_constant': 0},
    {'phase': 'symbol/index/string tables', 'payload_coefficient': 1,
     'alignment_N_coefficient': 0, 'alignment_constant': 3},
    {'phase': 'pending non-load walk', 'payload_coefficient': 1,
     'alignment_N_coefficient': 1, 'alignment_constant': 0},
    {'phase': 'final section names', 'payload_coefficient': 1,
     'alignment_N_coefficient': 0, 'alignment_constant': 1},
    {'phase': 'section header suffix', 'payload_coefficient': 0,
     'alignment_N_coefficient': 0, 'alignment_constant': 1},
]
assert sum(p['payload_coefficient'] for p in phases) == 4
assert sum(p['alignment_N_coefficient'] for p in phases) == 3
assert sum(p['alignment_constant'] for p in phases) == 5
result = {
    'scope': 'Conditional selected ELF writer file-position arithmetic',
    'source_files_verified': len(sources),
    'load_segments_upper': 'S + 1',
    'incoming_V': 'Retained endpoint envelope after RELRO trial/revert; separate 2*V + A placement-arithmetic condition still required',
    'load_prefix_formula': '(64 + 56*T) + (S + 1)*(V + A)',
    'remaining_writer_phases': phases,
    'formula': 'F = (64 + 56*T) + (S + 1)*(V + A) + 4*Bfile + (3*N + 5)*A + 64*N',
    'arithmetic_sufficient_condition': 'F + A <= INT64_MAX, plus prior unsigned header-product conditions',
    'incoming_Bfile': 'Sum of file-backed section lengths including ldlang padding and hidden tables, bounded over all writer sizing stages',
    'incoming_A_extension': 'Power-of-two byte alignment also bounds every file-backed header effective alignment',
    'selected_extra_page_alias_adjustment': False,
    'generated_payload_alignment_projection_complete': False,
    'concrete_final_file_size_or_relocation_reach_established': False,
    'complete_retained_tool_capacity': False,
    'native_execution': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
    'complete_retained_tool_capacity', 'native_execution']}))
