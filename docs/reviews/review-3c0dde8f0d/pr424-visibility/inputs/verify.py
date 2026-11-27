from pathlib import Path
import json,os,resource,subprocess
p=Path(__file__).resolve().parent.parent
i=p/'inputs'; o=p/'outputs'
soft,hard=resource.getrlimit(resource.RLIMIT_STACK)
resource.setrlimit(resource.RLIMIT_STACK,(16*1024*1024,hard))
print('cpu_affinity',sorted(os.sched_getaffinity(0)),flush=True)
probe=subprocess.run([str(o/'bin/admission_probe')],text=True,capture_output=True)
print(probe.stdout,probe.stderr,flush=True)
assert probe.returncode==0
results=[]
source=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/named-array-parameters-410/src')
for c in json.loads((i/'cases.json').read_text()):
    d=i/c['label']; out=o/c['label']; out.mkdir(exist_ok=True)
    command=['gnatmake','-q','-c','-u','-j1','-gnat2022','-gnata','-gnato','-gnatdM','-D',str(out),'-I'+str(d),'-I'+str(source),str(d/'main.adb')]
    r=subprocess.run(command,cwd=out,text=True,capture_output=True,timeout=60)
    print(c['label'],r.returncode,r.stdout,r.stderr,flush=True)
    result={'label':c['label'],'command':command,'returncode':r.returncode,'stdout':r.stdout,'stderr':r.stderr,'expected_frontend_success':c['frontend_success']}
    results.append(result)
    assert (r.returncode==0)==c['frontend_success'],result
(o/'results.json').write_text(json.dumps({'probe_stdout':probe.stdout,'probe_returncode':probe.returncode,'affinity':sorted(os.sched_getaffinity(0)),'frontend':results},indent=2)+'\n')
