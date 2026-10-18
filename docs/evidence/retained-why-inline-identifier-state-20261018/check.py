"""Focused offline counter, state binding and raw-memory decoder verification."""
from pathlib import Path
import json
import subprocess
import sys
import tempfile
import time

from compose import HERE, archive, compose
from counter import registration_transfer

start = time.monotonic()
result = compose()
assert json.loads(json.dumps(result)) == json.loads((HERE/'result.json').read_text())
assert result['private_counter_observed'] and result['same_run_graph_and_complete_Hsdecl_binding_checked']
assert result['registration_transfer']['initial'] == 60496
assert result['registration_transfer']['registrations_upper'] == 1145
assert result['registration_transfer']['counter_after_call_upper'] == 61641
assert not result['complete_continuing_call_counter_capacity_established']
assert not result['runtime_identifier_reentrancy_closure_established']
assert not result['family_wide_counter_invariance_established']
assert not result['prior_history_no_overflow_established']
assert not result['complete_transform_capacity_established']
assert not result['whole_pipeline_capacity_established']
assert [x['outcome'] for x in result['managed_capture_attempts']] == ['failure','failure','success']
checks = []
def reject(label, fn):
    try:
        fn()
    except AssertionError:
        checks.append(label)
    else:
        raise AssertionError(label+' unexpectedly accepted')
maximum = (1 << 62)-1
assert registration_transfer(maximum, 0)['counter_after_call_upper'] == maximum
assert registration_transfer(maximum-1, 1)['last_tag_upper'] == maximum
reject('preincrement overflow at maximum', lambda: registration_transfer(maximum, 1))
reject('Boolean initial state', lambda: registration_transfer(True, 1))
reject('negative starting state', lambda: registration_transfer(-1, 0))
reject('Boolean event bound', lambda: registration_transfer(0, True))
assert registration_transfer(60496, 1146)['counter_after_call_upper'] == 61642
checks.append('additional registration propagates instead of being silently excluded')
capture = archive(HERE/'capture.tar.gz')
with tempfile.TemporaryDirectory(prefix='silver-identifier-fixture-') as tmp:
    root = Path(tmp)
    for name in ['snapshot-observer.py','test-snapshot-observer.py']:
        (root/name).write_bytes(capture[name])
    process = subprocess.run([sys.executable, '-B', str(root/'test-snapshot-observer.py')],
                             text=True, capture_output=True, check=True)
    assert process.stdout.startswith('PASS:')
    checks.append(process.stdout.strip())
print(json.dumps({'status':'pass','elapsed_seconds':round(time.monotonic()-start,6),
                  'new_native_target_runs':0,'checks':checks}))
