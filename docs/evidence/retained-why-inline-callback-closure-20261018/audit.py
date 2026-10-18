#!/usr/bin/env python3
"""Read pinned ELF files as data; enumerate selected native interface references.

This is an evidence extractor, not a control-flow or non-aliasing theorem.
No target executable is started. GNU objdump is the only subprocess.
"""
import argparse
import bisect
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

PREFIX = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire')
INSTALL = PREFIX / 'cache/releases/gnatprove_16.1.0_82528bef/libexec/spark'
OBJDUMP = PREFIX / 'toolchains/gnat_native_16.1.0_9f74f58a/bin/objdump'
EXPECTED = {
    'gnatwhy3': (24561432, '7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368'),
    'ada_terms.cmxs': (374704, '8d66110e7af82ddfe07e9eec333ebc1ad801667aa2052b5eacc62ae2a453bf27'),
    'gnat_json.cmxs': (710720, 'cfa5d1b11faae072004fc0f63058b52c43e625a3312abcf046c6dc8758845ab1'),
}
MODULES = ['camlStdlib__Gc', 'camlThread', 'camlDynlink', 'camlStdlib__Sys',
           'camlDynlink_compilerlibs', 'camlDynlink_compilerlibs__Dll',
           'camlDynlink_compilerlibs__Meta', 'camlDynlink_compilerlibs__Symtable']
OPS = ['caml_ba_mapped_ops', 'caml_ba_ops', 'caml_condition_ops',
       'caml_int32_ops', 'caml_int64_ops', 'caml_mutex_ops',
       'caml_nativeint_ops', 'caml_threadstatus_ops', 'channel_operations',
       'ml_z_custom_ops']
SYMBOLS = [
    'generic_final_register', 'caml_final_register',
    'caml_final_register_called_without_value', 'caml_memprof_start',
    'caml_install_signal_handler', 'caml_thread_new', 'caml_c_thread_register',
    'caml_thread_yield', 'caml_natdynlink_loadsym', 'caml_dynlink_lookup_symbol',
    'caml_dynlink_open_lib', 'caml_get_global_data', 'caml_reify_bytecode',
    'caml_dlsym', 'caml_globalsym', 'caml_dlopen', 'caml_natdynlink_run_toplevel',
    'caml_alloc_final', 'caml_final_custom_operations',
    'caml_alloc_custom', 'caml_alloc_custom_mem', 'alloc_custom_gen',
    'caml_register_custom_operations', 'caml_init_custom_operations',
    'custom_ops_table', 'custom_ops_final_table', 'caml_channel_mutex_free',
    'finalisable_first', 'finalisable_last', 'running_finalisation_function',
] + OPS
WITNESS_BODIES = [
    'camlGnat_main__save_session_and_exit_3133',
    'camlWhy3__Trans__accum_1889',
    'camlStdlib__Ephemeron__find_730',
    'camlStdlib__Ephemeron__find_rec_721',
    'camlWhy3__Session_itp__get_task_1722',
    'camlWhy3__Session_itp__save_session_4339',
    'camlStdlib__exit_488', 'camlDynlink_common__fun_1837',
    'caml_finalize_channel', 'caml_close_channel', 'caml_io_mutex_free',
    'caml_process_pending_actions_exn', 'caml_execute_signal_exn',
    'caml_garbage_collection', 'caml_call_gc',
]


def operand_addresses(op, address, size):
    candidates = set()
    for x in re.findall(r'(?:#\s*|\b)([0-9a-f]+)\s+<', op):
        candidates.add(int(x, 16))
    without_displacements = re.sub(r'-?0x[0-9a-f]+\(%[^)]+\)', '', op)
    for x in re.findall(r'(?<![\w])(?:\$)?0x([0-9a-f]+)', without_displacements):
        candidates.add(int(x, 16))
    for x in re.findall(r'(-?0x[0-9a-f]+)\(%rip\)', op):
        candidates.add(address + size + int(x, 16))
    return candidates


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


