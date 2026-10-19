#!/usr/bin/env python3
"""Attach accepted native GGC owners to actual219; no full native capacity claim."""
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
PRIOR = E/'retained-literal-pool-finalizer-attachment-20261019'
LEDGER = E/'retained-literal-native-ggc-ledger-20261019'
PIPELINE = E/'retained-literal-pipeline-20261018'


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        pins = runpy.run_path(str(E/'retained-literal-lifetime-attachment-20261019/compose.py'))
        manifest = read(HERE/'inputs.json')
        pins['check_pins'](manifest)
        self.prior = runpy.run_path(str(PRIOR/'compose.py'))
        self.prior_context = self.prior['Context'](gcc_root,ada_root,plugin_include,gcc_match)
        self.reference = read(PRIOR/'result.json')
        require(len(self.reference['conditions']) == 219, 'accepted219 condition schema')
        self.route_api = self.prior_context.prior_context.prior_context.selected
        self.native = runpy.run_path(str(LEDGER/'derive.py'))
        self.native_context = self.native['Context'](gcc_root)
        self.native_reference = read(LEDGER/'result.json')
        self.native_checks = self.native_reference['local_representation_checks'].keys()
        self.validation = dict(accepted_current_and_historical_records=len(manifest['files']),
            predecessor=self.prior_context.validation, native=self.native_context.verified,
            identity_sets_overlap_and_must_not_be_added=True,
            all_executable_compiler_configuration_inputs_are_actual_pinned_bytes=True,
            no_new_historical_input_exception=True, predecessor_suites_rerun=False,
            source_reachability_arguments_are_reviewed_handwritten_arguments=True,
            upstream_false_guards_short_circuit_native_evaluation=True,
            source_configuration_and_owner_checks_precede_short_circuit=True,
            actual_finalizer_theorem_compared_with_native_premises=True)


def structural_leaf(leaf, label):
    """Omit only explicitly exported arithmetic flags from an owner comparison."""
    leaf = copy.deepcopy(leaf)
    if label == 'pool':
        for key in ('local_representation_checks','inherited_owner_guards',
                    'conditional_selected_shared_bitmap_and_pool_capacity_established'):
            del leaf[key]
        for domain in leaf['bit_domains'].values():
            del domain['fits']
        for row in leaf['dominance']['ordinary_pools']+[leaf['LRA_additional_pools']['live_ranges']]:
            del row['fits']
    else:
        for key in ('retained_scalar_guards','local_representation_checks',
                    'conditional_selected_finalizer_capacity'):
            del leaf[key]
    return leaf


