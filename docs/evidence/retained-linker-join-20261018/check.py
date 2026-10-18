"""Compose selected null linker counts, payloads and reviewed layout bounds."""
import argparse
import hashlib
import json
from pathlib import Path
import struct

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
records = {}
for row in json.loads((root / 'inputs.json').read_bytes()):
    raw = (repo / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    records[row['key']] = json.loads(raw) if row['path'].endswith('.json') else raw
fixed = records['fixed']['processed_fixed_totals']
Main = records['Main']
transfer = records['binder']['selected_binder_object_transfer']
binder = records['binder']['cases'][transfer['full_inventory_equal_to_case']]['object']
assert binder['file'] == transfer['object_summary']['file']
assert binder['merge_sections'] == ['.comment']
binder_names = [x['name'] for family in ['sections', 'symbols']
                for x in binder[family] if x['name']]
assert not any('@' in n for n in binder_names)
binder_name_bytes = sum(len(n.encode()) + 1 for n in binder_names)
assert (len(binder_names), binder_name_bytes, max(map(len, binder_names))) == (189, 4061, 45)
assert binder['eh_frame_bytes'] == 192
# Parse the accepted fixed-shape object's EH records; relocation cardinality
# alone would not prove the FDE count. The object is retained bytes, not rerun.
raw = records['binder_ELF']
assert hashlib.sha256(raw).hexdigest() == binder['file']['sha256']
assert raw[:6] == b'\x7fELF\x02\x01'
shoff = struct.unpack_from('<Q', raw, 40)[0]
stride, count, shstrndx = struct.unpack_from('<HHH', raw, 58)
assert stride == 64 and count == binder['section_count'] == 16
headers = [struct.unpack_from('<IIQQQQIIQQ', raw, shoff + 64 * i) for i in range(count)]
h = headers[shstrndx]
shstr = raw[h[4]:h[4] + h[5]]
eh_header, = [h for h in headers if shstr[h[0]:shstr.index(0, h[0])] == b'.eh_frame']
eh = raw[eh_header[4]:eh_header[4] + eh_header[5]]
assert len(eh) == 192
at = binder_EH_FDEs = 0
cies, eh_entries = set(), []
while at < len(eh):
    length, cie_pointer = struct.unpack_from('<II', eh, at)
    assert 4 <= length < 0xffffffff and at + 4 + length <= len(eh)
    if cie_pointer == 0:
        cies.add(at)
    else:
        assert at + 4 - cie_pointer in cies
        binder_EH_FDEs += 1
    eh_entries.append(dict(offset=at, length=length, CIE_pointer=cie_pointer))
    at += 4 + length
assert at == len(eh) and len(cies) == 1 and binder_EH_FDEs == 5
binder_Qrel = len(binder['relocations'])
assert binder_Qrel == 3
R = fixed['symbol_records'] + Main['outgoing_symbol_entries_including_null'] + binder['symbol_count']
Q = fixed['section_headers'] + Main['section_headers_including_null'] + binder['section_count']
P = fixed['elf_occurrences'] + 2
Qrel = records['indices']['processed_fixed_relocation_headers'] + Main['relocation_sections_upper'] + binder_Qrel
Trel = records['dynamic']['fixed_relocation_record_processing_bound'] + Main['relocations_upper'] + binder['relocation_count']
Vdef = records['global']['version_nodes_under_that_premise_upper']
assignments = records['global']['selected_assignment_walk_non_dot_visits_upper']
H = 3 * R + 2 * Q + Vdef + 21
I = Q + Qrel + 3 * P + 35
S = I + 93
N = S + 5
T = 3 * S + 13
J = 8 * R + 11 * H + 2 * assignments + Vdef + 2 * I + 2 * S
D = H + 1 + J
Z = R + P + S + 3 * H + 2
assert (R, Q, P, Qrel, Trel) == (49358, 36471, 1483, 7917, 546740)
assert (H, I, S, N, T, D, Z) == (221088, 48872, 48965, 48970, 146908, 3243678, 763072)

# Generated names are source-derived Main bounds plus the accepted binder
# projection. Null entries contribute no named occurrence; both table-leading
# NULs were included in Main's serialized totals and are removed here.
Main_name_occurrences = sum(Main[key]['distinct_names_upper']
                            for key in ['symbol_string_table', 'section_string_table'])
Main_name_bytes = sum(Main[key]['unshared_bytes_upper'] - 1
                      for key in ['symbol_string_table', 'section_string_table'])
generated_names = Main_name_occurrences + len(binder_names)
generated_name_bytes = Main_name_bytes + binder_name_bytes
argv = records['inventory']['collect2_argv']
rpath, = [argv[i + 1] for i, v in enumerate(argv) if v == '-rpath']
assert len(rpath) == 169
dynstr = 1569550 + generated_name_bytes + len(rpath)
ordinary_name_length = max(171, max(map(len, binder_names)),
                           Main['symbol_string_table']['name_bytes_excluding_NUL']) + 25
section_name_length = max(171, max(len(s['name']) for s in binder['sections']),
                          Main['section_string_table']['name_bytes_excluding_NUL']) + 11
ordinary_strings = 1 + Z * (ordinary_name_length + 1)
section_strings = 1 + (3 * S + 4) * (section_name_length + 1)
k = H.bit_length()
m = max(6, 5 if k < 3 else k + (3 if H & (1 << (k - 2)) else 2))
W = 1 << (m - 6)
bucket_count = 32771
EH = (733772 + 1179 * 8 + binder['eh_frame_bytes']
      + 11 * (binder['eh_frame_bytes'] // 4)
      + 10 * binder['eh_frame_section_count'])
EHheader = 119628 + 8 * binder_EH_FDEs
copy = (4 * records['copy']['input_symbol_st_size_sum_upper']
        + (records['copy']['maximum_copy_definition_alignment'] - 1) * H)
binder_all = sum(s['size'] for s in binder['sections'] if s['type'] != 0)
binder_property = sum(s['size'] for s in binder['sections'] if s['name'] == '.note.gnu.property')
binder_merge = sum(s['size'] for s in binder['sections'] if s['flags'] & 0x10)
assert (binder_all, binder_property, binder_merge) == (22644, 48, 31)
assert Main['selected_ident_bytes'] == 29
# Only generated .comment is mergeable; its alignment is one. Adding it
# neither raises the fixed merge groups' alignment nor creates wider entries.
generated_merge = Main['selected_ident_bytes'] + 2 + binder_merge
payloads = {
    'original_fixed_sections': fixed['all_section_bytes'],
    'original_Main_sections': records['fixed']['source_derived_Main_original_section_bytes_upper'],
    'original_binder_sections': binder_all,
    'full_fixed_merge_output': records['fixed']['fixed_merge_output_payload_upper'],
    'full_generated_merge_output': generated_merge,
    'full_EH_edited_output_including_PLT_templates': EH,
    'EH_header': EHheader,
    'full_property_rewrite': 296 + binder_property,
    'copy_storage': copy,
    'interpreter': records['copy']['interpreter_payload_bytes_upper'],
    'dynsym': 24 * D,
    'versym': 2 * D,
    'SysV_hash': 4 * (2 + bucket_count + D),
    'GNU_hash': 4 * (4 + bucket_count + H) + 8 * W,
    'ordinary_symtab': 24 * Z,
    'optional_symtab_indices': 4 * Z,
    'ordinary_strtab': ordinary_strings,
    'shstrtab': section_strings,
    'GOT_PLT_and_dynamic_relocations_including_copy_relocations': 208 * H + 104 * R + 24 * Trel + 104,
    'dynamic_tags': records['dynamic']['dynamic_table_bytes_upper'],
    'dynstr': dynstr,
    'version_definitions': records['versions']['version_definition_bytes_if_W_zero'],
    'version_requirements': records['versions']['version_need_bytes_upper'],
}
B = sum(payloads.values())
shape = records['layout_shape']
A = shape['selected_page_and_general_layout_alignment_upper']
assert A == 4096 and shape['selected_EH_alignment_upper'] == 8
assert shape['mapping_convergence_established']
assert shape['selected_segment_mapping_iterations_upper'] == 2
padding = (I + S + 5) * (A - 1) + 32768
Hfile = 64 + 56 * T
V = Hfile + B + padding
# Charging all logical payload as file-backed is conservative, including
# NOBITS copies. Charge all intra-section/script padding too.
Bfile = B + padding
F = Hfile + (S + 1) * (V + A) + 4 * Bfile + (3 * N + 5) * A + 64 * N
conditions = {
    'dynamic_section_index': S < 0xff00,
    'external_section_header_product': 64 * N <= 2**32 - 1,
    'external_program_header_product': 56 * T <= 2**32 - 1,
    'dynamic_symbol_count': 1 <= D <= 2**32 - 1,
    'global_hash_domain': H <= 805306341,
    'GNU_hash_signed_shift': m <= 30,
    'ordinary_symbol_uint32_product': Z <= records['symtab']['output_symbol_uint32_product_limit'],
    'ordinary_string_bytes': ordinary_strings <= 2**32,
    'ordinary_string_length': ordinary_name_length <= 2**31 - 2,
    'dynstr_bytes': dynstr <= 2**32,
    'dynstr_names': 72100 + generated_names <= 805306341,
    'dynstr_positive_references': J + Vdef + 152 <= 2**32 - 1,
    'section_string_bytes': section_strings <= 2**32,
    'section_string_references': 6 * S + 7 <= 2**32 - 1,
    'version_index': records['global']['maximum_version_index_under_that_premise_upper'] <= 32767,
    'PLT_jump_count': H <= 536870911,
    'property_writer_size': payloads['full_property_rewrite'] <= 2**32 - 1,
    'EH_edit_size': EH <= 2**32 - 1,
    'EH_FDE_count': 14952 + binder_EH_FDEs <= 536870911,
    'conditional_trial_address_arithmetic': 2 * V + A <= 2**63 - 1,
    'conditional_file_offset_arithmetic': F + A <= 2**63 - 1,
}
assert all(conditions.values()), conditions
result = {
    'scope': 'Selected null linker count/payload/layout composition; relocation and complete auxiliary storage not completed',
    'prior_inputs_verified': len(records),
    'binder_EH_entries': eh_entries,
    'counts': dict(R=R, Q=Q, P=P, Qrel=Qrel, Trel=Trel, H=H, I=I, S=S, N=N, T=T, D=D, Z=Z),
    'generated_name_occurrences': generated_names,
    'generated_name_NUL_inclusive_bytes': generated_name_bytes,
    'GNU_hash': dict(maximum_selected_symbols=H, exponent=m, bloom_words=W),
    'payload_components': payloads,
    'payload_union_bytes': B,
    'conditional_layout': dict(alignment_premise=A, padding=padding, headers=Hfile,
                              retained_endpoint=V, trial_endpoint=2 * V,
                              file_payload_with_padding=Bfile, file_endpoint=F),
    'layout_shape_join': dict(effective_alignment_established=True,
                             EH_alignment=shape['selected_EH_alignment_upper'],
                             mapping_iterations_upper=shape['selected_segment_mapping_iterations_upper'],
                             source_premises=shape['mapping_convergence_premises']),
    'component_arithmetic_conditions': conditions,
    'trial_span_is_signed32': 2 * V < 2**31,
    'trial_span_alone_establishes_relocation_reach': False,
    'whole_link_capacity_established': False,
    'native_execution': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['counts', 'payload_union_bytes', 'conditional_layout']}))
