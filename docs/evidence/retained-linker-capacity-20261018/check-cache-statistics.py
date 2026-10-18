"""Reconcile selected linker's unobserved modular cache statistics."""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--binutils-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
manifest = json.loads((root/'cache-source-inventory.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
assert len(manifest['files']) == 1516
sources = {}
uses = {}
other_identifiers = {}
member = re.compile(rb'(?:->|\.)\s*(?:alloc_size|cache_size|max_cache_size)\b')
identifier = re.compile(rb'\b(?:alloc_size|cache_size|max_cache_size)\b')
for row in manifest['files']:
    raw = (args.binutils_root/row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    sources[row['path']] = raw
    # Scan every retained file, including code-generation templates. History
    # comments may mention fields; the expected inventory makes those explicit.
    matches = []
    for hit in member.finditer(raw):
        start = raw.rfind(b'\n', 0, hit.start())+1
        end = raw.find(b'\n', hit.end())
        if end < 0:
            end = len(raw)
        matches.append(dict(line=raw.count(b'\n', 0, hit.start())+1,
                            text=raw[start:end].decode().strip()))
    if matches:
        uses[row['path']] = matches
    if Path(row['path']).suffix in ('.c', '.h', '.em', '.y', '.l', '.in', '.inc', '.def', '.cc'):
        rows = [dict(line=i, text=line.decode().strip())
                for i, line in enumerate(raw.split(b'\n'), 1)
                if identifier.search(line) and not member.search(line)]
        if rows:
            other_identifiers[row['path']] = rows

expected = {
    'bfd/elf32-i386.c': [2019],
    'bfd/elf64-x86-64.c': [3109],
    'bfd/elflink.c': [72, 76, 79, 87, 2922],
    'bfd/libbfd.c': [457],
    'ld/ldmain.c': [762],
    'ld/lexsup.c': [1776],
}
assert {p: [v['line'] for v in rows] for p, rows in uses.items()} == expected
assert {p: [v['line'] for v in rows] for p, rows in other_identifiers.items()} == {
    'bfd/bfd-in2.h': [2202], 'bfd/bfd.c': [359],
    'bfd/elf32-xtensa.c': [2107, 2119, 2122], 'bfd/elflink.c': [2893],
    'include/ansidecl.h': [254, 257, 265, 273],
    'include/bfdlink.h': [771, 773, 774, 775],
    'ld/ldlang.c': [197, 199, 201, 202], 'ld/lexsup.c': [1773],
    'libiberty/xmemdup.c': [8, 10, 35, 37, 38, 39],
}
assert b'typedef uint64_t bfd_size_type;' in sources['bfd/bfd-in2.h']
assert b'link_info.max_cache_size = (bfd_size_type) -1;' in sources['ld/ldmain.c']
keep = sources['bfd/elflink.c'].split(b'_bfd_elf_link_keep_memory (')[1].split(b'\n}\n')[0]
assert b'if (info->max_cache_size == (bfd_size_type) -1)\n    return true;' in keep
assert keep.index(b'return true;') < keep.index(b'size = info->cache_size;')
assert keep.index(b'return true;') < keep.index(b'size += abfd->alloc_size;')
setter = sources['ld/lexsup.c'].split(b'case OPTION_MAX_CACHE_SIZE:')[1].split(b'case ')[0]
assert b'link_info.max_cache_size = cache_size;' in setter
assert b'info->cache_size += sec->size;' in sources['bfd/elf64-x86-64.c']
assert b'info->cache_size += size;' in sources['bfd/elflink.c']
assert b'abfd->alloc_size += size;' in sources['bfd/libbfd.c']
inputs = json.loads((root/'cache-inputs.json').read_text())
for row in inputs:
    raw = (repo/row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    assert b'--max-cache-size' not in raw

result = dict(
    scope='Selected x86-64 link without --max-cache-size or plugins',
    complete_source_files_verified=len(sources),
    retained_input_identities_verified=len(inputs),
    member_access_inventory=uses,
    other_identifier_inventory=other_identifiers,
    selected_unobserved_unsigned_fields=['bfd.alloc_size', 'bfd_link_info.cache_size'],
    selected_max_cache_size='UINT64_MAX',
    semantic_justification='Every selected reader returns before observing either field; modular updates affect only those fields',
    mathematical_cumulative_totals_no_wrap_claim=False,
    additional_cumulative_memory_predicate_required_for_these_fields=False,
    individual_allocation_size_and_container_obligations_unchanged=True,
    source_reachability_automatically_proved=False,
    whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(sources=len(sources), member_accesses=sum(map(len, uses.values())),
                     unobserved_selected_fields=2, whole_link_capacity=False)))
