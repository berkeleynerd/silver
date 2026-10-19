#!/usr/bin/env python3
"""Attach the accepted recognition implication to actual-source367; add no guard."""
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
PRIOR = E / 'retained-literal-ira-lra-helper-attachment-20261019'
RECOGNITION = E / 'retained-literal-lra-recognition-20261019'
PIPELINE = E / 'retained-literal-pipeline-20261018'
FIELD = 'selected_native_LRA_recognition_lifetime'
SUMMARY = 'selected_named_LRA_recognition_lifetime_established'
ATTACHMENT = 'LRA_recognition_attachment'
OWNER = 'LRA_register_and_recognition_backing'


def read(path):
    return json.loads(Path(path).read_bytes())


def require(value, message):
    if not value:
        raise ValueError(message)


def without(record, keys):
    return {k: v for k, v in record.items() if k not in keys}


def same_typed(left, right):
    if type(left) is not type(right):
        return False
    if isinstance(right, dict):
        return left.keys() == right.keys() and all(same_typed(left[key], right[key]) for key in right)
    if isinstance(right, list):
        return len(left) == len(right) and all(same_typed(a, b) for a, b in zip(left, right))
    return left == right


def summaries(selected, context):
    return context.prior['summaries'](selected) + [
        ('selected.named_helper_storage', selected[context.prior['SUMMARY']]),
        ('helper_attachment.named_storage', selected[context.prior['ATTACHMENT']]['selected_named_helper_storage_established'])]


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        self.manifest = read(HERE / 'inputs.json')
        pins = runpy.run_path(str(E / 'retained-literal-lifetime-attachment-20261019/compose.py'))
        pins['check_pins'](self.manifest)
        self.prior = runpy.run_path(str(PRIOR / 'compose.py'))
        self.prior_context = self.prior['Context'](gcc_root, ada_root, plugin_include, gcc_match)
        self.project = self.prior_context.project
        self.reference = read(PRIOR / 'result.json')
        require(len(self.reference['conditions']) == 367, 'accepted367 guard schema')
        self.recognition = runpy.run_path(str(RECOGNITION / 'derive.py'))
        self.recognition_reference = read(RECOGNITION / 'result.json')['arithmetic']
        verified = self.recognition['verify_inputs'](gcc_root)
        require(verified == self.manifest['recognition_source_inventory'], 'complete accepted recognition source inventory')
        self.validation = dict(accepted_current_and_historical_records=len(self.manifest['files']),
            predecessor=self.prior_context.validation, recognition=verified,
            inventory_sets_overlap_and_must_not_be_added=True, recognition_fixed_Hello_fixture_called=False,
            complete_source_configuration_and_owners_checked_before_short_circuit=True,
            source_argument_is_reviewed_handwritten_argument=True, new_source_guards=0,
            no_new_historical_input_exception=True, predecessor_suites_rerun=False)


