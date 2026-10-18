"""Read retained fixed ELF/archive identities and inspect EH field extents."""
from pathlib import Path
import hashlib
import json
import struct
import argparse
import tarfile
from collections import Counter

ROOT = Path(__file__).resolve().parents[3]
inventory = json.loads((ROOT/'docs/evidence/retained-link-inputs-20261018/inventory.json').read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()

def archive(raw):
    pos = 8
    names = b''
    while pos < len(raw):
        h = raw[pos:pos+60]
        assert h[58:60] == b'`\n'
        n = h[:16].decode().rstrip()
        size = int(h[48:58])
        data = raw[pos+60:pos+60+size]
        assert len(data) == size
        if n == '//':
            names = data
        elif n not in ('/', '/SYM64/'):
            if n.startswith('/'):
                start = int(n[1:]); n = names[start:names.index(b'/\n', start)].decode()
            else:
                assert n.endswith('/'); n = n[:-1]
            yield n, data
        pos += 60 + size + size%2
    assert pos == len(raw)

def sections(raw):
    assert raw[:6] == b'\x7fELF\x02\x01'
    kind = struct.unpack_from('<H', raw, 16)[0]
    start = struct.unpack_from('<Q', raw, 40)[0]
    step, count, names_index = struct.unpack_from('<HHH', raw, 58)
    assert step == 64
    hdr = lambda i: struct.unpack_from('<IIQQQQIIQQ', raw, start+64*i)
    zero = hdr(0)
    count = count or zero[5]
    if names_index == 0xffff: names_index = zero[6]
    ns = hdr(names_index); names = raw[ns[4]:ns[4]+ns[5]]
    for i in range(count):
        h = hdr(i); n = names[h[0]:names.index(0, h[0])]
        if n == b'.eh_frame' and h[5]:
            data = raw[h[4]:h[4]+h[5]]
            assert len(data) == h[5]
            yield kind, i, h[8], data

def leb(raw, pos, end, signed=False):
    value = 0; shift = 0
    while True:
        assert pos < end
        b = raw[pos]; pos += 1
        value |= (b&127) << shift; shift += 7
        if not b&128: break
    if signed and b&64: value -= 1<<shift
    assert -(1<<63) <= value < (1<<64)
    return value, pos

def width(enc):
    assert enc&0x60 != 0x60
    return {0:8, 2:2, 3:4, 4:8}[enc&7]

def inspect(raw):
    p = 0; cies = {}; result = Counter()
    while p < len(raw):
        assert p+4 <= len(raw)
        n = struct.unpack_from('<I', raw, p)[0]
        result['entries'] += 1
        if n == 0:
            assert len(raw[p:])%4 == 0 and not any(raw[p:])
            result['terminators'] += 1; break
        assert n != 0xffffffff and n>=4 and p+4+n <= len(raw)
        end = p+4+n; ident = struct.unpack_from('<I', raw, p+4)[0]
        at = p+8
        if ident == 0:
            result['CIEs'] += 1
            begin = at
            version = raw[at]; at += 1
            assert version in (1,3,4)
            z = raw.index(0,at,end); aug = raw[at:z].decode(); at = z+1
            assert aug != 'eh'
            auglen = at-begin-1
            if version >= 4:
                assert raw[at:at+2] == bytes([8,0]); at += 2
            code, at = leb(raw, at, end)
            data, at = leb(raw, at, end, True)
            if version == 1: ra = raw[at]; at += 1
            else: ra, at = leb(raw, at, end)
            chars = aug
            if chars.startswith('z'):
                alen, at = leb(raw,at,end); chars = chars[1:]
            fde = 0; lsda = 255; peroff = 0
            for char in chars:
                if char in 'LR':
                    encoding = raw[at]; at += 1; width(encoding)
                    if char == 'L': lsda = encoding
                    else: fde = encoding
                elif char == 'P':
                    encoding = raw[at]; at += 1; w = width(encoding)
                    if encoding&0x70 == 0x50: at += (-at)&(w-1)
                    peroff = at-begin; at += w
                else: assert char == 'S', char
            augdata = at-begin-1-auglen
            assert at <= end
            initial = end-at
            for key,val in [('augmentation_string_bytes',auglen),('augmentation_data_bytes',augdata),('personality_offset',peroff),('CIE_initial_instruction_bytes',initial)]:
                result['max_'+key] = max(result['max_'+key],val)
            assert auglen <= 7 and augdata <= 31 and peroff <= 255 and initial <= 255
            cies[p] = (aug,fde,lsda)
        else:
            result['FDEs'] += 1
            aug,fde,lsda = cies[p+4-ident]
            begin = at; at += 2*width(fde)
            assert at <= end
            if aug.startswith('z'): alen,at = leb(raw,at,end)
            else: alen = 0
            if lsda != 255:
                off = at-begin
                result['max_LSDA_offset'] = max(result['max_LSDA_offset'],off)
                assert off<=255
                if not aug.startswith('z'): alen = end-at
            at += alen; assert at <= end
        p = end
    assert result['entries'] <= len(raw)//4
    return dict(result)

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--installed', action='store_true')
args = parser.parse_args()
base = Path(__file__).resolve().parent
retained = json.loads((base/'fixed-eh-inputs.json').read_text())
assert sha((ROOT/'docs/evidence/retained-link-inputs-20261018/inventory.json').read_bytes()) == retained['inventory_sha256']
assert sha((base/'fixed-eh-sections.tar.gz').read_bytes()) == retained['archive_sha256']
rows = retained['rows']
totals = Counter(); maxima = Counter()
with tarfile.open(base/'fixed-eh-sections.tar.gz') as archive_file:
    assert set(archive_file.getnames()) == {r['retained_payload'] for r in rows}
    for row in rows:
        raw = archive_file.extractfile(row['retained_payload']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        metrics = inspect(raw)
        assert metrics == row['metrics']
        w = row['occurrences']
        totals['sections'] += w; totals['bytes'] += w*len(raw)
        maxima['bytes'] = max(maxima['bytes'], len(raw))
        maxima['alignment'] = max(maxima['alignment'], row['alignment'])
        for k,v in metrics.items():
            if k.startswith('max_'): maxima[k] = max(maxima[k],v)
            else: totals[k] += w*v
assert dict(totals) == retained['totals'] and dict(maxima) == retained['maxima']
if args.installed:
    actual = []
    for f in inventory['files']:
        if f['role'] == 'generated-input' or f['kind'] not in ('elf','archive'):
            continue
        raw = Path(f['path']).read_bytes()
        assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
        members = list(archive(raw)) if f['kind'] == 'archive' else [('',raw)]
        for name,data in members:
            for kind,index,alignment,eh in sections(data):
                if kind != 1: continue
                actual.append({'path':f['path'],'file_sha256':f['sha256'],
                    'member':name,'member_sha256':sha(data),'section_index':index,
                    'occurrences':f['link_argv_occurrences'],'alignment':alignment,
                    'bytes':len(eh),'sha256':sha(eh),'metrics':inspect(eh)})
    assert actual == [{k:v for k,v in r.items() if k != 'retained_payload'} for r in rows]
# A=8 is only the fixed input alignment. The eventual output alignment must
# also include generated and linker-created EH contributions.
fixed_edited = totals['bytes'] + 11*totals['entries'] + 10*totals['sections']
result = {'scope':retained['scope'], 'retained_sections':len(rows),
    'totals_with_explicit_archive_occurrences':dict(totals),'maxima':dict(maxima),
    'fixed_payload_after_editing_if_output_alignment_8':fixed_edited,
    'installed_inputs_reextracted':args.installed,
    'CFA_semantics_relocations_or_whole_link_established':False,
    'native_tool_executions':0}
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
