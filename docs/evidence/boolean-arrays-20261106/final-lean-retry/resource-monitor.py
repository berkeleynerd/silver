"""Observe the exact retry without signaling or mutating proof processes."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import time

FOLDER = Path(__file__).parent
RUNNER_PID = 384195
LAKE_PID = 384336
LOG = Path('.silver/linux-x86_64/lean-proof.log')
seen = set()

for cycle in range(2160):
    memory = {line.split(':')[0]: int(line.split()[1])
              for line in Path('/proc/meminfo').read_text().splitlines()}
    children = []
    for directory in Path('/proc').iterdir():
        if not directory.name.isdigit():
            continue
        try:
            state = (directory / 'stat').read_text().split()
            if state[3] not in (str(LAKE_PID), str(RUNNER_PID)):
                continue
            command = (directory / 'cmdline').read_bytes().decode().split('\0')
            module = next((arg.rsplit('/', 1)[-1] for arg in command
                           if arg.endswith('.lean')), '?')
            children.append({'pid': int(directory.name), 'parent': int(state[3]),
                             'state': state[2], 'starttime': state[21],
                             'rss_kib': int(state[23]) * os.sysconf('SC_PAGE_SIZE') // 1024,
                             'cpu_seconds': (int(state[13]) + int(state[14])) / os.sysconf('SC_CLK_TCK'),
                             'module': module})
        except (FileNotFoundError, ProcessLookupError):
            continue
    contents = re.sub(r'\x1b\[[0-9;]*m', '', LOG.read_text(errors='replace'))
    for line in contents.splitlines():
        if (line.startswith(('error:', 'warning:', '✖', 'Lean phase '))
                or 'Silver axiom audit passed:' in line) and line not in seen:
            seen.add(line)
            diagnostic = {'utc': datetime.now(timezone.utc).isoformat(), 'line': line}
            with (FOLDER / 'diagnostics.jsonl').open('a') as stream:
                stream.write(json.dumps(diagnostic) + '\n')
            print('DIAGNOSTIC ' + json.dumps(diagnostic), flush=True)
    sample = {'utc': datetime.now(timezone.utc).isoformat(),
              'mem_available_kib': memory['MemAvailable'], 'children': children,
              'last_log_line': contents.splitlines()[-1] if contents else ''}
    with (FOLDER / 'resource-samples.jsonl').open('a') as stream:
        stream.write(json.dumps(sample) + '\n')
    if cycle % 6 == 0:
        print(json.dumps(sample), flush=True)
    if memory['MemAvailable'] < 8 * 1024 * 1024:
        print('RESOURCE CONCERN ' + json.dumps(sample), flush=True)
    if not (Path('/proc') / str(RUNNER_PID)).exists():
        print('PARENT RUNNER TERMINAL', flush=True)
        break
    time.sleep(5)