def validate_joins(raw, selected, context):
    """Pure source/owner validation runs even when prerequisite arithmetic fails.

    Reuse the accepted actual-source pool/finalizer attachment for its full
    invocation and ordinary cold-owner checks. No inherited guard is promoted:
    the178 subset keeps its actual values; the219 input itself is untouched.
    Native event/storage evaluation is a separate subsequent operation.
    """
    counts, source = context.native_context.recognize(raw), identity(raw)
    require(all(32 <= b <= 126 or b in (9,10,13) for b in raw), 'current selected source alphabet')
    core = selected['core_result']
    require(selected['source'] == core['source'] == source, 'actual source identity')
    require(selected['source_counts'] == core['source_counts'] == counts, 'actual source counts')
    require(selected['source_path'] == core['source_path'], 'exact source path')
    require(Path(selected['source_path']).read_bytes() == raw, 'actual source path bytes')
    require(selected['launch'] == core['launch'] and selected['complete_path_bound'] == core['complete_path_bound'],
        'path/launch equality')
    require(selected['conditions'].keys() == selected['conditional_conditions'].keys() ==
        context.reference['conditions'].keys(), 'preserve accepted219 condition keys')
    require(all(type(v) is bool for field in ('conditions','conditional_conditions')
        for v in selected[field].values()), 'boolean inherited219 arithmetic')
    for name in ('selected_native_frontend_storage','selected_current_source_bound_shared_storage',
            'selected_native_MEM_counter_lifetime','selected_native_SSA_lifetime_extension',
            'lifetime_attachment','mem_ssa_attachment'):
        require(selected[name]['source'] == source and selected[name]['source_counts'] == counts,
            'nested same-source owner '+name)
    # Reuse the accepted correspondence-only invocation join too: agreement
    # between two mutated launch records is insufficient without the actual
    # configured graph, fixed materialization inputs and exact output owners.
    context.route_api['join_invocation'](raw,core,selected['selected_native_invocation'],
        context.prior_context.route_context)
    launch = selected['launch']
    require(set(launch) == {'native_Main','datarep_Main','phase1_Main','phase2_Main',
        'native_options','producer_options','library_source_directory'} and
        launch['native_options'] == ['-gnatx','-Wno-free-nonheap-object','-fsplit-wide-types'] and
        launch['producer_options'] == ['-Wno-free-nonheap-object'], 'exact accepted launch options')
    require(all(identity((Path(launch['library_source_directory'])/role).read_bytes()) ==
        core['actual_shared_inputs'][role] for role in ('silver_io.ads','silver_io.adb','silver_output_libc.ads')),
        'launch fixed library source identities')
    # Revalidate all accepted pool/finalizer source/configuration/ordinary owner
    # relations, ignoring only their explicitly exported arithmetic flags in the
    # comparison. This is not an evaluation of the native ledger on failed input.
    pre219 = copy.deepcopy(selected)
    old_keys = context.prior_context.reference['conditions'].keys()
    for field in ('conditions','conditional_conditions'):
        pre219[field] = {k:pre219[field][k] for k in old_keys}
    checked = context.prior['attach'](raw, pre219, context.prior_context)
    for label, field in [('pool','selected_native_shared_bitmap_pool_lifetime'),
                         ('finalizer','selected_native_finalizer_lifetime')]:
        require(structural_leaf(selected[field],label) == structural_leaf(checked[field],label),
            'complete actual '+label+' source theorem and owner fields')
    # These are the accepted native composer's non-arithmetic owner premises,
    # checked here as well so a failed prerequisite cannot mask their mismatch.
    c,n = counts['output_calls'],counts['null_statements']
    ingress = core['native_gimplifier_ingress']
    require(ingress['whole_body_GGC_request_events_upper'] == 33*c+9*n+3 and
        ingress['corrected_direct_gimplifier_GGC_events_upper'] == 10*c+2*n+2 and
        ingress['selected_helper_subtotal_GGC_events_upper'] == 8*c, 'gimplifier existing owners')
    op = core['native_lowering_data']['conditional_native_selected_constructor_requests']
    require(op['selected_nonchain_RTX_lifetime_requests_upper'] == 104*c+n+17 and
        op['selected_rtvec_lifetime_requests_upper'] == 2*c+2 and
        op['call_and_move_sequence_stack_requests_upper'] == 8*c, 'operation owner interface')
    require(core['selected_native_backing']['DF_selected_reference_and_solver_transfer'][
        'selected_REG_DEAD_UNUSED_note_requests_upper'] == 600*c, 'DF/LRA note owner')
    mem = selected['selected_native_MEM_counter_lifetime']
    require(mem['RTL']['final_first_unused_pseudo_upper'] == 99+5*c and
        mem['RTL']['final_chain_upper'] == 7*c+7*n+45 and mem['mem_attrs']['variable_records_already_owned'] == 5*c,
        'MEM/register/chain owners')
    shared = selected['selected_current_source_bound_shared_storage']
    original = core['native_original_shared_storage']['partial_ledger']
    distinct = int(counts['Put']>0)+int(counts['Put_Line']>0)
    require(original['GGC_groups'] == dict(original_Main=609*c+24*n+54*distinct+398,
        original_String216=216,original_helpers94=94,synthetic173=173,
        new_shared_backings=331*c+12*n+19*distinct+418), 'original exact owner formulas')
    require(original['known_selected_GGC_event_subtotal'] == sum(original['GGC_groups'].values()) and
        original['GGC_groups']['new_shared_backings'] == shared['additional_shared_GGC_backing_request_events_upper'] and
        not original['prefix_and_filename_ingress_in_subtotal'] and
        not original['forced_dummy_and_warning_symbol_controls_in_subtotal'], 'original shared subtotal ownership')
    front = selected['selected_native_frontend_storage']['components']['gigi_array_and_name_input']
    require(front['association_array_requests'] == 2 and front['each_association_array_raw_bytes_upper'] ==
        8*front['joined_frontend_node_identities_upper'], 'association caller product')
    filename = shared['filename_ingress']
    require(filename['direct_GGC_requests_upper'] == 2*filename['lookup_calls_upper'] == 3180 and
        filename['each_character_caller_bytes_upper'] == selected['complete_path_bound']+1 and
        shared['identifier_hash']['incoming_historical_insertions_upper'] == 40847, 'filename and identifier owner')
    require(selected['selected_native_SSA_lifetime_extension']['later_new_SSA_NAME_objects'] == 0,
        'zero later SSA owner')
    f, fixed = selected['selected_native_finalizer_lifetime'], context.native_context.finalizer
    require((f['scalar_history_upper'], f['scalar_capacity_upper'], f['scalar_backing_bytes_upper']) ==
        (39275,58911,942584) and f['context_depth'] == f['array_registration_history'] == f['new_GGC_events'] == 0 and
        all(f[k] == fixed[k] for k in ('scalar_history_upper','scalar_capacity_upper','scalar_backing_bytes_upper',
            'context_depth','array_registration_history','depth_backing_bytes','outer_backing_bytes_each',
            'outer_vector_lengths','outer_vector_capacities','old_context_bitmap_backups')),
        'actual finalizer theorem equals accepted native premises')
    require(f['existing_ordinary_initialization'] == context.prior_context.initialization and
        not f['initialization_and_scalar_owners_recharged'] and f['selected_finalizer_lifetime_source_join_complete'] and
        f['actual_scalar_and_callback_owners_verified'] and f['actual_source_derived_configured_invocation_verified'],
        'actual finalizer initialization and configured source theorem')
    return source, counts


