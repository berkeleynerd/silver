from pathlib import Path
import datetime,json,os,re,subprocess,sys,time
root=Path(__file__).resolve().parents[1]
cpus={8,9,10,11}
assert cpus <= os.sched_getaffinity(0)
cases=[('lean-source',['-p','test_lean_source.py']),('platforms',['-p','test_platforms.py']),('output-integrity',['-p','test_output_integrity.py']),('silver-tool-failures',['-p','test_silver.py','-k','test_tool_failures_and_source_changes_do_not_report_success'])]
records=[]
def descendants(pid):
    result=[];todo=[pid]
    while todo:
        parent=todo.pop()
        try: children=[int(x) for x in Path(f'/proc/{parent}/task/{parent}/children').read_text().split()]
        except (FileNotFoundError,ProcessLookupError):continue
        result.extend(children);todo.extend(children)
    return result
for label,extra in cases:
    command=[sys.executable,'scripts/dev.py','test','--task','#286-repair-regression','--jobs','4','--',*extra]
    log=root/'tmp'/f'repair-{label}.console.log'
    entry={'label':label,'command':command,'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'cpus':sorted(cpus),'runner_affinity':None,'unittest_pid':None,'affinity_observations':[]}
    started=time.monotonic();reported=False;seen=set()
    with log.open('w') as out:
        process=subprocess.Popen(command,cwd=root,stdout=out,stderr=subprocess.STDOUT)
        entry['runner_pid']=process.pid
        entry['runner_affinity']=sorted(os.sched_getaffinity(process.pid))
        print(f'Started {label}: runner {process.pid}, console {log}',flush=True)
        while process.poll() is None:
            candidates=descendants(process.pid)
            if entry['unittest_pid'] is None:
                for pid in candidates:
                    try:args=Path(f'/proc/{pid}/cmdline').read_bytes().split(b'\0')
                    except FileNotFoundError:continue
                    if b'unittest' in args and b'discover' in args:
                        entry['unittest_pid']=pid
                        os.sched_setaffinity(pid,cpus)
                        seen.add(pid)
                        entry['affinity_observations'].append({'pid':pid,'cpus':sorted(os.sched_getaffinity(pid)),'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()})
                        print(f'{label}: unittest {pid} restricted to {sorted(cpus)}; managed runner remains {entry["runner_affinity"]}',flush=True)
                        break
            if entry['unittest_pid'] is not None:
                for pid in descendants(entry['unittest_pid']):
                    if pid in seen:continue
                    try:
                        inherited=sorted(os.sched_getaffinity(pid))
                        os.sched_setaffinity(pid,cpus)
                        entry['affinity_observations'].append({'pid':pid,'inherited_cpus':inherited,'cpus':sorted(os.sched_getaffinity(pid)),'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()})
                        seen.add(pid)
                    except (ProcessLookupError,FileNotFoundError):pass
            if not reported:
                found=re.search(r'Managed run: (\S+)',log.read_text(errors='replace'))
                if found:entry['run_id']=found.group(1);reported=True;print(f'{label}: managed run {entry["run_id"]}',flush=True)
            time.sleep(.02)
    entry['returncode']=process.returncode;entry['elapsed_seconds']=time.monotonic()-started
    entry['finished_at']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    records.append(entry)
    (root/'tmp/repair-regression-affinity.json').write_text(json.dumps(records,indent=2)+'\n')
    print(f'Finished {label}: exit {process.returncode}, {entry["elapsed_seconds"]:.3f}s',flush=True)
    if process.returncode:
        print(log.read_text(errors='replace')[-10000:],flush=True);sys.exit(process.returncode)
    assert entry['unittest_pid'] is not None,'No unittest affinity applied'
