#!/usr/bin/env python3
"""Check source excerpts and installed bytes for an incomplete exception prefix.

This is a consistency checker, not an exception-effect or reachability proof.
It reads pinned inputs and never starts a native program or subprocess.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sources():
    result = {}
    old = HERE.parent / 'retained-why-session-helper-source-20261019/sources.tar.gz'
    with tarfile.open(old) as tf:
        for member in tf.getmembers():
            if member.isfile():
                result[member.name] = tf.extractfile(member).read().decode()
    archive = HERE.parent / 'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
    with tarfile.open(archive) as tf:
        for member in tf.getmembers():
            if member.isfile() and re.search(r'\.(?:ml|mli|mll|mly|c|h)$', member.name):
                name = 'ocaml/' + member.name.split('/', 1)[1]
                raw = tf.extractfile(member).read().decode(errors='replace')
                if name in result:
                    assert result[name] == raw
                result[name] = raw
    return result


def printer_inventory(source):
    inventory = []
    for name, raw in sorted(source.items()):
        if not name.startswith('why3/'):
            continue
        lines = raw.splitlines()
        for index, line in enumerate(lines):
            if not re.search(r'\bExn_printer\.register\b', line):
                continue
            indentation = len(line) - len(line.lstrip())
            end = index + 1
            while end < len(lines):
                nxt = lines[end]
                indent = len(nxt) - len(nxt.lstrip())
                if indent <= indentation and re.match(
                        r'\s*(let |type |module |exception |external |open |%})', nxt):
                    break
                end += 1
            inventory.append({'file': name, 'start': index + 1, 'end': end,
                              'source': '\n'.join(lines[index:end])})
    return inventory


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['dependencies'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_inputs'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    source = sources()
    excerpts = json.loads((HERE / 'source-excerpts.json').read_text())
    for row in excerpts:
        raw = source[row['file']]
        assert identity(raw.encode()) == row['file_identity']
        assert '\n'.join(raw.splitlines()[row['start'] - 1:row['end']]) == row['source']
    audit = load_module('exception_elf', HERE.parent / 'retained-why-inline-callback-closure-20261018/audit.py')
    installed = inputs['installed_executable']
    raw = Path(installed['path']).read_bytes()
    assert identity(raw) == installed['identity']
    elf = audit.ELF(raw)
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
    # Reuse only the read-only raw-reference helper, with explicitly different
    # targets. This does not run the formatter checker or repeat its checks.
    scan = load_module('exception_census', HERE.parent / 'retained-why-formatter-prefix-repair-20261019/check.py')
    scan.SYMBOL = re.compile(r'(?:camlStdlib__Printexc__(?:register_printer|set_uncaught_exception_handler)|'
                             r'camlWhy3__Exn_printer__register|'
                             r'camlSexplib0__Sexp_conv__(?:add_inner|add|printexc_prefer_sexp))_\d+$')
    census = scan.native_census(elf)
    registry = printer_inventory(source)
    lexical = []
    for name, raw in sorted(source.items()):
        for number, line in enumerate(raw.splitlines(), 1):
            if re.search(r'Printexc\.(?:register_printer|set_uncaught_exception_handler)|'
                         r'Exn_converter|sexp_of_exn|Sexp_conv\.(?:add|record|register)|'
                         r'\bexception\s+\w+\s*=', line):
                lexical.append({'file': name, 'line': number, 'text': line.strip()})
    for row in native['static_words']:
        assert elf.read(row['address'], len(bytes.fromhex(row['hex']))).hex() == row['hex']
        assert int.from_bytes(bytes.fromhex(row['hex'])[:8], 'little') == elf.symbols[row['code_symbol']]['value']
    return {
        'why_printer_registration_snippets': len(registry),
        'source_excerpts_checked': len(excerpts),
        'native_bodies_checked': len(native['bodies']),
        'native_bytes_checked': byte_count,
        'native_raw_relative_candidates': len(census['raw_relative_candidates']),
        'primitive_exception_rejection_by_inspected_why_callbacks_under_prose_argument': True,
        'whole_exception_family_exhaustiveness_established': False,
        'sexplib_converter_registry_prefix_closed': False,
        'interrupted_catch_and_continuation_preservation_closed': False,
        'exceptional_identifier_charge': None, 'complete_R': None,
        'full_R_established': False, 'composed_endpoint_established': False,
        'native_runs': 0, 'debugger_runs': 0, 'disassembler_runs': 0,
    }, registry, census, lexical


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    result, registry, census, lexical = check()
    for name, data in [('result.json', result), ('why-printer-inventory.json', registry),
                       ('native-census.json', census), ('registration-inventory.json', lexical)]:
        if args.write:
            (HERE / name).write_text(json.dumps(data, indent=2) + '\n')
        else:
            assert data == json.loads((HERE / name).read_text()), name
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - started, 'result': result}))
