import os,sys,json,time,shutil,signal,subprocess,hashlib
S='/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T4'
SRC='/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/program-jjR2SY'
ROOT='/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64'
ALIRE_EXEC="cd /home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/toolchain && unset ALR_CONFIG GPR_CONFIG GPR_PROJECT_PATH GPR_PROJECT_PATH_FILE ADA_PROJECT_PATH && ALIRE_SETTINGS_DIR=/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/settings /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alr/bin/alr -n exec -- "
GP='/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/image-tools/bin/gnatprove'
FILES=['program.gpr','silver_io.ads','silver_io.adb','silver_output_libc.ads','silver_arguments.ads','silver_arguments.adb','silver_runtime.ads']
HEAVY=('gnatprove','gnat2why','gnatwhy3','why3server','cvc5','z3','alt-ergo','altergo','lean','lake')
def meminfo():
    d={}
    for l in open('/proc/meminfo'):
        k,v=l.split(':');d[k]=int(v.split()[0])*1024
    return d
def procs():
    out={}
    for p in os.listdir('/proc'):
        if not p.isdigit():continue
        try:
            st=open(f'/proc/{p}/stat').read()
            r=st.rindex(')');comm=st[st.index('(')+1:r];f=st[r+2:].split()
            ppid=int(f[1]);pgid=int(f[2]);rss=int(f[21])*4096
            out[int(p)]=(ppid,pgid,rss,comm)
        except Exception:pass
    return out
def cmdline(pid):
    try:return open(f'/proc/{pid}/cmdline','rb').read().replace(b'\0',b' ').decode(errors='replace')
    except Exception:return ''
def foreign_heavy(mine):
    res=[]
    for pid,(pp,pg,rss,comm) in procs().items():
        if pid in mine:continue
        if any(h in comm.lower() for h in HEAVY):
            c=cmdline(pid)
            if S in c:continue
            res.append((pid,comm,rss,c[:200]))
    return res
def tree(root_pgid,root_pid,ps):
    mine={pid for pid,v in ps.items() if v[1]==root_pgid}
    ch=True
    while ch:
        ch=False
        for pid,v in ps.items():
            if pid not in mine and v[0] in mine:
                mine.add(pid);ch=True
    return mine
def main():
    name=sys.argv[1];srcfile=sys.argv[2];steps=sys.argv[3];mem=sys.argv[4];cap=float(sys.argv[5]) if len(sys.argv)>5 else 4500
    guard=float(sys.argv[6]) if len(sys.argv)>6 and sys.argv[6] else 24.0
    proj=f'{S}/proj-{name}'
    if os.path.exists(proj):raise SystemExit('exists '+proj)
    os.makedirs(proj)
    for f in FILES:shutil.copy2(f'{SRC}/{f}',f'{proj}/{f}')
    shutil.copy2(srcfile,f'{proj}/main.adb')
    src=open(f'{proj}/main.adb','rb').read()
    cmd=ALIRE_EXEC+GP+f' -P {proj}/program.gpr -U --mode=all --report=all --warnings=continue --checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps={steps} --timeout=0 --memlimit={mem} -j8 --no-loop-unrolling'
    before=set(x for x in os.listdir(ROOT) if x.startswith('imagews-'))
    mi=meminfo()
    pre={'mem_available_gb':round(mi['MemAvailable']/2**30,2),'foreign_heavy':foreign_heavy(set())}
    log=open(f'{proj}/proof.log','wb')
    t0=time.time()
    p=subprocess.Popen(['bash','-c',cmd],stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
    open(f'{S}/pids.log','a').write(f'{time.strftime("%Y-%m-%dT%H:%M:%S")} {name} pid={p.pid} pgid={p.pid}\n')
    peak=0;peak_proc={};why3cmd={};minavail=mi['MemAvailable'];samples=[];stopped=None;maxprocs=0;seen=set()
    while True:
        rc=p.poll()
        if rc is not None:break
        ps=procs();mine=tree(p.pid,p.pid,ps)
        tot=sum(ps[x][2] for x in mine if x in ps);maxprocs=max(maxprocs,len(mine))
        for x in mine:
            if x in ps:
                c=ps[x][3];peak_proc[c]=max(peak_proc.get(c,0),ps[x][2]);seen.add(x)
                if c in ('gnatwhy3','cvc5','z3','alt-ergo') and c not in why3cmd: why3cmd[c]=cmdline(x)[:1500]
        peak=max(peak,tot)
        av=meminfo()['MemAvailable'];minavail=min(minavail,av)
        el=time.time()-t0
        if int(el)%10==0:samples.append((round(el),tot,av))
        if el>cap:stopped='wall_cap';break
        if av<3*2**30:stopped='memory_guard_available_below_3GiB';break
        if tot>guard*2**30:stopped=f'memory_guard_tree_above_{guard}GiB';break
        time.sleep(1)
    if stopped:
        try:os.killpg(p.pid,signal.SIGTERM)
        except Exception:pass
        time.sleep(5)
        ps=procs()
        for x in tree(p.pid,p.pid,ps)|{q for q in seen if q in ps}:
            if S in cmdline(x) or x in seen:
                try:os.kill(x,signal.SIGKILL)
                except Exception:pass
        try:os.killpg(p.pid,signal.SIGKILL)
        except Exception:pass
        rc=p.wait()
    el=time.time()-t0
    after=set(x for x in os.listdir(ROOT) if x.startswith('imagews-'))
    res={'name':name,'source':srcfile,'source_bytes':len(src),'lines':src.count(b'\n'),'statements':src.count(b';'),'steps':steps,'memlimit':mem,'command':cmd,'exit':rc,'stopped':stopped,'wall_s':round(el,1),
         'peak_tree_rss_bytes':peak,'peak_tree_rss_gib':round(peak/2**30,2),'peak_by_comm':{k:round(v/2**30,3) for k,v in sorted(peak_proc.items(),key=lambda kv:-kv[1])[:8]},'max_procs':maxprocs,'min_mem_available_gib':round(minavail/2**30,2),
         'pre':pre,'imagews_created':sorted(after-before),'imagews_removed':sorted(before-after),'samples':samples,'tool_cmdlines':why3cmd}
    rep=f'{proj}/obj/gnatprove/main.spark'
    if os.path.exists(rep):
        sys.path.insert(0,f'{S}/tools');import analyze
        res['report_bytes']=os.path.getsize(rep);res['report']=analyze.summary(rep)
    json.dump(res,open(f'{proj}/result.json','w'),indent=1,default=str)
    short={k:res.get(k) for k in ('name','source_bytes','statements','steps','memlimit','exit','stopped','wall_s','peak_tree_rss_gib','peak_by_comm','report_bytes','imagews_created')}
    if 'report' in res:
        r=res['report'];short.update(checks=r['checks'],flow=r['flow'],severity=r['severity'],unproved=r['unproved'][:5],win_steps=r['win_steps'],attempt_time=r['attempt_time'],quart=r['by_position_quartile'])
    print(json.dumps(short,default=str))
    open(f'{S}/results.jsonl','a').write(json.dumps(short,default=str)+'\n')
main()
