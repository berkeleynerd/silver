"""Join retained gnat1 startup and fixed binder-compiler capacities.

Called only after the complete adapter has freshly validated the current
actual-source invocation and driver projection. No source-family remainder
is accepted as a caller-supplied Boolean.
"""
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def require(condition, message):
    if not condition:
        raise ValueError(message)


def compiler_shells(invocation, driver, retained):
    P=invocation['path_bytes']
    require(P == 512 and driver['path_bytes'] == P, 'selected resolved-path bound')
    require(driver['source_identity'] == invocation['source_identity'] and
            driver['source_counts'] == invocation['source_counts'], 'same source and driver graph')
    lifecycle=retained['lifecycle']
    registry=retained['registry']
    split=retained['split']
    require(lifecycle['GCC_static_exit_and_fixed_startup_closed_under_stated_projection'] is True and
            lifecycle['new_static_exit_ordinary_requests'] == lifecycle['new_static_exit_GGC_events'] == 0,
            'accepted selected gnat1 lifecycle source result')
    require(lifecycle['GCC_owned_init_entries'] == 57 and lifecycle['GCC_static_cxa_registrations'] == 94,
            'gnat1 executable roots, distinct from driver/collect2')
    require(registry['fixed_pass_startup_component_complete'] is True and registry['pass_instances_upper'] == 394,
            'fixed complete startup registry')
    require(split['indexed_frontend_envelope']['argv_positions_upper'] == 25, 'accepted split command envelope')
    requests=dict(registry['individual_fixed_ordinary_requests'])
    requests.update(lifecycle['additional_fixed_ordinary_individual_request_bounds'])
    argc=25
    A=max(24,P+8);W=4*(A+67)
    requests.update(original_argv_pointers=(argc+1)*8,
        decoded_option_array_each=96*argc,
        saved_optimization_vector=8+96*2*argc,
        reconstructed_GNAT_C_argv=8*(2*argc+1),
        GNAT_runtime_argv=8,single_input_filename_pointer=8,
        diagnostic_option_classifier=2556*4,diagnostic_file_cache_slots=4104,
        diagnostic_recent_line_vector_each=6152,diagnostic_control_each=512,
        diagnostic_initial_obstack_each=4096,diagnostic_sink_vector=40,
        diagnostic_urlifier_vector=72,copied_argument=A+1,
        option_canonical_object=W,option_obstack_chunk=max(4096,W+116),
        auxiliary_basename=P+1,coverage_filename=2*P+7,getpwd_caller=max(4097,2*(P+1)))
    fronts=[]
    for row in driver['drivers']:
        if row['role'] == 'link':
            continue
        frontend=row['frontend']
        expected=23 if row['role']=='Main_compile' else 20
        require(frontend['argv_positions_exact_from_source'] == len(frontend['argv']) == expected,
                'current source-derived frontend argv')
        env=frontend['environment']
        require(env.get('LC_ALL') == 'C' and 'GLIBCXX_TUNABLES' not in env,
                'fixed runtime and locale inputs')
        require(frontend['frontend_theme'] == ('ASCII' if row['role']=='Main_compile' else 'emoji'),
                'actual default theme, common bounded layout')
        fronts.append(dict(role=row['role'],actual_argc=expected,argv_upper=argc,
            actual_max_argv_bytes_including_NUL=frontend['argv_max_bytes_including_NUL'],
            theme=frontend['frontend_theme'],individual_requests=dict(requests),
            fixed_startup_and_static_exit_source_projection=True,
            diagnostic_source_cache_read=False))
    require(len(fronts)==2, 'two compiler processes, no library regeneration')
    checks=dict(actual_argc_within_accepted_envelope=all(r['actual_argc']<=argc for r in fronts),
        actual_argument_width_within_envelope=all(r['actual_max_argv_bytes_including_NUL']<=A+1 for r in fronts),
        option_and_coverage_signed_arithmetic=max(W+116,2*P+7)<I32,
        individual_compiler_shell_requests=all(0<=x<=I64 for x in requests.values()),
        fixed_registry_ID_and_count=394+16<I32,
        fixed_gnat1_static_lifecycle=lifecycle['GCC_static_exit_and_fixed_startup_closed_under_stated_projection'])
    return dict(scope='Two actual compiler process shells and fixed startup/static exit',
        processes=fronts,conditions=checks,capacity_established=all(checks.values()),
        source_coverage_complete=True,Ada_argument_wrappers_owned_by_frontend_completion=True,
        additional_GGC_events=0,compiler_bodies_closed_by_this_component=False)


def binder_compiler(invocation, checksum):
    family=invocation['binder_object_family']
    E=checksum['allocation_event_bound']
    B=checksum['universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection']
    M=checksum['maximum_rounded_request_bound']
    require((E,B,M)==(56378,5167732,262144), 'reviewed checksum-family bound')
    require(family['GGC_events_upper']==E and family['GGC_rounded_bytes_upper']==B and
            family['GGC_largest_rounded_request']==M and family['checksum_domain']==[0,U32],
            'actual generated binder has the reviewed checksum family')
    require(invocation['compile_jobs']==['Main','binder'] and invocation['fixed_Silver_compile_jobs']==0 and
            invocation['regenerate_fixed_children_selected'] is False, 'fixed bundle graph')
    page_capacity=1<<(max(128,E)-1).bit_length()
    finalizer_capacity=max(4,E,2*min(15,E-1),3*(E-1)//2)
    requests=dict(page_pointer_each=8*page_capacity,
        scalar_finalizer=8+16*finalizer_capacity,array_finalizer=8+32*finalizer_capacity,
        largest_rounded_GGC=M,extra_Uint_wrapper=checksum['Uint_scanner']['wrapper_request_bytes'])
    checks=dict(first_collection_excluded=B<checksum['first_collection_threshold'],
        page_index_signed=E<=I32,page_vector_capacity_unsigned=page_capacity<=U32,
        finalizer_length_unsigned=E<=U32,finalizer_growth_unsigned=3*(E-1)<=U32,
        finalizer_capacity_31_bits=finalizer_capacity<2**31,
        individual_requests=all(0<x<=I64 for x in requests.values()),
        individual_GGC_order_region=M<=2**62,
        Uint_local_row_and_digit_dominance=checksum['Uint_scanner']['row_bound']<=2 and
            checksum['Uint_scanner']['digit_bound']<=6,
        fixed_semantic_and_ordinary_source_projection=True)
    return dict(scope='Output-binder compiler body, every uint32 Main checksum',
        positive_GGC_events_upper=E,cumulative_rounded_bytes_for_collection_exclusion=B,
        first_collection_margin=checksum['first_collection_threshold']-B,
        page_pointer_capacity=page_capacity,finalizer_capacity=finalizer_capacity,
        individual_requests=requests,conditions=checks,capacity_established=all(checks.values()),
        source_coverage_complete=True,actual_marking_collections=0,
        fixed_successful_ordinary_request_transfer=True,
        total_RAM_gate=False,process_shell_and_assembler_owned_separately=True)
