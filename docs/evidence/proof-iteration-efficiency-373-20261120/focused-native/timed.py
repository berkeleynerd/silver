from datetime import datetime,timezone
from pathlib import Path
import json,resource,subprocess,sys,time
out=Path(sys.argv[1]);cmd=sys.argv[2:]
resource.setrlimit(resource.RLIMIT_STACK,(16777216,resource.getrlimit(resource.RLIMIT_STACK)[1]))
tick=time.monotonic();start=datetime.now(timezone.utc).isoformat()
with out.with_suffix('.log').open('w') as f:
 print(json.dumps({'command':cmd,'started':start,'stack_limits':resource.getrlimit(resource.RLIMIT_STACK)}),file=f,flush=True)
 result=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
r=resource.getrusage(resource.RUSAGE_CHILDREN)
out.with_suffix('.timing.json').write_text(json.dumps({'command':cmd,'started':start,'finished':datetime.now(timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-tick,'returncode':result.returncode,'child_user_seconds':r.ru_utime,'child_system_seconds':r.ru_stime,'child_maxrss_kib':r.ru_maxrss,'note':'RUSAGE_CHILDREN max RSS is not a simultaneous process-tree peak.'},indent=2)+'\n')
out.with_suffix('.exit').write_text(str(result.returncode)+'\n');sys.exit(result.returncode)
