"""New byte-level name projection from retained captures; no prior script runs.

R51 supplies its accepted complete stored-field/root census. This projection
independently reads names and ALL declaration signature/type fields, including
unused Dparam signatures omitted by a formula-only walk.
"""
import gzip
import hashlib
import json
from pathlib import Path
import struct
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent
CASES = ['put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid']


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


class Bytes:
    def __init__(self, payload, archive, secondary):
        self.blocks = {}
        for line in payload.splitlines():
            row = json.loads(line)
            assert row['address'] not in self.blocks
            self.blocks[row['address']] = row
        self.archive, self.secondary = archive, secondary
        self.secondary_identity = None
        self.reads = set()

    def block(self, p):
        if p not in self.blocks and self.secondary_identity is None:
            blob = self.archive.extractfile(self.secondary).read()
            self.secondary_identity = identity(blob)
            extra = json.loads(blob)['blocks']
            for address, row in extra.items():
                address = int(address)
                data = (bytes.fromhex(row['payload_hex']) if 'payload_hex' in row
                        else struct.pack('<' + 'Q' * len(row['fields']), *row['fields']))
                if address in self.blocks:
                    old = self.blocks[address]
                    assert (old['header'], bytes.fromhex(old['payload_hex'])) == (row['header'], data)
                else:
                    self.blocks[address] = {**row, 'payload_hex': data.hex()}
        row = self.blocks[p]
        data = bytes.fromhex(row['payload_hex'])
        assert row['tag'] == row['header'] & 255
        assert row['words'] == row['header'] >> 10
        assert len(data) == 8 * row['words']
        self.reads.add(p)
        return row, data

    def fields(self, p, words=None, tag=0):
        row, data = self.block(p)
        assert row['tag'] == tag and (words is None or row['words'] == words)
        return struct.unpack('<' + 'Q' * row['words'], data)

    def string(self, p):
        row, data = self.block(p)
        assert row['tag'] == 252 and len(data) > 0 and data[-1] < 8
        n = len(data) - data[-1] - 1
        assert n >= 0 and data[n] == 0
        return data[:n]

    def seq(self, p):
        seen, out = set(), []
        while p != 1:
            assert p not in seen
            seen.add(p)
            value, p = self.fields(p, 2)
            out.append(value)
        return out

    def mapping(self, p, seen=None):
        if seen is None:
            seen = set()
        if p == 1:
            return []
        assert p not in seen
        seen.add(p)
        left, key, value, right, height = self.fields(p, 5)
        assert height & 1
        return self.mapping(left, seen) + [(key, value)] + self.mapping(right, seen)


