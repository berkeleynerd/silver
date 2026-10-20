#!/usr/bin/env python3
"""Check only the new retained byte-escape witnesses; never execute the target."""
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

START = datetime.now(timezone.utc)
T0 = time.monotonic()
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
F = E / 'retained-why-save-binder-formatter-stack-20261020'
SCALAR = E / 'retained-why-save-scalar-format-20261020'
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
inputs = {}


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path, digest=None):
    path = Path(path)
    raw = path.read_bytes()
    if digest:
        assert ident(raw)['sha256'] == digest, str(path)
    key = str(path.relative_to(REPO)) if path.is_relative_to(REPO) else str(path)
    inputs[key] = ident(raw)
    return raw


def js(path):
    return json.loads(read(path))


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


# Frozen inputs are consumed; no predecessor checker is run.
read(F / 'result.json', 'cca726643bb9a8a45aa8f02058e7e362bb365f31193347d0b0e83a93606d3ff8')
old_bodies = js(F / 'native-bodies.json')
old_frames = js(F / 'native-frames.json')
old_spec = js(F / 'formatter-spec.json')
js(F / 'formatter-call-closures.json')
js(F / 'multiplicities.json')
js(SCALAR / 'result.json')
js(E / 'retained-why-save-format-allocation-20261020/result.json')
js(E / 'retained-why-save-formatter-core-20261020/result.json')
read(REPO / 'docs/research/retained-tool-source-identity.md')
contract = read(SCALAR / 'libc-contract/Integer-Conversions.html')
assert b'hexadecimal' in contract and b'unsigned' in contract
read(SCALAR / 'libc-contract/Formatted-Output-Functions.html')
read(HERE / 'check.py')
read(HERE / 'README.md')
read(REPO / 'docs/research/retained-why-json-byte-escape.md')

archives = [
    ('retained-why-session-helper-source-20261019/sources.tar.gz',
     '2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749',
     'why3/', {'src/util/json_base.ml': [(11,32)]}),
    ('retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz',
     '04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7',
     'ocaml-8eb41f72ded84df884c3671734c947f612091f84/', {
         'stdlib/camlinternalFormatBasics.ml': [(15,90),(357,412)],
         'stdlib/camlinternalFormat.ml': [(1318,1352),(1380,1393),(1430,1452),
                                        (1518,1540),(1557,1605),(1686,1730)],
         'stdlib/format.ml': [(636,658),(1285,1312),(1354,1366)],
         'stdlib/bytes.ml': [(24,45),(96,108)],
         'stdlib/string.ml': [(40,56),(82,86)],
         'stdlib/char.ml': [(16,32)],
         'runtime/ints.c': [(142,185)],
         'runtime/alloc.c': [(79,107)],
         'runtime/str.c': [(60,84),(360,434)],
     }),
]
source = {}
witnesses = []
for file, digest, prefix, paths in archives:
    archive = E / file
    read(archive, digest)
    with tarfile.open(archive) as tar:
        for path, ranges in paths.items():
            raw = tar.extractfile(prefix + path).read()
            source[path] = raw.decode()
            lines = raw.decode().splitlines(keepends=True)
            for lo, hi in ranges:
                excerpt = ''.join(lines[lo-1:hi])
                witnesses.append(dict(archive=str(archive.relative_to(REPO)),
                    member=prefix+path, member_identity=ident(raw), first_line=lo,
                    last_line=min(hi,len(lines)), text=excerpt,
                    excerpt_identity=ident(excerpt.encode())))
assert 'String.iter (char fmt) s' in source['src/util/json_base.ml']
assert 'Lit_padding (padty, w), No_precision' in source['stdlib/camlinternalFormat.ml']
assert "String.blit str 0 res (width - len) len" in source['stdlib/camlinternalFormat.ml']
assert 'let blit =\n  B.blit_string' in source['stdlib/string.ml']
write('source-witnesses.json', witnesses)

