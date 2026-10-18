#!/usr/bin/env python3
"""Reconcile the selected null metadata transfer without running native tools."""
import argparse
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--ada-root', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-source-locations-source-identity.json').read_text())
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

anchors = {
    'back_end.adb': [
        'File_Info_Array : array (1 .. Last_Source_File) of File_Info_Type;',
        'File_Info_Array (J).File_Name        := Full_Debug_Name (J);',
        'max_gnat_node      => Int (Last_Node_Id - First_Node_Id + 1),'],
    'sinput.adb': ['Source_File.Init;', 'Instances.Append (No_Location);'],
    'gnat1drv.adb': ['System_Source_File_Index := S;'],
    'frontend.adb': ['if Opt.Config_File then', "for Index in Opt.Config_File_Names'Range loop"],
    'adaint.c': ['__gnat_to_canonical_file_spec (char *filespec)\n{\n  return filespec;\n}'],
    'gcc/ada/gcc-interface/trans.cc': [
        'if (Generate_SCO_Instance_Table != 0)',
        'for (i = 0; i < number_file; i++)',
        'linemap_line_start (line_table, file_info_ptr[i].Num_Source_Lines, 252);',
        'linemap_position_for_column (line_table, 252 - 1);',
        'return IDENTIFIER_POINTER (get_identifier (name));'],
    'gcc/ada/gcc-interface/utils.cc': [
        'associate_gnat_to_gnu = ggc_cleared_vec_alloc<tree> (max_gnat_nodes);',
        'dummy_node_table = ggc_cleared_vec_alloc<tree> (max_gnat_nodes);',
        'get_identifier (main_input_filename)'],
    'gcc/gimple-low.cc': [
        'gimple_set_block (stmt, data->block);',
        'gimple_set_block (x, DECL_INITIAL (current_function_decl));'],
    'gcc/tree-cfg.cc': ['return location_with_discriminator (loc, e.discrim);'],
    'gcc/gimple.h': ['gimple_set_location (g, set_block (g->location, block));'],
    'libcpp/line-map.cc': [
        'm_location_adhoc_data_map.allocated = 128;',
        'm_location_adhoc_data_map.allocated *= 2;',
        'htab_create (100, location_adhoc_data_hash, location_adhoc_data_eq, NULL);',
        'set->highest_location = RESERVED_LOCATION_COUNT - 1;'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)
assert 'get_or_create_combined_loc' not in sources['gcc/ada/gcc-interface/trans.cc']
assert 'TREE_SET_BLOCK' not in sources['gcc/ada/gcc-interface/trans.cc']
prior = json.loads((root / 'native-null-cgraph-lifecycle.json').read_text())
gimple = json.loads((root / 'native-null-initial-gimple.json').read_text())
indexed = json.loads((root / 'native-indexed-source-buffers.json').read_text())
assert prior['updated_selected_known_GGC_subtotal'] == 40086
assert indexed['additional_null_System_loads'] == 0
assert indexed['indexed_configuration_bytes'] == 327
assert gimple['incoming_shape']['SSA_live_statements_maximum'] == 3
assert gimple['incoming_shape']['edges'] == 4
assert gimple['SSA']['PHIs'] == 0

file_count = 3
filename_misses = file_count + 1
adhoc_requests = 5 + 3 + 4
assert adhoc_requests < 127 * 3 // 4
identifier_insertions = 39257 + 5 + filename_misses
assert identifier_insertions < 65536 * 3 // 4
line_ceiling = 2 ** 24
location_ceiling = 1 + file_count * (256 * (line_ceiling - 1) + 252) + 4
assert location_ceiling < 0x50000000 << 31
requests = [
    {'object': 'filename_identifier_nodes', 'events': filename_misses, 'individual_raw_bytes_at_most': 40},
    {'object': 'filename_NUL_strings', 'events': filename_misses, 'individual_raw_bytes_at_most': 32768},
    {'object': 'ordinary_line_map_vector', 'events': 1, 'individual_raw_bytes_at_most': 8192},
    {'object': 'GNAT_association_arrays', 'events': 2, 'individual_raw_bytes_at_most': 8 * (2 ** 31 - 1)},
    {'object': 'ad_hoc_location_backing', 'events': 1, 'individual_raw_bytes_at_most': 5120},
]
events = sum(row['events'] for row in requests)
assert events == 12
result = {
    'scope': identity['scope'], 'gcc_commit': identity['gcc_commit'],
    'complete_sources_verified': len(sources),
    'reused_results_verified': len(identity['reused_results']),
    'source_files_at_most': file_count,
    'source_file_roles': ['startup System', 'one selected -gnatec', 'single indexed Main'],
    'virtual_sources_and_macro_maps': 0,
    'Ada_file_info_array_component_bytes': 12,
    'Ada_file_info_array_bytes_at_most': file_count * 12,
    'source_line_maximum_required': line_ceiling,
    'maximum_encoded_location_with_later_columns': location_ceiling,
    'filename_spellings_at_most': filename_misses,
    'identifier_length_existing_requirement': 32767,
    'shared_identifier_insertions_at_most': identifier_insertions,
    'shared_identifier_table_slots_at_most': 65536,
    'shared_identifier_table_individual_bytes_at_most': 524288,
    'new_GGC_requests': requests,
    'new_GGC_events': events,
    'updated_selected_known_GGC_subtotal': prior['updated_selected_known_GGC_subtotal'] + events,
    'ad_hoc_location_requests_at_most': adhoc_requests,
    'ad_hoc_backing_capacity': 128,
    'ad_hoc_backing_rounded_bytes_at_most': 8192,
    'ordinary_ad_hoc_hash_control_bytes_at_most': 128,
    'ordinary_ad_hoc_hash_backing_bytes': 127 * 8,
    'GNAT_association_array_rounded_bytes_at_most': 2 ** 34,
    'input_requirements': [
        'Controlled selected invocation: one -gnatec, -gnatA, no target-description/JSON/SCO/PCH/LTO/debug inputs',
        'Declaration-free null Main source closure and indexed-null System reuse',
        'Existing complete-path descriptor and every interned spelling <=32767',
        'Positive last logical line <=16777216 for each actual physical file',
        'Existing frontend node inventory N=Last_Node_Id-First_Node_Id+1 <=IntLast',
    ],
    'remaining_terms': ['Ada Uint/Repinfo callbacks', 'Collector pages/finalizers',
                        'Whole-invocation process/library setup and teardown',
                        'Separate assembler/binder/linker/proof-producer composition'],
    'reachability_basis': 'Handwritten selected-route source argument; anchors do not prove reachability',
    'complete_capacity_result': False, 'native_execution': False,
    'aggregate_RAM_admission_gate': False,
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'sources_verified': len(sources), 'reused_results_verified': len(identity['reused_results']),
                  'new_GGC_events': events, 'known_GGC_subtotal': result['updated_selected_known_GGC_subtotal']}))