class ELF:
    def __init__(self, data):
        self.data = data
        h = struct.unpack_from('<16sHHIQQQIHHHHHH', data)
        assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
        self.sections = []
        for i in range(h[12]):
            x = struct.unpack_from('<IIQQQQIIQQ', data, h[6] + i * h[11])
            self.sections.append(dict(zip(
                ['nameoff', 'type', 'flags', 'addr', 'offset', 'size', 'link',
                 'info', 'align', 'entsize'], x)))
        shstr = self.section_bytes(h[13])
        for s in self.sections:
            s['name'] = self.string(shstr, s['nameoff'])
        self.segments = []
        for i in range(h[10]):
            x = struct.unpack_from('<IIQQQQQQ', data, h[5] + i * h[9])
            self.segments.append(dict(zip(
                ['type', 'flags', 'offset', 'vaddr', 'paddr', 'filesz',
                 'memsz', 'align'], x)))
        self.tables = {}
        self.symbols = {}
        for i, s in enumerate(self.sections):
            if s['type'] not in (2, 11):
                continue
            strings = self.section_bytes(s['link'])
            table = []
            for off in range(s['offset'], s['offset'] + s['size'], s['entsize']):
                n, info, other, shndx, value, size = struct.unpack_from('<IBBHQQ', data, off)
                sym = dict(name=self.string(strings, n), info=info, other=other,
                           shndx=shndx, value=value, size=size)
                table.append(sym)
                if sym['name'] and shndx:
                    self.symbols[sym['name']] = sym
            self.tables[i] = table
        self.named = sorted((x['value'], n) for n, x in self.symbols.items())
        self.addresses = [x[0] for x in self.named]

    @staticmethod
    def string(data, offset):
        end = data.index(b'\0', offset)
        return data[offset:end].decode('utf-8')

    def section_bytes(self, i):
        s = self.sections[i]
        assert s['type'] != 8
        return self.data[s['offset']:s['offset'] + s['size']]

    def read(self, address, size):
        for p in self.segments:
            if p['type'] == 1 and p['vaddr'] <= address and address + size <= p['vaddr'] + p['filesz']:
                off = p['offset'] + address - p['vaddr']
                return self.data[off:off + size]
        raise ValueError(('not entirely file-backed', hex(address), size))

    def label(self, address):
        i = bisect.bisect_right(self.addresses, address) - 1
        if i < 0:
            return None
        start, name = self.named[i]
        return name + '+' + hex(address - start)


def ranges(elf):
    out = {}
    for m in MODULES:
        for kind in ('code', 'data'):
            a = elf.symbols[m + '__' + kind + '_begin']['value']
            b = elf.symbols[m + '__' + kind + '_end']['value']
            out[m + ':' + kind] = (a, b)
    for name in SYMBOLS:
        x = elf.symbols[name]
        assert x['size'] > 0, name
        out[name] = (x['value'], x['value'] + x['size'])
    return out


def memberships(address, targets):
    return [name for name, (a, b) in targets.items() if a <= address < b]


def disassembly(elf, path, objdump, targets):
    raw = subprocess.check_output([str(objdump), '-d', '--wide', str(path)])
    lines = raw.decode().splitlines()
    functions = {}
    refs = []
    current = ''
    instructions = 0
    for line in lines:
        m = re.match(r'^[0-9a-f]+ <([^>]+)>:', line)
        if m:
            current = m[1]
            functions[current] = [line]
            continue
        if current:
            functions[current].append(line)
        m = re.match(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}\s)+)\s*(\S.*)$', line)
        if not m:
            continue
        instructions += 1
        address, bytewords, op = m.groups()
        address = int(address, 16)
        size = len(bytewords.split())
        candidates = operand_addresses(op, address, size)
        for value in sorted(candidates):
            groups = memberships(value, targets)
            if groups:
                refs.append(dict(function=current, address=address, target=value,
                                 groups=groups, instruction=line.strip()))
    owners = {x['function'] for x in refs}
    # Keep all selected module bodies, together with every reference owner.
    for n, body in functions.items():
        start = int(body[0].split()[0], 16)
        if any(targets[m + ':code'][0] <= start < targets[m + ':code'][1]
               for m in MODULES):
            owners.add(n)
    assert all(n in functions for n in WITNESS_BODIES), set(WITNESS_BODIES) - functions.keys()
    owners.update(WITNESS_BODIES)
    allocation_sites = []
    for n, body in functions.items():
        previous_rdi = None
        for line in body[1:]:
            if re.search(r',%[er]di(?:\s|$)', line):
                previous_rdi = line.strip()
            if re.search(r'\b(?:call|jmp)\s+.*<(?:caml_alloc_custom|caml_alloc_custom_mem)>', line):
                allocation_sites.append(dict(function=n, call=line.strip(),
                                             last_textual_rdi_write=previous_rdi))
    bodies = '\n'.join('\n'.join(functions[n]) for n in sorted(owners))
    # Normalize only objdump's input-path banner for identical relocated inputs.
    normalized = raw.replace(str(path).encode() + b':     file format',
                             b'<gnatwhy3>:     file format', 1)
    return {'disassembly_identity': identity(normalized), 'instruction_count': instructions,
            'code_references': refs, 'custom_allocator_sites': allocation_sites,
            'explicit_witness_bodies': WITNESS_BODIES}, bodies