raw = read(DISASM, 'f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
bodies = {m[1]: m[0] for m in re.finditer(
    r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', raw.decode(), re.M | re.S)}
elf = read(ELF, '7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
header = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
segments = [struct.unpack_from('<IIQQQQQQ', elf, header[5]+i*header[9])
            for i in range(header[10])]


def at(address, length):
    s = next(s for s in segments if s[0] == 1 and s[3] <= address
             and address+length <= s[3]+s[5])
    return elf[s[2]+address-s[3]:s[2]+address-s[3]+length]


def words(address, count):
    return list(struct.unpack('<'+'Q'*count, at(address, count*8)))


static = []


def obj(address, tag, fields):
    hd = words(address-8,1)[0]
    assert hd & 255 == tag and hd >> 10 == len(fields)
    assert words(address,len(fields)) == fields
    static.append(dict(address=hex(address), header=hex(hd), tag=tag,
                       fields=[hex(x) for x in fields],
                       bytes=at(address-8,8*(len(fields)+1)).hex()))


def string(address, expected):
    hd = words(address-8,1)[0]
    assert hd & 255 == 252
    payload = at(address,(hd >> 10)*8)
    length = len(payload)-1-payload[-1]
    assert payload[:length] == expected
    static.append(dict(address=hex(address), header=hex(hd),
                       value_hex=expected.hex(), bytes=at(address-8,8+len(payload)).hex()))


obj(0xb25170,0,[0xb25198,0xb25188])
obj(0xb25198,11,[0xb24c08,0xb251b0])
obj(0xb251b0,4,[13,0xb24b88,1,1])
obj(0xb24b88,0,[5,9])
string(0xb25188,b'\\u%04x')
string(0xb24c08,b'\\u')
string(0xf6da50,b'%x')
assert at(0x9f0f3f,2) == b'l\0'

NEW = {
    'camlWhy3__Json_base__char_430':32,
    'camlWhy3__Json_base__string_632':32,
    'camlWhy3__Json_base__fun_941':8,
    'camlStdlib__String__iter_425':48,
    'camlCamlinternalFormat__fun_6592':16,
    'camlCamlinternalFormat__fix_padding_3405':48,
}
SHARED = [
    'camlStdlib__Bytes__make_279','camlStdlib__Bytes__blit_string_370',
    'camlStdlib__Format__pp_print_char_913','camlStdlib__Format__pp_print_string_793',
    'camlStdlib__Format__fprintf_1781','camlStdlib__Format__fun_2984',
    'camlStdlib__Format__kfprintf_1763','camlStdlib__Format__fun_2958',
    'camlStdlib__Format__output_acc_1688',
    'camlCamlinternalFormat__make_printf_3510',
    'camlCamlinternalFormat__make_int_padding_precision_3515',
    'camlCamlinternalFormat__convert_int_3465',
    'camlCamlinternalFormat__format_of_iconv_3430',
    'camlCamlinternalFormat__transform_int_alt_3449','caml_apply2',
]
C = {'caml_format_int':80, 'parse_format':48, 'caml_alloc_sprintf':400,
     'caml_alloc_initialized_string':32, 'caml_alloc_string':32,
     'caml_create_bytes':16, 'caml_fill_bytes':16, 'caml_blit_string':16}
frames = {}
checked = 0
for name in list(NEW)+SHARED+list(C):
    body = bodies[name]
    if name in NEW:
        assert name not in old_bodies
    if name in SHARED:
        assert body == old_bodies[name]
    for line in body.splitlines()[1:]:
        m = re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)',line)
        if not m:
            assert not line.strip(), line
            continue
        bs = bytes.fromhex(m[2])
        assert at(int(m[1],16),len(bs)) == bs
        checked += len(bs)
    subs = re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp',body)
    pushes = re.findall(r'\bpush\s+[^\n]+',body)
    assert len(subs) <= 1
    own = 8+8*len(pushes)+sum(int(x,16) for x in subs)
    if name in SHARED:
        assert own == old_frames[name]['own_high_water_upper']
    else:
        assert own == (NEW | C)[name], (name,own)
    frames[name] = dict(own_high_water_upper=own, body_identity=ident(body.encode()),
                       group='new' if name in NEW else 'shared_F' if name in SHARED else 'R_wrapper')
write('native-bodies.json',{n:bodies[n] for n in frames})
write('native-frames.json',frames)

# Every byte is tied to the retained native comparison/relative-switch route.
# The preceding printable-range test removes 35..126 before this switch.
# Only the 27 slots for 8..34 belong to this selected byte switch.
table = [0x9e7210+x for x in struct.unpack('<27i',at(0x9e7210,27*4))]
specials = {8:b'\\b',9:b'\\t',10:b'\\n',12:b'\\f',13:b'\\r',34:b'\\"',92:b'\\\\'}
literal_sites = {0x556f48:0xb251d8,0x556f5c:0xb250d0,0x556f70:0xb24fd0,
                 0x556f84:0xb24ee8,0x556f98:0xb24e10,0x556fac:0xb24d60,
                 0x556fc6:0xb24cb0}
cases=[]
for c in range(256):
    a=(2*c+1-70) % (1 << 64)
    if a <= 183:
        target=0x556fc6 if a == 115 else 0x55700c
    else:
        a=(a+54) % (1 << 64)
        target=0x556fdc if a > 237 else table[a >> 1]
    if c in specials:
        assert target in literal_sites
        string(literal_sites[target],specials[c])
        kind='special';out=specials[c];events=1;allocation=0
    elif 32 <= c <= 126:
        assert target == 0x55700c
        kind='printable';out=bytes([c]);events=1;allocation=16
    else:
        assert target == 0x556fdc
        kind='hex';digits=format(c,'x')
        assert 1 <= len(digits) <= 2 and all(x in '0123456789abcdef' for x in digits)
        destination_start=4-len(digits)
        assert 0 <= destination_start and destination_start+len(digits)==4
        out=b'\\u'+('0'*destination_start+digits).encode()
        events=2;allocation=256
    cases.append(dict(byte=c,branch=kind,native_target=hex(target),
                      data_hex=out.hex(),data_bytes=len(out),text_operations=events,
                      non_core_requested_object_bytes=allocation))
assert Counter(c['branch'] for c in cases) == {'special':7,'printable':93,'hex':156}
write('byte-cases.json',cases)

def relative_table(address,count):
    return [address+x for x in struct.unpack('<'+'i'*count,at(address,4*count))]


assert relative_table(0x9ef080,16)[6] == 0x96eb24  # Int_x -> %x
assert relative_table(0x9ef1a4,12)[4] == 0x96f674  # Int
assert relative_table(0x9ef1a4,12)[11] == 0x96f7c8 # String_literal
# Source-selected literal padding/no precision, native creation and node sites.
sites = {
    0x970ed8:'49 83 ef 58',  # 88-byte fun_6592 allocation
    0x971167:'49 83 ef 18',  # data node
    0x98b299:'49 83 ef 30',  # fprintf closure
    0x98b177:'49 83 ef 28',  # output continuation
    0x557057:'49 83 ef 28',  # string iterator closure
    0x96f7c8:'49 83 ef 18',  # literal node
}
for address,expected in sites.items():
    assert at(address,len(bytes.fromhex(expected))) == bytes.fromhex(expected)
assert '<camlCamlinternalFormat__fun_6592>' in bodies['camlCamlinternalFormat__make_int_padding_precision_3515']
assert 'movq   $0x28f7' in bodies['camlCamlinternalFormat__make_int_padding_precision_3515']
assert 'movabs $0x100000000000005' in bodies['camlCamlinternalFormat__make_int_padding_precision_3515']
assert 'cmp    $0x1b,%rax' in bodies['camlCamlinternalFormat__transform_int_alt_3449']
assert 'cmp    $0x7f,%eax' in bodies['caml_alloc_sprintf']
assert bodies['caml_alloc_sprintf'].count('<__vsnprintf_chk@plt>') == 2
assert old_spec['select']['camlCamlinternalFormat__make_int_padding_precision_3515'] == [
    'camlCamlinternalFormat__fun_6559','caml_call_gc']

# All new OCaml direct edges are attached to shared F, new owners or named services.
adj={}
for name in NEW:
    direct = sorted({x for x in re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>',bodies[name])
                     if not x.startswith(name+'+')})
    assert all(x in NEW or x in old_bodies or x in
               ['caml_call_gc','caml_ml_array_bound_error'] for x in direct),(name,direct)
    adj[name]=dict(direct_targets=direct,
                  indirect_sites=re.findall(r'^\s*([0-9a-f]+):.*\b(?:call|jmp)\s+\*[^\n]+',bodies[name],re.M))
adj['camlWhy3__Json_base__char_430']['indirect_meaning']='0x556f44 local byte switch; all 256 cases checked'
adj['camlStdlib__String__iter_425']['indirect_meaning']='0x951df7 invokes only freshly created fun_941'
cadj={
    'caml_format_int':['parse_format','caml_alloc_sprintf','__stack_chk_fail@plt'],
    'parse_format':['caml_string_length','strlen@plt','memmove@plt'],
    'caml_alloc_sprintf':['__vsnprintf_chk@plt','caml_alloc_initialized_string','__stack_chk_fail@plt'],
    'caml_alloc_initialized_string':['caml_alloc_string','memcpy@plt'],
    'caml_alloc_string':['caml_alloc_small_dispatch'],
    'caml_create_bytes':['caml_alloc_string'],
    'caml_fill_bytes':['memset@plt'],
    'caml_blit_string':['memmove@plt'],
}
for name,edges in cadj.items():
    for target in edges:
        assert '<'+target+'>' in bodies[name],(name,target)
write('native-control.json',dict(
    static_objects=static,byte_switch_address='0x9e7210',
    byte_switch_bytes=at(0x9e7210,27*4).hex(),allocation_sites={hex(k):v for k,v in sites.items()},
    new_body_edges=adj,normal_C_wrapper_edges=cadj,
    C_excluded='negative/error numeric returns, long-result duplicate-format branch, large allocation; normal valid service inputs select small paths',
    formatter_extension=dict(new_ordinary_bodies=list(NEW)[4:],ordinary_own_delta=64,
        selected_int='Int_x / Lit_padding (Zeros,4) / No_precision',
        converter='camlCamlinternalFormat__convert_int_3465',
        new_apply2_target='camlCamlinternalFormat__fun_6592',
        no_arbitrary_width_precision=True),
    padding_excluded='negative width, width<=len, Left/Right, sign/base-prefix adjustments, all precision helpers; byte arithmetic proves predicates false',
    padding_service_frontier=['caml_c_call','caml_create_bytes','caml_fill_bytes','caml_blit_string',
                              'caml_call_gc','caml_ml_array_bound_error'],
    shared_F_frontier='unchanged named core/runtime services and selected default leaf output callbacks; import prior formatter closure',
))

S=lambda n:8*(1+(n+8)//8)
assert [S(n) for n in [1,2,4]] == [16,16,16]
assert 48+40+24+88+16+16+24 == 256
assert sum(NEW.values()) == 184
assert 32+32+8+48 == 120
assert 2456*4+176*64+32*3 == 21184
assert 80+max(48,400+32+32) == 544
assert max(16+32,16,16) < 544
for c in cases:
    assert c['data_bytes'] <= 6 and c['text_operations'] <= 2
    assert c['non_core_requested_object_bytes'] <= 256
# This exact all-byte census checks the bounded arithmetic, not program semantics.
all_byte = dict(n=256, s=7,p=93,u=156,
    data_bytes=2+sum(c['data_bytes'] for c in cases),
    text_operations=2+sum(c['text_operations'] for c in cases),
    non_core_requested_object_bytes=72+sum(c['non_core_requested_object_bytes'] for c in cases))
assert all_byte['data_bytes'] == 1045 and all_byte['text_operations'] == 414
assert all_byte['non_core_requested_object_bytes'] == 41496
result=dict(
    scope='all byte values in Json_base.char/string; exact fixed hex padding; conditional source argument',
    conditional=dict(char_data_bytes_upper=6,char_direct_text_operations_upper=2,
        hex_raw_bytes_upper=2,hex_padded_bytes=4,hex_non_core_requested_object_bytes=256,
        string_data_bytes='2+2s+p+6u <= 2+6n',
        string_direct_text_operations='2+s+p+2u <= 2+2n',
        string_non_core_requested_object_bytes='72+16p+256u <= 72+256n',
        string_iteration_closure_bytes=40,formatter_ordinary_own_delta_bytes=64,
        formatter_owned_stack='2456H+176J+32O',
        nonreentrant_lane_counts=dict(H=4,J=64,O=3),
        nonreentrant_string_lane_owned_ocaml_bytes=21304,
        nonreentrant_char_lane_owned_ocaml_bytes=21216,
        normal_C_wrapper_shell_bytes_in_R=544,
        live_new_owned_object_upper='same cumulative direct-object expression; no reclamation credit'),
    actual_joined=dict(source_native_behavior_relation='existing conditional trusted external relation',
        continued_numeric_service_success=False,formatter_state_and_callback_ownership=False,
        global_caller_occurrence_and_reentry_bound=False),
    actual=dict(string_data_bytes_upper=None,string_direct_text_operations_upper=None,
        string_non_core_requested_object_bytes_upper=None,added_stack_bytes_upper=None,
        physical_memory_sufficiency=False,physical_stack_sufficiency=False,
        complete_formatter_capacity_established=False,complete_save_capacity_established=False,
        complete_exit_capacity_established=False,complete_exit_stack_established=False,
        whole_pipeline_capacity_established=False),
    native=dict(bodies=len(frames),new_bodies=len(NEW),checked_instruction_bytes=checked),
    all_byte_census=all_byte,
    failures='all JSON prefixes under normal represented numeric/string services; abandoned reservations charged prospectively; service/GC/error internals remain R; negative vsnprintf returns excluded explicitly',
    global_budgets='r<=3 and e<=2 preserved, never reset here',
    runs=dict(target=0,capture=0,disassembler=0,source_fetch=0,solver=0,predecessor_checker=0),
    review_status='independent review pending; parent owns integration',
)
write('result.json',result)
write('inputs.json',inputs)
write('round.json',dict(date='2026-10-20',issues=[119,153],author_base='9fd8e81a452caa563637c76ec636119d2f205780',
    selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_confirmed_model=None,
    runtime_confirmed_effort=None,token_measurement=None,cost_measurement=None,
    host='Linux 7.0.14 x86_64',first_observed_author_timestamp_utc='2026-10-20 15:41:54 UTC',
    earlier_author_start_time=None,check_start_utc=START.isoformat(),
    check_end_utc=datetime.now(timezone.utc).isoformat(),check_seconds=time.monotonic()-T0,
    intended='Close fixed byte hex-padding delta and JSON char/string conditional interface',
    achieved='256 byte branches, static AST, 88-byte closure, 64H formatter delta, 120-byte caller lane, allocation/event formulas and C shell attached',
    worktree='tmp/json-byte-escape',native_workers=0,expensive_validation=False,
    historical_inputs_reused=True,review_status='pending',
    previous_focused_check=dict(status='pass',start_utc='2026-10-20T15:50:31.608795+00:00',
        seconds=2.2269142670011206,bodies=29,instruction_bytes=8056),
    repeat_reason='Final inspection reduced the byte-switch data witness from 119 slots to its 27 actually reachable table slots; earlier extra slots belonged to neighboring data. No result bound changed.',
    inspection_rework='One read-only substring display ended with ValueError after printing useful inventory; no target or evidence checker failure.'))
print(json.dumps(dict(status='pass',native=result['native'],all_byte_census=all_byte,
                      conditional=result['conditional'],check_seconds=time.monotonic()-T0),indent=2))
