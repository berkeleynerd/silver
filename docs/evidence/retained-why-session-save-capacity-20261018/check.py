#!/usr/bin/env python3
"""Check frozen missing-root evidence; read archives/ELF as data, never execute Why.

This is coverage and identity checking, not session reconstruction or a proof
that the native binary refines every cited source operation.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import tarfile
import time

P = Path(__file__).resolve().parent
ROOT = P.parents[2]
PRE = P.parent / 'retained-why-inline-callback-closure-20261018'
CAPTURE = P.parent / 'retained-why-inline-identifier-state-20261018/capture.tar.gz'
spec = importlib.util.spec_from_file_location('retained_elf', PRE / 'audit.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def inspect_capture(elf):
    with tarfile.open(CAPTURE) as archive:
        def read(name):
            return archive.extractfile(name).read()
        def obj(name):
            return json.loads(read(name))
        ids = obj('capture/identifier-state.json')
        base = ids['module']['address'] - elf.symbols['camlWhy3__Ident']['value']
        targets = []
        for name, offset in [('caml_signal_handlers', 0), ('camlStdlib', 0x338),
                             ('camlWhy3__Debug', 0x128)]:
            sym = elf.symbols[name]
            targets.append({
                'symbol': name, 'offset': offset,
                'elf_value': sym['value'], 'runtime_address': base + sym['value'] + offset,
                'bytes': 8, 'section': elf.sections[sym['shndx']]['name'],
                'overlapping_read_records': []})
        count = 0
        for count, line in enumerate(archive.extractfile('capture/memory-reads.jsonl'), 1):
            row = json.loads(line)
            assert row['bytes'] == len(bytes.fromhex(row['hex']))
            for target in targets:
                lo = max(row['address'], target['runtime_address'])
                hi = min(row['address'] + row['bytes'], target['runtime_address'] + 8)
                if lo < hi:
                    target['overlapping_read_records'].append(count)
        summary = obj('capture/summary.json')
        graph = obj('capture/inline-entry-graph.json')
        prep, = summary['driver_preparation']
        run = read('run.py').decode()
        prepare = read('prepare-snapshot.py').decode()
        assert "==sorted([case['argv'][-1],'why3.conf','temp'])" in run
        assert "assert not list((Path(case['cwd'])/'temp').iterdir())" in run
        assert "cwd.mkdir();(cwd/'temp').mkdir()" in prepare
        selected_members = ['run.py', 'prepare-snapshot.py', 'entry-observer.py',
                            'snapshot-observer.py', 'capture/memory-reads.jsonl',
                            'capture/summary.json', 'capture/inline-entry-graph.json',
                            'capture/identifier-state.json', 'capture/process.json',
                            'input/silver_arguments__input_is_valid.gnat-json']
        return {
            'process_pid': obj('capture/process.json')['pid'],
            'load_bias': base, 'raw_read_records': count, 'root_coverage': targets,
            'archive_members': [m.name for m in archive.getmembers()],
            'selected_member_identities': {n: identity(read(n)) for n in selected_members},
            'initial_cwd_entries_asserted_by_harness':
                ['silver_arguments__input_is_valid.gnat-json', 'why3.conf', 'temp'],
            'initial_temp_empty_asserted_by_harness': True,
            'session_xml_or_shapes_archive_members': [m.name for m in archive.getmembers()
                                                     if 'why3session' in m.name or 'why3shapes' in m.name],
            'session_xml_or_shapes_observed_opens': [r for r in summary['file_opens']
                                                   if 'why3session' in r['path'] or 'why3shapes' in r['path']],
            'driver_prepare': {
                'input_task': prep['input_task'],
                'input_task_chain_length': prep['input_shape']['chain_length'],
                'visited_directives': prep['visited_directives']},
            'inline_entry': {
                'task': graph['task_address'], 'ordered_tdecls': len(graph['ordered_tdecls']),
                'input_declaration_roots': len(graph['input_declaration_roots']),
                'hsdecl_declaration_roots': len(graph['hsdecl_declaration_roots']),
                'retained_blocks': len(graph['blocks']), 'scope': graph['scope']},
            'counter': ids['counter']['decoded'],
            'completed': summary['completed'], 'failures': summary['failures'],
            'guard_hits': summary['guard_hits'],
            'claim': 'These three runtime root words are unobserved. Some descendant bytes may overlap retained task/table graphs; no complete session join is established.'}


def main():
    started = time.monotonic()
    inputs = json.loads((P / 'inputs.json').read_text())
    for name, expected in inputs['reused_files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_inputs'].items():
        assert identity((P / name).read_bytes()) == expected, name
    data = Path(inputs['executable']['path']).read_bytes()
    assert identity(data) == inputs['executable']['identity']
    elf = audit.ELF(data)
    observed = inspect_capture(elf)
    assert observed == json.loads((P / 'capture-coverage.json').read_text())
    assert all(not r['overlapping_read_records'] for r in observed['root_coverage'])
    assert observed['completed'] and not observed['failures'] and not observed['guard_hits']
    native = json.loads((P / 'native-layout.json').read_text())
    instruction_bytes = 0
    for name, row in native['bodies'].items():
        symbol = elf.symbols[name]
        assert row['address'] == symbol['value'] and row['symbol_size'] == symbol['size']
        cursor = row['address']
        for r in row['instructions']:
            raw = bytes.fromhex(r['hex'])
            assert r['address'] == cursor
            assert elf.read(cursor, len(raw)) == raw
            cursor += len(raw)
            instruction_bytes += len(raw)
        assert cursor >= row['address'] + row['symbol_size']
    with tarfile.open(P / 'sources.tar.gz') as archive:
        index = json.load(archive.extractfile('source-index.json'))
        assert set(archive.getnames()) == {'source-index.json', *index}
        for name, row in index.items():
            assert identity(archive.extractfile(name).read()) == row['identity']
    plan = json.loads((P / 'observer-plan.json').read_text())
    result = json.loads((P / 'result.json').read_text())
    assert plan['executed'] is False
    assert result['B_binders'] is None and result['R'] is None
    assert result['accepted_accounted_endpoint'] == 61641
    assert not result['complete_save_charge'] and not result['complete_callback_capacity']
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - started,
                      'raw_read_records_checked': observed['raw_read_records'],
                      'unobserved_runtime_root_words': len(observed['root_coverage']),
                      'native_bodies': len(native['bodies']), 'native_bytes_checked': instruction_bytes,
                      'new_target_runs': 0, 'new_debugger_runs': 0, 'new_objdump_runs': 0}))


if __name__ == '__main__':
    main()
