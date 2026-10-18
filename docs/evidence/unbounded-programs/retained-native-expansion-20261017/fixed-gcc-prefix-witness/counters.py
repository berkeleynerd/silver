"""GDB script: observe installed gnat1 from exec to the pre-Main boundary."""
import gdb
import hashlib
import json
from pathlib import Path

ROOT = Path('/tmp/silver-native-gcc-prefix-20261018')
CAPTURE = ROOT / 'capture'
PLAN = json.loads((ROOT / 'invocation.json').read_text())
inferior = gdb.selected_inferior()
proc = Path('/proc') / str(inferior.pid)
executable = (proc / 'exe').resolve()
assert str(executable) == PLAN['gnat1']
assert hashlib.sha256(executable.read_bytes()).hexdigest() == PLAN['gnat1_sha256']
frontend_environment = dict(item.decode().split('=', 1) for item in
                            (proc / 'environ').read_bytes().split(b'\0') if item)
frontend_argv = [item.decode() for item in (proc / 'cmdline').read_bytes().split(b'\0') if item]
assert all(frontend_environment.get(k) == v for k, v in PLAN['environment'].items())
assert 'LD_LIBRARY_PATH' not in frontend_environment
assert len(inferior.threads()) == 1
(CAPTURE / 'frontend-exec.json').write_text(json.dumps({
    'executable': str(executable), 'environment': frontend_environment,
    'argv': frontend_argv, 'pc': hex(int(gdb.parse_and_eval('$pc'))),
    'threads': len(inferior.threads()), 'pid': inferior.pid,
}, indent=2) + '\n')

SPECS = {
    'ggc_bytes': {'address': 0x3d1a868, 'width': 8, 'signed': False, 'initial': 0},
    'decl_uid': {'address': 0x3d2354c, 'width': 4, 'signed': True, 'initial': 0},
    'type_uid': {'address': 0x3619d30, 'width': 4, 'signed': False, 'initial': 1},
    'debug_decl_uid': {'address': 0x3d23548, 'width': 4, 'signed': True, 'initial': 0},
}
events = (CAPTURE / 'counter-events.jsonl').open('w', buffering=1)
summary = {'specs': SPECS, 'phases': [], 'counters': {}, 'failures': [],
           'unexpected_collections': [], 'new_threads': [], 'completed': False}

def read(name):
    spec = SPECS[name]
    return int.from_bytes(bytes(inferior.read_memory(spec['address'], spec['width'])),
                          'little', signed=spec['signed'])

for name, spec in SPECS.items():
    value = read(name)
    assert value == spec['initial'], (name, value)
    summary['counters'][name] = {'initial': value, 'current': value, 'peak': value,
                               'minimum': value, 'events': 0, 'positive_sum': 0,
                               'negative_sum': 0, 'positive_events': 0,
                               'negative_events': 0, 'largest_increment': 0}

def save():
    (CAPTURE / 'counter-summary.json').write_text(json.dumps(summary, indent=2) + '\n')

def snapshot(label):
    summary['phases'].append({'phase': label, 'pc': hex(int(gdb.parse_and_eval('$pc'))),
                             'values': {name: read(name) for name in SPECS},
                             'events': {name: data['events'] for name, data in summary['counters'].items()},
                             'threads': len(inferior.threads())})
    save()
    print('PREFIX_PHASE ' + json.dumps(summary['phases'][-1]), flush=True)

class WriteWatch(gdb.Breakpoint):
    def __init__(self, name):
        self.name = name
        spec = SPECS[name]
        typ = ('long long' if spec['width'] == 8 else 'int')
        if not spec['signed']:
            typ = 'unsigned ' + typ
        super().__init__('*(%s *)%s' % (typ, hex(spec['address'])),
                         type=gdb.BP_WATCHPOINT, wp_class=gdb.WP_WRITE)
        self.silent = True

    def stop(self):
        name = self.name
        data = summary['counters'][name]
        current = read(name)
        prior = data['current']
        delta = current - prior
        pc = hex(int(gdb.parse_and_eval('$pc')))
        events.write(json.dumps({'counter': name, 'old': prior, 'new': current,
                                 'delta': delta, 'pc': pc}) + '\n')
        data['current'] = current
        data['events'] += 1
        data['peak'] = max(data['peak'], current)
        data['minimum'] = min(data['minimum'], current)
        data['positive_sum'] += max(delta, 0)
        data['negative_sum'] += max(-delta, 0)
        data['positive_events'] += int(delta > 0)
        data['negative_events'] += int(delta < 0)
        data['largest_increment'] = max(data['largest_increment'], delta)
        valid = ((name == 'ggc_bytes' and delta > 0) or
                 (name == 'decl_uid' and delta == 1 and current >= 0) or
                 (name == 'type_uid' and delta in (1, -1) and current >= 1) or
                 (name == 'debug_decl_uid' and delta == -1 and current < 0))
        if not valid:
            summary['failures'].append({'counter': name, 'old': prior, 'new': current, 'pc': pc})
            save()
            return True
        return False

class Phase(gdb.Breakpoint):
    def __init__(self, label, address, final=False):
        super().__init__('*' + hex(address))
        self.label, self.final = label, final
        self.silent = True

    def stop(self):
        snapshot(self.label)
        if self.final:
            summary['completed'] = True
            save()
        return self.final

class CollectionGuard(gdb.Breakpoint):
    def stop(self):
        summary['unexpected_collections'].append(hex(int(gdb.parse_and_eval('$pc'))))
        save()
        return True

def new_thread(event):
    summary['new_threads'].append(str(event.inferior_thread))
    save()

gdb.events.new_thread.connect(new_thread)
watches = [WriteWatch(name) for name in SPECS]
description = gdb.execute('info breakpoints', to_string=True)
(CAPTURE / 'watchpoints.txt').write_text(description)
assert description.count('hw watchpoint') == len(SPECS), description
for point in [Phase('gigi_entry', 0x9a8520),
              Phase('builtins_entry', 0x97c6b0),
              Phase('builtins_return', 0x9a909e),
              Phase('before_main_translation', 0x9a9419, final=True),
              CollectionGuard('*0xda5780')]:
    point.silent = True
snapshot('frontend_exec_before_initialization')

def finish_capture():
    events.flush()
    save()
    assert summary['completed'], summary
    assert not summary['failures'] and not summary['unexpected_collections'] and not summary['new_threads']
    assert [p['phase'] for p in summary['phases']] == [
        'frontend_exec_before_initialization', 'gigi_entry', 'builtins_entry',
        'builtins_return', 'before_main_translation']
    assert all(p['threads'] == 1 for p in summary['phases'])
    assert int(gdb.parse_and_eval('$pc')) == 0x9a9419
    print('PREFIX_COMPLETE ' + json.dumps(summary['counters']), flush=True)
