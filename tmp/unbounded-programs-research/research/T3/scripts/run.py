import sys, subprocess, time, resource, os
# usage: run.py OUTFILE cmd...
out=sys.argv[1]; cmd=sys.argv[2:]
t=time.time()
with open(out,'w') as f:
    p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT)
    with open(os.path.join(os.path.dirname(out) or '.','pids.txt'),'a') as pf: pf.write(f"{p.pid} {' '.join(cmd)[:200]}\n")
    rc=p.wait()
w=time.time()-t
r=resource.getrusage(resource.RUSAGE_CHILDREN)
txt=open(out,errors='replace').read().splitlines()
print(f"rc={rc} wall={w:.2f}s maxrss={r.ru_maxrss/1024:.1f}MB | "+" | ".join(txt[:3])[:400])
