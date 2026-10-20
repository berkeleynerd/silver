#!/usr/bin/env python3
"""Reconcile source/native operands and check the new request arithmetic."""
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INT_MAX = 2**31 - 1
SIZE_MAX = 2**64 - 1


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def receive_capacity(line_bytes):
    assert line_bytes >= 1
    capacity = 1024
    while capacity < line_bytes + 1023:
        capacity = 2 * (capacity + 1024)
    return capacity


def virtual_bytes(raw, va, size):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    phoff = struct.unpack_from('<Q', raw, 32)[0]
    phentsize, phnum = struct.unpack_from('<HH', raw, 54)
    for i in range(phnum):
        kind, _, offset, start, _, filesz, _, _ = struct.unpack_from(
            '<IIQQQQQQ', raw, phoff + i * phentsize)
        if kind == 1 and start <= va and va + size <= start + filesz:
            return raw[offset + va - start:offset + va - start + size]
    raise AssertionError((va, size))


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['repository_inputs'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    archive = ROOT / 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
    with tarfile.open(archive) as t:
        for w in witnesses:
            raw = t.extractfile(w['member']).read()
            assert identity(raw) == w['source_identity']
            assert ''.join(raw.decode().splitlines(keepends=True)[
                w['start']-1:w['end']]) == w['text']
    native = json.loads((HERE / 'native-inputs.json').read_text())
    for row in native['inputs']:
        assert identity(Path(row['path']).read_bytes()) == {
            k: row[k] for k in ('bytes', 'sha256')}
    raw = Path(native['inputs'][1]['path']).read_bytes()
    native_bytes = 0
    for rows in native['bodies'].values():
        for row in rows:
            expected = bytes.fromhex(row['hex'])
            assert virtual_bytes(raw, row['va'], len(expected)) == expected
            native_bytes += len(expected)
    # Actual parser operands, not a host ctypes layout guess.
    assert virtual_bytes(raw, 0x3246, 5) == bytes.fromhex('bf38000000')
    assert virtual_bytes(raw, 0x33e0, 5) == bytes.fromhex('bf38000000')
    assert virtual_bytes(raw, 0x3311, 4) == bytes.fromhex('48c1e703')

    protocol = json.loads((ROOT / 'docs/evidence/retained-adapter-protocol-storage-20261020/result.json').read_text())
    rows = protocol['cases']
    attempts = sum(r['run_entries'] for r in rows)
    digit_mass = sum(r['run_entries']*r['positive_ID_digits'] for r in rows)
    assert attempts == 459 and digit_mass == 1257
    interrupt_bytes = 11*attempts + digit_mass
    assert interrupt_bytes == 6306
    scalar_bytes = 2*attempts*56 + interrupt_bytes
    assert scalar_bytes == 57714

    # Check the field partition at empty, ordinary and native-length boundaries.
    partitions = 0
    for header in (b'run', b'runstdin'):
        for args in ([], [b''], [b'abc'], [b'a', b'', b'bc']):
            if header == b'runstdin' and not args:
                continue
            fields = [header, b'192', b'0.', b'0', b'/solver', *args]
            line = b';'.join(fields) + b'\n'
            m = len(args)
            assert line.count(b';') == m + 4
            assert sum(len(f)+1 for f in fields) == len(line)
            partitions += 1
    for m in (0, 1, 63, INT_MAX-2):
        # Pure natural-number algebra; no huge byte array is constructed.
        field_bytes = 3 + 3 + 2 + 1 + 7 + m
        line_bytes = field_bytes + (m+4) + 1
        assert field_bytes + (m+5) == line_bytes
        assert m+2 <= INT_MAX and 8*(m+2) <= SIZE_MAX
        partitions += 1

    # Visit every growth threshold relevant to the signed-length guard.
    boundaries = {1, 2, 1024, INT_MAX-1023}
    c = 1024
    while c < INT_MAX:
        pivot = c-1023
        boundaries.update(x for x in (pivot-1, pivot, pivot+1)
                          if 1 <= x <= INT_MAX-1023)
        c = 2*(c+1024)
    capacities = []
    for m in sorted(boundaries):
        r = receive_capacity(m)
        assert m+1023 <= INT_MAX
        assert 2*(r+1024) <= SIZE_MAX
        assert r >= m+1023
        if r != 1024:
            assert r//2-1024 < m+1023
        # An incomplete prefix and one maximal read fit this capacity.
        assert (m-1)+1024 <= r
        capacities.append(dict(line_bytes=m, capacity=r, old_new_bytes=2*r))
    assert INT_MAX-1023+1+1023 > INT_MAX
    return dict(scope='intact validated fixed-owner stock request stream',
        source_excerpts=len(witnesses), installed_instruction_bytes=native_bytes,
        request_record_bytes=56, argv_element_bytes=8,
        attempts_upper=attempts, interrupts_upper=attempts,
        total_interrupt_line_bytes_upper=interrupt_bytes,
        parsed_request_bytes='sum_d N_d*(L_d+8*m_d)+57714',
        parsed_request_allocations='sum_d N_d*m_d+4590',
        parent_exec_argv_bytes='8*sum_d N_d*(m_d+2)',
        line_partition_checks=partitions, receive_growth_boundaries=capacities,
        actual_line_and_argument_bounds_attached=False,
        malformed_front_stream_covered=False,
        proxy_stream_refinement_established=False,
        receive_overlap_native_bridge_still_required=True,
        libc_allocator_overhead_or_child_physical_memory_included=False,
        source_semantics_machine_checked=False, complete_q=None,
        native_target_solver_proof_runs=0, predecessor_checker_replays=0,
        production_configuration_changed=False)


if __name__ == '__main__':
    start = time.monotonic()
    result = check()
    output = HERE / 'result.json'
    if output.exists():
        assert json.loads(output.read_text()) == result
    else:
        output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(status='pass', source_excerpts=result['source_excerpts'],
        installed_instruction_bytes=result['installed_instruction_bytes'],
        receive_growth_boundaries=len(result['receive_growth_boundaries']),
        elapsed_seconds=time.monotonic()-start)))
