#!/usr/bin/env python3
"""Replay only a retained session observer's exact sequential raw reads offline."""
import argparse
import hashlib
import json
from pathlib import Path
import tempfile

from session_observer import SessionCapture, DEFAULT_LIMITS


class Reader:
    def __init__(self, path):
        self.file = path.open()
        self.count = 0

    def read(self, address, size):
        line = self.file.readline()
        if not line:
            raise AssertionError(('raw-read log exhausted', address, size))
        row = json.loads(line)
        assert (row['address'], row['bytes']) == (address, size), ('read sequence differs', row, address, size)
        raw = bytes.fromhex(row['hex'])
        assert len(raw) == size
        self.count += 1
        return raw


def replay(capture, scratch, limits=DEFAULT_LIMITS):
    metadata = json.loads((capture / 'session-observer.json').read_text())
    for name, expected in metadata.get('core_join', {}).items():
        raw = (capture / name).read_bytes()
        assert {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()} == expected, name
    if 'core_join' in metadata:
        assert json.loads((capture / 'process.json').read_text())['pid'] == metadata['pid']
    plan_path = capture.parent.parent / 'plan.json'
    if plan_path.is_file():
        spec = json.loads(plan_path.read_text())['session_observer']
        assert metadata['limits'] == spec['limits']
        limits = metadata['limits']
        for name, row in spec['symbols'].items():
            assert metadata['symbols'][name] == metadata['load_bias'] + row['elf_value']
        for row in metadata['code_checks']:
            assert row['hex'] == spec['symbols'][row['symbol']]['code_hex']
    reader = Reader(capture / 'session-memory-reads.jsonl')
    try:
        for row in metadata['code_checks']:
            assert reader.read(row['address'], row['bytes']).hex() == row['hex']
        with tempfile.TemporaryDirectory(prefix='session-replay-', dir=scratch) as temp:
            out = Path(temp)
            observer = SessionCapture(reader.read, metadata['symbols'].__getitem__, out, limits)
            observer.capture_roots()
            observer.capture_session()
            observer.capture_helpers()
            observer.close()
            assert not reader.file.readline(), 'unconsumed raw reads'
            files = sorted(p.name for p in out.iterdir())
            for name in files:
                assert (capture / name).read_bytes() == (out / name).read_bytes(), ('replay output differs', name)
            return {'status': 'pass', 'raw_reads': reader.count, 'files': files,
                    'session_complete': observer.session_result['complete'],
                    'helper_roots_complete': observer.helper_result['complete'], 'complete_R': False}
    finally:
        reader.file.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('capture', type=Path)
    parser.add_argument('--scratch-root', type=Path, required=True)
    args = parser.parse_args()
    args.scratch_root.mkdir(parents=True, exist_ok=True)
    print(json.dumps(replay(args.capture, args.scratch_root)))
