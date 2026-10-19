#!/usr/bin/env python3
"""Only new helper arithmetic, pins and fixed-owner reconciliation checks."""
import argparse
import copy
import datetime
import importlib.util
import json
import platform
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('new_helper_arithmetic', HERE / 'derive.py')
d = importlib.util.module_from_spec(spec)
spec.loader.exec_module(d)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--gcc-source', required=True)
    args = parser.parse_args()
    start = time.perf_counter()
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    def rejects(name, call):
        try:
            call()
        except ValueError:
            checks.append(name)
        else:
            raise AssertionError('expected rejection: ' + name)

    verification = d.verify_inputs(args.gcc_source)
    check('full byte and literal LF operative inputs', bool(verification))
    hello = d.arithmetic(1, 0)
    check('Hello extents', hello['extents'] == dict(A=4, K=104, B=10, M=27, U=29, P=64, R=157))
    expected_requests = [6280, 3328, 314, 471, 832, 1664, 240, 22608, 720,
                         40, 2496, 416, 1248, 512, 192, 48, 104, 240]
    check('Hello all 18 individual requests',
          [r['each_request_bytes_upper'] for r in hello['individual_requests']] == expected_requests)
    check('Hello all local guards', hello['conditional_named_helper_storage_capacity'])
    check('31 named guards', len(hello['local_representation_checks']) == 31)
    check('Hello inherited DF ceiling', hello['counters']['accepted_DF_reference_creations_upper'] == 36766)
    check('Hello per-pseudo two-range length sum', hello['counters']['assignment_live_length_sum_upper'] == 130)
    for c, n in ((1, 1), (2, 0), (10, 10), (100, 50), (1000, 100), (5000, 0),
                 (1, 2**31), (2**31, 0), (2**63, 2**64)):
        r = d.arithmetic(c, n)
        check(f'domain {c}/{n}: mathematical extents',
              r['extents']['K'] == 99+5*c and r['extents']['P'] == 14*c+12*n+50)
        check(f'domain {c}/{n}: boolean guards retained',
              all(type(v) is bool for v in r['local_representation_checks'].values()))
        check(f'domain {c}/{n}: no complete scope promotion',
              not any(r[key] for key in ('all_outer_IRA_interfaces_closed', 'all_LRA_ordinary_helpers_closed',
                  'complete_native_capacity', 'whole_literal_pipeline_capacity_established', 'numeric_packet_consumed')))
        check(f'domain {c}/{n}: no owner recharge or aggregate',
              r['new_GGC_events'] == r['new_scalar_registrations'] == r['new_array_registrations'] ==
              r['shared_bitmap_or_ET_blocks_recharged'] == 0 and r['aggregate_ordinary_bytes'] is None)
    for c, n in ((0, 0), (-1, 0), (True, 0), (1, False), (1, -1), (1.0, 0), ('1', 0)):
        rejects(f'invalid count {c!r}/{n!r}', lambda c=c, n=n: d.arithmetic(c, n))

    # Independent exact integer boundaries; test each condition without
    # allowing a different failed predicate to conceal the named one.
    def edge(key, last, variable='C'):
        a = (last, 0) if variable == 'C' else (1, last)
        b = (last+1, 0) if variable == 'C' else (1, last+1)
        check(key + ': last safe ' + variable, d.arithmetic(*a)['local_representation_checks'][key])
        check(key + ': first unsafe ' + variable, not d.arithmetic(*b)['local_representation_checks'][key])

    edge('register_growth_signed_tripling', (d.I32//3-99)//5)
    edge('register_array_length_and_value_counter_signed', ((2*d.I32-1)//3-99)//5)
    edge('register_indices_signed', (d.I32-99)//5)
    edge('block_indices_and_inheritance_epoch_signed', (d.I32-10)//2, 'N')
    edge('UID_narrowing_and_negation_signed', (d.I32-29)//5, 'N')
    edge('empty_scratch_vector_31_bit_capacity', (d.I32-29)//5, 'N')
    edge('point_endpoint_and_loop_successor_signed', (d.I32-65)//12, 'N')
    edge('regstat_DF_count_narrowing_and_use_plus_set', (d.I32-19076)//17690)
    edge('regstat_DF_count_narrowing_and_use_plus_set', (d.I32-36766)//368, 'N')
    edge('regstat_note_death_increments', d.I32//600)
    edge('regstat_and_inheritance_call_counters', d.I32)
    last_length_c = (d.I32-102)//28
    edge('assignment_live_length_sum_signed', last_length_c)
    edge('assignment_live_length_sum_signed', (d.I32-130)//24, 'N')
    check('5000-call comparison retains all helper guards',
          d.arithmetic(5000, 0)['conditional_named_helper_storage_capacity'])
    check('signed tripling fails before divided capacity',
          d.arithmetic((d.I32//3-99)//5+1, 0)['local_representation_checks']['register_array_length_and_value_counter_signed'])
    check('length sum fails with representable endpoints',
          d.arithmetic(last_length_c+1, 0)['local_representation_checks']['point_endpoint_and_loop_successor_signed'])
    # Exercise the actual initializer growth and one unused pseudo for all
    # smaller extents, independently of the final K over-approximation.
    check('4096 exact growth extents cover the later unused pseudo',
          all(3*k//2+1 > k+1 and 3*(k+1)//2+1 >= 3*k//2+1 for k in range(2, 4098)))
    for index, name in enumerate(row['name'] for row in hello['individual_requests']):
        key = 'request_PTRDIFF_MAX:' + name
        fixed = index in (14, 15, 16)
        check('individual request nonwrapping ' + name,
              d.arithmetic(2**63, 2**63)['local_representation_checks'][key] is fixed)

    frozen = d.read(d.REPO / d.ADAPTER)
    pools = d.read(d.REPO / 'docs/evidence/retained-literal-shared-bitmap-pools-20261019/result.json')
    before_adapter, before_pool = copy.deepcopy(frozen), copy.deepcopy(pools)
    interface = d.retained_interface_check(frozen, pools)
    check('accepted fixed-owner reconciliation', interface['fixed_Hello_positive_GGC_events_preserved'] == 47054)
    check('existing owner inputs never mutated', frozen == before_adapter and pools == before_pool)
    mutations = [
        ('source', lambda a, p: a['source'].__setitem__('bytes', 119)),
        ('complete counts', lambda a, p: a['source_counts'].__setitem__('Put', 1)),
        ('RTL register extent', lambda a, p: a['core_result']['RTL_shape'].__setitem__('first_unused_pseudo_number_upper', 105)),
        ('LRA record request', lambda a, p: a['core_result']['selected_native_backing']['LRA_register_and_recognition_backing'].__setitem__('register_record_request_bytes_upper', 0)),
        ('per-pseudo references', lambda a, p: a['core_result']['selected_native_backing']['LRA_register_and_recognition_backing'].__setitem__('referenced_pseudo_nrefs_upper', 3)),
        ('DF creation owner', lambda a, p: a['core_result']['selected_native_backing']['DF_selected_reference_and_solver_transfer'].__setitem__('ref_order_final_upper', 0)),
        ('bitmap point headers', lambda a, p: p['program_points'].__setitem__('each_assignment_header_array_bytes_upper', 0)),
        ('live-range pool', lambda a, p: p['LRA_additional_pools']['live_ranges'].__setitem__('live_objects_upper', 0)),
        ('GGC positive total', lambda a, p: a.__setitem__('selected_positive_GGC_events_upper', 47055)),
        ('GGC duplicated owner', lambda a, p: a['selected_native_GGC_ledger']['owner_rows'][-1].__setitem__('owner', a['selected_native_GGC_ledger']['owner_rows'][0]['owner'])),
        ('reload equivalence owner', lambda a, p: a['selected_native_GGC_ledger']['new_transfer']['reload_equivalence'].__setitem__('second_capacity_upper', 291)),
        ('false retained guard', lambda a, p: a['conditions'].__setitem__(next(iter(a['conditions'])), False)),
        ('null retained guard', lambda a, p: a['conditional_conditions'].__setitem__(next(iter(a['conditional_conditions'])), None)),
    ]
    for name, mutate in mutations:
        a, p = copy.deepcopy(frozen), copy.deepcopy(pools)
        mutate(a, p)
        rejects('fixed reconciliation rejects ' + name, lambda: d.retained_interface_check(a, p))
    pins = d.read(HERE / 'inputs.json')
    for name, mutate in (
        ('byte pin', lambda p: p['files'][0].__setitem__('bytes', 0)),
        ('LF coordinate', lambda p: p['excerpts'][0].__setitem__('first_LF_line', p['excerpts'][0]['first_LF_line']+1)),
        ('operative fragment', lambda p: p['excerpts'][0]['operative_fragments'].append('not a retained source expression')),
    ):
        changed = copy.deepcopy(pins)
        mutate(changed)
        rejects('input check rejects ' + name, lambda: d.verify_inputs(args.gcc_source, changed))
    result = copy.deepcopy(hello)
    result['input_verification'] = verification
    result['retained_interface'] = interface
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    elapsed = time.perf_counter()-start
    report = dict(status='passed', checks=len(checks), check_names=checks,
                  elapsed_seconds=elapsed,
                  completed_UTC=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  native_platform=platform.platform(), machine=platform.machine(),
                  input_verification=verification,
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_model_confirmation=None, runtime_effort_confirmation=None,
                  token_usage=None, monetary_cost=None,
                  native_tool_executions=0, predecessor_evaluator_or_checker_executions=0,
                  aggregate_or_corpus_replays=0)
    (HERE / 'check-results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(status='passed', checks=len(checks), elapsed_seconds=elapsed,
                          input_verification=verification)))


if __name__ == '__main__':
    main()
