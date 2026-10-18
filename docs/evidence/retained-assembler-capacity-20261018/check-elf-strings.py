#!/usr/bin/env python3
"""Check selected ELF object string-table requests offline; no native tools."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--record-excerpts', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'source-manifest.json').read_text())
assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(row['path'] for row in manifest['files'])
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes']
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
        sources[row['path']] = raw.decode()

def lines(name, low, high):
    return '\n'.join(sources[name].split('\n')[low-1:high])

def uncomment(source):
    return re.sub(r'/\*.*?\*/', '', source, flags=re.S)

ranges = {
    'gas/as.c': [(1184, 1188)],
    'bfd/bfd-in2.h': [(337, 374)],
    'bfd/elf-strtab.c': [(29, 126), (143, 180), (387, 415)],
    'bfd/elf.c': [(3541, 3549), (3635, 3662), (7015, 7021),
                  (7072, 7077), (8744, 8750), (8837, 8849)],
    'bfd/hash.c': [(344, 345), (406, 487), (548, 586), (611, 661),
                   (750, 759), (777, 785)],
    'include/objalloc.h': [(44, 63), (87, 98)],
    'libiberty/objalloc.c': [(55, 81), (85, 170)],
}
excerpts = ['# Selected ELF string-table allocator source excerpts\n\nLiteral LF numbering.\n']
for name, spans in ranges.items():
    source_lines = sources[name].split('\n')
    for low, high in spans:
        assert 1 <= low <= high <= len(source_lines)
        excerpts.append(f'\n## {name}:{low}–{high}\n\n```text\n')
        excerpts.extend(f'{n}: {source_lines[n-1].expandtabs(8)}'.rstrip()+'\n'
                        for n in range(low, high+1))
        excerpts.append('```\n')
excerpts = ''.join(excerpts)
if args.record_excerpts:
    (root / 'elf-string-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'elf-string-source-excerpts.md').read_text() == excerpts

anchors = {
    'bfd/elf-strtab.c': [
        'size_t amt = sizeof (struct elf_strtab_hash);',
        'table = (struct elf_strtab_hash *) bfd_malloc (amt);',
        'bfd_hash_table_init (&table->table, elf_strtab_hash_newfunc,',
        'bfd_hash_allocate (table, sizeof (struct elf_strtab_hash_entry));',
        'entry = bfd_hash_newfunc (entry, table, string);',
        'table->size = 1;', 'table->alloced = 64;',
        'if (tab->size == tab->alloced)', 'tab->alloced *= 2;',
        'bfd_realloc_or_free (tab->array, tab->alloced * amt);',
        'amt = tab->size;', 'amt *= sizeof (struct elf_strtab_hash_entry *);',
        'array = (struct elf_strtab_hash_entry **) bfd_malloc (amt);',
        'qsort (array, size, sizeof (struct elf_strtab_hash_entry *), strrevcmp);',
    ],
    'bfd/hash.c': [
        '#define DEFAULT_SIZE 4051',
        'static unsigned int bfd_default_hash_table_size = DEFAULT_SIZE;',
        'table->memory = (void *) objalloc_create ();',
        'objalloc_alloc ((struct objalloc *) table->memory, alloc);',
        'table->count++;',
        'if (!table->frozen && table->count > table->size * 3 / 4)',
        'ret = objalloc_alloc ((struct objalloc *) table->memory, size);',
    ],
    'libiberty/objalloc.c': [
        '#define CHUNK_SIZE (4096 - 32)', '#define BIG_REQUEST (512)',
        'o->current_space = CHUNK_SIZE - CHUNK_HEADER_SIZE;',
        'malloc (CHUNK_HEADER_SIZE + len)',
    ],
}
for name, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)
assert 'bfd_hash_set_default_size' not in sources['gas/as.c']
assert 'case OPTION_REDUCE_MEMORY_OVERHEADS:\n\t  break;' in sources['gas/as.c']
assert 'case OPTION_HASH_TABLE_SIZE:\n\t  break;' in sources['gas/as.c']

# Field layouts are read from complete pinned declarations on the selected
# LP64 ABI. Charges remain conservative, including the union's largest arm.
assert uncomment(lines('bfd/bfd-in2.h', 337, 346)).count(';') == 4
assert uncomment(lines('bfd/bfd-in2.h', 350, 374)).count(';') == 8
assert uncomment(lines('bfd/elf-strtab.c', 31, 44)).count(';') == 7
assert uncomment(lines('bfd/elf-strtab.c', 48, 58)).count(';') == 6
base_entry = 3*8
entry_layout = base_entry + 4 + 4 + 8
hash_layout = 3*8 + 4*4
table_layout = hash_layout + 4*8
assert (entry_layout, hash_layout, table_layout) == (40, 40, 72)
entry_ceiling, table_ceiling = 64, 96
assert entry_layout <= entry_ceiling and table_layout <= table_ceiling

obj = json.loads((root / 'object-check-results.json').read_text())
assert obj['symbol_string_table']['distinct_names_upper'] == 97
assert obj['section_string_table']['distinct_names_upper'] == 21
buckets = 4051
bucket_bytes = buckets*8
chunk_bytes, header_bytes, align = 4064, 16, 8
assert bucket_bytes == 32408 > chunk_bytes-header_bytes
assert bucket_bytes % align == 0 and bucket_bytes >= 512
large_chunk = header_bytes+bucket_bytes
assert large_chunk == 32424
per_small = (chunk_bytes-header_bytes)//entry_ceiling
assert per_small == 63
tables = {}
for label in ['symbol', 'section']:
    source = obj[label+'_string_table']
    distinct = source['distinct_names_upper']
    assert distinct <= buckets*3//4 == 3038
    capacity = 64
    capacities = [capacity]
    while capacity < distinct+1:
        capacity *= 2
        capacities.append(capacity)
    small_chunks = (distinct+per_small-1)//per_small
    requests = {
        'table_control': table_ceiling,
        'objalloc_control': 24,
        'objalloc_small_chunk': chunk_bytes,
        'objalloc_bucket_large_chunk': large_chunk,
        'entry_pointer_array': capacity*8,
        'final_sort_pointer_array': (distinct+1)*8,
    }
    assert all(size < (1 << 63) for size in requests.values())
    tables[label] = {
        'distinct_nonempty_names_upper': distinct,
        'hash_bucket_slots': buckets,
        'hash_bucket_raw_request_bytes': bucket_bytes,
        'hash_growths': 0,
        'hash_entry_request_bytes_upper': entry_ceiling,
        'hash_name_copy_requests': 0,
        'pointer_array_capacities': capacities,
        'small_chunks_upper_including_initial': small_chunks,
        'large_bucket_chunks': 1,
        'individual_heap_request_bytes_upper': requests,
    }
assert tables['symbol']['small_chunks_upper_including_initial'] == 2
assert tables['section']['small_chunks_upper_including_initial'] == 1
assert tables['symbol']['individual_heap_request_bytes_upper']['final_sort_pointer_array'] == 784
assert tables['section']['individual_heap_request_bytes_upper']['final_sort_pointer_array'] == 176

result = {
    'scope': 'Two selected null Main ELF string-table allocator contexts',
    'source_files_verified': len(sources),
    'selected_LP64_layout_bytes': {
        'hash_entry': base_entry, 'string_entry': entry_layout,
        'hash_control': hash_layout, 'string_table_control': table_layout,
    },
    'tables': tables,
    'separate_from_shared_notes_and_output_BFD_alloc_size': True,
    'source_level_allocators_only': True,
    'libc_allocator_and_qsort_internals_covered': False,
    'whole_GAS_or_link_capacity_established': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