def validate_joins(raw, selected, context):
    require(selected['conditions'].keys() == selected['conditional_conditions'].keys() ==
            context.reference['conditions'].keys(), 'preserve accepted367 condition keys')
    require(all(type(v) is bool or v is None for field in ('conditions', 'conditional_conditions')
                for v in selected[field].values()), 'boolean or uncomputed inherited367 arithmetic')
    for name, value in summaries(selected, context):
        require(type(value) is bool, 'boolean inherited capacity summary '+name)
    # Preserve actual values when projecting into the accepted335 validator.
    source, counts, x = context.prior['validate_joins'](raw,
        context.project(selected, context.prior_context.reference['conditions'].keys()), context.prior_context)
    leaf = selected[context.prior['HELPER_FIELD']]
    if leaf is None:
        require(any(v is not True for field in ('conditions', 'conditional_conditions') for v in selected[field].values()) or
                any(not v for _, v in summaries(selected, context)), 'null helper owner requires failed/uncomputed prerequisite')
    else:
        arithmetic = leaf['arithmetic']
        expected_arithmetic = context.prior_context.helper['arithmetic'](counts['output_calls'], counts['null_statements'])
        omitted = ['local_representation_checks', 'conditional_named_helper_storage_capacity', 'failed_predicates']
        require(arithmetic.keys() == expected_arithmetic.keys() and
                without(arithmetic, omitted) == without(expected_arithmetic, omitted), 'complete inherited helper arithmetic owners')
        context.prior['helper_guards'](arithmetic, context.prior_context)
        expected = dict(source=source, source_counts=counts, source_path=selected['source_path'],
            launch=selected['launch'], actual_shared_inputs=selected['actual_shared_inputs'],
            complete_path_bound=selected['complete_path_bound'], arithmetic=arithmetic,
            same_source_complete_owners_verified=True, actual_source_helper_adapter_attached=True,
            frozen_arithmetic_component_status_fields_retained_as_history=True,
            retained_owners=dict(RTL_shape=selected['core_result']['RTL_shape'],
                native_backing=selected['core_result']['selected_native_backing'],
                shared_bitmap_and_live_pools=selected['selected_native_shared_bitmap_pool_lifetime'],
                ordinary_IRA=selected[context.prior['IRA_FIELD']], IRA_numeric=selected[context.prior['NUMERIC_FIELD']],
                actual_GGC=selected['selected_native_GGC_ledger'],
                actual_GGC_events_upper=selected['selected_positive_GGC_events_upper'],
                selected_LRA_schedule=context.prior_context.schedule,
                separate_LRA10000_guard=selected['conditions'][context.prior['LRA_GUARD']]))
        require(leaf == expected, 'complete inherited helper source configuration and retained owners')
    attachment = selected[context.prior['ATTACHMENT']]
    omitted = ['source', 'source_counts', 'guards', 'status', 'not_computed_reasons', 'selected_named_helper_storage_established']
    reference = context.reference[context.prior['ATTACHMENT']]
    require(attachment.keys() == reference.keys() and without(attachment, omitted) == without(reference, omitted) and
            attachment['source'] == source and attachment['source_counts'] == counts, 'complete inherited helper attachment metadata')
    require(attachment['guards'].keys() == reference['guards'].keys() and
            all(type(v) is bool or v is None for v in attachment['guards'].values()), 'inherited helper attachment guard schema')
    require(all(selected[key] is False for key in ('whole_literal_pipeline_capacity_established', 'complete_native_capacity',
                'complete_proof_pipeline_capacity', 'complete_parent_storage_closed', 'production_launcher_adopted',
                'production_admission_changed', 'aggregate_RAM_gate')), 'inherited broad capacity remains open')
    return source, counts, x


