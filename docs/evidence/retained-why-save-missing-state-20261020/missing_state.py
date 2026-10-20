"""Read-only extension of the accepted SessionCapture at its existing stop.

Every read goes through the caller's durable reader/RawStore. No inferior calls,
continuation, term opening, or capacity conclusion. Failures preserve unknowns.
"""
import hashlib
import json

SYMBOLS = {
    'caml_ephe_none': {'elf_value': 16427024},
    'camlWhy3__Theory__entry': {'elf_value': 5856896},
    'camlWhy3__Termcode': {'elf_value': 14679272},
    'camlWhy3__Theory': {'elf_value': 11932264},
    'camlWhy3__Termcode__check_2028': {
        'elf_value': 8299424,
        'code_hex': '4883ec08488d053d596100488b98c0010000488b5b084881fb010800007c19488b80b801000049c786f000000000000000e8829c1f006690b8010000004883c408c3'},
    'camlWhy3__Theory__restore_path_4035': {
        'elf_value': 5837264,
        'code_hex': '4889c6488b4310488d1d520c5b00488b9bc8000000488b7b184889f3e90fee4000'},
}

LAYOUT_CHECKS = [{'symbol': 'camlWhy3__Theory__entry', 'offset': 2500,
    'code_hex': '488d1585a9ffff48891648ba05000000000000014889560848894e10488d56e048c742f8f70c0000488d0d8da9ffff48890a48b9050000000000000148894a0848894210488d05d9a95c00488998380300004889b8400300004889b00001000048899008010000'}]



def require(ok, message):
    if not ok:
        raise ValueError(message)


def integer(v):
    require(v & 1, ('expected immediate', v))
    return (v - (1 << 64) if v >= 1 << 63 else v) >> 1


