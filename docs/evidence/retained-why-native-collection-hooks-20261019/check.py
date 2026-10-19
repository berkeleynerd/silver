#!/usr/bin/env python3
"""Selected hook linkage evidence, not a native alias or effect theorem.

Read existing capture metadata and pinned ELF images. --write creates the new
numeric census from retained disassembly; --disassembly rechecks that census.
Default checks frozen projections and their byte witnesses. No target, capture,
disassembler, old checker or solver is executed. No live memory is read.
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
CAPTURE = 'docs/evidence/retained-why-session-save-state-20261019/capture.tar.gz'
CAPTURE_INDEX = 'docs/evidence/retained-why-session-save-state-20261019/capture-identities.json'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
CONTRACT = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/caml/misc.h'
DISASSEMBLY = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
HOOKS = {
    'caml_major_slice_begin_hook': 0xfaaf48,
    'caml_major_slice_end_hook': 0xfaaf40,
    'caml_minor_gc_begin_hook': 0xfaaf38,
    'caml_minor_gc_end_hook': 0xfaaf30,
}
ANCHORS = {'__bss_start', '_edata', '_end', '__data_start', 'data_start',
           '_DYNAMIC', '__TMC_END__', '_GLOBAL_OFFSET_TABLE_'}
DEPENDENCIES = [CAPTURE, CAPTURE_INDEX, OCAML,
    'docs/evidence/retained-why-inline-callback-closure-20261018/binding.json',
    'docs/evidence/retained-why-save-preservation-20261019/timing-hook-windows.json',
    'docs/research/retained-why-inline-callback-closure.md',
    'docs/research/retained-why-save-preservation.md',
    'docs/reviews/review-why-save-preservation-3700c2adc7.md']


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def record(name, value, write):
    path = HERE / name
    if write:
        path.write_text(json.dumps(value, indent=2) + '\n')
    else:
        assert json.loads(path.read_text()) == value, name


class ELF:
    def __init__(self, raw):
        self.raw = raw
        h = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
        assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
        self.kind = h[1]
        self.sections = [dict(zip(
            ['nameoff', 'type', 'flags', 'addr', 'offset', 'size', 'link', 'info', 'align', 'entsize'],
            struct.unpack_from('<IIQQQQIIQQ', raw, h[6] + i * h[11]))) for i in range(h[12])]
        names = self.data(h[13])
        for s in self.sections:
            s['name'] = self.string(names, s['nameoff'])
        self.tables = {}
        for i, s in enumerate(self.sections):
            if s['type'] not in (2, 11):
                continue
            names = self.data(s['link'])
            table = []
            for offset in range(s['offset'], s['offset'] + s['size'], s['entsize']):
                n, info, other, shndx, value, size = struct.unpack_from('<IBBHQQ', raw, offset)
                table.append(dict(name=self.string(names, n), info=info, other=other,
                                  shndx=shndx, value=value, size=size))
            self.tables[i] = table

    @staticmethod
    def string(raw, offset):
        return raw[offset:raw.index(b'\0', offset)].decode()

    def data(self, index):
        s = self.sections[index]
        assert s['type'] != 8
        return self.raw[s['offset']:s['offset'] + s['size']]

    def read(self, address, count):
        for s in self.sections:
            if s['type'] != 8 and s['addr'] <= address and address + count <= s['addr'] + s['size']:
                offset = s['offset'] + address - s['addr']
                return self.raw[offset:offset + count]
        raise AssertionError(('not file-backed', hex(address), count))

    def dynamic(self):
        out = []
        for s in self.sections:
            if s['type'] == 6:
                names = self.data(s['link'])
                for offset in range(s['offset'], s['offset'] + s['size'], s['entsize']):
                    tag, value = struct.unpack_from('<QQ', self.raw, offset)
                    if tag in (1, 14):
                        out.append({'tag': tag, 'string': self.string(names, value)})
        return out


def capture():
    manifest = json.loads((ROOT / CAPTURE_INDEX).read_text())
    assert identity((ROOT / CAPTURE).read_bytes()) == manifest['identity']
    wanted = ['input_is_valid/capture/summary.json', 'input_is_valid/capture/process.json',
              'input_is_valid/capture/maps.txt']
    with tarfile.open(ROOT / CAPTURE) as archive:
        members = {n: archive.extractfile(n).read() for n in wanted}
    for name, raw in members.items():
        assert identity(raw) == manifest['members'][name]
    summary = json.loads(members[wanted[0]])
    process = json.loads(members[wanted[1]])
    assert process['pid'] == 97103 and summary['completed'] and not summary['failures']
    prior = json.loads((ROOT / DEPENDENCIES[3]).read_text())
    assert summary['mapped_files'] == prior['mapped_files']
    return {'run_id': '20261019T000304-fcb988ec2c03', 'pid': process['pid'],
            'members': {n: identity(raw) for n, raw in members.items()},
            'mapped_files': summary['mapped_files'], 'environment': process['environment'],
            'maps': members[wanted[2]].decode(),
            'scope': 'Metadata projection only; accepted observation is not replayed.'}


def in_hook(value):
    return any(address <= value < address + 8 for address in HOOKS.values())


def linkage(path, expected, is_main):
    raw = Path(path).read_bytes()
    assert identity(raw) == expected, path
    e = ELF(raw)
    dynsyms = [x for i, table in e.tables.items() if e.sections[i]['type'] == 11 for x in table]
    syms = [dict(x, table=e.sections[i]['name']) for i, table in e.tables.items() for x in table]
    hook_symbols = [x for x in syms if x['name'] in HOOKS]
    aliases = []
    if is_main:
        for x in syms:
            if x['shndx'] and (in_hook(x['value']) or any(x['value'] <= address < x['value'] + x['size'] for address in HOOKS.values())):
                aliases.append(x)
        for name, address in HOOKS.items():
            matches = [x for x in hook_symbols if x['name'] == name]
            assert len(matches) == 2
            for x in matches:
                assert (x['value'], x['size'], x['info'], x['other']) == (address, 8, 17, 0)
                assert e.sections[x['shndx']]['name'] == '.bss' and e.sections[x['shndx']]['type'] == 8
    relocations = []
    relocation_sections = []
    for s in e.sections:
        if s['type'] not in (4, 9):
            continue
        assert s['type'] == 4
        relocation_sections.append({k: s[k] for k in ('name', 'flags', 'size', 'entsize')})
        for offset in range(s['offset'], s['offset'] + s['size'], s['entsize']):
            place, info, addend = struct.unpack_from('<QQq', raw, offset)
            symbol = e.tables[s['link']][info >> 32]
            kind = info & 0xffffffff
            resolved = addend if kind == 8 else symbol['value'] + addend
            if symbol['name'] in HOOKS or (is_main and (in_hook(place) or in_hook(resolved))):
                relocations.append(dict(section=s['name'], place=place, kind=kind,
                                        symbol=symbol['name'], addend=addend, resolved=resolved))
    anchors = [x for x in syms if x['name'] in ANCHORS] if is_main else []
    anchor_addresses = {x['value'] for x in anchors}
    stored_addresses = []
    anchor_pointers = []
    name_occurrences = []
    data_bytes = 0
    for i, s in enumerate(e.sections):
        if s['type'] == 8:
            continue
        data = e.data(i)
        for name in HOOKS:
            start = 0
            needle = name.encode() + b'\0'
            while (found := data.find(needle, start)) != -1:
                name_occurrences.append(dict(name=name, section=s['name'], offset=found,
                                             allocated=bool(s['flags'] & 2)))
                start = found + 1
        if not is_main or s['type'] != 1 or not s['flags'] & 2 or s['flags'] & 4:
            continue
        data_bytes += len(data)
        for address in sorted(anchor_addresses):
            start = 0
            while (found := data.find(address.to_bytes(8, 'little'), start)) != -1:
                anchor_pointers.append(dict(section=s['name'], address=s['addr'] + found, value=address))
                start = found + 1
        # Every byte offset, including unaligned 32-bit address fragments.
        for address in range(min(HOOKS.values()), max(HOOKS.values()) + 8):
            for size in (4, 8):
                needle = address.to_bytes(size, 'little')
                start = 0
                while (found := data.find(needle, start)) != -1:
                    stored_addresses.append(dict(section=s['name'], address=s['addr'] + found,
                                                 value=address, size=size))
                    start = found + 1
    return e, dict(path=path, identity=expected, elf_type=e.kind,
        dynamic_dependencies=e.dynamic(), hook_symbols=hook_symbols,
        overlapping_symbols=aliases, selected_relocations=relocations,
        section_anchor_symbols=anchors, section_anchor_stored_pointers=anchor_pointers,
        relocation_sections=relocation_sections,
        stored_address_matches=stored_addresses, allocated_noncode_progbits_bytes_scanned=data_bytes,
        hook_name_occurrences=name_occurrences,
        native_lookup_imports=[x['name'] for x in dynsyms if not x['shndx'] and any(t in x['name'] for t in ('dlsym', 'dlopen', 'dladdr', 'dlinfo', 'dl_iterate', 'getauxval'))],
        undefined_dynamic_symbols=[x['name'] for x in dynsyms if not x['shndx'] and x['name']],
        source_file_labels=sorted(set(x['name'] for x in syms if x['info'] & 15 == 4 and x['name'])))


def instructions(raw, elf):
    """Decode retained objdump records, joining byte-only continuation lines."""
    current = None
    owner = ''
    for line in raw.decode().splitlines():
        m = re.match(r'^[0-9a-f]+ <([^>]+)>:', line)
        if m:
            if current:
                yield current
                current = None
            owner = m[1]
            continue
        parts = line.split('\t')
        if len(parts) < 2 or not re.match(r'^\s*[0-9a-f]+:$', parts[0]):
            continue
        address = int(parts[0].strip()[:-1], 16)
        encoded = parts[1].strip()
        if not re.fullmatch(r'(?:[0-9a-f]{2})(?: [0-9a-f]{2})*', encoded):
            continue
        data = bytes.fromhex(encoded)
        op = '\t'.join(parts[2:]).strip()
        if not op:
            assert current and address == current['address'] + len(current['bytes'])
            current['bytes'] += data
            continue
        if current:
            yield current
        current = dict(owner=owner, address=address, bytes=data, operation=op)
    if current:
        yield current


def code_projection(elf, disassembly):
    raw = disassembly.read_bytes()
    prior = json.loads((ROOT / DEPENDENCIES[4]).read_text())
    assert identity(raw) == prior['origin_identity']
    refs, neighbours, anchor_refs, aux_refs, witnesses = [], [], [], [], []
    anchors = {x['value'] for table in elf.tables.values() for x in table if x['name'] in ANCHORS}
    witness_owners = {'unix_environment', 'register_tm_clones', 'deregister_tm_clones', 'scanmult'}
    counts = {'instructions': 0, 'matched_instruction_bytes': 0}
    coverage = {s['name']: bytearray(s['size']) for s in elf.sections if s['flags'] & 4}
    sections = [s for s in elf.sections if s['flags'] & 4]
    for row in instructions(raw, elf):
        address, encoded, op = row['address'], row['bytes'], row['operation']
        assert elf.read(address, len(encoded)) == encoded
        owners = [s for s in sections if s['addr'] <= address and address + len(encoded) <= s['addr'] + s['size']]
        assert len(owners) == 1
        s = owners[0]
        offset = address - s['addr']
        assert not any(coverage[s['name']][offset:offset + len(encoded)])
        coverage[s['name']][offset:offset + len(encoded)] = b'\1' * len(encoded)
        counts['instructions'] += 1
        counts['matched_instruction_bytes'] += len(encoded)
        candidates = {int(x, 16) for x in re.findall(r'(?:#\s*|\b)([0-9a-f]+)\s+<', op)}
        candidates.update(int(x, 16) for x in re.findall(r'0x([0-9a-f]+)', op))
        candidates.update(address + len(encoded) + int(x, 16) for x in re.findall(r'(-?0x[0-9a-f]+)\(%rip\)', op))
        hits = sorted(x for x in candidates if in_hook(x))
        near = sorted(x for x in candidates if 0xfaaf00 <= x < 0xfaaf80)
        converted = dict(owner=row['owner'], address=address, bytes=encoded.hex(), operation=op)
        if hits:
            refs.append(dict(converted, targets=hits))
        if near:
            neighbours.append(dict(converted, targets=near))
        if candidates.intersection(anchors):
            anchor_refs.append(dict(converted, targets=sorted(candidates.intersection(anchors))))
        if '<getauxval@plt>' in op:
            aux_refs.append(converted)
        if row['owner'] in witness_owners:
            witnesses.append(converted)
    gaps = []
    for s in sections:
        flags = coverage[s['name']]
        offset = 0
        while offset < len(flags):
            if flags[offset]:
                offset += 1
                continue
            start = offset
            while offset < len(flags) and not flags[offset]:
                offset += 1
            raw_gap = elf.read(s['addr'] + start, offset - start)
            gaps.append(dict(section=s['name'], address=s['addr'] + start,
                             bytes=raw_gap.hex()))
    expected_loads = {(x['instruction_address'], x['instruction_bytes']) for x in prior['windows'][:4]}
    assert {(x['address'], x['bytes']) for x in refs} == expected_loads
    return dict(origin_identity=identity(raw), counts=counts,
                executable_sections=[{k: s[k] for k in ('name', 'addr', 'size')} for s in sections],
                undecoded_ranges=gaps, hook_references=refs, neighbouring_references=neighbours,
                section_anchor_references=anchor_refs, getauxval_references=aux_refs,
                selected_owner_instructions=witnesses,
                scope='Numeric operands and decoded RIP targets; no register value propagation, alternate-entry decoding or native alias theorem.')


def run():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--disassembly', type=Path)
    args = parser.parse_args()
    started = time.monotonic()
    record('inputs.json', {p: identity((ROOT / p).read_bytes()) for p in DEPENDENCIES}, args.write)
    binding = capture()
    record('capture-binding.json', binding, args.write)
    images = {}
    for path, expected in binding['mapped_files'].items():
        is_main = Path(path).name == 'gnatwhy3'
        elf, details = linkage(path, expected, is_main)
        images[Path(path).name] = details
        if is_main:
            main = elf
    record('linkage.json', images, args.write)
    if args.write or args.disassembly:
        code = code_projection(main, args.disassembly or DISASSEMBLY)
        record('code-projection.json', code, args.write)
    else:
        code = json.loads((HERE / 'code-projection.json').read_text())
        prior = json.loads((ROOT / DEPENDENCIES[4]).read_text())
        assert code['origin_identity'] == prior['origin_identity']
        for key in ('hook_references', 'neighbouring_references', 'section_anchor_references',
                    'getauxval_references', 'selected_owner_instructions'):
            for row in code[key]:
                raw = bytes.fromhex(row['bytes'])
                assert main.read(row['address'], len(raw)) == raw
        assert {(x['address'], x['bytes']) for x in code['hook_references']} == {
            (x['instruction_address'], x['instruction_bytes']) for x in prior['windows'][:4]}
    excerpts = []
    prefix = CONTRACT.removesuffix('runtime/caml/misc.h')
    with tarfile.open(ROOT / OCAML) as archive:
        for name, first, last in [('runtime/caml/misc.h', 188, 196),
                                  ('otherlibs/unix/envir.c', 40, 70),
                                  ('runtime/startup_aux.c', 89, 143)]:
            member = prefix + name
            raw = archive.extractfile(member).read()
            excerpts.append(dict(archive=OCAML, member=member, identity=identity(raw),
                first=first, last=last, text=''.join(raw.decode().splitlines(keepends=True)[first - 1:last])))
    record('source-excerpts.json', excerpts, args.write)
    assert not code['undecoded_ranges']
    assert not images['gnatwhy3']['stored_address_matches']
    assert {x['name'] for x in images['gnatwhy3']['overlapping_symbols']} == set(HOOKS)
    for name, row in images.items():
        assert not row['selected_relocations']
        if name != 'gnatwhy3':
            assert not row['hook_symbols'] and not row['hook_name_occurrences']
    assert len(code['getauxval_references']) == 1
    assert code['getauxval_references'][0]['owner'] == 'unix_environment'
    anchor_leas = [x for x in code['section_anchor_references'] if x['operation'].startswith('lea')]
    assert {x['owner'] for x in anchor_leas} == {'register_tm_clones', 'deregister_tm_clones'}
    assert all('<stderr@GLIBC_2.2.5>' in x['operation'] and x['operation'].startswith('mov')
               for x in code['section_anchor_references'] if x not in anchor_leas)
    result = dict(status='pass', selected_images=len(images), hook_cells=len(HOOKS),
        main_hook_instruction_references=len(code['hook_references']),
        main_stored_address_matches=len(images['gnatwhy3']['stored_address_matches']),
        selected_hook_relocations=sum(len(x['selected_relocations']) for x in images.values()),
        instruction_census_recomputed=bool(args.write or args.disassembly),
        inspected_interface_null_preservation_claim=True,
        arbitrary_native_alias_theorem=False, runtime_hook_values_observed=False,
        complete_R=None, exceptional_identifier_charge=None,
        elapsed_seconds=time.monotonic() - started)
    if args.write:
        (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    run()
