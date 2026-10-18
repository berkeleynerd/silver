#!/usr/bin/env python3
"""Narrow frozen R1 correction identity/source check; no target execution."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile
import time

started = time.monotonic()
root = Path(__file__).resolve().parents[3]
old = '20e801be186ce6e41cb7c53d44d6cd072fa06dda'
fixed = 'f5475afb3513443a5a05bdfd1e6e7a8ab3a27269'
packet = 'docs/evidence/retained-why-inline-callback-closure-20261018/'


def blob(commit, path):
    return subprocess.check_output(['git', 'show', commit + ':' + path], cwd=root)


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


before = json.loads(blob(old, packet + 'result.json'))
after = json.loads(blob(fixed, packet + 'result.json'))
assert before['registration_transfer'] == after['registration_transfer']
assert after['registration_transfer']['counter_after_call_upper'] == 61641
false_flags = sorted(k for k, value in before.items() if value is False)
assert all(after[k] is False for k in false_flags)
assert after['actual_post_registration_escape_route_established'] is False
assert after['whole_program_absence_of_interfering_alias_mutation_established'] is False
assert after['stable_missing_task_witness_withdrawn'] is True
assert after['raw_task_guard_and_local_occurrence_inventory_checked'] is True

unchanged = ['sources.tar.gz', 'native.tar.gz', 'audit.py', 'binding.json']
for name in unchanged:
    assert blob(old, packet + name) == blob(fixed, packet + name)
round_record = json.loads(blob(fixed, packet + 'round.json'))
for path, expected in round_record['exact_review_inputs'].items():
    assert identity(blob(fixed, path)) == expected
historical = json.loads(blob(old, packet + 'round.json'))
for key in ['checks', 'exact_review_inputs']:
    assert round_record['historical_author_round'][key] == historical[key]
review = round_record['review']
assert identity(blob(review['commit'], review['report'])) == review['report_identity']

with tarfile.open(fileobj=io.BytesIO(blob(fixed, packet + 'sources.tar.gz'))) as archive:
    source = archive.extractfile('why3/src/session/session_itp.ml').read().decode()
assert 'let get_task s id =\n  Hpn.find s.session_raw_tasks id' in source
assert 'let goal_is_detached s pn =\n  try let (_:Task.task) = get_task s pn in false\n  with Not_found -> true' in source
assert '| APn pn     -> goal_is_detached s pn' in source
assert '| APn g when not (is_detached s any)  ->\n                let t = get_task s g in' in source
assert [i for i, line in enumerate(source.splitlines(), 1)
        if 'session_raw_tasks' in line] == [136, 311, 631, 687]

print(json.dumps({
    'status': 'pass',
    'reviewed_correction': fixed,
    'original_commit': old,
    'preserved_false_flags': false_flags,
    'accounted_endpoint': 61641,
    'unchanged_evidence': unchanged,
    'exact_review_inputs': round_record['exact_review_inputs'],
    'scope': 'Correction identities, preserved flags/arithmetic/history, unchanged extraction evidence, exact archived guard and local occurrences; prose reviewed separately',
    'new_native_target_runs': 0,
    'static_extraction_regenerated': False,
    'elapsed_seconds': time.monotonic() - started,
}, indent=2))
