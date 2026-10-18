"""Inspect selected fixed/binder FDE ranges and CFA field extents; no tool runs."""
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

with tarfile.open(root/'unwind-sources.tar.gz','r:gz') as archive:
    unwind_sources=json.loads((root/'unwind-sources.json').read_bytes())
    assert sorted(archive.getnames())==sorted(row['path'] for row in unwind_sources)
    for row in unwind_sources:
        raw=archive.extractfile(row['path']).read()
        assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']

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
            if idx == 0xfff1:
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
            row = rows.setdefault(key,dict(count=0, addend_min=0, addend_max=0,
                                           symbol_kinds=Counter(), symbol_value_max=0))
            row['count'] += 1
            row['addend_min'] = min(row['addend_min'],addend)
            row['addend_max'] = max(row['addend_max'],addend)
            row['symbol_value_max'] = max(row['symbol_value_max'],value)
            category = 'ABS_zero' if section_index == 0xfff1 else 'UNDEF' if section_index == 0 else 'section'
            row['symbol_kinds'][category] += 1
            if kind == 10:
                assert addend >= 0 and category == 'section'
            if 0 < section_index < n and hs[section_index][2] & 0x10 and sinfo & 15 == 3:
                counts[family + '_merge_section_symbol_relocations'] += 1
                if not 0 <= value + addend <= hs[section_index][5]:
                    bad_merge.append(dict(file=label, relocation_section=section_names[index],
                                          kind=names_by_type[kind],
                                          referenced_section=section_names[section_index],
                                          value=value,addend=addend,size=hs[section_index][5]))

    inspect_eh(data,label,hs,symbols,section_names,family)

eh_summary=Counter()
eh_rows=[]

def leb(raw,pos,end,signed=False):
    value=0;shift=0
    while True:
        assert pos<end
        b=raw[pos];pos+=1;value|=(b&127)<<shift;shift+=7
        assert shift<=70
        if not b&128:break
    if signed and b&64:value-=1<<shift
    return value,pos

def width(enc):
    return {0:8,2:2,3:4,4:8,10:2,11:4,12:8}[enc&15]

def scan_cfa(raw,p,end,encoded_width):
    while p<end:
        op=raw[p];p+=1;op=(op&0xc0) if op&0xc0 else op
        eh_summary['CFA_operations']+=1
        if op in (0,0x40,0xc0,0xa,0xb,0x2c,0x2d):pass
        elif op in (0x80,6,7,8,0xd,0xe,0x13,0x2e):_,p=leb(raw,p,end)
        elif op in (0x14,0x15,5,9,0xc,0x11,0x12,0x2f):
            _,p=leb(raw,p,end);_,p=leb(raw,p,end)
        elif op in (0xf,0x10,0x16):
            if op!=0xf:_,p=leb(raw,p,end)
            n,p=leb(raw,p,end);p+=n
        elif op==1:
            eh_summary['CFA_set_loc']+=1;p+=encoded_width
        elif op in (2,3,4,0x1d):p+={2:1,3:2,4:4,0x1d:8}[op]
        else:raise AssertionError(('CFA opcode',op))
        assert p<=end
    assert p==end

