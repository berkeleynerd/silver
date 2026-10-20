#!/usr/bin/env python3
"""Replay the previously unchecked suffix of four retained stopped captures.

No native process, solver, binder analysis or prior session replay is executed.
Each read after the accepted session-prefix boundary must match in order, and
the complete log is hashed. Observations describe those endpoints only.
"""
import argparse
import ast
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import sys
import tarfile
import tempfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
DOMAIN = EVIDENCE / 'retained-why-fixed-session-domain-20261020'


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def file_identity(path):
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            size += len(chunk)
            digest.update(chunk)
    return {'bytes': size, 'sha256': digest.hexdigest()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Packet:
    def __init__(self, spec):
        self.spec = spec
        self.path = DOMAIN / spec['path']
        assert file_identity(self.path) == {k: spec[k] for k in ('bytes', 'sha256')}
        self.members = {row['path']: row for row in spec['members']}
        assert len(self.members) == len(spec['members'])
        self.archive = tarfile.open(self.path)

    def raw(self, name):
        member = self.archive.getmember(name)
        assert member.isfile()
        raw = self.archive.extractfile(member).read()
        expected = self.members[name]
        assert identity(raw) == {k: expected[k] for k in ('bytes', 'sha256')}, name
        return raw

    def json(self, name):
        return json.loads(self.raw(name))


class Reader:
    def __init__(self, stream):
        self.stream = stream
        self.count = 0
        self.digest = hashlib.sha256()
        self.size = 0

    def line(self):
        raw = self.stream.readline()
        assert raw, ('unexpected end of read log', self.count)
        self.digest.update(raw)
        self.size += len(raw)
        self.count += 1
        return raw

    def read(self, address, size=8):
        row = json.loads(self.line())
        assert (row['address'], row['bytes']) == (address, size), ('read differs', self.count)
        raw = bytes.fromhex(row['hex'])
        assert len(raw) == size
        return raw

    def finish(self, expected):
        assert self.stream.read(1) == b'', 'unconsumed suffix'
        assert {'bytes': self.size, 'sha256': self.digest.hexdigest()} == {
            k: expected[k] for k in ('bytes', 'sha256')}


def run_case(case, common, archive_spec, scratch, counter, representative):
    start = time.perf_counter()
    packet = Packet(archive_spec)
    prefix = case['case'] + '/capture/'
    try:
        plan = common.json('plan.json')
        selected, = [row for row in plan['inputs'] if row['name'] == case['case']]
        get = lambda name: packet.json(prefix + name)
        summary, process, result = get('summary.json'), get('process.json'), get('result.json')
        assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
        assert not summary['new_threads'] and not summary.get('auxiliary_failures')
        assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
        assert result['completed'] and result['returncode'] == 0 and not result['timed_out']
        assert not result['failures'] and process['initial_threads'] == 1
        assert process['pid'] == case['pid']
        assert process['argv'] == selected['argv'] and process['environment'] == selected['environment']
        assert identity(packet.raw(case['case'] + '/' + selected['argv'][-1])) == selected['input']
        binary = selected['argv'][0]
        assert summary['mapped_files'][binary] == plan['file_identities'][binary]
        ident, table, graph, aux = [get(name) for name in (
            'identifier-state.json', 'hsdecl-table.json', 'representative-graph.json', 'auxiliary-state.json')]
        for name, expected in (
            ('identifier-state.json', summary['identifier_state']['identity']),
            ('hsdecl-table.json', summary['hsdecl_table']['identity']),
            ('representative-graph.json', summary['representative_graph']['identity']),
            ('auxiliary-state.json', summary['auxiliary_state']['identity'])):
            assert identity(packet.raw(prefix + name)) == expected
        assert aux['complete']
        addresses = {}

        def address_join(name, value):
            assert name not in addresses or addresses[name] == value
            addresses[name] = value

        for record in (ident, table):
            for name, row in record['instruction_checks'].items():
                address_join(name, row['address'])
        address_join('camlWhy3__Ident', ident['module']['address'])
        address_join('camlWhy3__Decl', table['module_address'])
        address_join('caml_ephe_none', aux['ephe_none_symbol'])
        assert table['ephe_none_symbol'] == aux['ephe_none_symbol']
        for row in aux['hashcons'].values():
            address_join(row['module']['symbol'], row['module']['address'])
        address_join('camlWhy3__Task', aux['Task.Stdecl']['module']['address'])
        read_member = packet.archive.getmember(prefix + 'memory-reads.jsonl')
        assert read_member.isfile()
        with packet.archive.extractfile(read_member) as stream:
            reader = Reader(stream)
            skipped = case['exact_session_replay']['sequential_reads']
            for _ in range(skipped):
                reader.line()  # Accepted prefix; hash without replaying it.
            with tempfile.TemporaryDirectory(prefix='registration-state-', dir=scratch) as directory:
                out = Path(directory)
                env = dict(OUT=out, PLAN=plan, SUMMARY={}, save=lambda: None,
                           data=reader.read, address=lambda name: addresses[name],
                           decode_tagged=representative.decoded, json=json, struct=struct,
                           identity=file_identity)
                # Execute only the exact three dependency-free helper bodies,
                # never the GDB module, setup, breakpoints or inferior reads.
                tree = ast.parse(common.raw('probe.py'))
                names = {'u64', 'block_fields', 'raw_graph'}
                nodes = [node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name in names]
                assert len(nodes) == len(names) and {node.name for node in nodes} == names
                exec(compile(ast.Module(body=nodes, type_ignores=[]), '<retained helpers>', 'exec'), env)
                exec(compile(common.raw('snapshot-observer.py'), '<retained snapshot observer>', 'exec'), env)
                exec(compile(common.raw('table-observer.py'), '<retained table observer>', 'exec'), env)
                try:
                    assert env['capture_identifier']() == ident
                    roots = env['read_table_state']()
                    replayed_graph = env['raw_graph'](roots)
                    replayed_graph['scope'] = graph['scope']
                    assert replayed_graph == graph
                    assert env['capture_auxiliary']() == aux
                    for name in ('identifier-state.json', 'hsdecl-table.json', 'auxiliary-state.json'):
                        assert (out / name).read_bytes() == packet.raw(prefix + name), name
                finally:
                    env['_memory_log'].close()
            reader.finish(packet.members[prefix + 'memory-reads.jsonl'])
        representative.validate_graph(graph)
        graph_with_roots = dict(graph, input_declaration_roots=[], hsdecl_declaration_roots=graph['roots'])
        maximum = representative.validate_table(table, graph_with_roots)
        observed = counter.auxiliary_observations(aux, representative.decoded)
        private_counter = representative.decoded(ident['counter']['fields'][0])
        assert private_counter == ident['counter']['decoded'] == summary['identifier_state']['counter']
        return {
            'case': case['case'], 'unit': case['unit'], 'pid': case['pid'],
            'endpoint': case['endpoint'], 'phase': case['phase'],
            'accepted_prefix_reads_not_replayed': skipped,
            'suffix_reads_replayed_in_order': reader.count - skipped,
            'total_read_log_lines_hashed': reader.count,
            'private_identifier_counter': private_counter,
            'Hsdecl': {**{k: table[k] for k in ('next_tag', 'outer_length', 'allocated_key_slots',
                'nonempty_key_slots', 'limit', 'oversize', 'rover')},
                'maximum_bucket_length': maximum, 'retained_unique_declarations': len(graph['roots']),
                'continuing_capacity_established': False},
            'representative_graph_blocks': len(graph['blocks']),
            'auxiliary_observations': observed,
            'byte_equal_projection_files': 3, 'representative_graph_structurally_equal': True,
            'scope': 'Stopped registration endpoint only; no freshness, no-wrap history or later-state transfer',
            'elapsed_seconds': time.perf_counter() - start,
        }
    finally:
        packet.archive.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case', action='append', choices=('put_line', 'put', 'first_or_default', 'is_message'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--scratch', type=Path, required=True)
    args = parser.parse_args()
    started = time.perf_counter()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['dependencies'].items():
        assert file_identity(REPO / name) == expected, name
    manifest = json.loads((DOMAIN / 'capture-manifest.json').read_text())
    cases = json.loads((DOMAIN / 'summary.json').read_text())['cases'][:4]
    if args.case:
        cases = [case for case in cases if case['case'] in args.case]
    sys.path.insert(0, str(EVIDENCE / 'retained-why-inline-identifier-state-20261018'))
    counter = load('fixed_registration_counter', EVIDENCE / 'retained-why-inline-identifier-state-20261018/compose.py')
    representative = load('fixed_registration_representative', EVIDENCE / 'retained-why-inline-representative-state-20261018/project.py')
    common_spec, = [row for row in manifest['archives'] if row['path'] == 'capture-common.tar.gz']
    common = Packet(common_spec)
    args.scratch.mkdir(parents=True, exist_ok=True)
    rows = []
    try:
        for case in cases:
            name = 'capture-' + case['case'].replace('_', '-') + '.tar.gz'
            spec, = [row for row in manifest['archives'] if row['path'] == name]
            row = run_case(case, common, spec, args.scratch, counter, representative)
            rows.append(row)
            print(json.dumps({k: row[k] for k in ('case', 'private_identifier_counter', 'suffix_reads_replayed_in_order', 'elapsed_seconds')}), flush=True)
    finally:
        common.archive.close()
    output = {
        'scope': 'Sequential offline replay of four previously unchecked registration-state suffixes',
        'cases': rows, 'native_runs': 0, 'binder_analyses': 0, 'accepted_session_replays_repeated': 0,
        'Input_Is_Valid': 'Prior accepted PID 97103 replay reused separately; no new replay here',
        'ordinary_ending_capacity_established': False, 'issue153_complete': False,
        'elapsed_seconds': time.perf_counter() - started,
    }
    args.output.write_text(json.dumps(output, indent=2) + '\n')


if __name__ == '__main__':
    main()
