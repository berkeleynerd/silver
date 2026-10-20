"""Check new projections, pinned source excerpts and static installed code bytes.

No native target, solver, predecessor checker or captured-memory reader runs.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

from project import derive, mask_census

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read(name):
    return json.loads((HERE / name).read_text())


def elf_bytes(elf, address, count):
    assert elf[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', elf, 32)[0]
    entsize, entries = struct.unpack_from('<HH', elf, 54)
    for i in range(entries):
        kind, _, offset, virtual, _, filesz, _, _ = struct.unpack_from('<IIQQQQQQ', elf, phoff + i * entsize)
        if kind == 1 and virtual <= address and address + count <= virtual + filesz:
            return elf[offset + address - virtual:offset + address - virtual + count]
    raise AssertionError((address, count))


def main():
    start = time.monotonic()
    args = argparse.ArgumentParser()
    args.add_argument('--refresh', action='store_true')
    args.add_argument('--binary', type=Path)
    options = args.parse_args()
    inputs = read('inputs.json')
    for name, expected in inputs['repository'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    companion = inputs['reviewed_companion']
    archive = (HERE / companion['archive']).read_bytes()
    assert identity(archive) == companion['identity']
    with tarfile.open(HERE / companion['archive']) as stream:
        assert set(stream.getnames()) == set(companion['files'])
        for name, expected in companion['files'].items():
            assert identity(stream.extractfile(name).read()) == expected, name
    sources = read('source-witnesses.json')
    archives = {}
    try:
        for row in sources:
            archive = row['archive']
            if archive not in archives:
                archives[archive] = tarfile.open(ROOT / archive)
            raw = archives[archive].extractfile(row['member']).read()
            assert identity(raw) == row['identity'], row['member']
            lines = raw.decode().splitlines()
            for excerpt in row['excerpts']:
                assert '\n'.join(lines[excerpt['first'] - 1:excerpt['last']]) == excerpt['text']
    finally:
        for archive in archives.values():
            archive.close()
    native = read('native-witnesses.json')
    binary = options.binary or Path(native['binary']['path'])
    elf = binary.read_bytes()
    assert identity(elf) == native['binary']['identity']
    byte_count = 0
    for body in native['bodies']:
        for instruction in body['instructions']:
            expected = bytes.fromhex(instruction['hex'])
            assert elf_bytes(elf, instruction['address'], len(expected)) == expected
            byte_count += len(expected)
    projection = derive(ROOT)
    raw = (json.dumps(projection, indent=2) + '\n').encode()
    if options.refresh:
        (HERE / 'raw-contexts.json').write_bytes(raw)
    else:
        assert (HERE / 'raw-contexts.json').read_bytes() == raw
    census = mask_census(ROOT)
    raw = (json.dumps(census, indent=2) + '\n').encode()
    if options.refresh:
        (HERE / 'mask-census.json').write_bytes(raw)
    else:
        assert (HERE / 'mask-census.json').read_bytes() == raw
    result = {
        'status': 'pass', 'elapsed_seconds': time.monotonic() - start,
        'repository_inputs': len(inputs['repository']), 'source_files': len(sources),
        'reviewed_companion_commit': companion['commit'],
        'reviewed_companion_files': len(companion['files']),
        'source_excerpts': sum(len(s['excerpts']) for s in sources),
        'native_bodies': len(native['bodies']), 'installed_instruction_bytes_checked': byte_count,
        'context_declarations': {k: v['non_goal_declarations'] for k, v in projection.items()},
        'first_memo_resize_insertion': 129,
        'lexical_mask_sites': len(census['ocaml_mask_call_sites']),
        'lexical_explicit_why_mask_clients': len(census['why_explicit_mask_clients']),
        'refresh': options.refresh, 'native_target_runs': 0, 'old_capture_reader_replays': 0,
        'source_theorem_machine_checked': False,
        'default_parallel_mutable_state_closed': False,
    }
    print(json.dumps(result, indent=2))
    if not options.refresh:
        (HERE / 'check-result.json').write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    main()
