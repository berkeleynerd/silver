#!/usr/bin/env python3
"""Actual-source pool/finalizer attachment; whole collector capacity stays open."""
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
PRIOR = E/'retained-literal-mem-ssa-attachment-20261019'
POOL = E/'retained-literal-shared-bitmap-pools-20261019'
FINAL = E/'retained-literal-finalizer-lifetime-20261019'
PIPELINE = E/'retained-literal-pipeline-20261018'
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


def finalizer_inputs(gcc_root):
    """Complete retained identities/excerpts; no fixed-result checker/census run."""
    manifest = read(FINAL/'inputs.json')
    roots = dict(gcc=Path(gcc_root), repo=REPO)
    for row in manifest['files']:
        require(identity((roots[row['root']]/row['path']).read_bytes()) ==
            {k:row[k] for k in ('bytes','sha256')}, 'changed finalizer source input '+row['path'])
    for row in manifest['excerpts']:
        lines = (roots['gcc']/row['path']).read_bytes().split(b'\n')
        raw = b'\n'.join(lines[row['first']-1:row['last']])+b'\n'
        require(hashlib.sha256(raw).hexdigest() == row['sha256'],
            'changed finalizer LF source excerpt '+row['path'])
    projection = manifest['array_sites']
    counts = dict(compiler=sum(r['root']=='gcc' for r in manifest['files']),
        repository=sum(r['root']=='repo' for r in manifest['files']), excerpts=len(manifest['excerpts']),
        retained_array_types=len(projection), retained_array_sites=sum(map(len,projection.values())))
    require(counts == dict(compiler=24, repository=8, excerpts=27,
        retained_array_types=15, retained_array_sites=28), 'complete accepted finalizer inventory')
    # Read only the already-owned initialization values from the retained census.
    # Its historical page/event/array substitutions do not enter this attachment.
    prior = read(REPO/manifest['array_census'])['collector_backing_substitution']
    initialization = {k:prior[k] for k in ('context_depth','depth_vector_bytes','each_outer_finalizer_vector_bytes')}
    require(initialization == dict(context_depth=0, depth_vector_bytes=40,
        each_outer_finalizer_vector_bytes=40), 'existing ordinary collector initialization owners')
    return counts, initialization


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        self.prior = runpy.run_path(str(PRIOR/'compose.py'))
        # Use the accepted historical/current-record checker; all inputs remain
        # actual current bytes matching their accepted commit, except its already
        # reviewed prose-only exception inside the unchanged predecessor Context.
        pin_api = runpy.run_path(str(E/'retained-literal-lifetime-attachment-20261019/compose.py'))
        manifest = read(HERE/'inputs.json')
        pin_api['check_pins'](manifest)
        self.prior_context = self.prior['Context'](gcc_root, ada_root, plugin_include, gcc_match)
        self.reference = read(PRIOR/'result.json')
        require(len(self.reference['conditions']) == 178, 'accepted178 condition schema')
        self.route_context = self.prior_context.prior_context.selected_context
        self.pool = runpy.run_path(str(POOL/'derive.py'))
        self.pool_context = self.pool['Context'](gcc_root)
        require((self.pool_context.source_files, self.pool_context.repository_files) == (38,19),
            'complete accepted pool identity inventory')
        self.finalizer_validation, self.initialization = finalizer_inputs(gcc_root)
        lines = (Path(gcc_root)/'gcc/lra-lives.cc').read_text().split('\n')
        require(lines[529] == 'static vec<int> point_freq_vec;', 'reviewed point-frequency vec<int> representation')
        self.point_frequency_representation = dict(element_type='int', element_bytes=4,
            reserve_and_growth_arithmetic='unsigned', compression='MAX or copy; no signed sum',
            actual_declaration='gcc/lra-lives.cc:530: static vec<int> point_freq_vec;',
            accepted_nonblocking_erratum='docs/reviews/review-literal-bitmap-finalizer-mem-ssa-e28fef05f2.md')
        self.validation = dict(accepted_current_and_historical_records=len(manifest['files']),
            predecessor=self.prior_context.validation,
            pool=dict(compiler=self.pool_context.source_files, repository=self.pool_context.repository_files),
            finalizer=self.finalizer_validation, identity_sets_overlap_and_must_not_be_added=True,
            all_executable_compiler_configuration_inputs_are_actual_pinned_bytes=True,
            no_new_historical_input_exception=True, accepted_array_census_reused_not_regenerated=True,
            fixed_finalizer_checker_used_as_general_evaluator=False,
            finalizer_adapter='Actual recognized source, actual scalar/callback owners and exact source-derived configured invocation; accepted source theorem supplies zero array registrations and depth0 independently of C/N.',
            point_frequency_representation=self.point_frequency_representation,
            predecessor_suites_rerun=False,
            source_reachability_arguments_are_reviewed_handwritten_arguments=True)


