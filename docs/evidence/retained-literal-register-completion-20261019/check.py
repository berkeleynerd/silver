#!/usr/bin/env python3
"""Focused source composition, cold-probe correction and failure checks."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import runpy
import tempfile
import time

HERE = Path(__file__).resolve().parent


def main():
    start, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    api = runpy.run_path(str(HERE / 'compose.py'))
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(api['PIPELINE'] / 'compose.py'))['arguments'](parser)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    context = api['Context'](args.gcc_root, args.ada_root, args.plugin_include, args.gcc_match)
    checks, examples, boundaries = [], [], []

    def check(name, condition):
        if not condition:
            raise AssertionError(name)
        checks.append(name)

    def rejected(name, fn):
        try:
            fn()
        except ValueError:
            checks.append(name)
        else:
            raise AssertionError(name + ': accepted')

    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    cases = [
        ('Hello', (api['REPO'] / 'samples/hello_world.adb').read_bytes()),
        ('C2_N2', shell + b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("a"); null;\nend Main;\n'),
        ('C10_N10', shell + b'Silver_IO.Put ("x"); null;\n' * 10 + b'end Main;\n'),
        ('long_literal', shell + b'Silver_IO.Put ("' + b'x' * 8192 + b'");\nend Main;\n'),
        ('C5000', shell + b'Silver_IO.Put ("x");\n' * 5000 + b'end Main;\n')]
    (api['REPO'] / 'tmp').mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='register-completion-', dir=api['REPO'] / 'tmp') as scratch:
        path = Path(scratch) / 'main.adb'
        for name, raw in cases:
            path.write_bytes(raw)
            result = api['evaluate'](api['PIPELINE'] / 'selected-route.json', context,
                                     None if name == 'Hello' else path)
            prior, ledger = result['predecessor_result'], result['selected_native_GGC_ledger']
            check(name + ': selected register conditions pass', result['selected_register_interfaces_capacity_established'])
            check(name + ': current source identities', result['source'] == prior['source'] and
                  result['source_counts'] == prior['source_counts'])
            check(name + ': exactly four events', ledger['total_positive_GGC_events_upper'] ==
                  prior['selected_positive_GGC_events_upper'] + 4)
            check(name + ': all fifty old owners unchanged', ledger['owner_rows'][:-1] ==
                  prior['selected_native_GGC_ledger']['owner_rows'] and len(ledger['owner_rows']) == 51)
            check(name + ': distinct probe owner', len({row['owner'] for row in ledger['owner_rows']}) == 51)
            check(name + ': finalizer and all nonpage collector fields unchanged', all(
                value == ledger['collector'][key] for key, value in
                prior['selected_native_GGC_ledger']['collector'].items()
                if key not in ('active_pages_upper', 'each_pointer_vector_capacity_upper',
                               'each_pointer_vector_request_bytes_upper')))
            check(name + ': current maps retain every noncollector old predicate', all(
                result[field][key] is value for field in ('conditions', 'conditional_conditions')
                for key, value in prior[field].items() if not key.startswith(api['GGC_PREFIX'])))
            check(name + ': no native or broader capacity promotion', all(result[key] is False for key in (
                'complete_native_capacity', 'complete_parent_storage_closed', 'complete_proof_pipeline_capacity',
                'whole_literal_pipeline_capacity_established', 'production_launcher_adopted',
                'production_admission_changed', 'aggregate_RAM_gate')) and result['native_tool_executions'] == 0)
            examples.append(dict(name=name, source=result['source'], counts=result['source_counts'],
                guards=len(result['conditions']), old_events=prior['selected_positive_GGC_events_upper'],
                corrected_events=ledger['total_positive_GGC_events_upper'],
                collector_pointer_capacity=ledger['collector']['each_pointer_vector_capacity_upper']))
            if name == 'Hello':
                hello = result

        # Substitutions here are explicitly negative interface tests. No
        # synthetic result is reported as an actual source capacity result.
        genuine_evaluate = context.prior['evaluate']
        original_outer, original_lra = context.outer['arithmetic'], context.lra['arithmetic']

        def forbidden(*args, **kwargs):
            raise AssertionError('new argument evaluated after failed prerequisite')

        for field in ('conditions', 'conditional_conditions'):
            fixture = copy.deepcopy(hello['predecessor_result'])
            fixture[field]['Main_source_EOF'] = False
            context.prior['evaluate'] = lambda *args, **kwargs: copy.deepcopy(fixture)
            context.outer['arithmetic'] = context.lra['arithmetic'] = forbidden
            result = api['evaluate'](api['PIPELINE'] / 'selected-route.json', context)
            check(field + ': false prerequisite retained with uncomputed new guards',
                  result[field]['Main_source_EOF'] is False and result['selected_native_GGC_ledger'] is None and
                  result['selected_native_outer_IRA_completion'] is None and
                  result['selected_native_LRA_arithmetic_completion'] is None and
                  not result['selected_register_interfaces_capacity_established'] and
                  len(result['unresolved_predicates']) == 41)
        context.outer['arithmetic'], context.lra['arithmetic'] = original_outer, original_lra
        fixture = copy.deepcopy(hello['predecessor_result'])
        fixture['source_counts']['output_calls'] += 1
        context.prior['evaluate'] = lambda *args, **kwargs: copy.deepcopy(fixture)
        rejected('false count/source correspondence rejected before new arithmetic',
                 lambda: api['evaluate'](api['PIPELINE'] / 'selected-route.json', context))
        context.prior['evaluate'] = genuine_evaluate
        path.write_bytes(shell + b'Silver_IO.Put (X); end Main;\n')
        rejected('unrecognized source never reaches register rule',
                 lambda: api['evaluate'](api['PIPELINE'] / 'selected-route.json', context, path))

    old = hello['predecessor_result']['selected_native_GGC_ledger']
    correction = hello['selected_native_outer_IRA_completion']['GGC_correction']
    # Pure arithmetic probes deliberately alter only a synthetic event count;
    # they make no claim that these totals arise from admitted programs.
    for total in (65532, 65533, 65536, api['I32'] - 4, api['I32'] - 3,
                  api['U32'] - 4, api['U32'] - 3):
        synthetic = copy.deepcopy(old)
        synthetic['owner_rows'][0]['positive_GGC_requests_upper'] += total - old['total_positive_GGC_events_upper']
        synthetic['total_positive_GGC_events_upper'] = total
        synthetic['collector'].update(active_pages_upper=total,
            each_pointer_vector_capacity_upper=api['power2'](max(128, total)),
            each_pointer_vector_request_bytes_upper=8 * api['power2'](max(128, total)))
        current = api['corrected_collector'](synthetic, correction)
        c = current['collector']
        check('corrected page boundary ' + str(total), current['total_positive_GGC_events_upper'] == total + 4 and
              c['each_pointer_vector_capacity_upper'] == api['power2'](max(128, total + 4)) and
              c['each_pointer_vector_request_bytes_upper'] == 8 * api['power2'](max(128, total + 4)) and
              current['local_representation_checks']['active_page_signed_index'] == (total + 4 <= api['I32']) and
              current['local_representation_checks']['active_page_unsigned_capacity'] ==
              (api['power2'](max(128, total + 4)) <= api['U32']))
        boundaries.append(dict(historical_events=total, corrected_events=total+4,
                               capacity=c['each_pointer_vector_capacity_upper']))
    bad = copy.deepcopy(old)
    bad['owner_rows'][0]['owner'] = api['PROBE_OWNER']
    rejected('duplicate probe owner rejected', lambda: api['corrected_collector'](bad, correction))
    bad = copy.deepcopy(old)
    bad['total_positive_GGC_events_upper'] += 1
    rejected('inconsistent historical sum rejected', lambda: api['corrected_collector'](bad, correction))
    bad = copy.deepcopy(correction)
    bad['positive_GGC_requests_upper'] = 3
    rejected('incomplete probe transfer rejected', lambda: api['corrected_collector'](old, bad))
    current = api['corrected_collector'](old, correction)
    current['owner_rows'][0]['positive_GGC_requests_upper'] += 1
    check('current ledger does not alias historical owner storage', old['owner_rows'][0]['positive_GGC_requests_upper'] == 39257)
    record = dict(scope='Focused current register/source attachment and #146 collector recomposition',
        checks=len(checks), passed=checks, actual_source_examples=examples,
        synthetic_arithmetic_boundaries_not_source_admission=boundaries,
        started_UTC=start, completed_UTC=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer, host=platform.platform(),
        native_tool_executions=0, predecessor_suite_replays=0)
    args.output.write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(checks=len(checks), elapsed_seconds=record['elapsed_seconds'])))


if __name__ == '__main__':
    main()
