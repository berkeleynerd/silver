#!/usr/bin/env python3
"""Offline source/ELF identities and reproducible callback callsite inventory.

The inventory is lexical and retains comment matches. It is evidence for the
accompanying source argument, not an OCaml semantic or call-graph verifier.
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
EVIDENCE = HERE.parent


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['dependencies'].items():
        assert identity((EVIDENCE.parent.parent / name).read_bytes()) == expected, name
    for name, expected in inputs['local_inputs'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    index = json.loads((HERE / 'source-identities.json').read_text())
    assert index['ocaml_revision'] == '8eb41f72ded84df884c3671734c947f612091f84'
    assert index['why3_revision'] == '9390baf120ef260547dfa14f08e11c890b203d9c'
    assert identity((HERE / 'sources.tar.gz').read_bytes()) == index['identity']
    with tarfile.open(HERE / 'sources.tar.gz') as archive:
        sources = {m.name: archive.extractfile(m).read() for m in archive.getmembers() if m.isfile()}
    assert set(sources) == set(index['members'])
    for name, raw in sources.items():
        assert identity(raw) == index['members'][name]['identity']
    retrieval = json.loads((HERE / 'retrieval.json').read_text())
    assert retrieval['revision'] == index['ocaml_revision']
    for row in retrieval['files']:
        assert row['url'] == row['final_url'] == 'https://raw.githubusercontent.com/ocaml/ocaml/' + index['ocaml_revision'] + '/' + row['path']
        assert row['status'] == 200
        assert identity(sources['ocaml/' + row['path']]) == {k: row[k] for k in ('bytes', 'sha256')}
    assert sources['ocaml/VERSION'].splitlines()[0] == b'4.14.2'
    previous = json.loads((EVIDENCE / 'retained-why-inline-callback-closure-20261018/inputs.json').read_text())
    expected, = [spec['members']['ocaml/stdlib/stdlib.ml'] for spec in previous['archives'].values()
                 if 'ocaml/stdlib/stdlib.ml' in spec['members']]
    assert identity(sources['ocaml/stdlib/stdlib.ml']) == expected
    native = json.loads((HERE / 'native-source-correspondence.json').read_text())
    binary = Path(native['executable']['path']).read_bytes()
    assert identity(binary) == native['executable']['identity']
    version = json.loads((HERE / 'runtime-version.json').read_text())
    assert version['identity'] == identity(binary) and version['embedded_version'] == '4.14.2'
    for offset in version['byte_offsets']:
        assert binary[offset:offset + 6] == b'4.14.2'
    path = EVIDENCE / 'retained-why-inline-callback-closure-20261018/audit.py'
    spec = importlib.util.spec_from_file_location('helper_source_elf', path)
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    elf = audit.ELF(binary)
    instruction_bytes = 0
    for name, body in native['bodies'].items():
        assert body['address'] == elf.symbols[name]['value']
        assert body['symbol_size'] == elf.symbols[name]['size']
        cursor = body['address']
        for instruction in body['instructions']:
            raw = bytes.fromhex(instruction['hex'])
            assert instruction['address'] == cursor and elf.read(cursor, len(raw)) == raw
            cursor += len(raw)
            instruction_bytes += len(raw)
        assert cursor >= body['address'] + body['symbol_size']
    compress = native['bodies']['camlWhy3__Compress__entry']['instructions']
    assert any(r['text'] == 'movq   $0x1,(%rdi)' for r in compress)
    assert any('<camlStdlib>' in r['text'] for r in compress)
    assert not any(n.startswith(('camlGzip__', 'camlZlib__')) for n in elf.symbols)
    patterns = {
        'formatter_setters': re.compile(r'\b(?:pp_)?set_(?:all_)?formatter_\w+|\bset_debug_formatter\b'),
        'exception_registrations': re.compile(r'\bExn_printer\.register\b|\bPrintexc\.(?:register_printer|set_uncaught_exception_handler)\b'),
    }
    inventory = {key: [] for key in patterns}
    for name, raw in sorted(sources.items()):
        if not name.startswith('why3/'):
            continue
        for line_number, line in enumerate(raw.decode().splitlines(), 1):
            for category, pattern in patterns.items():
                if pattern.search(line):
                    inventory[category].append({'file': name, 'line': line_number, 'text': line.strip()})
    # Verify the source excerpts supporting the queue/callback separation.
    format_source = sources['ocaml/stdlib/format.ml'].decode()
    token_type = format_source.split('type pp_token =', 1)[1].split('and stag =', 1)[0]
    assert '->' not in token_type and 'Pp_open_tag of stag' in token_type
    assert '| Acc_delay (p, f)         -> output_acc ppf p; f ppf;' in format_source
    assert 'make_formatter (Buffer.add_substring b) ignore' in format_source
    assert 'make_formatter (output_substring oc) (fun () -> flush oc)' in format_source
    assert 'type formatter\n' in sources['ocaml/stdlib/format.mli'].decode()
    return {'source_files': len(sources), 'why3_source_files': sum(n.startswith('why3/') for n in sources),
            'official_matching_ocaml_files_retrieved': len(retrieval['files']),
            'runtime_embedded_version': version['embedded_version'],
            'native_bodies_checked': len(native['bodies']), 'native_bytes_checked': instruction_bytes,
            'compression_implementation': 'Compress_none',
            'normal_formatter_identifier_charge_under_source_argument': 0,
            'full_R_established': False, 'composed_endpoint_established': False,
            'native_runs': 0, 'debugger_runs': 0, 'objdump_runs': 0, 'solver_runs': 0}, inventory


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    result, inventory = check()
    for name, data in [('result.json', result), ('callsite-inventory.json', inventory)]:
        if args.write:
            (HERE / name).write_text(json.dumps(data, indent=2) + '\n')
        else:
            assert data == json.loads((HERE / name).read_text())
    print(json.dumps({'status': 'pass', 'seconds': time.monotonic() - started, 'result': result}))
