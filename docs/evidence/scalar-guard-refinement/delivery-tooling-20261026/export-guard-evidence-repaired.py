#!/usr/bin/env python3
"""Export the ONE reviewed Image malformed-message repair checkpoint; no validators."""
from __future__ import annotations
import argparse
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
BASE = REPO / 'tmp/guard-final-evidence-20261026/export-guard-evidence.py'
BASE_SHA = 'ea6180a6d2989831636b509b35792edcb3c4bcbbf0c5d60018207bf4e67c22d7'
BASELINE = 'e88a218c7e935be6d885a5d1c43f0d94e9ebf031'
SUITE = '20261026T110119-3b18a2302af0'
EVENT_SHA = '7276749a9b3e94bff1c8d0c63444b8fae9b88fd4b806eb26e15f02405036ec9b'
LOG_SHA = 'b7c531ce2d5e5d8e1d3f35588226ffada55170e016b5fb5f4dfafd51e76738c9'
AUDITOR = 'scripts/check_evidence.py'
OLD_SHA = '7d8bb865f97e419ec5c3b6466964151feb3cd5ba8233fd80ae521af4525f268e'
NEW_SHA = '1cfe226a5c86874b4cd574da5589f8b925599f009a8e784bd42242e9da2b0060'
OLD = b'                              or record.get("message", {}).get("text") == ARRAY_INITIALIZATION_ADVISORY_TEXT)'
NEW = (b'                              or (isinstance(record.get("message"), dict)\n'
       b'                                  and record["message"].get("text") == ARRAY_INITIALIZATION_ADVISORY_TEXT))')
FAILED_TEST = 'test_mutated_advisory_fields_are_rejected (test_image_reports.ImageEvidenceTests.test_mutated_advisory_fields_are_rejected)'
ERROR = "ERROR: " + FAILED_TEST + " (description='changed message=[]')"


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


import hashlib
if hashlib.sha256(BASE.read_bytes()).hexdigest() != BASE_SHA:
    raise ValueError('reviewed base exporter changed')
b = load('guard_base_export', BASE)
c = load('guard_capture_repair', HERE / 'run-suite-with-renderer-capture.py')
require, sha, one, instant, command = b.require, b.sha, b.one, b.instant, b.command


