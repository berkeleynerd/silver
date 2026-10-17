import json, subprocess, sys
run = sys.argv[1]; cmd = sys.argv[2:]
def ok(k):
    r = json.loads(subprocess.run([sys.executable, run, str(k)] + cmd, capture_output=True, text=True, env={'RUN_OUT': '/dev/null', 'PATH': '/usr/bin:/bin'}).stdout)
    return r['rc'] == 0, r['rc']
lo, hi = 64, 65536  # KiB
assert ok(hi)[0], 'fails even at hi'
while hi - lo > 16:
    mid = (lo + hi) // 2
    if ok(mid)[0]: hi = mid
    else: lo = mid
print(json.dumps({'min_ok_kib': hi, 'max_fail_kib': lo, 'fail_rc': ok(lo)[1]}))
