set pagination off
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
