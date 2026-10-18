#!/usr/bin/env python3
"""Replay the selected compiler's static lifecycle without executing it.

ELF entries, exported destructor identities, complete retained instruction bytes,
straight-line initializer calls and request arithmetic are checked here. Source
dispositions and the fixed-prefix read projection remain reviewed arguments in
the companion report, not conclusions of a general machine-code verifier.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import struct

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--plugin-include', type=Path, required=True)
p.add_argument('--cxx-include', type=Path, required=True)
p.add_argument('--gnat1', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
here = Path(__file__).resolve().parent
identity = json.loads((here / 'static-lifecycle-inputs.json').read_bytes())
sha = lambda b: hashlib.sha256(b).hexdigest()
sources = {}
for row in identity['files']:
    root = {'gcc': a.gcc_root, 'plugin': a.plugin_include,
            'cxx': a.cxx_include}[row['root']]
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
prior = {}
for row in identity['prior_results']:
    raw = (here / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    prior[row['path']] = json.loads(raw) if row['path'].endswith('.json') else raw.decode()
raw = a.gnat1.read_bytes()
assert sha(raw) == identity['gnat1_sha256']
h = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
assert h[0][:7] == b'\x7fELF\x02\x01\x01' and h[2] == 62
section_list = [struct.unpack_from('<IIQQQQIIQQ', raw, h[6] + i*h[11])
                for i in range(h[12])]
st = section_list[h[13]]
names = raw[st[4]:st[4]+st[5]]
def z(buf, at):
    return buf[at:buf.index(b'\0', at)].decode()
sections = {z(names, row[0]): row for row in section_list}
def array(name):
    s = sections[name]
    return list(struct.unpack_from('<'+'Q'*(s[5]//8), raw, s[4]))
assert array('.init_array') == identity['init_array']
assert array('.fini_array') == identity['fini_array']
assert '.preinit_array' not in sections
assert len(array('.init_array')) == 59 and len(array('.fini_array')) == 2
assert len(set(identity['init_array'])) == 59
assert identity['compiler_init_roots'] == [
    root for root in identity['init_array'] if root not in
    (identity['CRT_init_root'], identity['linked_Cxx_library_init_root'])]
assert len(identity['compiler_init_roots']) == 57
assert set(identity['fini_array']) == {
    identity['CRT_fini_root'], identity['linked_runtime_fini_root']}
def at_vaddr(addr, size):
    owners = [s for s in section_list if s[1] != 8 and s[3] <= addr
              and addr+size <= s[3]+s[5] and s[5]]
    assert len(owners) == 1, hex(addr)
    s = owners[0]
    return raw[s[4]+addr-s[3]:s[4]+addr-s[3]+size]

st = sections['.dynstr']; names = raw[st[4]:st[4]+st[5]]
s = sections['.dynsym']; dynamic = []
for pos in range(s[4], s[4]+s[5], s[9]):
    name, info, other, section, addr, size = struct.unpack_from('<IBBHQQ', raw, pos)
    dynamic.append({'name': z(names, name), 'info': info, 'section': section,
                    'addr': addr, 'size': size})
exports = {}
for symbol in dynamic:
    if symbol['info'] & 15 == 2 and symbol['addr']:
        exports.setdefault(symbol['addr'], set()).add(symbol['name'])
for d in identity['destructors']:
    assert exports[d['address']] == set(d['symbols']), d['name']
registration_imports = [x['name'] for x in dynamic if not x['section'] and
                        re.search(r'(?:^|_)(?:atexit|on_exit)$', x['name'])]
assert registration_imports == ['__cxa_atexit']
relocations = []
for name, section in sections.items():
    if section[1] == 4:  # SHT_RELA
        for pos in range(section[4], section[4]+section[5], section[9]):
            offset, info, addend = struct.unpack_from('<QQq', raw, pos)
            if dynamic[info >> 32]['name'] == '__cxa_atexit':
                relocations.append((offset, info & 0xffffffff, addend))
assert relocations == [(identity['cxa_atexit_GOT'], 7, 0)]
assert at_vaddr(identity['cxa_atexit_plt'], 2) == b'\xff\x25'
assert (identity['cxa_atexit_plt'] + 6 +
        struct.unpack('<i', at_vaddr(identity['cxa_atexit_plt']+2, 4))[0]
        == identity['cxa_atexit_GOT'])

instructions = {}
for line in prior['static-lifecycle-disassembly.txt'].split('\n'):
    if not line:
        continue
    match = re.fullmatch(r'([0-9a-f]+): ([0-9a-f]+)\t(.*)', line)
    assert match, line
    addr = int(match[1], 16); code = bytes.fromhex(match[2])
    assert 1 <= len(code) <= 15 and at_vaddr(addr, len(code)) == code, hex(addr)
    instructions[addr] = {'bytes': code, 'asm': match[3]}

# All 57 GCC-owned initializer roots are straight-line. The two other roots
# are CRT and the linked C++ library and are kept distinct in the report.
registrations = []; initializer_calls = []; visited = set()
for root in identity['compiler_init_roots']:
    at = root; edi = None
    while True:
        assert at not in visited, hex(at)
        visited.add(at)
        insn = instructions[at]; asm = insn['asm']; op = asm.split()[0]
        immediate = re.fullmatch(r'mov\s+\$0x([0-9a-f]+),%[er]di', asm)
        if immediate:
            edi = int(immediate[1], 16)
        elif insn['bytes'][:3] == b'\x48\x8d\x3d':
            assert len(insn['bytes']) == 7
            edi = at + 7 + struct.unpack('<i', insn['bytes'][3:])[0]
        elif re.search(r',%[er]di(?:\s|$)', asm):
            edi = None
        branch = re.match(r'(call|jmp)\s+([0-9a-f]+)', asm)
        if branch:
            target = int(branch[2], 16)
            if target == identity['cxa_atexit_plt']:
                assert edi in {d['address'] for d in identity['destructors']}, (hex(at), edi)
                registrations.append({'site': at, 'root': root, 'destructor': edi})
            else:
                initializer_calls.append({'site': at, 'root': root, 'asm': asm})
            edi = None
        assert not (op.startswith('j') and op != 'jmp'), asm
        assert op != 'call' or branch, asm  # no indirect calls in these roots
        if op.startswith('ret') or op == 'jmp':
            assert op != 'jmp' or branch, asm
            break
        at += len(insn['bytes'])
assert len(registrations) == 94
counts = Counter(r['destructor'] for r in registrations)
assert len(counts) == 69 and set(counts) == {d['address'] for d in identity['destructors']}

# Conservative byte candidates for direct rel32 registration calls/tails in
# the complete .text. Every hit is an actual retained call/jump instruction.
# This corroborates the source/generated-lifecycle census; it is not a claim
# that arbitrary indirect machine-code data flow has been mechanically proved.
s = sections['.text']; code = raw[s[4]:s[4]+s[5]]; all_sites = []
for opcode in [b'\xe8', b'\xe9']:
    pos = code.find(opcode)
    while 0 <= pos <= len(code)-5:
        addr = s[3]+pos
        if addr+5+struct.unpack_from('<i', code, pos+1)[0] == identity['cxa_atexit_plt']:
            assert instructions[addr]['bytes'] == code[pos:pos+5], hex(addr)
            all_sites.append(addr)
        pos = code.find(opcode, pos+1)
extra_sites = sorted(set(all_sites)-{r['site'] for r in registrations})
assert len(all_sites) == 96 and extra_sites == [0x1358895, 0x264eeb1]

assert '#define GATHER_STATISTICS 0' in sources['auto-host.h']
assert 'm_map = new mem_map_t (13, false, false, false);' in sources['gcc/mem-stats.h']
assert 'm_reverse_map = new reverse_mem_map_t (13, false, false, false);' in sources['gcc/mem-stats.h']
assert 'm_reverse_object_map = new reverse_object_map_t (13, false, false, false);' in sources['gcc/mem-stats.h']
assert 'static vrange_allocator ggc_vrange_allocator (true);' in sources['gcc/value-range-storage.cc']
assert 'hash_map<const_tree, hashval_t> sem_item::m_type_hash_cache;' in sources['gcc/ipa-icf.cc']
assert 'static hash_map <nofree_string_hash, align_flags> cache;' in sources['gcc/toplev.cc']
assert 'target_hard_regs::finalize' in sources['gcc/reginfo.cc']
prefix = prior['native-gcc-prefix-witness.json']
assert prefix['gnat1_sha256'] == identity['gnat1_sha256']
assert prefix['counters']['ggc_bytes']['positive_events'] == 39257
assert not prefix['collection_or_new_thread_observed']
assert prior['native-process-shell.json']['known_GGC_subtotal_unchanged'] == 40098

groups = {}
for d in identity['destructors']:
    group = groups.setdefault(d['disposition'], {'targets': 0, 'registrations': 0})
    group['targets'] += 1; group['registrations'] += counts[d['address']]
result = {
    'scope': identity['scope'],
    'verified_source_files': len(identity['files']),
    'verified_prior_records_and_disassembly': len(identity['prior_results']),
    'gnat1_sha256': identity['gnat1_sha256'],
    'retained_complete_instructions_verified': len(instructions),
    'ELF_init_entries': 59, 'GCC_owned_init_entries': 57, 'ELF_fini_entries': 2,
    'GCC_static_cxa_registrations': 94, 'distinct_GCC_static_destructor_targets': 69,
    'direct_text_cxa_sites': len(all_sites),
    'other_direct_sites': [
        {'address': extra_sites[0], 'route': 'fixed alignment cache, conservatively charged'},
        {'address': extra_sites[1], 'route': 'hash statistics function static, GATHER_STATISTICS=0'}],
    'destructor_groups': groups,
    'initializer_calls_other_than_cxa_registration': initializer_calls,
    'registrations': registrations,
    'additional_fixed_ordinary_individual_request_bounds': {
        'each_statistics_map_control': 96,
        'each_statistics_key_pointer_map_backing': 13*16,
        'each_statistics_key_pair_map_backing': 13*24,
        'ICF_static_type_map_backing': 13*16,
        'GC_vrange_allocator_control': 8,
        'alignment_cache_backing': 13*24,
        'alignment_parse_vector': 8+4*4},
    'statistics_descriptor_instances': 4,
    'statistics_maps_per_descriptor': 3,
    'fixed_ordinary_prefix_capacity_basis': 'successful retained prefix plus source read projection, not GGC byte total',
    'new_static_exit_ordinary_requests': 0, 'new_static_exit_GGC_events': 0,
    'GCC_static_exit_and_fixed_startup_closed_under_stated_projection': True,
    'known_GGC_subtotal_unchanged': 40098,
    'variable_ingress_requires_separate_source_descriptor_joins': True,
    'whole_native_null_capacity_established': False,
    'aggregate_RAM_or_address_space_admission_gate': False,
    'compiler_prover_debugger_executions': 0}
a.output.write_text(json.dumps(result, indent=2)+'\n')
print(f"Verified {len(identity['files'])} sources, {len(instructions)} instructions, "
      f"{len(registrations)} compiler static registrations / {len(counts)} destructor targets")
