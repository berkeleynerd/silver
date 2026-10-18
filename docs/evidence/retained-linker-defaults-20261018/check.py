"""Replay selected linker defaults and input exclusions without native execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = json.loads((root / 'sources.json').read_bytes())
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
records = {}
for row in json.loads((root / 'inputs.json').read_bytes()):
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    records[row['key']] = json.loads(raw) if row['path'].endswith('.json') else raw.decode()

capture = records['capture/result.json']
assert capture['argv'][1:] == ['--help']
assert capture['returncode'] == 0 and capture['executable_unchanged']
assert sha(Path(capture['argv'][0]).read_bytes()) == capture['executable_sha256']
assert records['capture/stderr'] == ''
assert re.search(r'--compress-debug-sections=\[.*\]\n\s*Compress DWARF debug sections\n\s*Default: none\n', records['capture/stdout'])
assert re.search(r'-z noseparate-code[^\n]*\(default\)', records['capture/stdout'])
argv = records['inventory']['collect2_argv']
assert not any('compress-debug-sections' in x or 'pack-relative-relocs' == x
               or 'enable-linker-version' in x or x == 'separate-code' for x in argv)
anchors = {
    'ld/lexsup.c': ['bfd_get_compression_algorithm_name (config.compress_debug)',
                   'enable_linker_version = true;'],
    'ld/ldmain.c': ['ld_config_type config;', 'struct bfd_link_info link_info;',
                   'config.compress_debug = DEFAULT_COMPRESSED_DEBUG_ALGORITHM;',
                   'switch (config.compress_debug)', 'flags = BFD_COMPRESS;',
                   'ldctor_add_set_entry (h, reloc, NULL, section, value);'],
    'ld/emulparams/dt-relr.sh': ['link_info.enable_dt_relr = true;',
                               'strcmp (optarg, "pack-relative-relocs") == 0'],
    'bfd/elfxx-x86.c': ['if (!info->enable_dt_relr)\n    return true;'],
    'bfd/elflink.c': ['stabstr = bfd_get_section_by_name (abfd, ".stabstr");',
                     'if (stabstr != NULL)', 'flags = BSF_NO_FLAGS;',
                     'flags = BSF_GLOBAL;', 'flags = BSF_WEAK;',
                     'flags = BSF_GNU_UNIQUE;'],
    'bfd/linker.c': ['if (collect && name[0] == \'_\')',
                    'else if ((flags & BSF_CONSTRUCTOR) != 0)'],
    'bfd/elfxx-target.h': ['#define elf_backend_collect false'],
    'ld/ldlang.c': ['bool enable_linker_version = false;',
                   'if (! enable_linker_version)\n    return;'],
    'ld/ldctor.c': ['struct set_info *sets;',
                   'for (p = sets; p != NULL; p = p->next)'],
}
for path, strings in anchors.items():
    for s in strings:
        assert s in sources[path], (path, s)
assert 'BSF_CONSTRUCTOR' not in sources['bfd/elflink.c']
assert not re.search(r'#\s*define\s+elf_backend_collect\b', sources['bfd/elf64-x86-64.c'])
script = re.sub(r'/\*.*?\*/', '', records['script'], flags=re.S)
assert not re.search(r'\b(?:BYTE|SHORT|LONG|QUAD|SQUAD|FILL)\s*\(', script)
assert script.count('LINKER_VERSION') == 1
assert script.count('CONSTRUCTORS') == 1


def section_names(raw, expected):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    offset = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, names = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64
    zero = struct.unpack_from('<IIQQQQIIQQ', raw, offset)
    count = count or zero[5]
    names = zero[6] if names == 0xffff else names
    assert count == expected and offset + 64 * count <= len(raw)
    headers = [struct.unpack_from('<IIQQQQIIQQ', raw, offset + 64 * i)
               for i in range(count)]
    h = headers[names]
    assert h[4] + h[5] <= len(raw)
    strings = raw[h[4]:h[4] + h[5]]
    result = []
    for h in headers:
        assert h[0] < len(strings)
        result.append(strings[h[0]:strings.index(0, h[0])].decode())
        assert not h[2] & 0x800  # SHF_COMPRESSED
    assert not any(n.startswith(('.stab', '.zdebug')) for n in result)
    return result


files = members = objects = headers = 0
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
            expected = member['sections']
            members += 1
        else:
            data, expected = raw, f['elf']['sections']
        names = section_names(data, expected)
        objects += 1
        headers += len(names)
binder = records['binder']
case = binder['selected_binder_object_transfer']['full_inventory_equal_to_case']
# The accepted source transfer supplies this inventory, not a new measured
# generated object. Main's emission argument has only ordinary ELF/CFI data.
binder_sections = binder['cases'][case]['object']['sections']
assert not any(s['name'].startswith(('.stab', '.zdebug')) for s in binder_sections)
assert not any(s['flags'] & 0x800 for s in binder_sections)
result = {
    'scope': 'Selected linker payload exclusions, conditional on accepted Main/binder emission transfers',
    'source_files_verified': len(sources),
    'installed_fixed_files_verified': files,
    'installed_archive_members_verified': members,
    'unweighted_fixed_ELF_objects': objects,
    'unweighted_fixed_headers': headers,
    'compression_default': 'none',
    'selected_compression': False,
    'selected_packed_relative_relocations': False,
    'selected_link_info_separate_code': False,
    'fixed_STABS_or_compressed_sections': 0,
    'generated_STABS_or_compressed_sections': 0,
    'script_explicit_data_constructors': 0,
    'LINKER_VERSION_emitted_bytes': 0,
    'legacy_constructor_set_emitted_bytes': 0,
    'source_identity_premise': 'Retained release sources describe selected executable behavior; no historical build attestation',
    'capture_managed_run': '20261018T112705-2e2b04d26400',
    'capture_native_seconds': capture['duration_seconds'],
    'replay_native_execution': False,
    'whole_link_capacity_established': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
