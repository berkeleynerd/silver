#!/usr/bin/env python3
"""Inspect retained records and reject mutations. Never execute project validators."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import time
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('repair_export', HERE / 'export-guard-evidence-repaired.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
tick, started = time.monotonic(), m.b.utc()
records = []
args = argparse.Namespace(root=m.REPO / 'tmp/scalar-guard-refinement', target='d4d564cf35',
    out=HERE / 'check-only-no-artifact-copy', registry=m.REPO / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs',
    native_worktree=m.REPO / 'tmp/bounded-mutable-integers-native', lean_worktree=m.REPO / 'tmp/review-b79-b1-lean',
    renderer_snapshot=HERE / 'reconciled/suite-renderer-before-after.json', mode='inspect')
e = m.Export(args)


def rejected(name, action, expected):
    try:
        action()
    except ValueError as error:
        assert expected in str(error), (name, str(error))
        records.append({'check': name, 'result': 'rejected as expected', 'reason': str(error)})
    else:
        raise AssertionError(name + ' unexpectedly accepted')


delta = e.delta()
records.append({'check': 'exact reviewed delta only', 'result': 'passed', 'target': e.target,
                'old_sha256': delta['baseline_auditor_sha256'], 'new_sha256': delta['final_auditor_sha256']})
baseline = e.baseline_suite()
records.append({'check': 'real failed suite retained with reconciled renderer capture', 'result': 'passed',
                'run_id': baseline['run_id'], 'outcome': baseline['outcome'], 'tests': baseline['tests'],
                'errors': baseline['errors'], 'expected_inputs': baseline['input_comparison']['expected'],
                'baseline_inputs_matched': baseline['input_comparison']['baseline_matched']})
for rid, filename, count in [('20261026T120715-ae60c9d42d98', 'test_image_reports.py', 5),
                             ('20261026T120722-6e5bfb5dcbea', 'test_evidence.py', 60)]:
    result = e.repair_test(rid, filename, count)
    records.append({'check': 'real focused repair input extraction', 'result': 'passed', 'run_id': rid,
                    'tests': count, 'worktree': result['worktree'],
                    'expected_inputs': result['tracked_input_comparison']['expected'],
                    'matched': result['tracked_input_comparison']['matched']})
native, _, _ = e.native('20261026T121322-fc9f4056f886')
build, _, build_inputs, _ = e.managed('20261026T121505-a32d8e0916ec', args.native_worktree, 'build')
assert build_inputs['mode'] == 'build' and build_inputs['scope'] == ['compiler'] and not build_inputs['arguments']
records.append({'check': 'strict final-input native/build extraction inherited unchanged', 'result': 'passed',
                'native_run': native['run_id'], 'build_run': build['run_id'],
                'native_inputs': native['tracked_input_comparison']['matched'],
                'build_inputs': build['tracked_input_comparison']['matched']})

rejected('failed suite still rejected by ordinary success extractor',
         lambda: e.managed(m.SUITE, args.native_worktree, 'test'), 'unfinished/failed run')
rows = [json.loads(line) for line in (args.registry / m.SUITE / 'events.jsonl').read_bytes().splitlines()]
captured = m.one(rows, 'prepared')['inputs']['inputs_sha256']
missing = dict(captured)
del missing[str(args.native_worktree / 'src/silver_output_profile.adb')]
rejected('missing baseline source', lambda: e.baseline_compare(missing), 'incomplete baseline suite input inventory')
changed = dict(captured)
changed[str(args.native_worktree / 'alire.toml')] = '0' * 64
rejected('changed nonauditor input', lambda: e.baseline_compare(changed), 'suite baseline/commit mismatch')
changed = dict(captured)
changed[str(args.native_worktree / m.AUDITOR)] = m.NEW_SHA
rejected('wrong baseline auditor capture', lambda: e.baseline_compare(changed), 'reviewed baseline auditor')
real_blob = e.blob
with patch.object(e, 'blob', side_effect=lambda name: real_blob(name) + b'\n' if name == m.AUDITOR else real_blob(name)):
    rejected('any other final auditor bytes', e.delta, 'unreviewed auditor baseline/final bytes')
real_git = e.git
with patch.object(e, 'git', side_effect=lambda *argv: (m.AUDITOR + '\nsrc/silver_output_profile.adb\n').encode()
                  if argv[:2] == ('diff', '--name-only') else real_git(*argv)):
    rejected('additional governed final delta', e.delta, 'additional governed changes')
rejected('wrong focused repair module', lambda: e.repair_test('20261026T120715-ae60c9d42d98', 'test_evidence.py', 60),
         'wrong focused repair scope')
rejected('failed suite cannot substitute for focused repair', lambda: e.repair_test(m.SUITE, 'test_image_reports.py', 5),
         'wrong worktree')
original = m.REPO / 'tmp/guard-final-evidence-20261026/suite-final/suite-renderer-before-after.json'
capture = json.loads(original.read_bytes())
launch = original.parent / 'suite-launch.log'
selected = m.c.select_run(capture, launch, args.registry)
assert selected['run_id'] == m.SUITE and selected['suite_outcome'] == 'failure'
assert len(selected['ignored_nested_announcements']) == 4
records.append({'check': 'four fixture announcements excluded by actual registry identity', 'result': 'passed'})
wrong = copy.deepcopy(capture)
wrong['exit_code'] = 0
rejected('capture cannot promote failure to exit zero', lambda: m.c.select_run(wrong, launch, args.registry), 'child/managed result mismatch')
wrong = copy.deepcopy(capture)
wrong['cwd'] = str(args.root)
rejected('capture cannot select another worktree', lambda: m.c.select_run(wrong, launch, args.registry), 'wrong root suite identity')
for filename in ('export-guard-evidence-repaired.py', 'run-suite-with-renderer-capture.py', 'check-exporter-repair.py'):
    compile((HERE / filename).read_text(), str(HERE / filename), 'exec')
records.append({'check': 'three tooling scripts compile', 'result': 'passed'})
report = {'started_utc': started, 'finished_utc': m.b.utc(), 'elapsed_seconds': time.monotonic() - tick,
          'selected_model': 'GPT-6.1 Sol', 'selected_effort': 'Extra High', 'runtime_settings': 'unconfirmed',
          'tokens': 'unavailable', 'cost': 'unavailable', 'project_validators_invoked': False,
          'implementation_target': e.target, 'final_lean_inspection_pending': True,
          'scripts_sha256': {name: m.sha((HERE / name).read_bytes()) for name in
                            ('export-guard-evidence-repaired.py', 'run-suite-with-renderer-capture.py', 'check-exporter-repair.py')},
          'checks': records}
(HERE / 'inspection-checks.json').write_bytes(m.b.json_bytes(report))
print(json.dumps({'result': 'passed', 'checks': len(records), 'record': str(HERE / 'inspection-checks.json'),
                  'elapsed_seconds': report['elapsed_seconds']}, indent=2))
