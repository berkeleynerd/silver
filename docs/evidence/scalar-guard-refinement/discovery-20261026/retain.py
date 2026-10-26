#!/usr/bin/env python3
"""Retain completed #237 discovery; never invoke a native/proof tool.

This one-time extraction recipe requires the original scratch results and native
ledger. verify.py checks the resulting portable evidence without those inputs.
"""
from pathlib import Path
from collections import Counter
import gzip
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SCRATCH = ROOT / 'tmp/guard-discovery'
LEDGER = ROOT.parents[1] / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs'
NATIVE = SCRATCH / 'results/20261026T002359Z'
NEGATIVE = SCRATCH / 'negative-controls/results/20261026T003004Z-be3d3b48'
FRAME = SCRATCH / 'frame-results/20261026T002820Z'
retained = []


def sha(data):
    return hashlib.sha256(data).hexdigest()


def save(source, target, compress=False):
    source, target = Path(source), HERE / target
    raw = source.read_bytes()
    target.parent.mkdir(parents=True, exist_ok=True)
    if compress:
        target = target.with_name(target.name + '.gz')
        target.write_bytes(gzip.compress(raw, mtime=0))
    else:
        target.write_bytes(raw)
    retained.append(dict(original=str(source), retained=str(target.relative_to(HERE)),
                         bytes=len(raw), sha256=sha(raw), stored_sha256=sha(target.read_bytes())))
    return target


