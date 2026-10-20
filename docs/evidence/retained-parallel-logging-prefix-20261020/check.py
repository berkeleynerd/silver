#!/usr/bin/env python3
"""Check new finite projections and pinned source/ELF witnesses, without writes.

The source/control and first-trigger arguments are reviewed in the note; this
script does not execute OCaml, start a target or run any predecessor checker.
"""
import hashlib
import json
import platform
import re
import struct
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from project import HERE, ROOT, project
from audit_inputs import audit

COUNTS = {}


def checked(group, test):
    assert test, group
    COUNTS[group] = COUNTS.get(group, 0) + 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pins_and_sources():
    pins = json.loads((HERE / 'inputs.json').read_text())
    for group in ['archives', 'context_files', 'packet_files']:
        base = HERE if group == 'packet_files' else ROOT
        for path, digest in pins[group].items():
            checked(group, sha((base / path).read_bytes()) == digest)
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    for path in sorted({w['archive'] for w in witnesses}):
        with tarfile.open(ROOT / path) as arc:
            for w in witnesses:
                if w['archive'] != path:
                    continue
                raw = arc.extractfile(w['member']).read()
                text = ''.join(raw.decode().splitlines(keepends=True)
                               [w['first_line'] - 1:w['last_line']])
                checked('source_slice', sha(raw) == w['member_sha256']
                        and text == w['text'] and sha(text.encode()) == w['slice_sha256'])
            if 'why-session' in path:
                scan = []
                for member in arc.getnames():
                    if '/gnat/' not in member or not member.endswith('.ml'):
                        continue
                    raw = arc.extractfile(member).read()
                    hits = [{'line': i, 'text': line}
                            for i, line in enumerate(raw.decode().splitlines(), 1)
                            if re.search(r'\b(logging|parallel|opt_logging|opt_parallel)\b|open Gnat_config', line)]
                    scan.append({'member': member, 'sha256': sha(raw), 'hits': hits})
                checked('control_use_inventory', scan == json.loads((HERE / 'control-use-scan.json').read_text()))


def installed_bytes():
    witness = json.loads((HERE / 'installed-byte-witnesses.json').read_text())
    raw = __import__('pathlib').Path(witness['binary_path']).read_bytes()
    checked('installed_identity', len(raw) == witness['binary_bytes'] and sha(raw) == witness['binary_sha256'])
    checked('elf_header', raw[:64].hex() == witness['ELF_header_hex'])
    phoff = struct.unpack_from('<Q', raw, 32)[0]
    phsize, phcount = struct.unpack_from('<HH', raw, 54)
    checked('elf_header', raw[phoff:phoff + phsize * phcount].hex() == witness['program_headers_hex'])
    loads = [struct.unpack_from('<IIQQQQQQ', raw, phoff + i * phsize)
             for i in range(phcount)]
    loads = [row for row in loads if row[0] == 1]

    def offset(address):
        row, = [row for row in loads if row[3] <= address < row[3] + row[5]]
        return row[2] + address - row[3]

    rows = []
    for line in (HERE / 'installed-startup-disassembly.txt').read_text().splitlines():
        match = re.match(r'\s*(0x[0-9a-f]+) <\+\d+>:\s*((?:[0-9a-f]{2} )*[0-9a-f]{2})\s*\t', line)
        if match:
            address = int(match[1], 16)
            data = bytes.fromhex(match[2])
            rows.append({'virtual_address': address, 'file_offset': offset(address), 'bytes': data.hex()})
    checked('disassembly_rows', rows == witness['instructions'])
    for row in rows:
        data = bytes.fromhex(row['bytes'])
        at = row['file_offset']
        checked('instruction_bytes', raw[at:at + len(data)] == data)
    checked('arg_option_allocation', next(row['bytes'] for row in rows
                                        if row['virtual_address'] == 0x97b450) == '4981efd8000000')
    name = witness['static_transform_name']
    at = offset(name['virtual_address'] - 8)
    data = bytes.fromhex(name['data_hex'])
    checked('static_transform_name', at == name['file_offset'] and raw[at:at + len(data)] == data)
    checked('static_transform_name', struct.unpack_from('<Q', data)[0] == name['header'] == 4092)
    checked('static_transform_name', data[8:len(data) - data[-1] - 1].decode() == name['decoded'] == 'split_goal_wp_conj')


def main():
    start = time.perf_counter()
    pins_and_sources()
    installed_bytes()
    finite = project()  # Includes raw-graph layout, binder and counter assertions.
    checked('registration_projection', finite == json.loads((HERE / 'cut-projection.json').read_text()))
    joined = audit()
    checked('input_role_projection', joined == json.loads((HERE / 'input-role-projection.json').read_text()))
    checked('five_domains', len(finite) == len(joined) == 5)
    checked('bindings', sum(r['checked_binding_records'] for r in finite.values()) == 6747)
    checked('root_totals', sum(len(r['fixed_root_map']) for r in finite.values()) == 118)
    checked('raw_goal_totals', sum(len(r['goal_ids']) for r in finite.values()) == 161)
    checked('delta_bounds', [finite[c]['logging_delta']['minor_envelope_words']
                            for c in ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']]
            == [39, 38, 41, 40, 41])
    print(json.dumps({'status': 'pass', 'platform': platform.system() + ' ' + platform.machine(),
                      'elapsed_seconds': round(time.perf_counter() - start, 6),
                      'counted_checks': sum(COUNTS.values()), 'check_groups': COUNTS,
                      'internal_graph_and_input_assertions': 'also executed; not included in count',
                      'native_target_launches': 0, 'predecessor_checker_replays': 0},
                     indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
