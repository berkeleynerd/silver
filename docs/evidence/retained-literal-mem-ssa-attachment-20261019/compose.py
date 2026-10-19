#!/usr/bin/env python3
"""Attach accepted MEM/counter and SSA lifetimes to the actual-source route.

Offline research only. Frozen source arguments supply reachability; arithmetic
checks and finite examples are not a universal source proof or admission rule.
"""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
PIPELINE = E/'retained-literal-pipeline-20261018'
PRIOR = E/'retained-literal-lifetime-attachment-20261019'
MEM = E/'retained-literal-mem-counter-lifetime-20261019'
SSA = E/'retained-literal-ssa-lifetime-20261019'


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


def verify_ssa_inputs(gcc_root):
    """Check its complete manifest/excerpts without running the Hello checker."""
    manifest = read(SSA/'inputs.json')
    roots = dict(gcc=Path(gcc_root), repository=REPO)
    for row in manifest['files']:
        require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                {k: row[k] for k in ('bytes', 'sha256')},
                'changed accepted SSA source input '+row['path'])
    for row in manifest['source_excerpts']:
        lines = (roots['gcc']/row['path']).read_text().split('\n')
        require('\n'.join(lines[row['start']-1:row['end']]) == row['source'],
                'changed accepted SSA source excerpt '+row['path'])
    counts = dict(compiler=sum(r['root'] == 'gcc' for r in manifest['files']),
        repository=sum(r['root'] == 'repository' for r in manifest['files']),
        excerpts=len(manifest['source_excerpts']))
    require(counts == dict(compiler=24, repository=8, excerpts=26),
            'complete accepted SSA input inventory')
    return counts


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        self.prior = runpy.run_path(str(PRIOR/'compose.py'))
        manifest = read(HERE/'inputs.json')
        self.prior['check_pins'](manifest)
        self.prior_context = self.prior['Context'](gcc_root, ada_root, plugin_include, gcc_match)
        self.prior_reference = read(PRIOR/'result.json')
        require(len(self.prior_reference['conditions']) == 149,
                'accepted lifetime149 guard schema')
        self.mem = runpy.run_path(str(MEM/'derive.py'))
        # The MEM source packet consumes the identical historical prose note
        # already allowlisted and reviewed by the accepted lifetime attachment.
        # E/NATIVE remain actual paths; no executable/source input is redirected.
        audit = read(PRIOR/'inputs.json')['historical_audit_documents']
        require(len(audit) == 1, 'one accepted historical audit note')
        view = self.prior['RepositoryAuditView'](audit[0])
        extension = self.prior['audit_extension'](view)
        globals_ = self.mem['Context'].__init__.__globals__
        actual_repo = globals_['REPO']
        globals_['REPO'] = view
        try:
            self.mem_context = self.mem['Context'](gcc_root)
        finally:
            globals_['REPO'] = actual_repo
        require((self.mem_context.source_files, self.mem_context.repository_files) == (56, 19),
                'complete accepted MEM input inventory')
        self.ssa_validation = verify_ssa_inputs(gcc_root)
        self.validation = dict(accepted_current_and_historical_records=len(manifest['files']),
            predecessor=self.prior_context.validation,
            MEM=dict(compiler=self.mem_context.source_files, repository=self.mem_context.repository_files),
            SSA=self.ssa_validation, identity_sets_overlap_and_must_not_be_added=True,
            historical_MEM_prose_input=audit[0],
            historical_MEM_prose_extension_correspondence=extension,
            all_executable_compiler_source_configuration_inputs_are_actual_pinned_bytes=True,
            fixed_SSA_result_used_as_general_evaluator=False,
            SSA_adapter='Recompute the complete accepted initial owner with its callable for actual counts; attach accepted zero-increment source argument. The frozen Hello checker is never called.',
            predecessor_suites_rerun=False, accepted_runtime_census_reused=True,
            source_lifetime_arguments_are_reviewed_handwritten_arguments=True)


