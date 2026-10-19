#!/usr/bin/env python3
"""Focused new owner/interface and arithmetic boundaries; no old suite replay."""
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import time
from derive import Context, HERE, REPO, I32, U32, additions, compose, evaluate_default, power2, read


def main():
    start=time.monotonic()
    context=Context(Path('/tmp/silver-backend-compose-20261018/full-source'))
    checks=[]
    def check(name,value):
        if not value: raise AssertionError(name)
        checks.append(name)
    def reject(name,callback):
        try: callback()
        except (ValueError,TypeError): checks.append(name)
        else: raise AssertionError('accepted '+name)

    result=evaluate_default(context)
    check('retained result reproduced',result==read(HERE/'result.json'))
    rows={x['owner']:x for x in result['owner_rows']}
    check('positive event partition sum',sum(x['positive_GGC_requests_upper'] for x in rows.values())==47054)
    check('fixed prefix retains separate corrected ingress',
        [rows[x]['positive_GGC_requests_upper'] for x in
         ('fixed_prefix','filename_ingress','ordinary_line_map_array','GNAT_node_association_arrays')]==
        [39257,3180,3,2])
    check('association caller product and rounding',rows['GNAT_node_association_arrays']['each_raw_request_bytes_upper']==330352 and
        rows['GNAT_node_association_arrays']['each_rounded_request_bytes_upper']==524288)
    check('original subtotal never added as a duplicate row',
        result['ownership']['original_subtotal']==2312 and
        not result['ownership']['original_subtotal_added_as_an_extra_row'])
    check('gimplifier exhaustion preserves existing sum',result['gimplifier_exhaustion']['existing_event_sum']==56 and
        result['gimplifier_exhaustion']['new_events']==0)
    check('expansion call tree has distinct owner',rows['expansion_CALL_EXPR_trees']['positive_GGC_requests_upper']==1 and
        rows['expansion_CALL_EXPR_trees']['each_raw_request_bytes_upper']==56)
    check('first and second unshares distinct',rows['operation_nonchain_RTX_through_first_unshare']['positive_GGC_requests_upper']==121 and
        rows['second_LRA_unshare_nonchain']['positive_GGC_requests_upper']==680 and
        rows['second_LRA_unshare_blockage_rtvec']['positive_GGC_requests_upper']==1)
    check('DF note creation remains separately charged',rows['DF_LRA_register_note_construction']['positive_GGC_requests_upper']==600)
    check('whole chain replaces initial chain',rows['whole_final_instruction_chain']['positive_GGC_requests_upper']==52 and
        result['ownership']['expansion_chain_replaced_by_whole_final_chain'])
    check('original Main function structure separate from synthetic',rows['Main_struct_function']['positive_GGC_requests_upper']==5 and
        rows['synthetic_nonMain_structures_and_gimplification']['positive_GGC_requests_upper']==173)
    x=result['new_transfer']
    check('reload additional reserve retains rounded capacity',
        x['reload_equivalence']['first_capacity_upper']==146 and
        x['reload_equivalence']['second_desired_length_upper']==208 and
        x['reload_equivalence']['second_pre_round_slots_upper']==219 and
        x['reload_equivalence']['second_capacity_upper']==292)
    check('CFG transient edge histories',x['edge_vectors']['histories_upper']==18 and
        x['edge_vectors']['allocations_per_history_upper']==3 and
        rows['RTL_edge_vector_growth']['positive_GGC_requests_upper']==54)
    check('CFI rows use literal N',rows['CFI_nonchain_and_backings']['positive_GGC_requests_upper']==39)
    check('signed frequency guard and vector correction',x['hard_register_usage']['per_hard_register_sum_upper']==10000 and
        x['hard_register_usage']['point_frequency_element_type']=='int')
    collector=result['collector']
    check('active pages exclude unused quire pages',collector['active_pages_upper']==47054 and
        collector['each_pointer_vector_capacity_upper']==65536 and
        collector['each_pointer_vector_request_bytes_upper']==524288 and
        not collector['unused_quire_pages_in_active_count'])
    check('finalizer owner is not total event count',collector['scalar_finalizer_history_upper']==39275 and
        collector['array_finalizer_registrations']==0 and collector['scalar_finalizer_backing_bytes_upper']==942584)
    check('depth and callback closure retained',collector['context_depth']==collector['old_context_bitmap_backups']==
        collector['callback_GGC_events']==0 and collector['marker_ordinary_request_bytes_each']==104)
    check('no scheduling byte gate',not collector['scheduling_counters_require_cumulative_byte_no_wrap'] and
        collector['actual_collection_count'] is None)
    check('conditional GGC closure with exact ordinary residuals',result['conditional_selected_GGC_and_collector_storage_capacity'] and
        len(result['remaining_ordinary_owners'])==4 and not result['complete_all_ordinary_native_capacity'])
    check('no broad capacity or publication claim',not any(result[k] for k in
        ('complete_native_capacity','whole_literal_pipeline_capacity_established','production_invocation_established',
         'production_admission_changed','aggregate_RAM_gate')))
    check('no prohibited runs',all(result[k]==0 for k in
        ('native_tool_executions','predecessor_evaluator_or_checker_executions','aggregate_executions','corpus_replays')))
    raw=(REPO/'samples/hello_world.adb').read_bytes()
    path=context.selected['source_path']
    reject('same counts different source',lambda:compose(raw+b'\n',path,context.selected,context))
    reject('different source path',lambda:compose(raw,path+'x',context.selected,context))
    mutations=[
        (('source_counts','null_statements'),1),
        (('core_result','source_path'),path+'x'),
        (('complete_path_bound',),513),
        (('selected_native_frontend_storage','source','sha256'),'0'*64),
        (('selected_current_source_bound_shared_storage','filename_ingress','direct_GGC_requests_upper'),3178),
        (('selected_current_source_bound_shared_storage','identifier_hash','incoming_historical_insertions_upper'),40846),
        (('selected_native_frontend_storage','components','gigi_array_and_name_input','association_array_requests'),0),
        (('core_result','native_original_shared_storage','partial_ledger','GGC_groups','original_Main'),1060),
        (('core_result','native_gimplifier_ingress','selected_helper_subtotal_GGC_events_upper'),6),
        (('core_result','native_lowering_data','conditional_native_selected_constructor_requests','selected_nonchain_RTX_lifetime_requests_upper'),120),
        (('core_result','selected_native_backing','DF_selected_reference_and_solver_transfer','selected_REG_DEAD_UNUSED_note_requests_upper'),0),
        (('selected_native_MEM_counter_lifetime','RTL','final_first_unused_pseudo_upper'),101),
        (('selected_native_MEM_counter_lifetime','RTL','final_chain_upper'),19),
        (('core_result','native_collector_callbacks','collector_callback_additional_GGC_events'),1)]
    for route,value in mutations:
        changed=copy.deepcopy(context.selected); target=changed
        for key in route[:-1]: target=target[key]
        target[route[-1]]=value
        reject('altered owner '+'.'.join(route),lambda changed=changed:compose(raw,path,changed,context))
    for c,n in ((0,0),(-1,0),(1,-1),(True,0),(1,False)):
        reject('invalid counts '+str((c,n)),lambda c=c,n=n:additions(c,n))
    cases=0
    for c in (1,2,19,100,1000,10000):
        for n in (0,1,20,100):
            r=additions(c,n)
            check('count transfer '+str((c,n)),r['fits'] and
                r['rows'][1]['positive_GGC_requests_upper']==664*c+n+16 and
                r['rows'][15]['positive_GGC_requests_upper']==4*n+39)
            cases+=1
    boundary_cases=0
    for c in (I32//10000,I32//10000+1):
        check('signed hard usage boundary '+str(c),
            additions(c,0)['local_representation_checks']['LRA_signed_hard_register_frequency']==(10000*c<=I32))
        boundary_cases+=1
    for demand in (0,1,127,128,129,65535,65536,65537,I32,I32+1):
        cap=power2(max(128,demand))
        check('page indexed backing boundary '+str(demand),cap>=max(128,demand) and cap<=U32 and
            (demand>I32 or cap<=2**31))
        boundary_cases+=1
    for c in (1,10,100,1000,10000):
        r=additions(c,0)['reload_equivalence']; k=99+5*c
        check('additional equivalence slots '+str(c),r['first_capacity_upper']>=k and
            r['second_capacity_upper']>=2*k and r['second_pre_round_slots_upper']>=3*r['first_capacity_upper']//2)
        boundary_cases+=1
    output=dict(status='passed',checks=checks,check_count=len(checks),count_cases=cases,
        boundary_cases=boundary_cases,verified_inputs=context.verified,
        elapsed_seconds=time.monotonic()-start,completed_utc=datetime.now(timezone.utc).isoformat(),
        platform=platform.platform(),native_tool_executions=0,
        predecessor_evaluator_or_checker_executions=0,aggregate_executions=0,corpus_replays=0)
    (HERE/'check-results.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:output[k] for k in ('status','check_count','count_cases','boundary_cases','elapsed_seconds')}))


if __name__=='__main__': main()