def arithmetic_guards(ledger, context):
    checks = ledger['local_representation_checks'] if ledger is not None else {k:None for k in context.native_checks}
    require(checks.keys() == context.native_checks, 'preserve accepted native guard schema')
    guards = {}
    for key,value in checks.items():
        require(ledger is None or type(value) is bool, 'boolean native GGC arithmetic '+key)
        guards['native_GGC_'+key] = value
    value = None if ledger is None else ledger['conditional_selected_GGC_and_collector_storage_capacity']
    require(ledger is None or type(value) is bool, 'boolean native GGC capacity conjunction')
    guards['native_GGC_conditional_capacity'] = value
    return guards


def attach(raw, selected, context):
    source, counts = validate_joins(raw, selected, context)
    reasons = [field+'.'+key for field in ('conditions','conditional_conditions')
        for key,value in selected[field].items() if not value]
    for name,value in [('selected.conditional_arithmetic_pass',selected['conditional_arithmetic_pass']),
                       ('core_result.conditional_arithmetic_pass',selected['core_result']['conditional_arithmetic_pass'])]:
        require(type(value) is bool, 'boolean inherited capacity summary '+name)
        if not value: reasons.append(name)
    # The native API requires true inherited guards. Never fabricate/promote
    # values to enter it: a false prerequisite leaves every new guard uncomputed.
    ledger = None if reasons else context.native['compose'](raw,selected['source_path'],selected,context.native_context)
    guards = arithmetic_guards(ledger,context)
    require(not (guards.keys() & selected['conditions'].keys()), 'new guards cannot replace inherited219')
    if ledger is not None:
        require(ledger['source'] == source and ledger['source_counts'] == counts and
            ledger['source_path'] == selected['source_path'] and ledger['launch'] == selected['launch'] and
            ledger['complete_path_bound'] == selected['complete_path_bound'] and
            ledger['same_source_path_and_owner_join_verified'], 'native actual source/path/launch join')
        rows = ledger['owner_rows']
        require(len({r['owner'] for r in rows}) == len(rows) and
            sum(r['positive_GGC_requests_upper'] for r in rows) == ledger['total_positive_GGC_events_upper'] and
            ledger['selected_GGC_event_partition_closed'], 'unique complete positive GGC event owners')
        require(not ledger['ownership']['original_subtotal_added_as_an_extra_row'] and
            not ledger['ownership']['scalar_finalizer_history_recomputed_from_event_total'] and
            ledger['gimplifier_exhaustion']['new_events'] == 0, 'zero and subtotal owners never charged again')
        f, collector = selected['selected_native_finalizer_lifetime'], ledger['collector']
        require((collector['scalar_finalizer_history_upper'],collector['scalar_finalizer_capacity_upper'],
            collector['scalar_finalizer_backing_bytes_upper']) ==
            (f['scalar_history_upper'],f['scalar_capacity_upper'],f['scalar_backing_bytes_upper']) and
            collector['array_finalizer_registrations'] == f['array_registration_history'] == 0 and
            collector['context_depth'] == f['context_depth'] == 0 and
            collector['depth_backing_bytes'] == f['depth_backing_bytes'] == 40 and
            collector['each_outer_finalizer_backing_bytes'] == f['outer_backing_bytes_each'] == 40 and
            collector['old_context_bitmap_backups'] == f['old_context_bitmap_backups'] == 0 and
            collector['callback_GGC_events'] == 0 and collector['marker_ordinary_request_bytes_each'] == 104,
            'native collector matches actual finalizer and callback owners')
        require(collector['active_pages_upper'] == ledger['total_positive_GGC_events_upper'] and
            not collector['unused_quire_pages_in_active_count'] and collector['actual_collection_count'] is None and
            not collector['scheduling_counters_require_cumulative_byte_no_wrap'] and
            not any(ledger[k] for k in ('complete_all_ordinary_native_capacity','complete_native_capacity',
                'whole_literal_pipeline_capacity_established','production_invocation_established',
                'production_admission_changed','aggregate_RAM_gate')), 'native indexed-only scope')
    result = copy.deepcopy(selected)
    result['conditions'].update(guards)
    result['conditional_conditions'].update(guards)
    passed = all(v is True for v in result['conditions'].values()) and not reasons
    conditional = all(v is True for v in result['conditional_conditions'].values()) and not reasons
    result.update(scope='Actual-source selected literal route with accepted complete positive GGC partition and conditional collector indexed storage; remaining ordinary/native/pipeline capacity open',
        evaluated_predicates_pass=passed,conditional_arithmetic_pass=conditional,
        failed_predicates=[k for k,v in result['conditions'].items() if v is False],
        failed_conditional_predicates=[k for k,v in result['conditional_conditions'].items() if v is False],
        unresolved_predicates=[k for k,v in result['conditions'].items() if v is None],
        selected_native_GGC_ledger=ledger,validation=context.validation,
        selected_positive_GGC_events_upper=None if ledger is None else ledger['total_positive_GGC_events_upper'],
        selected_active_pages_upper=None if ledger is None else ledger['collector']['active_pages_upper'],
        selected_GGC_event_partition_closed=ledger is not None,
        selected_collector_indexed_storage_capacity_established=passed and conditional)
    result['ggc_attachment'] = dict(source=source,source_counts=counts,inherited_guards=219,
        new_guards=len(guards),guards=guards,
        ledger_status='not_computed_upstream_arithmetic' if ledger is None else 'computed',
        ledger_not_computed_reasons=reasons,native_evaluation_performed=ledger is not None,
        source_configuration_ownership_checks_performed=True,
        actual_finalizer_scalar_array_depth_initialization_and_callbacks_joined=True,
        existing_ordinary_cold_and_all_predecessor_event_owners_preserved=True,
        zero_pool_finalizer_delta_recharged=False,
        source_event_partition_is_conditional_on_all_arithmetic=True,
        selected_GGC_and_indexed_collector_capacity_established=passed and conditional,
        frozen_leaf_pending_and_incomplete_flags_preserved_as_history=True,
        accepted_native_implementation='ca4ef8d20f557307b1d1085b42d570fc5d224d77',
        accepted_native_review='f58ceffafe3a7458447b24fa563aa3f7f146deca',
        accepted219_implementation='562493728b6cd0ec918cee1eb2848c05c2c3a565',
        accepted219_review='d454e615431be79b746bb62c19175d3d2191d196',
        independent_attachment_review_status='pending')
    result['accounting'] += (' The accepted native event partition is attached to actual source/path/launch/configuration '
        'and finalizer owners. Zero pool/finalizer deltas, ordinary initialization and existing event owners remain '
        'unchanged. New count/page bounds are conditional on all inherited and new arithmetic; an upstream failure '
        'leaves the native ledger uncomputed. Indexed collector storage does not close remaining ordinary capacity.')
    result['open_joins']['native_remaining_lifetime_and_collector'] = (
        'Selected positive GGC events and collector indexed storage are attached conditionally. Remaining IRA '
        'allocno/object/preference/cost-class and traversal/emit storage, LRA helper arrays/maps, RTL CFG/jump/label '
        'temporary containers, CFI trace/hash/vector capacity, stack and other required native/proof/parent phases '
        'remain open. No complete ordinary, native, producer, proof, parent or full-current-grammar capacity follows. '
        'Production launcher/materialization and source/binary correspondence remain separate.')
    return result


def evaluate(descriptor_path, context, source_override=None):
    selected = context.prior['evaluate'](descriptor_path,context.prior_context,source_override)
    return attach(Path(selected['source_path']).read_bytes(),selected,context)


if __name__ == '__main__':
    start,timer = datetime.now(timezone.utc).isoformat(),time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor',type=Path,default=PIPELINE/'selected-route.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    result = evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),args.source)
    result['offline_run'] = dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(evaluated_predicates_pass=result['evaluated_predicates_pass'],
        guards=len(result['conditions']),positive_GGC_events=result['selected_positive_GGC_events_upper'])))