class Export(b.Export):
    def delta(self):
        old = self.git('show', BASELINE + ':' + AUDITOR)
        new = self.blob(AUDITOR)
        require(sha(old) == OLD_SHA and sha(new) == NEW_SHA, 'unreviewed auditor baseline/final bytes')
        require(old.count(OLD) == 1 and old.replace(OLD, NEW, 1) == new, 'auditor delta is not the one reviewed isinstance guard')
        changed = set(self.git('diff', '--name-only', BASELINE, self.target).decode().splitlines())
        governed = lambda name: (name.split('/', 1)[0] in {'scripts', 'tests', 'src', 'proof', 'samples', 'catalogue', 'rosetta'}
                                 or name in {'silver.gpr', 'alire.toml'})
        require({name for name in changed if governed(name)} == {AUDITOR}, 'additional governed changes invalidate repair reuse')
        baseline_tracked = set(self.git('ls-tree', '-r', '--name-only', BASELINE).decode().splitlines())
        require({name for name in baseline_tracked if governed(name)} == {name for name in self.tracked if governed(name)},
                'governed source inventory changed')
        return {'baseline_commit': BASELINE, 'final_commit': self.target, 'changed_governed_inputs': [AUDITOR],
                'baseline_auditor_sha256': OLD_SHA, 'final_auditor_sha256': NEW_SHA,
                'exact_replacement_verified': True, 'all_other_governed_inputs_unchanged': True,
                'patch': self.retain('repair/auditor-only.patch', self.git('diff', BASELINE, self.target, '--', AUDITOR)),
                'baseline_auditor': self.retain('repair/baseline-check_evidence.py', old),
                'final_auditor': self.retain('repair/final-check_evidence.py', new)}

    def baseline_compare(self, captured):
        """The single historical auditor is explicit; every other hash stays exact."""
        native = self.args.native_worktree.resolve()
        captured = b.hashes(captured)
        expected = self.expected('test')
        local, external = {}, {}
        for name, digest in captured.items():
            path = Path(name)
            if path.is_absolute():
                if not path.is_relative_to(native):
                    external[name] = digest
                    continue
                name = path.relative_to(native).as_posix()
            require(name not in local, 'duplicate captured input: ' + name)
            local[name] = digest
        require(set(local) & self.tracked == expected, 'incomplete baseline suite input inventory')
        require(local[AUDITOR] == OLD_SHA, 'suite did not capture the reviewed baseline auditor')
        require(not {name for name in local if name not in expected and
                     name.split('/', 1)[0] in {'scripts', 'tests', 'src', 'proof', 'samples', 'catalogue'}},
                'baseline capture has uncommitted governed input')
        for name in sorted(expected):
            baseline_digest = sha(self.git('show', BASELINE + ':' + name))
            require(local[name] == baseline_digest, 'suite baseline/commit mismatch: ' + name)
            final_digest = sha(self.blob(name))
            require(final_digest == (NEW_SHA if name == AUDITOR else baseline_digest), 'unreviewed suite input delta: ' + name)
            require(sha((self.root / name).read_bytes()) == final_digest, 'canonical source drift: ' + name)
        for name, digest in captured.items():
            path = Path(name)
            path = path if path.is_absolute() else native / path
            expected_live = NEW_SHA if path == native / AUDITOR else digest
            require(path.is_file() and sha(path.read_bytes()) == expected_live, 'baseline/live input drift: ' + str(path))
        return {'baseline_commit': BASELINE, 'target_commit': self.target, 'expected': len(expected),
                'baseline_matched': len(expected), 'unchanged_matched': len(expected) - 1,
                'explicit_repaired_input': AUDITOR, 'baseline_auditor_sha256': OLD_SHA,
                'final_auditor_sha256': NEW_SHA, 'all_other_captured_inputs_live_match': True,
                'external_inputs': len(external),
                'baseline_target_inputs': self.inventory({name: local[name] for name in sorted(expected)})}

    def renderer_baseline(self, suite):
        snapshot = self.args.renderer_snapshot.resolve()
        raw = snapshot.read_bytes()
        capture = json.loads(raw)
        original = Path(capture['original_capture']['path'])
        launch = Path(capture['original_launch_log']['path'])
        original_raw = original.read_bytes()
        prior = json.loads(original_raw)
        require(sha(original_raw) == capture['original_capture']['sha256'], 'original snapshot changed')
        require(sha(launch.read_bytes()) == capture['launch_log_sha256']
                == capture['original_launch_log']['sha256'] == prior['launch_log_sha256'], 'original launch log changed')
        require(prior['run_id'] is None and prior['exit_code'] == 1
                and prior['rejection'] == 'expected exactly one managed run ID', 'wrong original capture defect')
        for key in ('command', 'cwd', 'before_utc', 'after_utc', 'elapsed_seconds', 'exit_code', 'before', 'after',
                    'sample_manifest_before_sha256', 'sample_manifest_after_sha256', 'run_ids'):
            require(capture[key] == prior[key], 'reconciliation changed original capture: ' + key)
        selected = c.select_run(prior, launch, self.args.registry)
        require(all(capture[key] == value for key, value in selected.items()), 'incorrect reconciled identity')
        require(capture['run_id'] == SUITE and capture['suite_outcome'] == 'failure'
                and capture['exit_code'] == 1 and capture['capture_rejection'] is None
                and capture['rejection'] == 'complete suite did not finish successfully', 'baseline failure was changed')
        require(instant(capture['before_utc']) <= instant(suite['started_utc']) < instant(suite['finished_utc'])
                <= instant(capture['after_utc']), 'renderer capture does not bracket suite')
        for name, digest in b.hashes(capture['before']).items():
            require(sha(self.blob(name)) == digest and sha((self.args.native_worktree / name).read_bytes()) == digest,
                    'renderer target/live mismatch: ' + name)
        require(capture['sample_manifest_managed_sha256'] == sha(self.blob('samples/manifest.json')), 'sample target mismatch')
        return {'capture_valid': True, 'suite_outcome': 'failure', 'original_rejection_retained': prior['rejection'],
                'reconciled_snapshot': self.retain('suite/reconciled-renderer-before-after.json', raw),
                'original_snapshot': self.retain('suite/original-renderer-before-after.json', original_raw),
                'original_launch_log': self.retain('suite/original-suite-launch.log', launch.read_bytes())}

    def baseline_suite(self):
        directory = self.args.registry.resolve() / SUITE
        raw, log = (directory / 'events.jsonl').read_bytes(), (directory / 'native.log').read_bytes()
        require(sha(raw) == EVENT_SHA and sha(log) == LOG_SHA, 'selected baseline evidence changed')
        rows = [json.loads(line) for line in raw.splitlines()]
        start, prepared, finish = (one(rows, event) for event in ('started', 'prepared', 'finished'))
        native = self.args.native_worktree.resolve()
        require(start['kind'] == 'test' and start['host'] == 'linux-x86_64'
                and Path(start['worktree']['resolved']) == native, 'wrong baseline suite identity')
        require(all(row['run_id'] == SUITE for row in rows), 'mixed baseline run IDs')
        require(finish['outcome'] == 'failure' and finish['returncode'] == 1 and not finish['failure_keys'], 'baseline failure changed')
        require(instant(start['utc']) < instant(finish['utc']), 'invalid baseline interval')
        inputs = prepared['inputs']
        require(inputs['mode'] == 'test' and inputs['arguments'] == [] and inputs['scope'] == ['all-tests'], 'wrong baseline suite scope')
        commands = [command(row['command']) for row in rows if row['event'] == 'command']
        require(len(commands) == 1 and commands[0][1:] == c.SUITE_COMMAND and start['command'] == commands[0], 'wrong baseline suite command')
        text = log.decode()
        require(re.findall(r'(?m)^(?:ERROR|FAIL):.*$', text) == [ERROR]
                and text.endswith('Ran 511 tests in 3540.751s\n\nFAILED (errors=1)\n')
                and "AttributeError: 'list' object has no attribute 'get'" in text,
                'baseline failure is not the reviewed malformed-message error')
        require(not re.search(r'(?m)^.*\.\.\. (?:skipped|expected failure|unexpected success)', text), 'baseline has excluded outcomes')
        for prefix in ('test_checked_in_certificates_equal_regeneration ', 'test_manifest_samples ',
                       'test_native_complete_100_doors ', 'test_native_guarded_updates_division_and_captured_bounds '):
            require(re.search(r'(?m)^' + prefix + r'.* \.\.\. ok$', text), 'missing retained baseline success: ' + prefix)
        result = {'run_id': SUITE, 'baseline_commit': BASELINE, 'kind': 'test', 'outcome': 'failure', 'returncode': 1,
                  'worktree': str(native), 'invocation_command': start['command'], 'commands': commands,
                  'started_utc': start['utc'], 'finished_utc': finish['utc'], 'duration_seconds': finish['duration_seconds'],
                  'tests': 511, 'unittest_seconds': 3540.751, 'errors': 1, 'skipped': 0,
                  'failure_identity': ERROR, 'exception': "AttributeError: 'list' object has no attribute 'get'",
                  'input_comparison': self.baseline_compare(inputs['inputs_sha256']),
                  'captured_inputs': self.inventory(inputs),
                  'events': self.retain('suite/baseline-events.jsonl', raw),
                  'log': self.retain('suite/baseline-native.log', log)}
        result['renderer_inputs'] = self.renderer_baseline(result)
        return result

    def repair_test(self, run_id, filename, count):
        result, rows, inputs, directory = self.managed(run_id, self.root, 'test')
        require(inputs['mode'] == 'test' and inputs['arguments'] == ['-p', filename]
                and inputs['scope'] == ['-p', filename], 'wrong focused repair scope')
        require(len(result['commands']) == 1 and result['commands'][0][1:] == c.SUITE_COMMAND + ['-p', filename]
                and result['invocation_command'] == result['commands'][0], 'wrong focused repair command')
        text = (directory / 'native.log').read_text()
        summaries = re.findall(r'(?m)^Ran (\d+) tests in ([\d.]+)s$', text)
        require(len(summaries) == 1 and int(summaries[0][0]) == count
                and re.search(r'\nRan \d+ tests in [\d.]+s\s+OK\s*$', text), 'missing successful focused repair result')
        require(not re.search(r'(?m)^(?:ERROR|FAIL):|^.*\.\.\. (?:skipped|expected failure|unexpected success)', text), 'repair has excluded outcomes')
        if filename == 'test_image_reports.py':
            require(FAILED_TEST + ' ... ok\n' in text, 'previously failing Image test did not pass')
        baseline_rows = [json.loads(line) for line in (self.args.registry / SUITE / 'events.jsonl').read_bytes().splitlines()]
        require(instant(one(baseline_rows, 'finished')['utc']) < instant(result['started_utc']), 'repair predates baseline failure')
        result.update(tests=count, unittest_seconds=float(summaries[0][1]), errors=0, skipped=0)
        return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=('inspect', 'delivery'))
    p.add_argument('--root', type=Path, default=REPO / 'tmp/scalar-guard-refinement')
    p.add_argument('--target', required=True)
    p.add_argument('--registry', type=Path, default=REPO / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
    p.add_argument('--native-worktree', type=Path, default=REPO / 'tmp/bounded-mutable-integers-native')
    p.add_argument('--lean-worktree', type=Path, default=REPO / 'tmp/review-b79-b1-lean')
    p.add_argument('--out', type=Path, required=True)
    for name in ('native-full', 'build', 'lean', 'repair-image', 'repair-evidence'):
        p.add_argument('--' + name, required=True)
    p.add_argument('--renderer-snapshot', type=Path, required=True)
    args = p.parse_args()
    export = Export(args)
    require(not (export.out / 'validation.json').exists(), 'delivery index exists; use new output directory')
    delta = export.delta()
    native, _, _ = export.native(args.native_full)
    build, _, build_inputs, _ = export.managed(args.build, args.native_worktree.resolve(), 'build')
    require(build_inputs['mode'] == 'build' and build_inputs['scope'] == ['compiler'] and not build_inputs['arguments'], 'wrong build scope')
    lean = export.lean(args.lean)
    lean['certificate_scope'] = ('Complete Lean regenerates candidates from captured source/generator inputs; '
        'checked-in candidate parity passed in the separately retained complete suite, whose one unrelated '
        'Image malformed-message error keeps that whole run labeled failure.')
    baseline = export.baseline_suite()
    repair = {'image': export.repair_test(args.repair_image, 'test_image_reports.py', 5),
              'evidence': export.repair_test(args.repair_evidence, 'test_evidence.py', 60)}
    result = {'schema_version': 2, 'implementation_commit': export.target, 'platform': 'Linux x86_64',
              'exported_utc': b.utc(), 'native_full': native, 'native_build': build, 'lean': lean,
              'full_suite_checkpoint': {'claim': 'retained failed complete suite plus successful focused auditor repair',
                                        'fresh_full_suite_success': False, 'baseline_failed_full_suite': baseline,
                                        'reviewed_auditor_delta': delta, 'successful_final_input_repair_tests': repair},
              'fresh_check_evidence': native['fresh_check_evidence'],
              'limits': ['The full 511-test run remains failure (one Image malformed-message error); no fresh 511-test pass is claimed.',
                         'Unaffected completed full-suite cases are reused only for the exact independently reviewed auditor guard delta.',
                         'Native/Lean caches may be reused; final-input complete audits freshly execute.',
                         'No independent kernel replay, native macOS or hosted CI is claimed.',
                         'External comprehensive review and capability/issue integration remain separate.']}
    # Re-read all evidence and current captures at the end; the baseline exception
    # is confined to baseline_compare, never native/build/Lean/focused handling.
    export.delta()
    export.baseline_suite()
    for run_id, kind, worktree in ((args.native_full, 'prove', args.native_worktree),
                                  (args.build, 'build', args.native_worktree),
                                  (args.lean, 'lean', args.lean_worktree),
                                  (args.repair_image, 'test', args.root), (args.repair_evidence, 'test', args.root)):
        rows = [json.loads(line) for line in (args.registry / run_id / 'events.jsonl').read_bytes().splitlines()]
        capture = one(rows, 'started' if kind == 'lean' else 'prepared')['inputs']
        export.compare(capture['sources' if kind == 'lean' else 'inputs_sha256'], worktree.resolve(), kind)
    export.out.mkdir(parents=True, exist_ok=True)
    filename = 'inspection-only.json' if args.mode == 'inspect' else 'validation.json'
    result['exported_utc'] = b.utc()
    if args.mode == 'delivery':
        (export.out / 'artifact-index.json').write_bytes(b.json_bytes(export.artifacts))
    destination = export.out / filename
    destination.with_suffix('.json.tmp').write_bytes(b.json_bytes(result))
    destination.with_suffix('.json.tmp').replace(destination)
    print(json.dumps({'implementation_commit': export.target, 'index': str(destination),
                      'baseline_full_suite_outcome': 'failure', 'focused_repair_tests': 65}, indent=2))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        print('evidence export rejected: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
