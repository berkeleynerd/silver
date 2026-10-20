"""Bounded read-only session projection, shared by live adapter and offline replay.

The injected reader must persist raw reads before returning them. This module
also flushes each complete raw block before applying a typed layout check.
It does not run the target, call a printer, evaluate OCaml, or compute B/R.
"""
from collections import OrderedDict
import json
from pathlib import Path
import struct


class ProjectionError(Exception):
    pass


def require(condition, detail):
    if not condition:
        raise ProjectionError(detail)


def tagged(value):
    require(value & 1, ('expected tagged integer', value))
    return (value - (1 << 64) if value >= 1 << 63 else value) >> 1


class RawStore:
    def __init__(self, read, out, limits):
        self.read = read
        self.out = Path(out)
        self.limits = limits
        self.seen = set()
        self.cache = OrderedDict()
        self.payload_bytes = 0
        self.log = (self.out / 'session-blocks.jsonl').open('w')

    def word(self, address):
        return int.from_bytes(self.read(address, 8), 'little')

    def raw(self, pointer):
        require(pointer != 0 and pointer % 8 == 0, ('invalid block pointer', pointer))
        if pointer in self.cache:
            self.cache.move_to_end(pointer)
            return self.cache[pointer]
        header_raw = self.read(pointer - 8, 8)
        header = int.from_bytes(header_raw, 'little')
        words = header >> 10
        require(words <= self.limits['block_words'], ('block word limit', pointer, words))
        if pointer not in self.seen:
            require(len(self.seen) < self.limits['blocks'], 'projection block limit')
            require(self.payload_bytes + words * 8 + 8 <= self.limits['payload_bytes'],
                    'projection payload limit')
        payload = self.read(pointer, words * 8) if words else b''
        require(len(payload) == words * 8, ('short payload', pointer))
        row = {'address': pointer, 'header': header, 'tag': header & 255,
               'words': words, 'header_hex': header_raw.hex(), 'payload_hex': payload.hex()}
        if pointer not in self.seen:
            self.log.write(json.dumps(row, separators=(',', ':')) + '\n')
            self.log.flush()
            self.seen.add(pointer)
            self.payload_bytes += words * 8 + 8
        row['fields'] = tuple(struct.unpack('<' + 'Q' * words, payload))
        self.cache[pointer] = row
        if len(self.cache) > self.limits['cached_blocks']:
            self.cache.popitem(last=False)
        return row

    def block(self, pointer, tag=0, words=None):
        row = self.raw(pointer)
        require(row['tag'] == tag and (words is None or row['words'] == words),
                ('block layout', pointer, row['tag'], row['words'], tag, words))
        return row['fields']

    def values(self, pointer):
        seen = set()
        while pointer != 1:
            require(pointer not in seen, ('list cycle', pointer))
            require(len(seen) < self.limits['edges'], 'list edge limit')
            seen.add(pointer)
            item, pointer = self.block(pointer, words=2)
            yield item

    def table(self, pointer, int_keys=True):
        size, buckets, seed, initial_size = self.block(pointer, words=4)
        n = tagged(size)
        require(0 <= n <= self.limits['edges'], ('table count', n))
        tagged(seed)
        tagged(initial_size)
        heads = self.block(buckets)
        require(len(heads) > 0 and len(heads) & (len(heads) - 1) == 0,
                ('table array length', len(heads)))
        rows = []
        first = {}
        for bucket, cell in enumerate(heads):
            seen = set()
            while cell != 1:
                require(cell not in seen, ('bucket cycle', cell))
                require(len(rows) < self.limits['edges'], 'table edge limit')
                seen.add(cell)
                key, value, following = self.block(cell, words=3)
                if int_keys:
                    decoded = tagged(key)
                    require(decoded & (len(heads) - 1) == bucket,
                            ('integer key in wrong bucket', decoded, bucket))
                    first.setdefault(decoded, value)
                rows.append({'bucket': bucket, 'cell': cell, 'key': key,
                             'value': value, 'next': following})
                cell = following
        require(n == len(rows), ('table count mismatch', n, len(rows)))
        return {'address': pointer, 'array': buckets, 'entries': rows}, first

    def ordinary_graph(self, roots, name):
        """Stream ordinary logical/data blocks; runtime closures remain unsupported.

        Sharing is represented by addresses. Cycles are retained, not silently
        turned into a finite occurrence-tree proof. Opaque tag>=251 payloads
        are retained without following possible C pointers.
        """
        pending = set(roots)
        seen = set()
        path = self.out / (name + '-addresses.jsonl')
        with path.open('w') as log:
            while pending:
                require(len(pending) <= self.limits['edges'], 'graph frontier limit')
                pointer = pending.pop()
                if pointer & 1 or pointer in seen:
                    continue
                row = self.raw(pointer)
                log.write(json.dumps(pointer) + '\n')
                log.flush()
                seen.add(pointer)
                require(row['tag'] < 246 or row['tag'] >= 251,
                        ('unsupported runtime block in ordinary graph', pointer, row['tag']))
                if row['tag'] < 246:
                    for value in row['fields']:
                        if not value & 1 and value not in seen:
                            pending.add(value)
        return {'roots': roots, 'blocks': len(seen), 'address_file': path.name}

    def close(self):
        self.log.close()


