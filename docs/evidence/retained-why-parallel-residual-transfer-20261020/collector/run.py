"""Five serial prefix-only cases; abort at first failed case, preserve evidence."""
from pathlib import Path
import json,hashlib,subprocess,os,signal,time,re,atexit
import sys
ROOT=Path(sys.argv[1]).resolve();PLAN=json.loads((ROOT/'plan.json').read_text());CODE=Path(PLAN['collector_root'])
def identity(p):
 b=Path(p).read_bytes();return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
assert all(identity(p)==m for p,m in PLAN['file_identities'].items())
def check_driver_resolution():
 installed=Path(PLAN['installed_driver_directory'])
 expected=json.loads((ROOT/'driver-resolution.json').read_text())
 for path,row in expected.items():
  path=Path(path);assert identity(path)==row['identity']
  imports=[]
  for name in re.findall(r'^import "([^"]+)"',path.read_text(),re.M):
   dirs=[path.parent] if path.parent==installed else [path.parent,installed]
   matches=[str(d/name) for d in dirs if (d/name).is_file()]
   assert len(matches)==1, (str(path),name,matches)
   imports.append({'name':name,'candidates':matches})
  assert imports==row['imports']
check_driver_resolution()
for case in PLAN['inputs']:
 assert sorted(p.name for p in Path(case['cwd']).iterdir())==sorted([case['argv'][-1],'why3.conf','temp'])
 assert not list((Path(case['cwd'])/'temp').iterdir())
gdbroot=Path(PLAN['gdbroot']);results=[]
servers=[]
def clean_servers():
 for child in servers:
  if child.poll() is None:
   child.terminate()
   try:child.wait(timeout=5)
   except subprocess.TimeoutExpired:child.kill();child.wait()
atexit.register(clean_servers)
for i,case in enumerate(PLAN['inputs']):
 out=Path(case['cwd'])/'capture';out.mkdir(exist_ok=False)
 server_spec=case['server'];server_log=open(out/'server.log','wb')
 server=subprocess.Popen(server_spec['argv'],cwd=server_spec['cwd'],env=server_spec['environment'],stdout=server_log,stderr=subprocess.STDOUT,start_new_session=True)
 servers.append(server)
 server_start=time.monotonic();server_proc=Path('/proc')/str(server.pid)
 server_identity={'pid':server.pid,'argv':server_spec['argv'],'environment':server_spec['environment'],'binary':identity(server_spec['argv'][0])}
 try:
  for wait_index in range(200):
   if Path(server_spec['socket']).is_socket():break
   assert server.poll() is None,'server exited before listening'
   time.sleep(0.01)
  else:raise RuntimeError('server did not create socket')
  server_identity['actual_argv']=[x.decode() for x in (server_proc/'cmdline').read_bytes().split(b'\0') if x]
  server_identity['actual_environment']=dict(x.decode().split('=',1) for x in (server_proc/'environ').read_bytes().split(b'\0') if x)
  assert server_identity['actual_argv']==server_spec['argv']
  assert server_identity['actual_environment']==server_spec['environment']
  assert server_identity['binary']==PLAN['server_identity']
 except BaseException:
  server.terminate();server.wait(timeout=10);server_log.close();raise
 script='''set pagination off
set confirm off
set auto-load off
set debuginfod enabled off
set startup-with-shell off
set disable-randomization off
set breakpoint always-inserted on
set language c
python
import gdb,json
root='CAPTURE_ROOT_VALUE'
COLLECTOR_ROOT='COLLECTOR_ROOT_VALUE'
CAPTURE_ROOT=root
plan=json.load(open(root+'/plan.json'))
CASE_INDEX=INDEX
case=plan['inputs'][CASE_INDEX]
gdb.execute('unset environment')
for k,v in case['environment'].items():gdb.execute('set environment '+k+'='+v)
end
starti
python
exec(open(COLLECTOR_ROOT+'/probe.py').read())
end
continue
python
finish_capture()
end
kill
quit
'''.replace('CASE_INDEX=INDEX','CASE_INDEX='+str(i)).replace('CAPTURE_ROOT_VALUE',str(ROOT)).replace('COLLECTOR_ROOT_VALUE',str(CODE))
 (out/'probe.gdb').write_text(script)
 env={'PATH':'/usr/bin:/bin','LC_ALL':'C','LD_LIBRARY_PATH':str(gdbroot/'usr/lib/x86_64-linux-gnu'),'DEBUGINFOD_URLS':''}
 cmd=[str(gdbroot/'usr/bin/gdb'),'-nx','-q','-batch','-x',str(out/'probe.gdb'),'--args',*case['argv']]
 start=time.monotonic();p=subprocess.Popen(cmd,cwd=case['cwd'],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 timed_out=False
 try:log,_=p.communicate(timeout=600)
 except subprocess.TimeoutExpired:
  timed_out=True;os.killpg(p.pid,signal.SIGTERM);log,_=p.communicate(timeout=10)
 debugger_seconds=time.monotonic()-start
 (out/'debugger.log').write_text(log)
 server_identity['forced_cleanup']=False
 try:server.wait(timeout=5)
 except subprocess.TimeoutExpired:
  server_identity['forced_cleanup']=True;server.terminate();server.wait(timeout=10)
 server_identity['returncode']=server.returncode;server_identity['duration_seconds']=time.monotonic()-server_start
 server_log.close();(out/'server.json').write_text(json.dumps(server_identity,indent=2)+'\n')
 summary=json.loads((out/'summary.json').read_text()) if (out/'summary.json').exists() else {}
 result={'name':case['name'],'command':cmd,'debugger_environment':env,'duration_seconds':debugger_seconds,'returncode':p.returncode,'timed_out':timed_out,'completed':summary.get('completed',False),'failures':summary.get('failures',['missing summary']),'guard_hits':summary.get('guard_hits',[])}
 (out/'result.json').write_text(json.dumps(result,indent=2)+'\n');results.append(result)
 (ROOT/'result.json').write_text(json.dumps({'cases':results},indent=2)+'\n')
 print(json.dumps(result),flush=True)
 if p.returncode or timed_out or not result['completed'] or result['failures']:
  print(log,flush=True);raise SystemExit(1)
assert all(identity(p)==m for p,m in PLAN['file_identities'].items())
check_driver_resolution()
print('R53 selected registration metadata capture completed; client/server J12, no solver scheduling/preparation, inputs unchanged.',flush=True)
