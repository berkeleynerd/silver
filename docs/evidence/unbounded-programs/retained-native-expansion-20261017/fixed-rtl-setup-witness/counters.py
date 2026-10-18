"""Measure first initialize_rtl entry-to-return; incoming counters are observations."""
import gdb,json
from pathlib import Path
ROOT=Path('/tmp/silver-native-rtl-setup-20261018')
CAPTURE=ROOT/'capture'
inferior=gdb.selected_inferior()
assert int(gdb.parse_and_eval('$pc'))==0x1358170
return_address=int.from_bytes(bytes(inferior.read_memory(int(gdb.parse_and_eval('$rsp')),8)),'little')
assert int.from_bytes(bytes(inferior.read_memory(0x3d1a948,4)),'little')==0
target=int.from_bytes(bytes(inferior.read_memory(0x3617c70,8)),'little')
assert bytes(inferior.read_memory(target+0xde0,1))==b'\x00'
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
    spec['initial'] = value
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
    print('RTL_PHASE ' + json.dumps(summary['phases'][-1]), flush=True)

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
PHASES = [
 ('ira_init_once_return',0x1358235),
 ('fake_stack_mems_return',0x13581d5),
 ('alias_target_return',0x13581da),
 ('recog_init_return',0x13581e8),
 ('dummy_function_start_return',0x13581ed),
 ('expmed_return',0x13581f2),
 ('lower_subreg_return',0x13581f7),
 ('set_costs_return',0x13581fc),
 ('expr_target_return',0x1358201),
 ('ira_init_return',0x1358206),
 ('dummy_function_end_return',0x1358216),
 ('initialize_rtl_return',return_address)]
summary['return_address']=hex(return_address)
summary['initial_timer_pointer']=hex(int.from_bytes(bytes(inferior.read_memory(0x3d1a870,8)),'little'))
summary['initial_rtl_initialized']=0
summary['initial_target_specific_initialized']=False
for label,address in PHASES:
    Phase(label,address,final=label=='initialize_rtl_return')
CollectionGuard('*0xda5780').silent=True
snapshot('initialize_rtl_entry')

def finish_capture():
    events.flush()
    save()
    assert summary['completed'], summary
    assert not summary['failures'] and not summary['unexpected_collections'] and not summary['new_threads']
    assert [p['phase'] for p in summary['phases']] == ['initialize_rtl_entry']+[label for label,_ in PHASES]
    assert all(p['threads'] == 1 for p in summary['phases'])
    assert int(gdb.parse_and_eval('$pc')) == return_address
    print('RTL_COMPLETE ' + json.dumps(summary['counters']), flush=True)
