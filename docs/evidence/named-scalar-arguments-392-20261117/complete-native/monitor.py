from pathlib import Path
from datetime import datetime,timezone
import json,subprocess,shutil
r=Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-aarch64/e513549bff0f5897/runs/20261117T034048-8c22c1e6a33d')
e=[json.loads(s) for s in (r/'events.jsonl').read_text().splitlines()]
p=Path('.silver/linux-aarch64/compiler/obj/gnatprove');d=shutil.disk_usage(p)
mem={s.split(':',1)[0]:s.split(':',1)[1].strip() for s in Path('/proc/meminfo').read_text().splitlines()}
x={'utc':datetime.now(timezone.utc).isoformat(),'last_events':[{k:v.get(k) for k in ('event','phase','state','utc','returncode','error')} for v in e[-2:]],'spark_reports':len(list(p.glob('*.spark'))),'manifest_exists':(p/'proof-provenance.json').exists(),'disk_free_bytes':d.free,'memory_available':mem['MemAvailable'],'swap_free':mem['SwapFree']}
with Path('tmp/final-native-392/monitoring.jsonl').open('a') as f:f.write(json.dumps(x)+'\n')
print(json.dumps(x))
