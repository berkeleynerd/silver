#!/usr/bin/env python3
"""Run a command under an optional stack limit; report exit, wall, maxrss of child."""
import json, os, resource, subprocess, sys, time

def run(cmd, stack_kib=None, timeout=600):
    def pre():
        if stack_kib is not None:
            resource.setrlimit(resource.RLIMIT_STACK, (stack_kib * 1024, stack_kib * 1024))
    t0 = time.monotonic()
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, preexec_fn=pre)
    try:
        out, _ = p.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        p.kill(); out, _ = p.communicate(); rc = 'timeout'
    else:
        rc = p.returncode
    wall = time.monotonic() - t0
    # wait4 rusage of this child
    return rc, wall, out.decode(errors='replace')

def run_rusage(cmd, stack_kib=None, timeout=600):
    def pre():
        if stack_kib is not None:
            resource.setrlimit(resource.RLIMIT_STACK, (stack_kib * 1024, stack_kib * 1024))
    t0 = time.monotonic()
    pid = os.fork()
    if pid == 0:
        pre()
        devnull = os.open('/dev/null', os.O_WRONLY)
        outfd = os.open(os.environ.get('RUN_OUT', '/dev/null'), os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
        os.dup2(outfd, 1); os.dup2(outfd, 2)
        os.execv(cmd[0], cmd)
    _, status, ru = os.wait4(pid, 0)
    wall = time.monotonic() - t0
    rc = os.waitstatus_to_exitcode(status)
    return rc, wall, ru.ru_maxrss, ru.ru_utime + ru.ru_stime

if __name__ == '__main__':
    stack = int(sys.argv[1]) if sys.argv[1] != '-' else None
    rc, wall, rss, cpu = run_rusage(sys.argv[2:], stack)
    print(json.dumps({'rc': rc, 'wall': round(wall, 4), 'cpu': round(cpu, 4), 'maxrss_kib': rss}))