def ssa_extension(raw, core, context):
    """General checked adaptation of the accepted zero-increment argument.

    The accepted SSA packet has only a retained-Hello checker, not a general
    source evaluator. Its reviewed no-new-requests argument is attached to the
    actual core owner, recomputed using the existing initial-SSA callable.
    """
    counts = context.mem_context.recognize(raw)
    source = identity(raw)
    require(core['source'] == source and core['source_counts'] == counts,
            'SSA actual source and complete counts')
    c, n = counts['output_calls'], counts['null_statements']
    selected = context.prior_context.selected_context
    expected = selected.core['native_initial_ssa_lifetime'](c, n, selected.core_context)
    initial = core['native_initial_SSA_lifetime']
    require(initial == expected, 'complete accepted actual-source initial SSA owner')
    uses = 3*c+1
    slabs = 1+int(uses > 25)+(max(0, uses-127)+408)//409
    require(initial['source_input'] == dict(calls=c, nulls=n, SSA_slots_upper=3*c+2,
        memory_definitions_upper=3*c, memory_uses_upper=uses, initial_CFG_block_slots_upper=n+4)
        and initial['real_SSA_names'] == initial['PHIs'] == 0
        and initial['default_memory_names'] == initial['default_definition_hash_entries'] == 1
        and initial['nondefault_memory_names_upper'] == 3*c
        and sum(r['requests_upper'] for r in initial['individual_GGC_request_groups']) ==
            initial['additional_GGC_request_events_upper'] == 6*c+10+slabs
        and initial['additional_singleton_finalizer_registrations_upper'] == 1,
        'SSA definition vector slab and scalar owner conservation')
    return dict(source=source, source_counts=counts,
        scope='Accepted selected Main SSA-name/default-definition/operand-slab lifetime through teardown; actual-source attachment review pending',
        source_lifetime_closed=True, later_incremental_update_allocations=0,
        later_new_SSA_NAME_objects=0, later_SSA_name_vector_backings=0,
        later_free_name_queue_backings=0, later_free_name_vector_backings=0,
        later_default_hash_keys=0, operand_slabs_beyond_initial_envelope=0,
        operand_slabs_upper=slabs,
        retained_initial_SSA_owned_GGC_events_upper=initial['additional_GGC_request_events_upper'],
        retained_initial_individual_GGC_request_groups=copy.deepcopy(initial['individual_GGC_request_groups']),
        retained_initial_guards=copy.deepcopy(initial['local_representation_checks']),
        conditional_selected_SSA_lifetime_fits=all(initial['local_representation_checks'].values()),
        additional_GGC_events_charged=0, additional_scalar_registrations_charged=0,
        helper_SSA_owners_added_again=0, initial_scalar_registration_added_again=0,
        full_GGC_ledger_established=False, complete_native_capacity=False,
        production_admission_changed=False, total_GGC_events=None,
        accepted_source_argument_target='e0c24340e86f4ae90c9de0794bab6797a0bd1563',
        accepted_source_argument_review='c63c6088f91d00e4224c7cf96fe1367e20861e83',
        source_argument_is_handwritten=True)


def arithmetic_guards(mem, ssa):
    guards = {}
    def add(prefix, checks):
        for key, value in checks.items():
            require(type(value) is bool, 'boolean attached arithmetic guard '+prefix+key)
            name = 'native_mem_ssa_'+prefix+key
            require(name not in guards, 'distinct attached arithmetic guard '+name)
            guards[name] = value
    add('MEM_', mem['local_representation_checks'])
    add('emission_', mem['emission_guards'])
    add('MEM_', dict(conditional_capacity=mem['conditional_selected_chronology_and_pool_capacity_established']))
    add('SSA_', ssa['retained_initial_guards'])
    add('SSA_', dict(conditional_lifetime_capacity=ssa['conditional_selected_SSA_lifetime_fits']))
    return guards


