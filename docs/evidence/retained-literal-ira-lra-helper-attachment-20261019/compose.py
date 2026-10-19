#!/usr/bin/env python3
"""Attach accepted named IRA/LRA helper storage to actual-source335."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
PRIOR = E / 'retained-literal-ira-numeric-attachment-20261019'
HELPER = E / 'retained-literal-ira-lra-helpers-20261019'
PIPELINE = E / 'retained-literal-pipeline-20261018'
NUMERIC_FIELD = 'selected_native_IRA_numeric_arithmetic'
IRA_FIELD = 'selected_native_IRA_ordinary_storage'
HELPER_FIELD = 'selected_native_IRA_LRA_helper_storage'
SUMMARY = 'selected_named_IRA_LRA_helper_storage_established'
ATTACHMENT = 'IRA_LRA_helper_attachment'
LRA_GUARD = 'native_GGC_LRA_signed_hard_register_frequency'
PREFIX = 'native_IRA_LRA_helper_'
CONJUNCTION = PREFIX + 'conditional_capacity'


def read(path):
    return json.loads(Path(path).read_bytes())


def require(value, message):
    if not value:
        raise ValueError(message)


def without(record, keys):
    return {k: v for k, v in record.items() if k not in keys}


def summaries(selected):
    return [
        ('selected.evaluated_predicates_pass', selected['evaluated_predicates_pass']),
        ('selected.conditional_arithmetic_pass', selected['conditional_arithmetic_pass']),
        ('selected.named_ordinary_capacity', selected['selected_named_ordinary_capacity_established']),
        ('ordinary_attachment.named_capacity', selected['ordinary_attachment']['selected_named_ordinary_capacity_established']),
        ('selected.named_numeric_capacity', selected['selected_named_IRA_numeric_arithmetic_established']),
        ('numeric_attachment.named_capacity', selected['IRA_numeric_attachment']['selected_named_IRA_numeric_arithmetic_established']),
        ('core.conditional_arithmetic_pass', selected['core_result']['conditional_arithmetic_pass'])]


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        pins = runpy.run_path(str(E / 'retained-literal-lifetime-attachment-20261019/compose.py'))
        self.manifest = read(HERE / 'inputs.json')
        pins['check_pins'](self.manifest)
        self.prior = runpy.run_path(str(PRIOR / 'compose.py'))
        self.prior_context = self.prior['Context'](gcc_root, ada_root, plugin_include, gcc_match)
        self.reference = read(PRIOR / 'result.json')
        require(len(self.reference['conditions']) == 335, 'accepted335 guard schema')
        self.project = self.prior_context.prior['project']
        # Reuse the accepted existing core owner model, not a new lifetime census.
        self.route = self.prior_context.prior_context.prior_context.prior_context.route_context
        self.helper = runpy.run_path(str(HELPER / 'derive.py'))
        self.helper_reference = read(HELPER / 'result.json')
        verified = self.helper['verify_inputs'](gcc_root)
        require(verified == self.manifest['helper_source_inventory'], 'complete accepted helper source inventory')
        self.schedule = read(E / 'unbounded-programs/retained-native-expansion-20261017/literal-rtl-backing-predecessor.json')['source_selected_LRA_passes']
        require(self.schedule == self.manifest['retained_LRA_schedule'], 'accepted complete LRA schedule')
        self.validation = dict(
            accepted_current_and_historical_records=len(self.manifest['files']),
            predecessor=self.prior_context.validation, helper=verified,
            inventory_sets_overlap_and_must_not_be_added=True,
            helper_fixed_Hello_reconciliation_called=False,
            no_new_historical_input_exception=True,
            complete_source_configuration_and_owners_checked_before_short_circuit=True,
            source_argument_is_reviewed_handwritten_argument=True,
            predecessor_suites_rerun=False)


def validate_joins(raw, selected, context):
    require(selected['conditions'].keys() == selected['conditional_conditions'].keys() ==
            context.reference['conditions'].keys(), 'preserve accepted335 condition keys')
    require(all(type(v) is bool or v is None for f in ('conditions', 'conditional_conditions')
                for v in selected[f].values()), 'boolean or uncomputed inherited335 arithmetic')
    for name, value in summaries(selected):
        require(type(value) is bool, 'boolean inherited capacity summary ' + name)
    # Project actual305 values; no false/null prerequisite is promoted for an API.
    source, counts, x = context.prior['validate_joins'](raw,
        context.project(selected, context.prior_context.reference['conditions'].keys()), context.prior_context)
    c, n = counts['output_calls'], counts['null_statements']
    x.update(U=x['M'] + 2, R=3*x['K']//2 + 1)
    core = selected['core_result']
    pools = selected['selected_native_shared_bitmap_pool_lifetime']
    # Full existing backing owner dictionaries, including layouts, zero charges
    # and old residual scope, must match on passing and false/null routes.
    backing = core['selected_native_backing']
    expected_backing = context.route.core_context.backing['backing'](c, n)
    require(backing.keys() == expected_backing.keys() and
            without(backing, ['local_representation_checks']) ==
            without(expected_backing, ['local_representation_checks']), 'complete existing RTL DF LRA backing owners')
    require(backing['local_representation_checks'].keys() == expected_backing['local_representation_checks'].keys() and
            all(type(v) is bool for v in backing['local_representation_checks'].values()), 'existing backing guard schema')
    require(all(pools['extents'][k] == x[k] for k in ('K', 'B', 'M', 'U', 'P')),
            'helper actual complete bitmap extents')
    lra = backing['LRA_register_and_recognition_backing']
    df = backing['DF_selected_reference_and_solver_transfer']
    require(lra['register_record_entries_upper'] == lra['last_reg_value_upper'] == x['R'] and
            lra['register_record_request_bytes_upper'] == 144*x['R'] and
            lra['constraint_stack_request_bytes_upper'] == 8+8*x['U'] and
            lra['referenced_pseudo_nrefs_upper'] == 2, 'helper exact retained LRA register constraint nrefs owners')
    require(df['ref_order_final_upper'] == 17690*c+368*n+19076 and
            df['selected_REG_DEAD_UNUSED_note_requests_upper'] == 600*c, 'helper accepted DF count and note owners')
    require(pools['reg_bitmap_families']['LRA_per_register_instruction_heads_upper'] == x['R'] and
            pools['program_points']['each_assignment_header_array_bytes_upper'] == 32*x['P'] and
            pools['LRA_additional_pools']['live_ranges']['live_objects_upper'] == 10*c and
            pools['LRA_additional_pools']['live_range_copies'] ==
            pools['LRA_additional_pools']['copy_pool_objects'] == 0, 'helper retained bitmap global live-pool owners')
    # Complete numeric wrapper and arithmetic owners remain bound. Recompute
    # only the accepted OLD model for structure; preserve every exported value.
    leaf = selected[NUMERIC_FIELD]
    if leaf is None:
        require(any(v is not True for f in ('conditions', 'conditional_conditions') for v in selected[f].values()) or
                any(not v for _, v in summaries(selected)), 'null numeric owner requires failed/uncomputed prerequisite')
    else:
        arithmetic = leaf['arithmetic']
        expected_arithmetic = context.prior_context.numeric['arithmetic'](c, n)
        omitted = ['local_numeric_checks', 'inherited_representation_checks',
                   'conditional_selected_IRA_numeric_arithmetic', 'failed_predicates']
        require(arithmetic.keys() == expected_arithmetic.keys() and
                without(arithmetic, omitted) == without(expected_arithmetic, omitted), 'complete inherited numeric arithmetic owners')
        context.prior['numeric_guards'](arithmetic, context.prior_context)
        expected = dict(source=source, source_counts=counts, source_path=selected['source_path'],
            launch=selected['launch'], actual_shared_inputs=selected['actual_shared_inputs'],
            complete_path_bound=selected['complete_path_bound'], arithmetic=arithmetic,
            same_source_complete_owners_verified=True, actual_source_numeric_adapter_attached=True,
            frozen_arithmetic_component_status_fields_retained_as_history=True,
            retained_owners=dict(RTL_shape=core['RTL_shape'], bitmap_extents=pools['extents'],
                ordinary_IRA=selected[IRA_FIELD], actual_GGC_owners=selected['selected_native_GGC_ledger'],
                actual_GGC_events_upper=selected['selected_positive_GGC_events_upper'],
                inherited_numeric_guard_owners=context.prior_context.manifest['inherited_numeric_guard_owners'],
                separate_LRA10000_guard=selected['conditions'][LRA_GUARD]))
        require(leaf == expected, 'complete inherited numeric source configuration and retained owners')
    attachment = selected['IRA_numeric_attachment']
    omitted = ['source', 'source_counts', 'guards', 'status', 'not_computed_reasons',
               'selected_named_IRA_numeric_arithmetic_established']
    require(attachment.keys() == context.reference['IRA_numeric_attachment'].keys() and
            without(attachment, omitted) == without(context.reference['IRA_numeric_attachment'], omitted) and
            attachment['source'] == source and attachment['source_counts'] == counts,
            'complete inherited numeric attachment metadata')
    require(attachment['guards'].keys() == context.reference['IRA_numeric_attachment']['guards'].keys() and
            all(type(v) is bool or v is None for v in attachment['guards'].values()), 'inherited numeric attachment guard schema')
    return source, counts, x


def helper_guards(leaf, context):
    expected = context.helper_reference['local_representation_checks'].keys()
    checks = {k: None for k in expected} if leaf is None else leaf['local_representation_checks']
    require(checks.keys() == expected and len(checks) == 31, 'accepted31 helper guard schema')
    require(leaf is None or all(type(v) is bool for v in checks.values()), 'boolean computed helper guards')
    value = None if leaf is None else leaf['conditional_named_helper_storage_capacity']
    require(leaf is None or type(value) is bool, 'boolean helper conjunction')
    result = {PREFIX+k: v for k, v in checks.items()}
    result[CONJUNCTION] = value
    return result


def attach(raw, selected, context):
    source, counts, x = validate_joins(raw, selected, context)
    reasons = [f+'.'+k+('=uncomputed' if v is None else '=false')
               for f in ('conditions', 'conditional_conditions') for k, v in selected[f].items() if v is not True]
    reasons += [name+'=false' for name, value in summaries(selected) if not value]
    arithmetic = None if reasons else context.helper['arithmetic'](counts['output_calls'], counts['null_statements'])
    guards = helper_guards(arithmetic, context)
    require(not (guards.keys() & selected['conditions'].keys()), 'helper predicates cannot replace inherited335')
    leaf = None
    if arithmetic is not None:
        require(arithmetic.keys() == without(context.helper_reference, ['input_verification', 'retained_interface']).keys(),
                'complete accepted helper arithmetic schema')
        c, n = counts['output_calls'], counts['null_statements']
        require(arithmetic['counts'] == dict(C=c, N=n) and arithmetic['extents'] == x,
                'helper actual complete count and extent transfer')
        counters = arithmetic['counters']
        require(counters['accepted_DF_reference_creations_upper'] == counters['regstat_sets_and_refs_each_upper'] ==
                selected['core_result']['selected_native_backing']['DF_selected_reference_and_solver_transfer']['ref_order_final_upper'] and
                counters['regstat_deaths_each_upper'] == 600*c and
                counters['LRA_initial_value_counter_upper'] == x['R'] and
                counters['LRA_live_ranges_per_pseudo_upper'] == 2 and
                counters['assignment_live_length_sum_upper'] == 2*(x['P']+1) and
                counters['inheritance_passes_upper'] == 1 and counters['inheritance_EBB_epochs_upper'] == x['B'],
                'helper exact DF inheritance and per-pseudo length owners')
        require(all(arithmetic[k] == 0 for k in ('new_GGC_events', 'new_scalar_registrations',
                    'new_array_registrations', 'shared_bitmap_or_ET_blocks_recharged')) and
                arithmetic['retained_LRA_register_and_constraint_owners_recharged'] is False,
                'helper cannot recharge existing owners')
        require(all(arithmetic[k] is False for k in ('aggregate_RAM_gate', 'all_outer_IRA_interfaces_closed',
                'all_LRA_ordinary_helpers_closed', 'all_LRA_numeric_arithmetic_closed',
                'complete_all_ordinary_native_capacity', 'complete_native_capacity',
                'whole_literal_pipeline_capacity_established', 'production_admission_changed')) and
                arithmetic['aggregate_ordinary_bytes'] is arithmetic['lifetime_ordinary_request_total'] is None,
                'helper scope remains named')
        leaf = dict(source=source, source_counts=copy.deepcopy(counts), source_path=selected['source_path'],
            launch=copy.deepcopy(selected['launch']), actual_shared_inputs=copy.deepcopy(selected['actual_shared_inputs']),
            complete_path_bound=selected['complete_path_bound'], arithmetic=arithmetic,
            same_source_complete_owners_verified=True, actual_source_helper_adapter_attached=True,
            frozen_arithmetic_component_status_fields_retained_as_history=True,
            retained_owners=copy.deepcopy(dict(RTL_shape=selected['core_result']['RTL_shape'],
                native_backing=selected['core_result']['selected_native_backing'],
                shared_bitmap_and_live_pools=selected['selected_native_shared_bitmap_pool_lifetime'],
                ordinary_IRA=selected[IRA_FIELD], IRA_numeric=selected[NUMERIC_FIELD],
                actual_GGC=selected['selected_native_GGC_ledger'],
                actual_GGC_events_upper=selected['selected_positive_GGC_events_upper'],
                selected_LRA_schedule=context.schedule,
                separate_LRA10000_guard=selected['conditions'][LRA_GUARD])))
    result = copy.deepcopy(selected)
    for field in ('conditions', 'conditional_conditions'):
        result[field].update(guards)
    passed = not reasons and all(v is True for v in result['conditions'].values())
    conditional = not reasons and all(v is True for v in result['conditional_conditions'].values())
    result.update(scope='Actual-source selected literal route with named outer IRA and LRA helper storage; other native and pipeline obligations remain open',
        evaluated_predicates_pass=passed, conditional_arithmetic_pass=conditional,
        failed_predicates=[k for k, v in result['conditions'].items() if v is False],
        failed_conditional_predicates=[k for k, v in result['conditional_conditions'].items() if v is False],
        unresolved_predicates=[k for k, v in result['conditions'].items() if v is None],
        validation=context.validation)
    result[HELPER_FIELD] = leaf
    result[SUMMARY] = passed and conditional
    result[ATTACHMENT] = dict(source=source, source_counts=counts, inherited_guards=335, new_guards=len(guards),
        guards=guards, status='not_computed_upstream_prerequisites' if arithmetic is None else 'computed',
        not_computed_reasons=reasons, selected_named_helper_storage_established=passed and conditional,
        accepted_helper_source=context.manifest['accepted_helper_source'],
        accepted_helper_review=context.manifest['accepted_helper_review'],
        inherited_guard_maps_preserved=True, complete_owners_checked_before_short_circuit=True,
        fixed_Hello_reconciliation_used_as_actual_source_rule=False,
        earlier_helper_open_flags_are_component_history=True,
        new_GGC_events=0, new_scalar_registrations=0, new_array_registrations=0,
        shared_bitmap_or_ET_blocks_recharged=0, retained_LRA_register_and_constraint_owners_recharged=False,
        aggregate_RAM_gate=False, independent_attachment_review_status='pending')
    result['accounting'] += ' Named IRA/LRA helper storage and index arithmetic is attached to actual source/configuration and complete prior owners without recharge. Earlier open flags retain their component scope.'
    result['open_joins']['native_remaining_lifetime_and_collector'] = (
        'Named outer IRA equivalence/scratch, common reginfo/regstat and selected LRA register/live-scan/inheritance/assignment '
        'storage and index arithmetic are conditionally attached. Full dynamic LRA recognition lifetime, other outer IRA '
        'helpers/external sort, other LRA arithmetic/automatic storage/elimination offsets, other native/helper/stack, '
        'producer/proof/parent/current-grammar and source-binary/materialization obligations remain open.')
    return result


def evaluate(descriptor_path, context, source_override=None):
    prior = context.prior['evaluate'](descriptor_path, context.prior_context, source_override)
    return attach(Path(prior['source_path']).read_bytes(), prior, context)


if __name__ == '__main__':
    start, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE / 'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor', type=Path, default=PIPELINE / 'selected-route.json')
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = evaluate(args.descriptor, Context(args.gcc_root, args.ada_root, args.plugin_include, args.gcc_match), args.source)
    result['offline_run'] = dict(started_utc=start, completed_utc=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(passed=result['evaluated_predicates_pass'], guards=len(result['conditions']))))