def finalizer_extension(raw, selected, context):
    """General source theorem attachment; never execute/promote the fixed sample."""
    counts, source = context.pool_context.recognize(raw), identity(raw)
    core, query = selected['core_result'], selected['selected_native_shared_query_lifetime']
    invocation = selected['selected_native_invocation']
    require(all(r['source'] == source and r['source_counts'] == counts for r in (core,query)) and
        invocation['source_identity'] == source and invocation['source_counts'] == counts,
        'finalizer actual source and complete counts')
    # Recompute the accepted general invocation interface from the actual bytes
    # and path class using the existing verified Context. This rejects PCH,
    # plugins, extra flags/jobs/environment or altered materialization inputs.
    runtime = dict(cwd=invocation['graph']['project_root'],
        binder_temporary_root=invocation['processes'][0]['environment']['TMPDIR'])
    route = context.route_context
    configured = route.invocation['build'](raw, route.invocation_context, runtime,
        path_bytes=core['complete_path_bound']+1, host_page_bytes=4096)
    require(invocation == configured, 'exact accepted source-derived selected invocation')
    scalar = query['scalar_finalizers']
    owner = dict(incoming_history_upper=39257, original_registrations_already_owned=5,
        named_registrations_already_owned=6, RTL_registrations_already_owned=5,
        alias_graph_registrations_already_owned=2, other_later_registrations=0,
        additional_registrations_upper=18, historical_registrations_upper=39275,
        occupied_upper=39275, allocated_slots_upper=58911, each_ordinary_backing_bytes_upper=942584,
        complete_selected_lifetime_closed=True)
    require(query['complete_scalar_finalizer_lifetime_closed'] and
        {k:v for k,v in scalar.items() if k != 'checks'} == owner,
        'actual complete scalar39275 capacity58911 owner')
    callback = core['native_collector_callbacks']
    require(callback['source'] == source and callback['source_counts'] == counts and
        callback['selected_literal_collector_callback_effects_closed'] is True and
        callback['value_expression_insertions_upper'] == callback['collector_callback_additional_GGC_events'] ==
        callback['finalizer_additional_ordinary_allocation_requests'] == 0 and
        callback['value_expression_marker'] == dict(ordinary_hash_backing_requests_per_callback=1,
            each_ordinary_hash_backing_bytes=104, hash_insertions=0, recursive_tree_walks=0,
            dynamic_vector_backing_requests=0), 'actual selected callback zero-allocation effects')
    checks = dict(context_depth_masks_fit_64_bits=0 <= 0 < 63,
        depth_entries_fit_existing_ten=1 <= 10,
        depth_individual_request_span=40 <= I64,
        outer_vector_length_unsigned=1 <= U32,
        outer_vector_growth_and_capacity=4 <= I32 and 3*4 <= U32,
        outer_individual_request_span=8+4*8 <= I64)
    return dict(source=source, source_counts=counts,
        scope='Accepted selected literal array/depth/outer-finalizer source theorem attached to actual configured source; attachment review pending',
        context_depth=0, depth_entries_used_upper=1, depth_backing_bytes=40,
        outer_vector_lengths=[1,1], outer_vector_capacities=[4,4], outer_backing_bytes_each=40,
        old_context_bitmap_backups=0,
        scalar_history_upper=scalar['historical_registrations_upper'],
        scalar_capacity_upper=scalar['allocated_slots_upper'],
        scalar_backing_bytes_upper=scalar['each_ordinary_backing_bytes_upper'],
        retained_scalar_guards=copy.deepcopy(scalar['checks']), local_representation_checks=checks,
        conditional_selected_finalizer_capacity=all(checks.values()) and all(scalar['checks'].values()),
        array_registration_history=0, array_inner_capacity=0, array_inner_backing_requests=0,
        vector_destructor_loop_reachable=False, new_GGC_events=0,
        new_scalar_registrations=0, new_array_registrations=0,
        initialization_and_scalar_owners_recharged=False,
        existing_ordinary_initialization=copy.deepcopy(context.initialization),
        actual_scalar_and_callback_owners_verified=True,
        actual_source_derived_configured_invocation_verified=True,
        selected_finalizer_lifetime_source_join_complete=True,
        accepted_source_argument_target='2b16ef1814d5c668590dc9728fef94d46ea549cd',
        accepted_source_argument_review='d22953155f84b5ad875a74bbf6e565c9ae37c7cc',
        source_argument_is_handwritten=True, total_GGC_events=None, active_page_bound=None,
        by_depth_and_save_in_use_page_arrays_closed=False,
        complete_collector_capacity=False, full_pipeline_capacity=False,
        production_admission_changed=False, aggregate_RAM_gate=False)


