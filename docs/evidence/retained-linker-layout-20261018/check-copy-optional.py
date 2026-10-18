"""Replay retained copy-storage and optional-section source joins offline."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import struct
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--prior-repo', type=Path,
               help='Repository containing the pinned accepted prerequisite records')
p.add_argument('--binder-repo', type=Path,
               help='Optional separate repository containing the binder prerequisite')
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = a.prior_repo or root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
inputs = json.loads((root / 'copy-optional-inputs.json').read_bytes())
records = {}
for row in inputs:
    base = (a.binder_repo or repo) if row['key'] == 'binder' else repo
    raw = (base / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    if row['path'].endswith('.json'):
        records[row['key']] = json.loads(raw)

manifest = json.loads((root / 'sources.json').read_bytes())
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()

for row in json.loads((root / 'copy-optional-source.json').read_bytes())['files']:
    raw = gzip.decompress((root / row['archive']).read_bytes())
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    sources[row['path']] = raw.decode()

gas_manifest = records['gas_manifest']
with tarfile.open(repo / 'docs/evidence/retained-assembler-capacity-20261018/sources.tar.gz') as archive:
    for row in gas_manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        if row['path'] in sources:
            assert sources[row['path']] == raw.decode()
        sources[row['path']] = raw.decode()

anchors = {
    'bfd/elflink.c': [
        'h->size = sym->st_size;', 'h->size = isym->st_size;',
        'h->size = h->root.u.c.size;',
        'if (!_bfd_elf_merge_symbol (abfd, info, shortname, sym,',
        'if (!_bfd_elf_merge_symbol (abfd, info, name, isym,',
        'memset (&ret->size, 0, (sizeof (struct elf_link_hash_entry)',
        'if (h->dynamic_adjusted)', 'h->dynamic_adjusted = 1;',
        'power_of_two = bfd_section_alignment (sec);',
        'dynbss->size = BFD_ALIGN (dynbss->size, mask + 1);',
        'dynbss->size += h->size;',
        'memcpy (h, old_ent, htab->root.table.entsize);',
    ],
    'bfd/elfxx-x86.c': [
        'if (h->is_weakalias)',
        'return _bfd_elf_adjust_dynamic_copy (info, h, s);',
        'bool gen_plt_sframe_p = (_bfd_elf_sframe_present_input_bfds (info)',
        's->size = htab->dynamic_interpreter_size;',
    ],
    'bfd/linker.c': ['struct bfd_link_hash_entry *sub;', '*sub = *h;'],
    'bfd/elf.c': [
        'newsym = (elf_symbol_type *) bfd_zalloc (abfd, sizeof (*newsym));',
        'sym.st_size = type_ptr ? type_ptr->internal_elf_sym.st_size : 0;',
    ],
    'gas/config/obj-elf.c': [
        'S_SET_SIZE (dest, S_GET_SIZE (src));',
        'S_SET_SIZE (symp, size->X_add_number);',
    ],
    'ld/ldelf.c': [
        'const char *ldelf_emit_note_gnu_build_id;',
        'const char *ldelf_emit_note_fdo_package_metadata;',
        'if (ldelf_emit_note_gnu_build_id != NULL',
        'sinterp->size = strlen ((char *) sinterp->contents) + 1;',
    ],
    'ld/emultempl/elf.em': [
        'case OPTION_BUILD_ID:', 'case OPTION_PACKAGE_METADATA:',
        'ldelf_emit_note_gnu_build_id = xstrdup (optarg);',
        'ldelf_emit_note_fdo_package_metadata = package_metadata;',
    ],
    'bfd/elf-sframe.c': [
        'asection *sec = bfd_get_section_by_name (pbfd, ".sframe");',
        'sec = sfe_info->sframe_section;',
        'if (sec == NULL)\n    return true;',
    ],
    'libctf/ctf-open-bfd.c': [
        'if ((ctf_asect = bfd_get_section_by_name (abfd, _CTF_SECTION)) == NULL)',
        'return (ctf_set_open_errno (errp, ECTF_NOCTFDATA));',
    ],
    'libctf/ctf-open.c': ['const char _CTF_SECTION[] = ".ctf";'],
    'ld/ldlang.c': [
        'if (!any_ctf)\n    {\n      ctf_output = NULL;',
        'if (!ctf_output)\n    return;',
    ],
    'bfd/elf-attrs.c': [
        'if (be->translate_gnu_props_to_obj_attrs == NULL)',
        'if (be->translate_obj_attrs_to_gnu_props == NULL)',
        'if (!res.has_object_attributes && frozen_cfg->size == 0)',
    ],
    'bfd/elfxx-target.h': [
        '#define elf_backend_translate_gnu_props_to_obj_attrs\tNULL',
        '#define elf_backend_translate_obj_attrs_to_gnu_props\tNULL',
    ],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)

# These checks make the reviewed assignment/copy census replayable; the
# prose supplies the selected call graph and alias/rollback argument.
elflink = sources['bfd/elflink.c']
assert elflink.count('h->size = sym->st_size;') == 1
assert elflink.count('h->size = isym->st_size;') == 1
assert elflink.count('if (!_bfd_elf_merge_symbol (abfd, info, shortname, sym,') == 2
assert elflink.count('if (!_bfd_elf_merge_symbol (abfd, info, name, isym,') == 1
for name, start, end in [
    ('bfd/elflink.c', '_bfd_elf_link_hash_copy_indirect (', '\nvoid\n'),
    ('bfd/elfxx-x86.c', '_bfd_x86_elf_copy_indirect_symbol (', '\n/* Remove'),
]:
    body = sources[name].split(start, 1)[1].split(end, 1)[0]
    assert '->size' not in body

fixed_record = records['fixed']
fixed = fixed_record['processed_fixed_totals']
assert fixed['common_symbols'] == 0
assert fixed_record['maximum_fixed_section_alignment'] == 64
assert fixed['symbol_size_bytes'] == 8850737
assert fixed['sframe_section_types'] == fixed['sframe_named_sections'] == 0
assert fixed['attributes_section_types'] == fixed['attributes_named_sections'] == 0


def no_optional_sections(raw):
    assert raw[:6] == b'\x7fELF\x02\x01'
    offset = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, string_index = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64 and 0 < count < 0xff00 and string_index < count
    headers = [struct.unpack_from('<IIQQQQIIQQ', raw, offset + i * stride)
               for i in range(count)]
    h = headers[string_index]
    strings = raw[h[4]:h[4] + h[5]]
    for h in headers:
        name = strings[h[0]:strings.index(0, h[0])]
        assert name not in (b'.ctf', b'.sframe', b'.gnu.attributes'), name
        assert h[1] != 0x6ffffff5  # SHT_GNU_ATTRIBUTES


# Zero bytes alone would not exclude an empty .ctf input. Check names too.
fixed_files = fixed_members = 0
for f in records['inventory']['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    fixed_files += 1
    if f['kind'] == 'script':
        continue
    for member in f.get('members', [f]):
        if f['kind'] == 'archive':
            start = member['header_offset'] + 60
            data = raw[start:start + member['bytes']]
            assert len(data) == member['bytes'] and sha(data) == member['sha256']
            fixed_members += 1
        else:
            data = raw
        no_optional_sections(data)

binder = records['binder']['selected_binder_object_transfer']['object_summary']
assert binder['common_symbol_count'] == 0
assert binder['maximum_section_alignment'] == 32
assert binder['symbol_st_size_sum'] == 11766
assert binder['sframe_bytes'] == binder['sframe_section_count'] == 0
for section in records['binder']['cases']['indexed-cr']['object']['sections']:
    assert section['name'] not in ('.ctf', '.sframe', '.gnu.attributes')
    assert section['type'] != 0x6ffffff5
assert records['defaults']['selected_SFrame_gate'] is False
obj = records['object']
function_bytes = records['assembler']['selected_instructions']['encoded_function_bytes']
assert function_bytes == 26
main_size_sum = obj['outgoing_symbol_entries_including_null'] * function_bytes
assert main_size_sum == 2548
assert obj['file_alignment_bytes_upper'] == 8
size_sum = fixed['symbol_size_bytes'] + main_size_sum + binder['symbol_st_size_sum']
assert size_sum == 8865051

argv = records['inventory']['collect2_argv']
assert not any(x.startswith(('--build-id', '--package-metadata')) for x in argv)
assert argv.count('-dynamic-linker') == 1
interpreter = argv[argv.index('-dynamic-linker') + 1]
assert interpreter == '/lib64/ld-linux-x86-64.so.2'
interpreter_bytes = len(interpreter.encode()) + 1
assert interpreter_bytes == 28

result = {
    'scope': 'Selected copy-storage and optional-section payload joins; not whole-link capacity',
    'source_files_verified': len(sources),
    'pinned_prerequisite_records_and_archives_verified': len(inputs),
    'installed_fixed_files_verified': fixed_files,
    'installed_archive_members_verified': fixed_members,
    'fixed_symbol_st_size_sum': fixed['symbol_size_bytes'],
    'Main_symbol_st_size_sum_upper': main_size_sum,
    'binder_symbol_st_size_sum': binder['symbol_st_size_sum'],
    'input_symbol_st_size_sum_upper': size_sum,
    'positive_size_assignment_charge_per_input_record': 4,
    'maximum_copy_definition_alignment': 64,
    'copy_payload_formula': 'Copy <= 35460204 + 63 H',
    'H_requirement': 'Upper bound on processed global ELF hash entries',
    'copy_relocation_bytes_separate': '24 H',
    'copy_payload_charged_in_full_to_B_and_Bfile': True,
    'interpreter_payload_bytes_upper': interpreter_bytes,
    'interpreter_alignment': 1,
    'new_build_id_payload_bytes': 0,
    'new_package_metadata_payload_bytes': 0,
    'fixed_input_notes_retained_in_original_payload': True,
    'SFrame_input_and_synthetic_payload_bytes': 0,
    'SFrame_encoder_backing_allocation_requests': 0,
    'CTF_output_payload_bytes': 0,
    'object_attribute_output_payload_bytes': 0,
    'CTF_initialization_and_empty_attribute_bookkeeping_not_excluded': True,
    'empty_script_output_section_declarations_excluded_from_zero_claim': True,
    'whole_link_capacity_or_relocation_legality_established': False,
    'generated_objects_read': False,
    'native_tool_executions': 0,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
    'input_symbol_st_size_sum_upper', 'copy_payload_formula',
    'interpreter_payload_bytes_upper', 'SFrame_input_and_synthetic_payload_bytes']}))