def validate_arithmetic(arithmetic, selected, counts, x, context):
    c, n = counts['output_calls'], counts['null_statements']
    backing = selected['core_result']['selected_native_backing']
    owner = backing[OWNER]
    premises = {key: backing['local_representation_checks'][key] for key in context.manifest['consumed_backing_premises']}
    require(all(value is True for value in premises.values()), 'consumed existing backing premises must pass')
    expected = copy.deepcopy(context.recognition_reference)
    expected.update(C=c, N=n, K=x['K'], M=x['M'], U=x['U'], inherited_arithmetic_premises=premises)
    d = expected['derived']
    for key, live, q, blocks in [('recognition_pool', x['M'], 819, owner['recognition_pool_blocks_upper']),
                              ('instruction_register_pool', 10*c, 2730, owner['instruction_register_pool_blocks_upper'])]:
        require(blocks == (live+q-1)//q, 'existing rounded pool block owner')
        d[key] = dict(live_upper=live, slots_per_block=q, retained_blocks_upper=blocks, retained_slots_upper=q*blocks)
    d.update(map_entries_upper=owner['recognition_pointer_entries_upper'],
             map_request_bytes_upper=owner['recognition_pointer_request_bytes_upper'])
    require(owner['live_recognition_records_upper'] == x['M'] and owner['live_instruction_register_records_upper'] == 10*c and
            owner['referenced_pseudo_nrefs_upper'] == d['per_pseudo_nrefs_upper'] == 2 and
            owner['implicit_call_array_stack_entries_used'] == d['argument_stack_entries_used'] == 3 and
            owner['implicit_call_array_stack_entries_available'] == d['argument_stack_entries_available'] == 92,
            'recognition exact live nrefs and argument owners')
    require(same_typed(arithmetic, expected), 'complete recognition implication count premise counter scope and zero-charge relation')


def attach(raw, selected, context):
    source, counts, x = validate_joins(raw, selected, context)
    reasons = [field+'.'+key+('=uncomputed' if value is None else '=false')
        for field in ('conditions', 'conditional_conditions') for key, value in selected[field].items() if value is not True]
    reasons += [name+'=false' for name, value in summaries(selected, context) if not value]
    arithmetic = None if reasons else context.recognition['arithmetic'](counts['output_calls'], counts['null_statements'])
    leaf = None
    if arithmetic is not None:
        validate_arithmetic(arithmetic, selected, counts, x, context)
        leaf = dict(source=source, source_counts=copy.deepcopy(counts), source_path=selected['source_path'],
            launch=copy.deepcopy(selected['launch']), actual_shared_inputs=copy.deepcopy(selected['actual_shared_inputs']),
            complete_path_bound=selected['complete_path_bound'], arithmetic=arithmetic,
            actual_source_recognition_adapter_attached=True, same_source_complete_owners_verified=True,
            frozen_arithmetic_component_status_fields_retained_as_history=True,
            stored_pseudo_keys_preserved_through_final_renumber_until_deletion_or_draining=True,
            retained_owners=copy.deepcopy(dict(recognition=selected['core_result']['selected_native_backing'][OWNER],
                helper=selected[context.prior['HELPER_FIELD']], shared_bitmap_and_live_pools=selected['selected_native_shared_bitmap_pool_lifetime'],
                actual_GGC=selected['selected_native_GGC_ledger'], actual_GGC_events_upper=selected['selected_positive_GGC_events_upper'],
                selected_LRA_schedule=context.prior_context.schedule,
                separate_LRA10000_guard=selected['conditions'][context.prior['LRA_GUARD']])))
    result = copy.deepcopy(selected)
    established = not reasons and arithmetic is not None
    result.update(scope='Actual-source selected literal route with named LRA recognition lifetime and retained counters; full native/pipeline capacity remains open',
        evaluated_predicates_pass=established and all(v is True for v in result['conditions'].values()),
        conditional_arithmetic_pass=established and all(v is True for v in result['conditional_conditions'].values()),
        failed_predicates=[key for key, value in result['conditions'].items() if value is False],
        failed_conditional_predicates=[key for key, value in result['conditional_conditions'].items() if value is False],
        unresolved_predicates=[key for key, value in result['conditions'].items() if value is None],
        validation=context.validation)
    result[FIELD], result[SUMMARY] = leaf, established
    result[ATTACHMENT] = dict(source=source, source_counts=copy.deepcopy(counts), inherited_guards=367, new_guards=0,
        status='not_computed_upstream_prerequisites' if arithmetic is None else 'computed', not_computed_reasons=reasons,
        selected_named_recognition_lifetime_established=established,
        accepted_recognition_source=context.manifest['accepted_recognition_source'], accepted_recognition_review=context.manifest['accepted_recognition_review'],
        inherited_guard_maps_preserved=True, complete_owners_checked_before_short_circuit=True,
        fixed_Hello_reconciliation_used_as_actual_source_rule=False, earlier_open_flags_are_component_history=True,
        new_allocation_owners=0, new_GGC_events=0, new_finalizer_registrations=0, new_pool_or_bitmap_charge=0,
        existing_recognition_owners_recharged=False, aggregate_RAM_gate=False, independent_attachment_review_status='pending')
    result['accounting'] += ' Named recognition lifetime and rounded retained-slot counters are attached to actual source/configuration and complete existing owners; no guards or charges added.'
    result['open_joins']['native_remaining_lifetime_and_collector'] = (
        'Named recognition creation/reuse/invalidation/recreation/final-renumber/draining and retained-slot counter implication '
        'are conditionally attached. Other outer IRA/imported/external-sort helpers, other LRA arithmetic/automatic storage/'
        'elimination offsets, other native/helper/stack, producer/proof/parent/current-grammar and source-binary/materialization obligations remain open.')
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
    print(json.dumps(dict(passed=result['evaluated_predicates_pass'], guards=len(result['conditions']), recognition=result[SUMMARY])))