def arithmetic_guards(pool, finalizer):
    guards = {}
    def add(prefix, checks):
        for key, value in checks.items():
            require(type(value) is bool, 'boolean pool/finalizer arithmetic '+prefix+key)
            name = 'native_pool_finalizer_'+prefix+key
            require(name not in guards, 'distinct pool/finalizer arithmetic '+name)
            guards[name] = value
    add('pool_', pool['local_representation_checks'])
    add('pool_inherited_', pool['inherited_owner_guards'])
    add('pool_domain_', {k:row['fits'] for k,row in pool['bit_domains'].items()})
    for row in pool['dominance']['ordinary_pools']+[pool['LRA_additional_pools']['live_ranges']]:
        add('pool_fit_', {row['family'].replace(' ','_'):row['fits']})
    add('pool_', dict(conditional_capacity=pool['conditional_selected_shared_bitmap_and_pool_capacity_established']))
    add('finalizer_scalar_', finalizer['retained_scalar_guards'])
    add('finalizer_', finalizer['local_representation_checks'])
    add('finalizer_', dict(conditional_capacity=finalizer['conditional_selected_finalizer_capacity']))
    return guards


def attach(raw, selected, context):
    counts, source = context.pool_context.recognize(raw), identity(raw)
    require(selected['source'] == source and selected['source_counts'] == counts,
        'pool/finalizer actual source and complete counts')
    require(selected['conditions'].keys() == context.reference['conditions'].keys() and
        selected['conditional_conditions'].keys() == selected['conditions'].keys(), 'preserve accepted178 condition keys')
    core, query, mem = (selected[k] for k in ('core_result', 'selected_native_shared_query_lifetime',
        'selected_native_MEM_counter_lifetime'))
    # Keep the full ordinary cold owners, including the conservative initial
    # ET block capacities, rather than just their new leaf's small projections.
    c, n = counts['output_calls'], counts['null_statements']
    route = context.route_context
    for field, function in [('native_initial_SSA_lifetime','native_initial_ssa_lifetime'),
            ('native_initial_CF_CFG_lifetime','native_initial_cf_cfg_lifetime')]:
        expected = route.core[function](c,n,route.core_context)
        require(core[field]['ordinary_requests'] == expected['ordinary_requests'],
            'complete existing ordinary cold CFG/SSA owners '+field)
    require(core['native_SSA_helper_backing'] ==
        route.core['native_ssa_helper_backing'](c,n,route.core_context),
        'complete existing ordinary cold SSA helper owners')
    pool = context.pool['evaluate_source'](raw, core, query, mem, context.pool_context)
    finalizer = finalizer_extension(raw, selected, context)
    for label, leaf in [('pool',pool), ('finalizer',finalizer)]:
        require(leaf['source'] == source and leaf['source_counts'] == counts,
            'attached complete actual source and counts '+label)
    require(all(pool[k] == finalizer[k] == 0 for k in ('new_GGC_events', 'new_scalar_registrations',
        'new_array_registrations')) and pool['collector_callback_GGC_events'] == 0,
        'zero pool/finalizer GGC and registration deltas')
    lra, dom = pool['LRA_additional_pools'], pool['dominance']
    require(pool['retained_bitmap_owner_rows']['no_predecessor_event_owner_recharged'] is True and
        pool['DF_bitmap_families']['initial_chunks_retain_existing_owners'] is True and
        pool['DF_bitmap_families']['generations_coexist'] is False and
        pool['DF_bitmap_families']['returned_block_cache_is_separate'] is True and
        lra['copy_and_invariant_controls_retain_existing_owners'] is True and
        lra['invariant_vector_initial_slots_already_owned'] == 100 and
        lra['invariant_hash_initial_slots_already_owned'] == 127 and
        lra['copy_pool_objects'] == lra['invariant_pool_objects'] == lra['live_range_copies'] == 0 and
        dom['initial_CF_SSA_and_RTL_cold_block_owners_recharged'] is False,
        'existing ordinary cold bitmap pool and invariant owners retained once')
    require(pool['bitmap_allocator']['lifetime_chunk_requests_upper'] is None and
        pool['bitmap_allocator']['cumulative_chunk_or_element_count_field'] is False and
        pool['shared_block_cache']['stored_block_count_field'] is False and
        all(r['lifetime_block_requests_upper'] is None for r in dom['ordinary_pools']+[lra['live_ranges']]),
        'ordinary representation argument does not invent lifetime or aggregate counters')
    require(finalizer['initialization_and_scalar_owners_recharged'] is False and
        (finalizer['scalar_history_upper'], finalizer['scalar_capacity_upper'], finalizer['scalar_backing_bytes_upper']) ==
            (39275,58911,942584) and finalizer['context_depth'] == 0 and
        finalizer['depth_entries_used_upper'] == 1 and finalizer['depth_backing_bytes'] == 40 and
        finalizer['outer_vector_lengths'] == [1,1] and finalizer['outer_vector_capacities'] == [4,4] and
        finalizer['outer_backing_bytes_each'] == 40 and finalizer['old_context_bitmap_backups'] == 0 and
        finalizer['array_registration_history'] == finalizer['array_inner_capacity'] ==
            finalizer['array_inner_backing_requests'] == 0 and finalizer['vector_destructor_loop_reachable'] is False,
        'existing scalar and initialization owners and zero-array depth0 source theorem')
    require(pool['total_GGC_events'] is finalizer['total_GGC_events'] is finalizer['active_page_bound'] is None and
        pool['complete_collector_lifetime_closed'] is False and finalizer['complete_collector_capacity'] is False and
        finalizer['by_depth_and_save_in_use_page_arrays_closed'] is False and
        all(selected[k] is False for k in ('whole_literal_pipeline_capacity_established','complete_native_capacity',
            'complete_proof_pipeline_capacity','complete_parent_storage_closed','production_launcher_adopted',
            'production_admission_changed','aggregate_RAM_gate')) and
        selected['complete_imported_allocation_events'] is selected['complete_imported_allocation_bytes'] is None,
        'page GGC native and complete-pipeline scope remains open')
    guards = arithmetic_guards(pool, finalizer)
    require(not (guards.keys() & selected['conditions'].keys()), 'new guards cannot replace inherited178')
    result = copy.deepcopy(selected)
    result['conditions'].update(guards)
    result['conditional_conditions'].update(guards)
    result.update(scope='Actual-source selected literal route with accepted shared bitmap/pool and finalizer lifetimes; incomplete native/collector/pipeline',
        evaluated_predicates_pass=all(v is True for v in result['conditions'].values()),
        conditional_arithmetic_pass=all(result['conditional_conditions'].values()),
        failed_predicates=[k for k,v in result['conditions'].items() if v is False],
        failed_conditional_predicates=[k for k,v in result['conditional_conditions'].items() if not v],
        unresolved_predicates=[k for k,v in result['conditions'].items() if v is None],
        selected_native_shared_bitmap_pool_lifetime=pool,
        selected_native_finalizer_lifetime=finalizer, validation=context.validation)
    result['pool_finalizer_attachment'] = dict(source=source, source_counts=counts,
        inherited_guards=178, new_guards=len(guards), guards=guards,
        actual_core_MEM_query_and_configured_invocation_joined=True,
        accepted_current_scopes=dict(selected_shared_ordinary_bitmap_representation=True,
            selected_LRA_live_copy_invariant_pools=True, selected_dominance_ET_pools=True,
            selected_array_finalizers=True, selected_context_depth_and_outer_vectors=True,
            existing_scalar_owner_retained=True),
        new_GGC_events=0, new_scalar_registrations=0, new_array_registrations=0,
        existing_ordinary_cold_owners_preserved=True,
        existing_scalar39275_and_initialization_charged_again=False,
        conservative_initial_CFG_SSA_ET_owners_unchanged=True,
        prior_MEM_SSA_and_shared_event_owners=copy.deepcopy(selected['mem_ssa_attachment']['owners']),
        point_frequency_representation=copy.deepcopy(context.point_frequency_representation),
        no_new_total_or_pending_ledger_input=True,
        frozen_leaf_pending_and_incomplete_flags_preserved_as_history=True,
        accepted_reviews=[r for r in read(HERE/'inputs.json')['files'] if '/reviews/' in r['path']],
        independent_attachment_review_status='pending', total_GGC_events=None, active_page_bound=None)
    result['pool_finalizer_leaf_scope'] = ('Frozen pool review/finalizer-open flags remain historical. '
        'pool_finalizer_attachment labels current accepted selected scopes. Finalizer source theorem is '
        'attached to actual source/configuration/scalar/callback owners; no fixed result supplies a universal evaluator.')
    result['accounting'] += (' Shared bitmap/pool and finalizer joins add zero GGC events and zero scalar/array '
        'registrations. Existing ordinary cold bitmap/ET/LRA initialization and scalar39275/58911 plus '
        'depth/outer40-byte requests remain owned once. No ordinary lifetime chunk total or page/GGC total follows.')
    result['open_joins']['native_remaining_lifetime_and_collector'] = ('Selected shared ordinary bitmap '
        'representation, LRA live/copy/invariant and dominance ET pool scopes plus selected array finalizer, '
        'depth0 and outer-vector lifetimes are attached. Other ordinary helpers/IRA pools and stack, '
        'complete disjoint positive GGC event/object/request ledger, collector pages/marks/free-page/order/'
        'epoch/by_depth/save_in_use metadata and counters, remaining frontend/pass heaps and other required '
        'native/proof/parent phases remain open. No complete original/native total follows.')
    return result


def evaluate(descriptor_path, context, source_override=None):
    selected = context.prior['evaluate'](descriptor_path, context.prior_context, source_override)
    return attach(Path(selected['source_path']).read_bytes(), selected, context)


if __name__ == '__main__':
    start, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor', type=Path, default=PIPELINE/'selected-route.json')
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = evaluate(args.descriptor, Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match), args.source)
    result['offline_run'] = dict(started_utc=start, completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(evaluated_predicates_pass=result['evaluated_predicates_pass'],
        guards=len(result['conditions']), whole_literal_pipeline_capacity_established=False)))