def dump(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')


def load(path):
    return json.loads(Path(path).read_text())


def retain_reports(source, target):
    # Retain complete policy inputs and diagnostics, never sessions/objects.
    for path in sorted(source.rglob('*')):
        if path.is_file() and (path.suffix in ('.spark', '.sarif', '.stdout', '.stderr')
                               or path.name in ('gnatprove.out', 'data_representation_generation.log')):
            save(path, target / path.relative_to(source), True)


def records(source):
    raw, sarif = [], []
    for path in sorted(source.glob('*.spark')):
        data = load(path)
        role = 'Main' if path.name.startswith('main') else path.stem
        for category in ('proof', 'flow', 'warn_error', 'spark'):
            for record in data.get(category, []):
                if isinstance(record, dict):
                    raw.append(dict(role=role, report=path.name, category=category,
                                    **{k: v for k, v in record.items()
                                       if k not in ('check_tree', 'stats', 'cntexmp')}))
    for path in sorted(source.glob('*.sarif')):
        for run in load(path).get('runs', []):
            for record in run.get('results', []):
                location = record.get('locations', [{}])[0]
                physical = location.get('physicalLocation', {})
                filename = physical.get('artifactLocation', {}).get('uri', '')
                sarif.append(dict(report=path.name, file=filename, **record))
    return raw, sarif


def ledger_for(stdout, label):
    match = re.search(r'Managed run: (\S+)', stdout.read_text())
    assert match, stdout
    run_id = match.group(1)
    events_path = LEDGER / run_id / 'events.jsonl'
    events = [json.loads(line) for line in events_path.read_text().splitlines()]
    prepared = next(event for event in events if event['event'] == 'prepared')
    started = next(event for event in events if event['event'] == 'started')
    finished = next(event for event in events if event['event'] == 'finished')
    command = next(event for event in events if event['event'] == 'command')
    save(events_path, Path('runs') / run_id / 'events.jsonl', True)
    save(LEDGER / run_id / 'native.log', Path('runs') / run_id / 'native.log', True)
    return dict(label=label, run_id=run_id, started_utc=started['utc'],
                finished_utc=finished['utc'], duration_seconds=finished['duration_seconds'],
                outcome=finished['outcome'], workers=started['workers'],
                command=command['command'], command_utc=command['utc'],
                native_phases=[event for event in events
                               if event['event'] in ('phase-start', 'phase-end')],
                prepared_fingerprint=prepared['fingerprint'],
                prepared_inputs=prepared['inputs'])


def compare(run, original, portable):
    data = Path(original).read_bytes()
    expected = run['prepared_inputs']['inputs_sha256'][str(original)]
    assert data and sha(data) == expected
    assert (HERE / portable).read_bytes() == data
    return dict(run_id=run['run_id'], original=str(original), retained=str(portable),
                bytes=len(data), sha256=sha(data), matches_prepared_event=True)


def main():
    runs, comparisons, cases = [], [], []
    for name in ('README.md', 'prepare.py', 'prepare_shapes.py', 'run.py', 'measure_frames.py',
                 'manifest.json', 'doors.expected.txt'):
        save(SCRATCH / name, Path('recipes') / name)
    for name in ('README.md', 'prepare.py', 'run-negative-controls.py', 'manifest.json'):
        save(SCRATCH / 'negative-controls' / name, Path('recipes/negative-controls') / name)
    for label, batch in (('native', NATIVE), ('negative', NEGATIVE)):
        for name in ('summary.json', 'expectations.json', 'diagnostic-summary.json'):
            if (batch / name).exists():
                save(batch / name, Path(label) / name, True)
        for case in load(batch / 'summary.json'):
            name = case['name']
            source = batch / name
            target = Path(label) / name
            original_input = source / 'input' if label == 'negative' else SCRATCH / 'probes' / name
            retained_input = source / 'input' if label == 'negative' else source
            for relative in ('src/main.adb', 'probe.gpr'):
                save(retained_input / relative, target / relative)
            for path in sorted(source.glob('*')):
                if path.is_file() and (path.suffix in ('.stdout', '.stderr') or path.name in ('run.json', 'expected.txt')):
                    save(path, target / path.name, path.name == 'run.json')
            retain_reports(source / 'reports', target / 'reports')
            run = ledger_for(source / 'proof.stdout', f'{label}/{name}/proof')
            runs.append(run)
            for relative in ('src/main.adb', 'probe.gpr'):
                comparisons.append(compare(run, original_input / relative, target / relative))
            raw, sarif = records(source / 'reports')
            cases.append(dict(group=label, name=name, run_id=run['run_id'],
                              source_bytes=(retained_input / 'src/main.adb').stat().st_size,
                              exit_status=case['exit_status'], raw_records=raw, sarif_records=sarif,
                              proof_sites=[r for r in raw if r['role'] == 'Main' and r['category'] == 'proof']))
            if name == 'doors':
                build = ledger_for(source / 'build.stdout', 'native/doors/build')
                runs.append(build)
                for run_to_match in (run, build):
                    if run_to_match is build:
                        for relative in ('src/main.adb', 'probe.gpr'):
                            comparisons.append(compare(build, original_input / relative, target / relative))
                    for lib in ('silver_io.ads', 'silver_io.adb', 'silver_output_libc.ads'):
                        portable = Path('runtime') / lib
                        if not (HERE / portable).exists():
                            save(ROOT / 'src' / lib, portable)
                        comparisons.append(compare(run_to_match, ROOT / 'src' / lib, portable))
    save(SCRATCH / 'frame-proxy/src/main.adb', Path('frame/proxy/src/main.adb'))
    save(SCRATCH / 'frame-proxy/frame.gpr', Path('frame/proxy/frame.gpr'))
    for path in sorted(FRAME.iterdir()):
        if path.is_file():
            save(path, Path('frame/results') / path.name, path.suffix in ('.stdout', '.stderr'))
    for path in sorted((SCRATCH / 'recognizer-shapes').iterdir()):
        if path.is_file():
            save(path, Path('frame/recognizer-shapes') / path.name)
    for stdout in [FRAME / 'build.stdout', *sorted(FRAME.glob('proxy-*.stdout'))]:
        run = ledger_for(stdout, 'frame/' + stdout.stem)
        runs.append(run)
        for relative in ('src/main.adb', 'frame.gpr'):
            comparisons.append(compare(run, SCRATCH / 'frame-proxy' / relative,
                                       Path('frame/proxy') / relative))
    dump('analysis.json', dict(scope='Native discovery only; no Silver admission or universal proof claim.',
                               cases=cases, runs=runs, source_comparisons=comparisons))
    dump('retention-index.json', dict(compression='gzip, mtime=0; sha256/bytes describe decompressed originals',
                                     inputs=retained))
    print(json.dumps(dict(files=len(retained), runs=len(runs), source_comparisons=len(comparisons),
                          all_comparisons_nonzero=all(row['bytes'] > 0 for row in comparisons))))


if __name__ == '__main__':
    main()