def attach(raw, selected, context):
    counts = context.mem_context.recognize(raw)
    source = identity(raw)
    require(selected['source'] == source and selected['source_counts'] == counts,
            'MEM/SSA selected actual source and complete counts')
    require(selected['conditions'].keys() == context.prior_reference['conditions'].keys()
        and selected['conditional_conditions'].keys() == selected['conditions'].keys(),
        'preserve accepted149 condition keys')
    core = selected['core_result']
    query = selected['selected_native_shared_query_lifetime']
    mem = context.mem['evaluate_source'](raw, core, query, context.mem_context)
    ssa = ssa_extension(raw, core, context)
    for label, leaf in [('MEM', mem), ('SSA', ssa)]:
        require(leaf['source'] == source and leaf['source_counts'] == counts,
                'attached actual source and complete counts '+label)
    c = counts['output_calls']
    rtl, attrs, df = mem['RTL'], mem['mem_attrs'], mem['DF']
    q0, cap0 = context.mem['register_capacity'](98+3*c)
    q, cap = context.mem['register_capacity'](99+5*c)
    require(attrs['variable_records_already_owned'] == 5*c
        and attrs['pool_setter_records_upper'] == 4*c and attrs['call_setter_records_upper'] == c
        and attrs['record_raw_bytes'] == 40 and attrs['fixed_setup_events_already_owned'] == 437
        and attrs['fixed_setup_recharged'] is False
        and all(attrs[k] == 0 for k in ('later_additional_records', 'frame_records',
            'CFI_records', 'copy_records', 'hash_backing_requests'))
        and mem['new_mem_attrs_events'] == 0, 'MEM existing5C and fixed437 owners once')
    require(rtl['pre_split_growths_already_owned'] == q0 and rtl['complete_Main_growths_upper'] == q
        and rtl['pre_split_array_capacity_upper'] == cap0 and rtl['final_array_capacity_upper'] == cap
        and rtl['each_final_pointer_request_bytes_upper'] == 8*cap
        and rtl['each_final_alignment_request_bytes_upper'] == cap
        and rtl['later_additional_pointer_GGC_backings_upper'] ==
            rtl['later_additional_alignment_requests_upper'] == mem['new_GGC_backing_events_upper'] == q-q0,
        'disjoint later register backing owner q(K)-q(K0)')
    pools = df['ordinary_pools']
    require(df['instances'] == 1 and df['scan_generations'] == 2
        and df['scan_rebuild_resets_ref_order'] is False
        and df['scan_rebuild_releases_old_pools_before_allocating_new'] is True
        and len(pools) == 6 and all(p['generations_upper'] == 2 for p in pools)
        and [p['blocks_already_priced'] for p in pools] == [False]*4+[True]*2
        and all(p['lifetime_block_requests_upper'] == 2*p['blocks_per_generation_upper'] for p in pools)
        and df['newly_priced_blocks_upper_per_generation'] == sum(p['blocks_per_generation_upper'] for p in pools[:4])
        and df['newly_priced_lifetime_block_requests_upper'] == 2*df['newly_priced_blocks_upper_per_generation']
        and all(p[k] == 0 for p in pools+mem['LRA']['ordinary_pools']
            for k in ('GGC_events', 'scalar_finalizers', 'array_finalizers')),
        'DF per-generation retention and lifetime requests remain distinct ordinary owners')
    require(ssa['additional_GGC_events_charged'] == ssa['additional_scalar_registrations_charged'] ==
        ssa['helper_SSA_owners_added_again'] == ssa['initial_scalar_registration_added_again'] == 0
        and ssa['retained_initial_SSA_owned_GGC_events_upper'] ==
            core['native_initial_SSA_lifetime']['additional_GGC_request_events_upper'],
        'SSA extends initial allowance without second charge')
    require(all(mem[k] is False for k in ('complete_global_counter_lifetime_closed',
        'complete_array_finalizer_lifetime_closed', 'complete_collector_lifetime_closed',
        'complete_all_ordinary_helper_lifetimes_closed', 'whole_literal_pipeline_capacity_established',
        'production_admission_changed', 'aggregate_RAM_gate')) and mem['total_GGC_events'] is None
        and all(selected[k] is False for k in ('whole_literal_pipeline_capacity_established',
            'complete_native_capacity', 'complete_proof_pipeline_capacity', 'complete_parent_storage_closed',
            'production_launcher_adopted', 'production_admission_changed', 'aggregate_RAM_gate'))
        and selected['complete_imported_allocation_events'] is None
        and selected['complete_imported_allocation_bytes'] is None,
        'native collector global and full-pipeline scope remains incomplete')
    guards = arithmetic_guards(mem, ssa)
    require(not (selected['conditions'].keys() & guards.keys()), 'new guards cannot replace inherited149')
    result = copy.deepcopy(selected)
    result['conditions'].update(guards)
    result['conditional_conditions'].update(guards)
    result.update(scope='Actual-source selected literal route with accepted MEM/counter/pool and SSA lifetimes; incomplete whole pipeline',
        evaluated_predicates_pass=all(v is True for v in result['conditions'].values()),
        conditional_arithmetic_pass=all(result['conditional_conditions'].values()),
        failed_predicates=[k for k,v in result['conditions'].items() if v is False],
        failed_conditional_predicates=[k for k,v in result['conditional_conditions'].items() if not v],
        unresolved_predicates=[k for k,v in result['conditions'].items() if v is None],
        selected_native_MEM_counter_lifetime=mem, selected_native_SSA_lifetime_extension=ssa,
        validation=context.validation)
    result['mem_ssa_attachment'] = dict(source=source, source_counts=counts,
        inherited_guards=149, new_guards=len(guards), guards=guards,
        actual_core_query_and_initial_SSA_owners_joined=True,
        accepted_current_scopes=dict(mem_attrs_setters=True, RTL_UID_pseudo_arrays=True,
            alias_incoming_and_reuse=True, DF_reference_order_and_typed_pools=True,
            LRA_value_and_recognition_pools=True, selected_cfun_sequence_owner_transfer=True,
            selected_emission_counters=True, SSA_names_defaults_and_operand_slabs=True),
        owners=dict(mem_attrs=dict(existing_variable_records=5*c, new_later_records=0,
                existing_fixed_setup_envelope=437, fixed_setup_added_again=False),
            later_register_arrays=dict(existing_pre_split_growths=q0, complete_growths=q,
                new_GGC_pointer_backings=q-q0, new_ordinary_alignment_requests=q-q0,
                individual_pointer_request_bytes_upper=8*cap, individual_alignment_request_bytes_upper=cap,
                initial_dummy_and_Main_owners_added_again=False),
            SSA=dict(retained_initial_GGC_events=ssa['retained_initial_SSA_owned_GGC_events_upper'],
                new_later_GGC_events=0, helper_events_added_again=0, scalar_registration_added_again=0),
            DF=dict(new_ordinary_blocks_per_generation=df['newly_priced_blocks_upper_per_generation'],
                new_ordinary_lifetime_block_requests=df['newly_priced_lifetime_block_requests_upper'],
                generations=2, old_generation_released_before_next=True,
                existing_register_pool_added_again=False, GGC_events=0)),
        predecessor_event_owners=copy.deepcopy(selected['lifetime_attachment']['event_owners']),
        all_event_owners_are_scoped_and_not_a_complete_ledger=True,
        predecessor_lifetime_attachment_accepted_at='ad0b400815c0275ab89cc75316f2aede66f9c45e',
        frozen_MEM_and_predecessor_pending_flags_preserved_as_history=True,
        accepted_reviews=[r for r in read(HERE/'inputs.json')['files'] if '/reviews/' in r['path']],
        independent_attachment_review_status='pending', total_GGC_events=None)
    result['MEM_SSA_leaf_scope'] = ('Frozen MEM pending-review and later-SSA/open-family fields remain historical. '
        'mem_ssa_attachment labels its accepted current scopes, and selected_native_SSA_lifetime_extension '
        'extends the existing initial owner. No frozen Hello result is used as a general source evaluator.')
    result['accounting'] += (' MEM5C and fixed437 retain their owners. Only q(99+5C)-q(98+3C) additional '
        'register pointer backings are newly attached GGC events; matching alignment arrays and DF pools '
        'are ordinary storage. SSA6C+10+L extends its initial lifetime with zero additional charge. '
        'DF per-generation retained blocks and lifetime requests are distinct. No complete total follows.')
    result['open_joins']['native_remaining_lifetime_and_collector'] = ('Selected MEM/setter, RTL/DF/LRA/emission '
        'chronology, typed DF/LRA pools and SSA-name/default/operand-slab lifetime scopes are attached. '
        'Remaining gimplifier/pass-manager/ordinary pools and shared bitmap/ET lifetime, ordinary stack, '
        'typed-array and outer-finalizer/depth, collector page/mark/epoch metadata, remaining frontend/pass '
        'heaps and complete disjoint positive event/object ledger remain open. No complete original/native total follows.')
    return result


def evaluate(descriptor_path, context, source_override=None):
    selected = context.prior['evaluate'](descriptor_path, context.prior_context, source_override)
    return attach(Path(selected['source_path']).read_bytes(), selected, context)


if __name__ == '__main__':
    start = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor', type=Path, default=PIPELINE/'selected-route.json')
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = evaluate(args.descriptor, Context(args.gcc_root, args.ada_root, args.plugin_include, args.gcc_match), args.source)
    result['offline_run'] = dict(started_utc=start, completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(evaluated_predicates_pass=result['evaluated_predicates_pass'],
        guards=len(result['conditions']), whole_literal_pipeline_capacity_established=False)))
