"""Reconcile selected ELF section shape, alignment and mapping transfers offline."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--prior-repo', type=Path)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = a.prior_repo or root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
records = {}
for row in json.loads((root / 'layout-shape-inputs.json').read_bytes()):
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    records[row['key']] = json.loads(raw) if row['path'].endswith('.json') else raw.decode()
sources = {}
for manifest_file, archive_file in [('sources.json', 'sources.tar.gz'),
                                    ('layout-shape-sources.json', 'layout-shape-sources.tar.gz')]:
    manifest = json.loads((root / manifest_file).read_bytes())
    assert sha((root / archive_file).read_bytes()) == manifest['archive_sha256']
    with tarfile.open(root / archive_file) as t:
        for row in manifest['files']:
            raw = t.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            sources[row['path']] = raw.decode()

assert records['defaults']['selected_link_info_separate_code'] is False
assert records['defaults']['selected_packed_relative_relocations'] is False
assert records['defaults']['selected_compression'] is False
assert records['copy']['SFrame_input_and_synthetic_payload_bytes'] == 0
assert records['copy']['object_attribute_output_payload_bytes'] == 0
assert records['copy']['maximum_copy_definition_alignment'] == 64
argv = records['inventory']['collect2_argv']
assert not any(x in argv for x in ['-T', '--script', '--section-start', '--unique'])
assert not any(x.startswith(('max-page-size=', 'common-page-size=')) for x in argv)
script = records['script']
assert 'SUBALIGN' not in script and 'PHDRS' not in script and 'MEMORY' not in script
assert not re.search(r'\bAT\s*\(', script)
assert '. = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));' in script
assert '. = ALIGN(ALIGNOF(NEXT_SECTION));' in script
assert 'DATA_SEGMENT_RELRO_END (SIZEOF (.got.plt) >= 24 ? 24 : 0, .)' in script
assert script.count('ALIGN(CONSTANT (MAXPAGESIZE)) + (. & (CONSTANT (MAXPAGESIZE) - 1))') == 2

# Shell emulation parameters select config.separate_code separately from
# link_info.separate_code. Neither the selected script generator nor any
# selected source_sh dependency assigns the former's enabling variable.
params = sources['ld/emulparams/elf_x86_64.sh']
deps = ['ld/' + x for x in re.findall(r'source_sh \$\{srcdir\}/([^\n]+)', params)]
assert len(deps) == 14
for path in ['ld/genscripts.sh', 'ld/emulparams/elf_x86_64.sh'] + deps:
    assert 'SEPARATE_CODE' not in sources[path], path
for path in deps:
    assert 'source_sh' not in sources[path], path

allocated_names = {}
fixed_link_order = fixed_mbind = fixed_large = 0
maximum_alignment = maximum_eh_alignment = 1
files = members = objects = 0
for f in records['inventory']['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    files += 1
    if f['kind'] == 'script':
        continue
    for member in f.get('members', [f]):
        if f['kind'] == 'archive':
            start = member['header_offset'] + 60
            data = raw[start:start + member['bytes']]
            assert len(data) == member['bytes'] and sha(data) == member['sha256']
            members += 1
        else:
            data = raw
        assert data[:6] == b'\x7fELF\x02\x01'
        elf_type = struct.unpack_from('<H', data, 16)[0]
        offset = struct.unpack_from('<Q', data, 40)[0]
        stride, count, string_index = struct.unpack_from('<HHH', data, 58)
        assert stride == 64 and 0 < count < 0xff00 and string_index < count
        headers = [struct.unpack_from('<IIQQQQIIQQ', data, offset + 64*i)
                   for i in range(count)]
        shstr = headers[string_index]
        strings = data[shstr[4]:shstr[4] + shstr[5]]
        for h in headers:
            name = strings[h[0]:strings.index(0, h[0])].decode()
            fixed_link_order += bool(h[2] & 0x80)
            fixed_mbind += bool(h[2] & 0x1000000)
            fixed_large += bool(h[2] & 0x10000000)
            maximum_alignment = max(maximum_alignment, h[8])
            if name == '.eh_frame':
                maximum_eh_alignment = max(maximum_eh_alignment, h[8])
            if elf_type == 1 and h[2] & 2:
                row = allocated_names.setdefault(name, {'occurrences': 0, 'bytes': 0,
                                                       'types_flags': set(), 'alignments': set()})
                row['occurrences'] += 1
                row['bytes'] += h[5]
                row['types_flags'].add((h[1], h[2]))
                row['alignments'].add(h[8])
        objects += 1
assert fixed_link_order == fixed_mbind == fixed_large == 0
assert len(allocated_names) == 45
assert maximum_alignment == 64 and maximum_eh_alignment == 8
assert allocated_names['.tm_clone_table']['bytes'] == 0

def group(name):
    # These are the relevant selected script wildcards, in their order.
    for prefix, output in [('.text', '.text'), ('.rodata', '.rodata'),
                           ('.data.rel.ro', '.data.rel.ro'), ('.data', '.data'),
                           ('.init_array', '.init_array'), ('.fini_array', '.fini_array')]:
        if name == prefix or name.startswith(prefix + '.'):
            return output
    assert name in {'.bss', '.eh_frame', '.fini', '.gcc_except_table', '.init',
                    '.note.ABI-tag', '.note.gnu.property', '.tbss', '.tm_clone_table'}, name
    return name

groups = sorted(set(map(group, allocated_names)))
assert len(groups) == 15
notes = {n for n in allocated_names if n.startswith('.note')}
assert notes == {'.note.ABI-tag', '.note.gnu.property'}
binder_sections = records['binder']['cases']['indexed-cr']['object']['sections']
assert max(sec['alignment'] for sec in binder_sections) == 32
assert max(sec['alignment'] for sec in binder_sections if sec['name'] == '.eh_frame') == 8
for sec in binder_sections:
    assert sec['flags'] & (0x80 | 0x1000000 | 0x10000000) == 0
    if sec['flags'] & 2:
        group(sec['name'])

anchors = {
    'bfd/elfcode.h': ['#define LOG_FILE_ALIGN\t3'],
    'bfd/elf64-x86-64.c': ['#define ELF_MAXPAGESIZE\t\t\t    0x1000',
                          '#define elf_backend_plt_alignment\t    4'],
    'bfd/elfxx-x86.c': ['got_align = (bed->target_id == X86_64_ELF_DATA) ? 3 : 2;',
        'plt_alignment = bfd_log2 (htab->plt.plt_entry_size);',
        '*again = false;', 'if (!info->enable_dt_relr)\n    return true;'],
    'bfd/elf.c': ['segs = 2;', 'if ((this_hdr->sh_flags & SHF_LINK_ORDER) != 0)',
                 'elf_program_header_size (abfd) = count * bed->s->sizeof_phdr;'],
    'bfd/elfxx-target.h': ['#define elf_backend_modify_segment_map\t0'],
    'bfd/elflink.c': ['s = bfd_make_section_anyway_with_flags (abfd, ".dynamic", flags);',
                     'if (!_bfd_elf_add_dynamic_entry (info, DT_NULL, 0))'],
    'gas/write.c': ['sec = subseg_new (GNU_BUILD_ATTRS_SECTION_NAME, false);',
                   'bfd_set_section_flags (sec, (SEC_READONLY | SEC_HAS_CONTENTS | SEC_DATA\n\t\t\t       | SEC_OCTETS));'],
    'ld/ldlang.c': ['if (section->alignment_power > output->bfd_section->alignment_power)',
                   'if (o->alignment_power < i->alignment_power)',
                   'return cur->region != prev->region;',
                   'one_lang_size_sections_pass (relax, check_regions);'],
    'ld/ldelfgen.c': ['int tries = 10;', 'while (need_layout && --tries);',
        'if (os_info != NULL && os_info->ordered != 0)',
        'if (phdr_size != elf_program_header_size (link_info.output_bfd))'],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
assert not re.search(r'^#define\s+elf_backend_modify_segment_map\b',
                     sources['bfd/elf64-x86-64.c'], re.M)
for n, row in allocated_names.items():
    row['types_flags'] = sorted(map(list, row['types_flags']))
    row['alignments'] = sorted(row['alignments'])
    row['script_output_or_orphan'] = group(n)

result = {
    'scope': 'Selected section shape, alignment and program-header mapping convergence',
    'source_files_verified': len(sources),
    'installed_fixed_files_verified': files,
    'installed_archive_members_verified': members,
    'fixed_ELF_objects_verified': objects,
    'fixed_SHF_LINK_ORDER_sections': fixed_link_order,
    'fixed_SHF_GNU_MBIND_sections': fixed_mbind,
    'fixed_SHF_X86_64_LARGE_sections': fixed_large,
    'fixed_ET_REL_allocated_section_names': allocated_names,
    'fixed_script_output_or_orphan_families': groups,
    'fixed_EH_alignment_upper': maximum_eh_alignment,
    'selected_non_page_section_alignment_upper': 64,
    'selected_page_and_general_layout_alignment_upper': 4096,
    'selected_EH_alignment_upper': 8,
    'selected_link_order_reordering_requests': 0,
    'selected_RELR_relaxation_layout_changes': 0,
    'selected_config_separate_code': False,
    'selected_link_info_separate_code': False,
    'selected_PT_LOAD_segments': 2,
    'selected_program_headers_upper': 12,
    'selected_ELF_and_program_header_prefix_upper': 736,
    'selected_segment_mapping_iterations_upper': 2,
    'mapping_convergence_established': True,
    'mapping_convergence_premises': ['accepted generated emission and fixed-input family',
                                   'selected default script/options and source behavior',
                                   'prior nonwrapping virtual-address arithmetic'],
    'whole_link_capacity_or_relocation_legality_established': False,
    'native_tool_executions': 0,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
    'selected_non_page_section_alignment_upper', 'selected_EH_alignment_upper',
    'mapping_convergence_established']}))
