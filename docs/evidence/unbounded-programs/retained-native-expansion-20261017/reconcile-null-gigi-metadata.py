#!/usr/bin/env python3
"""Check null gigi cache/name and unit-order container joins offline."""
import argparse
import hashlib
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--ada', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-gigi-metadata-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    base = args.gcc_root if row['root'] == 'gcc' else args.ada
    raw = (base / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in identity['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']

anchors = {
    'gcc/stringpool.cc': ['ident_hash = ht_create (14);',
                          'ident_hash->alloc_subobject = stringpool_ggc_alloc;',
                          'return GCC_IDENT_TO_HT_IDENT (make_node (IDENTIFIER_NODE));'],
    'libcpp/symtab.cc': ['table->alloc_subobject (len + 1)',
                       'if (++table->nelements * 4 >= table->nslots * 3)',
                       'size = table->nslots * 2;'],
    'gcc/ada/gcc-interface/misc.cc': ['#define LANG_HOOKS_IDENTIFIER_SIZE\tsizeof (struct tree_identifier)'],
    'gcc/ada/gcc-interface/utils.cc': ['vec_safe_push (global_decls, decl);',
                                    'associate_gnat_to_gnu[(GNAT_ENTITY) - First_Node_Id] = (VAL)',
                                    'if (No (gnat_node)', 'suppress_warning (decl);'],
    'gcc/tree-iterator.cc': ['vec_safe_push (stmt_list_cache, t);'],
    'gcc/vec.cc': ['alloc = alloc * 2;', 'alloc = (alloc * 3 / 2);'],
    'gcc/vec.h': ['size = ::ggc_round_alloc_size (size);',
                  'v = static_cast <vec<T, A, vl_embed> *> (::ggc_realloc (v, size'],
    'gcc/gcc-diagnostic-spec.cc': ['nowarn_map = nowarn_map_t::create_ggc (32);',
                                  'nowarn_map->put (loc, optspec);'],
    'gcc/hash-map.h': ['hash_map *map = ggc_alloc<hash_map> ();'],
    'gcc/hash-table.h': ['if (insert == INSERT && m_size * 3 <= m_n_elements * 4)',
                        'nindex = hash_table_higher_prime_index (elts * 2);'],
    'gcc/varasm.cc': ['if (first_global_object_name'],
    'gcc/ada/gcc-interface/trans.cc': ['first_global_object_name = ggc_strdup (IDENTIFIER_POINTER (t));',
                                    't = create_concat_name (Defining_Entity (Unit (gnat_root)), NULL);',
                                    'void_ftype = build_function_type_list (void_type_node, NULL_TREE);',
                                    'tree stmt, label = create_label_decl (NULL_TREE, gnat_node);'],
    'gcc/tree.cc': ['t = cache_wide_int_in_type_cache (type, cst, ix, limit);'],
    'gcc/config/i386/i386.h': ['#define FUNCTION_BOUNDARY 8'],
    'gcc/params.opt': ['Var(param_integer_share_limit) Init(251)'],
    'exp_dbug.adb': ['Get_Name_String (Chars (E));',
                     'Add_Str_To_Name_Buffer ("_ada_");',
                     'Add_Str_To_Name_Buffer ("___");'],
    'gcc/cgraphunit.cc': ['auto_vec<cgraph_order_sort> nodes;',
                          'cgraph_node **order = XCNEWVEC (cgraph_node *,',
                          'cgraph_node **tp_first_run_order = XCNEWVEC (cgraph_node *,',
                          '&& !DECL_HARD_REGISTER (vnode->decl)'],
    'gcc/ipa-utils.cc': ['XCNEWVEC (struct postorder_stack, symtab->cgraph_count);'],
}
for name, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[name], (name, fragment)

# Reuse the reviewed target-closure identity, checking its source bytes too.
target_manifest = json.loads((root / 'null-symbols-source-identity.json').read_text())
by_path = {row['path']: row for row in target_manifest['files']}
for name in target_manifest['selected_target_headers']:
    raw = (args.gcc_root / name).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == by_path[name]['sha256']
    for token in ['TARGET_OPTION_RELAYOUT_FUNCTION', 'SUBTARGET_MANGLE_DECL_ASSEMBLER_NAME']:
        assert token not in raw.decode(), (name, token)

prefix = json.loads((root / 'native-gcc-prefix-witness.json').read_text())
histogram = prefix['rounded_GGC_allocation_histogram']
prefix_events = sum(row['events'] for row in histogram)
prefix_bytes = sum(row['bytes']*row['events'] for row in histogram)
assert (prefix_events, prefix_bytes) == (39257,3318816)

names = ['main___elabb', 'main', '_ada_main']
assert [len(x)+1 for x in names] == [13,5,10]
identifier_slots = 1 << 14
while (prefix_events+len(names))*4 >= identifier_slots*3:
    identifier_slots *= 2
assert identifier_slots == 65536

# Prefix vector/hash backing is independent of raw source/path metadata.
# Seed each such individual object by the entire retained allocation sum.
# This is a deliberately coarse single-object upper bound, not a RAM gate.
vector_bounds = [prefix_bytes]
for _ in range(2):
    vector_bounds.append(4*(vector_bounds[-1]+16))
assert vector_bounds[-1] == 53101376
# The selected prime table has next-prime(n) <= 3*n for n >= 7.
# Expansion requests at most next-prime(2*old_slots), hence <=6*old bytes.
prime_region = sources['gcc/hash-table.cc'].split('struct prime_ent const prime_tab[] = {',1)[1].split('};',1)[0]
primes = [int(x) for x in re.findall(r'\{\s+(\d+),',prime_region)]
assert primes[:4] == [7,13,31,61]
assert all(b <= 3*(a+1) for a,b in zip(primes,primes[1:]))
warning_bounds = [prefix_bytes]
for _ in range(3):
    warning_bounds.append(6*warning_bounds[-1])
assert warning_bounds[-1] == 716864256
assert warning_bounds[-1] < 2**30
assert (warning_bounds[-1]//8)*4 < 2**32
assert vector_bounds[-1]//8 < 2**31

rows = [
    dict(object='three identifier nodes and their strings', requests=6,
         node_raw_bytes=40, string_raw_bytes=[13,5,10]),
    dict(object='global_decls backing for two additional pushes', requests=2,
         raw_bytes_upper=vector_bounds[-1]),
    dict(object='stmt_list_cache backing for at most five frees', requests=5,
         raw_bytes_upper=144),
    dict(object='one canonical FUNCTION_TYPE hash lookup growth', requests=1,
         raw_bytes_upper=6*prefix_bytes),
    dict(object='warning-map control/entries for at most three suppressions', requests=4,
         control_raw_bytes_upper=128, entries_raw_bytes_upper=warning_bounds[-1]),
]
events = sum(row['requests'] for row in rows)
assert events == 18
result = dict(
    scope='Selected null gigi names/shared caches and whole-unit output-order containers',
    gcc_commit=identity['gcc_commit'], checked_source_identities=len(sources),
    selected_target_headers_checked=len(target_manifest['selected_target_headers']),
    fixed_prefix_individual_container_seed_bytes=prefix_bytes,
    seed_scope='Only source-independent global_decls/type-hash/warning-map backing; source maps, variable pathname strings and association arrays excluded',
    objects=rows, GGC_event_allowance=events,
    existing_selected_known_GGC_subtotal=40006,
    updated_selected_known_GGC_subtotal=40006+events,
    ordinary_identifier_hash=dict(slots_upper=identifier_slots, raw_array_bytes_upper=identifier_slots*8,
                                  live_plus_deleted_insertions_upper=prefix_events+3),
    first_global_object_name_already_initialized_in_prefix=True,
    canonical_function_layout_new_constant_requests=0,
    no_new_deferred_context_record_or_association_array=True,
    unit_ordering=dict(function_nodes_upper=1, asm_nodes=0, hard_register_dummy_omitted=True,
                      order_array_bytes_upper=8, time_profile_order_array_bytes_upper=8,
                      reverse_postorder_stack_bytes_upper=24,
                      source_order_vector_requested_capacity_upper=4,
                      source_order_vector_raw_bytes_upper=104,
                      additional_GGC_requests=0),
    required_remaining_inputs=[
        'Source/path/line-map and Ada callback metadata corrections',
        'cgraph creation/registration and IPA, initial GIMPLE/CFG/SSA allocations',
        'Forced dummy symbol creation and remaining whole-unit emission callbacks',
        'Collector pages/finalizers and non-DF shared pool retained-count composition'],
    aggregate_RAM_admission_gate=False,
    native_execution=False, complete_capacity_result=False)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
print(json.dumps(dict(identities=len(sources), added_GGC_events=events,
                     known_subtotal=40006+events, complete_capacity_result=False)))
