#!/usr/bin/env python3
"""Compose retained null callback and collector transfers, offline only."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import struct

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--ada-root', type=Path, required=True)
p.add_argument('--gnat1', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-callback-collector-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    parent = a.gcc_root if row['root'] == 'gcc' else a.ada_root
    raw = (parent / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in identity['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']

# Reuse the reviewed arithmetic functions verbatim, without running either
# script's main or recreating its successful evidence.
arithmetic = {}
for filename, names in [('derive.py', {'native_table_backing_row'}),
                        ('reconcile-ggc-storage.py', {'page_backing_bound', 'heap_capacity_bound'})]:
    tree = ast.parse((root / filename).read_text())
    selected = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names]
    assert len(selected) == len(names)
    exec(compile(ast.Module(body=selected, type_ignores=[]), filename, 'exec'), arithmetic)
table_row = arithmetic['native_table_backing_row']
anchors = {
    'gcc/ada/gcc-interface/decl.cc': [
        'if (is_type && (!gnu_decl || this_made_decl))',
        'return TREE_OVERFLOW (gnu_size) ? No_Uint : UI_From_gnu (gnu_size);'],
    'gcc/ada/gcc-interface/trans.cc': ['First_Formal_With_Extras (gnat_subprog)'],
    'gcc/ada/gcc-interface/cuintp.cc': ['return UI_From_Int (hw_input);'],
    'uintp.adb': ['if Min_Direct <= Input and then Input <= Max_Direct then'],
    'uintp.ads': ['Max_Direct : constant Int := (Base - 1) * (Base - 1);'],
    'gcc/ggc-common.cc': ['gt_clear_caches ();', 'ggc_mark_root_tab (*rt);'],
    'gcc/ggc-page.cc': ['ggc_mark_roots ();', 'ggc_handle_finalizers ();',
                        'if (p->context_depth < G.context_depth)',
                        'if (in_gc)\n    return;'],
    'gcc/hash-table.h': ['if (!ggc_test_and_set_mark (h->m_entries))',
                          'H::keep_cache_entry (*iter)', 'h->clear_slot (&*iter);'],
    'gcc/symbol-summary.h': ['new (ggc_internal_alloc (sizeof (T))) T ()'],
    'gcc/ipa-fnsummary.h': ['ggc_alloc_no_dtor<ipa_fn_summary_t> ()'],
    'gcc/tree.cc': ['hash_set<tree> pset;', 'auto_vec<tree, 16> to_mark;',
                    'value_expr_for_decl\n    = hash_table<tree_decl_map_cache_hasher>::create_ggc (512);'],
    'gcc/hash-set.h': ['explicit hash_set (size_t n = 13, bool ggc = false'],
    'gcc/hash-table.cc': ['{         13, 0x3b13b13c, 0x745d1747, 3 },'],
    'gcc/vec.h': ['m_auto.embedded_init (N, 0, 1);'],
}
for name, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[name], (name, snippet)
locks = sources['gnat1drv.adb'].split('--  Back end needs to explicitly unlock tables it needs to touch', 1)[1].split('--  Here we call the back end', 1)[0]
assert all(x not in locks for x in ['Uintp', 'Urealp', 'Repinfo'])
assert '#define Uints_Ptr uintp__uints__table' in sources['uintp.h']
assert '#define Udigits_Ptr uintp__udigits__table' in sources['uintp.h']

fixed = json.loads((root / 'local-envelope.json').read_text())['native_fixed_source_reduction_join']['fixed']
float_row = json.loads((root / 'native-fixed-float-callbacks.json').read_text())['sufficient_callback_transfer']
raw_fixed = json.loads((root / 'native-fixed-inputs.json').read_text())['fixed_lifetime_table_growth']
assert (fixed['Uint_entries'], fixed['Uint_digits'], fixed['Ureal_entries']) == (24324, 74958, 60)
assert raw_fixed['repinfo__rep_table__last_valX'] == 504
assert (float_row['Uint_appends'], float_row['Udigit_word_appends'], float_row['Ureal_appends']) == (4096, 32768, 7)
assert float_row['Repinfo_nodes_from_float_conversion'] == 0
demands = {'Uints': fixed['Uint_entries'] + float_row['Uint_appends'],
           'Udigits': fixed['Uint_digits'] + float_row['Udigit_word_appends'],
           'Ureals': fixed['Ureal_entries'] + float_row['Ureal_appends'],
           'Rep_Table': raw_fixed['repinfo__rep_table__last_valX']}
specs = {'Uints': (-699999999, 5000, 100, 8, -600000000),
         'Udigits': (0, 10000, 100, 4, 2**31-1),
         'Ureals': (-599999998, 200, 100, 16, -500000000),
         'Rep_Table': (1, 1000, 200, 32, 2**31-1)}
backing = {name: table_row(demands[name], *spec) for name, spec in specs.items()}
assert all(r['all_selected_checks_pass'] for r in backing.values())
assert 3584 < (32768-1)**2
local_words = max(2*74958, 74958+1, float_row['largest_local_numeric_vector_words'])
assert local_words == 149916 and 4*local_words+16 < 2**63

known = json.loads((root / 'native-null-source-locations.json').read_text())['updated_selected_known_GGC_subtotal']
assert known == 40098
page_capacity = arithmetic['page_backing_bound'](known)
finalizer_capacity = arithmetic['heap_capacity_bound'](known)
assert (page_capacity, finalizer_capacity) == (65536, 60145)
storage = json.loads((root / 'native-ggc-storage.json').read_text())
assert storage['context_depth_without_PCH'] == 0
assert storage['maximum_objects_per_page'] == 512

# Read existing ELF bytes; never execute the frontend. The native root arrays
# are compiled data. This is a census, not proof that all callbacks allocate
# nothing or that every recorded root is nonnull at a selected collection.
binary = a.gnat1.read_bytes()
binary_hash = hashlib.sha256(binary).hexdigest()
assert binary_hash == '5bf9b821ec0388ca6a6962dbc4bcb5773799926445fede6356069357c48dd58e'
assert binary[:6] == b'\x7fELF\x02\x01'
assert struct.unpack_from('<H', binary, 16)[0] == 2
section_offset = struct.unpack_from('<Q', binary, 40)[0]
section_stride, section_count = struct.unpack_from('<HH', binary, 58)
sections = [struct.unpack_from('<IIQQQQIIQQ', binary, section_offset+i*section_stride)
            for i in range(section_count)]
symbols = {}
names_by_address = {}
for sec in sections:
    if sec[1] != 11:  # SHT_DYNSYM, the retained executable has no SHT_SYMTAB.
        continue
    string_section = sections[sec[6]]
    strings = binary[string_section[4]:string_section[4]+string_section[5]]
    for offset in range(sec[4], sec[4]+sec[5], sec[9]):
        name_offset, info, other, index, value, size = struct.unpack_from('<IBBHQQ', binary, offset)
        name = strings[name_offset:strings.index(b'\0', name_offset)].decode()
        symbols[name] = (value, size)
        if value:
            names_by_address[value] = name

def elf_bytes(address, size):
    for sec in sections:
        if sec[1] != 8 and sec[3] <= address and address+size <= sec[3]+sec[5]:
            offset = sec[4]+address-sec[3]
            return binary[offset:offset+size]
    raise AssertionError(('address not in file-backed ELF section', hex(address), size))

root_inventory = {}
for name in ['gt_ggc_rtab', 'gt_ggc_deletable_rtab']:
    address, size = symbols[name]
    table_addresses = struct.unpack('<'+'Q'*(size//8), elf_bytes(address, size))
    assert table_addresses[-1] == 0 and all(table_addresses[:-1])
    records = []
    raw_tables = bytearray()
    callback_addresses = set()
    for table_address in table_addresses[:-1]:
        offset = 0
        while True:
            raw = elf_bytes(table_address+offset, 40)
            raw_tables.extend(raw)
            base, nelt, stride, cb, pch = struct.unpack('<QQQQQ', raw)
            if not base:
                assert (nelt, stride, cb, pch) == (0, 0, 0, 0)
                break
            assert nelt*stride <= 2**63-1 and base+(nelt-1)*stride+8 < 2**64
            if name == 'gt_ggc_rtab':
                assert cb != 0
            else:
                assert cb == pch == 0
            records.append((nelt, stride))
            callback_addresses.add(cb)
            offset += 40
    root_inventory[name] = {
        'table_count': len(table_addresses)-1,
        'root_record_count': len(records),
        'root_elements': sum(n for n, _ in records),
        'maximum_nelt': max(n for n, _ in records),
        'maximum_stride': max(s for _, s in records),
        'maximum_nelt_times_stride': max(n*s for n, s in records),
        'table_data_sha256': hashlib.sha256(raw_tables).hexdigest(),
        'distinct_callbacks': len(callback_addresses-{0}),
        'callbacks_not_exported_in_dynsym': [hex(c) for c in sorted(callback_addresses) if c and c not in names_by_address],
    }
assert root_inventory['gt_ggc_rtab']['root_record_count'] == 347
assert root_inventory['gt_ggc_rtab']['root_elements'] == 10426
assert root_inventory['gt_ggc_rtab']['distinct_callbacks'] == 115
assert root_inventory['gt_ggc_deletable_rtab']['root_record_count'] == 12
assert root_inventory['gt_ggc_deletable_rtab']['root_elements'] == 12
assert root_inventory['gt_ggc_rtab']['callbacks_not_exported_in_dynsym'] == ['0x9725b0', '0x972620', '0x104c290']
finalizers = sorted(name for name, (address, size) in symbols.items()
                    if address and name.startswith('_Z8finalizeI'))
assert len(finalizers) == 85
result = {
    'scope': identity['scope'], 'gcc_commit': identity['gcc_commit'],
    'complete_sources_verified': len(sources),
    'retained_inputs_verified': len(identity['reused_results']),
    'Ada_callbacks': {
        'fixed_layout_direct_Uint_maximum': 3584,
        'new_fixed_layout_Uint_Repinfo_or_annotation_cache_entries': 0,
        'new_postprefix_null_Uint_Repinfo_or_annotation_cache_entries': 0,
        'fixed_float_transfer': float_row,
        'fixed_capture_plus_float_deliberately_overcounts': True,
        'outgoing_table_demands': demands,
        'table_backing_checks': backing,
        'tables_remain_unlocked_through_gigi': True,
        'UI_Ints_new_wrapper_requests_at_most': 4096,
        'UI_Ints_wrapper_bytes': 16,
        'UI_Ints_static_bucket_bytes': 8184,
        'maximum_UI_Vector_words_at_all_joined_phases': local_words,
        'maximum_individual_UI_Vector_bytes_including_descriptor': 4*local_words+16,
        'new_GGC_events': 0,
    },
    'known_GGC_events_through_null_metadata': known,
    'null_value_expression_cache_marker': {
        'table_initialized_even_when_empty': True,
        'selected_null_value_expression_insertions': 0,
        'ordinary_hash_backing_requests_per_callback': 1,
        'ordinary_hash_slots': 13,
        'individual_ordinary_hash_backing_bytes': 104,
        'inline_vector_elements': 16,
        'selected_null_pushes': 0,
        'dynamic_vector_backing_requests': 0,
        'new_GGC_events': 0,
        'collector_call_count_not_used_as_capacity_condition': True,
    },
    'offline_static_collector_inventory': {
        'gnat1_sha256': binary_hash,
        'roots': root_inventory,
        'exported_typed_finalizer_candidates': len(finalizers),
        'finalizer_symbol_name_inventory_sha256': hashlib.sha256(('\n'.join(finalizers)+'\n').encode()).hexdigest(),
        'actual_selected_finalizer_registrations_inferred': False,
        'binary_executed': False,
    },
    'collector_backing_substitution': {
        'active_pages_at_most': known,
        'page_vector_capacity_at_most': page_capacity,
        'each_page_pointer_vector_bytes_at_most': 8*page_capacity,
        'finalizer_registrations_at_most': known,
        'each_finalizer_vector_capacity_at_most': finalizer_capacity,
        'scalar_finalizer_backing_bytes_at_most': 8+16*finalizer_capacity,
        'array_finalizer_backing_bytes_at_most': 8+32*finalizer_capacity,
        'context_depth': 0,
        'old_context_bitmap_backup_requests': 0,
        'individual_page_entry_bytes_at_most': 128,
        'page_quire_bytes': 2097152,
        'page_lookup_chain_bytes': 2064,
        'secondary_page_lookup_bytes': 32768,
        'depth_vector_bytes': 40,
        'each_outer_finalizer_vector_bytes': 40,
    },
    'collector_callback_closure': 'Selected generic/template routes inspected; complete generated-root/user-marker/finalizer census still required',
    'whole_collector_allocation_closure': False,
    'whole_process_capacity_established': False,
    'remaining_terms': ['Generated-root and all selected custom marker/finalizer closure',
                        'Whole-invocation process/library setup and teardown',
                        'Separate assembler/binder/linker/proof-producer composition'],
    'native_execution': False, 'aggregate_RAM_admission_gate': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'sources_verified': len(sources), 'retained_inputs_verified': len(identity['reused_results']),
                  'Ada_demands': demands, 'known_GGC_events': known, 'whole_collector_closed': False}))
