set pagination off
set confirm off
set auto-load off
set debuginfod enabled off
set startup-with-shell off
set disable-randomization off
set breakpoint always-inserted on
set follow-fork-mode child
set detach-on-fork on
set language c
python
import gdb,json
plan=json.load(open('/tmp/silver-producer-gcc-prefix-20261018/invocation.json'))
gdb.execute('unset environment')
for key,value in plan['environment'].items():
    gdb.execute('set environment '+key+'='+value)
end
catch exec
run
python
exec(open('/tmp/silver-producer-gcc-prefix-20261018/counters.py').read())
end
continue
python
finish_capture()
end
quit
