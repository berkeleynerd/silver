#!/usr/bin/env python3
"""Attach retained prefix charges to channel constructors; no target execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INITIAL = 'docs/evidence/retained-why-initial-registration-bound-20261020/result.json'
NAMES = {
    'caml_open_descriptor_in', 'caml_open_descriptor_out',
    'caml_alloc_channel', 'caml_ml_open_descriptor_in',
    'caml_ml_open_descriptor_out', 'caml_ml_out_channels_list',
    'caml_finalize_channel', 'caml_ml_close_channel',
    'caml_alloc_custom_mem', 'alloc_custom_gen', 'caml_alloc_small',
}
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')


def read(path):
    return json.loads(path.read_text())


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def derive():
    inputs = read(HERE / 'inputs.json')
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_files'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    slices = read(HERE / 'source-witnesses.json')
    for archive in {r['archive'] for r in slices}:
        with tarfile.open(ROOT / archive) as stream:
            cache = {}
            for row in (r for r in slices if r['archive'] == archive):
                member = row['member']
                if member not in cache:
                    cache[member] = stream.extractfile(member).read()
                raw = cache[member]
                assert identity(raw) == row['member_identity']
                assert ''.join(raw.decode().splitlines(keepends=True)[
                    row['first_line']-1:row['last_line']]) == row['text']
    meta = read(HERE / 'native-witnesses.json')
    binary = Path(meta['executable']['path']).read_bytes()
    assert identity(binary) == meta['executable']['identity']
    assert binary[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', binary, 32)[0]
    size, count = struct.unpack_from('<HH', binary, 54)
    loads = []
    for i in range(count):
        kind, flags, off, addr, _, n, _, _ = struct.unpack_from(
            '<IIQQQQQQ', binary, phoff+i*size)
        if kind == 1 and flags & 1:
            loads.append((addr, addr+n, off))
    bodies = read(HERE / 'native-bodies.json')
    assert set(bodies) == NAMES
    checked = 0
    for name, body in bodies.items():
        assert re.match(r'[0-9a-f]+ <'+re.escape(name)+r'>:', body)
        for line in body.splitlines():
            if not (m := INSN.match(line)):
                continue
            addr, raw = int(m[1], 16), bytes.fromhex(m[2])
            assert any(lo <= addr and addr+len(raw) <= hi and
                       binary[off+addr-lo:off+addr-lo+len(raw)] == raw
                       for lo, hi, off in loads), name
            checked += len(raw)
    assert checked == meta['instruction_bytes']
    for name in ['caml_alloc_channel', 'caml_ml_open_descriptor_in',
                 'caml_ml_open_descriptor_out', 'caml_ml_out_channels_list']:
        body = bodies[name]
        assert len(re.findall(r'addl\s+\$0x1,0x40\(', body)) == 1
        assert re.search(r'mov\s+\$0x8,%esi', body)
        assert '<caml_alloc_custom_mem>' in body
    assert re.search(r'movq\s+\$0x0,0x40\(', bodies['caml_open_descriptor_in'])
    assert '<caml_alloc_small>' in bodies['alloc_custom_gen']
    assert '<alloc_custom_gen>' in bodies['caml_alloc_custom_mem']
    prior = read(ROOT / INITIAL)
    assert prior['initial_no_wrap_established_under_named_relation']
    rows = []
    for row in prior['cases']:
        b = row['minor_allocated_words']
        q = b // 3
        assert 0 <= 3*q <= b < 3*(q+1)
        # Use only completed increments preceding the first unsafe C increment.
        assert b < 2**28 < 3*(2**31-1)
        assert q < 2**31-1
        rows.append({
            'case': row['case'], 'pid': row['pid'], 'endpoint': row['endpoint'],
            'minor_words': b, 'initial_wrapper_increments_upper': q,
            'initial_managed_channels_upper': q,
            'initial_managed_output_channels_upper': q,
            'initial_each_refcount_upper': q,
            'additional_increment_headroom_to_INT_MAX': 2**31-1-q,
            'actual_channel_census_measured': False,
        })
    assert len(rows) == 5
    return {
        'scope': 'Five debugger-controlled prefixes under existing source/runtime relation',
        'cases': rows,
        'conditional_initial_count_and_no_wrap_established': True,
        'unmanaged_channel_count_upper': None,
        'post_cut_wrapper_attempts_upper': None,
        'post_cut_channel_capacity_established': False,
        'complete_channel_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
        'native_runs': 0, 'predecessor_checker_replays': 0,
        'new_disassembler_runs': 0, 'native_bodies': len(bodies),
        'checked_native_bytes': checked, 'source_slices': len(slices),
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    result = derive()
    raw = (json.dumps(result, indent=2)+'\n').encode()
    if args.write:
        (HERE / 'result.json').write_bytes(raw)
    else:
        assert (HERE / 'result.json').read_bytes() == raw
    print(json.dumps({'status': 'pass', 'cases': len(result['cases']),
                     'native_bodies': result['native_bodies'],
                     'native_bytes': result['checked_native_bytes'],
                     'source_slices': result['source_slices'],
                     'elapsed_seconds': time.monotonic()-start,
                     'native_runs': 0, 'predecessor_checker_replays': 0}, indent=2))
