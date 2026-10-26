#!/usr/bin/env python3
"""Capture a lead-run suite, or reconcile an existing capture without rerunning it."""
from datetime import datetime, timezone
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
RENDERER = {'rosetta/refresh.py', 'rosetta/coverage.json', 'rosetta/manifest.json'}
SUITE_COMMAND = ['-m', 'unittest', 'discover', '-s', 'tests', '-v']


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def stamp():
    return datetime.now(timezone.utc).isoformat()


def instant(value):
    result = datetime.fromisoformat(value)
    require(result.tzinfo is not None, 'timestamp has no timezone')
    return result


def one(rows, event):
    matches = [row for row in rows if row.get('event') == event]
    require(len(matches) == 1, 'expected one ' + event)
    return matches[0]


def select_run(record, launch_log, registry):
    """Use real registry path and ledger identity; nested fixture stdout is data."""
    root = Path(record['cwd']).resolve()
    wrapper = record['command']
    require(len(wrapper) == 7 and wrapper[1:4] == ['scripts/dev.py', 'test', '--jobs']
            and wrapper[5] == '--task' and int(wrapper[4]) > 0, 'unexpected wrapper command')
    candidates, ignored = [], []
    observed = re.findall(r'^Managed run: (\d{8}T\d{6}-[0-9a-f]{12}) \((.*)\)$',
                          launch_log.read_text(), flags=re.M)
    require(observed, 'no managed run announcement')
    for run_id, printed_path in observed:
        directory = registry.resolve() / run_id
        # Fixture runners advertise separate /tmp/... registries and may reuse IDs.
        if Path(printed_path).resolve() != directory:
            ignored.append({'run_id': run_id, 'reason': 'announcement names a different registry'})
            continue
        rows = [json.loads(line) for line in (directory / 'events.jsonl').read_bytes().splitlines()]
        start, prepared, finish = (one(rows, event) for event in ('started', 'prepared', 'finished'))
        require(all(row.get('run_id') == run_id for row in rows), 'mixed managed run IDs')
        require(start['kind'] == 'test' and start['host'] == 'linux-x86_64'
                and Path(start['worktree']['resolved']) == root
                and start['scope'] == ['all-tests'] and start['task'] == wrapper[6]
                and start['requested_workers'] == int(wrapper[4])
                and start['command'] == [wrapper[0], *SUITE_COMMAND], 'wrong root suite identity')
        for value in (start['inputs'], prepared['inputs']):
            require(value['mode'] == 'test' and value['scope'] == ['all-tests']
                    and value['arguments'] == [], 'wrong root suite scope/arguments')
        commands = [row for row in rows if row['event'] == 'command']
        require(len(commands) == 1 and commands[0]['command'] == start['command']
                and Path(commands[0]['cwd']) == root, 'wrong suite effective command')
        require(instant(record['before_utc']) <= instant(start['utc']) < instant(finish['utc'])
                <= instant(record['after_utc']), 'capture does not bracket suite')
        require(finish['outcome'] in ('success', 'failure')
                and (finish['returncode'] or 0) == record['exit_code'], 'child/managed result mismatch')
        require((finish['outcome'] == 'success') == (record['exit_code'] == 0), 'managed outcome mismatch')
        captures = prepared['inputs']['inputs_sha256']
        sample = captures.get(str(root / 'samples/manifest.json'), captures.get('samples/manifest.json'))
        require(sample == record['sample_manifest_before_sha256']
                == record['sample_manifest_after_sha256'], 'managed sample manifest mismatch')
        candidates.append((run_id, finish['outcome'], sample))
    require(len(candidates) == 1, 'expected one actual root full-test ledger identity')
    require(set(record['before']) == RENDERER and record['before'] == record['after'], 'renderer changed/incomplete')
    run_id, outcome, sample = candidates[0]
    return {'run_id': run_id, 'suite_outcome': outcome, 'sample_manifest_managed_sha256': sample,
            'selection_basis': 'announced actual registry path plus worktree/kind/scope/arguments/command/task/workers/time identity',
            'ignored_nested_announcements': ignored, 'capture_rejection': None,
            'rejection': None if outcome == 'success' else 'complete suite did not finish successfully'}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, default=REPO / 'tmp/bounded-mutable-integers-native')
    p.add_argument('--registry', type=Path, default=REPO / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--jobs', type=int, default=2)
    p.add_argument('--task', default='#240')
    p.add_argument('--reconcile', type=Path, help='existing snapshot; never launch a validator in this mode')
    args = p.parse_args()
    out = args.out.resolve()
    require(not out.exists(), 'use a new output directory')
    if args.reconcile:
        original = args.reconcile.resolve()
        record = json.loads(original.read_bytes())
        launch = original.parent / 'suite-launch.log'
        require(digest(launch) == record['launch_log_sha256'], 'original launch log mismatch')
        record['original_capture'] = {'path': str(original), 'sha256': digest(original),
                                      'run_id': record.get('run_id'), 'rejection': record.get('rejection')}
        record['original_launch_log'] = {'path': str(launch), 'sha256': digest(launch)}
        record['reconciled_utc'] = stamp()
    else:
        root = args.root.resolve()
        require(args.jobs > 0, 'use positive jobs')
        before = {name: digest(root / name) for name in sorted(RENDERER)}
        sample = digest(root / 'samples/manifest.json')
        record = {'schema_version': 2, 'cwd': str(root), 'before': before,
                  'before_utc': stamp(), 'sample_manifest_before_sha256': sample}
        record['command'] = [sys.executable, 'scripts/dev.py', 'test', '--jobs', str(args.jobs), '--task', args.task]
        out.mkdir(parents=True)
        launch = out / 'suite-launch.log'
        tick = time.monotonic()
        with launch.open('w') as log:
            with subprocess.Popen(record['command'], cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                  text=True, errors='replace') as child:
                for line in child.stdout:
                    log.write(line)
                    log.flush()
                    print(line, end='', flush=True)
                record['exit_code'] = child.wait()
        record.update(after={name: digest(root / name) for name in sorted(RENDERER)},
                      after_utc=stamp(), elapsed_seconds=time.monotonic() - tick,
                      sample_manifest_after_sha256=digest(root / 'samples/manifest.json'),
                      launch_log_sha256=digest(launch))
    record.update(select_run(record, launch, args.registry))
    record['schema_version'] = 2
    out.mkdir(parents=True, exist_ok=True)
    snapshot = out / 'suite-renderer-before-after.json'
    snapshot.write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')
    print(json.dumps({'run_id': record['run_id'], 'exit_code': record['exit_code'],
                      'rejection': record['rejection'], 'snapshot': str(snapshot)}, indent=2))
    # Reconciliation success means capture identity resolved; suite failure stays explicit.
    return 0 if args.reconcile else record['exit_code']


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('suite capture rejected: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
