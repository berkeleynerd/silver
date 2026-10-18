#!/usr/bin/env python3
"""Check selected GAS/BFD fixed startup arithmetic offline; no native tools."""
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
    'gas/as.c': [(459, 473), (531, 629), (1325, 1341), (1355, 1402)],
    'gas/config/tc-i386.c': [(17204, 17211), (17250, 17300)],
    'gas/read.c': [(253, 302), (2012, 2044), (6598, 6603)],
    'gas/depend.c': [(23, 74)],
    'gas/stabs.c': [(661, 676)],
    'gas/dwarf2dbg.c': [(1166, 1180), (3082, 3118)],
    'gas/ehopt.c': [(584, 589)],
    'gas/input-scrub.c': [(243, 275)],
    'gas/symbols.c': [(2043, 2064)],
    'libiberty/xatexit.c': [(45, 85)],
    'libiberty/concat.c': [(104, 121)],
    'include/getopt.h': [(81, 93)],
    'bfd/opncls.c': [(50, 99), (729, 765), (1985, 2010)],
    'bfd/bfd-in2.h': [(337, 374), (435, 453), (687, 849),
                      (1947, 1976), (2080, 2288)],
    'bfd/libbfd.h': [(56, 60)],
    'bfd/elfxx-x86.h': [(750, 763), (963, 966)],
    'bfd/elfxx-x86.c': [(40, 44)],
    'bfd/elf.c': [(295, 319), (3315, 3344)],
    'bfd/elf-bfd.h': [(1855, 1947), (1970, 1999), (2049, 2097), (2128, 2281)],
    'bfd/elf-attrs.h': [(145, 155)],
    'include/elf/internal.h': [(65, 82), (102, 118)],
    'bfd/section.c': [(790, 809), (1114, 1152)],
    'bfd/hash.c': [(382, 405), (596, 651), (726, 748)],
    'bfd/libbfd.c': [(434, 481)],
    'include/objalloc.h': [(44, 63), (85, 100)],
    'libiberty/objalloc.c': [(55, 81), (85, 170)],
}
excerpts = ['# Selected GAS/BFD fixed startup source excerpts\n\nLiteral LF numbering.\n']
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
    (root / 'startup-source-excerpts.md').write_text(excerpts)
else:
    assert (root / 'startup-source-excerpts.md').read_text() == excerpts

anchors = {
    'gas/as.c': ['shortopts = concat (std_shortopts, md_shortopts, (char *) NULL);',
                 '+ md_longopts_size + sizeof (struct option));',
                 'xatexit (free_notes);', 'xatexit (output_file_close);',
                 'xatexit (dump_statistics);'],
    'gas/read.c': ['include_dirs = XNEWVEC (const char *, 1);'],
    'gas/depend.c': ['static char * dep_file = NULL;',
                     'if (dep_file == NULL)\n    return;'],
    'bfd/opncls.c': ['nbfd = (bfd *) bfd_zmalloc (sizeof (bfd));',
                     'nbfd->id = bfd_id_counter++;',
                     'nbfd->memory = objalloc_create ();',
                     'sizeof (struct section_hash_entry), 13)',
                     'char *n = bfd_alloc (abfd, len);'],
    'bfd/elfxx-x86.c': ['bfd_elf_allocate_object (abfd, sizeof (struct elf_x86_obj_tdata))'],
    'bfd/elf.c': ['abfd->tdata.any = bfd_zalloc (abfd, object_size);',
                  'struct output_elf_obj_tdata *o = bfd_zalloc (abfd, sizeof *o);'],
    'bfd/section.c': ['bfd_hash_allocate (table, sizeof (struct section_hash_entry));',
                      'section_hash_lookup (&abfd->section_htab, name, true, false);'],
    'bfd/libbfd.c': ['|| ((signed long) ul_size) < 0)',
                     'abfd->alloc_size += size;'],
    'libiberty/objalloc.c': ['#define CHUNK_SIZE (4096 - 32)',
                            'len = (len + OBJALLOC_ALIGN - 1) &~ (OBJALLOC_ALIGN - 1);',
                            'malloc (CHUNK_HEADER_SIZE + len)'],
}
for name, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)

