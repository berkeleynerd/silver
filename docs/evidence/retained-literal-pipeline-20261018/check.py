#!/usr/bin/env python3
"""Check shared source counters, descriptor binding and the honest open verdict."""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import tempfile
import time

HERE = Path(__file__).resolve().parent


def main():
    started=datetime.now(timezone.utc).isoformat()
    timer=time.perf_counter()
    spec=importlib.util.spec_from_file_location('literal_pipeline',HERE/'compose.py')
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    parser=argparse.ArgumentParser(description=__doc__)
    module.arguments(parser)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    context=module.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    fixture=module.read(HERE/'fixture.json')
    fixture['source']=str((HERE/fixture['source']).resolve())
    fixture['shared_inputs']={role:str((HERE/path).resolve())
                              for role,path in fixture['shared_inputs'].items()}
    original=Path(fixture['source']).read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    tail=b'\nend Main;\n'
    rows=[]
    with tempfile.TemporaryDirectory(prefix='silver-literal-aggregate-check-') as temporary:
        root=Path(temporary)
        descriptor, source=root/'descriptor.json',root/'main.adb'

        def evaluate(raw, changed=None):
            descriptor.write_text(json.dumps(changed or fixture))
            source.write_bytes(raw)
            result=module.evaluate(descriptor,context,source)
            assert not result['whole_literal_pipeline_capacity_established']
            assert result['next_repair']=='native_remaining_lifetime_and_collector'
            assert result['native_tool_executions']==0
            return result

        variants=[
            ('retained',original,1,0,13),
            ('case_CRLF',original.upper().replace(b'\n',b'\r\n'),1,0,13),
            ('equal_literals_are_distinct',shell+b'Silver_IO.Put ("x");\nnull;\nSilver_IO.Put_Line ("x");'+tail,2,1,2),
            ('quotes_empty_and_comment',shell+b'-- Silver_IO.Put ("ignored");\nSilver_IO.Put ("a""b"); Silver_IO.Put_Line ("");'+tail,2,0,3),
            ('literal_keyword_is_not_procedure',shell+b'Silver_IO.Put ("Put_Line"); null; Silver_IO.Put ("a""b"); null;'+tail,2,2,11),
            ('literal_scratch_boundary',shell+b'Silver_IO.Put ("'+b'a'*999+b'"); null; Silver_IO.Put_Line ("'+b'b'*1000+b'"); Silver_IO.Put ("");'+tail,3,1,1999),
            ('comments_above_old_cap',b'-- ordinary comment\n'*300+original,1,0,13),
            ('literal_above_old_cap',shell+b'Silver_IO.Put ("'+b'a'*8192+b'");'+tail,1,0,8192),
            ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail,5000,0,5000),
        ]
        for name,raw,c,n,characters in variants:
            result=evaluate(raw)
            counts=result['source_counts']
            assert (counts['output_calls'],counts['null_statements'],counts['decoded_literal_bytes']) == (c,n,characters)
            assert result['Why_core']['K']==result['Why_core']['K_literal']==c
            assert result['Why_source_counts']['H_chars']==characters
            assert result['Why_core']['V']==2*c
            assert result['RTL_shape']['first_unused_pseudo_number_upper']==99+5*c
            frontend=result['native_Main_frontend_interface']
            assert frontend['selected_source']==counts
            assert frontend['Main_counts']['word_tokens']==result['Why_source_counts']['W']
            assert frontend['Main_constructor']['total']['node_identities']==41+19*c+4*n
            assert frontend['gigi_source_interface']['Main_source_syntax_visit_bound']==73+81*c+4*n
            assert frontend['gigi_source_interface']['separate_fixed_frontend_allowance']==dict(
                node_identities=None,entity_identities=None)
            assert not frontend['attachment_status']['complete_native_frontend']
            assert not frontend['attachment_status']['complete_gigi_allocation']
            assert not frontend['attachment_status']['complete_native_capacity']
            collector=result['native_collector_callbacks']
            assert collector['source_counts']==counts
            assert collector['collector_callback_additional_GGC_events']==0
            assert collector['value_expression_marker']['each_ordinary_hash_backing_bytes']==104
            assert collector['total_GGC_events'] is None
            assert collector['collector_page_and_finalizer_backing'] is None
            assert not collector['complete_collector_lifetime_closed']
            original_helper=result['native_original_helper_storage']
            original_interface=original_helper['interface']
            assert original_interface==context.original_helper_expected
            assert original_interface['GGC_events']==94
            assert original_interface['top_level_substitute_in_expr_calls']==4
            assert original_helper['ordinary_requests']==2
            assert original_helper['ordinary_caller_bytes_sum_ceiling']==80
            name_input=original_helper['name_input']
            f=len(fixture['launch']['native_Main'].encode('ascii'))
            local_p=max(9,f+28)
            assert name_input['first_global_object_name']=='_ada_main'
            assert name_input['filename_bytes_excluding_NUL']==f
            assert name_input['local_cleaned_component_bound']==local_p
            assert original_helper['evaluated_requests']==dict(P=local_p,GGC_events=94,
                GGC_caller_bytes_sum_ceiling=6832+2*local_p,
                GGC_rounded_slots_sum_ceiling=7912+2*context.original_helper['rho'](local_p+33))
            assert original_helper['identity_demands']['fresh_DECL_UIDs']==8
            assert original_helper['identity_demands']['fresh_type_UIDs_ceiling']==4
            assert original_helper['incoming_private_name_fnno']==0
            assert original_helper['next_private_name_fnno']==2
            assert original_helper['incoming_next_DECL_UID'] is None
            assert original_helper['incoming_next_type_UID'] is None
            assert original_helper['shared_container_demands']['identifier_insertion_capable_lookups']==6
            assert original_helper['shared_container_demands']['identifier_new_entries_ceiling']==4
            assert original_helper['shared_container_demands']['type_hash_insertion_capable_lookups']==2
            assert original_helper['shared_container_demands']['type_hash_new_records_ceiling']==2
            assert original_helper['shared_container_backing'] is None
            assert original_helper['complete_imported_allocation_events'] is None
            assert original_helper['complete_imported_allocation_bytes'] is None
            assert not original_helper['complete_global_counter_lifetime_closed']
            assert not original_helper['complete_collector_lifetime_closed']
            assert not original_helper['whole_literal_pipeline_capacity_established']
            assert result['native_original_helper_source_validation']['complete_source_files_verified']==27
            original_string=result['native_original_String_storage']
            original_main=result['native_original_Main_storage']
            assert original_string['interface']==context.original_string_expected
            assert original_string['helper94_additions']==1
            assert original_string['synthetic173_additions']==original_string['null_helper11_additions']==0
            assert original_string['cold_String_including_helpers']==dict(GGC_events=310,
                GGC_caller_bytes=13149+6832+2*local_p,
                GGC_separately_rounded_bytes=17112+7912+2*context.original_helper['rho'](local_p+33),
                ordinary_requests=5,ordinary_caller_bytes=272)
            assert original_string['corrected_integer_constant_storage']==dict(
                precision_bits=128,value_words=2,extended_words=3,typed_prefix_bytes=16,caller_bytes=40)
            assert original_string['identity_demands']==dict(DECL_UID=13,type_UID=10,alias_ID=1)
            assert original_string['shared_container_demands']==dict(identifier_lookups=11,
                identifier_new_entries=11,identifier_character_bytes=93,global_decls_pushes=5,
                alias_sets_pushes_envelope=2,large_integer_insertion_capable_lookups_envelope=129,
                large_integer_new_entries_envelope=129,small_integer_cache_writes_envelope=129,
                new_integer_cache_vectors=0,type_hash_insertion_capable_lookups=0,finalizers=0)
            d=int(counts['Put']>0)+int(counts['Put_Line']>0)
            lengths=counts['decoded_literal_lengths']
            main_leaf=original_main['interface']
            assert main_leaf['inputs']==dict(C=c,N=n,D=d,lengths=lengths,I=114)
            assert main_leaf['derived']['V']==frontend['gigi_source_interface']['Main_source_syntax_visit_bound']
            assert main_leaf['conditional_direct_totals']['GGC_events']==609*c+24*n+54*d+284+114
            assert all(main_leaf['conditional_direct_totals'][key]==
                value['constant']+114*value['I_coefficient']
                for key,value in main_leaf['symbolic_direct_totals'].items())
            assert main_leaf['ordinary_literal_scratch']==dict(requests=sum(x>=1000 for x in lengths),
                caller_bytes=sum(x for x in lengths if x>=1000),
                largest_alloca_bytes=max((x for x in lengths if x<1000),default=0))
            assert original_main['shared_container_demands']==dict(identifier_lookups=c+4*d+5,
                type_hash_lookups=2*(d+1),integer_hash_lookups=164*c+16*d+8,global_decls_pushes=d+3,
                stmt_list_cache_pushes=dict(constant=151+167*c+12*n,I_coefficient=1),
                alias_sets_pushes=2,scalar_finalizer_vector_pushes=1,
                Uint_entries=2*c,Udigits_words=10*c,UI_Ints_wrapper_calls=2*c)
            assert original_main['identity_demands']==dict(DECL_UID=2*c+n+3*d+5,
                type_UID=6*c+5*d+3,alias_ID=1,function_definition_numbers=0,
                helper_name_fnno=0,annotation_var_count=0)
            assert original_main['evaluated_stmt_list_cache_pushes_upper']==151+167*c+12*n+114
            assert original_main['fixed_context_I']==114 and original_main['fixed_context_I_source_bound_established']
            assert original_main['fixed_context_interface']==context.context_visits_expected['context_input']
            assert original_main['helper94_additions']==original_main['synthetic173_additions']==0
            assert original_main['null_helper11_additions']==0
            assert original_main['historical_null_structural_and_name_packets_additions']==0
            assert main_leaf['original_tree_constant_pool_demands']['independent_review_pending']
            assert original_main['fixed_context_interface']['independent_review_pending']
            for attached in (original_string,original_main):
                assert attached['shared_container_backing'] is None
                assert attached['incoming_global_counters'] is None
                assert attached['complete_imported_allocation_events'] is None
                assert attached['complete_imported_allocation_bytes'] is None
                assert not attached['complete_global_counter_lifetime_closed']
                assert not attached['complete_collector_lifetime_closed']
                assert not attached['whole_literal_pipeline_capacity_established']
            assert result['native_original_storage_source_validation']['fixed_context']['complete_files_verified']==2320
            assert result['native_original_storage_source_validation']['String']['complete_files_verified']==34
            assert result['native_original_storage_source_validation']['Main']['complete_files_verified']==46
            assert result['native_original_storage_source_validation']['Main']['direct_files_verified']==45
            assert result['native_original_storage_source_validation']['Main']['historical_repository_files_verified']==1
            assert result['native_original_storage_source_validation']['String']['direct_files_verified']==34
            assert result['native_original_storage_source_validation']['String']['historical_repository_files_verified']==0
            synthetic=result['native_synthetic_function_storage']
            assert synthetic['function_structure_calls']==3
            assert synthetic['initial_helper_gimplifications']==2
            assert synthetic['GGC_events']==173
            assert synthetic['GGC_events']==sum(row['requests'] for row in synthetic['GGC_groups'])
            registers=[row for row in synthetic['GGC_groups'] if row['family']=='return_ABI_hard_REG']
            assert len(registers)==1 and registers[0]['requests']==6
            assert registers[0]['caller_bytes']==24
            assert synthetic['ordinary_requests']==8
            assert synthetic['identity_demands']['function_definition_numbers']==3
            assert synthetic['shared_container_demands']['singleton_finalizer_registrations']==2
            assert not result['native_unit_frontier']['synthetic_counter_no_wrap_established']
            assert not synthetic['original_gigi_predecessor_construction_included']
            assert not synthetic['cgraph_nodes_and_symbol_map_backing_included']
            pools=result['native_pool_lifetime']
            assert pools['source_input'] == dict(
                bounds_finalize_calls_upper=c,pool_entries_upper=2*c,insertion_capable_pool_lookups_upper=3*c)
            assert pools['incoming_tree_pool']['live_upper']==39257
            assert pools['incoming_tree_pool']['capacity_upper']==131071
            assert pools['tree_pool']['live_upper']==39257+2*c
            assert pools['tree_pool']['replacement_requests_upper']==3*c
            assert pools['symbols']['cold_String_helper_nodes']==2
            assert pools['symbols']['registered_nodes_upper']==c+6
            assert pools['symbols']['next_uid_upper']==c+7
            assert pools['symbols']['order_upper']==c+6
            assert pools['bounds_lifecycle']['initializer_outgoing_references']==0
            assert pools['additional_GGC_request_events_upper']==5*c+7
            assert pools['conditional_arithmetic_fits']
            assert pools['named_consumer_closed']
            assert pools['selected_imported_tree_pool_frontier_established']
            assert result['conditions']['native_varpool_and_shared_tree_pool']
            assert pools['imported_tree_pool_demands']==dict(original_Main_context_profiles=0,
                cold_String_residual216=0,original_helpers94=0,synthetic173=0,
                implicit_with_visits_independent=True,
                source_review='docs/reviews/review-original-native-storage-round9.md')
            assert not pools['imported_constructor_frontier_established']
            assert 'native_varpool_and_shared_tree_pool' not in result['open_joins']
            graph=result['native_graph_lifetime']
            assert graph['edge_creation_events_upper']==4*c
            assert graph['edge_uid_endpoint_upper']==4*c+1
            assert graph['call_summary_ID_high_water_upper']==c
            assert graph['additional_GGC_request_events_upper']==8*c+35
            assert graph['additional_registered_symbols']==2
            assert graph['cold_helper_summary_ID_assignments']==0
            cleanup=[row for row in graph['individual_GGC_request_groups']
                     if row['object']=='call-site hash terminal-empty backing']
            assert len(cleanup)==1 and cleanup[0]['requests_upper']==4
            assert cleanup[0]['raw_bytes_upper']==8*graph['call_site_hash_slots_upper']
            assert graph['conditional_arithmetic_fits']
            assert graph['conditional_graph_and_summary_lifetime_closed']
            assert graph['selected_graph_constructor_frontier_established']
            assert result['conditions']['native_graph_and_summary_lifetime']
            assert not graph['imported_constructor_frontier_established']
            counter=result['native_counter_emission_interface']
            assert counter['calls']==c and counter['null_statements']==n
            assert counter['interface']==context.counter_expected==context.counter['interface']()
            assert counter['symbol_registrations_upper']==pools['symbols']['registered_nodes_upper']==c+6
            assert counter['next_symbol_UID_upper']==c+7
            assert counter['next_symbol_order_upper']==c+6
            assert counter['interface']['function_definition_numbers']==dict(
                empty_elaboration=0,Main=1,String_bit_size_helper=2,String_byte_size_helper=3)
            assert counter['interface']['next_function_definition_number']==4
            assert counter['interface']['main_function_boundary_labels']==['.LFB1','.LFE1']
            assert counter['interface']['empty_elaboration_symbol_registrations']==0
            assert not counter['interface']['complete_global_counter_lifetime_closed']
            assert not counter['interface']['complete_collector_lifetime_closed']
            assert counter['interface']['complete_imported_allocation_events'] is None
            assert counter['interface']['complete_imported_allocation_bytes'] is None
            assert result['conditions']['native_function_and_symbol_counter_endpoints']
            assert result['native_counter_source_validation']['complete_source_files_verified']==48
            helpers=result['native_SSA_helper_backing']
            assert helpers['source_input']['SSA_slots_upper']==3*c+2
            assert helpers['conditional_SSA_helper_backing_closed']
            assert helpers['additional_GGC_request_events_upper']==0
            assert helpers['out_of_SSA']['real_partitions']==0
            initial=result['native_initial_SSA_lifetime']
            assert initial['conditional_initial_SSA_lifetime_closed']
            assert initial['source_input']['SSA_slots_upper']==3*c+2
            assert initial['source_input']['memory_uses_upper']==3*c+1
            assert initial['additional_singleton_finalizer_registrations_upper']==1
            assert initial['additional_global_SSA_name_creation_events_upper']==3*c+1
            assert not initial['global_SSA_creation_counter_lifetime_closed']
            cfg=result['native_initial_CF_CFG_lifetime']
            assert cfg['conditional_initial_CF_CFG_lifetime_closed']
            assert cfg['source_input']['initial_CFG_block_slots_upper']==n+4
            assert cfg['source_input']['post_goto_statements_upper']==3*c+n+2
            assert cfg['additional_singleton_finalizer_registrations_upper']==0
            direct=cfg['direct_gimplifier_interface']
            assert direct['direct_site_GGC_request_events_upper']==10*c+2*n+2
            assert direct['retained_source_bind_tuples_upper']==c+1
            assert direct['initial_tuple_requests_upper']==4*c+2*n+2
            assert direct['simultaneous_bind_depth_upper']==2
            assert direct['bind_stack_allocated_slots_upper']==16
            assert direct['bind_stack_bytes']==136
            assert direct['bind_stack_backing_requests_upper']==2
            assert direct['bind_stack_cumulative_requested_bytes_upper']==208
            assert cfg['additional_CF_block_location_requests_upper']==4*c+2*n+2
            assert not cfg['direct_gimplifier_interface']['complete_gimplifier_lifetime_closed']
            assert not cfg['shared_metadata_bitmap_ET_pool_and_global_counters_closed']
            gimplifier=result['native_gimplifier_selected_helpers']
            assert gimplifier['source_input']==dict(calls=c,nulls=n)
            assert gimplifier['selected_site_GGC_request_events_upper']==6*c
            assert gimplifier['bounds_address_pointer_type_cache_misses']==0
            assert gimplifier['selected_GIMPLE_folding']['generated_matcher_dispatches']==0
            assert gimplifier['selected_GIMPLE_folding']['replacement_tree_or_tuple_allocations']==0
            assert gimplifier['direct_warning_copy_interface']['copy_warning_calls_upper']==c+1
            assert not gimplifier['direct_warning_copy_interface']['backing_requests_priced']
            assert gimplifier['whole_body_copy_weight_upper'] is None
            assert gimplifier['data_address_subtree_copy_requests_upper'] is None
            assert gimplifier['complete_gimplifier_GGC_request_events_upper'] is None
            assert not gimplifier['complete_gimplifier_lifetime_closed']
            vectors=[row for row in gimplifier['individual_GGC_request_groups']
                     if row['object']=='materialization copied constructor element vector']
            assert len(vectors)==1 and vectors[0]['requests_upper']==2*c
            assert vectors[0]['logical_elements']==2
            assert vectors[0]['initial_reserved_elements']==4
            assert vectors[0]['bytes_before_GC_rounding']==72
            assert vectors[0]['raw_bytes_upper']==128
            ingress=result['native_gimplifier_ingress']
            assert ingress['source_input']['calls']==c and ingress['source_input']['nulls']==n
            assert ingress['whole_body_copy_weight_upper']==9*c+3*n+1
            assert ingress['whole_body_GGC_request_events_upper']==33*c+9*n+3
            assert ingress['materialization_data_address_delta']['tree_requests_upper']==2*c
            assert ingress['selected_helper_subtotal_GGC_events_upper']==8*c
            assert ingress['protected_set']['distinct_entries_upper']==c+1
            assert result['conditions']['native_whole_body_copy_local_interface']
            protected=result['native_unshare_protected_set_storage']
            assert protected['source_input']['distinct_protected_entries_upper']==c+1
            assert protected['object_request_bytes_upper']==64
            assert protected['backing_requests_upper']==c+2
            assert protected['additional_GGC_request_events_upper']==0
            assert protected['conditional_protected_set_storage_closed']
            warning=result['native_warning_map_demand']
            assert warning['prefix_capacity_ceiling']==4093
            assert warning['direct_warning_copy_calls']==c+1
            assert warning['selected_initial_gimplifier_warning_put_call_ceiling']==2*c+1
            assert warning['local_gigi_suppression_call_ceiling']==2*c+n
            assert warning['other_original_gigi_put_calls']==5
            assert warning['original_gigi_source_count_closed']
            warning_map=warning['conditional_map_transfer']
            assert warning_map['original_gigi_put_call_ceiling']==2*c+n+5
            assert warning_map['outgoing_live_or_occupied_ceiling']==4099+4*c+n
            assert warning_map['additive_GGC_event_ceiling']==4*c+n+7
            assert result['conditions']['native_initial_warning_map_lifetime']
            assert not ingress['complete_gimplifier_lifetime_closed']
            assert ingress['complete_gimplifier_GGC_request_events_upper'] is None
            assembler=result['Main_assembler_object_interface']
            assert assembler['local_interface_fits']
            emission=result['native_complete_emission_interface']
            assert emission['source_identity']==module.identity(raw)
            assert emission['source_counts']==counts
            assert emission['counts']==assembler['counts']
            assert emission['assembly']==assembler['assembly']
            assert emission['final_chain']==result['RTL_shape']['final_chain']
            assert emission['counter_bounds']['ordinary_label_next_at_exit_upper']==39258+7*c+7*n+45
            assert emission['counter_bounds']['constant_label_next_at_exit_upper']==39257+2*c
            assert emission['counter_and_emission_guards_fit']
            assert result['conditions']['native_global_RTL_label_endpoint']
            assert result['conditions']['native_global_constant_label_endpoint']
            assert emission['complete_selected_stream_source_correspondence_conditional']
            assert not emission['production_invocation_and_materialization_established']
            assert not emission['complete_non_label_global_counter_lifetime_closed']
            assert not emission['complete_shared_backing_and_collector_capacity_closed']
            verification=result['native_emission_source_validation']
            assert verification['complete_source_files_verified']==44
            assert verification['current_predecessor_repository_files_verified']==32
            assert verification['historical_predecessor_repository_files_verified']==1
            assert verification['direct_files_verified']==76
            assert verification['historical_predecessor_paths']==[
                'docs/evidence/retained-literal-pipeline-20261018/compose.py']
            assert verification['historical_repository_revision']=='13daeca1e97eef2d0894f6f5175789677df54ce9'
            assert result['native_emission_review']==context.emission_review
            assert result['native_emission_review']['closes_selected_label_sources_and_complete_compiler_stream']
            assert not result['native_emission_review']['establishes_production_invocation_or_complete_capacity']
            storage=result['Main_GAS_BFD_storage']
            assert storage['selected_GAS_BFD_storage_fits']
            assert storage['path_bytes']==fixture['complete_path_bound']+1
            assert result['conditional_conditions']['Main_GAS_BFD_storage']
            assert result['conditions']['Main_GAS_BFD_storage'] is None
            assert assembler['source_identity']==module.identity(raw)
            assert assembler['text_bytes_upper']==result['RTL_shape']['shortening_text_bytes_upper']
            linker=result['literal_output_linker']
            assert linker['source_identity']==module.identity(raw)
            assert linker['counts']==assembler['counts']
            assert result['linker_path_bytes_including_NUL_upper']==fixture['complete_path_bound']+1
            assert linker['link']['Main_external_size_sum_upper']==assembler['text_bytes_upper']
            ali=result['Main_ALI_interface']
            assert ali['source']==module.identity(raw) and ali['source_counts']==counts
            assert ali['path_spelling_bytes_upper']==fixture['complete_path_bound']
            assert ali['selected_Main_ALI_interface_fits']
            assert not ali['whole_binder_or_parent_capacity_established']
            consumers=result['ALI_consumer_interfaces']
            assert consumers['Main_ALI_interface']==ali
            assert consumers['selected_ALI_consumer_local_interfaces_fit']
            assert not consumers['native_parser_name_contribution']['complete_pool_backing_established']
            assert not consumers['Gprbind_Main_reader']['complete_name_vector_backing_established']
            assert not consumers['parent_GPRbuild_DW_reader_capacity_established']
            assert not consumers['whole_binder_or_parent_capacity_established']
            parent=result['native_GPR_parent_DW_interface']
            assert parent['source']==module.identity(raw) and parent['source_counts']==counts
            assert parent['Main_ALI_interface']==ali
            assert parent['path_spelling_bytes_upper']==fixture['complete_path_bound']
            assert parent['selected_parent_DW_reader_local_interface_fits']
            assert parent['schedule']['Phase_2_ALI_DW_calls_upper']==3
            assert parent['schedule']['Record_ALI_For_additional_W_reads_upper']==0
            assert parent['parser_name_contribution']['entry_events_upper']==5470
            assert parent['parser_name_contribution']['value_bytes_upper']==6225037
            assert not parent['fixed_child_regeneration_correspondence_established']
            assert not parent['complete_GPR_Names_backing_established']
            assert not parent['whole_native_parent_capacity_established']
            assert not parent['output_launch_descriptor_materialized']
            expected=True
            assert result['conditional_arithmetic_pass']==expected,(name,result['failed_conditional_predicates'])
            assert not result['evaluated_predicates_pass']
            assert result['failed_predicates']==[]
            assert set(result['unresolved_predicates'])=={
                'Main_assembler_object_interface','Main_GAS_BFD_storage',
                'literal_output_linker_representation'}
            frontier=result['native_unit_frontier']
            assert frontier==result['open_joins']['native_post_prefix_imported_frontier']
            assert not frontier['Main_is_only_defined_body_established']
            assert frontier['Main_is_only_emitted_body_established']
            assert frontier['additional_imported_pool_symbol_events_upper'] is None
            assert frontier['additional_imported_defined_bodies_upper']==2
            assert frontier['additional_emitted_stream_interface']==dict(
                emitted_non_Main_functions=0,additional_non_Main_emitted_lines=0)
            assert frontier['cold_String_layout']==context.cold_string
            assert frontier['cold_String_layout']['helper_emitted_functions']==0
            assert frontier['cold_String_layout']['helper_allocation_bytes'] is None
            assert frontier['selected_generated_function_frontier']['non_Main_function_definition_number_increment']==3
            assert frontier['selected_generated_function_frontier']['empty_elaboration']['allocation_request_events'] is None
            assert frontier['selected_generated_function_frontier']['empty_elaboration']['symbol_registration_count'] is None
            assert frontier['selected_counter_emission_interface']==counter
            assert frontier['selected_complete_emission_interface']==emission
            assert frontier['selected_complete_emission_review']==context.emission_review
            assert frontier['selected_whole_stream_and_label_sources_closed']
            assert not frontier['production_invocation_and_materialization_established']
            assert frontier['selected_empty_elaboration_symbol_registration_established']
            assert frontier['selected_function_and_symbol_counter_to_name_join_established']
            assert not frontier['complete_global_counter_lifetime_closed']
            assert not frontier['complete_collector_lifetime_closed']
            assert frontier['complete_imported_allocation_events'] is None
            assert frontier['complete_imported_allocation_bytes'] is None
            assessments=frontier['source_family_condition_assessments']
            assert len(assessments)==5
            assert {key for key,row in assessments.items() if row['source_family_premises_closed']}=={
                'native_varpool_and_shared_tree_pool','native_graph_and_summary_lifetime'}
            assert assessments['native_varpool_and_shared_tree_pool']['residual'] is None
            assert assessments['native_graph_and_summary_lifetime']['residual'] is None
            assert all(assessments[key]['residual'] for key in result['unresolved_predicates'])
            for key in result['unresolved_predicates']:
                assert assessments[key]['selected_emission_source_premises_closed']
                assert not assessments[key]['production_invocation_materialized']
                assert 'production' in assessments[key]['residual']
            assert result['literal_output_linker_historical_conservative']['link']['failed_sufficient_checks']==(
                ['fixed_signed_relocation_reach'] if name=='5000_calls' else [])
            assert linker['link']['failed_sufficient_checks']==[]
            if name=='5000_calls':
                assert result['failed_conditional_predicates']==[]
            if name in ('literal_above_old_cap','5000_calls'):
                assert not result['Why_core']['producer_core_fits']
                assert result['selected_Why_core']['literal_Main_core_fits']
                assert result['selected_Why_core']['Main_gnat_json_bytes']==0
            rows.append(dict(case=name,source_bytes=len(raw),calls=c,nulls=n,decoded_characters=characters,
                             conditional_arithmetic_pass=expected,
                             evaluated_predicates_pass=False,
                             unresolved_predicates=result['unresolved_predicates'],
                             failed_conditional_predicates=result['failed_conditional_predicates'],
                             failed_predicates=result['failed_predicates'],
                             hypothetical_general_Why_JSON_byte_bound=result['Why_core']['json_bytes'],
                             source_selected_Main_JSON_bytes=0,
                             whole_pipeline_closed=False))
        result=evaluate(b'--'+b'x'*32764+b'\n'+original)
        assert 'Main_expanded_columns' in result['failed_predicates']
        rows.append(dict(case='physical_column_overflow',failed_predicates=result['failed_predicates']))
        changed=copy.deepcopy(fixture);changed['complete_path_bound']=16
        result=evaluate(original,changed)
        assert 'shared_launch_paths' in result['failed_predicates']
        rows.append(dict(case='path_envelope_overflow',failed_predicates=result['failed_predicates']))
        for p,expected in ((976,True),(977,False)):
            changed=copy.deepcopy(fixture);changed['complete_path_bound']=p
            result=evaluate(original,changed)
            assert result['conditions']['Main_ALI_interface']==expected
            assert result['conditions']['ALI_consumer_local_interfaces']==expected
            assert result['conditions']['GPR_parent_DW_local_interface']==expected
            assert result['native_GPR_parent_DW_interface']['Main_ALI_interface']==result['Main_ALI_interface']
            assert result['ALI_consumer_interfaces']['Main_ALI_interface']==result['Main_ALI_interface']
            assert result['Main_ALI_interface']['path_spelling_bytes_upper']==p
            assert result['Main_GAS_BFD_storage']['path_bytes']==p+1
            assert result['linker_path_bytes_including_NUL_upper']==p+1
            rows.append(dict(case='Main_ALI_path_envelope_'+str(p),path_spelling_bytes=p,
                             Main_ALI_interface_fits=expected,failed_predicates=result['failed_predicates']))

        # A component must refer to the same writer result, not merely source
        # counts and a plausible success flag. Exercise both join failures.
        parent_evaluate=context.gpr_parent['evaluate']
        for field in ('path_spelling_bytes_upper','Main_ALI_interface'):
            def mismatched_parent(*args, **kwargs):
                result=parent_evaluate(*args, **kwargs)
                if field=='path_spelling_bytes_upper':
                    result[field]+=1
                else:
                    result[field]=copy.deepcopy(result[field])
                    result[field]['Main_ALI_reader_bytes_including_EOF_upper']+=1
                return result
            context.gpr_parent['evaluate']=mismatched_parent
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal GPR parent DW interface join'
                rows.append(dict(case='GPR_parent_'+field+'_mismatch',rejected=str(error)))
            else:
                raise AssertionError('GPR parent accepted mismatched '+field)
            finally:
                context.gpr_parent['evaluate']=parent_evaluate

        ingress_evaluate=context.ingress['evaluate']
        def mismatched_ingress(c,n):
            result=ingress_evaluate(c,n)
            result['corrected_direct_gimplifier_GGC_events_upper']+=1
            return result
        context.ingress['evaluate']=mismatched_ingress
        try:
            evaluate(original)
        except ValueError as error:
            assert str(error)=='literal native ingress/direct/helper interface join'
            rows.append(dict(case='native_ingress_direct_subtotal_mismatch',rejected=str(error)))
        else:
            raise AssertionError('native ingress accepted a mismatched direct subtotal')
        finally:
            context.ingress['evaluate']=ingress_evaluate

        warning_evaluate=context.warning_residual['evaluate']
        def silently_zeroed_warning_residual(c,n):
            result=warning_evaluate(c,n)
            result['other_original_gigi_put_calls']=0
            result['conditional_map_transfer']=context.warning['evaluate'](c,n,0)['conditional_map_transfer']
            return result
        context.warning_residual['evaluate']=silently_zeroed_warning_residual
        try:
            evaluate(original)
        except ValueError as error:
            assert str(error)=='literal native warning-map source interface join'
            rows.append(dict(case='unjustified_zero_warning_residual',rejected=str(error)))
        else:
            raise AssertionError('unproved original-gigi residual accepted')
        finally:
            context.warning_residual['evaluate']=warning_evaluate

        imported_original=context.imported_functions
        for name,path,value in (
            ('residual_loses_replacements',('R_counts_replacement_puts',),False),
            ('unproved_warning_frontier',('selected_original_gigi_warning_frontier_closed',),False),
            ('missing_elaboration_structure',('empty_elaboration','function_structures_allocated'),0),
            ('missing_elaboration_counter',('empty_elaboration','persistent_function_definition_number_increment'),0),
            ('unproved_elaboration_symbol_zero',('empty_elaboration','symbol_registration_count'),0),
            ('unproved_elaboration_allocation_zero',('empty_elaboration','allocation_request_events'),0)):
            context.imported_functions=copy.deepcopy(imported_original)
            target=context.imported_functions
            for key in path[:-1]:
                target=target[key]
            target[path[-1]]=value
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal imported function and warning frontier join'
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered imported frontier: '+name)
            finally:
                context.imported_functions=imported_original

        cold_original=context.cold_string
        for name,field,value in (
            ('silently_erased_helpers','size_functions_created',0),
            ('erased_initial_gimplifications','initial_helper_gimplifications',0),
            ('helper_emission','helper_emitted_functions',1),
            ('unproved_helper_allocation_zero','helper_allocation_request_events',0),
            ('premature_imported_closure','complete_imported_frontier_closed',True),
            ('discard_resets_counter','persistent_counter_increments',dict(
                symbol_next_uid=0,symbol_order=2,function_definition_number=2,
                private_size_function_fnno=2))):
            context.cold_string=copy.deepcopy(cold_original)
            context.cold_string[field]=value
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal cold String helper interface join'
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered cold helper interface: '+name)
            finally:
                context.cold_string=cold_original

        original_evaluate=context.original_helper['evaluate']
        for name,path,value in (
            ('omitted_private_copy',('GGC_groups',0,'requests'),0),
            ('omitted_parameter_substitutions',('top_level_substitute_in_expr_calls',),2),
            ('omitted_substitution_candidates',('substitution_envelope','GGC_events'),0),
            ('discarded_candidates_removed',('substitution_envelope','discarded_candidates_included'),False),
            ('events_erased',('GGC_events',),0),
            ('name_bytes_erased',('GGC_caller_bytes_sum_ceiling','P_coefficient'),0),
            ('ordinary_vector_erased',('ordinary_requests',),0),
            ('DECL_demand_erased',('identity_demands','fresh_DECL_UIDs'),0),
            ('type_demand_erased',('identity_demands','fresh_type_UIDs_ceiling'),0),
            ('private_name_increment_erased',('identity_demands','helper_name_fnno_increments'),0),
            ('identifier_lookup_erased',('shared_container_demands','identifier_insertion_capable_lookups'),0),
            ('identifier_entry_erased',('shared_container_demands','identifier_new_entries_ceiling'),0),
            ('type_lookup_erased',('shared_container_demands','type_hash_insertion_capable_lookups'),0),
            ('type_entry_erased',('shared_container_demands','type_hash_new_records_ceiling'),0),
            ('broader_String_promoted',('broader_Standard_String_conversion_included',),True),
            ('original_Main_promoted',('original_Main_gigi_included',),True),
            ('backing_promoted',('shared_table_backing_included',),True),
            ('collector_promoted',('collector_pages_and_allocator_metadata_included',),True),
            ('whole_capacity_promoted',('whole_literal_pipeline_closed',),True)):
            def mismatched_original():
                result=original_evaluate()
                changed=result
                for key in path[:-1]:
                    changed=changed[key]
                changed[path[-1]]=value
                return result
            context.original_helper['evaluate']=mismatched_original
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal original helper storage interface join'
                rows.append(dict(case='original_helper_'+name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered original helper interface: '+name)
            finally:
                context.original_helper['evaluate']=original_evaluate
        original_at=context.original_helper['evaluate_at']
        def mismatched_original_name(p):
            result=original_at(p)
            result['GGC_caller_bytes_sum_ceiling']-=2*p
            return result
        context.original_helper['evaluate_at']=mismatched_original_name
        try:
            evaluate(original)
        except ValueError as error:
            assert str(error)=='literal original helper name arithmetic join'
            rows.append(dict(case='original_helper_name_substitution',rejected=str(error)))
        else:
            raise AssertionError('accepted omitted helper name substitution')
        finally:
            context.original_helper['evaluate_at']=original_at
        for f,g,expected in ((0,9,28),(4,100,100),(73,9,101),
                             (module.I32-61,9,module.I32-33),
                             (module.I32-60,9,module.I32-32)):
            local_p=module.original_helper_name_bound(f,g)
            assert local_p==expected
            fits=local_p<=context.original_helper_expected['finite_arithmetic_guards']['P_max']
            assert fits==(f<=module.I32-61)
            rows.append(dict(case='original_helper_name_bound_'+str(f)+'_'+str(g),
                filename_bytes=f,global_name_bytes=g,local_P=local_p,fits=fits))
        changed=copy.deepcopy(fixture)
        changed['launch']={key:(('/tmp/'+('z'*75)+'/main.adb')
            if key.endswith('_Main') else value) for key,value in changed['launch'].items()}
        changed['complete_path_bound']=4096
        renamed=evaluate(original,changed)['native_original_helper_storage']
        renamed_p=len(changed['launch']['native_Main'])+28
        assert renamed['name_input']['local_cleaned_component_bound']==renamed_p
        assert renamed['evaluated_requests']['GGC_caller_bytes_sum_ceiling']==6832+2*renamed_p
        assert renamed_p!=4096 and renamed_p!=4097
        rows.append(dict(case='original_helper_actual_filename_not_path_envelope',local_P=renamed_p,
            path_envelope=4096,path_envelope_including_NUL=4097))
        for change in ('missing_file','changed_hash','changed_revision'):
            manifest=copy.deepcopy(context.original_manifest)
            if change=='missing_file':
                manifest['files'].pop()
            elif change=='changed_hash':
                manifest['files'][0]['sha256']='0'*64
            else:
                manifest['commit']='unreviewed'
            try:
                module.verify_original_helper_sources(manifest,args.gcc_root,args.ada_root,args.gcc_match)
            except ValueError as error:
                assert str(error)=='literal original helper exact source-manifest join'
                rows.append(dict(case='original_helper_manifest_'+change,rejected=str(error)))
            else:
                raise AssertionError('accepted changed helper source manifest')
        fake_original_gcc=root/'fake-original-gcc'
        first_gcc=next(row for row in context.original_manifest['files'] if row['root']=='gcc')
        bad_source=fake_original_gcc/first_gcc['path']
        bad_source.parent.mkdir(parents=True)
        bad_source.write_bytes(b'changed source\n')
        try:
            module.verify_original_helper_sources(context.original_manifest,fake_original_gcc,
                args.ada_root,args.gcc_match)
        except ValueError as error:
            assert str(error)=='literal original helper complete source join: '+first_gcc['path']
            rows.append(dict(case='original_helper_complete_source_mismatch',rejected=str(error)))
        else:
            raise AssertionError('accepted stale original helper source')

        # Challenge the new direct-request interfaces without replaying leaves.
        def altered(result,path,value):
            changed=result
            for key in path[:-1]:
                changed=changed[key]
            changed[path[-1]]=value
            return result

        def rejects(name,operation,message):
            try:
                operation()
            except ValueError as error:
                assert str(error)==message,(name,str(error))
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered original storage interface: '+name)

        string_evaluate=context.original_string['evaluate']
        for field,value in (
            ('GGC_events',310),('identifier_lookups',0),('identifier_new_entries',0),
            ('identifier_character_bytes',0),('global_decls_pushes',0),
            ('alias_sets_pushes_envelope',0),('large_integer_insertion_capable_lookups_envelope',0),
            ('large_integer_new_entries_envelope',0),('small_integer_cache_writes_envelope',0),
            ('helper_94_included',True),('synthetic_173_included',True),('Main_null_helper_11_included',True),
            ('tree_pool_entries',1),('tree_pool_insertion_capable_lookups',1),
            ('tree_pool_replacement_objects',1),('shared_table_backing_included',True),
            ('complete_imported_frontend',True),('complete_global_containers',True),
            ('complete_collector',True),('complete_whole_pipeline',True)):
            context.original_string['evaluate']=lambda: altered(string_evaluate(),(field,),value)
            try:
                rejects('original_String_'+field,lambda:evaluate(original),
                    'literal original String residual storage interface join')
            finally:
                context.original_string['evaluate']=string_evaluate
        audit=context.original_string_audit
        context.original_string_audit=copy.deepcopy(audit)
        context.original_string_audit['constant_extended_words_ceiling']=2
        try:
            rejects('original_String_extension_word_regression',lambda:evaluate(original),
                'literal original String residual storage interface join')
        finally:
            context.original_string_audit=audit

        main_evaluate=context.original_main['evaluate']
        mixed=variants[3][1]
        for name,path,value in (
            ('calls',('inputs','C'),1),('nulls',('inputs','N'),1),
            ('procedures',('inputs','D'),1),('decoded_lengths',('inputs','lengths'),[2,1]),
            ('context_I',('inputs','I'),0),('syntax_V',('derived','V'),0),
            ('identifier',('shared_demands','identifier_lookups'),0),
            ('type',('shared_demands','type_hash_lookups'),0),
            ('integer',('shared_demands','integer_hash_lookups'),0),
            ('global_decls',('shared_demands','global_decls_pushes'),0),
            ('statement_cache_I',('shared_demands','stmt_list_cache_pushes','I_coefficient'),0),
            ('alias_sets',('shared_demands','alias_sets_pushes'),0),
            ('namespace_finalizer',('shared_demands','scalar_finalizer_vector_pushes'),0),
            ('Uint',('shared_demands','Uint_entries'),0),
            ('Udigits',('shared_demands','Udigits_words'),0),
            ('UI_Ints',('shared_demands','UI_Ints_wrapper_calls'),0),
            ('pool_insertions',('original_tree_constant_pool_demands','insertions'),1),
            ('pool_lookups',('original_tree_constant_pool_demands','lookups'),1),
            ('pool_replacements',('original_tree_constant_pool_demands','replacements'),1),
            ('pool_depends_on_I',('original_tree_constant_pool_demands','independent_of_unsupplied_I'),False),
            ('duplicate_intervals',('exclusions',),[]),
            ('caller_I',('symbolic_direct_totals','caller_bytes','I_coefficient'),0),
            ('concrete_events',('conditional_direct_totals','GGC_events'),0),
            ('premature_original_closure',('complete_original_gigi_storage_closed',),True),
            ('premature_whole_closure',('whole_toolchain_capacity_established',),True)):
            def mismatched_main(lengths,*args,**kwargs):
                result=main_evaluate(lengths,*args,**kwargs)
                return altered(result,path,value) if len(lengths)==2 else result
            context.original_main['evaluate']=mismatched_main
            try:
                rejects('original_Main_'+name,lambda:evaluate(mixed),
                    'literal original Main storage interface join')
            finally:
                context.original_main['evaluate']=main_evaluate
        context_evaluate=context.context_visits['evaluate']
        for field,value in (
            ('I_upper_bound',113),('runtime_implicit_with_visits',35),
            ('new_elaboration_implicit_with_visits',38),('old_elaboration_implicit_with_visits',38),
            ('additional_statement_list_GGC_requests',0),('additional_caller_bytes',0),
            ('additional_rounded_slot_bytes',0),('additional_stmt_list_cache_pushes',0),
            ('pool_demands',dict(insertions=0,lookups=1,replacements=0)),
            ('complete_frontend_storage_closed',True),('complete_original_gigi_storage_closed',True),
            ('whole_toolchain_capacity_established',True)):
            context.context_visits['evaluate']=lambda: altered(context_evaluate(),(field,),value)
            try:
                rejects('original_Main_fixed_context_'+field,lambda:evaluate(original),
                    'literal fixed Main context visits interface join')
            finally:
                context.context_visits['evaluate']=context_evaluate

        for label,directory,manifest_name in (
            ('String','retained-literal-string-layout-storage-20261018','source-manifest.json'),
            ('Main','retained-literal-original-main-storage-20261018','inputs.json')):
            frozen_manifest=module.read(module.EVIDENCE/directory/manifest_name)
            for change in ('missing_file','changed_hash','changed_revision'):
                manifest=copy.deepcopy(frozen_manifest)
                if change=='missing_file':
                    manifest['files'].pop()
                elif change=='changed_hash':
                    manifest['files'][0]['sha256']='0'*64
                else:
                    manifest['commit' if label=='String' else 'gcc_commit']='unreviewed'
                rejects('original_'+label+'_manifest_'+change,
                    lambda:module.verify_original_storage_sources(manifest,label,
                        args.gcc_root,args.ada_root,args.gcc_match),
                    'literal original '+label+' exact source-manifest join')
            first=next(row for row in frozen_manifest['files'] if row['root']=='gcc')
            fake_gcc=root/('fake-'+label+'-gcc')
            bad_source=fake_gcc/first['path']
            bad_source.parent.mkdir(parents=True)
            bad_source.write_bytes(b'changed source\n')
            rejects('original_'+label+'_complete_source_mismatch',
                lambda:module.verify_original_storage_sources(frozen_manifest,label,
                    fake_gcc,args.ada_root,args.gcc_match),
                'literal original '+label+' complete source join: '+first['path'])
        historical_read=module.read_historical_repository_file
        module.read_historical_repository_file=lambda revision,path:b'changed historical note\n'
        try:
            rejects('original_Main_historical_note_mismatch',
                lambda:module.verify_original_storage_sources(frozen_manifest,'Main',
                    args.gcc_root,args.ada_root,args.gcc_match),
                'literal original Main complete source join: docs/research/retained-literal-pipeline.md')
        finally:
            module.read_historical_repository_file=historical_read
        manifest=copy.deepcopy(context.context_visit_manifest)
        manifest['repository_inputs'].pop()
        rejects('original_Main_fixed_context_manifest_missing_file',
            lambda:module.verify_context_visit_sources(manifest,args.ada_root),
            'literal fixed context exact source-manifest join')
        original_read=module.read
        for relative in (
            'retained-literal-string-layout-storage-20261018/fold-audit.json',
            'retained-literal-string-layout-storage-20261018/interface.json',
            'retained-literal-original-main-storage-20261018/derive.py',
            'retained-literal-original-main-storage-20261018/result.json',
            'retained-literal-context-visits-20261018/inputs.json',
            'retained-literal-context-visits-20261018/result.json'):
            pin_path='docs/evidence/'+relative
            def changed_pin(path):
                result=original_read(path)
                if path==HERE/'inputs.json':
                    pin=next(row for row in result if row['path']==pin_path)
                    pin['sha256']='0'*64
                return result
            module.read=changed_pin
            try:
                rejects('original_storage_repository_pin_'+relative,
                    lambda:module.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),
                    'changed aggregate input: '+pin_path)
            finally:
                module.read=original_read

        # The new leaf is accepted; challenge only this attachment and guards.
        emission_evaluate=context.emission['evaluate_source']
        for name,path,value,message in (
            ('source_identity',('source_identity','sha256'),'0'*64,'actual source-count'),
            ('recognized_C',('source_counts','output_calls'),2,'actual source-count'),
            ('decoded_W',('counts','decoded_bytes'),0,'actual source-count'),
            ('maximum_length',('counts','maximum_literal_length'),0,'actual source-count'),
            ('final_chain',('final_chain',),0,'complete stream and final-RTL'),
            ('text',('text_bytes_upper',),0,'complete stream and final-RTL'),
            ('lines',('assembly','lines_upper'),0,'complete stream and final-RTL'),
            ('bytes',('assembly','bytes_upper'),0,'complete stream and final-RTL'),
            ('line_width',('assembly','longest_line_excluding_LF_upper'),513,'complete stream and final-RTL'),
            ('prefix',('counter_bounds','fixed_prefix_positive_GGC_events_upper'),0,'counter endpoint and existing pool'),
            ('ordinary_next',('counter_bounds','ordinary_label_next_at_exit_upper'),39309,'counter endpoint and existing pool'),
            ('constant_next',('counter_bounds','constant_label_next_at_exit_upper'),39258,'counter endpoint and existing pool'),
            ('CFI_temporary',('counter_bounds','CFI_label_signed_temporary_maximum'),5,'counter endpoint and existing pool'),
            ('ordinary_guard',('counter_and_emission_guards','ordinary_label_next_signed_int'),False,'counter endpoint and existing pool'),
            ('constant_guard',('counter_and_emission_guards','constant_label_next_signed_int'),False,'counter endpoint and existing pool'),
            ('guard_summary',('counter_and_emission_guards_fit',),False,'counter endpoint and existing pool'),
            ('extra_body',('emission','emitted_function_bodies'),2,'complete writer and name inventory'),
            ('extra_line',('emission','additional_non_Main_emitted_lines'),1,'complete writer and name inventory'),
            ('external_directive',('emission','selected_pending_external_directive_lines'),1,'complete writer and name inventory'),
            ('function_label',('emission','Main_boundary_labels'),['.LFB0','.LFE0'],'complete writer and name inventory'),
            ('pool_definitions',('emission','constant_label_definitions_upper'),1,'complete writer and name inventory'),
            ('data_extent',('emission','rodata_bytes_upper'),0,'complete writer and name inventory'),
            ('symbol_width',('emission','symbol_name_bytes_including_NUL_upper'),27,'complete writer and name inventory'),
            ('route_removed',('source_family_emission_routes_closed_under_selected_descriptor',),False,'reviewed scope and open-boundary'),
            ('conditional_result_removed',('complete_selected_stream_source_correspondence_conditional',),False,'reviewed scope and open-boundary'),
            ('production_promoted',('production_invocation_and_materialization_established',),True,'reviewed scope and open-boundary'),
            ('source_premise_erased',('installed_relevant_behavior_correspondence_is_external_premise',),False,'reviewed scope and open-boundary'),
            ('global_counters_promoted',('complete_non_label_global_counter_lifetime_closed',),True,'reviewed scope and open-boundary'),
            ('collector_promoted',('complete_shared_backing_and_collector_capacity_closed',),True,'reviewed scope and open-boundary'),
            ('whole_capacity_promoted',('whole_literal_pipeline_capacity_established',),True,'reviewed scope and open-boundary'),
            ('admission_changed',('production_admission_changed',),True,'reviewed scope and open-boundary')):
            def changed_emission(raw):
                return altered(emission_evaluate(raw),path,value)
            context.emission['evaluate_source']=changed_emission
            try:
                rejects('emission_'+name,lambda:evaluate(original),'literal emission '+message+' join')
            finally:
                context.emission['evaluate_source']=emission_evaluate

        # Check the exact downstream object input, not just equal stream sizes.
        assemble=context.assembler['evaluate']
        def changed_object(raw,ctx):
            result=assemble(raw,ctx)
            result['ELF']['object_bytes_upper']+=1
            return result
        context.assembler['evaluate']=changed_object
        try:
            rejects('emission_assembler_object_input_mismatch',lambda:evaluate(original),
                    'literal assembler storage interface join')
        finally:
            context.assembler['evaluate']=assemble

        for change in ('missing_file','changed_hash','changed_revision'):
            manifest=copy.deepcopy(context.emission_manifest)
            if change=='missing_file': manifest['files'].pop()
            elif change=='changed_hash': manifest['files'][0]['sha256']='0'*64
            else: manifest['reviewed_silver_revision']='0'*40
            rejects('emission_manifest_'+change,
                lambda:module.verify_emission_sources(manifest,args.gcc_root,args.ada_root),
                'literal emission exact source-manifest join')
        first=next(row for row in context.emission_manifest['files'] if row['root']=='gcc')
        fake_gcc=root/'fake-emission-gcc'
        bad_source=fake_gcc/first['path']
        bad_source.parent.mkdir(parents=True)
        bad_source.write_bytes(b'changed source\n')
        rejects('emission_complete_source_mismatch',
            lambda:module.verify_emission_sources(context.emission_manifest,fake_gcc,args.ada_root),
            'literal emission complete source join: '+first['path'])
        historical_read=module.read_historical_repository_file
        module.read_historical_repository_file=lambda revision,path:b'changed historical aggregate\n'
        try:
            rejects('emission_historical_aggregate_mismatch',
                lambda:module.verify_emission_sources(context.emission_manifest,args.gcc_root,args.ada_root),
                'literal emission predecessor input join: docs/evidence/retained-literal-pipeline-20261018/compose.py')
        finally:
            module.read_historical_repository_file=historical_read
        # The 32 unchanged predecessor files still use current-byte checks.
        first=context.emission_manifest['historical_silver_inputs'][0]['path']
        fake_repo=root/'fake-emission-repo'
        changed_current=fake_repo/first
        changed_current.parent.mkdir(parents=True)
        changed_current.write_bytes(b'changed current predecessor\n')
        repository=module.REPO
        module.REPO=fake_repo
        try:
            rejects('emission_current_predecessor_mismatch',
                lambda:module.verify_emission_sources(context.emission_manifest,args.gcc_root,args.ada_root),
                'literal emission predecessor input join: '+first)
        finally:
            module.REPO=repository

        for pin_path in (
                'docs/research/retained-literal-emission-closure.md',
                'docs/evidence/retained-literal-emission-closure-20261018/derive.py',
                'docs/evidence/retained-literal-emission-closure-20261018/source-manifest.json',
                'docs/reviews/review-literal-emission-a937eaede5.md',
                'docs/reviews/check-literal-emission-a937eaede5.json'):
            def changed_pin(path):
                result=original_read(path)
                if path==HERE/'inputs.json':
                    next(row for row in result if row['path']==pin_path)['sha256']='0'*64
                return result
            module.read=changed_pin
            try:
                rejects('emission_repository_pin_'+pin_path,
                    lambda:module.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),
                    'changed aggregate input: '+pin_path)
            finally:
                module.read=original_read
        def wrong_review(revision,path):
            if path==context.emission_review['review_path']:
                return b'unaccepted review\n'
            return historical_read(revision,path)
        module.read_historical_repository_file=wrong_review
        try:
            rejects('emission_review_scope_mismatch',
                lambda:module.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),
                'literal emission accepted review scope join')
        finally:
            module.read_historical_repository_file=historical_read

        # Pure mathematical endpoints; no billion-statement source is fabricated.
        ordinary_last=(module.I32-39258-45-7)//7
        constant_last=(module.I32-39257)//2
        for name,c,n,field,expected in (
                ('ordinary_last',1,ordinary_last,'ordinary_label_next_signed_int',True),
                ('ordinary_next',1,ordinary_last+1,'ordinary_label_next_signed_int',False),
                ('constant_last',constant_last,0,'constant_label_next_signed_int',True),
                ('constant_next',constant_last+1,0,'constant_label_next_signed_int',False)):
            interface=context.emission['evaluate'](c,n,0,0)
            guards=module.emission_counter_endpoint_checks(interface['counter_bounds'],0,
                interface['text_bytes_upper'])
            assert guards==interface['counter_and_emission_guards'] and guards[field] is expected
            rows.append(dict(case='emission_endpoint_'+name,calls=c,nulls=n,
                             guard=field,fits=expected,scope='mathematical endpoint interface only'))

        synthetic_evaluate=context.synthetic['evaluate']
        counter_evaluate=context.counter['evaluate']
        for name,path,value in (
            ('calls',('calls',),2),
            ('nulls',('null_statements',),1),
            ('registration_bound',('symbol_registrations_upper',),5),
            ('next_UID_bound',('next_symbol_UID_upper',),7),
            ('next_order_bound',('next_symbol_order_upper',),6),
            ('rewound_helper_holes',('live_symbols_after_both_helper_removals_upper',),3),
            ('Main_funcdef',('interface','function_definition_numbers','Main'),0),
            ('next_funcdef',('interface','next_function_definition_number'),3),
            ('empty_symbol_registration',('interface','empty_elaboration_symbol_registrations'),1),
            ('erased_helper_symbols',('interface','size_helper_symbol_registrations'),0),
            ('extra_target_function',('interface','target_hook_additional_function_definitions'),1),
            ('erased_function_allocation',('interface','nonnull_function_allocations'),3),
            ('extra_emitted_function',('interface','emitted_functions'),2),
            ('wrong_Main_labels',('interface','main_function_boundary_labels'),['.LFB4','.LFE4']),
            ('invented_original_events',('interface','complete_imported_allocation_events'),0),
            ('invented_original_bytes',('interface','complete_imported_allocation_bytes'),0),
            ('premature_global_counter_closure',('interface','complete_global_counter_lifetime_closed'),True),
            ('premature_collector_closure',('interface','complete_collector_lifetime_closed'),True),
            ('premature_whole_capacity',('whole_literal_pipeline_capacity_established',),True),
            ('premature_interface_capacity',('interface','whole_literal_pipeline_capacity_established'),True)):
            def mismatched_counter(c,n):
                result=counter_evaluate(c,n)
                changed=result
                for key in path[:-1]:
                    changed=changed[key]
                changed[path[-1]]=value
                return result
            context.counter['evaluate']=mismatched_counter
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal counter exact interface and source-count join'
                rows.append(dict(case='counter_'+name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered counter interface: '+name)
            finally:
                context.counter['evaluate']=counter_evaluate

        for function_name,path,value in (
            ('native_pool_lifetime',('symbols','registered_nodes_upper'),5),
            ('native_pool_lifetime',('symbols','next_uid_upper'),7),
            ('native_pool_lifetime',('symbols','order_upper'),6),
            ('native_graph_lifetime',('ordinary_requests','COMDAT_map_live_upper'),5),
            ('native_graph_lifetime',('additional_registered_symbols',),0),
            ('native_graph_lifetime',('source_input','calls'),2),
            ('native_graph_lifetime',('selected_graph_constructor_frontier_established',),False),
            ('native_graph_lifetime',('conditional_graph_and_summary_lifetime_closed',),False)):
            original_function=getattr(module,function_name)
            def mismatched_bounds(*args,**kwargs):
                result=original_function(*args,**kwargs)
                changed=result
                for key in path[:-1]:
                    changed=changed[key]
                changed[path[-1]]=value
                return result
            setattr(module,function_name,mismatched_bounds)
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal counter pool and graph bound join'
                rows.append(dict(case='counter_'+function_name+'_'+path[-1],rejected=str(error)))
            else:
                raise AssertionError('accepted mismatched counter bound: '+str(path))
            finally:
                setattr(module,function_name,original_function)

        assembler_evaluate=context.assembler['evaluate']
        for path in (('assembly','lines_upper'),('assembly','bytes_upper'),
                     ('assembly','longest_line_excluding_LF_upper'),
                     ('GAS','symbol_name_bytes_including_NUL_upper')):
            def mismatched_envelope(*args,**kwargs):
                result=assembler_evaluate(*args,**kwargs)
                result[path[0]][path[1]]+=1
                return result
            context.assembler['evaluate']=mismatched_envelope
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal counter selected emitted-name envelope join'
                rows.append(dict(case='counter_emission_'+path[-1],rejected=str(error)))
            else:
                raise AssertionError('accepted mismatched emission envelope: '+str(path))
            finally:
                context.assembler['evaluate']=assembler_evaluate

        for change in ('missing_file','changed_hash','changed_revision'):
            manifest=copy.deepcopy(context.counter_manifest)
            if change=='missing_file':
                manifest['files'].pop()
            elif change=='changed_hash':
                manifest['files'][0]['sha256']='0'*64
            else:
                manifest['gcc_revision']='unreviewed'
            try:
                module.verify_counter_sources(manifest,args.gcc_root,args.ada_root)
            except ValueError as error:
                assert str(error)=='literal counter exact source-manifest join'
                rows.append(dict(case='counter_manifest_'+change,rejected=str(error)))
            else:
                raise AssertionError('accepted changed counter source manifest: '+change)
        fake_gcc=root/'fake-gcc'
        first_gcc=next(row for row in context.counter_manifest['files'] if row['root']=='gcc')
        bad_source=fake_gcc/first_gcc['path']
        bad_source.parent.mkdir(parents=True)
        bad_source.write_bytes(b'changed source\n')
        try:
            module.verify_counter_sources(context.counter_manifest,fake_gcc,args.ada_root)
        except ValueError as error:
            assert str(error)=='literal counter complete source join: '+first_gcc['path']
            rows.append(dict(case='counter_complete_source_mismatch',rejected=str(error)))
        else:
            raise AssertionError('accepted changed counter source')

        # Check the endpoint without constructing a source with billions of calls.
        for c,expected in ((module.I32-7,True),(module.I32-6,False)):
            counter=module.native_counter_emission(c,0,context,context.imported_functions,
                synthetic_evaluate(),module.native_pool_lifetime(c,context),
                module.native_graph_lifetime(c,0,context),context.assembler['interface'](c,0,c,1))
            assert counter['symbol_next_values_fit_signed_32']==expected
            rows.append(dict(case='counter_symbol_endpoint_'+str(c),calls=c,
                             next_symbol_UID_upper=c+7,fits=expected))

        for name,path,value in (
            ('erased_synthetic_function',('function_structure_calls',),2),
            ('erased_synthetic_gimplification',('initial_helper_gimplifications',),0),
            ('erased_synthetic_GGC',('GGC_events',),0),
            ('unproved_original_construction',('original_gigi_predecessor_construction_included',),True),
            ('duplicate_cgraph_charge',('cgraph_nodes_and_symbol_map_backing_included',),True),
            ('invented_identifier_backing',('shared_identifier_backing_included',),True),
            ('lost_synthetic_finalizers',('shared_container_demands','singleton_finalizer_registrations'),0),
            ('lost_synthetic_funcdef',('identity_demands','function_definition_numbers'),0)):
            def mismatched_synthetic():
                result=synthetic_evaluate()
                changed=result
                for key in path[:-1]:
                    changed=changed[key]
                changed[path[-1]]=value
                return result
            context.synthetic['evaluate']=mismatched_synthetic
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal synthetic function storage interface join'
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered synthetic interface: '+name)
            finally:
                context.synthetic['evaluate']=synthetic_evaluate

        frontend_compose=context.frontend['compose']
        collector_evaluate=context.collector['evaluate']
        for name,path,value in (
            ('borrowed_null_total',('total_GGC_events',),40098),
            ('invented_backing',('collector_page_and_finalizer_backing',),{}),
            ('erased_marker_scratch',('value_expression_marker','each_ordinary_hash_backing_bytes'),0),
            ('unproved_cache_empty',('value_expression_insertions_upper',),1),
            ('premature_collector_closure',('complete_collector_lifetime_closed',),True),
            ('collector_source_mismatch',('source','bytes'),0)):
            def mismatched_collector(*args,**kwargs):
                result=collector_evaluate(*args,**kwargs)
                changed=result
                for key in path[:-1]:
                    changed=changed[key]
                changed[path[-1]]=value
                return result
            context.collector['evaluate']=mismatched_collector
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal collector callback interface join'
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError('accepted altered collector interface: '+name)
            finally:
                context.collector['evaluate']=collector_evaluate

        mutations=[
            ('fixed_node_zero',('gigi_source_interface','separate_fixed_frontend_allowance','node_identities'),0),
            ('fixed_entity_zero',('gigi_source_interface','separate_fixed_frontend_allowance','entity_identities'),0),
            ('constructor_ordinary_subtotal',('Main_constructor','total','node_identities'),
                lambda r:r['gigi_source_interface']['Main_ordinary_allocation_allowance']),
            ('source_visit_ordinary_subtotal',('gigi_source_interface','Main_source_syntax_visit_bound'),
                lambda r:r['gigi_source_interface']['Main_ordinary_allocation_allowance']),
            ('constructor_completeness',('Main_constructor','whole_native_frontend_closed'),True),
            ('gigi_completeness',('gigi_source_interface','complete_backend_capacity_result'),True),
            ('frontend_completeness',('attachment_status','complete_native_frontend'),True),
            ('allocation_completeness',('attachment_status','complete_gigi_allocation'),True),
            ('capacity_completeness',('attachment_status','complete_native_capacity'),True),
            ('source_count_mismatch',('selected_source','output_calls'),
                lambda r:r['selected_source']['output_calls']+1)]
        for name,path,value in mutations:
            def mismatched_frontend(*args,**kwargs):
                result=frontend_compose(*args,**kwargs)
                changed=result
                for key in path[:-1]:
                    changed=changed[key]
                changed[path[-1]]=value(result) if callable(value) else value
                return result
            context.frontend['compose']=mismatched_frontend
            try:
                evaluate(original)
            except ValueError as error:
                assert str(error)=='literal native Main frontend interface join'
                rows.append(dict(case='native_Main_frontend_'+name,rejected=str(error)))
            else:
                raise AssertionError('native Main frontend accepted '+name)
            finally:
                context.frontend['compose']=frontend_compose

        for calls,expected in ((1073741822,True),(1073741823,False),
                               (2147483646,False)):
            ingress=context.ingress['evaluate'](calls,0)
            protected=module.native_unshare_protected_set_storage(ingress)
            assert protected['conditional_protected_set_storage_closed']==expected
            rows.append(dict(case='protected_set_probe_boundary_'+str(calls),fits=expected))
        for key,value in (('distinct_entries_upper',3),('backing_requests_upper',4)):
            ingress=context.ingress['evaluate'](1,0)
            ingress['protected_set'][key]=value
            try:
                module.native_unshare_protected_set_storage(ingress)
            except ValueError as error:
                assert str(error)=='literal unshare protected-set storage interface'
                rows.append(dict(case='protected_set_mismatch_'+key,rejected=str(error)))
            else:
                raise AssertionError('mismatched protected set accepted')

        rejections=[('VT_rejected',b'\v'+original,fixture),
                    ('concat_rejected',shell+b'Silver_IO.Put ("a" & "b");'+tail,fixture),
                    ('name_actual_rejected',shell+b'Silver_IO.Put (X);'+tail,fixture),
                    ('no_output_rejected',shell+b'null;'+tail,fixture)]
        changed=copy.deepcopy(fixture);changed['launch']['native_options'].remove('-fsplit-wide-types')
        rejections.append(('split_option_required',original,changed))
        changed=copy.deepcopy(fixture);changed['launch']['phase2_Main']='/tmp/different/main.adb'
        rejections.append(('common_Main_required',original,changed))
        bad=root/'bad-input';bad.write_bytes(b'changed input\n')
        for role in ('configuration','System','silver_io.ads'):
            changed=copy.deepcopy(fixture);changed['shared_inputs'][role]=str(bad)
            rejections.append((role+'_mismatch',original,changed))
        for name,raw,changed in rejections:
            try:
                evaluate(raw,changed)
            except ValueError as error:
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError(name)
        boundary=(1073741823-context.pool_seed)//2
        for c,expected in ((boundary,True),(boundary+1,False)):
            pools=module.native_pool_lifetime(c,context)
            assert pools['conditional_arithmetic_fits']==expected
            assert not pools['named_consumer_closed']
            assert pools['local_representation_checks']['tree_pool_live_and_probe']==expected
            rows.append(dict(case='tree_pool_prime_region_'+str(c),calls=c,
                             capacity=pools['tree_pool']['capacity_upper'],
                             conditional_arithmetic_fits=expected,named_consumer_closed=False))
        # Expansion happens before lookup equality: even an existing key
        # at the first 13-slot load boundary incurs a backing request.
        size,occupied=13,10
        assert 3*size <= 4*occupied
        replacement=next(p for p in context.primes if p >= 2*occupied)
        assert replacement==31 and occupied==10
        rows.append(dict(case='pre_hit_expansion',before_slots=size,
                         after_slots=replacement,fresh_entries=0))
        # empty_slow's megabyte branch requests 128 slots, rounded to 251.
        # It is selected only from a table larger than 131072 pointer slots.
        for c in (101,65535,65536):
            graph=module.native_graph_lifetime(c,0,context)
            slots=graph['call_site_hash_slots_upper']
            cleanup_request=128 if slots>131072 else 2*c
            cleanup_slots=next(p for p in context.primes if p>=cleanup_request)
            assert cleanup_slots<=slots
            assert graph['call_site_hash_terminal_empty_events_upper']==4
            rows.append(dict(case='call_site_terminal_empty_'+str(c),calls=c,
                             slots_upper=slots,cleanup_slots_upper=cleanup_slots,
                             events_upper=4))
        size_boundary=(module.I32-7)//26
        for c,expected in ((size_boundary,True),(size_boundary+1,False)):
            graph=module.native_graph_lifetime(c,0,context)
            assert graph['conditional_arithmetic_fits']==expected
            assert graph['conditional_graph_and_summary_lifetime_closed']==expected
            assert graph['local_representation_checks']['summary_signed_size_and_rounding']==expected
            rows.append(dict(case='summary_signed_size_'+str(c),calls=c,
                             rounding_numerator=graph['summary_rounding_numerator_upper'],
                             conditional_arithmetic_fits=expected,
                             selected_graph_constructor_frontier_established=True))
        edge_boundary=(module.I32-1)//4
        for c,expected in ((edge_boundary,True),(edge_boundary+1,False)):
            graph=module.native_graph_lifetime(c,0,context)
            assert graph['local_representation_checks']['cgraph_edge_UID']==expected
            rows.append(dict(case='cgraph_edge_UID_'+str(c),calls=c,
                             endpoint=graph['edge_uid_endpoint_upper'],fits=expected))
        for c,expected in (((module.I32-3)//3,True),((module.I32-3)//3+1,False)):
            helpers=module.native_ssa_helper_backing(c,0,context)
            assert helpers['local_representation_checks']['SSA_plus_one_vector_31_bit']==expected
            assert not helpers['conditional_SSA_helper_backing_closed']
            rows.append(dict(case='SSA_helper_SSA_slots_'+str(c),calls=c,fits=expected))
        for c,request,slots in ((6,60,61),(7,69,127)):
            helpers=module.native_ssa_helper_backing(c,0,context)
            coalesce=helpers['out_of_SSA']
            assert coalesce['coalesce_hash_request_slots_upper']==request
            assert coalesce['coalesce_hash_slots_upper']==slots
            assert coalesce['coalesce_hash_backing_bytes']==8*slots
            assert coalesce['coalesce_hash_live_entries']==0
            assert coalesce['coalesce_hash_probe_calls']==0
            assert helpers['conditional_SSA_helper_backing_closed']
            rows.append(dict(case='coalesce_initial_backing_'+str(c),calls=c,
                             request_slots=request,slots=slots,bytes=8*slots))
        coalesce_boundary=(module.I32-6)//9
        for c,expected in ((coalesce_boundary,True),(coalesce_boundary+1,False)):
            helpers=module.native_ssa_helper_backing(c,0,context)
            assert helpers['local_representation_checks']['coalesce_initial_request_unsigned']
            assert helpers['local_representation_checks']['coalesce_prime_capacity']==expected
            assert helpers['local_representation_checks']['coalesce_empty_iteration_index']==expected
            assert helpers['conditional_SSA_helper_backing_closed']==expected
            assert (helpers['out_of_SSA']['coalesce_hash_backing_bytes'] is not None)==expected
            rows.append(dict(case='coalesce_prime_request_'+str(c),calls=c,
                             request_slots=9*c+6,fits=expected))
        coalesce_unsigned_boundary=(2**32-1-6)//9
        for c,expected in ((coalesce_unsigned_boundary,True),(coalesce_unsigned_boundary+1,False)):
            helpers=module.native_ssa_helper_backing(c,0,context)
            assert helpers['local_representation_checks']['coalesce_initial_request_unsigned']==expected
            assert not helpers['conditional_SSA_helper_backing_closed']
            rows.append(dict(case='coalesce_unsigned_request_'+str(c),calls=c,
                             request_slots=9*c+6,fits=expected))
        for n,expected in ((module.I32-69,True),(module.I32-68,False)):
            helpers=module.native_ssa_helper_backing(1,n,context)
            assert helpers['conditional_SSA_helper_backing_closed']==expected
            assert helpers['local_representation_checks']['ranger_block_plus_64_signed']==expected
            rows.append(dict(case='SSA_helper_ranger_blocks_'+str(n),nulls=n,fits=expected))
        for c,slabs,slab_bytes in ((8,1,1024),(9,2,5120),(42,2,5120),(43,3,21504)):
            initial=module.native_initial_ssa_lifetime(c,0,context)
            groups=[g for g in initial['individual_GGC_request_groups'] if 'slab' in g['object']]
            assert sum(g['requests_upper'] for g in groups)==slabs
            assert sum(g['requests_upper']*g['raw_bytes_upper'] for g in groups)==slab_bytes
            assert initial['initial_SSA_operand_slab_requested_bytes_upper']==slab_bytes
            assert initial['additional_GGC_request_events_upper']==6*c+10+slabs
            assert initial['conditional_initial_SSA_lifetime_closed']
            rows.append(dict(case='initial_SSA_operand_slabs_'+str(c),calls=c,
                             slab_count=slabs,slab_requested_bytes=slab_bytes))
        for c,expected in ((357913940,True),(357913941,False)):
            initial=module.native_initial_ssa_lifetime(c,0,context)
            assert initial['local_representation_checks']['SSA_vector_normalized_capacity_31_bit']==expected
            rows.append(dict(case='initial_SSA_normalized_vector_'+str(c),calls=c,
                             capacity=initial['SSA_name_vector_normalized_capacity_upper'],fits=expected))
        for n,expected in ((module.I32//4-4,True),(module.I32//4-3,False)):
            initial=module.native_initial_ssa_lifetime(1,n,context)
            ordinary=initial['ordinary_requests']
            assert initial['local_representation_checks']['initial_CFG_and_dominance_signed_intermediate']==expected
            assert ordinary['cold_forward_dominance_unsigned_arrays']==9
            assert ordinary['walk_preorder_stack_bytes_upper']==8+16*(n+5)
            assert initial['conditional_initial_SSA_lifetime_closed']==expected
            rows.append(dict(case='initial_SSA_dominance_extent_'+str(n),nulls=n,fits=expected))
        for n,block_requests,label_requests in ((16,1,1),(17,2,1),(19,4,1),(20,5,2)):
            cfg=module.native_initial_cf_cfg_lifetime(1,n,context)
            groups={g['object']:g for g in cfg['individual_GGC_request_groups']}
            assert groups['initial CFG block-map backing']['requests_upper']==block_requests
            assert groups['initial CFG label-map backing']['requests_upper']==label_requests
            assert groups['initial CFG predecessor and successor vectors']['requests_upper']==2*(n+3)
            assert cfg['conditional_initial_CF_CFG_lifetime_closed']
            rows.append(dict(case='initial_CFG_map_growth_'+str(n),nulls=n,
                             block_requests=block_requests,label_requests=label_requests))
        for n,slots in ((14,31),(15,61)):
            cfg=module.native_initial_cf_cfg_lifetime(1,n,context)
            assert cfg['ordinary_requests']['EH_hash_slots_upper']==slots
            rows.append(dict(case='initial_EH_hash_envelope_'+str(n),nulls=n,slots=slots))
        for c,slots in ((3,31),(4,61)):
            cfg=module.native_initial_cf_cfg_lifetime(c,0,context)
            assert cfg['ordinary_requests']['discriminator_hash_slots_upper']==slots
            assert cfg['discriminator_assignment_calls_upper']==3*c+5
            assert cfg['discriminator_block_ID_endpoint_upper']==c+4
            rows.append(dict(case='initial_discriminator_hash_envelope_'+str(c),calls=c,slots=slots))
        boundary=(1073741823-5)//3
        for c,expected in ((boundary,True),(boundary+1,False)):
            cfg=module.native_initial_cf_cfg_lifetime(c,0,context)
            assert cfg['local_representation_checks']['discriminator_hash_prime_and_probe']==expected
            assert cfg['conditional_initial_CF_CFG_lifetime_closed']==expected
            rows.append(dict(case='initial_discriminator_prime_region_'+str(c),calls=c,fits=expected))
        for c,expected in ((1073741823,True),(1073741824,False)):
            cfg=module.native_initial_cf_cfg_lifetime(c,0,context)
            assert cfg['local_representation_checks']['GC_vector_normalized_capacity_31_bit']==expected
            rows.append(dict(case='initial_local_decl_normalized_vector_'+str(c),calls=c,fits=expected))
        for n,expected in ((1073741819,True),(1073741820,False)):
            cfg=module.native_initial_cf_cfg_lifetime(1,n,context)
            assert cfg['local_representation_checks']['GC_vector_normalized_capacity_31_bit']==expected
            rows.append(dict(case='initial_CFG_normalized_vector_'+str(n),nulls=n,fits=expected))
        for n,elements in ((124,1),(125,2)):
            cfg=module.native_initial_cf_cfg_lifetime(1,n,context)
            assert cfg['ordinary_requests']['shared_altered_bitmap_live_elements_upper']==elements
            assert cfg['ordinary_requests']['shared_altered_bitmap_fresh_elements_upper']==elements
            rows.append(dict(case='initial_CFG_bitmap_extent_'+str(n),nulls=n,elements=elements))
    result=dict(case_count=len(rows),cases=rows,all_checks_pass=True,
                native_tool_executions=0,whole_literal_pipeline_capacity_established=False,
                offline_run=dict(started_utc=started,
                    completed_utc=datetime.now(timezone.utc).isoformat(),
                    elapsed_seconds=time.perf_counter()-timer))
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(cases=len(rows),all_checks_pass=True,native_tool_executions=0)))


if __name__=='__main__':
    main()
