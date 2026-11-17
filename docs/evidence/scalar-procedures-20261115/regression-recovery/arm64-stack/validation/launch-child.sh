#!/bin/sh
set -eu
ulimit -S -s 16384
python3 - <<'STACK_RECORD'
from pathlib import Path
import datetime,json,os,resource
limits=resource.getrlimit(resource.RLIMIT_STACK)
assert limits==(16777216, resource.RLIM_INFINITY), limits
Path('tmp/stack-validation-20261115/actual-child-stack.json').write_text(json.dumps(dict(recorded_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),shell_pid=os.getppid(),probe_pid=os.getpid(),actual_stack_soft_bytes=limits[0],actual_stack_hard_bytes=limits[1],inherited_by_exec=True),indent=2)+'\n')
STACK_RECORD
exec python3 scripts/dev.py test --task '#370' --reason 'Complete unchanged scalar-guard tests with a per-invocation 16384 KiB stack; measured ARM64 parser frames require this environment for admitted exact-source-limit cases; parent limits and production/test/harness code unchanged; original full-suite failure retained' -- -p test_scalar_guards.py
