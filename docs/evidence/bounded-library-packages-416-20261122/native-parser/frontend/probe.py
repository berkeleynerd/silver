from pathlib import Path
import json, subprocess
base=Path(__file__).parent
records=[]
for name,stem in [('zero','p'),('one','p')]+[(n,n) for n in ['ada','interfaces','system','standard','gnat']]:
 command=['gprbuild','-P',str(base/name/'check.gpr'),'-c','-u',stem+'.adb','main.adb','-p','-j8']
 result=subprocess.run(command,capture_output=True,text=True)
 record={'case':name,'phase':'compile','command':command,'returncode':result.returncode,'stdout':result.stdout,'stderr':result.stderr}
 records.append(record)
 print(json.dumps(record),flush=True)
 if name=='zero':
  assert result.returncode!=0
  assert 'does not allow a body' in result.stdout+result.stderr
 elif name=='one':
  assert result.returncode==0
 if result.returncode==0:
  command=['gprbuild','-P',str(base/name/'check.gpr'),'-p','-j8']
  result=subprocess.run(command,capture_output=True,text=True)
  record={'case':name,'phase':'build','command':command,'returncode':result.returncode,'stdout':result.stdout,'stderr':result.stderr}
  records.append(record)
  print(json.dumps(record),flush=True)
  if name=='one': assert result.returncode==0
(base/'out/result.json').write_text(json.dumps(records,indent=2)+'\n')
