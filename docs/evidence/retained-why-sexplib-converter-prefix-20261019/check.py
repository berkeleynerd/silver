#!/usr/bin/env python3
"""Check pinned source, registration identities, and existing installed bytes.

This checks evidence consistency. It does not execute OCaml, decode a whole
program, prove exception effects, or establish the complete remainder R.
"""
import argparse
import bisect
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
REVISIONS = {
    'sexplib0': 'df916dfe8d0538a0dbfcdcb35c6e933ac9fc8130',
    'sexplib': 'e5b3b209d40c5ecb348634832eafd1945b25fb2d',
    'parsexp': 'f359b2244cc5f7421120917450a846a4a326836d',
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sources():
    result = {}
    for package, revision in REVISIONS.items():
        with tarfile.open(HERE / (package + '.tar.gz')) as tf:
            prefix = package + '-' + revision + '/'
            for member in tf.getmembers():
                if member.isfile() and re.search(r'\.(?:ml|mli|mll|mly|c|h)$', member.name):
                    assert member.name.startswith(prefix)
                    name = package + '/' + member.name[len(prefix):]
                    assert name not in result
                    result[name] = tf.extractfile(member).read().decode(errors='replace')
    with tarfile.open(HERE.parent / 'retained-why-session-helper-source-20261019/sources.tar.gz') as tf:
        for member in tf.getmembers():
            if member.isfile() and member.name.startswith('why3/'):
                result[member.name] = tf.extractfile(member).read().decode()
    with tarfile.open(HERE.parent / 'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz') as tf:
        member = next(m for m in tf.getmembers() if m.name.endswith('/stdlib/ephemeron.ml'))
        result['ocaml/stdlib/ephemeron.ml'] = tf.extractfile(member).read().decode()
    return result


def source_census(source):
    matches, deriving, members = [], [], {}
    pattern = re.compile(r'Exn_converter|Exn_magic|sexp_of_exn|printexc_prefer_sexp|'
                         r'include.*Sexp_conv|module.*=.*(?:Conv|Sexplib|Parsexp)|'
                         r'\bexception\s+\w+\s*=')
    for name, raw in sorted(source.items()):
        members[name] = identity(raw.encode())
        lines = raw.splitlines()
        for i, line in enumerate(lines):
            if pattern.search(line):
                matches.append({'file': name, 'line': i + 1, 'text': line.strip()})
            if name.startswith('why3/') and 'deriving' in line and 'sexp' in line:
                start = i
                while start and not re.match(r'\s*(?:type|and|exception|let|val)\b', lines[start]):
                    start -= 1
                deriving.append({'file': name, 'start': start + 1, 'end': i + 1,
                                 'source': '\n'.join(lines[start:i + 1])})
    return {'members': members, 'api_and_alias_matches': matches,
            'why_sexp_deriving_declarations': deriving}


def access_census(elf, ranges):
    """Raw REX RIP-relative candidates and aligned pointers, not decoded CFG."""
    functions = sorted((s['value'], n, s['size']) for n, s in elf.symbols.items()
                       if s['info'] & 15 == 2 and s['size'])
    starts = [row[0] for row in functions]
    refs, words = [], []
    for section in elf.sections:
        raw = elf.data[section['offset']:section['offset'] + section['size']]
        if section['flags'] & 4:
            for match in re.finditer(rb'[\x48-\x4f][\x8b\x8d\x89][\x05\x0d\x15\x1d\x25\x2d\x35\x3d]', raw):
                offset = match.start()
                if offset + 7 > len(raw):
                    continue
                address = section['addr'] + offset
                target = address + 7 + struct.unpack_from('<i', raw, offset + 3)[0]
                names = [n for n, row in ranges.items() if row['start'] <= target < row['end']]
                if names:
                    start, owner, size = functions[bisect.bisect_right(starts, address) - 1]
                    assert start <= address < start + size
                    refs.append({'address': address, 'owner': owner, 'target': target,
                                 'ranges': names, 'hex': raw[offset:offset + 7].hex()})
        elif section['type'] == 1 and section['flags'] & 2:
            for offset in range((-section['addr']) % 8, len(raw) - 7, 8):
                target, = struct.unpack_from('<Q', raw, offset)
                names = [n for n, row in ranges.items() if row['start'] <= target < row['end']]
                if names:
                    address = section['addr'] + offset
                    words.append({'address': address, 'owner': elf.label(address),
                                  'target': target, 'ranges': names})
    return {'raw_rip_candidates': refs, 'aligned_data_words': words}


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['dependencies'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_inputs'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    for package, revision in REVISIONS.items():
        retrieval = json.loads((HERE / (package + '-retrieval.json')).read_text())
        tag = json.loads((HERE / (package + '-tag.json')).read_text())
        assert retrieval['version'] == 'v0.16.0' and retrieval['commit'] == revision
        assert retrieval['url'] == retrieval['final_url'] == 'https://codeload.github.com/janestreet/' + package + '/tar.gz/' + revision
        assert retrieval['status'] == 200
        assert identity((HERE / (package + '.tar.gz')).read_bytes()) == {k: retrieval[k] for k in ('bytes', 'sha256')}
        assert tag['status'] == 200 and tag['response']['object']['sha'] == revision
        assert tag['response']['object']['type'] == 'commit'
    source = sources()
    excerpts = json.loads((HERE / 'source-excerpts.json').read_text())
    for row in excerpts:
        raw = source[row['file']]
        assert identity(raw.encode()) == row['file_identity']
        assert '\n'.join(raw.splitlines()[row['start'] - 1:row['end']]) == row['source']
    audit = load_module('sexplib_elf', HERE.parent / 'retained-why-inline-callback-closure-20261018/audit.py')
    elfs = {}
    for name, row in inputs['installed_files'].items():
        raw = Path(row['path']).read_bytes()
        assert identity(raw) == row['identity'], name
        elfs[name] = audit.ELF(raw)
    elf = elfs['gnatwhy3']
    for row in inputs['installed_version_strings']:
        raw = row['value'].encode() + b'\0'
        assert elf.data[row['file_offset']:row['file_offset'] + len(raw)] == raw
    native = json.loads((HERE / 'native-bodies.json').read_text())
    byte_count = 0
    for name, body in native['bodies'].items():
        assert body['address'] == elf.symbols[name]['value']
        assert body['symbol_size'] == elf.symbols[name]['size']
        cursor = body['address']
        for row in body['instructions']:
            raw = bytes.fromhex(row['hex'])
            assert row['address'] == cursor and elf.read(cursor, len(raw)) == raw
            cursor += len(raw)
            byte_count += len(raw)
        assert cursor >= body['address'] + body['symbol_size']
    for window in native['windows']:
        cursor = window['start']
        for row in window['instructions']:
            raw = bytes.fromhex(row['hex'])
            assert row['address'] == cursor and elf.read(cursor, len(raw)) == raw
            cursor += len(raw)
            byte_count += len(raw)
        assert cursor == window['end']
    for row in native['static_closures']:
        raw = bytes.fromhex(row['hex'])
        assert elf.read(row['address'], len(raw)) == raw
        assert int.from_bytes(raw[row['code_offset']:row['code_offset'] + 8], 'little') == elf.symbols[row['code_symbol']]['value']
    events = json.loads((HERE / 'registration-events.json').read_text())
    latest = {}
    for sequence, row in enumerate(events, 1):
        assert row['sequence'] == sequence
        assert '[%extension_constructor ' + row['source_constructor'] + ']' in source[row['file']].splitlines()[row['line'] - 1]
        assert row['closure'] in {c['closure_symbol'] for c in native['static_closures']}
        address = row['driver_call']
        raw = elf.read(address, 5)
        assert raw[0] == 0xe8
        target = address + 5 + struct.unpack_from('<i', raw, 1)[0]
        expected = 'camlStdlib__List__iter_507' if sequence <= 18 else 'camlSexplib0__Sexp_conv__add_inner_2040'
        assert target == elf.symbols[expected]['value']
        latest[row['constructor_identity']] = row
    assert len(events) == 24 and len(latest) == 23
    assert sum(row['printexc'] for row in latest.values()) == 6
    assert events[17]['constructor_identity'] == events[21]['constructor_identity']
    scan = load_module('sexplib_raw', HERE.parent / 'retained-why-formatter-prefix-repair-20261019/check.py')
    scan.SYMBOL = re.compile(r'(?:camlSexplib0__Sexp_conv__(?:add_inner|add)|camlSexplib__Exn_magic__register\d*)_\d+$')
    census = scan.native_census(elf)
    census['access'] = access_census(elf, inputs['access_ranges'])
    census['plugin_related_symbols'] = {name: sorted({s['name'] for table in e.tables.values() for s in table
        if re.search(r'caml(?:Sexplib|Parsexp|Ppx_sexp)', s['name'])}) for name, e in elfs.items() if name != 'gnatwhy3'}
    census['sexplib_unix_symbols'] = sorted(n for n in elf.symbols if 'Sexplib_unix' in n)
    source_rows = source_census(source)
    assert all(re.match(r'\s*(?:type|and)\b', row['source'])
               for row in source_rows['why_sexp_deriving_declarations'])
    return {
        'package_source_files': {p: sum(n.startswith(p + '/') for n in source) for p in REVISIONS},
        'why_source_files': sum(n.startswith('why3/') for n in source),
        'why_sexp_deriving_declarations': len(source_rows['why_sexp_deriving_declarations']),
        'source_excerpts_checked': len(excerpts), 'native_bodies_checked': len(native['bodies']),
        'native_windows_checked': len(native['windows']), 'native_bytes_checked': byte_count,
        'static_closures_checked': len(native['static_closures']),
        'initialization_registration_events': len(events), 'distinct_constructor_keys': len(latest),
        'latest_auto_enabled_keys': sum(row['printexc'] for row in latest.values()),
        'latest_auto_disabled_keys': sum(not row['printexc'] for row in latest.values()),
        'converter_prefix_family_closed_under_prose_argument': True,
        'arbitrary_inner_exception_charge_established': False,
        'whole_exception_family_exhaustiveness_established': False,
        'interrupted_catch_and_continuation_preservation_closed': False,
        'exceptional_identifier_charge': None, 'complete_R': None,
        'full_R_established': False, 'composed_endpoint_established': False,
        'native_runs': 0, 'debugger_runs': 0, 'disassembler_runs': 0,
    }, source_rows, census


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    result, source_rows, census = check()
    for name, data in [('result.json', result), ('source-census.json', source_rows), ('native-census.json', census)]:
        if args.write:
            (HERE / name).write_text(json.dumps(data, indent=2) + '\n')
        else:
            assert data == json.loads((HERE / name).read_text()), name
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - started, 'result': result}))
