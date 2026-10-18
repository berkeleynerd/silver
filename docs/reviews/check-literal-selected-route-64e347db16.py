#!/usr/bin/env python3
"""Narrow frozen-input/retained-verdict audit; run no candidate evaluator."""
import hashlib
import json
import platform
from pathlib import Path
import subprocess
import time
from datetime import datetime, timezone

REPO = Path(__file__).resolve().parents[2]
PACKET = REPO / 'docs/evidence/retained-literal-pipeline-20261018'
TARGET = '64e347db16294fc96723aca482b080f2ad9f4a79'
BASE = '6b21533df0'


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def git(*args):
    return subprocess.check_output(['git', '-C', str(REPO), *args])


def main():
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    passed = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        passed.append(name)

    paths = git('diff', '--name-only', BASE, TARGET).decode().splitlines()
    target_files = []
    for path in paths:
        raw = (REPO / path).read_bytes()
        check('frozen target ' + path, raw == git('show', TARGET + ':' + path))
        target_files.append(dict(path=path, **identity(raw)))
    check('nine target files', len(paths) == 9)

    manifest = read(PACKET / 'selected-route-inputs.json')
    for row in manifest['files']:
        raw = (REPO / row['path']).read_bytes()
        check('attachment pin ' + row['path'], identity(raw) == {k: row[k] for k in ('bytes', 'sha256')})
        component = ('numeric' if 'literal-ada-numeric' in row['path'] else
                     'invocation' if 'literal-invocation-join' in row['path'] else 'core')
        check('accepted component freeze ' + row['path'],
              raw == git('show', manifest[component + '_freeze'] + ':' + row['path']))
    check('21 attachment inputs', len(manifest['files']) == 21)
    for row in manifest['reviews']:
        raw = git('show', row['revision'] + ':' + row['path'])
        check('historical acceptance ' + row['path'],
              raw == (REPO / row['path']).read_bytes() and
              identity(raw) == {k: row[k] for k in ('bytes', 'sha256')})
    check('three acceptance reviews', len(manifest['reviews']) == 3)
    core_pins = read(PACKET / 'inputs.json')
    check('205 core pins', len(core_pins) == 205 and all(
        identity((REPO / row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')}
        for row in core_pins))
    shared_path = 'docs/evidence/retained-literal-original-shared-storage-20261018/inputs.json'
    shared_raw = (REPO / shared_path).read_bytes()
    shared = json.loads(shared_raw)
    historical = {'docs/evidence/retained-literal-pipeline-20261018/' + name
                  for name in ('compose.py', 'inputs.json', 'result.json')}
    check('shared 35 current and three historical pins unchanged',
          shared_raw == git('show', manifest['core_freeze'] + ':' + shared_path) and
          sum(row['path'] in historical for row in shared) == 3 and
          sum(row['path'] not in historical for row in shared) == 35)

    checks = read(PACKET / 'selected-route-check-results.json')
    check('retained focused success belongs to exact implementation',
          checks['checks'] == len(checks['passed']) == 97 and all(row['passed'] for row in checks['passed']) and
          all(identity((PACKET / name).read_bytes()) == ident
              for name, ident in checks['implementation_inputs'].items()))
    result = read(PACKET / 'selected-route-result.json')
    core, invocation, numeric = (result[key] for key in ('core_result', 'selected_native_invocation', 'native_Ada_numeric'))
    closed = {'Main_assembler_object_interface', 'Main_GAS_BFD_storage', 'literal_output_linker_representation'}
    added = {'native_invocation_' + key for key in ('selected_native_launch_graph_computable',
             'selected_main_emission_to_GAS_object_route_bound', 'selected_fixed_link_input_materialization_computable')}
    added.update('native_Ada_numeric_' + key for key in numeric['checks'])
    check('48 predicates preserve all 40 inherited guards and eight additions',
          len(core['conditions']) == 40 and len(result['conditions']) == 48 and
          set(result['conditions']) == set(core['conditions']) | added and
          set(core['unresolved_predicates']) == closed and
          all(result['conditions'][key] == (core['conditional_conditions'][key] if key in closed else value)
              for key, value in core['conditions'].items()) and
          all(result['conditional_conditions'][key] == value for key, value in core['conditional_conditions'].items()))
    source = identity((REPO / 'samples/hello_world.adb').read_bytes())
    check('actual Hello identity across selected components',
          result['source'] == core['source'] == invocation['source_identity'] == source and
          {k: numeric['source'][k] for k in ('bytes', 'sha256')} == source)
    check('four equal Main roles and P/P+1 conventions',
          all(invocation['common_Main_bindings'][phase] == dict(path=core['launch'][phase + '_Main'], identity=source)
              and core['launch'][phase + '_Main'] == invocation['graph']['Main']
              for phase in ('native', 'datarep', 'phase1', 'phase2')) and
          core['complete_path_bound'] == 512 and invocation['path_bytes'] == 513 and invocation['host_page_bytes'] == 4096)
    conservative = core['literal_output_linker_historical_conservative']
    current = core['literal_output_linker']
    other = {k: v for k, v in conservative['link']['checks'].items() if k != 'fixed_signed_relocation_reach'}
    check('conservative invocation input and 39 unchanged linker guards',
          invocation['link_interface'] == conservative and len(other) == 39 and
          other == core['literal_output_linker_refinement']['unchanged_other_checks'] and
          all(current['link']['checks'][key] == value for key, value in other.items()))
    check('numeric result unchanged and separate from GCC event ledger',
          numeric == read(REPO / 'docs/evidence/retained-literal-ada-numeric-20261018/result.json') and
          core['native_original_shared_storage']['partial_ledger']['known_selected_GGC_event_subtotal'] == 2312 and
          result['selected_current_GGC_partial_ledger'] == 'core_result.native_original_shared_storage.partial_ledger')
    check('selected verdict and broad limitations', result['evaluated_predicates_pass'] and
          result['failed_predicates'] == result['unresolved_predicates'] == [] and
          all(result[key] is False for key in ('whole_literal_pipeline_capacity_established', 'complete_native_capacity',
              'complete_proof_pipeline_capacity', 'complete_parent_storage_closed', 'production_launcher_adopted',
              'production_admission_changed', 'aggregate_RAM_gate')) and
          result['complete_imported_allocation_events'] is result['complete_imported_allocation_bytes'] is None and
          result['invocation_join']['fixed_library_proofs_required'] and not invocation['proof_library_verification_waived'])
    variants = {row['name']: row for row in checks['variants']}
    check('retained capacity failure keeps all four inherited failures',
          variants['expanded_column_failure']['failed_predicates'] == ['Main_expanded_columns', 'Main_ALI_interface',
              'ALI_consumer_local_interfaces', 'GPR_parent_DW_local_interface'] and
          variants['expanded_column_failure']['unresolved_predicates'] == [])
    output = dict(target=TARGET, base=git('rev-parse', BASE).decode().strip(),
                  started_utc=started, completed_utc=datetime.now(timezone.utc).isoformat(),
                  elapsed_seconds=time.perf_counter() - timer, platform=platform.platform(),
                  target_files=target_files, checks=len(passed), passed=passed,
                  retained_focused_checks=97, retained_focused_elapsed_seconds=checks['elapsed_seconds'],
                  candidate_evaluators_executed=0, native_tool_executions=0, broad_suites_rerun=False,
                  external_source_and_installed_validation='Reused from exact accepted component and attachment evidence; not freshly executed.',
                  selected_model='GPT-6 Astra', selected_effort='Extra High', runtime_confirmed_model_effort=None,
                  token_cost_measurements=None)
    destination = Path(__file__).with_suffix('.json')
    destination.write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps(dict(checks=len(passed), elapsed_seconds=output['elapsed_seconds'], output=str(destination))))


if __name__ == '__main__':
    main()
