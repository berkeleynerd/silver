import os, resource, subprocess, sys, time
# usage: runlean.py <timeout_s> <lean_file> <out_file> <stats_file>
timeout_s, lean_file, out_file, stats_file = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
env = dict(os.environ)
env['LEAN_PATH'] = '/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/lean-frozen/lib/lean:/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/lean/lib/lean'
lean = '/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/lean/bin/lean'
t0 = time.time()
with open(out_file, 'w') as out:
    p = subprocess.Popen([lean, lean_file], stdout=out, stderr=subprocess.STDOUT, env=env, cwd=os.path.dirname(lean_file))
    with open(stats_file, 'w') as st:
        st.write(f'pid {p.pid}\n')
    try:
        rc = p.wait(timeout=timeout_s)
    except subprocess.TimeoutExpired:
        p.kill(); rc = 'timeout'; p.wait()
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
with open(stats_file, 'a') as st:
    st.write(f'rc {rc}\nwall {time.time()-t0:.1f}\nmaxrss_kib {ru.ru_maxrss}\nuser {ru.ru_utime:.1f}\n')
