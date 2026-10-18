"""Join fixed/Main/PLT EH byte and entry transfers; retain binder terms."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = json.loads((root / 'sources.json').read_text())
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
extra = json.loads((root / 'transformation-source.json').read_text())
raw = gzip.decompress((root / extra['archive']).read_bytes())
assert len(raw) == extra['bytes'] and sha(raw) == extra['sha256']
sources[extra['path']] = raw.decode()
inputs = json.loads((root / 'transformation-inputs.json').read_text())
for row in inputs:
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
fixed = json.loads((repo / inputs[0]['path']).read_text())['totals_with_explicit_archive_occurrences']
assembler = json.loads((repo / inputs[2]['path']).read_text())
cfi = assembler['selected_cfi']
assert (fixed['sections'], fixed['bytes'], fixed['entries'], fixed['FDEs']) == (1175, 551576, 16297, 14948)
assert (cfi['eh_frame_contribution_bytes'], cfi['FDE_objects']) == (92, 1)
assert re.search(r'#define\s+PLT_CIE_LENGTH\s+20\b', sources[extra['path']])
assert re.search(r'#define\s+PLT_FDE_LENGTH\s+36\b', sources[extra['path']])
assert re.search(r'#define\s+PLT_FDE_LEN_OFFSET\s+4 \+ PLT_CIE_LENGTH \+ 12', sources[extra['path']])
arrays = {}
for name, body in re.findall(r'static const bfd_byte (elf_x86_64_eh_frame_\w+)\[\]\s*=\s*\{(.*?)\};', sources['bfd/elf64-x86-64.c'], re.S):
    body = re.sub(r'/\*.*?\*/', '', body, flags=re.S)
    body = re.sub(r'^\s*#define[^\n]*', '', body, flags=re.M)
    tokens = [t.strip() for t in body.split(',') if t.strip()]
    assert tokens[:9] == ['PLT_CIE_LENGTH', '0', '0', '0', '0', '0', '0', '0', '1']
    assert tokens[9:17] == ["'z'", "'R'", '0', '1', '0x78', '16', '1', 'DW_EH_PE_pcrel | DW_EH_PE_sdata4']
    assert tokens[24] in ('PLT_FDE_LENGTH', 'PLT_GOT_FDE_LENGTH')
    expected = 48 if name.endswith('non_lazy_plt') else 64
    assert len(tokens) == expected
    arrays[name] = expected
assert len(arrays) == 5
for anchor in ['htab->plt_eh_frame->size = htab->plt.eh_frame_plt_size;',
               'htab->plt_got_eh_frame->size\n\t  = htab->non_lazy_plt->eh_frame_plt_size;',
               'htab->plt_second_eh_frame->size\n\t  = htab->non_lazy_plt->eh_frame_plt_size;',
               'bfd_put_32 (dynobj, htab->elf.splt->size,']:
    assert anchor in sources['bfd/elfxx-x86.c'], anchor
synthetic_bytes, synthetic_entries, synthetic_sections, synthetic_fdes = 64 + 48 + 48, 6, 3, 3
Main_entries = cfi['eh_frame_contribution_bytes'] // 4  # Includes any terminator.
N = fixed['sections'] + 1 + synthetic_sections
E = fixed['entries'] + Main_entries + synthetic_entries
B = fixed['bytes'] + cfi['eh_frame_contribution_bytes'] + synthetic_bytes
F = fixed['FDEs'] + cfi['FDE_objects'] + synthetic_fdes
constant = B + 11 * E + 2 * N
assert (constant, N, F) == (733772, 1179, 14952)
assert constant + 8 * N == 743204
assert 12 + 8 * F == 119628
result = {
    'scope': 'Fixed/Main/PLT EH payload/header join, conditional on binder and valid frame contents',
    'source_files_verified': len(sources), 'prior_inputs_verified': len(inputs),
    'PLT_template_bytes': arrays,
    'synthetic_PLT_EH': {'sections_upper': synthetic_sections,
                         'original_bytes_upper': synthetic_bytes,
                         'entries_upper': synthetic_entries, 'FDEs_upper': synthetic_fdes,
                         'input_alignment_bytes': 8},
    'Main_original_bytes_upper': 92, 'Main_entries_upper': Main_entries,
    'Main_FDEs_upper': 1,
    'nonbinder_original_bytes_upper': B,
    'nonbinder_entries_upper': E, 'nonbinder_sections_upper': N,
    'edited_payload_formula': 'EHedited <= 733772 + 1179*Aeh + Bbinder_EH + 11*Ebinder_EH + (Aeh+2)*Nbinder_EH',
    'nonbinder_edited_payload_if_Aeh_8': 743204,
    'FDE_count_formula': 'F <= 14952 + Fbinder_EH',
    'header_bytes_formula': 'EHheader <= 119628 + 8*Fbinder_EH',
    'header_search_array_bytes_formula': '24*(14952 + Fbinder_EH)',
    'alignment_condition': 'Aeh is power of two, <=2^30, bounds all output EH alignment',
    'each_input_editing_condition': 'B + 11*E + Aeh + 2 <= UINT32_MAX',
    'FDE_count_condition': '14952 + Fbinder_EH <= 536870911',
    'PLT_FDE_range_encoding_condition': 'Each emitted PLT byte size <= UINT32_MAX; relative-address reach separate',
    'generated_binder_CFA_semantics_relocations_or_whole_link_established': False,
    'native_execution': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified', 'prior_inputs_verified',
      'nonbinder_edited_payload_if_Aeh_8', 'FDE_count_formula']}))
