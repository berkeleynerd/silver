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
            pools=result['native_pool_lifetime']
            assert pools['source_input'] == dict(
                bounds_finalize_calls_upper=c,pool_entries_upper=2*c,insertion_capable_pool_lookups_upper=3*c)
            assert pools['incoming_tree_pool']['live_upper']==39257
            assert pools['incoming_tree_pool']['capacity_upper']==131071
            assert pools['tree_pool']['live_upper']==39257+2*c
            assert pools['tree_pool']['replacement_requests_upper']==3*c
            assert pools['symbols']['next_uid_upper']==c+5
            assert pools['bounds_lifecycle']['initializer_outgoing_references']==0
            assert pools['additional_GGC_request_events_upper']==5*c+5
            assert pools['conditional_arithmetic_fits']
            assert not pools['named_consumer_closed']
            assert not pools['imported_constructor_frontier_established']
            assert 'native_varpool_and_shared_tree_pool' not in result['open_joins']
            graph=result['native_graph_lifetime']
            assert graph['edge_creation_events_upper']==4*c
            assert graph['edge_uid_endpoint_upper']==4*c+1
            assert graph['call_summary_ID_high_water_upper']==c
            assert graph['additional_GGC_request_events_upper']==8*c+33
            cleanup=[row for row in graph['individual_GGC_request_groups']
                     if row['object']=='call-site hash terminal-empty backing']
            assert len(cleanup)==1 and cleanup[0]['requests_upper']==4
            assert cleanup[0]['raw_bytes_upper']==8*graph['call_site_hash_slots_upper']
            assert graph['conditional_arithmetic_fits']
            assert not graph['conditional_graph_and_summary_lifetime_closed']
            assert not graph['imported_constructor_frontier_established']
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
            assert warning['other_original_gigi_put_calls'] is None
            assert warning['conditional_map_transfer'] is None
            assert not warning['original_gigi_source_count_closed']
            assert not ingress['complete_gimplifier_lifetime_closed']
            assert ingress['complete_gimplifier_GGC_request_events_upper'] is None
            assembler=result['Main_assembler_object_interface']
            assert assembler['local_interface_fits']
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
            expected=name!='5000_calls'
            assert result['conditional_arithmetic_pass']==expected,(name,result['failed_conditional_predicates'])
            assert not result['evaluated_predicates_pass']
            assert result['failed_predicates']==[]
            assert set(result['unresolved_predicates'])=={
                'native_varpool_and_shared_tree_pool','native_graph_and_summary_lifetime',
                'Main_assembler_object_interface','Main_GAS_BFD_storage',
                'literal_output_linker_representation'}
            frontier=result['native_unit_frontier']
            assert frontier==result['open_joins']['native_post_prefix_imported_frontier']
            assert not frontier['Main_is_only_defined_body_established']
            assert not frontier['Main_is_only_emitted_body_established']
            assert frontier['additional_imported_pool_symbol_events_upper'] is None
            assert frontier['additional_imported_defined_bodies_upper'] is None
            assert frontier['additional_emitted_stream_interface'] is None
            assert linker['link']['failed_sufficient_checks']==(
                ['fixed_signed_relocation_reach'] if name=='5000_calls' else [])
            if name=='5000_calls':
                assert result['failed_conditional_predicates']==['literal_output_linker_representation']
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

        warning_evaluate=context.warning['evaluate']
        def silently_zeroed_warning_residual(c,n):
            return warning_evaluate(c,n,0)
        context.warning['evaluate']=silently_zeroed_warning_residual
        try:
            evaluate(original)
        except ValueError as error:
            assert str(error)=='literal native warning-map conditional interface join'
            rows.append(dict(case='unjustified_zero_warning_residual',rejected=str(error)))
        else:
            raise AssertionError('unproved original-gigi residual accepted')
        finally:
            context.warning['evaluate']=warning_evaluate

        frontend_compose=context.frontend['compose']
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
            assert not graph['conditional_graph_and_summary_lifetime_closed']
            assert graph['local_representation_checks']['summary_signed_size_and_rounding']==expected
            rows.append(dict(case='summary_signed_size_'+str(c),calls=c,
                             rounding_numerator=graph['summary_rounding_numerator_upper'],
                             conditional_arithmetic_fits=expected,named_consumer_closed=False))
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
