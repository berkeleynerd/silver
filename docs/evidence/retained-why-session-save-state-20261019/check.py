#!/usr/bin/env python3
"""Offline checks for PID 97103 only. No target, debugger or solver execution."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import sys
import tarfile
import tempfile
import time

from binders import certificate

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent
REPO = EVIDENCE.parent.parent
PREFIX = 'input_is_valid/capture/'


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def archive(path):
    with tarfile.open(path) as stream:
        return {m.name: stream.extractfile(m).read() for m in stream.getmembers() if m.isfile()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def run():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['dependencies'].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    for name, expected in inputs['local_inputs'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    manifest = json.loads((HERE / 'capture-identities.json').read_text())
    assert identity((HERE / 'capture.tar.gz').read_bytes()) == manifest['identity']
    contents = archive(HERE / 'capture.tar.gz')
    assert {name: identity(raw) for name, raw in contents.items()} == manifest['members']
    get = lambda name: json.loads(contents[PREFIX + name])
    plan = json.loads(contents['plan.json'])
    prepared = json.loads(contents['prepared.json'])
    frozen = json.loads((EVIDENCE / 'retained-why-session-save-observer-20261018/prepared.json').read_text())
    assert prepared == frozen
    for name, expected in prepared['files'].items():
        assert identity(contents[name]) == expected, name
    process, summary, native = get('process.json'), get('summary.json'), get('result.json')
    metadata, ident, aux = get('session-observer.json'), get('identifier-state.json'), get('auxiliary-state.json')
    assert process['pid'] == metadata['pid'] == 97103
    assert process['initial_threads'] == 1
    assert summary['completed'] and not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
    assert native['returncode'] == 0 and native['completed'] and not native['timed_out'] and not native['failures']
    assert aux['complete'] and not summary.get('auxiliary_failures')
    for name, expected in metadata['core_join'].items():
        assert identity(contents[PREFIX + name]) == expected
    for name, expected in [('inline-entry-graph.json', summary['inline_entry']['graph']),
                           ('hsdecl-table.json', summary['hsdecl_table']['identity']),
                           ('identifier-state.json', summary['identifier_state']['identity']),
                           ('auxiliary-state.json', summary['auxiliary_state']['identity'])]:
        assert identity(contents[PREFIX + name]) == expected
    case, = plan['inputs']
    assert process['argv'] == case['argv'] and process['environment'] == case['environment']
    assert identity(contents['input_is_valid/' + case['argv'][-1]]) == case['input']
    assert summary['mapped_files'][case['argv'][0]] == plan['file_identities'][case['argv'][0]]
    for name, row in ident['instruction_checks'].items():
        assert row['first32'] == plan['shared_observer']['symbols'][name]['first32']
    graph, table = get('inline-entry-graph.json'), get('hsdecl-table.json')
    for name, row in table['instruction_checks'].items():
        assert row['first32'] == plan['table_observer']['symbols'][name]['first32']
    representative = load('representative', EVIDENCE / 'retained-why-inline-representative-state-20261018/project.py')
    representative.validate_graph(graph)
    bucket_max = representative.validate_table(table, graph)
    original = archive(EVIDENCE / 'retained-why-preparation-entry-20261018/capture.tar.gz')
    joined = representative.input_isomorphism(json.loads(original['capture/inline-entry-graph.json']), graph)
    details = json.loads((EVIDENCE / 'retained-why-inline-refinement-20261018/details.json').read_text())
    projection = representative.project(graph, details)
    sys.path.insert(0, str(EVIDENCE / 'retained-why-inline-identifier-state-20261018'))
    counter = load('counter_composition', EVIDENCE / 'retained-why-inline-identifier-state-20261018/compose.py')
    adapted = {('capture/' + name[len(PREFIX):] if name.startswith(PREFIX) else name): raw
               for name, raw in contents.items()}
    scratch = REPO / 'tmp/why-session-save-state-offline-20261019'
    scratch.mkdir(parents=True, exist_ok=True)
    previous_tempdir, tempfile.tempdir = tempfile.tempdir, str(scratch)
    try:
        raw_reads = counter.replay(adapted, plan, ident, aux)
    finally:
        tempfile.tempdir = previous_tempdir
    assert ident['counter']['decoded'] == representative.decoded(ident['counter']['fields'][0]) == summary['identifier_state']['counter'] == 60496
    accepted = json.loads((EVIDENCE / 'retained-why-inline-representative-state-20261018/result.json').read_text())
    registrations = accepted['attached_local_demands']['events']['all_fresh_identifier_registrations_upper']
    assert registrations == 1145
    transfer = counter.registration_transfer(60496, registrations)
    blocks = {}
    for line in contents[PREFIX + 'session-blocks.jsonl'].splitlines():
        row = json.loads(line)
        assert str(row['address']) not in blocks
        assert int.from_bytes(bytes.fromhex(row['header_hex']), 'little') == row['header']
        assert row['tag'] == row['header'] & 255 and row['words'] == row['header'] >> 10
        raw = bytes.fromhex(row['payload_hex'])
        assert len(raw) == row['words'] * 8
        row['fields'] = list(struct.unpack('<' + 'Q' * row['words'], raw))
        blocks[str(row['address'])] = row
    cert = certificate(blocks, get('session-task-chains.json'), get('session-forest.json'))
    assert metadata['driver_input_task'] == summary['driver_preparation'][0]['input_task']
    assert str(metadata['driver_input_task']) in cert['tasks']
    assert metadata['inline_entry_task'] == summary['inline_entry']['task']
    roots = get('session-result.json')['logical_graph']['roots']
    assert set(roots) == {p for t in cert['tasks'].values() for p in t['logical_declarations']}
    # A separate pre-existing explicit-alpha opener checks every retained
    # formula's occurrence totals, independent of the direct count accumulator.
    refiner_module = load('session_refiner', EVIDENCE / 'retained-why-inline-refinement-20261018/refine.py')
    refiner = refiner_module.Refiner({'blocks': blocks, 'roots': roots})
    for pointer, row in cert['formulas'].items():
        nodes, binders, _, _ = refiner.dimensions(refiner.open(int(pointer)))
        assert (nodes, binders) == (row['opened_term_occurrences'], row['opened_binder_occurrences'])
    managed = [json.loads(line) for line in contents['managed/events.jsonl'].splitlines()]
    finished, = [event for event in managed if event['event'] == 'finished']
    helper = get('exit-hook-roots.json')
    native_helpers = json.loads((HERE / 'native-helpers.json').read_text())
    executable = Path(native_helpers['executable']['path']).read_bytes()
    assert identity(executable) == native_helpers['executable']['identity'] == plan['file_identities'][case['argv'][0]]
    audit = load('helper_elf', EVIDENCE / 'retained-why-inline-callback-closure-20261018/audit.py')
    elf = audit.ELF(executable)
    native_bytes = 0
    for name, body in native_helpers['bodies'].items():
        assert body['address'] == elf.symbols[name]['value']
        assert body['symbol_size'] == elf.symbols[name]['size']
        cursor = body['address']
        for instruction in body['instructions']:
            raw = bytes.fromhex(instruction['hex'])
            assert instruction['address'] == cursor and elf.read(cursor, len(raw)) == raw
            cursor += len(raw)
            native_bytes += len(raw)
        assert cursor >= body['address'] + body['symbol_size']
    source_index = json.loads((HERE / 'source-identities.json').read_text())
    assert identity((HERE / 'sources.tar.gz').read_bytes()) == source_index['identity']
    sources = archive(HERE / 'sources.tar.gz')
    assert set(sources) == set(source_index['members'])
    for name, raw in sources.items():
        assert identity(raw) == source_index['members'][name]['identity']
    exit_symbols = []
    for link in helper['exit_chain']:
        closure = link.get('callback', link)
        exit_symbols.append(elf.label(closure['code'] - metadata['load_bias']))
    assert exit_symbols == ['camlWhy3__Debug__fun_3069+0x0',
                            'camlStdlib__Format__flush_standard_formatters_1825+0x0',
                            'camlStdlib__flush_all_236+0x0']
    result = {'pid': process['pid'], 'native_platform': 'linux-x86_64',
              'managed_run': finished['run_id'], 'managed_outcome': finished['outcome'],
              'managed_seconds': finished['duration_seconds'], 'debugger_seconds': native['duration_seconds'],
              'frozen_preparation_files_matched': len(prepared['files']),
              'core_raw_read_records_scanned': raw_reads,
              'private_counter_and_auxiliary_values_replayed': True,
              'input_graph_isomorphism_blocks': len(joined), 'input_declaration_roots': len(graph['input_declaration_roots']),
              'complete_Hsdecl_graph_blocks': len(graph['blocks']), 'Hsdecl_buckets': table['outer_length'],
              'Hsdecl_unique_old_objects': len(graph['hsdecl_declaration_roots']), 'Hsdecl_bucket_max': bucket_max,
              'same_process_representative_projection': {k: v for k, v in projection.items() if k != 'groups'},
              'representative_envelope': accepted['representative_envelope'],
              'registration_transfer': transfer,
              'session_table_bindings': {name: len(table['entries']) for name, table in get('session-tables.json').items()},
              'apn_visits': len(cert['visits']), 'attached_visits': sum(not v['detached'] for v in cert['visits']),
              'distinct_raw_tasks': len(cert['tasks']), 'logical_declaration_roots': len(roots),
              'distinct_prop_formulas': len(cert['formulas']), 'logical_graph_blocks': get('session-result.json')['logical_graph']['blocks'],
              'all_session_and_helper_blocks': len(blocks),
              'all_session_and_helper_payload_bytes': sum((b['words'] + 1) * 8 for b in blocks.values()),
              'finite_opened_states': cert['finite_opened_states'],
              'distinct_nonempty_bv_subst_records': cert['distinct_nonempty_bv_subst_records'],
              'B_binders': cert['B_binders'], 'registered_statistics': len(helper.get('registered_stats', [])),
              'timing_entries': len(helper['timing_table']['entries']),
              'exit_callback_symbols_then_terminal': exit_symbols,
              'native_helper_bodies_checked': len(native_helpers['bodies']),
              'native_helper_bytes_checked': native_bytes,
              'retained_source_files': len(sources),
              'helper_roots_complete': helper['complete'], 'complete_R': False,
              'composed_endpoint_established': False, 'native_runs_by_this_checker': 0, 'solver_runs': 0}
    return result, cert


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    result, cert = run()
    for name, value in [('result.json', result), ('binder-certificate.json', cert)]:
        if args.write:
            (HERE / name).write_text(json.dumps(value, indent=2) + '\n')
        else:
            assert value == json.loads((HERE / name).read_text()), name
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - start, 'result': result}, indent=2))
