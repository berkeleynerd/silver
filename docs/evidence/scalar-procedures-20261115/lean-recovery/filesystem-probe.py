"""Read-only storage/startup discrimination; no theorem or assurance claim."""
import hashlib,json,platform,resource,subprocess
from pathlib import Path
mounted=Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/procedures-lean-370')
native=Path('/home/agent/silver-worktrees/procedures-lean-370')
result={'platform':platform.platform(),'rlimit_nofile':resource.getrlimit(resource.RLIMIT_NOFILE),'trials':[]}
for root in [mounted,native]:
 file=root/'.tools/linux-aarch64/lean/lib/lean/Lake.olean'
 handles=[];trial={'path':str(file),'sha256':hashlib.sha256(file.read_bytes()).hexdigest()}
 try:
  for _ in range(12000):handles.append(file.open('rb'))
 except OSError as e:trial['error']={'errno':e.errno,'message':str(e)}
 finally:
  trial['opened_handles']=len(handles)
  for handle in handles:handle.close()
 probe=root/'tmp/lean-recovery/lake-probe.lean'
 p=subprocess.run([str(root/'.tools/linux-aarch64/lean/bin/lean'),str(probe)],capture_output=True,text=True)
 trial['import_probe']={'source':probe.read_text(),'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
 result['trials'].append(trial)
print(json.dumps(result,indent=2))
