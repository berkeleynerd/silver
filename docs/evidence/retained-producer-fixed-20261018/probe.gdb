set pagination off
set python print-stack full
set confirm off
set auto-load off
set debuginfod enabled off
set startup-with-shell off
set disable-randomization off
unset environment LD_LIBRARY_PATH
set language c
python
import gdb, json
exec(open('/tmp/silver-producer-counter-plan-20261018/raw_snapshot_v2.py').read())
snapshots = []
def record(phase):
    row = raw_snapshot(phase, graph=True)
    with open('/tmp/silver-producer-counter-plan-20261018/graph-' + phase + '.json', 'w') as out:
        json.dump(row, out, sort_keys=True)
    row = {k:v for k,v in row.items() if k not in ('graph', 'layout', 'theory_roots', 'theory_occurrences', 'node_kind_counts')}
    snapshots.append(row)
    print('CAPACITY_SNAPSHOT ' + json.dumps(row, sort_keys=True))
class CounterBreakpoint(gdb.Breakpoint):
    def __init__(self, spec, phase, stop):
        super().__init__(spec, internal=True)
        self.phase, self.halt = phase, stop
    def stop(self):
        record(self.phase)
        return self.halt
CounterBreakpoint('gnat2why__driver__translate_standard_package', 'before_standard', False)
CounterBreakpoint('gnat2why__driver__translate_cunit', 'after_standard', False)
CounterBreakpoint('why__atree__free', 'before_free', True)
CounterBreakpoint('gnat2why-driver.adb:604', 'before_backend', True)
end
run
python
print('CAPACITY_FINAL ' + json.dumps(snapshots, sort_keys=True))
end
quit