std_short = uncomment(lines('gas/as.c', 459, 473))
std_chars = re.findall(r"'(?:\\.|[^'\\])'", std_short)
assert len(std_chars) == 26 and std_chars[-1] == "'\\0'"
md_short = uncomment(lines('gas/config/tc-i386.c', 17204, 17211))
md_strings = re.findall(r'"([^"\\]*)"', md_short)
assert md_strings == ['kVQ:', 's', 'qnO::']
short_bytes = len(std_chars)-1 + sum(map(len, md_strings)) + 1
std_long = uncomment(lines('gas/as.c', 531, 618))
md_long = uncomment(lines('gas/config/tc-i386.c', 17250, 17299))
std_named = len(re.findall(r'\{\s*"', std_long))
md_named = len(re.findall(r'\{\s*"', md_long))
md_null = len(re.findall(r'\{\s*NULL', md_long))
assert (std_named, md_named, md_null) == (56, 36, 1)
long_count = std_named+md_named+md_null+1
assert short_bytes == 36 and long_count*32 == 3008

# Every semicolon, including closing/union declarations, costs eight bytes.
# Comma-separated extra fields and embedded aggregates are added in full,
# without reclaiming their already charged declaration slots. This is a
# conservative source-layout check; it does not invoke sizeof or a compiler.
layouts = {
    'bfd': ('bfd/bfd-in2.h', 1947, 2288, 89, 8+64, 1024),
    'asection': ('bfd/bfd-in2.h', 435, 849, 57, 8, 512),
    'ELF_section_data': ('bfd/elf-bfd.h', 1875, 1947, 20, 80+2*32, 320),
    'output_ELF_data': ('bfd/elf-bfd.h', 2049, 2097, 21, 8, 192),
    'generic_ELF_data': ('bfd/elf-bfd.h', 2128, 2281, 62,
                         128+8*80+2*77*16+2*8+24+3*8, 4096),
}
layout_sums = {}
for label, (name, low, high, count, extra, upper) in layouts.items():
    assert uncomment(lines(name, low, high)).count(';') == count, label
    layout_sums[label] = count*8+extra
    assert layout_sums[label] <= upper
layout_sums['x86_ELF_data'] = layout_sums['generic_ELF_data']+3*8
layout_sums['section_hash_entry'] = layout_sums['asection']+24
assert layout_sums['x86_ELF_data'] == 3816 <= 4096
assert layout_sums['section_hash_entry'] == 488 <= 576
assert '#define NUM_KNOWN_OBJ_ATTRIBUTES 77' in sources['bfd/elf-bfd.h']

entry_count = 13
initial_buckets, next_buckets = 13, 31
assert 10 > initial_buckets*3//4
assert entry_count <= next_buckets*3//4
assert 3 <= 32  # GAS registrations within the static xatexit first block.
startup_counter_fixed = 4096+192+13*320
assert startup_counter_fixed == 8448
fixed_requests = {
    'GAS_short_options': (1, short_bytes),
    'GAS_long_options': (1, long_count*32),
    'GAS_include_dirs': (1, 8),
    'BFD_control': (1, 1024),
    'x86_ELF_object_data': (1, 4096),
    'output_ELF_object_data': (1, 192),
    'ELF_section_data': (13, 320),
    'section_hash_entry': (13, 576),
    'section_hash_buckets': (2, 248),
    'objalloc_control_for_two_arenas': (2, 24),
    'initial_objalloc_chunks_for_two_arenas': (2, 4064),
}
assert all(size+23 < (1 << 63) for count, size in fixed_requests.values())

result = {
    'scope': 'Selected GAS fixed options and output-BFD startup metadata',
    'source_files_verified': len(sources),
    'long_option_counts': {'standard_named': std_named, 'x86_named': md_named,
                           'x86_null_sentinel': md_null, 'extra_null_sentinel': 1},
    'conservative_LP64_layout_bytes': layout_sums,
    'fixed_raw_requests_upper': {
        name: {'count_upper': count, 'bytes_per_request_upper': size}
        for name, (count, size) in fixed_requests.items()
    },
    'section_hash_bucket_capacities': [initial_buckets, next_buckets],
    'objalloc_request_contract': 'max(P,4096)+23<=PTRDIFF_MAX; 1<=P',
    'BFD_main_arena_startup_raw_bytes_upper': 'P+8448',
    'BFD_lifetime_alloc_size_contract': 'P+8448+R<=2^64-1; R includes all other successful raw requests, even later released',
    'whole_BFD_request_inventory_complete': False,
    'production_phase_argument_path_join_complete': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
