from pathlib import Path
import argparse,datetime,json,os,signal,subprocess,time
p=argparse.ArgumentParser();p.add_argument('--max-tree-rss-kib',type=int);p.add_argument('--stop-on-log-pattern',action='append',default=[]);p.add_argument('directory');p.add_argument('command',nargs=argparse.REMAINDER);a=p.parse_args()
d=Path(a.directory);d.mkdir(parents=True,exist_ok=True)
command=a.command[1:] if a.command and a.command[0]=='--' else a.command
start=time.monotonic();summary={'command':command,'cwd':str(Path.cwd()),'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'peak_sum_rss_kib':0,'peak_process_rss_kib':0,'minimum_mem_available_kib':2**63,'minimum_disk_available_bytes':2**63}
with (d/'launcher.log').open('w') as log,(d/'resources.jsonl').open('w') as resources:
 child=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
 summary['pid']=child.pid;(d/'launcher.json').write_text(json.dumps(summary,indent=2)+'\n')
 interrupted=False
 try:
  while True:
   rows=[]
   for proc in Path('/proc').iterdir():
    if not proc.name.isdigit():continue
    try:
     fields=(proc/'stat').read_text().split();status=dict(line.split(':',1) for line in (proc/'status').read_text().splitlines() if ':' in line)
     if int(fields[5])!=child.pid:continue
     rss=int(status.get('VmRSS','0 kB').split()[0]);cmd=(proc/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
     rows.append({'pid':int(proc.name),'rss_kib':rss,'command':cmd})
    except (OSError,ValueError,IndexError):continue
   mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines());available=int(mem['MemAvailable'].split()[0]);total=sum(r['rss_kib'] for r in rows)
   disk=os.statvfs(Path.cwd()/'.silver/linux-aarch64/proof');disk_available=disk.f_bavail*disk.f_frsize
   sample={'elapsed_seconds':time.monotonic()-start,'sum_rss_kib':total,'mem_available_kib':available,'disk_available_bytes':disk_available,'disk_total_bytes':disk.f_blocks*disk.f_frsize,'processes':rows}
   resources.write(json.dumps(sample)+'\n');resources.flush()
   summary['peak_sum_rss_kib']=max(summary['peak_sum_rss_kib'],total);summary['peak_process_rss_kib']=max(summary['peak_process_rss_kib'],max([r['rss_kib'] for r in rows],default=0));summary['minimum_mem_available_kib']=min(summary['minimum_mem_available_kib'],available);summary['minimum_disk_available_bytes']=min(summary['minimum_disk_available_bytes'],disk_available)
   result=child.poll()
   if result is not None:break
   if a.stop_on_log_pattern and not interrupted:
    output=(d/'launcher.log').read_text(errors='replace')
    matched=next((pattern for pattern in a.stop_on_log_pattern if pattern in output),None)
    if matched is not None:
     interrupted=True;summary['diagnostic_interruption']={'pattern':matched,'sample':sample};os.killpg(child.pid,signal.SIGINT)
   if (available<1572864 or a.max_tree_rss_kib is not None and total>a.max_tree_rss_kib) and not interrupted:
    interrupted=True;summary['resource_interruption']=sample;os.killpg(child.pid,signal.SIGINT)
   time.sleep(5)
 except KeyboardInterrupt:
  interrupted=True;os.killpg(child.pid,signal.SIGINT);result=child.wait()
 summary.update(returncode=result,elapsed_seconds=time.monotonic()-start,finished_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),interrupted=interrupted)
 (d/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2),flush=True)
raise SystemExit(result)
