#!/usr/bin/env python3
"""Read retained assembler ELF startup fields; never execute the assembler."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--installed', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
record = json.loads((root/'installed-defaults.json').read_text())
selected = root.parent/'retained-linker-capacity-20261018/selected-tools.json'
assert sha(selected.read_bytes()) == record['selected_tools_sha256']
assert json.loads(selected.read_text())['as']['resolved_path'] == record['binary_path']
assert sha((root/'installed-default-regions.tar.gz').read_bytes()) == record['archive_sha256']
parts = []
with tarfile.open(root/'installed-default-regions.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['member'] for r in record['regions'])
    for row in record['regions']:
        data = archive.extractfile(row['member']).read()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
        parts.append((row['file_offset'], data))

def read(offset, length):
    for start, data in parts:
        if start <= offset and offset+length <= start+len(data):
            return data[offset-start:offset-start+length]
    raise AssertionError((offset, length))

header = read(0, 64)
assert header[:6] == b'\x7fELF\x02\x01'
shoff = struct.unpack_from('<Q', header, 40)[0]
shsize, shcount = struct.unpack_from('<HH', header, 58)
assert shsize == 64 and shcount != 0
sections = [struct.unpack('<IIQQQQIIQQ', read(shoff+64*i, 64)) for i in range(shcount)]
fields = []
for si, section in enumerate(sections):
    if section[1] != 2:
        continue
    assert section[9] == 24 and section[5] % 24 == 0
    string_section = sections[section[6]]
    names = read(string_section[4], string_section[5])
    symbols = read(section[4], section[5])
    for index in range(section[5]//24):
        name_offset, info, other, shindex, value, size = struct.unpack_from('<IBBHQQ', symbols, 24*index)
        name = names[name_offset:names.index(0, name_offset)].decode()
        if name not in ('flag_gen_sframe', 'cfi_sections', 'all_cfi_sections'):
            continue
        assert info & 15 == 1 and size == 4
        containing = sections[shindex]
        assert containing[3] <= value and value+size <= containing[3]+containing[5]
        offset = None if containing[1] == 8 else containing[4]+value-containing[3]
        data = bytes(size) if offset is None else read(offset, size)
        fields.append({'name': name, 'symbol_table_index': si, 'symbol_index': index,
                       'section_index': shindex, 'section_type': containing[1],
                       'symbol_value': value, 'symbol_bytes': size, 'file_offset': offset,
                       'initial_bytes_hex': data.hex()})
assert fields == record['fields']
values = {r['name']: int.from_bytes(bytes.fromhex(r['initial_bytes_hex']), 'little') for r in fields}
assert values == {'cfi_sections': 1, 'flag_gen_sframe': 0, 'all_cfi_sections': 0}

manifest = json.loads((root/'source-manifest.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
sources = {}
with tarfile.open(root/'sources.tar.gz') as archive:
    for row in manifest['files']:
        data = archive.extractfile(row['path']).read()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
        sources[row['path']] = data.decode()
enum = sources['gas/as.h'].split('enum gen_sframe_option', 1)[1].split('};', 1)[0]
positions = [enum.index(x) for x in ['GEN_SFRAME_DEFAULT_NONE', 'GEN_SFRAME_CONFIG_ENABLED',
                                     'GEN_SFRAME_DISABLED', 'GEN_SFRAME_ENABLED']]
assert positions == sorted(positions)
assert all('=' not in line for line in enum.split('\n') if line.lstrip().startswith('GEN_'))
cfi = sources['gas/dw2gencfi.c']
for fragment in ['static int cfi_sections = CFI_EMIT_eh_frame;',
                 'int all_cfi_sections = 0;', 'all_cfi_sections |= cfi_sections;',
                 'flag_gen_sframe == GEN_SFRAME_ENABLED',
                 'flag_gen_sframe == GEN_SFRAME_CONFIG_ENABLED',
                 '(all_cfi_sections & CFI_EMIT_sframe) != 0']:
    assert fragment in cfi
assert '#define CFI_EMIT_eh_frame               (1 << 0)' in sources['gas/dw2gencfi.h']
assert '#define CFI_EMIT_sframe                 (1 << 4)' in sources['gas/dw2gencfi.h']

if args.installed:
    data = Path(record['binary_path']).read_bytes()
    assert len(data) == record['binary_bytes'] and sha(data) == record['binary_sha256']
    for start, retained in parts:
        assert data[start:start+len(retained)] == retained

# Caller premises: selected argv does not enable gsframe, and the derived
# null-unit stream has no .cfi_sections directive requesting .sframe.
flag = values['flag_gen_sframe']
all_sections_after_start = values['all_cfi_sections'] | values['cfi_sections']
sframe_gate = flag in (1, 3) or (bool(all_sections_after_start & (1 << 4)) and flag != 2)
assert not sframe_gate
result = {
    'scope': 'Selected assembler startup defaults plus explicit null-stream/argv premises',
    'binary_sha256': record['binary_sha256'],
    'source_files_verified': len(sources), 'initial_field_values': values,
    'selected_null_after_CFI_start_sections': all_sections_after_start,
    'selected_SFrame_gate': sframe_gate,
    'caller_premises': ['No --gsframe/--gsframe-3 enabling argument',
                       'No .cfi_sections requesting .sframe in selected emitted stream'],
    'whole_link_SFrame_excluded': False,
    'installed_binary_rechecked': args.installed, 'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
