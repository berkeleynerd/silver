#!/usr/bin/env python3
"""Actual-source register completion and corrected Main collector accounting."""
import copy
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import time

I32, U32, I64, OBJECT_LIMIT = 2**31 - 1, 2**32 - 1, 2**63 - 1, 2**62
PROBE_OWNER = 'IRA_cold_prohibited_mode_probe'
GGC_PREFIX = 'native_GGC_'
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
PRIOR = E / 'retained-literal-lra-recognition-attachment-20261019'
OUTER = E / 'retained-literal-outer-ira-completion-20261019'
LRA = E / 'retained-literal-lra-arithmetic-completion-20261019'
PIPELINE = E / 'retained-literal-pipeline-20261018'
OUTER_PREFIX = 'native_completed_outer_IRA_'
LRA_PREFIX = 'native_completed_LRA_'


def read(path):
    return json.loads(Path(path).read_bytes())


def require(value, message):
    if not value:
        raise ValueError(message)


def power2(value):
    require(type(value) is int and value >= 0, 'nonnegative integer extent')
    return 1 << (max(1, value) - 1).bit_length()


def corrected_collector(previous, correction):
    """Extend the historical 50 owners; never add an old subtotal again.

    This is arithmetic over an already validated actual-source ledger. Its
    caller must establish the source/configuration and the new probe theorem.
    The old records are preserved by the outer result as historical inputs.
    """
    require(correction['owner'] == PROBE_OWNER and
            type(correction['positive_GGC_requests_upper']) is int and
            correction['positive_GGC_requests_upper'] == 4 and
            correction['each_raw_request_bytes_upper'] == 72 and
            correction['each_rounded_request_bytes_upper'] == 128 and
            correction['constructor_requests'] == [
                dict(kind='REG', count=2, each_raw_bytes_upper=24),
                dict(kind='SET', count=1, each_raw_bytes_upper=24),
                dict(kind='INSN', count=1, each_raw_bytes_upper=72)],
            'exact cold target-probe constructor transfer')
    old_rows = previous['owner_rows']
    require(len(old_rows) == 50 and len({row['owner'] for row in old_rows}) == 50,
            '50 distinct historical owner rows')
    require(all(row['owner'] != PROBE_OWNER for row in old_rows),
            'cold target probe must not already be charged')
    for row in old_rows:
        require(type(row['positive_GGC_requests_upper']) is int and
                row['positive_GGC_requests_upper'] >= 0 and
                type(row['each_raw_request_bytes_upper']) is int and
                row['each_raw_request_bytes_upper'] >= 0 and
                row['each_rounded_request_bytes_upper'] ==
                power2(max(8, row['each_raw_request_bytes_upper'])),
                'typed historical owner count and individual request')
    old_total = sum(row['positive_GGC_requests_upper'] for row in old_rows)
    require(old_total == previous['total_positive_GGC_events_upper'] ==
            previous['collector']['active_pages_upper'],
            'historical owner sum and active-page input agree')
    require(previous['collector']['each_pointer_vector_capacity_upper'] ==
            power2(max(128, old_total)) and
            previous['collector']['each_pointer_vector_request_bytes_upper'] ==
            8 * power2(max(128, old_total)), 'historical collector growth transfer')
    result = copy.deepcopy(previous)
    row = dict(owner=PROBE_OWNER, positive_GGC_requests_upper=4,
               each_raw_request_bytes_upper=72, each_rounded_request_bytes_upper=128,
               authority='Reviewed outer IRA completion: ira.cc literal LF1727-1733; #146')
    result['owner_rows'].append(row)
    total = old_total + 4
    capacity = power2(max(128, total))
    result['total_positive_GGC_events_upper'] = total
    result['collector'].update(active_pages_upper=total,
        each_pointer_vector_capacity_upper=capacity,
        each_pointer_vector_request_bytes_upper=8 * capacity)
    checks = result['local_representation_checks']
    require(all(type(value) is bool for value in checks.values()),
            'computed historical collector checks are boolean')
    checks.update(individual_GGC_order_region=all(
        r['each_raw_request_bytes_upper'] <= OBJECT_LIMIT for r in result['owner_rows']),
        active_page_signed_index=total <= I32,
        active_page_unsigned_capacity=capacity <= U32,
        each_active_page_pointer_backing=8 * capacity <= I64)
    result['conditional_selected_GGC_and_collector_storage_capacity'] = all(checks.values())
    result['ownership']['cold_IRA_probe_correction'] = dict(
        issue=146, old_owner_rows_preserved=50, added_owner_rows=1,
        positive_events_added=4, scalar_finalizer_delta=0, array_finalizer_delta=0,
        pseudo_number_delta=0, instruction_UID_delta=0, instruction_chain_delta=0,
        historical_total_used_as_an_additional_row=False)
    result['scope'] = 'Corrected selected literal Main GGC partition and collector indexed storage'
    return result


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        self.manifest = read(HERE / 'inputs.json')
        runpy.run_path(str(E / 'retained-literal-lifetime-attachment-20261019/compose.py'))[
            'check_pins'](self.manifest)
        self.prior = runpy.run_path(str(PRIOR / 'compose.py'))
        self.prior_context = self.prior['Context'](gcc_root, ada_root, plugin_include, gcc_match)
        self.outer = runpy.run_path(str(OUTER / 'derive.py'))
        self.lra = runpy.run_path(str(LRA / 'derive.py'))
        self.outer_inputs = self.outer['validate_inputs'](gcc_root)
        self.lra_inputs = self.lra['verify_inputs'](gcc_root)
        self.outer_schema = read(OUTER / 'result.json')['hello']['local_representation_checks'].keys()
        self.lra_schema = self.lra['arithmetic'](1, 0)['local_checks'].keys()
        self.prior_schema = read(PRIOR / 'result.json')['conditions'].keys()
        require(len(self.prior_schema) == 367, 'accepted recognition367 schema')
        require(self.manifest['source_review_accepted'] is True,
                'reviewed selected register source arguments required')


