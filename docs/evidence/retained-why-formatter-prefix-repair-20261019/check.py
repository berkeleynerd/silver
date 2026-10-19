#!/usr/bin/env python3
"""Offline identity/census checks for the bounded formatter-family repair.

Lexical and raw E8/E9 scans are diagnostics, not a decoded call graph or an
indirect-call closure proof. No subprocess, target or disassembler is started.
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
REVISION = '8eb41f72ded84df884c3671734c947f612091f84'
SYMBOL = re.compile(r'camlStdlib__Format__(?:(?:pp_)?set_(?:all_)?formatter_'
                    r'(?:out|output|tag|stag)\w*|(?:pp_)?make_formatter|'
                    r'formatter_of_(?:out|buffer|symbolic)\w*)_\d+$')
PATTERNS = {
    'mutator': re.compile(r'\b(?:pp_)?set_(?:all_)?formatter_(?:out|output|tag|stag)\w*'),
    'constructor': re.compile(r'\b(?:pp_)?make_formatter\b|\bformatter_of_(?:out|buffer|symbolic)\w*'),
    'callback_field': re.compile(r'\b(?:out_string|out_flush|out_newline|out_spaces|out_indent|'
                                 r'mark_open_stag|mark_close_stag|print_open_stag|print_close_stag|'
                                 r'mark_open_tag|mark_close_tag|print_open_tag|print_close_tag)\s*='),
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def census(archive, prefix, ocaml=False):
    inventory, members = [], {}
    with tarfile.open(archive) as tf:
        names = set()
        for member in tf.getmembers():
            assert member.name not in names
            names.add(member.name)
            if not member.isfile():
                continue
            if not member.name.startswith(prefix):
                continue
            name = member.name[len(prefix):]
            if not re.search(r'\.(?:ml|mli|mll|mly|c|h)$', name):
                continue
            raw = tf.extractfile(member).read()
            members[name] = identity(raw)
            for number, line in enumerate(raw.decode(errors='replace').splitlines(), 1):
                categories = [k for k, pattern in PATTERNS.items() if pattern.search(line)]
                if categories:
                    inventory.append({'file': name, 'line': number, 'categories': categories,
                                      'text': line.strip()})
    return {'source_members': members, 'matches': inventory}


def native_census(elf):
    targets = {s['value']: n for n, s in elf.symbols.items() if SYMBOL.fullmatch(n)}
    functions = sorted((s['value'], n, s['size']) for n, s in elf.symbols.items()
                       if s['info'] & 15 == 2 and s['size'])
    starts = [r[0] for r in functions]
    refs = []
    words = []
    for section in elf.sections:
        raw = elf.data[section['offset']:section['offset'] + section['size']]
        if section['flags'] & 4:
            for match in re.finditer(b'[\xe8\xe9]', raw):
                offset = match.start()
                if offset + 5 > len(raw):
                    continue
                address = section['addr'] + offset
                target = address + 5 + struct.unpack_from('<i', raw, offset + 1)[0]
                if target not in targets:
                    continue
                i = bisect.bisect_right(starts, address) - 1
                start, name, size = functions[i]
                assert start <= address < start + size
                refs.append({'address': address, 'owner': name, 'target': targets[target],
                             'hex': raw[offset:offset + 5].hex()})
        elif section['type'] == 1 and section['flags'] & 2:
            for offset in range((-section['addr']) % 8, len(raw) - 7, 8):
                value, = struct.unpack_from('<Q', raw, offset)
                if value in targets:
                    address = section['addr'] + offset
                    words.append({'address': address, 'owner': elf.label(address),
                                  'target': targets[value]})
    return {'targets': {n: a for a, n in sorted(targets.items())},
            'raw_relative_candidates': refs, 'aligned_data_words': words}


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['dependencies'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_inputs'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    retrieval = json.loads((HERE / 'retrieval.json').read_text())
    assert retrieval['url'] == retrieval['final_url'] == 'https://codeload.github.com/ocaml/ocaml/tar.gz/' + REVISION
    assert retrieval['status'] == 200
    assert identity((HERE / 'ocaml-source.tar.gz').read_bytes()) == {k: retrieval[k] for k in ('bytes', 'sha256')}
    ocaml = census(HERE / 'ocaml-source.tar.gz', 'ocaml-' + REVISION + '/', True)
    previous = HERE.parent / 'retained-why-session-helper-source-20261019/sources.tar.gz'
    why = census(previous, 'why3/')
    overlapping = 0
    with tarfile.open(previous) as tf:
        for member in tf.getmembers():
            if member.isfile() and member.name.startswith('ocaml/'):
                name = member.name[6:]
                if name in ocaml['source_members']:
                    assert identity(tf.extractfile(member).read()) == ocaml['source_members'][name]
                    overlapping += 1
    assert ocaml['source_members']['utils/misc.ml']['sha256'] == 'd13bfe71d818cd561cf72e6b50f57334290add9046acde84a015e594194575b3'
    assert ocaml['source_members']['parsing/location.ml']['sha256'] == '2354eb8d74e8286eef4251ace8b50d3cb8b501ddb6444c98e1488a3e501e2891'
    path = HERE.parent / 'retained-why-inline-callback-closure-20261018/audit.py'
    spec = importlib.util.spec_from_file_location('formatter_repair_elf', path)
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    elfs = {}
    for name, row in inputs['installed_files'].items():
        raw = Path(row['path']).read_bytes()
        assert identity(raw) == row['identity'], name
        elfs[name] = audit.ELF(raw)
    elf = elfs['gnatwhy3']
    native = native_census(elf)
    native['plugin_format_symbols'] = {
        name: sorted({s['name'] for table in e.tables.values() for s in table
                      if s['name'].startswith('camlStdlib__Format')})
        for name, e in elfs.items() if name != 'gnatwhy3'
    }
    bodies = json.loads((HERE / 'native-bodies.json').read_text())
    byte_count = 0
    for name, body in bodies['bodies'].items():
        assert body['address'] == elf.symbols[name]['value']
        assert body['symbol_size'] == elf.symbols[name]['size']
        cursor = body['address']
        for row in body['instructions']:
            raw = bytes.fromhex(row['hex'])
            assert row['address'] == cursor and elf.read(cursor, len(raw)) == raw
            cursor += len(raw)
            byte_count += len(raw)
        assert cursor >= body['address'] + body['symbol_size']
    return {
        'ocaml_source_files_scanned': len(ocaml['source_members']),
        'why_source_files_scanned': len(why['source_members']),
        'prior_ocaml_source_members_compared': overlapping,
        'native_target_symbols': len(native['targets']),
        'native_relative_candidates': len(native['raw_relative_candidates']),
        'native_target_pointer_words': len(native['aligned_data_words']),
        'native_bodies_checked': len(bodies['bodies']), 'native_bytes_checked': byte_count,
        'normal_formatter_charge_under_prose_source_argument': 0,
        'complete_R': None, 'full_R_established': False,
        'composed_endpoint_established': False,
        'native_runs': 0, 'debugger_runs': 0, 'disassembler_runs': 0,
    }, {'ocaml': ocaml, 'why': why}, native


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    result, source, native = check()
    for name, data in [('result.json', result), ('source-census.json', source),
                       ('native-census.json', native)]:
        if args.write:
            (HERE / name).write_text(json.dumps(data, indent=2) + '\n')
        else:
            assert data == json.loads((HERE / name).read_text()), name
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - started, 'result': result}))