def project(case):
    graph_path = EV / 'retained-why-preinline-prefix-20261020' / (case + '-graph.json.gz')
    type_path = EV / 'retained-why-fixed-inline-family-20261020' / (case + '-types.json')
    graph = json.loads(gzip.decompress(graph_path.read_bytes()))
    typed = json.loads(type_path.read_bytes())
    inp = typed['input']
    prefix = inp['member'].removesuffix('session-blocks.jsonl')
    secondary = prefix + ('inline-entry-graph.json' if case == 'input-is-valid' else 'representative-graph.json')
    with tarfile.open(ROOT / inp['archive']) as archive:
        payload = archive.extractfile(inp['member']).read()
        assert identity(payload) == inp['identity']
        raw = Bytes(payload, archive, secondary)
        identifiers, symbols, type_nodes, type_symbols, variables = {}, set(), set(), set(), set()
        roles = {}
        constructors = set()
        proposition_ids = set()
        def ident(p, role):
            roles.setdefault(p, set()).add(role)
            if p not in identifiers:
                name, attrs, _loc, tag = raw.fields(p, 4)
                assert tag & 1
                value = raw.string(name)
                # These exact inputs are ASCII; byte length is not a Unicode
                # codepoint count and decoding never discards invalid bytes.
                spelling = value.decode('ascii')
                aa = []
                for a, unit in raw.mapping(attrs):
                    assert unit == 1
                    text, atag = raw.fields(a, 2)
                    assert atag & 1
                    aa.append(raw.string(text).decode('ascii'))
                identifiers[p] = {'name': spelling, 'bytes': len(value),
                                  'string_pointer': name, 'attrs': sorted(aa)}
            return p
        def tv(p):
            name, = raw.fields(p, 1)
            ident(name, 'type_variable')
        def ts(p):
            if p in type_symbols:
                return
            type_symbols.add(p)
            name, params, definition = raw.fields(p, 3)
            ident(name, 'type_symbol')
            for param in raw.seq(params):
                tv(param)
            if definition != 1:
                row, _ = raw.block(definition)
                assert row['tag'] in (0, 1, 2)
                if row['tag'] == 0:
                    body, = raw.fields(definition, 1)
                    ty(body)
        def ty(p):
            if p in type_nodes:
                return
            type_nodes.add(p)
            node, _tag = raw.fields(p, 2)
            row, _ = raw.block(node)
            if row['tag'] == 0:
                var, = raw.fields(node, 1)
                tv(var)
            else:
                head, args = raw.fields(node, 2, tag=1)
                ts(head)
                for arg in raw.seq(args):
                    ty(arg)
        def symbol(p, role='logic_symbol'):
            if p in symbols:
                name = raw.fields(p, 5)[0]
                ident(name, role)
                return
            symbols.add(p)
            name, args, value, _constr, _proj = raw.fields(p, 5)
            ident(name, role)
            for arg in raw.seq(args):
                ty(arg)
            if value != 1:
                result, = raw.fields(value, 1)
                ty(result)
        def variable(p):
            variables.add(p)
            name, typ = raw.fields(p, 2)
            ident(name, 'variable')
            ty(typ)
            return identifiers[name]
        def proposition(p):
            name, = raw.fields(p, 1)
            proposition_ids.add(ident(name, 'proposition'))
        metadata_path = EV / 'retained-why-parallel-symbol-exclusion-20261020' / (case + '-metadata.json')
        metadata_inventory = json.loads(metadata_path.read_bytes())
        assert not any(e['meta'] in ('introduced_lsymbol', 'introduced_prsymbol', 'float_type')
                       for e in metadata_inventory['update_events'])
        map_name = ('first-domain-address-map.json.gz' if case == 'first-or-default'
                    else case + '-correspondence.map.json.gz')
        map_path = EV / 'retained-why-parallel-residual-transfer-20261020' / map_name
        address_map = json.loads(gzip.decompress(map_path.read_bytes()))
        reverse = {value: int(key) for key, value in address_map.items()}
        assert len(reverse) == len(address_map)
        range_origins = []
        for event in metadata_inventory['update_events']:
            if event['meta'] != 'range_type':
                continue
            assert event['origin'] == 'raw'
            (kts, new_ts), (kls, new_ls) = event['arguments']
            assert (kts, kls) == (1, 2)
            old_ts, old_ls = reverse[new_ts], reverse[new_ls]
            ts(old_ts)
            symbol(old_ls, 'range_metadata_projection')
            range_origins.append({'new_type_symbol': new_ts, 'old_type_symbol': old_ts,
                                  'new_logic_symbol': new_ls, 'old_logic_symbol': old_ls})
        for row in graph['declarations']:
            node, news, _tag = raw.fields(row['declaration'], 3)
            kind = row['kind']
            value, = raw.fields(node, 1, tag=kind)
            for name, _unit in raw.mapping(news):
                ident(name, 'declared_identifier')
            if kind == 0:
                ts(value)
            elif kind == 1:
                for entry in raw.seq(value):
                    head, cs = raw.fields(entry, 2)
                    ts(head)
                    for item in raw.seq(cs):
                        c, projections = raw.fields(item, 2)
                        constructors.add(c)
                        symbol(c, 'data_constructor')
                        for projection in raw.seq(projections):
                            if projection != 1:
                                pj, = raw.fields(projection, 1)
                                symbol(pj, 'data_projection')
            elif kind == 2:
                symbol(value, 'parameter_head')
            elif kind == 3:
                for item in raw.seq(value):
                    ls, definition = raw.fields(item, 2)
                    assert raw.fields(definition, 3)[0] == ls
                    symbol(ls, 'definition_head')
            elif kind == 4:
                _sign, entries = raw.fields(value, 2)
                for entry in raw.seq(entries):
                    ls, clauses = raw.fields(entry, 2)
                    symbol(ls, 'inductive_head')
                    for clause in raw.seq(clauses):
                        pr, _formula = raw.fields(clause, 2)
                        proposition(pr)
            else:
                assert kind == 5
                _pk, pr, _formula = raw.fields(value, 3)
                proposition(pr)
        for p, row in graph['symbols'].items():
            p = int(p)
            symbol(p)
            name = raw.fields(p, 5)[0]
            assert identifiers[name]['name'] == row['name']
            assert identifiers[name]['attrs'] == row['attrs']
        positive_names = set()
        for p, row in graph['variables'].items():
            ty(row['type'])
            if int(p) > 0:
                observed = variable(int(p))
                assert (observed['name'], observed['attrs']) == (row['name'], row['attrs'])
                positive_names.add(observed['name'])
        for row in graph['terms']:
            if row['type'] is not None:
                ty(row['type'])
        # Check original typed inventory coverage and raw bytes without replaying
        # its extraction or its transformation models.
        for p, row in typed['identifiers'].items():
            p = ident(int(p), 'retained_R56_identifier')
            assert (identifiers[p]['name'], identifiers[p]['attrs']) == (row['name'], row['attrs'])
        # These symbolic variable names are already accepted R51 products. The
        # independent bound below needs only the source copy/'unused origin rule.
        synthetic = [row for p, row in graph['variables'].items() if int(p) < 0]
        allowed = positive_names | {s + "'unused" for s in positive_names}
        assert all(row['name'] in allowed for row in synthetic)
        attr_union = sorted({a for row in identifiers.values() for a in row['attrs']})
        def maximum(ids):
            rows = [(identifiers[p]['bytes'], p) for p in ids]
            n = max((n for n, _ in rows), default=0)
            return {'bytes': n, 'witnesses': [p for value, p in rows if value == n][:8]}
        initial = maximum(identifiers)
        cons_names = [raw.fields(p, 5)[0] for p in constructors]
        result = {
            'case': case,
            'capture': {'archive': inp['archive'], 'member': inp['member'], 'identity': identity(payload),
                        'additional_member': secondary if raw.secondary_identity else None,
                        'additional_member_identity': raw.secondary_identity},
            'accepted_graph_identity': identity(graph_path.read_bytes()),
            'accepted_types_identity': identity(type_path.read_bytes()),
            'range_metadata_origin_rows': range_origins,
            'address_map_file': str(map_path.relative_to(ROOT)),
            'address_map_identity': identity(map_path.read_bytes()),
            'accepted_metadata_inventory_identity': identity(metadata_path.read_bytes()),
            'no_raw_or_selected_Z3_introduced_symbol_metadata': True,
            'logical_declarations_walked': len(graph['declarations']),
            'logic_signatures_walked': len(symbols), 'type_nodes_walked': len(type_nodes),
            'type_symbols_walked': len(type_symbols), 'physical_variables_walked': len(variables),
            'synthetic_variable_names_checked': len(synthetic), 'captured_blocks_read': len(raw.reads),
            'initial_all_identifier_bytes_max': initial,
            'initial_constructor_bytes_max': maximum(cons_names),
            'initial_proposition_bytes_max': maximum(proposition_ids),
            'all_identifier_spellings_ASCII': True,
            'identifier_attribute_union': attr_union,
            'identifier_attribute_at_prefix_count': sum(a.startswith('at:') for a in attr_union),
            'identifier_attribute_max_bytes': max(map(len, attr_union), default=0),
            'identifiers': {str(p): {**row, 'roles': sorted(roles[p])} for p, row in sorted(identifiers.items())},
            'L_interface': max(initial['bytes'] + 7, 8),
            'L_uses_monotone_name_origin_argument_not_exhaustive_future_capture': True,
        }
    return result


if __name__ == '__main__':
    for case in CASES:
        r = project(case)
        (HERE / (case + '-names.json')).write_text(json.dumps(r, indent=2) + '\n')
        print(case, r['initial_all_identifier_bytes_max'], 'L', r['L_interface'],
              'identifiers', len(r['identifiers']), 'at:', r['identifier_attribute_at_prefix_count'], flush=True)
