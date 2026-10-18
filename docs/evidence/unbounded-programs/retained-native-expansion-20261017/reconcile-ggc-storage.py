#!/usr/bin/env python3
"""Check selected GGC storage arithmetic; execute no compiler or prover."""
import argparse
import ctypes
import gzip
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'ggc-storage-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
    sources[row['path']] = raw.decode()
config = identity['configuration']
raw = gzip.decompress((root / config['archive']).read_bytes())
assert len(raw) == config['bytes'] and hashlib.sha256(raw).hexdigest() == config['sha256']
header = raw.decode()
for token in ['#define HAVE_MMAP_ANON 1', '#define HAVE_MADVISE 1',
              '#define HAVE_DECL_MADVISE 1', '#define GATHER_STATISTICS 0',
              '#define SIZEOF_LONG 8', '#define SIZEOF_LONG_LONG 8',
              '/* #undef ENABLE_GC_ALWAYS_COLLECT */', '/* #undef ENABLE_GC_CHECKING */']:
    assert token in header
page = sources['gcc/ggc-page.cc']
tokens = ['#define PAGE_L1_BITS\t(8)', '#define PAGE_L2_BITS\t(32 - PAGE_L1_BITS - G.lg_pagesize)',
          '#  define GGC_QUIRE_SIZE 512', '#define INITIAL_PTE_COUNT 128',
          'G.by_depth_max *= 2;', 'int i = entry->index_by_depth;',
          'bitmap_size = BITMAP_SIZE (num_objects + 1);',
          'page_entry_size = sizeof (page_entry) - sizeof (long) + bitmap_size;',
          'entry_size = num_objects * OBJECT_SIZE (order);',
          'entry_size = PAGE_ALIGN (entry_size);',
          'G.depth_max = 10;', 'G.finalizers.safe_push (vNULL);',
          'G.vec_finalizers.safe_push (vNULL);', 'G.allocated += object_size;',
          'timevar_ggc_mem_total += object_size;', 'G.bytes_mapped += size;',
          'float allocated_last_gc =', 'order = 10;',
          'object_size_table[order] = (size_t) 1 << order;']
for token in tokens:
    assert token in page, token
context_writes = re.findall(r'G\.context_depth\s*=(?!=)\s*([^;]+);', page)
assert context_writes == ['1']
assert page.index('G.context_depth = 1;') > page.index('ggc_pch_read (FILE *f, void *addr)')
assert 'gt_pch_restore (f);' in sources['gcc/c-family/c-pch.cc']
assert 'ggc_pch_read (f, mmi.preferred_base);' in sources['gcc/ggc-common.cc']

pointer = ctypes.c_void_p
assert ctypes.sizeof(pointer) == ctypes.sizeof(ctypes.c_ulong) == 8
assert ctypes.sizeof(ctypes.c_uint) == 4 and ctypes.sizeof(ctypes.c_ushort) == 2

class PageEntry(ctypes.Structure):
    _fields_ = [('next', pointer), ('prev', pointer), ('bytes', ctypes.c_size_t),
                ('free_list', pointer), ('page', pointer), ('index_by_depth', ctypes.c_ulong),
                ('context_depth', ctypes.c_ushort), ('num_free_objects', ctypes.c_ushort),
                ('next_bit_hint', ctypes.c_ushort), ('order', ctypes.c_ubyte),
                ('discarded', ctypes.c_bool), ('in_use_p', ctypes.c_ulong * 1)]

class PageTableChain(ctypes.Structure):
    _fields_ = [('next', pointer), ('high_bits', ctypes.c_size_t), ('table', pointer * 256)]