def evaluate(descriptor, context, source=None):
    # A caller supplies source bytes through the established descriptor/path
    # API, never a mutable predecessor result or a fixed Hello record.
    previous = context.prior['evaluate'](descriptor, context.prior_context, source)
    raw = Path(previous['source_path']).read_bytes()
    identity, counts, extents = context.prior['validate_joins'](raw, previous, context.prior_context)
    require(previous['conditions'].keys() == previous['conditional_conditions'].keys() ==
            context.prior_schema, 'complete367 predecessor guard schema')
    reasons = [field + '.' + key + ('=uncomputed' if value is None else '=false')
        for field in ('conditions', 'conditional_conditions')
        for key, value in previous[field].items() if value is not True]
    for name in ('evaluated_predicates_pass', 'conditional_arithmetic_pass',
                 'selected_named_LRA_recognition_lifetime_established'):
        require(type(previous[name]) is bool, 'boolean predecessor summary ' + name)
        if not previous[name]:
            reasons.append(name + '=false')
    outer = lra = collector = None
    if not reasons:
        recognized = previous[context.prior['FIELD']]['arithmetic']
        context.prior['validate_arithmetic'](recognized, previous, counts, extents,
                                             context.prior_context)
        c, n = counts['output_calls'], counts['null_statements']
        outer = context.outer['arithmetic'](c, n)
        lra = context.lra['arithmetic'](c, n)
        require(outer['source_counts'] == dict(output_calls=c, null_statements=n) and
                lra['counts'] == dict(C=c, N=n),
                'actual source counts in both selected register arguments')
        require(all(outer['extents'][key] == extents[key] for key in outer['extents']
                    if key in extents) and
                all(lra['extents'][key] == extents[key] for key in lra['extents']),
                'existing source-derived register block and instruction domains')
        require(outer['local_representation_checks'].keys() == context.outer_schema and
                lra['local_checks'].keys() == context.lra_schema and
                all(type(v) is bool for checks in (outer['local_representation_checks'],
                    lra['local_checks'], lra['imported_checks']) for v in checks.values()),
                'complete typed register arithmetic schemas')
        # These are consequences of retained guards. Failure is a broken join,
        # never permission to erase an inherited condition or add a silent cap.
        require(all(lra['imported_checks'].values()), 'retained guards imply imported LRA arithmetic')
        require(lra['new_count_restrictions'] == lra['new_allocation_owners'] ==
                lra['new_GGC_events'] == lra['new_finalizer_registrations'] ==
                lra['pool_and_bitmap_recharges'] == 0, 'no LRA recharge or new count restriction')
        collector = corrected_collector(previous['selected_native_GGC_ledger'], outer['GGC_correction'])
    guards = {OUTER_PREFIX + key: None if outer is None else outer['local_representation_checks'][key]
              for key in context.outer_schema}
    guards[OUTER_PREFIX + 'capacity'] = None if outer is None else outer[
        'conditional_remaining_outer_IRA_interface_arithmetic']
    guards.update({LRA_PREFIX + key: None if lra is None else lra['local_checks'][key]
                   for key in context.lra_schema})
    guards[LRA_PREFIX + 'capacity'] = None if lra is None else lra['conditional_arithmetic_pass']
    require(not guards.keys() & context.prior_schema, 'new source-interface names cannot replace old guards')
    maps = {}
    for field in ('conditions', 'conditional_conditions'):
        current = dict(previous[field])
        if collector is not None:
            # #146 supersedes exactly the collector arithmetic; all older
            # successful records and copies stay inside predecessor_result.
            for key, value in collector['local_representation_checks'].items():
                require(GGC_PREFIX + key in current, 'existing collector guard owner')
                current[GGC_PREFIX + key] = value
            current[GGC_PREFIX + 'conditional_capacity'] = collector[
                'conditional_selected_GGC_and_collector_storage_capacity']
        current.update(guards)
        maps[field] = current
    passed = not reasons and all(value is True for value in maps['conditions'].values())
    conditional = not reasons and all(value is True for value in maps['conditional_conditions'].values())
    return dict(scope='Actual-source selected register closure and corrected Main GGC accounting',
        source=identity, source_counts=counts, source_path=previous['source_path'],
        launch=previous['launch'], complete_path_bound=previous['complete_path_bound'],
        **maps, evaluated_predicates_pass=passed, conditional_arithmetic_pass=conditional,
        failed_predicates=[key for key, value in maps['conditions'].items() if value is False],
        unresolved_predicates=[key for key, value in maps['conditions'].items() if value is None],
        selected_native_outer_IRA_completion=outer, selected_native_LRA_arithmetic_completion=lra,
        selected_native_GGC_ledger=collector,
        selected_positive_GGC_events_upper=None if collector is None else collector['total_positive_GGC_events_upper'],
        selected_register_interfaces_capacity_established=passed,
        selected_GGC_event_partition_closed=collector is not None,
        selected_collector_indexed_storage_capacity_established=collector is not None and
            collector['conditional_selected_GGC_and_collector_storage_capacity'],
        predecessor_result=previous,
        predecessor_scope='Exact historical367 result; its GGC total/collector and completeness claim are superseded by the current51-row ledger. Other owners are retained unchanged.',
        corrected_guard_owner='#146: current conditions and current selected_native_GGC_ledger',
        not_computed_reasons=reasons,
        complete_native_capacity=False, complete_parent_storage_closed=False,
        complete_proof_pipeline_capacity=False, whole_literal_pipeline_capacity_established=False,
        production_launcher_adopted=False, production_admission_changed=False, aggregate_RAM_gate=False,
        validation=dict(prior=context.prior_context.validation, outer=context.outer_inputs,
                        LRA=context.lra_inputs, source_review_accepted=True,
                        fixed_Hello_apis_used=False, predecessor_suites_rerun=False),
        native_tool_executions=0)


def main():
    start, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE / 'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor', type=Path, default=PIPELINE / 'selected-route.json')
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    context = Context(args.gcc_root, args.ada_root, args.plugin_include, args.gcc_match)
    result = evaluate(args.descriptor, context, args.source)
    result['offline_run'] = dict(start_UTC=start, end_UTC=datetime.now(timezone.utc).isoformat(),
                                elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(guards=len(result['conditions']),
        fits=result['evaluated_predicates_pass'], events=result['selected_positive_GGC_events_upper'])))


if __name__ == '__main__':
    main()
