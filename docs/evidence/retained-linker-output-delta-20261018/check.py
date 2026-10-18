"""Check the fixed output-link delta using retained bytes; run no native tool."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--prior-repo', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
records = {}
for row in json.loads((root/'inputs.json').read_bytes()):
    raw = (args.prior_repo/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    records[row['key']] = json.loads(raw)
manifest = json.loads((root/'manifest.json').read_bytes())


def unpack(key):
    m = manifest[key]
    raw = (root/m['file']).read_bytes()
    assert len(raw) == m['bytes'] and sha(raw) == m['sha256']
    result = {}
    with tarfile.open(root/m['file']) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in m['members'])
        for row in m['members']:
            b = archive.extractfile(row['path']).read()
            assert len(b) == row['bytes'] and sha(b) == row['sha256'], row['path']
            result[row['path']] = b
    return result


art, src = unpack('artifacts'), unpack('sources')
historical = 0
for row in records['options_identity']['artifacts']:
    name = 'options/'+row['path']
    if name in art:
        assert len(art[name]) == row['bytes'] and sha(art[name]) == row['sha256']
        historical += 1
literal_result, = [r for r in records['options_results']
                  if r['case'] == 'literal' and r['variant'] == 'proposed']
assert literal_result['build_exit'] == literal_result['run_exit'] == 0
assert literal_result['stdout'] == 'a'
assert art['options/literal-proposed/run.stdout'] == b'a'
assert sha(art['options/literal-proposed/src/main.adb']) == literal_result['source_sha256']
indexed = json.loads(art['indexed/executable-identity.json'])
assert indexed['sha256'] == records['indexed_programs']['programs']['static-image-mutation']['executable_sha256']


def elf(raw):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    shoff = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, names = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64 and 0 < count < 65535
    assert shoff+count*64 <= len(raw)
    hdrs = [struct.unpack_from('<IIQQQQIIQQ', raw, shoff+64*i) for i in range(count)]

    def payload(h):
        if h[1] == 8:
            return b''
        assert h[4]+h[5] <= len(raw)
        return raw[h[4]:h[4]+h[5]]

    def cstr(buf, pos):
        return buf[pos:buf.index(0, pos)].decode()

    strings = payload(hdrs[names])
    sections = [dict(index=i, name=cstr(strings, h[0]), type=h[1], flags=h[2],
                     offset=h[4], bytes=h[5], link=h[6], info=h[7],
                     alignment=h[8], entsize=h[9]) for i, h in enumerate(hdrs)]
    symbols, tables, relocations = [], {}, []
    for i, h in enumerate(hdrs):
        if h[1] not in (2, 11):
            continue
        assert h[9] == 24 and h[5] % 24 == 0
        strings, table = payload(hdrs[h[6]]), []
        for off in range(h[4], h[4]+h[5], 24):
            name, info, other, section, value, size = struct.unpack_from('<IBBHQQ', raw, off)
            row = dict(index=len(table), name=cstr(strings, name), binding=info >> 4,
                       type=info & 15, visibility=other, section=section, value=value, bytes=size)
            table.append(row)
            symbols.append(row)
        tables[i] = table
    for h in hdrs:
        if h[1] not in (4, 9):
            continue
        assert h[1] == 4 and h[9] == 24 and h[5] % 24 == 0
        for off in range(h[4], h[4]+h[5], 24):
            pos, info, addend = struct.unpack_from('<QQq', raw, off)
            sym = tables[h[6]][info >> 32]
            relocations.append(dict(section=sections[h[7]]['name'], offset=pos,
                                    type=info & 0xffffffff, symbol=sym['name'],
                                    addend=addend, symbol_section=sym['section']))
    return dict(bytes=len(raw), sha256=sha(raw), sections=sections,
                symbols=symbols, relocations=relocations)


def metrics(d):
    syms, secs = d['symbols'], d['sections']
    names = [s['name'] for s in syms+secs if s['name']]
    return dict(R=len(syms), Q=len(secs), Qrel=sum(s['type'] in (4, 9) for s in secs),
                Trel=len(d['relocations']), original_payload=sum(s['bytes'] for s in secs),
                name_occurrences=len(names), name_NUL_bytes=sum(len(n.encode())+1 for n in names),
                maximum_name_bytes=max(len(n.encode()) for n in names),
                global_records=sum(s['binding'] != 0 for s in syms),
                symbol_size_sum=sum(s['bytes'] for s in syms),
                maximum_symbol_size=max(s['bytes'] for s in syms),
                maximum_alignment=max(s['alignment'] for s in secs))


def section_bytes(raw, section):
    return b'' if section['type'] == 8 else raw[section['offset']:section['offset']+section['bytes']]


fixed_objects = {}
for name in ['silver_io.o', 'silver_output_libc.o']:
    retained = [art['objects/'+case+'/'+name] for case in
                ['literal-baseline', 'literal-proposed', 'long_name-baseline', 'long_name-proposed']]
    retained += [art['indexed/obj/'+name]]
    assert len({sha(b) for b in retained}) == 1
    fixed_objects[name] = elf(retained[0])
for name in ['silver_io.ads', 'silver_io.adb', 'silver_output_libc.ads']:
    assert src['silver/src/'+name] == art['indexed/'+name]
    assert src['silver/src/'+name] == art['options/literal-proposed/src/'+name]
    assert src['silver/src/'+name] == art['options/long_name-proposed/src/'+name]
io = fixed_objects['silver_io.o']
assert {s['name'] for s in io['symbols'] if s['binding'] and not s['section']} == {
    '__gnat_set_exit_status', 'putchar', 'fflush'}
assert {s['name'] for s in io['symbols'] if s['binding'] and s['section']} == {
    'silver_io__put', 'silver_io__put_line', 'silver_io_E', 'silver_io__max_length'}
libc = fixed_objects['silver_output_libc.o']
assert [s['name'] for s in libc['symbols'] if s['binding']] == ['silver_output_libc_E']
for obj in fixed_objects.values():
    assert not any(s['section'] in (0xfff2, 0xff02) or s['type'] in (6, 10) for s in obj['symbols'])
    assert not any('@' in s['name'] for s in obj['symbols'])
    assert not any(s['flags'] & 2 and s['flags'] & (0x10 | 0x400) for s in obj['sections'])
    assert not any(s['name'].startswith('.gnu.lto_') for s in obj['sections'])
assert all(r['type'] == (4 if r['section'] == '.text' else 2) for r in io['relocations'])

# Reconstruct only the output ALI closure, not a new broad runtime census.
todo, closure, units = ['main.ali', 's-stalib.ali'], {}, {}
while todo:
    name = todo.pop()
    if name in closure:
        continue
    raw = art['closure/'+name]
    closure[name] = raw
    todo += [n.decode() for n in re.findall(rb'^[WYZ] \S+[ \t]+\S+[ \t]+(\S+)', raw, re.M)]
    for unit, version in re.findall(rb'^U (\S+)[ \t]+\S+[ \t]+([0-9a-f]+)', raw, re.M):
        unit, version = unit.decode(), version.decode()
        assert unit not in units or units[unit] == version
        units[unit] = version
assert len(closure) == 83 and len(units) == 140
assert not any(b'[main standard ' in b for n, b in closure.items() if n != 'main.ali')
assert closure['main.ali'] == art['options/literal-proposed/obj/main.ali']
spec = art['options/literal-proposed/obj/b__main.ads']
versions = re.findall(rb'(u[0-9]+) : constant Version_32 := 16#([0-9a-f]{8})#;\s*'
                      rb'pragma Export \(C, \1, "([^"]+)"\);', spec)
actual = {name.decode(): version.decode() for _, version, name in versions}
expected = {unit[:-2].replace('.', '__')+unit[-1].upper(): version for unit, version in units.items()}
assert len(versions) == 140 and actual == expected
indexed_spec = art['indexed/obj/b__main~1.ads']
normalize_spec = lambda b: re.sub(rb'(u00001 : constant Version_32 := 16#)[0-9a-f]{8}', rb'\g<1>CHECKSUM', b)
assert normalize_spec(spec) == normalize_spec(indexed_spec)
body = art['options/literal-proposed/obj/b__main.adb']
indexed_body = art['indexed/obj/b__main~1.adb']
def normalize_body(b):
    b = b.replace(b'b__main~1.', b'b__main.')
    return re.sub(rb'--  BEGIN Object file/option list.*?--  END Object file/option list', b'OPTIONS', b, flags=re.S)
assert normalize_body(body) == normalize_body(indexed_body)

# Source filename and checksum are the exact two object differences.
literal_raw = art['objects/literal-proposed/b__main.o']
indexed_raw = art['indexed/obj/b__main~1.o']
literal_binder, indexed_binder = elf(literal_raw), elf(indexed_raw)
symbol_differences = [(a, b) for a, b in zip(literal_binder['symbols'], indexed_binder['symbols']) if a != b]
assert len(literal_binder['symbols']) == len(indexed_binder['symbols']) == 243
assert len(symbol_differences) == 1
a, b = symbol_differences[0]
assert a['type'] == b['type'] == 4 and a['binding'] == b['binding'] == 0
assert a['name'] == 'b__main.adb' and b['name'] == 'b__main~1.adb'
assert {k: v for k, v in a.items() if k != 'name'} == {k: v for k, v in b.items() if k != 'name'}
assert literal_binder['relocations'] == indexed_binder['relocations']
mainB, = [s for s in indexed_binder['symbols'] if s['name'] == 'mainB']
assert mainB['type'] == 1 and mainB['bytes'] == 4
different_sections = []
for a, b in zip(literal_binder['sections'], indexed_binder['sections']):
    assert a['name'] == b['name'] and a['type'] == b['type'] and a['flags'] == b['flags']
    x, y = section_bytes(literal_raw, a), section_bytes(indexed_raw, b)
    if x != y:
        different_sections.append(a['name'])
        if a['name'] == '.rodata':
            assert b['index'] == mainB['section'] and len(x) == len(y)
            assert [i for i, (xx, yy) in enumerate(zip(x, y)) if xx != yy] == list(range(mainB['value'], mainB['value']+4))
            for buf, sp in [(x, spec), (y, indexed_spec)]:
                value = int(re.search(rb'u00001 : constant Version_32 := 16#([0-9a-f]{8})', sp)[1], 16)
                assert int.from_bytes(buf[mainB['value']:mainB['value']+4], 'little') == value
        else:
            assert a['name'] in ('.symtab', '.strtab')
assert different_sections == ['.rodata', '.symtab', '.strtab']
fixed_objects['indexed_output_binder.o'] = indexed_binder

eh = {}
for name, raw in [('silver_io.o', art['indexed/obj/silver_io.o']), ('indexed_output_binder.o', indexed_raw)]:
    sec, = [s for s in fixed_objects[name]['sections'] if s['name'] == '.eh_frame']
    buf, at, cies, entries, fdes = section_bytes(raw, sec), 0, set(), [], 0
    while at < len(buf):
        length, cie = struct.unpack_from('<II', buf, at)
        assert 4 <= length < 0xffffffff and at+4+length <= len(buf)
        if cie == 0:
            cies.add(at)
        else:
            assert at+4-cie in cies
            fdes += 1
        entries.append(dict(offset=at, length=length, CIE_pointer=cie))
        at += 4+length
    assert at == len(buf) and len(cies) == 1
    eh[name] = dict(bytes=len(buf), CIEs=len(cies), FDEs=fdes, entries=entries)
assert eh['silver_io.o']['FDEs'] == 2 and eh['indexed_output_binder.o']['FDEs'] == 6

# Targeted definition query against the retained installed-input inventory.
want = {'silver_io__put', 'silver_io__put_line', 'silver_io_E', 'silver_io__max_length',
        'silver_output_libc_E', '__gnat_set_exit_status', 'putchar', 'fflush'}
definitions = {n: [] for n in sorted(want)}
for f in records['inventory']['files']:
    if f['role'] == 'generated-input' or f['kind'] == 'script':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    for member in f.get('members', [f]):
        path, data = f['path'], raw
        if f['kind'] == 'archive':
            start = member['header_offset']+60
            data, path = raw[start:start+member['bytes']], path+'('+member['name']+')'
            assert sha(data) == member['sha256']
        for sym in elf(data)['symbols']:
            name = sym['name'].split('@')[0]
            if name in want and sym['binding'] and sym['section']:
                definitions[name].append(dict(path=path, **sym))
assert all(not definitions[n] for n in want if n.startswith('silver_'))
assert all(len(definitions[n]) == 1 for n in ['__gnat_set_exit_status', 'putchar', 'fflush'])
assert all(definitions[n][0]['type'] == 2 and definitions[n][0]['visibility'] == 0
           for n in ['__gnat_set_exit_status', 'putchar', 'fflush'])
measured = {n: metrics(d) for n, d in fixed_objects.items()}
fixed = records['fixed']['processed_fixed_totals']
base = dict(R=fixed['symbol_records'], Q=fixed['section_headers'], P=fixed['elf_occurrences'],
            Qrel=records['indices']['processed_fixed_relocation_headers'],
            Trel=records['dynamic']['fixed_relocation_record_processing_bound'],
            original_payload=fixed['all_section_bytes'])
assert base == dict(R=49081, Q=36433, P=1481, Qrel=7905, Trel=546364, original_payload=46206441)
offsets = {k: base[k]+sum(m[k] for m in measured.values()) for k in base if k != 'P'}
offsets['P'] = base['P']+4  # Main, binder and the two Silver objects.
assert offsets == dict(R=49337, Q=36473, Qrel=7910, Trel=546512, original_payload=46235378, P=1485)
result = dict(
    scope='Fixed library and binder interface delta for direct literal output/null sequences',
    prior_input_identities=len(records), historical_option_artifacts_verified=historical,
    artifact_members=len(art), source_members=len(src),
    fixed_object_metrics=measured,
    fixed_object_identities={n: dict(bytes=d['bytes'], sha256=d['sha256']) for n, d in fixed_objects.items()},
    library_source_identities={n: sha(b) for n, b in src.items() if n.startswith('silver/')},
    runtime_definitions=definitions,
    ALI_closure=dict(files=len(closure), units=len(units), runtime_files=len(closure)-3,
                     version_exports=len(versions), fixed_incoming_Main_signatures=0),
    indexed_binder_bridge=dict(differing_sections=different_sections, mainB=mainB,
                              executable_identity=indexed),
    EH=eh,
    symbolic_link_offsets=offsets,
    fixed_generated_names=dict(occurrences=sum(m['name_occurrences'] for m in measured.values()),
                              NUL_bytes=sum(m['name_NUL_bytes'] for m in measured.values()), maximum_bytes=46),
    fixed_generated_symbol_size_sum=sum(m['symbol_size_sum'] for m in measured.values()),
    fixed_input_delta_checked=True,
    historical_output_link_witness_used_explicit_no_plugin=False,
    output_Main_object_envelope_established_here=False,
    output_binder_compiler_lifetime_capacity_established_here=False,
    whole_output_link_capacity_established=False,
    whole_pipeline_capacity_established=False,
    current_library_semantic_limit_changed=False,
    native_executions=0)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(fixed_input_delta_checked=True, ALI_files=len(closure), units=len(units),
                      symbolic_link_offsets=offsets, native_executions=0), indent=2))