DEFAULT_LIMITS = {'blocks': 1000000, 'payload_bytes': 128 * 1024 * 1024,
                  'block_words': 1 << 20, 'edges': 1000000, 'cached_blocks': 256}


class SessionCapture:
    def __init__(self, read, address, out, limits=None):
        self.address = address
        self.out = Path(out)
        self.store = RawStore(read, out, limits or DEFAULT_LIMITS)
        self.roots = {'complete': False, 'root_words': {}}
        self.session_result = {'complete': False, 'failures': []}
        self.helper_result = {'complete': False, 'failures': [], 'unknown_closures': []}
        self.session_fields = None

    def save(self, name, value):
        (self.out / name).write_text(json.dumps(value, indent=2) + '\n')

    def capture_roots(self):
        """Root words first; root/controller records survive later layout failures."""
        try:
            for key, symbol, offset in [
                ('signal_handlers', 'caml_signal_handlers', 0),
                ('exit_function', 'camlStdlib', 0x338),
                ('registered_stats', 'camlWhy3__Debug', 0x128),
                ('stats_flag', 'camlWhy3__Debug', 0x70),
                ('formatter', 'camlWhy3__Debug', 0x80),
                ('timing_map', 'camlWhy3__Debug', 0x108)]:
                location = self.address(symbol) + offset
                value = self.store.word(location)
                self.roots['root_words'][key] = {'symbol': symbol, 'offset': offset,
                                                 'address': location, 'value': value}
                self.save('session-root.json', self.roots)
            handlers = self.store.block(self.root('signal_handlers'))
            require(len(handlers) > 2, 'handler array lacks SIGINT')
            self.roots['sigint_closure'] = handlers[2]
            self.save('session-root.json', self.roots)
            closure = self.store.block(handlers[2], tag=247, words=4)
            require(closure[0] == self.address('camlGnat_main__fun_14206'), 'SIGINT closure code')
            self.roots['controller'] = closure[2]
            self.save('session-root.json', self.roots)
            controller = self.store.block(closure[2], words=6)
            self.roots['session'] = controller[0]
            self.save('session-root.json', self.roots)
            self.session_fields = self.store.block(controller[0], words=17)
            self.store.raw(self.session_fields[7])  # session directory string
            self.store.raw(self.session_fields[10])  # shallow shape record
            self.roots['complete'] = True
        except Exception as error:
            self.roots['failure'] = repr(error)
        finally:
            self.save('session-root.json', self.roots)
        return self.roots

    def root(self, key):
        return self.roots['root_words'][key]['value']

    def capture_session(self):
        try:
            require(self.roots['complete'], 'incomplete session root')
            fields = self.session_fields
            tables = {}
            lookup = {}
            for name, index in [('files', 8), ('proof_nodes', 2), ('transformations', 4),
                                ('raw_tasks', 11), ('proof_attempts', 0)]:
                tables[name], lookup[name] = self.store.table(fields[index])
                self.save('session-tables.json', tables)
            for row in tables['proof_attempts']['entries']:
                self.store.raw(row['value'])
            visits = self.forest(tables['files']['entries'], lookup)
            self.session_result['apn_visits'] = len(visits)
            self.save('session-forest.json', {'visits': visits})
            tasks = {}
            declarations = set()
            for row in tables['raw_tasks']['entries']:
                pointer = row['value']
                if str(pointer) in tasks:
                    continue
                chain = []
                seen = set()
                task = pointer
                while task != 1:
                    require(task not in seen, ('task cycle', task))
                    require(len(chain) < self.store.limits['edges'], 'task chain limit')
                    seen.add(task)
                    head, = self.store.block(task, words=1)
                    hd = self.store.block(head, words=6)
                    tdecl = hd[0]
                    node, _tag = self.store.block(tdecl, words=2)
                    tdnode = self.store.raw(node)
                    require(tdnode['tag'] in (0, 1, 2, 3), ('tdecl node tag', node))
                    if tdnode['tag'] == 0:
                        declaration, = self.store.block(node, words=1)
                        declarations.add(declaration)
                    chain.append({'option': task, 'head': head, 'tdecl': tdecl})
                    task = hd[1]
                tasks[str(pointer)] = chain
                self.save('session-task-chains.json', tasks)
            self.session_result['raw_task_values'] = len(tasks)
            self.session_result['logical_declarations'] = len(declarations)
            self.session_result['logical_graph'] = self.store.ordinary_graph(
                sorted(declarations), 'session-task-graph')
            self.session_result['complete'] = True
        except Exception as error:
            self.session_result['failures'].append(repr(error))
        finally:
            self.session_result['retained_blocks'] = len(self.store.seen)
            self.session_result['retained_payload_bytes'] = self.store.payload_bytes
            self.save('session-result.json', self.session_result)
        return self.session_result

    def forest(self, files, lookup):
        work = [('file', row['value']) for row in reversed(files)]
        active = set()
        visits = []
        events = 0
        with (self.out / 'session-forest-events.jsonl').open('w') as log:
            while work:
                events += 1
                require(events <= self.store.limits['edges'], 'forest event limit')
                kind, value = work.pop()
                log.write(json.dumps([kind, value]) + '\n')
                log.flush()
                if kind == 'leave':
                    active.remove(tuple(value))
                    continue
                if kind == 'visit':
                    goal = value['goal']
                    value['detached'] = goal not in lookup['raw_tasks']
                    value['task'] = lookup['raw_tasks'].get(goal)
                    visits.append(value)
                    continue
                token = (kind, value)
                require(token not in active, ('session forest cycle', token))
                active.add(token)
                work.append(('leave', token))
                if kind == 'file':
                    fields = self.store.block(value, words=5)
                    children = [('theory', p) for p in self.store.values(fields[4])]
                elif kind == 'theory':
                    fields = self.store.block(value, words=4)
                    children = [('goal', tagged(p)) for p in self.store.values(fields[1])]
                elif kind == 'goal':
                    require(value in lookup['proof_nodes'], ('missing proof node', value))
                    fields = self.store.block(lookup['proof_nodes'][value], words=5)
                    parent = self.store.raw(fields[2])
                    require(parent['tag'] in (0, 1) and parent['words'] == 1, 'proof parent layout')
                    self.store.table(fields[3], int_keys=False)
                    work.append(('visit', {'goal': value, 'root': parent['tag'] == 1,
                                           'proof_node': lookup['proof_nodes'][value]}))
                    children = [('transformation', tagged(p)) for p in self.store.values(fields[4])]
                elif kind == 'transformation':
                    require(value in lookup['transformations'], ('missing transformation', value))
                    fields = self.store.block(lookup['transformations'][value], words=5)
                    children = [('goal', tagged(p)) for p in self.store.values(fields[2])]
                else:
                    raise ProjectionError(('unknown forest action', kind))
                work.extend(reversed(children))
        return visits

    def closure(self, pointer):
        row = self.store.raw(pointer)
        require(row['tag'] == 247 and row['words'] >= 2, ('closure layout', pointer))
        return {'address': pointer, 'code': row['fields'][0], 'words': row['words'],
                'raw_fields': list(row['fields'])}

    def capture_helpers(self):
        """Retain known root structures and opaque callable environments; no R claim."""
        result = self.helper_result
        result['scope'] = 'Known exit/statistics roots and immediate callback environments; source/global reachability and R remain open'
        try:
            exit_ref, = self.store.block(self.root('exit_function'), words=1)
            chain = []
            seen = set()
            while True:
                require(exit_ref not in seen, ('exit chain cycle', exit_ref))
                require(len(seen) < self.store.limits['edges'], 'exit chain limit')
                seen.add(exit_ref)
                closure = self.closure(exit_ref)
                chain.append(closure)
                result['exit_chain'] = chain
                self.save('exit-hook-roots.json', result)
                if closure['code'] != self.address('camlStdlib__new_exit_481'):
                    result['terminal_exit_closure'] = closure
                    break
                require(closure['words'] == 5, 'exit link word count')
                _code, _info, callback, gate, previous = closure['raw_fields']
                gate_value, = self.store.block(gate, words=1)
                require(gate_value in (1, 3), 'exit once-only gate')
                closure['callback'] = self.closure(callback)
                closure['gate'] = gate_value
                exit_ref = previous
            stats, = self.store.block(self.root('registered_stats'), words=1)
            rows = []
            value_roots = []
            for pointer in self.store.values(stats):
                wrapper = self.closure(pointer)
                rows.append(wrapper)
                result['registered_stats'] = rows
                self.save('exit-hook-roots.json', result)
                if (wrapper['code'] != self.address('camlWhy3__Debug__fun_3073')
                        or wrapper['words'] != 3):
                    result['unknown_closures'].append(pointer)
                    continue
                record = wrapper['raw_fields'][2]
                value, printer, name = self.store.block(record, words=3)
                wrapper['statistic'] = {'record': record, 'value': value,
                                        'printer': self.closure(printer), 'name': name}
                self.store.raw(name)
                value_roots.append(value)
            result['statistic_values'] = self.store.ordinary_graph(value_roots, 'statistic-values')
            for key in ['stats_flag', 'formatter', 'timing_map']:
                self.store.raw(self.root(key))
            formatter, = self.store.block(self.root('formatter'), words=1)
            self.store.raw(formatter)
            result['formatter_record'] = formatter
            timing, _ = self.store.table(self.root('timing_map'), int_keys=False)
            result['timing_table'] = timing
            result['timing_graph'] = self.store.ordinary_graph(
                [p for row in timing['entries'] for p in [row['key'], row['value']]], 'timing-values')
            result['complete'] = not result['unknown_closures']
        except Exception as error:
            result['failures'].append(repr(error))
        finally:
            result['complete_R'] = False
            self.save('exit-hook-roots.json', result)
        return result

    def close(self):
        self.store.close()
