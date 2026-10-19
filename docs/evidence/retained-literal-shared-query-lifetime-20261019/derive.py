#!/usr/bin/env python3
"""Source-bound closure of selected literal shared query and scalar lifetimes."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1
PACKETS = dict(original='retained-literal-original-shared-storage-20261018',
    named='retained-literal-later-shared-storage-20261018',
    rtl='retained-literal-rtl-cache-controls-20261019',
    graph='retained-literal-type-alias-controls-20261019')


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


class Context:
    def __init__(self,gcc_root):
        pins=read(HERE/'inputs.json')
        roots=dict(gcc=Path(gcc_root),repository=REPO)
        for row in pins['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')},'changed query-lifetime input '+row['path'])
        self.source_files=sum(r['root']=='gcc' for r in pins['files'])
        self.repository_files=sum(r['root']=='repository' for r in pins['files'])
        # Import accepted pure arithmetic/recognizer only. Do not instantiate
        # any predecessor Context or run its checker or aggregate evaluator.
        self.shared=runpy.run_path(str(E/PACKETS['original']/'compose.py'))
        self.location=runpy.run_path(str(E/'retained-literal-location-lifetime-20261018/derive.py'))
        self.recognizer=runpy.run_path(str(E/'unbounded-programs/retained-native-expansion-20261017/derive-literal-output.py'))['source_counts']
        self.primes=runpy.run_path(str(E/'retained-literal-warning-map-20261018/derive.py'))['PRIMES']
        self.defaults={k:read(E/v/'result.json') for k,v in PACKETS.items()}
        self.correction=read(E/'retained-literal-location-lifetime-20261018/shared-identifier-correction.json')


def endpoints(c,n,d,context):
    require(type(c) is int and c>=1 and type(n) is int and n>=0 and
            type(d) is int and 1<=d<=min(2,c),'literal C N D domain')
    shared=context.shared
    r=164*c+16*d+8
    q=2*d+4
    history=40879+3*c+4*d
    slots=max(65536,shared['identifier_slots'](history))
    identifiers=dict(historical_insertions_upper=history,occupied_upper=history,
        allocated_slots_upper=slots,each_ordinary_backing_bytes_upper=8*slots,
        corrected_incoming_history_upper=40847,
        original_insertions_already_owned=c+4*d+31,named_insertions_already_owned=2*c+1,
        other_later_insertions=0,checks=dict(history_unsigned=4*history<=U32,
            threshold_unsigned=3*slots<=U32,doubling_unsigned=slots<=U32,
            request_span=8*slots<=I64),complete_selected_lifetime_closed=True)
    type_hash=shared['hash_backing'](131071,39257,q,q,context.primes)
    integer_hash=shared['hash_backing'](131071,39257,r+129,r+129,context.primes)
    global_decls=shared['gc_vector'](414851,d+8)
    stmt_cache=shared['gc_vector'](0,265+167*c+12*n)
    alias=shared['gc_vector'](414851,10)
    for row in (type_hash,integer_hash,global_decls,stmt_cache,alias):
        row.update(complete_selected_lifetime_closed=True,
                   all_backing_events_already_owned=True,new_backing_events_in_this_packet=0)
    final_history=39257+18
    cap=max(58891,shared['heap_capacity'](final_history))
    finalizers=dict(incoming_history_upper=39257,original_registrations_already_owned=5,
        named_registrations_already_owned=6,RTL_registrations_already_owned=5,
        alias_graph_registrations_already_owned=2,other_later_registrations=0,
        additional_registrations_upper=18,historical_registrations_upper=final_history,
        occupied_upper=final_history,allocated_slots_upper=cap,
        each_ordinary_backing_bytes_upper=8+16*cap,complete_selected_lifetime_closed=True,
        checks=dict(length_unsigned=final_history<=U32,growth_unsigned=3*(final_history-1)<=U32,
                    capacity_31_bits=cap<=I32,request_span=8+16*cap<=I64))
    counters=dict(next_DECL_UID_upper=5869+5*c+n+3*d,next_type_UID_upper=2295+6*c+5*d,
        alias_ID_upper=alias['occupied_upper']-1,temporary_name_serial_upper=history,
        checks=dict(DECL_UID_signed=5869+5*c+n+3*d<=I32,type_UID_unsigned=2295+6*c+5*d<=U32,
            alias_ID_signed=alias['occupied_upper']-1<=I32,temporary_name_serial_unsigned=history<=U32))
    fits=all(identifiers['checks'].values()) and all(finalizers['checks'].values()) and \
        all(counters['checks'].values()) and all(x['fits'] for x in
            (type_hash,integer_hash,global_decls,stmt_cache,alias))
    return dict(source_input=dict(output_calls=c,null_statements=n,distinct_output_callees=d),
        identifier_hash=identifiers,type_hash=type_hash,integer_hash=integer_hash,
        global_decls=global_decls,stmt_list_cache=stmt_cache,alias_sets=alias,
        scalar_finalizers=finalizers,counter_endpoints=counters,
        original_source_demands=dict(type_hash_lookups=q,type_hash_entries=q,
            integer_hash_lookups=r+129,integer_hash_entries=r+129,global_decls_pushes=d+8,
            stmt_list_cache_pushes=265+167*c+12*n,alias_sets_pushes=4,
            small_integer_cache_writes=r+132,already_owned_small_integer_cache_vectors=r),
        later_query_demands=dict(type_UID_increments=0,type_hash_lookups=0,type_hash_entries=0,
            integer_hash_lookups=0,integer_hash_entries=0,small_integer_cache_writes=0,
            small_integer_cache_vectors=0,call_length_existing_small_slot_lookups=c,
            global_decls_pushes=0,stmt_list_cache_pushes=0,alias_sets_pushes_already_owned=6,
            identifier_insertions_already_owned=2*c+1,DECL_UID_increments_already_owned=3*c+2,
            other_identifier_insertions=0,other_DECL_UID_increments=0),
        closed_scalar_control_owners=[dict(owner='original',registrations=5),
            dict(owner='named later',registrations=6),dict(owner='RTL controls',registrations=5),
            dict(owner='alias graph',registrations=2)],
        conditional_selected_shared_capacity_established=fits,
        complete_identifier_lifetime_closed=True,complete_DECL_UID_lifetime_closed=True,
        complete_type_lifetime_closed=True,complete_tree_integer_cache_lifetime_closed=True,
        complete_alias_lifetime_closed=True,complete_global_decls_lifetime_closed=True,
        complete_stmt_list_cache_lifetime_closed=True,complete_scalar_finalizer_lifetime_closed=True,
        complete_array_finalizer_lifetime_closed=False,complete_collector_lifetime_closed=False,
        complete_global_counter_lifetime_closed=False,complete_gimplifier_lifetime_closed=False,
        whole_literal_pipeline_capacity_established=False,total_GGC_events=None,
        new_direct_GGC_events=0,new_shared_GGC_backing_events=0,
        new_scalar_registrations=0,new_ordinary_backing_events=0,
        graph14_events_added_again=0,RTL4C_events_added_again=0,
        source_reachability_argument_is_handwritten=True,independent_review_status='pending',
        remaining_families=['mem_attrs changing setters versus existing operation/frame owners',
            'SSA/version, instruction/label/register, DF and emission reset-boundary counters',
            'ordinary pools/stacks', 'array/outer-finalizer/depth and collector page/mark state',
            'disjoint positive GGC event and individual object ledger',
            'frontend tables, production invocation/source correspondence and external pipeline'],
        native_tool_executions=0,accepted_component_suites_rerun=0,aggregate_executions=0,
        corpus_checkers_rerun=0,production_admission_changed=False,aggregate_RAM_gate=False)


def evaluate_source(raw,original,correction,named,rtl,graph,context):
    require(isinstance(raw,bytes) and all(32<=b<=126 or b in (9,10,13) for b in raw),
            'current literal source alphabet')
    counts=context.recognizer(raw)
    require(counts['maximum_literal_length']<=I32,'signed literal length')
    source=identity(raw)
    for label,packet in [('original',original),('named',named),('RTL',rtl),('graph',graph)]:
        require(packet['source']==source and packet['source_counts']==counts,
                'same actual source and recognized counts required: '+label)
    expected=context.location['corrected_shared_identifier_projection'](original,source,counts)
    require(correction==expected,'exact indexed filename correction required')
    c,n=counts['output_calls'],counts['null_statements']
    d=int(counts['Put']>0)+int(counts['Put_Line']>0)
    result=endpoints(c,n,d,context)
    for k,v in result['original_source_demands'].items():
        require(original['source_bound_demands'][k]==v,'original ownership '+k)
    require(original['source_bound_demands']['identifier_new_entries']==c+4*d+31 and
        original['counter_endpoints']['next_DECL_UID_upper']==5867+2*c+n+3*d and
        original['counter_endpoints']['next_type_UID_upper']==2295+6*c+5*d and
        correction['identifier_hash']['historical_insertions_upper']==40878+c+4*d,
        'corrected original identity boundary')
    for k in ('type_hash','integer_hash','global_decls','stmt_list_cache'):
        expected_row={name:value for name,value in result[k].items() if name not in
            ('complete_selected_lifetime_closed','all_backing_events_already_owned','new_backing_events_in_this_packet')}
        require(original[k]==expected_row,'exact original allocated history '+k)
    require(original['scalar_finalizers']['incoming_occupied_upper']==39257 and
        original['scalar_finalizers']['additional_pushes']==5 and
        original['scalar_finalizers']['occupied_upper']==39262 and
        original['scalar_finalizers']['allocated_slots_upper']==58891,'original scalar boundary')
    require(named['named_source_demands']==dict(identifier_insertions=2*c+1,
        DECL_UID_increments=3*c+2,type_UID_increments=0,scalar_finalizer_registrations=6),
        'named later ownership')
    require(rtl['additional_control_scalar_registrations_upper']==5 and
        rtl['selected_DF_GGC_controls']==rtl['selected_recorded_loop_exit_controls']==0 and
        rtl['new_shared_GGC_backing_request_events_upper']==4*c,'repaired RTL ownership')
    require(graph['new_alias_IDs_upper']==6 and graph['new_disjoint_GGC_events_upper']==14 and
        graph['new_scalar_finalizer_registrations_upper']==2 and
        graph['alias_sets']['occupied_upper']==414861 and
        graph['alias_sets']['allocated_slots_upper']==1048575 and
        graph['joined_type_UID_projection_upper']==result['counter_endpoints']['next_type_UID_upper'],
        'exact graph ownership')
    result.update(source=source,source_counts=counts,
        complete_source_files_verified=context.source_files,repository_inputs_verified=context.repository_files,
        same_source_corrected_incoming_history_verified=True,
        source_argument='docs/research/retained-literal-shared-query-lifetime.md')
    return result


def evaluate_default(context):
    return evaluate_source((REPO/'samples/hello_world.adb').read_bytes(),context.defaults['original'],
        context.correction,context.defaults['named'],context.defaults['rtl'],context.defaults['graph'],context)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args=parser.parse_args();context=Context(args.gcc_root)
    result=evaluate_default(context)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(shared_capacity_fits=result['conditional_selected_shared_capacity_established'],
                         new_events=result['new_direct_GGC_events']+result['new_shared_GGC_backing_events'])))


if __name__=='__main__':
    main()