def scan(elf, targets):
    refs = []
    words = 0
    for s in elf.sections:
        # Symbol and relocation tables are decoded separately below.
        if s['type'] != 1 or not s['flags'] & 2 or s['flags'] & 4:
            continue
        for off in range((-s['addr']) % 8, s['size'] - 7, 8):
            words += 1
            value = struct.unpack_from('<Q', elf.data, s['offset'] + off)[0]
            groups = memberships(value, targets)
            if groups:
                a = s['addr'] + off
                refs.append(dict(section=s['name'], address=a, value=value,
                                 nearest_symbol=elf.label(a), groups=groups))
    relocs = []
    for s in elf.sections:
        if s['type'] != 4 or not s['flags'] & 2:
            continue
        for off in range(s['offset'], s['offset'] + s['size'], s['entsize']):
            place, info, addend = struct.unpack_from('<QQq', elf.data, off)
            sym = elf.tables[s['link']][info >> 32]
            kind = info & 0xffffffff
            value = addend if kind == 8 else sym['value'] + addend
            groups = memberships(value, targets)
            if groups:
                relocs.append(dict(place=place, type=kind, symbol=sym['name'],
                                   addend=addend, value=value, groups=groups))
    exports = [x for i, table in elf.tables.items() if elf.sections[i]['type'] == 11
               for x in table if memberships(x['value'], targets)]
    return dict(aligned_allocated_progbits_words_scanned=words,
                data_references=refs, relocations=relocs, dynamic_symbols=exports)


def audit(install=INSTALL, objdump=OBJDUMP):
    paths = [install / 'bin/gnatwhy3'] + [install / 'lib/why3/plugins' / n
                                        for n in ['ada_terms.cmxs', 'gnat_json.cmxs']]
    elfs = {}
    for p in paths:
        data = p.read_bytes()
        ident = identity(data)
        assert (ident['bytes'], ident['sha256']) == EXPECTED[p.name], (p, ident)
        elfs[p.name] = ELF(data)
    main = elfs['gnatwhy3']
    targets = ranges(main)
    native, bodies = disassembly(main, paths[0], objdump, targets)
    native.update(scan(main, targets))
    native['ranges'] = targets
    native['input_identities'] = {n: identity(e.data) for n, e in elfs.items()}
    native['selected_storage'] = {}
    for name in SYMBOLS:
        sym = main.symbols[name]
        s = main.sections[sym['shndx']]
        rec = dict(address=sym['value'], size=sym['size'], section=s['name'],
                   zero_fill=s['type'] == 8, runtime_value_observed=False)
        if s['type'] != 8:
            rec['file_bytes'] = main.read(sym['value'], sym['size']).hex()
        native['selected_storage'][name] = rec
    native['plugins'] = {}
    for p in paths[1:]:
        e = elfs[p.name]
        imports = [x['name'] for i, table in e.tables.items()
                   if e.sections[i]['type'] == 11 for x in table
                   if not x['shndx'] and x['name']]
        native['plugins'][p.name] = {'imports': sorted(imports)}
    return native, bodies


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--install', type=Path, default=INSTALL)
    parser.add_argument('--objdump', type=Path, default=OBJDUMP)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result, bodies = audit(args.install, args.objdump)
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / 'native-audit.json').write_text(json.dumps(result, indent=2) + '\n')
    (args.output / 'native-bodies.txt').write_text(bodies)
    print(json.dumps({'status': 'pass', 'input_identities': result['input_identities'],
                      'code_references': len(result['code_references']),
                      'data_references': len(result['data_references'])}))
