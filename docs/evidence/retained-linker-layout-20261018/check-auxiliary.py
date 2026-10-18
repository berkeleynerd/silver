"""Reconcile selected layout, merge/EH and final-link scratch requests offline.

This is a scoped source-argument replay, not a whole-link allocation census.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--prior-repo', type=Path)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = a.prior_repo or root.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
records = {}
for row in json.loads((root / 'auxiliary-inputs.json').read_bytes()):
    raw = ((root if row.get('local') else repo) / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    records[row['key']] = json.loads(raw)
sources = {}
for prefix in ['', 'auxiliary-']:
    manifest = json.loads((root / (prefix + 'sources.json')).read_bytes())
    archive = root / (prefix + 'sources.tar.gz')
    assert sha(archive.read_bytes()) == manifest['archive_sha256']
    with tarfile.open(archive) as t:
        for row in manifest['files']:
            raw = t.extractfile(row['path']).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            sources[row['path']] = raw.decode()

j = records['join']
# The immutable projection records the original capture identity. Later joins
# may add unrelated results; compare every consumed aggregate field directly.
current = json.loads((repo / j['source_result_at_capture']['path']).read_bytes())
for key in ['counts', 'payload_union_bytes', 'binder_EH_entries']:
    assert current[key] == j[key], key
for key, value in j['payload_components'].items():
    assert current['payload_components'][key] == value, key
c = j['counts']
I, S, N, R, Z, Trel = (c[k] for k in ['I', 'S', 'N', 'R', 'Z', 'Trel'])
B = j['payload_union_bytes']
shape = records['shape']
assert shape['selected_program_headers_upper'] == 12
assert shape['selected_EH_alignment_upper'] == 8
assert shape['selected_non_page_section_alignment_upper'] == 64
assert shape['selected_link_order_reordering_requests'] == 0
fixed = records['fixed']['processed_fixed_totals']
generated_merge = j['payload_components']['full_generated_merge_output']
merge_entries = fixed['merge_entries'] + generated_merge
merge_bytes = fixed['merge_entry_bytes'] + generated_merge
merge_sections = fixed['merge_input_sections'] + 2
assert (merge_entries, merge_bytes, merge_sections) == (116495, 3147350, 4897)
merge_capacity = 0x2000
while merge_entries > merge_capacity // 3 * 2:
    merge_capacity *= 2
link_order_capacity = 64
while link_order_capacity < I:
    link_order_capacity *= 2
EHentries = records['unwind']['nonbinder_entries_upper'] + len(j['binder_EH_entries'])
EHbytes = records['unwind']['nonbinder_original_bytes_upper'] + 192
FDEs = (j['payload_components']['EH_header'] - 12) // 8
assert (EHentries, EHbytes, FDEs) == (16332, 552020, 14957)
primes = [int(n) for n in re.findall(r'\{\s*(\d+),\s*0x', sources['libiberty/hashtab.c'])]
CIE_capacity = next(n for n in primes if n >= 2 * EHentries)
assert CIE_capacity == 32749

anchors = {
    'bfd/libbfd.c': ['|| sz > SSIZE_MAX)', '|| ((signed long) ul_size) < 0)',
        'ret = objalloc_alloc ((struct objalloc *) abfd->memory, ul_size);',
        '_bfd_minimum_mmap_size = _bfd_pagesize * 4;'],
    'libiberty/hashtab.c': ['nindex = higher_prime_index (elts * 2);',
        'if (insert == INSERT && size * 3 <= htab->n_elements * 4)'],
    'libiberty/objalloc.c': ['#define CHUNK_SIZE (4096 - 32)', '#define BIG_REQUEST (512)',
        'len = (len + OBJALLOC_ALIGN - 1) &~ (OBJALLOC_ALIGN - 1);',
        'ret = (char *) malloc (CHUNK_HEADER_SIZE + len);'],
    'include/objalloc.h': ['struct objalloc_align { char x; double d; };',
        'unsigned long __len = (l);'],
    'ld/ldlang.c': ['if (!link_info.non_contiguous_regions)\n\treturn true;',
        'if (wont_add_section_p (section, output))\n    return;'],
    'ld/ldelfgen.c': ['os_info->alloc = 64;', 'os_info->alloc *= 2;',
        'if (os_info->count > 1\n\t\t      && fixup_link_order (os))'],
    'bfd/elf.c': ['amt = bfd_count_sections (abfd) * sizeof (asection *);',
        'amt += (to - from) * sizeof (asection *);',
        'amt = section_number * sizeof (Elf_Internal_Shdr *);',
        'phdrs = bfd_zalloc (abfd, (actual * sizeof (*phdrs)'],
    'bfd/merge.c': ['typedef uint32_t mapofs_type;',
        'if (sec->size % sec->entsize != 0)',
        'return count + added > nbuckets / 3 * 2;',
        'amt = (secinfo->noffsetmap + 2048);',
        'append_offsetmap (secinfo, sec->size, NULL);',
        'amt = (sz / OFSDIV + 1) * sizeof (secinfo->ofstolowbound[0]);'],
    'bfd/elf-eh-frame.c': ['if (sec->size == 0',
        '+ (num_entries - 1) * sizeof (struct eh_cie_fde)))',
        'bfd_alloc (abfd, (set_loc_count + 1) * sizeof (unsigned int));',
        'bfd_malloc (hdr_info->u.dwarf.fde_count'],
    'bfd/elflink.c': ['max_contents_size = _bfd_minimum_mmap_size;',
        'size = (size + size_align - 1) & -size_align;',
        'if (max_sym_count < 20)\n    max_sym_count = 20;',
        'strtabsize += strtabsize;',
        'amt = max_internal_reloc_count * sizeof (Elf_Internal_Rela);'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)

# Layouts are read from the pinned declarations under the selected LP64 ABI.
# The EH records use deliberately loose 64/256-byte bounds, including padding.
requests = {
    'link_order_per_output_array': 16 + 16 * link_order_capacity,
    'mapper_section_pointer_array': 8 * S,
    'each_segment_map': 80 + 8 * S,
    'final_program_headers_and_sort_pointers': 12 * (64 + 8),
    'section_header_pointer_array': 8 * N,
    'individual_internal_section_header': 80,
    'merge_each_key_or_value_bucket_array': 8 * merge_capacity,
    'merge_each_hash_entry_with_bytes': 32 + merge_bytes,
    'merge_input_copy_with_optional_terminator': 2 * merge_bytes,
    'merge_offset_map': 4 * (merge_entries + 2048),
    'merge_entry_map': 8 * (merge_entries + 2048),
    'merge_fast_offset_lookup': 4 * (merge_bytes // 32 + 1),
    'merge_suffix_sort_pointers': 8 * merge_entries,
    'merge_padding_buffer': 64,
    'EH_per_section_entry_info': 16 + 64 * EHentries,
    'EH_per_section_local_CIE_array': 256 * EHentries,
    'EH_one_full_CIE_record': 256,
    'EH_CIE_hash_control': 128,
    'EH_CIE_hash_backing': 8 * CIE_capacity,
    'EH_set_loc_array': 4 * (EHbytes + 1),
    'EH_header_search_array': 24 * FDEs,
    'final_content_scratch_at_4096_host_pages': max(16384, B + 7),
    'final_external_relocation_scratch_at_4096_host_pages': max(16384, 24 * Trel),
    'final_internal_relocation_scratch': 24 * Trel,
    'final_external_symbol_scratch': 24 * max(R, 20),
    'final_internal_symbol_scratch': 32 * max(R, 20),
    'final_symbol_index_or_section_pointer_scratch': 8 * max(R, 20),
    'final_local_extended_symbol_indices': 4 * R,
    'ordinary_output_symbol_cache': 40 * max(R, 20, 2 * Z),
    'ordinary_external_output_symbols': 24 * Z,
    'ordinary_output_extended_symbol_indices': 4 * Z,
}
assert merge_capacity == 262144 and link_order_capacity == 65536
assert max(requests.values()) == B + 7
assert all(0 < n < 2**31 for n in requests.values())
assert merge_entries + 2048 < 2**32 and merge_capacity < 2**31
assert all(n < 2**31 for n in [I, S, N, R, Z, Trel, EHentries, EHbytes, FDEs])

result = {
    'scope': 'Allocator interface, selected layout, merge/EH arrays and final-link scratch',
    'source_files_verified': len(sources),
    'prior_input_identities_verified': len(records),
    'selected_LP64_object_allocator': {'alignment': 8, 'chunk_header': 16,
        'small_chunk': 4064, 'backing_request_formula': 'max(4064, max(1,n)+23)'},
    'host_page_premise_bytes': 4096,
    'host_page_parameterized_scratch': {'contents': 'max(4*G,B+7)',
                                      'external_relocations': 'max(4*G,24*Trel)'},
    'link_order_capacity_upper': link_order_capacity,
    'merge_entries_upper': merge_entries, 'merge_original_entry_bytes_upper': merge_bytes,
    'merge_section_occurrences_upper': merge_sections,
    'merge_capacity_upper': merge_capacity,
    'EH_entries_upper': EHentries, 'EH_original_bytes_upper': EHbytes, 'EH_FDEs_upper': FDEs,
    'individual_request_upper_bytes': requests,
    'largest_scoped_request_upper': max(requests.values()),
    'largest_scoped_objalloc_backing_upper': max(4064, max(requests.values()) + 23),
    'covered_count_arithmetic_fits': True,
    'request_sum_is_an_admission_condition': False,
    'whole_link_allocation_census_or_capacity_established': False,
    'native_tool_executions': 0,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['source_files_verified',
    'largest_scoped_request_upper', 'whole_link_allocation_census_or_capacity_established']}))
