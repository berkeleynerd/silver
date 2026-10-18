#!/usr/bin/env python3
"""Independent attachment identity/projection audit; no evaluator/native rerun."""
import ast
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
PACKET = Path('docs/evidence/retained-literal-pipeline-20261018')
TARGET = '99b7247d180b851187e653710b7e56d39f2f35d3'
BASE = 'e67e2a9a267220e9ef87e4ffee2028839a9ed598'
PREDECESSOR = '7573e127ffb020ddfb1214491179c59442e7798b'


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads((ROOT/path).read_bytes())


def main():
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    changed = git('diff', '--name-only', BASE, TARGET).decode().splitlines()
    check('exact nine frozen target files', len(changed) == 9 and all(
        (ROOT/path).read_bytes() == git('show', TARGET+':'+path) for path in changed))
    pins = read(PACKET/'inputs.json')
    check('all 205 current aggregate pins', len(pins) == 205 and all(
        identity((ROOT/row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')}
        for row in pins))
    attachment = read(PACKET/'attachment-inputs.json')
    check('exact accepted historical review snapshots', all(
        identity(git('show', row['revision']+':'+row['path'])) ==
        {k: row[k] for k in ('bytes', 'sha256')} and
        row['required_acceptance_text'].encode() in git('show', row['revision']+':'+row['path'])
        for row in attachment['accepted_reviews'].values()))
    shared = Path('docs/evidence/retained-literal-original-shared-storage-20261018')
    historical = {str(PACKET/name) for name in ('compose.py', 'inputs.json', 'result.json')}
    shared_pins = read(shared/'inputs.json')
    check('shared exact three historical and 35 current partition', len(shared_pins) == 38 and
        {row['path'] for row in shared_pins if row['path'] in historical} == historical and all(
            identity(git('show', PREDECESSOR+':'+row['path']) if row['path'] in historical else
                     (ROOT/row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')}
            for row in shared_pins))
    previous = ast.parse(git('show', PREDECESSOR+':'+str(PACKET/'compose.py')))
    current = ast.parse((ROOT/PACKET/'compose.py').read_bytes())
    definitions = lambda tree: {node.name: node for node in tree.body
                               if isinstance(node, (ast.FunctionDef, ast.ClassDef))}
    before, after = definitions(previous), definitions(current)
    dump = lambda node: ast.dump(node, include_attributes=False)
    check('only Context and evaluate changed among inherited definitions',
          [name for name in before if dump(before[name]) != dump(after[name])] == ['Context', 'evaluate'])
    old_init, new_init = before['Context'].body[0].body, after['Context'].body[0].body
    check('all 106 existing Context statements remain exact prefix', len(old_init) == 106 and
          len(new_init) == 113 and all(dump(a) == dump(b) for a, b in zip(old_init, new_init)))
    leaf = definitions(ast.parse((ROOT/shared/'compose.py').read_bytes()))['derive']
    reads = {node.slice.value for node in ast.walk(leaf) if isinstance(node, ast.Subscript) and
             isinstance(node.value, ast.Name) and node.value.id == 'aggregate' and
             isinstance(node.slice, ast.Constant)}
    result = read(PACKET/'result.json')
    wrapper = result['native_original_shared_storage']
    capacity = wrapper['source_capacity_projection_keys']
    diagnostics = wrapper['inherited_diagnostic_keys']
    check('leaf reads exactly eleven capacity and three diagnostic projections',
          len(capacity) == 11 and len(diagnostics) == 3 and not set(capacity) & set(diagnostics) and
          reads == set(capacity+diagnostics))
    evaluation = after['evaluate']
    projection = next(node.value for node in ast.walk(evaluation) if isinstance(node, ast.Assign) and
                      any(isinstance(t, ast.Name) and t.id == 'shared_projection' for t in node.targets))
    check('actual projection supplies every direct leaf read',
          isinstance(projection, ast.Call) and {k.arg for k in projection.keywords} == reads)
    check('adapter invokes derive and no Context',
          not any(isinstance(node, ast.Call) and isinstance(node.func, ast.Subscript) and
                  isinstance(node.func.slice, ast.Constant) and node.func.slice.value == 'Context'
                  for node in new_init[len(old_init):] for node in ast.walk(node)))
    leaf_result = read(shared/'result.json')
    leaf_result.pop('offline_run')
    check('retained Hello shared interface exactly equals accepted leaf result', wrapper['interface'] == leaf_result)
    ledger = wrapper['partial_ledger']
    check('retained partial ledger exact disjoint named groups', ledger['GGC_groups'] == dict(
        original_Main=1061, original_String216=216, original_helpers94=94,
        synthetic173=173, new_shared_backings=768) and
        ledger['known_selected_GGC_event_subtotal'] == 2312 and
        ledger['new_shared_ordinary_backing_events_upper'] == 41)
    historical_linker = result['literal_output_linker_historical_conservative']
    active = json.loads(json.dumps(result['literal_output_linker']))
    active['link']['relocation_bounds']['common_signed32'] = historical_linker['link']['relocation_bounds']['common_signed32']
    for key in ('checks', 'failed_sufficient_checks', 'selected_output_link_representation_fits'):
        active['link'][key] = historical_linker['link'][key]
    active['selected_literal_assembler_and_linker_representation_fits'] = historical_linker['selected_literal_assembler_and_linker_representation_fits']
    check('retained linker differs only in reviewed bound and verdict fields', active == historical_linker)
    log = read(PACKET/'attachment-check-results.json')
    check('reused 45-check record has complete successful detail', log['checks'] == len(log['checks_detail']) == 45 and
          log['all_passed'] and all(row['passed'] for row in log['checks_detail']))
    check('retained actual predicates and whole verdict remain open',
          set(result['unresolved_predicates']) == {'Main_assembler_object_interface', 'Main_GAS_BFD_storage',
                                                  'literal_output_linker_representation'} and
          all(result['conditions'][k] is None for k in result['unresolved_predicates']) and
          not result['whole_literal_pipeline_capacity_established'])
    record = dict(target=TARGET, base=BASE, historical_predecessor=PREDECESSOR,
        selected_model='GPT-6 Astra', selected_effort='Extra High', runtime_confirmation=None,
        token_cost_measurements=None, host=dict(system=platform.system(), release=platform.release(), machine=platform.machine()),
        checks=len(checks), passed=True, check_names=checks,
        frozen_inputs={path: identity((ROOT/path).read_bytes()) for path in changed},
        source_root_validation_reused=True, aggregate_evaluator_executions=0, native_tool_executions=0,
        broad_success_reruns=0, started_utc=started, completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    output = Path(__file__).with_suffix('.json')
    output.write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({k: record[k] for k in ('checks', 'passed', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
