#!/usr/bin/env python3
"""Check only this successor's source projection and reused client records.

No target execution, old checker/Context replay, disassembly or corpus census.
The optional retained disassembly is read only when creating the six new hook
windows. Default checking needs the frozen windows and pinned ELF, not that
temporary text file. Source arguments and arbitrary native aliasing are not
proved by this checker.
"""
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
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
NATIVE = 'docs/evidence/retained-why-inline-callback-closure-20261018/native.tar.gz'
PREFIX = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
INSTALL = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
DEPENDENCIES = [WHY, OCAML, NATIVE,
    'docs/research/retained-why-inline-callback-closure.md',
    'docs/research/retained-why-callback-launch.md',
    'docs/research/retained-why-sexplib-converter-prefix.md',
    'docs/research/retained-why-session-save-outcomes.md',
    'docs/reviews/review-why-session-save-outcomes-0aa373fb93.md',
    'docs/evidence/retained-why-session-save-state-20261019/binder-certificate.json',
    'docs/evidence/retained-why-session-save-state-20261019/capture-identities.json',
    'docs/evidence/retained-why-session-save-outcomes-20261019/atom-certificate.json']
SPECS = [
    ('why3/src/session/termcode.mli', 35, 108),
    ('why3/src/session/termcode.ml', 338, 409),
    ('why3/src/session/termcode.ml', 509, 543),
    ('why3/src/session/termcode.ml', 599, 637),
    ('why3/src/core/trans.ml', 75, 103),
    ('why3/src/util/weakhtbl.ml', 69, 104),
    ('why3/src/core/ident.ml', 225, 286),
    ('why3/src/core/task.ml', 59, 100),
    ('why3/src/session/session_itp.ml', 2212, 2245),
    ('why3/src/gnat/gnat_main.ml', 265, 279),
    ('why3/src/gnat/gnat_main.ml', 298, 309),
    ('why3/src/gnat/gnat_main.ml', 331, 335),
    ('stdlib/buffer.ml', 15, 40),
    ('stdlib/buffer.ml', 56, 127),
    ('stdlib/format.ml', 937, 977),
    ('stdlib/format.ml', 990, 1007),
    ('runtime/signals.c', 72, 104),
    ('runtime/signals.c', 201, 227),
    ('runtime/signals.c', 260, 292),
    ('runtime/finalise.c', 44, 70),
    ('runtime/finalise.c', 164, 194),
    ('runtime/finalise.c', 352, 404),
    ('stdlib/gc.ml', 103, 161),
    ('runtime/memprof.c', 40, 52),
    ('runtime/memprof.c', 119, 181),
    ('runtime/memprof.c', 568, 624),
    ('runtime/memprof.c', 766, 815),
    ('runtime/memprof.c', 975, 1049),
    ('otherlibs/systhreads/thread.ml', 81, 102),
    ('otherlibs/systhreads/st_stubs.c', 723, 740),
    ('runtime/misc.c', 36, 42),
    ('runtime/caml/misc.h', 193, 196),
]
HOOKS = [
    ('caml_major_slice_begin_hook', 0xfaaf48, 0x9c551d),
    ('caml_major_slice_end_hook', 0xfaaf40, 0x9c595e),
    ('caml_minor_gc_begin_hook', 0xfaaf38, 0x9c6b8f),
    ('caml_minor_gc_end_hook', 0xfaaf30, 0x9c6e01),
    ('caml_finalise_begin_hook', 0xfaaf28, 0x9dc402),
    ('caml_finalise_end_hook', 0xfaaf20, 0x9dc4ce),
]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def record(name, value, write):
    p = HERE / name
    if write:
        p.write_text(json.dumps(value, indent=2) + '\n')
    else:
        assert json.loads(p.read_text()) == value, name


def sources():
    result = []
    with tarfile.open(ROOT / WHY) as why, tarfile.open(ROOT / OCAML) as ocaml:
        for file, first, last in SPECS:
            member = file if file.startswith('why3/') else PREFIX + file
            archive, name = (why, WHY) if file.startswith('why3/') else (ocaml, OCAML)
            data = archive.extractfile(member).read()
            lines = data.decode().splitlines(keepends=True)
            assert 1 <= first <= last <= len(lines)
            result.append({'archive': name, 'member': member,
                           'file_identity': identity(data), 'first': first,
                           'last': last, 'text': ''.join(lines[first - 1:last])})
    return result


def clients():
    with tarfile.open(ROOT / NATIVE) as archive:
        data = archive.extractfile('native-audit.json').read()
    audit = json.loads(data)
    selected = []
    groups = {'camlStdlib__Gc:code', 'camlStdlib__Gc:data',
              'caml_memprof_start', 'caml_final_register',
              'caml_final_register_called_without_value'}
    for item in audit['code_references']:
        if groups.intersection(item['groups']):
            if not item['function'].startswith('camlStdlib__Gc__') and item['function'] not in {
                    'caml_memprof_start', 'caml_final_register',
                    'caml_final_register_called_without_value'}:
                selected.append(item)
            elif item['function'] == 'camlStdlib__Gc__start_inner_723' and 'caml_memprof_start' in item['groups']:
                selected.append(item)
    gc_lo, gc_hi = audit['ranges']['camlStdlib__Gc:data']
    return {'origin_archive': NATIVE, 'origin_member': 'native-audit.json',
            'member_identity': identity(data), 'selected_code_references': selected,
            'external_gc_data_references': [x for x in audit['data_references']
                if 'camlStdlib__Gc:data' in x['groups'] and not gc_lo <= x['address'] < gc_hi],
            'scope': 'Projection of accepted diagnostic only; no new reachability census.'}


