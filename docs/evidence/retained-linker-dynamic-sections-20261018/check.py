#!/usr/bin/env python3
"""Check pinned source identities and local x86 sizing arithmetic offline."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'sources.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sha((root / 'sources.tar.gz').read_bytes()) == manifest['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    assert set(archive.getnames()) == {row['path'] for row in manifest['files']}
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()

generic = sources['bfd/elfxx-x86.c']
target = sources['bfd/elf64-x86-64.c']
header = sources['bfd/elfxx-x86.h']
ifunc = sources['bfd/elf-ifunc.c']
assert 'ret->got_entry_size = 8;' in generic
assert 'ret->sizeof_reloc = sizeof (Elf64_External_Rela);' in generic
assert '#define LAZY_PLT_ENTRY_SIZE 16' in target
assert '#define NON_LAZY_PLT_ENTRY_SIZE 8' in target
for fragment in ('s->size += plt_entry_size;',
                 'sreloc->size += p->count * htab->sizeof_reloc;',
                 'htab->elf.srelplt->reloc_count++;',
                 'htab->elf.sgotplt->size += 2 * htab->got_entry_size;',
                 'htab->elf.tlsdesc_got = htab->elf.sgot->size;',
                 'return elf_x86_allocate_dynrelocs (h, inf);'):
    assert fragment in generic, fragment
assert 'if (bfd_link_pic (info))\n\thtab->irelifunc->size += count * sizeof_reloc;' in ifunc
assert '.  unsigned reloc_count;' in sources['bfd/section.c']
assert 'unsigned int got_entry_size;' in header
assert '((htab)->elf.srelplt->reloc_count * (htab)->got_entry_size)' in header

ordinary = 16 + 32 + 8 + 24 + 16 + 16 + 48 + 24
ifunc_bytes = 16 + 16 + 8 + 24 + 8 + 24 + 16
local = 16 + 16 + 48 + 24
shared = (16 + 24) + (8 + 16 + 16)
assert ordinary == 184 and ifunc_bytes == 112 <= ordinary
assert local == 104 and shared == 80
limit = (2**32 - 1) // 8
assert limit == 536870911 and limit*8 <= 2**32 - 1
assert (limit+1)*8 == 2**32
result = {
    'source_files_checked': len(sources),
    'ordinary_callback_bytes_excluding_q': ordinary,
    'IFUNC_callback_bytes_excluding_q': ifunc_bytes,
    'local_positive_GOT_entry_bytes': local,
    'per_phase_shared_TLS_bytes': shared,
    'per_incoming_dynamic_relocation_bytes': 24,
    'unsigned32_jump_count_sufficient_bound': limit,
    'whole_link_capacity_established': False,
    'native_tool_executions': 0,
}
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
