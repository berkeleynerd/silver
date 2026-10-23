"""Focused finite checks for the new Hsattr attachment and source projection."""
import json
import platform
import sys
import time
import derive

start = time.monotonic()
checks = 0


def require(value):
    global checks
    assert value
    checks += 1


manifest = derive.read(derive.HERE / 'inputs.json')
for path, expected in manifest['files'].items():
    require(derive.identity((derive.ROOT / path).read_bytes()) == expected)
require(derive.source_projection() == derive.read(derive.HERE / 'source-witnesses.json'))
require(derive.origin_projection() == derive.read(derive.HERE / 'origins.json'))
result = derive.calculate()
require(result == derive.read(derive.HERE / 'result.json'))
for value in (True, False, -1, 3, 2.0, None):
    try:
        derive.calculate(value)
    except ValueError:
        checks += 1
    else:
        raise AssertionError('bad event budget accepted')
try:
    derive.no_at(['model_trace:x', 'at:unexpected'])
except AssertionError:
    checks += 1
else:
    raise AssertionError('located-label antecedent not checked')
zero, one = derive.calculate(0), derive.calculate(1)
for a, b, c in zip(zero['cases'], one['cases'], result['cases']):
    require(a['lifetime_requests_and_increments_upper'] < b['lifetime_requests_and_increments_upper'] < c['lifetime_requests_and_increments_upper'])
    require(c['backing']['individual_outer_array_length_upper'] == 3*c['lifetime_requests_and_increments_upper']+3)
    require(c['counter']['final_upper'] == c['lifetime_requests_and_increments_upper'])
    require(c['native_owner_operands_fit'] and not c['actual_whole_process_headroom'])
out = dict(status='pass', checks=checks, elapsed_seconds=time.monotonic()-start,
           host=platform.system() + ' ' + platform.machine(),
           native_runs=0, predecessor_checker_replays=0,
           source_simulation_proved_by_checker=False)
derive.write(sys.argv[1] if len(sys.argv) == 2 else 'check-result.json', out)
print(json.dumps(out, indent=2))
