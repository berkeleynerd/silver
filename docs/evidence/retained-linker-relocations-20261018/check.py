"""Read fixed and accepted binder ELF relocation operand domains; no tool runs."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import struct
import argparse
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
repo = root.parents[2]
for row in json.loads((root/'inputs.json').read_bytes()):
    raw = (repo/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
manifest = json.loads((root/'sources.json').read_bytes())
with tarfile.open(root/'sources.tar.gz', 'r:gz') as archive:
    assert sorted(archive.getnames()) == sorted(row['path'] for row in manifest['files'])
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
layout = json.loads((root/'layout-projection.json').read_bytes())
aggregate = json.loads((repo/'docs/evidence/retained-linker-join-20261018/result.json').read_bytes())
assert layout == {k: aggregate[k] for k in layout}
main = json.loads((repo/'docs/evidence/retained-assembler-capacity-20261018/check-results.json').read_bytes())
shape = json.loads((repo/'docs/evidence/retained-linker-layout-20261018/layout-shape-results.json').read_bytes())
assert shape['mapping_convergence_established']
assert shape['selected_EH_alignment_upper'] == 8
inventory = json.loads((repo / 'docs/evidence/retained-link-inputs-20261018/inventory.json').read_bytes())
sha = lambda b: hashlib.sha256(b).hexdigest()
names_by_type = {1:'R_X86_64_64',2:'R_X86_64_PC32',4:'R_X86_64_PLT32',
                 9:'R_X86_64_GOTPCREL',10:'R_X86_64_32',19:'R_X86_64_TLSGD',
                 20:'R_X86_64_TLSLD',21:'R_X86_64_DTPOFF32',
                 41:'R_X86_64_GOTPCRELX',42:'R_X86_64_REX_GOTPCRELX'}
rows = {}
counts = Counter()
bad_merge = []


def inspect(data, label, family):
    assert data[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H',data,18)[0] == 62
    elf_type = struct.unpack_from('<H',data,16)[0]
    if elf_type != 1:
        assert elf_type == 3
        counts['DSOs_excluded_from_relocation_scan'] += 1
        return
    counts[family + '_ET_REL_files'] += 1
    shoff = struct.unpack_from('<Q',data,40)[0]
    stride, n, name_index = struct.unpack_from('<HHH',data,58)
    assert stride == 64
    zero = struct.unpack_from('<IIQQQQIIQQ',data,shoff)
    n = n or zero[5]
    name_index = zero[6] if name_index == 65535 else name_index
    assert shoff + 64 * n <= len(data)
    hs = [struct.unpack_from('<IIQQQQIIQQ',data,shoff+64*i) for i in range(n)]
    for h in hs:
        if h[2] & 0x400:
            assert family == 'fixed'
            assert h[8] <= 8
            counts['fixed_TLS_section_alignment_maximum'] = max(
                counts['fixed_TLS_section_alignment_maximum'], h[8])
    h = hs[name_index]
    strings = data[h[4]:h[4]+h[5]]
    section_names = [strings[h[0]:strings.index(0,h[0])].decode() for h in hs]
    symbols = {}
    for index,h in enumerate(hs):
        assert h[1] not in (9,18)  # No REL or extended-index companion.
        if h[1] not in (2,11):
            continue
        assert h[9] == 24 and h[5] % 24 == 0 and h[4]+h[5] <= len(data)
        syms = [struct.unpack_from('<IBBHQQ',data,off)
                for off in range(h[4],h[4]+h[5],24)]
        symbols[index] = syms
        for nm, info, other, idx, value, size in syms:
            counts[family + '_symbol_records'] += 1
            assert idx not in (0xfff2,0xff02,0xffff)
            if idx in (0, 0xfff1):
                assert value == 0
            elif idx:
                assert idx < n and value <= hs[idx][5], (label,idx,value,hs[idx][5])
    for index,h in enumerate(hs):
        if h[1] != 4:
            continue
        assert h[9] == 24 and h[5] % 24 == 0 and h[4]+h[5] <= len(data)
        syms = symbols[h[6]]
        target = hs[h[7]]
        assert 0 < h[7] < n
        for offset in range(h[4],h[4]+h[5],24):
            position,info,addend = struct.unpack_from('<QQq',data,offset)
            kind, symbol_index = info & 0xffffffff, info >> 32
            assert kind in names_by_type
            width = 8 if kind == 1 else 4
            assert position + width <= target[5]
            symbol = syms[symbol_index]
            _, sinfo, _, section_index, value, size = symbol
            key = (family,kind)
            row = rows.setdefault(key,dict(count=0, addend_min=addend, addend_max=addend,
                                           symbol_kinds=Counter(), symbol_value_max=0))
            row['count'] += 1
            row['addend_min'] = min(row['addend_min'],addend)
            row['addend_max'] = max(row['addend_max'],addend)
            row['symbol_value_max'] = max(row['symbol_value_max'],value)
            category = 'ABS_zero' if section_index == 0xfff1 else 'UNDEF' if section_index == 0 else 'section'
            row['symbol_kinds'][category] += 1
            if kind == 10:
                assert addend >= 0 and category == 'section'
            if kind == 21:
                assert category == 'section' and hs[section_index][2] & 0x400
            if 0 < section_index < n and hs[section_index][2] & 0x10 and sinfo & 15 == 3:
                counts[family + '_merge_section_symbol_relocations'] += 1
                if not 0 <= value + addend <= hs[section_index][5]:
                    bad_merge.append(dict(file=label, relocation_section=section_names[index],
                                          kind=names_by_type[kind],
                                          referenced_section=section_names[section_index],
                                          value=value,addend=addend,size=hs[section_index][5]))


for f in inventory['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    counts['fixed_files_verified'] += 1
    if f['kind'] == 'script':
        continue
    for m in f.get('members',[f]):
        if f['kind'] == 'archive':
            start = m['header_offset']+60
            data = raw[start:start+m['bytes']]
            assert len(data) == m['bytes'] and sha(data) == m['sha256']
            label = f['path'] + ':' + m['name']
            counts['archive_members_verified'] += 1
        else:
            data,label = raw,f['path']
        inspect(data,label,'fixed')
binder = (repo/'docs/evidence/retained-linker-join-20261018/binder-object.elf').read_bytes()
assert sha(binder) == '368b82296a24b933d1154f07b54bdad7af2f291302d4db23196f9d89128e2883'
inspect(binder,'accepted indexed binder','binder')
result = dict(counts=dict(counts), rows=[dict(family=k[0],type=k[1],name=names_by_type[k[1]],**v)
                                     for k,v in sorted(rows.items())],
              merge_source_offset_violations=bad_merge)
assert not bad_merge
assert sum(r['count'] for r in result['rows'] if r['family'] == 'fixed') == 462574
assert sum(r['count'] for r in result['rows'] if r['family'] == 'binder') == 95
K = max(max(abs(r['addend_min']), abs(r['addend_max'])) for r in result['rows'])
assert K == 2019040
assert counts['fixed_TLS_section_alignment_maximum'] == 8
V = layout['conditional_layout']['retained_endpoint']
Vtrial = layout['conditional_layout']['trial_endpoint']
assert Vtrial == 2 * V
main_bytes = main['selected_instructions']['encoded_function_bytes']
assert main_bytes == 26 and main['selected_instructions']['instruction_fixups'] == 0
# Numeric reconciliation of the source transfer in the companion record.
# It does not prove symbol resolution or input instruction compatibility.
bounds = dict(original_addend_absolute=K, Main_text_endpoint=main_bytes,
              ordinary_PC_relative=V+K,
              TLS_thread_offset=V+15,
              rewritten_PC_relative_with_instruction_bias=V+16,
              conservative_common_signed32=Vtrial+K+15,
              original_unsigned32=V+293932,
              PLT_index=layout['counts']['H']+layout['counts']['R'])
assert bounds['conservative_common_signed32'] < 2**31
assert bounds['original_unsigned32'] < 2**32
assert bounds['PLT_index'] < 2**31
result.update(scope='Selected relocation input census and conditional operand reach; symbol resolution and instruction compatibility are separate',
              source_files_verified=len(manifest['files']), input_records_verified=4,
              bounds=bounds, no_nonzero_ABS_or_COMMON_input_symbols=True,
              original_relocation_writes_within_target_sections=True,
              merged_section_symbol_offsets_within_original_sections=True,
              arithmetic_conditions_pass=True,
              complete_relocation_legality_established=False,
              whole_link_capacity_established=False, native_tool_executions=0)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(counts=result['counts'],bounds=bounds)))
