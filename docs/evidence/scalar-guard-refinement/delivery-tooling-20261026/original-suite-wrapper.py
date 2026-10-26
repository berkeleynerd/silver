#!/usr/bin/env python3
"""Lead-run wrapper: complete managed suite plus omitted Rosetta input capture."""
from datetime import datetime, timezone
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time


def stamp():
    return datetime.now(timezone.utc).isoformat()


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    owned = Path(__file__).resolve().parent
    repo = owned.parents[1]
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, default=repo / 'tmp/bounded-mutable-integers-native')
    p.add_argument('--registry', type=Path,
                   default=repo / '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
    p.add_argument('--out', type=Path, default=owned / 'suite-capture')
    p.add_argument('--jobs', type=int, default=2, help='managed native worker reservation')
    p.add_argument('--task', default='#240')
    args = p.parse_args()
    root, out = args.root.resolve(), args.out.resolve()
    if args.jobs < 1 or out.exists():
        raise ValueError('use positive jobs and a new output directory')
    selected = ('rosetta/refresh.py', 'rosetta/coverage.json', 'rosetta/manifest.json')
    before = {name: digest(root / name) for name in selected}
    sample_before = digest(root / 'samples/manifest.json')
    before_utc = stamp()
    out.mkdir(parents=True)
    cmd = [sys.executable, 'scripts/dev.py', 'test', '--jobs', str(args.jobs), '--task', args.task]
    tick = time.monotonic()
    run_ids = []
    with (out / 'suite-launch.log').open('w') as log:
        with subprocess.Popen(cmd, cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              text=True, errors='replace') as child:
            for line in child.stdout:
                log.write(line)
                log.flush()
                print(line, end='', flush=True)
                run_ids.extend(re.findall(r'^Managed run: (\d{8}T\d{6}-[0-9a-f]{12}) \(', line))
            status = child.wait()
    after = {name: digest(root / name) for name in selected}
    sample_after = digest(root / 'samples/manifest.json')
    record = {'schema_version': 1, 'command': cmd, 'cwd': str(root),
              'before_utc': before_utc, 'after_utc': stamp(),
              'elapsed_seconds': time.monotonic() - tick, 'exit_code': status,
              'before': before, 'after': after,
              'sample_manifest_before_sha256': sample_before,
              'sample_manifest_after_sha256': sample_after,
              'launch_log_sha256': digest(out / 'suite-launch.log'),
              'run_ids': run_ids, 'run_id': run_ids[0] if len(run_ids) == 1 else None}
    rejection = None
    if len(run_ids) != 1:
        rejection = 'expected exactly one managed run ID'
    else:
        rows = [json.loads(line) for line in
                (args.registry / run_ids[0] / 'events.jsonl').read_text().splitlines()]
        finishes = [row for row in rows if row.get('event') == 'finished']
        prepared = [row for row in rows if row.get('event') == 'prepared']
        if len(finishes) != 1 or finishes[0]['outcome'] != 'success' or status != 0:
            rejection = 'complete suite did not finish successfully'
        if len(prepared) != 1:
            rejection = 'suite input capture missing'
        else:
            captures = prepared[0]['inputs']['inputs_sha256']
            managed_sample = captures.get(str(root / 'samples/manifest.json'), captures.get('samples/manifest.json'))
            record['sample_manifest_managed_sha256'] = managed_sample
            if managed_sample != sample_before:
                rejection = 'complete managed capture omitted or mismatched samples/manifest.json'
    if before != after or sample_before != sample_after:
        rejection = 'suite inputs changed during execution'
    record['rejection'] = rejection
    (out / 'suite-renderer-before-after.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({'run_id': record['run_id'], 'exit_code': status, 'rejection': rejection,
                      'snapshot': str(out / 'suite-renderer-before-after.json')}, indent=2))
    return 1 if rejection else status


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('suite capture rejected: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
