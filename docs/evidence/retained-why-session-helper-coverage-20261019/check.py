#!/usr/bin/env python3
"""Offline exact-read coverage for the current formatter's missing descendants."""
import argparse
import bisect
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
STATE = HERE.parent / 'retained-why-session-save-state-20261019'
PREFIX = 'input_is_valid/capture/'


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def check():
    manifest = json.loads((STATE / 'capture-identities.json').read_text())
    raw = (STATE / 'capture.tar.gz').read_bytes()
    assert identity(raw) == manifest['identity'] == {
        'bytes': 12297103, 'sha256': '583b69d7acc87323f6c6c69e525825da29b1c2ea3141130f7d2bc065f7ea632c'}
    with tarfile.open(STATE / 'capture.tar.gz') as archive:
        def member(name):
            value = archive.extractfile(PREFIX + name).read()
            assert identity(value) == manifest['members'][PREFIX + name]
            return value
        metadata = json.loads(member('session-observer.json'))
        helpers = json.loads(member('exit-hook-roots.json'))
        blocks = {r['address']: r for r in map(json.loads, member('session-blocks.jsonl').splitlines())}
        formatter = helpers['formatter_record']
        row = blocks[formatter]
        assert row['tag'] == 0 and row['words'] == 28
        fields = struct.unpack('<' + 'Q' * 28, bytes.fromhex(row['payload_hex']))
        targets = {value: {'label': 'Debug formatter field ' + str(index),
                           'address': value, 'bytes': 8, 'overlapping_reads': 0}
                   for index, value in enumerate(fields) if value % 2 == 0}
        # Literal ELF module address and offsets from the retained,
        # byte-matched flush_standard_formatters body in the state packet.
        for offset in (0x360, 0x368):
            address = metadata['load_bias'] + 0xf8b0f0 + offset
            targets[address] = {'label': 'camlStdlib__Format+' + hex(offset),
                                'address': address, 'bytes': 8, 'overlapping_reads': 0}
        keys = sorted(targets)
        count = 0
        for count, line in enumerate(member('memory-reads.jsonl').splitlines(), 1):
            record = json.loads(line)
            lo, size = record['address'], record['bytes']
            assert len(bytes.fromhex(record['hex'])) == size
            hi = lo + size
            for address in keys[bisect.bisect_left(keys, lo - 7):bisect.bisect_left(keys, hi)]:
                assert lo < address + 8 and address < hi
                targets[address]['overlapping_reads'] += 1
        assert count == 835579
        assert all(row['overlapping_reads'] == 0 for row in targets.values())
        return {'pid': metadata['pid'], 'load_bias': metadata['load_bias'],
                'formatter_record': formatter, 'formatter_words': len(fields),
                'core_raw_read_records_scanned': count, 'targets': list(targets.values()),
                'target_word_count': len(targets), 'complete_R': False,
                'scope': 'Absence of overlap with these exact 18 runtime words, not a claim about arbitrary descendants or source-prefix invariance',
                'native_runs': 0, 'objdump_runs': 0, 'solver_runs': 0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    result = check()
    if args.write:
        (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == json.loads((HERE / 'result.json').read_text())
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - start,
                      'reads': result['core_raw_read_records_scanned'],
                      'unobserved_words': result['target_word_count']}))
