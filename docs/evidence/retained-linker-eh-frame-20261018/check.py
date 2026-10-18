#!/usr/bin/env python3
"""Reconcile retained ELF unwind sizing sources and arithmetic offline."""
import argparse
import hashlib
import json
from pathlib import Path
import re
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
    assert set(archive.getnames()) == {r['path'] for r in manifest['files']}
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        sources[row['path']] = raw.decode()
eh = sources['bfd/elf-eh-frame.c']
header = sources['bfd/elf-bfd.h']
for fragment in ['#define EH_FRAME_HDR_SIZE 8',
                 'REQUIRE (sec->size == (unsigned int) sec->size);',
                 '(num_entries - 1) * sizeof (struct eh_cie_fde)',
                 '(set_loc_count + 1) * sizeof (unsigned int)',
                 'offset = (offset + eh_alignment - 1) & -eh_alignment;',
                 'offset += size_of_output_cie_fde (ent);',
                 'sec->size += 4 + hdr_info->u.dwarf.fde_count * 8;',
                 'size += 4 + hdr_info->u.dwarf.fde_count * 8;',
                 'htab_try_create (1, cie_hash, cie_eq, free)',
                 'hdr_info->u.dwarf.fde_count++;',
                 'hdr_info->u.dwarf.array[hdr_info->array_count++].fde',
                 'unsigned int new_size;']:
    assert fragment in eh, fragment
for fragment in ['unsigned int aug_str_len : 3;', 'unsigned int aug_data_len : 5;',
                 'unsigned int personality_offset : 8;',
                 'unsigned int lsda_offset : 8;', 'unsigned int fde_count;',
                 'unsigned int array_count;']:
    assert fragment in header, fragment
assert 'eh_alignment = ((1 << o->alignment_power)' in sources['bfd/elflink.c']
assert 'LDEMUL_AFTER_ALLOCATION=' not in sources['ld/emultempl/elf-x86.em']
assert sources['ld/ldlang.c'].count('  ldemul_after_allocation ();') == 2

# Layout calculations assume the documented Linux LP64 ABI. Field inventory
# and path interpretation are reviewed in the derivation, not proved by text.
align8 = lambda n: (n + 7) // 8 * 8
entry_size = align8(16 + 4*4 + 4) + 8
section_size = 8 + 8 + entry_size
cie_size = align8(align8(2*4 + 2 + 20) + 4*8 + 8 + 8 + 5 + 50)
assert (entry_size, section_size, cie_size) == (48, 64, 136)
uint32 = 2**32 - 1
fde_limit = (uint32 - 4) // 8
assert fde_limit == 536870911
assert 4 + fde_limit*8 <= uint32 < 4 + (fde_limit+1)*8
primes_text = sources['libiberty/hashtab.c'].split('static struct prime_ent const prime_tab[] = {', 1)[1].split('};', 1)[0]
primes = [int(s, 0) for s in re.findall(r'\{\s*(0x[0-9a-f]+|[0-9]+),', primes_text)]
assert len(primes) == 30 and primes[0] == 7
prime_bound = next(p for p in primes if p >= 2*fde_limit)
assert prime_bound == 2147483647 and 2*prime_bound-3 <= uint32
assert max(8*prime_bound, 24*fde_limit, 8+4+8*fde_limit) < 2**63
# Arithmetic boundary examples, not an executable caller-coverage argument.
for b in [4, 8, 420, 2**20, uint32]:
    e = b//4
    assert 16+entry_size*e < 2**63
    assert cie_size*e < 2**63
    assert 4*(b//3+1) < 2**63 and b//3+1 <= uint32
result = {
    'scope': 'Conditional EH-frame editing and header transfer, not whole link',
    'source_files_checked': len(sources),
    'LP64_entry_metadata_bytes': entry_size,
    'LP64_one_entry_section_metadata_bytes': section_size,
    'LP64_CIE_record_bytes': cie_size,
    'entry_local_byte_bound': 'B+11E+3',
    'cross_input_sufficient_condition': 'B+11E+A+2 <= 2^32-1',
    'header_fde_count_limit': fde_limit,
    'header_byte_bound_at_limit': 8+4+8*fde_limit,
    'search_array_bytes_at_limit': 24*fde_limit,
    'CIE_hash_prime_bound': prime_bound,
    'whole_link_capacity_or_relocation_reach_established': False,
    'native_tool_executions': 0,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
