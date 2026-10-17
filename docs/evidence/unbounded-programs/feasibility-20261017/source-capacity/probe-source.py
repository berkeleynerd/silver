#!/usr/bin/env python3
"""Bounded frontend accounting probes; no proof run or backend invocation."""
from pathlib import Path
import hashlib, json, os, platform, re, shutil, signal, subprocess, time

ROOT = Path('/tmp/silver-unbounded-feasibility-20261017/source-capacity')
REPO = Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/unbounded-planning-corrections')
GCC = Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/.tools/macos-aarch64/alire/toolchains/gnat_native_16.1.0_657cf254/bin/gcc')
LIBS = ['silver_io.ads','silver_io.adb','silver_output_libc.ads','silver_arguments.ads','silver_arguments.adb','silver_runtime.ads']
MAX_KIB = 512 * 1024
MAX_SECONDS = 30

def processes():
    r = subprocess.run(['/bin/ps','-axo','pid=,pgid=,rss='], capture_output=True, text=True, check=True)
    return [tuple(map(int,line.split())) for line in r.stdout.splitlines() if line.strip()]

def host_memory():
    r = subprocess.run(['/usr/bin/vm_stat'], capture_output=True, text=True, check=True)
    page = int(re.search(r'page size of (\d+) bytes', r.stdout).group(1))
    counts = {k:int(v) for k,v in re.findall(r'^(.*?):\s+(\d+)\.', r.stdout, re.M)}
    # Free+inactive+speculative is only a guard estimate, not an OS guarantee.
    estimate = page * sum(counts.get(k,0) for k in ['Pages free','Pages inactive','Pages speculative'])
    return {'estimate_bytes':estimate,'raw':r.stdout}

# Abort before any compiler process if observation is unavailable.
processes()
mem = host_memory()
if mem['estimate_bytes'] < 2 * 1024**3:
    raise SystemExit('Host headroom estimate below2GiB: no compiler launched')
ROOT.mkdir(parents=True, exist_ok=True)
(ROOT/'host-preflight.json').write_text(json.dumps({'platform':platform.platform(),'memory':mem,'gcc':str(GCC),'guards':{'aggregate_process_rss_kib':MAX_KIB,'wall_seconds':MAX_SECONDS}},indent=2)+'\n')
(ROOT/'gcc-version.txt').write_text(subprocess.run([str(GCC),'-v'],capture_output=True,text=True,check=True).stderr)

null = 'procedure Main is\n pragma SPARK_Mode (On);\nbegin\n null;\nend Main;\n'
static = 'with Silver_IO;\nprocedure Main is\n pragma SPARK_Mode (On);\n S : String := "hello";\nbegin\n Silver_IO.Put_Line (S);\nend Main;\n'
argument = 'with Silver_IO, Silver_Arguments;\nprocedure Main is\n pragma SPARK_Mode (On);\n D : constant String := Silver_Arguments.First_Or_Default ("x");\nbegin\n if Silver_Arguments.Input_Is_Valid then\n Silver_IO.Put_Line (D);\n else\n Silver_Arguments.Reject;\n end if;\nend Main;\n'
mixed = '''with Silver_IO; use Silver_IO;
with Silver_IO;
procedure Main is
 pragma SPARK_Mode (On);
 K : constant Integer := 2;
 N : Integer range 0 .. 10 := 1;
 S : String := "ab";
 T : constant String := S;
begin
 for I in 1 .. 2 loop
  if (N <= 9 and then S = "ab") or else not (S /= T) then
   N := (K * I);
   S := "cd";
   Put (Item => Integer'Image ((I + K)));
  elsif N = 10 then
   Put_Line (S & T);
  else
   null;
  end if;
  for J in reverse 1 .. I loop
   Put_Line (Integer'Image ((-J)));
  end loop;
 end loop;
end Main;
'''
def pad_comments(source, total):
    remaining=total-len(source)
    chunks=[]
    while remaining:
        if remaining<3: chunk=' '*remaining
        else: chunk='--'+'x'*(min(remaining,1000)-3)+'\n'
        chunks.append(chunk);remaining-=len(chunk)
    return source+''.join(chunks)

dense='with Silver_IO;\nprocedure Main is\n pragma SPARK_Mode (On);\nbegin\n'
tail='end Main;\n'
dense += ' null;\n'*((65536-len(dense)-len(tail))//7)+tail
dense=pad_comments(dense,65536)
blank=null+'\n'*(65536-len(null))
fold='with Silver_IO;\nprocedure Main is\n pragma SPARK_Mode (On);\n A0 : constant String := "x";\n'
for i in range(1,17): fold+=f' A{i} : constant String := A{i-1} & A{i-1};\n'
fold+='begin\n Silver_IO.Put_Line (A16);\nend Main;\n'
cases=[('null',null,False),('static',static,False),('argument',argument,False),('mixed',mixed,False),('sparse64k',pad_comments(static,65536),False),('dense64k',dense,False),('blank64k',blank,False),('fold64k_value',fold,False),('mixed_expanded',mixed,True)]
records=[]
for name,source,expand in cases:
    d=ROOT/'probes'/name
    if d.exists():raise SystemExit(f'Refusing to overwrite existing probe {d}')
    d.mkdir(parents=True)
    (d/'main.adb').write_text(source)
    assert len(source.encode())<=65536
    for unit in LIBS:shutil.copyfile(REPO/'src'/unit,d/unit)
    argv=[str(GCC),'-c','-gnatc','-gnat2022','-gnata','-gnato','-gnatdl','-gnatdd']
    if expand:argv+=['-gnatdx']
    argv+=['main.adb']
    record={'name':name,'argv':argv,'cwd':str(d),'source_bytes':len(source.encode()),'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'expanded':expand,'inputs':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in d.iterdir()}}
    (d/'command.json').write_text(json.dumps(record,indent=2)+'\n')
    start=time.monotonic();peak=0;guard=None
    with (d/'stdout.txt').open('wb') as out,(d/'stderr.txt').open('wb') as err:
        p=subprocess.Popen(argv,cwd=d,stdout=out,stderr=err,start_new_session=True)
        while p.poll() is None:
            rows=processes();rss=sum(r for pid,pgid,r in rows if pgid==p.pid);peak=max(peak,rss)
            if rss>MAX_KIB:guard='aggregate_rss_guard'
            if time.monotonic()-start>MAX_SECONDS:guard='wall_guard'
            if guard:
                os.killpg(p.pid,signal.SIGTERM)
                try:p.wait(timeout=2)
                except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);p.wait()
                break
            time.sleep(.025)
        record.update(exit_status=p.wait(),wall_seconds=time.monotonic()-start,peak_sampled_process_group_rss_kib=peak,guard_stop=guard)
    records.append(record)
    (ROOT/'probe-results.json').write_text(json.dumps(records,indent=2)+'\n')
    print(json.dumps({k:record[k] for k in ['name','exit_status','wall_seconds','peak_sampled_process_group_rss_kib','guard_stop']}),flush=True)
    if guard:break
