"""Read-only sampling and bounded SIGSTOP guard for the exact failed run.

Run from the integration worktree. The root coordinator alone authorizes
resumptions through monitor-policy.json; this script never resumes or kills.
"""
import datetime
import json
import os
from pathlib import Path
import signal
import time

FOLDER = Path(__file__).parent
EVENTS = Path('tmp/complete-lean-resource-events.jsonl')
LOG = Path('.silver/linux-x86_64/lean-proof.log')
RUNNER_PID = 186036
LAKE_PID = 186098


def stop_process(process, reason, available):
    directory = Path('/proc') / str(process['pid'])
    try:
        state = (directory / 'stat').read_text().split()
        assert state[21] == process['starttime'], 'PID identity changed'
        if state[2] in ('T', 'Z'):
            return
        os.kill(process['pid'], signal.SIGSTOP)
    except (FileNotFoundError, ProcessLookupError):
        return
    event = {
        'event': 'suspend',
        'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'pid': process['pid'],
        'process_starttime': process['starttime'],
        'module': 'Silver.' + process['module'].removesuffix('.lean'),
        'reason': reason + ' No automatic resume, source/options/artifact changes, or termination.',
        'mem_available_kib': available,
    }
    with EVENTS.open('a') as stream:
        stream.write(json.dumps(event) + '\n')
    print('RESOURCE EVENT ' + json.dumps(event), flush=True)
    process['state'] = 'T'


for cycle in range(1440):
    policy = json.loads((FOLDER / 'monitor-policy.json').read_text())
    memory = {line.split(':')[0]: int(line.split()[1])
              for line in Path('/proc/meminfo').read_text().splitlines()}
    children = []
    for directory in Path('/proc').iterdir():
        if not directory.name.isdigit():
            continue
        try:
            state = (directory / 'stat').read_text().split()
            if state[3] != str(LAKE_PID):
                continue
            command = (directory / 'cmdline').read_bytes().decode().split('\0')
            module = next((arg.rsplit('/', 1)[-1] for arg in command
                           if arg.endswith('.lean')), '?')
            children.append({'pid': int(directory.name), 'state': state[2],
                             'starttime': state[21],
                             'rss_kib': int(state[23]) * os.sysconf('SC_PAGE_SIZE') // 1024,
                             'module': module})
        except (FileNotFoundError, ProcessLookupError):
            continue
    available = memory['MemAvailable']
    if policy.get('sequential_harvest'):
        allowed = set(policy.get('allowed_dense_pids', [policy.get('allowed_dense_pid')]))
        for process in children:
            if process['pid'] in allowed:
                continue
            if ('Candidate' in process['module'] or 'Certificate' in process['module']
                    or process['rss_kib'] > 1024 * 1024):
                stop_process(process, 'Root-authorized sequential harvest: park newly scheduled dense job', available)
    if available < policy['emergency_stop_available_kib']:
        runnable = [process for process in children if process['state'] not in ('T', 'Z')
                    and process['rss_kib'] > 1024 * 1024]
        if runnable:
            stop_process(max(runnable, key=lambda process: process['rss_kib']),
                         'Emergency root override: host available RAM below 6 GiB', available)
    sample = {'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'mem_available_kib': available, 'children': children,
              'last_log_line': LOG.read_text().splitlines()[-1]}
    with (FOLDER / 'resource-samples.jsonl').open('a') as stream:
        stream.write(json.dumps(sample) + '\n')
    if cycle % 6 == 0:
        print(json.dumps(sample), flush=True)
    if not (Path('/proc') / str(RUNNER_PID)).exists():
        print('PARENT RUNNER TERMINAL', flush=True)
        break
    time.sleep(policy['sample_interval_seconds'])
