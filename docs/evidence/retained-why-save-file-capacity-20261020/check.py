#!/usr/bin/env python3
"""Check new save-file witnesses and arithmetic; no predecessor replay."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import file_bounds, PREMISES, MAX_OFFSET, MAX_STRING

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def derive():
    states = json.loads((ROOT / 'docs/evidence/retained-why-save-state-join-20261020/result.json').read_text())
    joined = json.loads((ROOT / 'docs/evidence/retained-why-save-round32-20261020/result.json').read_text())
    xml_cases = joined['under_named_existing_external_premises']['cases']
    assert [(x['case'], x['pid']) for x in xml_cases] == [
        (x['case'], x['new_pid']) for x in states['cases']]
    cases = []
    supplied = {name: True for name in PREMISES}
    progress = 'positive_count_write_returns_positive_or_interrupts_or_raises'
    for state, xml in zip(states['cases'], xml_cases):
        op = state['conditional_operational_transfer']
        entry = state['captured_entry']
        chunk = max(xml['candidate_B'], op['dictionary_string_bytes_upper'],
                    op['bound_shape_text_bytes_upper'], entry['old_shape_bytes_max'],
                    entry['checksum_bytes_max'], 128)
        args = [entry['session_dir_bytes'],
                xml['format_core']['core_bounds']['offered_xml_bytes_upper'],
                op['shape_file_bytes_per_save_upper'], chunk,
                op['conditional_save_entries']]
        assert args[-1] == 3
        conditional = file_bounds(*args, premises=supplied)
        assert all(conditional['guards'].values())
        assert conditional['candidate']['filename_including_backup_bytes_upper'] == op['filename_including_backup_bytes_upper']
        assert conditional['candidate']['new_descriptor_and_channel_attempts_upper'] == op['channel_open_calls_upper']
        cases.append({'case': state['case'], 'pid': state['new_pid'],
                      'inputs': dict(zip(('directory_bytes', 'xml_bytes', 'shape_bytes',
                                          'max_argument_string', 'save_entries'), args)),
                      'no_external_assertion': file_bounds(*args),
                      'without_positive_write_contract': file_bounds(*args, premises={**supplied, progress: False}),
                      'under_named_conditional_contracts': conditional})
    return {'scope': 'Selected new save descriptors/paths; positive-write service attachment remains open',
            'positive_write_service_attachment_established': False,
            'source_semantic_argument_machine_proved': False,
            'cases': cases, 'native_runs': 0, 'predecessor_checker_replays': 0}


def check():
    start = time.monotonic()
    pins = json.loads((HERE / 'inputs.json').read_text())
    for path, expected in pins['files'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    for path, expected in pins['local_files'].items():
        assert identity((HERE / path).read_bytes()) == expected, path
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    archives = {}
    try:
        for witness in witnesses:
            name = witness['archive']
            if name not in archives:
                archives[name] = tarfile.open(ROOT / name)
            raw = archives[name].extractfile(witness['member']).read()
            assert identity(raw) == witness['member_identity']
            lines = raw.decode().splitlines(keepends=True)
            assert ''.join(lines[witness['first_line']-1:witness['last_line']]) == witness['text']
    finally:
        for archive in archives.values():
            archive.close()
    native = json.loads((HERE / 'native-witnesses.json').read_text())
    elf = Path(native['executable']['path']).read_bytes()
    assert identity(elf) == native['executable']['identity']
    assert identity(Path(native['retained_disassembly']['path']).read_bytes()) == native['retained_disassembly']['identity']
    phoff = struct.unpack_from('<Q', elf, 32)[0]
    entsize, count = struct.unpack_from('<HH', elf, 54)
    loads = [struct.unpack_from('<IIQQQQQQ', elf, phoff+i*entsize) for i in range(count)]
    bodies = json.loads((HERE / 'native-bodies.json').read_text())
    pattern = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')
    checked = 0
    for body in bodies.values():
        for line in body.splitlines():
            match = pattern.match(line)
            if not match:
                continue
            address = int(match[1], 16)
            instruction = bytes.fromhex(match[2])
            for kind, _, off, va, _, size, _, _ in loads:
                if kind == 1 and va <= address and address+len(instruction) <= va+size:
                    assert elf[off+address-va:off+address-va+len(instruction)] == instruction
                    break
            else:
                raise AssertionError(hex(address))
            checked += len(instruction)
    assert checked == native['instruction_bytes']
    result = derive()
    assert result == json.loads((HERE / 'result.json').read_text())
    supplied = {name: True for name in PREMISES}
    for row in result['cases']:
        args = row['inputs']
        for name in PREMISES:
            assert file_bounds(**args, premises={**supplied, name: False})['selected_file_bounds'] is None
    assert file_bounds(1, MAX_OFFSET, MAX_OFFSET, MAX_STRING, premises=supplied)['selected_file_bounds'] is not None
    assert file_bounds(1, MAX_OFFSET+1, 0, 0, premises=supplied)['selected_file_bounds'] is None
    assert file_bounds(1, 0, MAX_OFFSET+1, 0, premises=supplied)['selected_file_bounds'] is None
    assert file_bounds(1, 0, 0, MAX_STRING+1, premises=supplied)['selected_file_bounds'] is None
    for bad in (-1, True):
        try:
            file_bounds(bad, 0, 0, 0)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid bound accepted')
    return {'status': 'pass', 'source_witnesses': len(witnesses), 'native_bodies': len(bodies),
            'native_instruction_bytes': checked, 'cases': len(result['cases']),
            'missing_premise_checks': len(result['cases'])*len(PREMISES),
            'elapsed_seconds': time.monotonic()-start, 'native_runs': 0,
            'positive_write_service_attachment_established': False}


if __name__ == '__main__':
    print(json.dumps(check(), indent=2))