def hook_source_uses():
    """Named search authorized for the four unresolved native cells only."""
    pattern = re.compile(rb'caml_(?:major_slice|minor_gc)_(?:begin|end)_hook')
    records = []
    with tarfile.open(ROOT / OCAML) as archive:
        for member in archive:
            if not member.isfile() or not any(member.name.startswith(PREFIX + root)
                    for root in ['runtime/', 'otherlibs/']):
                continue
            data = archive.extractfile(member).read()
            matches = [{'line': n, 'text': line.decode()}
                       for n, line in enumerate(data.splitlines(), 1) if pattern.search(line)]
            if matches:
                records.append({'member': member.name, 'identity': identity(data), 'matches': matches})
    return {'archive': OCAML, 'scope': [PREFIX + 'runtime/', PREFIX + 'otherlibs/'],
            'names': [x[0] for x in HOOKS[:4]], 'files': records,
            'complete_selected_linked_native_source_relation': False}


def hook_windows(elf, write, disassembly):
    header = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    assert header[0][:6] == b'\x7fELF\x02\x01' and header[2] == 62
    segments = [struct.unpack_from('<IIQQQQQQ', elf, header[5] + i * header[9])
                for i in range(header[10])]
    if write:
        raw = disassembly.read_bytes()
        lines = raw.decode().splitlines()
        windows = []
        for name, target, address in HOOKS:
            matching = [s for s in lines if re.match(rf'\s*{address:x}:', s)]
            assert len(matching) == 1
            line = matching[0]
            assert f'<{name}>' in line
            encoding = bytes.fromhex(line.split('\t')[1])
            assert len(encoding) == 7 and encoding[:3] in [b'\x48\x8b\x05', b'\x48\x8b\x15']
            assert address + 7 + struct.unpack('<i', encoding[3:])[0] == target
            windows.append({'symbol': name, 'object_address': target,
                            'instruction_address': address, 'instruction_bytes': encoding.hex(),
                            'instruction': line, 'object_storage': 'zero-fill',
                            'object_runtime_value_observed': False})
        result = {'origin': str(disassembly), 'origin_identity': identity(raw),
                  'windows': windows}
        record('timing-hook-windows.json', result, True)
    else:
        result = json.loads((HERE / 'timing-hook-windows.json').read_text())
    assert [(x['symbol'], x['object_address'], x['instruction_address'])
            for x in result['windows']] == HOOKS
    for item in result['windows']:
        addr = item['instruction_address']
        data = bytes.fromhex(item['instruction_bytes'])
        assert len(data) == 7 and data[:3] in [b'\x48\x8b\x05', b'\x48\x8b\x15']
        assert addr + 7 + struct.unpack('<i', data[3:])[0] == item['object_address']
        segment, = [s for s in segments if s[0] == 1 and s[3] <= addr and addr + len(data) <= s[3] + s[5]]
        offset = segment[2] + addr - segment[3]
        assert elf[offset:offset + len(data)] == data
        target = item['object_address']
        assert any(s[0] == 1 and s[3] + s[5] <= target and target + 8 <= s[3] + s[6] for s in segments)
        assert item['object_storage'] == 'zero-fill' and not item['object_runtime_value_observed']
    return sum(len(bytes.fromhex(x['instruction_bytes'])) for x in result['windows'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--install', type=Path, default=INSTALL)
    parser.add_argument('--disassembly', type=Path, default=DISASM)
    args = parser.parse_args()
    began = time.monotonic()
    record('inputs.json', {p: identity((ROOT / p).read_bytes()) for p in DEPENDENCIES}, args.write)
    excerpts = sources()
    record('source-excerpts.json', excerpts, args.write)
    projection = clients()
    record('registered-clients.json', projection, args.write)
    hook_uses = hook_source_uses()
    record('hook-source-uses.json', hook_uses, args.write)
    elf = args.install.read_bytes()
    assert identity(elf) == {'bytes': 24561432, 'sha256': '7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368'}
    byte_count = hook_windows(elf, args.write, args.disassembly)
    result = {'status': 'pass', 'source_excerpts': len(excerpts),
              'source_members': len({x['member'] for x in excerpts}),
              'imported_code_reference_records': len(projection['selected_code_references']),
              'new_timing_hook_windows': len(HOOKS), 'new_installed_bytes_checked': byte_count,
              'named_hook_source_occurrences': sum(len(x['matches']) for x in hook_uses['files']),
              'unclosed_collection_timing_hook_cells': 4,
              'complete_R': None, 'exceptional_identifier_charge': None,
              'measured_seconds': time.monotonic() - began,
              'mode': 'write' if args.write else 'compare'}
    if not args.write:
        (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
