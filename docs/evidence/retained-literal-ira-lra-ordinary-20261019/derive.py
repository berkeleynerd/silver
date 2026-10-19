#!/usr/bin/env python3
"""IRA allocation graph/cost-storage subset. Pure new arithmetic, no replay.

This module does not close numeric cost arithmetic, the outer IRA-pass helper
interfaces, or remaining LRA helpers. Source reachability is handwritten.
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
I32,U32,I64,U64=2**31-1,2**32-1,2**63-1,2**64-1
PRIMES=(7,13,31,61,127,251,509,1021,2039,4093,8191,16381,32749,65521,
        131071,262139,524287,1048573,2097143,4194301,8388593,16777213,
        33554393,67108859,134217689,268435399,536870909,1073741789,
        2147483647,4294967291)


def require(value,message):
    if not value:raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


def verify_inputs(gcc_root,pins=None):
    pins=read(HERE/'inputs.json') if pins is None else pins
    roots=dict(gcc=Path(gcc_root),repository=REPO)
    for row in pins['files']:
        require(identity((roots[row['root']]/row['path']).read_bytes())==
                {k:row[k] for k in ('bytes','sha256')},'changed IRA input '+row['path'])
    for row in pins['excerpts']:
        require(row['text'] in (roots[row['root']]/row['path']).read_text(),
                'missing IRA excerpt '+row['name'])
    return dict(GCC_files=sum(r['root']=='gcc' for r in pins['files']),
        repository_files=sum(r['root']=='repository' for r in pins['files']),
        source_excerpts=len(pins['excerpts']))


def pooled(name,objects,stride=None,stride_upper=None):
    require(type(objects) is int and objects>=0,'pool object domain')
    require((stride is None)!=(stride_upper is None),'pool stride domain')
    ceiling=stride if stride is not None else stride_upper
    require(type(ceiling) is int and 8<=ceiling<=65528 and ceiling%8==0,
            'pool stride range')
    qmin=65528//ceiling
    blocks=(objects+qmin-1)//qmin
    # Unknown exact struct packing is never substituted for an exact stride.
    # For the real stride q>=qmin and q<=8191; ceil(o/q)*q<=o+8190.
    retained=(blocks*qmin if stride is not None else objects+8190) if objects else 0
    return dict(family=name,live_objects_upper=objects,
        exact_stride_bytes=stride,stride_bytes_upper=ceiling,
        slots_per_block_lower=qmin,retained_blocks_upper=blocks,
        allocated_and_free_slots_upper=retained,
        stored_count_type='size_t',individual_block_request_bytes=65536,
        new_GGC_events=0,new_scalar_registrations=0,new_array_registrations=0,
        ordinary_blocks_are_not_GGC_events=True,
        retained_counts_fit=retained<=U64 and blocks<=U64,
        lifetime_block_request_total=None)


def arithmetic(c,n):
    require(type(c) is int and c>=1 and type(n) is int and n>=0,'literal C/N domain')
    a,k,b,m,u=4*c,99+5*c,2*n+10,7*c+5*n+20,7*c+5*n+22
    p=2*m+b; h=k-92; vec_cap=max(4,2*b)
    prime=next((q for q in PRIMES if q>=max(200,2*h)),None)
    rows=[]
    def row(name,instances,elements,size,header=0,owner='new IRA subset'):
        rows.append(dict(family=name,simultaneous_instances_upper=instances,
            logical_elements_upper=elements,element_bytes=size,
            each_request_bytes_upper=header+elements*size,owner=owner))
    row('allocno/object-ID exact reserve',2,2*k,8,8)
    row('global/root regno-to-allocno map',2,k,8)
    row('block-node array',1,b,256)
    row('root-node array',1,1,256)
    row('preference/copy pointer exact reserve',2,u,8,8)
    row('cost tables: working and total',2,a,140)
    row('preferred class by allocno',1,a,4)
    row('allocno class/equivalence gain/best class by register',3,k,4)
    row('cost-class pointer map with signed byte caller',1,k,8)
    row('individual cost-class record',h,1,644)
    row('valid mode-change pointer map',1,k,8)
    row('empty valid-mode obstack initial chunk',1,1,65536)
    row('each class cost-pool wrapper',34,1,136)
    row('per-allocno saved-call number',1,a,4)
    row('start/finish live-range pointer arrays',2,p,8)
    row('live-point compression map',1,p,4)
    row('minimum live-range array',1,a,4)
    row('last-lived by point array',1,p,4)
    row('fast sorted allocnos',1,a,8)
    row('fast priorities',1,a,4)
    row('fast used hard-register sets by point',1,p,16)
    row('IRA preorder pointer vector backing',1,vec_cap,8,8)
    row('IRA reverse-order result and DFS vectors',2,b,8,8)
    row('optional root-region sort array',1,1,8)
    row('optional region child/removed exact reserves',2,b+1,8,8)
    row('emit-data array',1,a,24)
    row('empty new-allocno emit-data pointer reserve',1,50,8,8)
    # Retained setup owners: expose their individual maximum, never charge
    # them as an additional Main lifetime event/history total.
    row('persistent target cost work buffer',62,1,140,owner='retained target setup')
    row('target move table per mode and flavor',3,34*34,2,owner='retained target setup')
    pools=[pooled('IRA allocnos',a,stride_upper=256),
           pooled('IRA objects',a,stride=88),
           pooled('IRA preferences',a,stride=32),
           pooled('IRA live ranges',8*c,stride=40)]
    bitmap=8+8*((p+63)//64)
    sparse=32+8*a
    checks=dict(
        allocno_object_and_preference_ID_signed=a<=I32,
        register_extent_signed=k<=I32,
        cost_class_pointer_byte_caller_signed=8*k<=I32,
        exact_allocno_vector_signed_doubling=2*k<=I32,
        exact_allocno_reserve_covers_live_objects=a<=2*k,
        exact_preference_reserve_covers_live_preferences=a<=u,
        preference_copy_capacity_31_bits=u<=I32,
        CFG_block_and_region_sum_signed=b+1<=I32,
        IRA_preorder_growth_unsigned=3*b<=U32,
        IRA_preorder_capacity_31_bits=vec_cap<=I32,
        point_endpoint_and_finish_successor_signed=p+1<=I32,
        point_range_comparator_differences_signed=p<=I32,
        call_sequence_counter_signed=c+b+1<=I32,
        sparse_set_unsigned_multiply=2*(a-1)<=U32,
        sparse_set_unsigned_request=sparse<=U32,
        sparse_set_pointer_span=sparse<=I64,
        dense_bitmap_unsigned_rounding=p+63<=U32,
        dense_bitmap_unsigned_request=bitmap<=U32,
        every_named_ordinary_request_span=all(r['each_request_bytes_upper']<=I64 for r in rows),
        cost_class_hash_prime_exists=prime is not None,
        cost_class_hash_too_empty_unsigned=8*h<=U32,
        cost_class_hash_load_products_size_t=prime is not None and max(3*prime,4*h,2*h)<=U64,
        cost_class_hash_probe_addition_unsigned=prime is not None and 2*prime-3<=U32,
        cost_class_hash_individual_span=prime is not None and 8*prime<=I64,
        typed_pool_retained_count_fields=all(q['retained_counts_fit'] for q in pools))
    return dict(scope='IRA graph/cost/traversal allocation-storage subset of selected ira_build/fast color/emit-data/ira_emit(false)/destroy, with named imported allocator/DF/query owners; numeric cost and excess-pressure arithmetic and outer IRA/LRA interfaces remain open',
        source_input=dict(output_calls=c,null_statements=n),
        extents=dict(A=a,K=k,B=b,M=m,U=u,P=p,cost_class_insert_attempts_upper=h),
        ordinary_requests=rows,ordinary_pools=pools,
        cost_class_hash=dict(wrapper_bytes=48,initial_slot_request=200,
            insertion_capable_queries_upper=h,record_creations_upper=h,
            slots_upper=prime,each_backing_bytes_upper=None if prime is None else 8*prime,
            pre_hit_growth_included=True,entries_deleted_before_finish=False),
        lifetimes=dict(IRA_builds=1,fast_color_calls=1,root_regions=1,
            allocno_live_objects_upper=a,one_word_objects_per_allocno=1,
            preference_records_upper=a,copy_records=0,
            hard_cost_vector_pool_backing_blocks=0,
            live_range_constructor_calls_upper=8*c,
            live_range_copies=0,live_range_finish_successor_upper=p+1,
            pressure_sum_upper_per_allocno=None,
            last_call_number_upper=c+b,
            ordinary_pool_and_graph_teardown_before_LRA=True,
            mode_change_obstack_payload_records=0,
            root_bitmap_headers=4,root_bitmap_key_extent_upper=k,
            dead_point_bitmap_heads_upper=34,dead_point_bitmap_key_extent_upper=p,
            equiv_pseudos_bitmap_heads=1,equiv_pseudos_bitmap_key_extent_upper=k,
            shared_bitmap_allocator_owner_preserved=True,
            target_cost_buffers_recharged=False),
        sparse_sets=dict(instances=2,element_extent_upper=a,individual_bytes_upper=sparse),
        dense_point_bitmaps=dict(instances=3,individual_bytes_upper=bitmap,
            accepted_program_point_owner_preserved=True),
        local_representation_checks=checks,
        conditional_named_IRA_allocation_capacity=all(checks.values()),
        failed_predicates=[key for key,value in checks.items() if not value],
        new_GGC_events=0,new_scalar_registrations=0,new_array_registrations=0,
        shared_bitmap_or_ET_blocks_recharged=0,aggregate_RAM_gate=False,
        aggregate_ordinary_bytes=None,lifetime_ordinary_request_total=None,
        numeric_cost_arithmetic_closed=False,excess_pressure_arithmetic_closed=False,
        outer_IRA_helper_interfaces_closed=False,
        all_LRA_ordinary_helpers_closed=False,complete_all_ordinary_native_capacity=False,
        complete_native_capacity=False,whole_literal_pipeline_capacity_established=False,
        production_admission_changed=False,independent_review_status='pending',
        source_reachability_argument_is_handwritten=True,
        native_tool_executions=0,predecessor_evaluator_or_checker_executions=0,
        aggregate_or_corpus_replays=0)


def retained_interface_check():
    """Read and reconcile accepted fixed-input facts; no new source evaluator."""
    base=REPO/'docs/evidence'
    mem=read(base/'retained-literal-mem-ssa-attachment-20261019/result.json')
    pools=read(base/'retained-literal-shared-bitmap-pools-20261019/result.json')
    ledger=read(base/'retained-literal-native-ggc-ledger-20261019/result.json')
    raw=(REPO/'samples/hello_world.adb').read_bytes()
    require(identity(raw)==mem['source']==pools['source']==ledger['source'],
            'accepted retained source identity')
    require(mem['source_counts']==pools['source_counts']==ledger['source_counts'],
            'accepted retained complete counts')
    counts=mem['source_counts'];c,n=counts['output_calls'],counts['null_statements']
    r=arithmetic(c,n);x=r['extents'];shape=mem['core_result']['RTL_shape']
    require(shape['split_referenced_pseudos_upper']==x['A'] and
            shape['first_unused_pseudo_number_upper']==x['K'] and
            shape['IRA_entry_chain']==x['M'] and shape['block_slots_upper']==x['B'],
            'accepted retained IRA shape')
    require(all(pools['extents'][key]==x[key] for key in ('K','B','M','U','P')),
            'accepted retained point and bitmap domains')
    require(ledger['selected_GGC_event_partition_closed'] is True and
            ledger['local_representation_checks']['LRA_signed_hard_register_frequency'] is True,
            'accepted distinct GGC/hard-usage guards')
    return dict(source=mem['source'],source_counts=counts,
        frozen_GGC_total_preserved=ledger['total_positive_GGC_events_upper'],
        no_GGC_owner_row_added=True,no_actual_source_adapter_created=True,
        inherited_point_bitmap_and_pool_owners_preserved=True)


if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--gcc-source',required=True)
    args=ap.parse_args();v=verify_inputs(args.gcc_source)
    r=arithmetic(1,0);r['input_verification']=v;r['retained_interface']=retained_interface_check()
    print(json.dumps(r,indent=2))
