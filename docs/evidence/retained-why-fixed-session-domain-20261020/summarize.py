#!/usr/bin/env python3
"""Summarize already successful certificates; do not recompute their binders."""
import argparse
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent


def read(path):
    return json.loads(path.read_bytes())


def identity(path):
    raw = path.read_bytes()
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def summarize():
    timer = time.perf_counter()
    cases = []
    for name, label in [('put_line','Silver_IO.Put_Line'), ('put','Silver_IO.Put'),
                        ('first_or_default','Silver_Arguments.First_Or_Default'),
                        ('is_message','Silver_Arguments.Is_Message')]:
        path = HERE/(name.replace('_','-')+'-analysis.json')
        facts = read(path)
        cert = facts['full_certificate']
        assert facts['B_binders'] == cert['B_binders']
        assert facts['forest_visits'] == len(cert['visits'])
        assert facts['distinct_formulas'] == len(cert['formulas'])
        assert facts['raw_task_values'] == len(cert['tasks'])
        assert facts['explicit_alpha_crosschecked_formulas'] == facts['distinct_formulas']
        assert not facts['ordinary_ending_capacity_established']
        assert not facts['all_pair_preparation_capacity_established']
        assert facts['source_inputs']['binders'] == identity(E/'retained-why-session-save-state-20261019/binders.py')
        assert facts['source_inputs']['refiner'] == identity(E/'retained-why-inline-refinement-20261018/refine.py')
        cases.append(dict(case=name, unit=label, pid=facts['pid'],
            source='new retained registration-endpoint capture', endpoint=facts['endpoint'],
            phase='pre-scheduling registration; before driver preparation',
            B_binders=facts['B_binders'], forest_visits=facts['forest_visits'],
            distinct_formulas=facts['distinct_formulas'], raw_task_values=facts['raw_task_values'],
            source_analysis=str(path.relative_to(REPO)), analysis_identity=identity(path),
            original_offline_analysis_seconds=facts['elapsed_seconds'],
            exact_session_replay=dict(sequential_reads=facts['exact_session_replay']['sequential_reads'],
                byte_equal_projection_files=len(facts['exact_session_replay']['byte_equal_files'])),
            later_counter_Hsdecl_auxiliary_reads='retained; not replayed by this analyzer'))
    prior_path = E/'retained-why-session-save-state-20261019/result.json'
    prior = read(prior_path)
    assert (prior['pid'],prior['B_binders'],prior['apn_visits'],prior['distinct_prop_formulas']) == (97103,966,5,66)
    cases.append(dict(case='input_is_valid', unit='Silver_Arguments.Input_Is_Valid', pid=prior['pid'],
        source='reused prior first-inline capture; not a fifth new native process',
        endpoint='first Input_Is_Valid/cvc5 inline entry', phase='first-inline entry',
        B_binders=prior['B_binders'], forest_visits=prior['apn_visits'],
        distinct_formulas=prior['distinct_prop_formulas'], raw_task_values=prior['distinct_raw_tasks'],
        source_analysis=str(prior_path.relative_to(REPO)), analysis_identity=identity(prior_path),
        managed_run=prior['managed_run'], prior_managed_capture_seconds=prior['managed_seconds'],
        counter_Hsdecl_auxiliary_replay='separately established by the prior packet; not a new replay'))
    return dict(scope='Five retained process-specific forest binder charges at explicitly different endpoints',
        cases=cases, new_native_cases=4, reused_prior_cases=1,
        managed_run='20261020T071442-a3e5fa7cb995', managed_capture_seconds=247.745976497,
        serial_native_worker_count=1, new_native_executions_by_packaging=0,
        analyzer_replays_by_packaging=0, binder_analyses_repeated_by_packaging=0,
        ordinary_ending_capacity_established=False, all_pair_preparation_capacity_established=False,
        issue153_complete=False, B_charge_scope='per save over each retained logical forest',
        deterministic_input_graph_universalized=False, B966_transferred_to_other_processes=False,
        current_admission_changed=False, Oracle_changed=False,
        model=dict(selected='GPT-6.1 Sol', effort='Extra High', runtime_confirmation=False),
        token_and_monetary_measurements=None,
        summary_only_elapsed_seconds=time.perf_counter()-timer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = summarize()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(cases=len(result['cases']),
        B_binders={row['case']:row['B_binders'] for row in result['cases']},
        elapsed_seconds=result['summary_only_elapsed_seconds'])))