class MissingState:
    def __init__(self, session, plan, phase):
        self.session, self.s, self.plan = session, session.store, plan
        self.result = {'schema': 1, 'phase': phase, 'complete': False,
                       'failures': [], 'sections': {}, 'capacity_established': False}
        self.identifiers = set()
        self.provers = set()

    def save(self):
        self.session.save('save-missing-state.json', self.result)

    def section(self, name, operation):
        try:
            self.result['sections'][name] = {'known': True, 'value': operation()}
        except Exception as error:
            self.result['sections'][name] = {'known': False, 'value': None,
                                            'failure': repr(error)}
            self.result['failures'].append(name)
        self.save()

    def string(self, p):
        row = self.s.raw(p)
        require(row['tag'] == 252 and row['words'] > 0, ('string layout', p))
        raw = bytes.fromhex(row['payload_hex'])
        require(raw[-1] <= 7, ('string padding count', p))
        n = len(raw) - 1 - raw[-1]
        require(n >= 0 and raw[n] == 0, ('string terminator', p))
        value = raw[:n]
        return {'pointer': p, 'bytes': n, 'hex': value.hex(),
                'sha256': hashlib.sha256(value).hexdigest()}

    def path(self, p):
        values = [self.string(v) for v in self.s.values(p)]
        return {'pointer': p, 'components': values, 'component_count': len(values),
                'total_bytes': sum(v['bytes'] for v in values),
                'joined_dot_bytes': sum(v['bytes'] for v in values) + max(0, len(values)-1)}

    def ident(self, p):
        name, _attrs, _loc, tag = self.s.block(p, words=4)
        self.identifiers.add(p)
        return {'pointer': p, 'id_tag': integer(tag), 'id_string': self.string(name)}

    def prover(self, p):
        self.provers.add(p)
        name, version, altern = self.s.block(p, words=3)
        return {'pointer': p, 'name': self.string(name), 'version': self.string(version),
                'alternative': self.string(altern)}

    def table(self, p, key, value):
        size, array, seed, initial = self.s.block(p, words=4)
        heads = self.s.block(array)
        require(len(heads) > 0 and len(heads) & (len(heads)-1) == 0, 'bucket capacity')
        result = {'pointer': p, 'array': array, 'size': integer(size),
                  'seed': integer(seed), 'initial_size': integer(initial),
                  'bucket_capacity': len(heads), 'bucket_heads': list(heads), 'entries': []}
        seen = set()
        for bucket, cell in enumerate(heads):
            while cell != 1:
                require(cell not in seen, ('cycle or shared bucket cell', cell))
                require(len(seen) < self.s.limits['edges'], 'diagnostic table edge limit')
                seen.add(cell)
                k, v, following = self.s.block(cell, words=3)
                if key == integer:
                    require(integer(k) & (len(heads)-1) == bucket, 'integer bucket placement')
                result['entries'].append({'bucket': bucket, 'cell': cell, 'raw_key': k,
                                           'raw_value': v, 'next': following,
                                           'key': key(k), 'value': value(v)})
                cell = following
        result['binding_visits'] = len(result['entries'])
        result['disjoint_finite_chains'] = True
        result['size_equals_binding_visits'] = result['size'] == len(result['entries'])
        require(result['size'] >= 0, 'negative table size')
        # Preserve scalar/header disagreement as evidence; it is not repaired.
        return result

    def map(self, p, key, value):
        nodes, active, seen, heights = [], set(), set(), {1: 0}
        stack = [(p, False)]
        ordered = []
        while stack:
            node, leave = stack.pop()
            if node == 1:
                continue
            if leave:
                active.remove(node)
                fields = self.s.block(node, words=5)
                left, k, v, right, h = fields
                h = integer(h)
                require(h == 1 + max(heights[left], heights[right]), 'map stored height')
                require(abs(heights[left]-heights[right]) <= 2, 'map balance')
                heights[node] = h
                continue
            require(node not in active and node not in seen, ('map cycle or shared node', node))
            require(len(seen) < self.s.limits['edges'], 'diagnostic map edge limit')
            seen.add(node); active.add(node)
            left, k, v, right, h = self.s.block(node, words=5)
            nodes.append({'pointer': node, 'left': left, 'key': key(k), 'value': value(v),
                          'right': right, 'height': integer(h)})
            stack.extend([(node, True), (right, False), (left, False)])
        # Check key ordering independently of pointer enumeration.
        by_pointer = {n['pointer']: n for n in nodes}
        stack, cursor = [], p
        while stack or cursor != 1:
            while cursor != 1:
                stack.append(cursor); cursor = by_pointer[cursor]['left']
            cursor = stack.pop(); k = by_pointer[cursor]['key']
            ordered.append(bytes.fromhex(k['hex']) if isinstance(k, dict) else k)
            cursor = by_pointer[cursor]['right']
        require(all(a < b for a, b in zip(ordered, ordered[1:])), 'map ordering')
        return {'pointer': p, 'cardinality': len(nodes), 'height': heights[p], 'nodes': nodes,
                'finite_balanced_ordered': True}

    def indices(self, p):
        values = [integer(v) for v in self.s.values(p)]
        return {'pointer': p, 'length': len(values), 'indices': values,
                'absolute_index_max': max(map(abs, values), default=0)}

    def gshape(self, p):
        hyp, index, n = self.s.block(p, words=3)
        return {'pointer': p, 'n': integer(n),
                'hyp_shape': self.map(hyp, self.string, integer),
                'index_sh': self.map(index, integer, self.string)}

    def buffer(self):
        location = self.session.address('camlWhy3__Termcode') + 0x1c0
        p = self.s.word(location)
        backing, position, length, initial = self.s.block(p, words=4)
        pos, cap = integer(position), integer(length)
        current, original = self.string(backing), self.string(initial)
        require(0 <= pos <= cap == current['bytes'], 'Buffer entry invariant')
        return {'root_address': location, 'pointer': p, 'position': pos, 'capacity': cap,
                'backing': current, 'initial_backing': original}

    def serializer(self, sf):
        files = self.table(sf[8], integer, lambda p: p)
        goals = self.table(sf[2], integer, lambda p: p)
        trans = self.table(sf[4], integer, lambda p: p)
        attempts = self.table(sf[0], integer, lambda p: p)
        out = {'session_dir': self.string(sf[7]), 'proof_attempt_table': attempts,
               'files': [], 'goals': [],
               'transformations': [], 'attempts': [], 'provers': []}
        for row in files['entries']:
            p = row['raw_value']; fid, path, fmt, detached, theories = self.s.block(p, words=5)
            theories_out = []
            for th in self.s.values(theories):
                name, children, parent, det = self.s.block(th, words=4)
                theories_out.append({'pointer': th, 'name': self.ident(name),
                                     'goals': [integer(v) for v in self.s.values(children)],
                                     'parent': integer(parent), 'detached': integer(det)})
            out['files'].append({'pointer': p, 'id': integer(fid), 'path': self.path(path),
                                 'format': self.string(fmt), 'detached': integer(detached),
                                 'theories': theories_out})
        for row in goals['entries']:
            p = row['raw_value']; name, expl, parent, ats, ts = self.s.block(p, words=5)
            out['goals'].append({'pointer': p, 'goal': row['key'], 'name': self.ident(name),
                                 'explanation': self.string(expl),
                                 'attempts': self.table(ats, self.prover, integer),
                                 'transformations': [integer(v) for v in self.s.values(ts)]})
        for row in trans['entries']:
            p = row['raw_value']; name, args, children, parent, det = self.s.block(p, words=5)
            out['transformations'].append({'pointer': p, 'id': row['key'],
                'name': self.string(name), 'arguments': self.path(args),
                'subtasks': [integer(v) for v in self.s.values(children)],
                'parent': integer(parent), 'detached': integer(det)})
        for row in attempts['entries']:
            p = row['raw_value']; parent, prover, limits, state, obsolete, script = self.s.block(p, words=6)
            script_path = None
            if script != 1:
                path, = self.s.block(script, words=1); script_path = self.path(path)
            # Retain scalar/result payload bytes without imposing a guessed record layout.
            self.s.ordinary_graph([limits, state], 'save-attempt-'+str(row['key']))
            out['attempts'].append({'pointer': p, 'id': row['key'], 'parent': integer(parent),
                'prover': self.prover(prover), 'limits': limits, 'proof_state': state,
                'obsolete': integer(obsolete), 'script': script_path})
        out['provers'] = [self.prover(p) for p in sorted(self.provers)]
        return out

    def restore_paths(self):
        root = self.session.address('camlWhy3__Theory') + 0x100
        closure = self.s.word(root)
        code, info, table = self.s.block(closure, tag=247, words=3)
        require(code == self.session.address('camlWhy3__Theory__restore_path_4035'), 'restore closure code')
        none = self.s.word(self.session.address('caml_ephe_none'))
        # K1 table cells are (cached_hash, ephemeron, rest), not (key,value,rest).
        size, array, seed, initial = self.s.block(table, words=4)
        heads = self.s.block(array)
        require(len(heads)>0 and len(heads)&(len(heads)-1)==0, 'weak bucket capacity')
        rows, seen = [], set()
        for bucket, cell in enumerate(heads):
            while cell != 1:
                require(cell not in seen, 'weak table cycle/shared cell')
                require(len(seen)<self.s.limits['edges'], 'diagnostic weak edge limit')
                seen.add(cell)
                h, eph, following = self.s.block(cell, words=3)
                _link, value, key = self.s.block(eph, tag=251, words=3)
                require(integer(h)&(len(heads)-1)==bucket, 'weak cached hash bucket')
                rows.append({'bucket': bucket, 'cell': cell, 'hash': integer(h),
                             'ephemeron': eph, 'key': key, 'data': value, 'next': following})
                cell = following
        paths = []
        for p in sorted(self.identifiers):
            ident = self.ident(p); tag = ident['id_tag']; found = None
            for row in rows:
                if row['hash'] != tag or row['key']==none or row['data']==none:
                    continue
                kfields = self.s.block(row['key'], words=4)
                if integer(kfields[3]) == tag:
                    found = row; break
            if found:
                lp, theory, qualified = self.s.block(found['data'], words=3)
                decoded = {'library_path': self.path(lp), 'theory_name': self.string(theory),
                           'qualified_path': self.path(qualified)}
                path = decoded['qualified_path']
                name_bytes = path['joined_dot_bytes'] if path['component_count'] else ident['id_string']['bytes']
            else:
                decoded = None; name_bytes = ident['id_string']['bytes']
            paths.append({'ident': ident, 'binding': found, 'restore_path': decoded,
                          'serializer_name_bytes': name_bytes,
                          'fallback': found is None or not decoded['qualified_path']['component_count']})
        return {'root_address': root, 'closure': closure, 'table': table,
                'size': integer(size), 'seed': integer(seed), 'initial_size': integer(initial),
                'bucket_capacity': len(heads), 'bucket_heads': list(heads), 'ephe_none': none,
                'entries': rows, 'binding_visits': len(rows),
                'size_equals_binding_visits': integer(size)==len(rows),
                'disjoint_finite_chains': True, 'required_identifiers': paths}

    def capture(self):
        require(self.session.roots['complete'], 'accepted session roots incomplete')
        checks = []
        for witness in LAYOUT_CHECKS:
            location = self.session.address(witness['symbol']) + witness['offset']
            expected = bytes.fromhex(witness['code_hex'])
            observed = self.s.read(location, len(expected))
            checks.append(dict(witness, runtime_address=location, observed_hex=observed.hex()))
            self.result['layout_checks'] = checks
            self.save()
            require(observed == expected, 'Theory restore-path initialization layout mismatch')
        sf = self.session.session_fields
        shape = self.s.block(sf[10], words=6)
        self.result['session'] = self.session.roots['session']
        self.result['shape_version'] = integer(shape[0])
        self.result['has_shapes'] = integer(shape[1])
        self.save()
        self.section('prover_ids', lambda: self.table(sf[9], self.prover, integer))
        self.section('gshape', lambda: self.gshape(shape[2]))
        self.section('bound_shapes', lambda: self.table(shape[3], integer, self.indices))
        self.section('old_shapes', lambda: self.table(shape[4], integer, self.string))
        self.section('checksums', lambda: self.table(shape[5], integer, self.string))
        self.section('shape_buffer', self.buffer)
        self.section('proof_attempts', lambda: self.table(sf[0], integer, lambda p: p))
        for name, i, key in [('file_state', 13, integer), ('theory_state', 14, self.ident),
                             ('transformation_state', 15, integer), ('proof_node_state', 16, integer)]:
            self.section(name, lambda i=i, key=key: self.table(sf[i], key, integer))
        self.section('serializer', lambda: self.serializer(sf))
        self.section('restore_paths', self.restore_paths)
        self.result['complete'] = not self.result['failures']
        self.save()
        return self.result


def collect(session, plan, phase):
    # Preserve a small extension-only raw-read log in addition to the inherited
    # durable log. Cache hits remain backed by accumulated session-blocks.jsonl.
    original_read = session.store.read
    with (session.out / 'save-state-memory-reads.jsonl').open('w') as log:
        def read(address, size):
            raw = original_read(address, size)
            log.write(json.dumps({'address': address, 'bytes': size, 'hex': raw.hex()}, separators=(',', ':'))+'\n')
            log.flush()
            return raw
        session.store.read = read
        try:
            return MissingState(session, plan, phase).capture()
        finally:
            session.store.read = original_read