def inspect_eh(data,label,hs,symbols,names,family):
    rels={}
    for h in hs:
        if h[1]!=4:continue
        by=rels.setdefault(h[7],{})
        for at in range(h[4],h[4]+h[5],24):
            offset,info,addend=struct.unpack_from('<QQq',data,at)
            assert offset not in by
            by[offset]=(info&0xffffffff,symbols[h[6]][info>>32],addend)
    ranges={}
    for index,h in enumerate(hs):
        if names[index]!='.eh_frame' or not h[5]:continue
        raw=data[h[4]:h[4]+h[5]];at=0;cies={};by=rels.get(index,{})
        eh_summary[family+'_EH_sections']+=1
        while at<len(raw):
            n=struct.unpack_from('<I',raw,at)[0]
            if not n:
                assert not any(raw[at:]);break
            assert n<0xffffffff and n>=4
            end=at+4+n;assert end<=len(raw)
            ident=struct.unpack_from('<I',raw,at+4)[0];p=at+8
            if ident==0:
                version=raw[p];p+=1;assert version in (1,3,4)
                z=raw.index(0,p,end);aug=raw[p:z].decode();p=z+1
                if version==4:assert raw[p:p+2]==b'\x08\0';p+=2
                _,p=leb(raw,p,end);_,p=leb(raw,p,end,True)
                if version==1:p+=1
                else:_,p=leb(raw,p,end)
                assert aug.startswith('z')
                alen,p=leb(raw,p,end);aend=p+alen;fde=0
                for ch in aug[1:]:
                    if ch in 'LR':
                        enc=raw[p];p+=1
                        eh_summary['CIE_'+ch+'_encoding_'+hex(enc)]+=1
                        if ch=='R':fde=enc
                    elif ch=='P':
                        enc=raw[p];p+=1
                        eh_summary['CIE_P_encoding_'+hex(enc)]+=1
                        if enc&0x70==0x50:p+=(-p)&(width(enc)-1)
                        p+=width(enc)
                    else:assert ch=='S'
                assert p==aend and p<=end
                cies[at]=fde
                scan_cfa(raw,p,end,width(fde))
            else:
                encoding=cies[at+4-ident]
                assert encoding==0x1b,(label,encoding)
                kind,sym,addend=by[p];assert kind==2
                assert raw[p:p+4]==b'\0'*4
                for relpos,(relkind,_,_) in by.items():
                    if relpos==p:
                        continue  # The unique exact PC32 initial-location field.
                    relwidth=8 if relkind==1 else 4
                    assert relpos+relwidth<=p or relpos>=p+8
                size=struct.unpack_from('<i',raw,p+4)[0]
                _,info,_,target,value,symsize=sym
                assert info>>4==0  # Local FDE target, unaffected by global binding.
                assert 0<target<len(hs) and hs[target][2]&4 and not hs[target][2]&0x410
                begin=value+addend
                assert 0<=begin<=begin+size<=hs[target][5],(label,begin,size,hs[target][5])
                ranges.setdefault(target,[]).append((begin,begin+size))
                eh_summary[family+'_FDEs']+=1
                eh_summary['maximum_range']=max(eh_summary['maximum_range'],size)
                eh_summary['zero_ranges']+=int(size==0)
                p+=8;alen,p=leb(raw,p,end);p+=alen
                assert p<=end
                scan_cfa(raw,p,end,width(encoding))
            at=end
    for target,items in ranges.items():
        previous_end=0
        for begin,end in sorted(items):
            assert previous_end<=begin,(label,names[target],previous_end,begin,end)
            previous_end=end
        eh_summary['code_sections_with_FDEs']+=1
        eh_rows.append(dict(file=label,section=names[target],ranges=sorted(items)))

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
assert not bad_merge
assert eh_summary['fixed_EH_sections']==888 and eh_summary['fixed_FDEs']==14267
assert eh_summary['binder_FDEs']==5 and eh_summary['binder_EH_sections']==1
assert eh_summary['CFA_set_loc']==0 and eh_summary['zero_ranges']==0
eh_summary['CFA_set_loc']=0
assert main['selected_cfi']['FDE_objects']==1
V=layout['conditional_layout']['retained_endpoint']
EH=aggregate['payload_components']['full_EH_edited_output_including_PLT_templates']
assert V<2**31 and EH<2**32
result=dict(scope='Selected original FDE code ranges, CFA decoding and conditional edited-field reach; not full unwind semantic proof',
            source_files_verified=len(manifest['files'])+len(unwind_sources),
            input_counts=dict(counts), EH_counts=dict(eh_summary),
            original_FDE_ranges_in_nonmerge_nonTLS_code=True,
            original_FDE_ranges_nonoverlapping_within_each_input_section=True,
            original_FDE_initial_location_encoding='DW_EH_PE_pcrel | DW_EH_PE_sdata4',
            range_inventory_sha256=sha(json.dumps(eh_rows,sort_keys=True,separators=(',',':')).encode()),
            function_and_FDE_address_upper=V,
            original_and_edited_EH_payload_union=EH,
            original_FDE_range_maximum=eh_summary['maximum_range'],
            Main_range_upper=main['selected_instructions']['encoded_function_bytes'],
            final_signed32_fields_fit_under_operand_projection=True,
            native_tool_executions=0, whole_link_capacity_established=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(EH_counts=result['EH_counts'],field_address_bound=V)))