assert ctypes.sizeof(PageEntry) == 64 and PageEntry.in_use_p.offset == 56
assert ctypes.sizeof(PageTableChain) == 2064
page_size = 4096
largest_raw_request = 2 ** 62
ptrdiff_max = 2 ** 63 - 1
assert largest_raw_request + page_size - 1 <= ptrdiff_max
page_rows = []
for rounded in [*range(8, 513), *(2 ** k for k in range(10, 63))]:
    count = max(1, page_size // rounded)
    bitmap = ((count + 1 + 63) // 64) * 8
    page_entry = 56 + bitmap
    entry_size = max(page_size, count * rounded)
    entry_size = ((entry_size + page_size - 1) // page_size) * page_size
    assert 1 <= count <= 512
    assert count + 1 <= 513 < 2 ** 16
    assert bitmap <= 72 and page_entry <= 128
    assert (count - 1) * rounded < entry_size <= max(page_size, rounded)
    assert entry_size + page_size - 1 <= ptrdiff_max
    page_rows.append((rounded, count, bitmap, page_entry, entry_size))

def page_backing_bound(demand):
    assert 0 <= demand <= 2 ** 31 - 1
    return max(128, 1 << max(0, (max(1, demand) - 1).bit_length()))

def heap_capacity_bound(demand):
    if demand == 0:
        return 0
    assert 1 <= demand <= 2 ** 31 - 1
    return min(2 ** 31 - 1, max(4, demand, 2 * min(15, demand - 1),
                               3 * (demand - 1) // 2))

for demand in [0, 1, 127, 128, 129, 39257, 2 ** 30, 2 ** 30 + 1, 2 ** 31 - 1]:
    capacity = page_backing_bound(demand)
    assert max(128, demand) <= capacity <= 2 ** 31
    assert 8 * capacity <= 2 ** 34 < ptrdiff_max
    finalizer_capacity = heap_capacity_bound(demand)
    assert demand <= finalizer_capacity <= 2 ** 31 - 1
    assert 8 + finalizer_capacity * 32 <= ptrdiff_max
sample = json.loads((root / 'native-gcc-prefix-witness.json').read_text())
events = sample['counters']['ggc_bytes']['positive_events']
assert events == 39257
capacity = page_backing_bound(events)
finalizer_capacity = heap_capacity_bound(events)
assert capacity == 65536 and finalizer_capacity == 58884
result = {
    'scope': 'Selected Linux LP64, 4096-byte pages, mmap GGC; per-object/page/lookup and ordinary-finalizer backing',
    'gcc_commit': identity['commit'], 'source_files_verified': len(sources),
    'configuration_sha256': config['sha256'],
    'page_size_premise': page_size, 'raw_object_sufficient_limit': largest_raw_request,
    'page_entry_size': 64, 'page_entry_bitmap_offset': 56,
    'maximum_objects_per_page': 512, 'maximum_bitmap_with_sentry_bytes': 72,
    'maximum_individual_page_entry_request': 128,
    'page_quire_request': 512 * page_size, 'page_table_chain_request': 2064,
    'secondary_lookup_request': 4096 * 8, 'context_depth_without_PCH': 0,
    'depth_vector_request': 10 * 4, 'outer_finalizer_vector_requests_each': 8 + 4 * 8,
    'page_index_demand_sufficient_limit': 2 ** 31 - 1,
    'page_index_capacity_limit': 2 ** 31,
    'page_index_backing_request_limit_each': 8 * 2 ** 31,
    'sample_prefix_substitution': {
        'GGC_events': events, 'active_page_capacity_bound': capacity,
        'by_depth_request_bound': 8 * capacity, 'save_in_use_request_bound': 8 * capacity,
        'finalizer_capacity_bound': finalizer_capacity,
        'single_finalizer_backing_request_bound': 8 + 16 * finalizer_capacity,
        'vector_finalizer_backing_request_bound': 8 + 32 * finalizer_capacity,
        'largest_observed_rounded_object': sample['counters']['ggc_bytes']['largest_increment'],
        'bound_is_conservative_not_measured_backing': True,
    },
    'counter_classes': {
        'storage_checked': ['by_depth_in_use', 'by_depth_max', 'finalizer vec capacity/length',
                            'page bitmap/free count/hint', 'context-depth shifts'],
        'not_storage_indices': ['G.allocated', 'G.allocated_last_gc', 'G.bytes_mapped',
                                'timevar_ggc_mem_total'],
    },
    'source_sensitive_metadata_and_later_events_still_required': True,
    'aggregate_RAM_or_address_span_gate': False,
    'generated_marker_recursion_closed': False,
    'compiler_or_prover_executed': False, 'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'source_files_verified': len(sources), 'rounded_size_cases': len(page_rows),
                  'prefix_page_backbone_each': 8 * capacity, 'whole_native_capacity_established': False}))
