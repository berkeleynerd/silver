"""Check a reconstructed compiler rejection and a nearby passing control."""
from pathlib import Path
import json, os, re, subprocess, sys, time
base=Path(__file__).resolve().parent
binary=Path(sys.argv[1]).resolve()
cpus=','.join(str(n) for n in sorted(os.sched_getaffinity(0))[:2])
records=[]
for name in ['contradiction','control']:
    source=base/(name+'.adb')
    row={'fixture':name,'observations':[]}
    for action in ['check','compile']:
        command=['bash','-c','ulimit -s 8192 || exit; exec "$@"','guard-frontend-probe','taskset','-c',cpus,str(binary),action,str(source)]
        start=time.monotonic()
        p=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        (base/(name+'-'+action+'.log')).write_bytes(p.stdout)
        obs={'action':action,'returncode':p.returncode,'elapsed_seconds':time.monotonic()-start,'command':command}
        row['observations'].append(obs)
        print(json.dumps({'fixture':name,**obs}),flush=True)
        lines=p.stdout.decode(errors='replace').splitlines()
        print('\n'.join(line for line in lines if any(word in line for word in ['Admitted','Rejected','error:','compilation phase','Success:','Executable:','Workspace:'])),flush=True)
        if action=='check' and p.returncode: break
    records.append(row)
    (base/'results.json').write_text(json.dumps({'scope':'independently reconstructed case; managed success means the expected rejection/control contrast was observed, not that the rejected program compiled','observations':records},indent=2)+'\n')
assert records[0]['observations'][0]['returncode']==0
assert records[0]['observations'][1]['returncode']!=0
assert all(o['returncode']==0 for o in records[1]['observations'])
print('CONFIRMED: admitted reconstructed source fails compile; nearby control passes.',flush=True)
