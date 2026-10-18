#!/usr/bin/env python3
"""Check retained GAS hash-table counts and requests without native execution."""
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

ranges = {
    'gas/as.c': [(1366, 1378)],
    'gas/symbols.c': [(3132, 3137)],
    'gas/hash.h': [(24, 28), (52, 58), (96, 117)],
    'gas/hash.c': [(47, 63)],
    'gas/macro.c': [(59, 65)],
    'gas/read.c': [(335, 520), (556, 615)],
    'gas/config/tc-i386.c': [(1310, 1361), (3643, 3704)],
    'gas/config/obj-elf.c': [(73, 200)],
    'gas/dw2gencfi.c': [(699, 731), (2723, 2755)],
    'opcodes/i386-tbl.h': [(47951, 48282), (50514, 50521), (51912, 51926)],
    'include/hashtab.h': [(96, 141)],
    'libiberty/hashtab.c': [(134, 193), (282, 286), (339, 374),
                          (517, 575), (633, 695)],
}
excerpts = ['# Selected GAS hash source excerpts\n\nLiteral LF numbering.\n']
for name, spans in ranges.items():
    lines = sources[name].split('\n')
    for low, high in spans:
        assert 1 <= low <= high <= len(lines)
        excerpts.append(f'\n## {name}:{low}–{high}\n\n```text\n')
        excerpts.extend(f'{n}: {lines[n-1].expandtabs(8)}'.rstrip()+'\n'
                        for n in range(low, high+1))
        excerpts.append('```\n')
excerpts = ''.join(excerpts)
if args.record_excerpts:
    (root / 'hash-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'hash-source-excerpts.md').read_text() == excerpts

table = sources['opcodes/i386-tbl.h']
assert 'typedef unsigned short i386_op_off_t;' in table
offset_text = table.split('static const i386_op_off_t i386_op_sets[] =', 1)[1].split('};', 1)[0]
offsets = list(map(int, re.findall(r'\b\d+\b', offset_text)))
assert len(offsets) == 2614 and offsets == sorted(set(offsets))
assert offsets[0] == 0 and max(offsets) == 4550 < 2**16
register_text = table.split('static const reg_entry i386_regtab[] =', 1)[1].split('};', 1)[0]
register_rows = re.findall(r'^  \{ "', register_text, re.M)
assert len(register_rows) == 352
pseudo = {}
for name, symbol in [('gas/read.c', 'potable'),
                     ('gas/config/tc-i386.c', 'md_pseudo_table'),
                     ('gas/config/obj-elf.c', 'elf_pseudo_table'),
                     ('gas/dw2gencfi.c', 'cfi_pseudo_table')]:
    bodies = [part.split('};', 1)[0]
              for part in sources[name].split(' '+symbol+'[] =')[1:]]
    counts = [len(re.findall(r'\{\s*"', body)) for body in bodies]
    assert counts and len(set(counts)) == 1
    pseudo[symbol] = counts[0]
assert pseudo == {'potable': 165, 'md_pseudo_table': 33,
                  'elf_pseudo_table': 36, 'cfi_pseudo_table': 29}
assert sum(pseudo.values()) == 263

for name, fragments in {
    'gas/hash.h': ['NULL, notes_calloc, NULL);',
                   'string_tuple_t *tuple = table->alloc_f (1, sizeof (*tuple));'],
    'gas/symbols.c': ['sy_hash = htab_create_alloc (1024, hash_symbol_entry, eq_symbol_entry,',
                      'NULL, xcalloc, free);'],
    'gas/macro.c': ['macro_hash = htab_create_alloc (16, hash_string_tuple, eq_string_tuple,',
                    'macro_del_f, notes_calloc, NULL);'],
    'gas/config/tc-i386.c': ['const i386_op_off_t *end = cur + ARRAY_SIZE (i386_op_sets) - 1;',
                            'for (; cur < end; ++cur)',
                            'for (regtab = i386_regtab; regtab_size--; regtab++)'],
    'libiberty/hashtab.c': ['nindex = higher_prime_index (elts * 2);',
                           'if (insert == INSERT && size * 3 <= htab->n_elements * 4)',
                           'htab->n_elements++;'],
}.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)

prime_text = sources['libiberty/hashtab.c'].split('static struct prime_ent const prime_tab[] = {', 1)[1].split('};', 1)[0]
primes = [int(s, 0) for s in re.findall(r'\{\s*(0x[0-9a-f]+|[0-9]+),', prime_text)]
prime_ge = lambda n: next(p for p in primes if p >= n)
tables = {}
for name, initial, entries in [('opcode', 16, len(offsets)-1),
                               ('register', 16, len(register_rows)),
                               ('pseudo_op', 16, sum(pseudo.values())),
                               ('macro', 16, 0), ('symbol', 1024, 88)]:
    capacity = prime_ge(max(initial, 2*entries))
    tables[name] = {'initial_requested_slots': initial,
                    'insert_calls_or_live_entries_upper': entries,
                    'pointer_slots_upper': capacity,
                    'pointer_array_bytes_upper': 8*capacity,
                    'allocator': 'heap' if name == 'symbol' else 'notes'}
    assert capacity*3 < 2**64 and entries*4 < 2**64
    assert 2*capacity-3 < 2**32 and 8*capacity < 2**63
assert [tables[n]['pointer_slots_upper'] for n in tables] == [8191, 1021, 1021, 31, 2039]
assert 88*4 < 2039*3
control_size = 9*8+3*8+3*4+4
assert control_size == 112 <= 128
h = max(128, 16, *(r['pointer_array_bytes_upper'] for r in tables.values()))
assert h == 65528
descriptor_q = max(h, 8*(5+1), len('main.o')+1)
assert descriptor_q+241 == 65769
result = {
    'scope': 'Selected GAS hash-table requests; other startup and BFD storage remain separate',
    'source_files_verified': len(sources),
    'opcode_offsets_including_sentinel': len(offsets),
    'maximum_opcode_offset': max(offsets),
    'register_rows_charged': len(register_rows),
    'pseudo_rows_including_all_conditional_branches': pseudo,
    'tables': tables,
    'LP64_hash_control_bytes': control_size,
    'conservative_hash_control_request_upper': 128,
    'string_tuple_request_bytes': 16,
    'string_tuple_requests_upper': 2613+352+263,
    'H_bytes_upper': h,
    'joined_notes_raw_request_contract': 'Q=max(65528,8*(A+1),P)',
    'joined_notes_chunk_contract': 'max(4064,Q+241)<=PTRDIFF_MAX; 0<=A<INT_MAX',
    'descriptor_example_notes_chunk_bytes_upper': descriptor_q+241,
    'production_phase_argument_path_join_complete': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
