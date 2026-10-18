#!/usr/bin/env python3
"""Check the frozen source witnesses for the review's membership-guard finding.

This reads an archive only. It is not a runtime or semantic proof.
"""
import hashlib
import json
from pathlib import Path
import tarfile
import time

started = time.monotonic()
packet = Path(__file__).resolve().parent.parent / 'retained-why-inline-callback-closure-20261018'
archive = packet / 'sources.tar.gz'
assert hashlib.sha256(archive.read_bytes()).hexdigest() == 'e59e901cb848afa258750a6c80de876dd0dd9aac3e45491f0dc19b95a136abb6'
member = 'why3/src/session/session_itp.ml'
with tarfile.open(archive) as source_archive:
    data = source_archive.extractfile(member).read()
assert len(data) == 81245
assert hashlib.sha256(data).hexdigest() == 'b04b689c189e095a383ea9b66ac017f9476b8d1a8c7d05a4af96dacbb43366b9'
source = data.decode()
witnesses = [
    'let get_task s id =\n  Hpn.find s.session_raw_tasks id',
    'let goal_is_detached s pn =\n  try let (_:Task.task) = get_task s pn in false\n  with Not_found -> true',
    '| APn pn     -> goal_is_detached s pn',
    '| APn g when not (is_detached s any)  ->\n                let t = get_task s g in',
]
lines = []
for witness in witnesses:
    assert source.count(witness) == 1
    lines.append(source[:source.index(witness)].count('\n') + 1)
occurrences = [i for i, line in enumerate(source.splitlines(), 1)
               if 'session_raw_tasks' in line]
assert occurrences == [136, 311, 631, 687]
print(json.dumps({
    'status': 'pass',
    'reviewed_commit': '20e801be186ce6e41cb7c53d44d6cd072fa06dda',
    'source_member': member,
    'witness_start_lines': lines,
    'session_raw_tasks_occurrence_lines': occurrences,
    'scope': 'Frozen source identity and exact membership-guard witnesses; no whole-program mutation or exception theorem',
    'new_native_target_runs': 0,
    'elapsed_seconds': time.monotonic() - started,
}, indent=2))
