#!/usr/bin/env python3
"""Source-bound original-construction shared storage; no native execution."""
import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = REPO / 'docs/evidence'
AGGREGATE = EVIDENCE / 'retained-literal-pipeline-20261018'
NATIVE = EVIDENCE / 'unbounded-programs/retained-native-expansion-20261017'
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def verify_identity(path, row, label):
    require(identity(Path(path).read_bytes())==
        {k:row[k] for k in ('bytes','sha256')},'changed '+label+': '+row['path'])


def require(value, message):
    if not value:
        raise ValueError(message)


def load(path):
    spec = importlib.util.spec_from_file_location('original_shared_'+path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def rho(value):
    return 1 << (max(1, value)-1).bit_length()


def heap_capacity(length):
    """Lifetime high-water capacity of a push-only heap vector (pops allowed)."""
    return 0 if length == 0 else max(4, length, 2*min(15,length-1), 3*(length-1)//2)


def identifier_slots(history):
    # Expansion is after insertion and fires at equality, so require strict >.
    return max(16384, rho(4*history//3+1))


def gc_vector(incoming_capacity, pushes):
    length = incoming_capacity+pushes
    desired = max(incoming_capacity, heap_capacity(length))
    rounded = rho(8+8*desired) if desired else 0
    normalized = (rounded-8)//8 if rounded else 0
    checks = dict(length_unsigned=length<=U32,
        growth_unsigned=3*max(0,length-1)<=U32,
        normalized_capacity_31_bits=normalized<=I32,
        request_and_pointer_span=rounded<=I64,
        allocator_order_region=rounded<=2**62)
    return dict(incoming_occupied_upper=incoming_capacity,
        incoming_allocated_slots_upper=incoming_capacity,
        additional_pushes=pushes,additional_GGC_backing_requests_upper=pushes,
        occupied_upper=length,allocated_slots_upper=normalized,
        each_caller_bytes_upper=rounded,each_rounded_bytes_upper=rounded,
        checks=checks,fits=all(checks.values()))


def hash_backing(incoming_slots, incoming_history, lookups, insertions, primes):
    history = incoming_history+insertions
    requested = 2*history
    prime = next((p for p in primes if p>=requested), None)
    slots = None if prime is None else max(incoming_slots,prime)
    checks = dict(prime_exists=prime is not None,
        load_products=4*history<=2**64-1 and (slots is None or 3*slots<=2**64-1),
        empty_threshold_unsigned=8*history<=U32,
        probe_addition=slots is not None and 2*(slots-1)<=U32,
        request_and_pointer_span=slots is not None and 8*slots<=I64,
        allocator_order_region=slots is not None and rho(8*slots)<=2**62)
    return dict(incoming_occupied_upper=incoming_history,
        incoming_allocated_slots_upper=incoming_slots,
        additional_insertion_capable_lookups=lookups,
        additional_new_entries_upper=insertions,
        occupied_upper=history,allocated_slots_upper=slots,
        additional_GGC_backing_requests_upper=lookups,
        each_caller_bytes_upper=None if slots is None else 8*slots,
        each_rounded_bytes_upper=None if slots is None else rho(8*slots),
        successful_lookup_can_replace_backing=True,
        checks=checks,fits=all(checks.values()))


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        pins=read(HERE/'inputs.json')
        for row in pins:
            verify_identity(REPO/row['path'],row,'shared-storage input')
        self.repository_inputs_verified=len(pins)
        roots=dict(gcc=Path(gcc_root),ada=Path(ada_root),plugin=Path(plugin_include))
        sources=read(HERE/'sources.json')
        for row in sources['files']:
            verify_identity(roots[row['root']]/row['path'],row,'shared-storage source')
        self.complete_source_files_verified=len(sources['files'])
        self.aggregate=load(AGGREGATE/'compose.py')
        self.aggregate_context=self.aggregate.Context(gcc_root,ada_root,plugin_include,gcc_match)
        self.prefix=read(NATIVE/'native-gcc-prefix-witness.json')
        corpus=read(EVIDENCE/'unbounded-programs/retained-source-closure-20261017/source-inventory.json')
        fixed=read(NATIVE/'native-fixed-inputs.json')
        require(corpus['installed_runtime_corpora']['all_names_and_bytes_equal'] and
            corpus['installed_runtime_corpora']['native']['file_count']==1575 and
            fixed['selected_specifications'] and len(fixed['selected_specifications'])==38 and
            fixed['fixed_generic_instances']==8,
            'fixed physical-union and virtual-copy input join')
        self.primes=self.aggregate_context.primes


def derive(aggregate, context):
    """Consume the exact reviewed actual-source attachment, not supplied C/N."""
    counts=aggregate['source_counts']
    c,n=counts['output_calls'],counts['null_statements']
    d=int(counts['Put']>0)+int(counts['Put_Line']>0)
    ac=context.aggregate_context
    original=aggregate['native_original_Main_storage']
    main=original['interface']
    string=aggregate['native_original_String_storage']['interface']
    helper=aggregate['native_original_helper_storage']['interface']
    synthetic=aggregate['native_synthetic_function_storage']
    require(main==ac.original_main['evaluate'](counts['decoded_literal_lengths'],n,d,114)
        and original['fixed_context_I']==114 and original['fixed_context_I_source_bound_established']
        and original['fixed_context_interface']==ac.context_visits_expected['context_input']
        and main['inputs']['C']==c and main['derived']['V']==73+81*c+4*n
        and string==ac.original_string_expected and helper==ac.original_helper_expected
        and synthetic==ac.synthetic_expected
        and not aggregate['whole_literal_pipeline_capacity_established'],
        'exact source-bound original shared-demand join')
    require(aggregate['native_original_String_storage']['helper94_additions']==1
        and aggregate['native_original_String_storage']['null_helper11_additions']==0
        and original['helper94_additions']==original['synthetic173_additions']==0
        and original['null_helper11_additions']==0
        and original['historical_null_structural_and_name_packets_additions']==0,
        'original shared-demand ownership join')
    warning=aggregate['native_warning_map_demand']['conditional_map_transfer']
    require(warning['additional_singleton_finalizer_registrations_ceiling']==1
        and warning['additional_vector_finalizer_registrations']==0
        and aggregate['native_pool_lifetime']['additional_singleton_finalizer_registrations_upper']==1
        and aggregate['native_collector_callbacks']['collector_callback_additional_GGC_events']==0
        and aggregate['native_counter_emission_interface']['interface']['function_definition_numbers']==
            dict(empty_elaboration=0,Main=1,String_bit_size_helper=2,String_byte_size_helper=3),
        'interleaved warning/symbol finalizer and function frontier join')
    counters=context.prefix['counters']
    e,b=counters['ggc_bytes']['positive_events'],counters['ggc_bytes']['positive_sum']
    require(e==39257 and b==3318816 and counters['decl_uid']['positive_sum']==5832
        and counters['type_uid']['positive_sum']==2277
        and not context.prefix['counter_wrap_or_reset'], 'fixed prefix shared-state join')
    # Count overapproximation, not a claim these files were loaded. The optional
    # Image_I physical body is already in the full runtime union; its copy is +1.
    files=1575+2+1+1+8+1
    filename_insertions=files+1
    incoming_identifiers=e+filename_insertions
    ms,hs,ss=main['shared_demands'],helper['shared_container_demands'],synthetic['shared_container_demands']
    demand=dict(
        identifier_lookups=ms['identifier_lookups']+string['identifier_lookups']+
            hs['identifier_insertion_capable_lookups']+ss['identifier_insertion_capable_lookups']+1,
        identifier_new_entries=ms['identifier_lookups']+string['identifier_new_entries']+
            hs['identifier_new_entries_ceiling']+ss['identifier_new_entries_ceiling']+1,
        type_hash_lookups=ms['type_hash_lookups']+hs['type_hash_insertion_capable_lookups'],
        type_hash_entries=ms['type_hash_lookups']+hs['type_hash_new_records_ceiling'],
        integer_hash_lookups=ms['integer_hash_lookups']+string['large_integer_insertion_capable_lookups_envelope'],
        integer_hash_entries=ms['integer_hash_lookups']+string['large_integer_new_entries_envelope'],
        small_integer_cache_writes=ms['integer_hash_lookups']+string['small_integer_cache_writes_envelope']+
            hs['existing_small_constant_cache_new_entries_ceiling'],
        already_owned_small_integer_cache_vectors=ms['integer_hash_lookups'],
        global_decls_pushes=ms['global_decls_pushes']+string['global_decls_pushes'],
        stmt_list_cache_pushes=ms['stmt_list_cache_pushes']['constant']+114,
        alias_sets_pushes=ms['alias_sets_pushes']+string['alias_sets_pushes_envelope'],
        scalar_finalizer_pushes=ms['scalar_finalizer_vector_pushes']+
            ss['singleton_finalizer_registrations']+1+1,
        vector_finalizer_pushes=0,dummy_identifier_entries=1,dummy_DECL_UIDs=1)
    history=incoming_identifiers+demand['identifier_new_entries']
    slots=identifier_slots(history)
    id_checks=dict(historical_insertions_unsigned=4*history<=U32,
        slot_threshold_unsigned=3*slots<=U32,doubling_unsigned=slots<=U32,
        individual_request=8*slots<=I64)
    identifiers=dict(incoming_historical_insertions_upper=incoming_identifiers,
        incoming_occupied_upper=incoming_identifiers,
        incoming_allocated_slots_upper=identifier_slots(incoming_identifiers),
        historical_insertions_upper=history,occupied_upper=history,
        allocated_slots_upper=slots,each_ordinary_backing_bytes_upper=8*slots,
        variable_ingress_backing_requests_upper=filename_insertions,
        post_prefix_backing_requests_upper=demand['identifier_new_entries'],
        checks=id_checks,fits=all(id_checks.values()))
    # A cache record insertion has its own positive GGC event. Initial sizes
    # are 1021/2039; retained historical occupancy bounds expansion high-water.
    initial_hash_slots=max(2039,next(p for p in context.primes if p>=2*e))
    require(8*initial_hash_slots<=b,'fixed hash allocated-state seed')
    types=hash_backing(initial_hash_slots,e,demand['type_hash_lookups'],demand['type_hash_entries'],context.primes)
    integers=hash_backing(initial_hash_slots,e,demand['integer_hash_lookups'],demand['integer_hash_entries'],context.primes)
    incoming_vector=(b-8)//8
    globals_=gc_vector(incoming_vector,demand['global_decls_pushes'])
    statements=gc_vector(0,demand['stmt_list_cache_pushes'])
    aliases=gc_vector(incoming_vector,demand['alias_sets_pushes'])
    z=e+demand['scalar_finalizer_pushes']
    final_capacity=heap_capacity(z)
    final_checks=dict(length_unsigned=z<=U32,growth_unsigned=3*(z-1)<=U32,
        capacity_31_bits=final_capacity<=I32,request_span=8+16*final_capacity<=I64)
    finalizers=dict(incoming_occupied_upper=e,incoming_allocated_slots_upper=heap_capacity(e),
        additional_pushes=demand['scalar_finalizer_pushes'],
        additional_ordinary_backing_requests_upper=demand['scalar_finalizer_pushes'],
        occupied_upper=z,allocated_slots_upper=final_capacity,
        each_ordinary_backing_bytes_upper=8+16*final_capacity,
        checks=final_checks,fits=all(final_checks.values()))
    decl=5832+main['identities']['DECL_UID']+13+8+8+1
    typ=1+2277+main['identities']['type_UID']+10+4
    guards=dict(DECL_UID_signed=decl<=I32,type_UID_unsigned=typ<=U32,
        alias_ID_signed=aliases['occupied_upper']-1<=I32,
        temporary_name_serial_unsigned=history<=U32)
    path=aggregate['complete_path_bound']
    filename_checks=dict(spelling_short=0<=path<=32767,identifier_length_unsigned=path<=U32,
        terminal_NUL_request=path+1<=I64,source_file_count_signed=files<=I32)
    conditions=dict(identifier_hash=identifiers['fits'],type_hash=types['fits'],integer_hash=integers['fits'],
        global_decls=globals_['fits'],stmt_list_cache=statements['fits'],alias_sets=aliases['fits'],
        scalar_finalizers=finalizers['fits'],selected_counter_endpoints=all(guards.values()),
        filename_ingress=all(filename_checks.values()))
    return dict(scope='Selected original construction through finalize_size_functions return, before ordinary Main analysis/gimplification.',
        source=aggregate['source'],source_counts=counts,path_spelling_bytes_upper=path,
        source_bound_demands=demand,
        filename_ingress=dict(runtime_physical_union=1575,Silver_specifications=2,Main=1,configuration=1,
            spec_virtual_copies=8,possible_Image_I_body_virtual_copy=1,source_file_entries_upper=files,
            optional_Image_I_physical_body_already_in_union=True,identifier_lookups_upper=filename_insertions,
            each_identifier_node_bytes=40,each_character_request_bytes_upper=path+1,
            each_identifier_node_rounded_bytes_upper=rho(40),
            each_character_rounded_bytes_upper=rho(path+1),
            direct_identifier_and_character_requests_upper=2*filename_insertions,
            direct_requests_not_added_to_shared_backing_events=True,checks=filename_checks,
            actual_invocation_materialization_established=False),
        identifier_hash=identifiers,type_hash=types,integer_hash=integers,
        global_decls=globals_,stmt_list_cache=statements,alias_sets=aliases,scalar_finalizers=finalizers,
        small_integer_cache=dict(max_slots_per_vector=252,each_existing_or_new_vector_caller_bytes_upper=2040,
            extra_GGC_requests=0,direct_vector_requests_already_owned_by_Main=True),
        counter_endpoints=dict(incoming_DECL_UID_upper=5832,next_DECL_UID_upper=decl,
            incoming_type_UID_upper=2278,next_type_UID_upper=typ,
            incoming_temporary_name_serial_upper=incoming_identifiers,
            next_temporary_name_serial_upper=history,alias_ID_upper=aliases['occupied_upper']-1,
            function_definition_numbers=aggregate['native_counter_emission_interface']['interface']['function_definition_numbers'],
            next_function_definition_number=4,helper_name_fnno_next=2,checks=guards),
        additional_shared_GGC_backing_request_events_upper=demand['type_hash_lookups']+demand['integer_hash_lookups']+
            demand['global_decls_pushes']+demand['stmt_list_cache_pushes']+demand['alias_sets_pushes'],
        conditions=conditions,selected_original_shared_container_interface_fits=all(conditions.values()),
        failed_conditions=[k for k,v in conditions.items() if not v],
        retained_aggregate_unresolved_predicates=aggregate['unresolved_predicates'],
        retained_aggregate_failed_conditional_predicates=aggregate['failed_conditional_predicates'],
        remaining_Ada_integer_storage=dict(Uint_entries=ms['Uint_entries'],Udigits_words=ms['Udigits_words'],
            UI_Ints_wrapper_calls=ms['UI_Ints_wrapper_calls'],incoming_occupied=None,incoming_allocated=None,
            complete_backing_closed=False),
        later_consumers_included=False,complete_original_gigi_storage_closed=False,
        complete_global_counter_lifetime_closed=False,complete_collector_lifetime_closed=False,
        complete_imported_allocation_events=None,complete_imported_allocation_bytes=None,
        whole_literal_pipeline_capacity_established=False,aggregate_RAM_gate=False,
        production_admission_changed=False,native_tool_executions=0,
        repository_inputs_verified=context.repository_inputs_verified,
        complete_source_files_verified=context.complete_source_files_verified,
        premises=['Retained source/installed-behavior and selected native configuration.',
            'Existing single-name, one-unit, no-preprocessing source-search and fixed virtual-copy closure.',
            'Complete path spelling descriptor bounds every selected filename; actual invocation materialization remains open.',
            'Existing fixed-prefix read projection; B only seeds source-independent GGC-backed containers.'])


def evaluate(descriptor, context, source=None):
    return derive(context.aggregate.evaluate(descriptor,context.aggregate_context,source),context)


def arguments(parser):
    for name in ('gcc-root','ada-root','plugin-include'):
        parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--gcc-match',type=Path)
    parser.add_argument('--descriptor',type=Path,default=AGGREGATE/'fixture.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)


def main():
    started=datetime.now(timezone.utc).isoformat(); timer=time.perf_counter()
    parser=argparse.ArgumentParser(description=__doc__); arguments(parser); args=parser.parse_args()
    context=Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    result=evaluate(args.descriptor,context,args.source)
    result['offline_run']=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:result[k] for k in ('selected_original_shared_container_interface_fits',
        'whole_literal_pipeline_capacity_established','native_tool_executions')}))


if __name__=='__main__':
    main()
