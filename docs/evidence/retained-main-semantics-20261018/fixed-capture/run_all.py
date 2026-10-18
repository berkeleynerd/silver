from pathlib import Path
import json,os,subprocess,time,signal,hashlib
root=Path(__file__).parent;dest=root/'all-miss';plan=json.loads((dest/'invocation.json').read_text())
gdbroot=Path('/tmp/silver-capacity-debugger-20261018/root');gdb=gdbroot/'usr/bin/gdb'
script='''set pagination off
set breakpoint always-inserted on
set confirm off
set auto-load off
set debuginfod enabled off
set startup-with-shell off
set disable-randomization off
unset environment LD_LIBRARY_PATH
set language c
starti
python
exec(open('/tmp/silver-frontend-fixed-counter-20261018/counter-all.py').read())
end
continue
python
final()
end
quit
'''
(dest/'probe.gdb').write_text(script);env=dict(os.environ);env.update(plan['environment']);env['LD_LIBRARY_PATH']=str(gdbroot/'usr/lib/x86_64-linux-gnu');env['DEBUGINFOD_URLS']=''
cmd=[str(gdb),'-nx','-q','-batch','-x',str(dest/'probe.gdb'),'--args',*plan['argv']]
start=time.monotonic();p=subprocess.Popen(cmd,cwd=plan['cwd'],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
try:out,_=p.communicate(timeout=180)
except subprocess.TimeoutExpired:
 os.killpg(p.pid,signal.SIGTERM);out,_=p.communicate();(dest/'probe.log').write_text(out);raise SystemExit('timeout; log retained')
(dest/'probe.log').write_text(out)
result=dict(command=cmd,elapsed_seconds=time.monotonic()-start,returncode=p.returncode,producer_sha256=hashlib.sha256(Path(plan['argv'][0]).read_bytes()).hexdigest(),scope='all frontend table logical writes; scratch-only range-cache invalidation with returned-value coherence audit; no solver')
(dest/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));print('\n'.join(l for l in out.splitlines() if l.startswith('POOL_')))
if p.returncode or not (dest/'pool-counters.json').exists():print(out);raise SystemExit(1)
x=json.loads((dest/'pool-counters.json').read_text())
if x['coherence_failures'] or len(x['queries'])!=len(x['returns']) or x['unexpected_collect'] or x['phases'][-1]['phase']!='before_symbol_free':print(out);raise SystemExit(2)
