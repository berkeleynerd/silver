"""Local #373 timing wrapper; the managed runner owns validation and evidence."""
from datetime import datetime, timezone
from pathlib import Path
import json
import resource
import subprocess
import sys
import time

destination = Path(sys.argv[1])
command = sys.argv[2:]
started = datetime.now(timezone.utc).isoformat()
tick = time.monotonic()
with destination.with_suffix('.log').open('w') as output:
    print(json.dumps({'command': command, 'started': started,
                      'stack_limits': resource.getrlimit(resource.RLIMIT_STACK)}),
          file=output, flush=True)
    result = subprocess.run(command, stdout=output, stderr=subprocess.STDOUT)
usage = resource.getrusage(resource.RUSAGE_CHILDREN)
destination.with_suffix('.timing.json').write_text(json.dumps({
    'command': command, 'started': started,
    'finished': datetime.now(timezone.utc).isoformat(),
    'elapsed_seconds': time.monotonic() - tick, 'returncode': result.returncode,
    'child_user_seconds': usage.ru_utime, 'child_system_seconds': usage.ru_stime,
    'child_maxrss_kib': usage.ru_maxrss,
    'note': 'RUSAGE_CHILDREN max RSS is not a simultaneous process-tree peak.'
}, indent=2) + '\n')
destination.with_suffix('.exit').write_text(str(result.returncode) + '\n')
raise SystemExit(result.returncode)
