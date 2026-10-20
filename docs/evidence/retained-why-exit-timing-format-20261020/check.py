#!/usr/bin/env python3
"""Focused retained Float_f extension; never executes target or old checkers."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
E=HERE.parent
F=E/'retained-why-save-binder-formatter-stack-20261020'
SCALAR=E/'retained-why-save-scalar-format-20261020'
DISASM=Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF=Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
inputs={}

def identity(raw):return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def read(p):
    p=Path(p);raw=p.read_bytes()
    inputs[str(p.relative_to(REPO)) if p.is_relative_to(REPO) else str(p)]=identity(raw)
    return raw

def js(p):return json.loads(read(p))
def write(name,value):(HERE/name).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')

# Explicit immutable component interface, not a replay of its checker.
f_result=read(F/'result.json')
assert identity(f_result)==dict(bytes=3380,sha256='cca726643bb9a8a45aa8f02058e7e362bb365f31193347d0b0e83a93606d3ff8')
f_bodies=js(F/'native-bodies.json');f_frames=js(F/'native-frames.json')
f_spec=js(F/'formatter-spec.json');js(F/'multiplicities.json')
js(SCALAR/'result.json')
contract=read(SCALAR/'libc-contract/Floating_002dPoint-Conversions.html')
assert b'fixed-point' in contract and b'precision' in contract and b'infinity or a NaN' in contract
read(SCALAR/'libc-contract/Formatted-Output-Functions.html')

# Source slices are extracted from the exact retained revisions.
selections=[
 ('retained-why-session-helper-source-20261019/sources.tar.gz','why3/',{
  'src/util/debug.ml':[(175,187)]}),
 ('retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz',
  'ocaml-8eb41f72ded84df884c3671734c947f612091f84/',{
  'stdlib/camlinternalFormatBasics.ml':[(34,49)],
  'stdlib/camlinternalFormat.ml':[(220,229),(250,284),(294,301),(1380,1505),(1684,1785),(1968,2005),(2625,2665)],
  'stdlib/format.ml':[(1249,1311),(1354,1400)],
  'runtime/memory.c':[(795,843),(889,905)],
 })]
witnesses=[];source={}
for file,prefix,paths in selections:
    archive=E/file;read(archive)
    with tarfile.open(archive) as t:
        for path,ranges in paths.items():
            raw=t.extractfile(prefix+path).read();source[path]=raw.decode()
            lines=raw.decode().splitlines(keepends=True)
            for lo,hi in ranges:
                text=''.join(lines[lo-1:hi])
                witnesses.append(dict(archive=str(archive.relative_to(REPO)),member=prefix+path,
                    member_identity=identity(raw),first_line=lo,last_line=min(hi,len(lines)),text=text,
                    excerpt_identity=identity(text.encode())))
# Recheck the already retained exact runtime allocation/locale source slices.
for w in js(SCALAR/'source-witnesses.json'):
    if '/runtime/' not in w['member']:continue
    archive=REPO/w['archive'];read(archive)
    with tarfile.open(archive) as t:raw=t.extractfile(w['member']).read()
    assert identity(raw)==w['member_identity']
    assert ''.join(raw.decode().splitlines(keepends=True)[w['first_line']-1:w['last_line']])==w['text']
    witnesses.append(w)
TEMPLATE='<stats>@[%s: %f, %d@]@.'
assert TEMPLATE in source['src/util/debug.ml']
assert '| Float_f' in source['stdlib/camlinternalFormatBasics.ml']
assert 'if str = "" then (0, Pp_box)' in source['stdlib/camlinternalFormat.ml']
assert 'Format (End_of_format, "")' in source['stdlib/camlinternalFormat.ml']
write('source-witnesses.json',witnesses)

# Process environment is an observation; runtime locale success remains a premise.
env=[]
capture=E/'retained-why-save-state-capture-20261020'
manifest=js(capture/'capture-manifest.json')
retained_archives={a['path']:a for a in manifest['archives']}
for case,pid in [('put-line',17310),('put',17514),('first-or-default',17631),('is-message',17704),('input-is-valid',17869)]:
    archive=capture/f'capture-{case}.tar.gz'
    recorded=retained_archives[archive.name]
    assert identity(read(archive))=={k:recorded[k] for k in ['bytes','sha256']}
    with tarfile.open(archive) as t:
        names=[n for n in t.getnames() if n.endswith('/process.json')]
        assert len(names)==1
        raw=t.extractfile(names[0]).read()
    retained_member=next(m for m in recorded['members'] if m['path']==names[0])
    assert identity(raw)=={k:retained_member[k] for k in ['bytes','sha256']}
    p=json.loads(raw)
    assert p['pid']==pid and p['environment']['LC_ALL']=='C'
    env.append(dict(case=case.replace('-','_'),pid=pid,archive=str(archive.relative_to(REPO)),
      member=names[0],member_identity=identity(raw),LC_ALL='C'))
write('retained-environment.json',env)

raw=read(DISASM)
assert identity(raw)==dict(bytes=69046582,sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
bodies={m[1]:m[0] for m in re.finditer(r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)',raw.decode(),re.M|re.S)}
elf=read(ELF)
assert identity(elf)==dict(bytes=24561432,sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
h=struct.unpack_from('<16sHHIQQQIHHHHHH',elf)
segments=[struct.unpack_from('<IIQQQQQQ',elf,h[5]+i*h[9]) for i in range(h[10])]
def at(address,length):
    s=next(s for s in segments if s[0]==1 and s[3]<=address and address+length<=s[3]+s[5])
    return elf[s[2]+address-s[3]:s[2]+address-s[3]+length]

OCAML=['camlCamlinternalFormat__make_float_padding_precision_3516',
 'camlCamlinternalFormat__fun_6659','camlCamlinternalFormat__convert_float_3481',
 'camlCamlinternalFormat__format_of_fconv_3442','camlCamlinternalFormat__char_of_fconv_inner_5934',
 'camlCamlinternalFormat__buffer_create_603','camlCamlinternalFormat__buffer_check_size_606',
 'camlCamlinternalFormat__buffer_add_char_643','camlCamlinternalFormat__buffer_add_string_647',
 'camlCamlinternalFormat__bprint_fconv_flag_756','camlStdlib__Int__to_string_303',
 'camlStdlib__Bytes__sub_302','camlStdlib__Format__compute_tag_1645',
 'camlCamlinternalFormat__open_box_of_string_4522']
CFRAMES={'caml_format_float':48,'caml_alloc_sprintf':400,
 'caml_stat_strdup':16,'caml_stat_strdup_noexc':32,'caml_stat_alloc_noexc':16,
 'caml_alloc_string':32,'caml_alloc_initialized_string':32,'caml_stat_free':8}
checked=0;frames={}
for n in OCAML+list(CFRAMES):
    v=bodies[n]
    if n in OCAML:assert v==f_bodies[n]
    for line in v.splitlines()[1:]:
        m=re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)',line)
        if not m:
            assert not line.strip(),line
            continue
        bs=bytes.fromhex(m[2]);assert at(int(m[1],16),len(bs))==bs
        checked+=len(bs)
    if n in OCAML:frames[n]=f_frames[n]
    else:
        subs=re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp',v)
        pushes=re.findall(r'\bpush\s+[^\n]+',v)
        assert len(subs)<=1
        own=8+8*len(pushes)+sum(int(x,16) for x in subs)
        assert own==CFRAMES[n],(n,own)
        frames[n]=dict(own_high_water_upper=own,body_identity=identity(v.encode()))
write('native-bodies.json',{n:bodies[n] for n in OCAML+list(CFRAMES)})
write('native-frames.json',frames)

# Static dispatch table ties Float_f (ordinal0) and Float_g (ordinal3) to the
# identical plain printf branch, without admitting Float_F or hexadecimal paths.
conv_targets=[0x9ef180+x for x in struct.unpack('<9i',at(0x9ef180,36))]
char_targets=[0x9eea68+x for x in struct.unpack('<9i',at(0x9eea68,36))]
assert conv_targets[0]==conv_targets[3]==0x96f31c
assert char_targets[0]==0x968a0c
assert at(0x968a0c,6)==bytes.fromhex('b8 cd 00 00 00 c3')
assert 'mov    $0xfffffffffffffff5,%rbx' in bodies['camlCamlinternalFormat__fun_6659'] # tagged -6
assert at(0x9714bc,4)==bytes.fromhex('49 83 ef 40') # selected64-byte float argument closure
assert 'sub    $0x18,%r15' in bodies['camlCamlinternalFormat__buffer_create_603']
assert 'sub    $0x18,%r15' in bodies['camlCamlinternalFormat__fun_6659']
assert 'sub    $0x30,%r15' in bodies['camlCamlinternalFormat__convert_float_3481']
assert bodies['camlCamlinternalFormat__convert_float_3481'].index('sub    $0x30,%r15') < bodies['camlCamlinternalFormat__convert_float_3481'].index('jmp    *%rdx')
assert 'add    $0x10,%rdi' in bodies['caml_stat_alloc_noexc']
assert 'cmp    $0x7f,%eax' in bodies['caml_alloc_sprintf']
assert 'ja     9cd448' in bodies['caml_alloc_sprintf']
assert bodies['caml_alloc_sprintf'].count('<__vsnprintf_chk@plt>')==2
literal_offsets=[m.start() for m in re.finditer(re.escape(TEMPLATE.encode()),elf)]
assert literal_offsets

# A selected normal runtime wrapper DAG: allocation/GC/libc/error internals are
# explicit frontiers, not silently assumed to have zero stack.
CADJ={
 'caml_format_float':['caml_alloc_sprintf','uselocale@plt'],
 'caml_alloc_sprintf':['__vsnprintf_chk@plt','caml_alloc_initialized_string',
   'caml_stat_strdup','caml_alloc_string','caml_stat_free','__stack_chk_fail@plt'],
 'caml_stat_strdup':['caml_stat_strdup_noexc','caml_raise_out_of_memory'],
 'caml_stat_strdup_noexc':['strlen@plt','caml_stat_alloc_noexc','memcpy@plt'],
 'caml_stat_alloc_noexc':['malloc@plt'],
 'caml_alloc_initialized_string':['caml_alloc_string','memcpy@plt'],
 'caml_alloc_string':['caml_alloc_small_dispatch'],
 'caml_stat_free':['free@plt'],
}
front=set()
for n,targets in CADJ.items():
    direct=set(x.split('+')[0] for x in re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>',bodies[n]))-{n}
    excluded=direct-set(targets)
    assert excluded==({'caml_alloc_shr','caml_check_urgent_gc'} if n=='caml_alloc_string' else set()),(n,excluded)
    assert set(targets)<=direct
    front.update(set(targets)-set(CADJ))
def stack(n):return CFRAMES[n]+max([stack(x) if x in CADJ else 0 for x in CADJ[n]] or [0])
assert stack('caml_format_float')==512
write('native-control.json',dict(ocaml_existing_F_bodies=OCAML,added_F_bodies=[],
  convert_float_jump_table=dict(address='0x9ef180',targets=[hex(x) for x in conv_targets]),
  char_of_fconv_jump_table=dict(address='0x9eea68',targets=[hex(x) for x in char_targets]),
  template_literal_elf_offsets=literal_offsets,normal_C_wrapper_calls=CADJ,
  normal_C_wrapper_services=sorted(front),normal_C_wrapper_shell_upper=512,
  excluded_large_string_allocation='Normal317-byte result has40 payload words; small allocation path. Negative/error conversion result is outside this normal theorem.',
  bridge_included=False))

# Exact arithmetic over all finite binary64 magnitudes, not floating samples.
assert 2**1024+1 < 10**309
assert 1+309+1+6==317
assert 10**18<=2**62<10**19
assert len(b'%.6f')==4 and len(b'%.6f\0')==5
assert (317+8)//8==40 and 8*(1+(317+8)//8)==328
assert 317+8<0x807 and 317+1==318
assert 5+16==21
conversion_objects=dict(unexecuted_hex_closure=48,format_buffer_record=24,
    format_buffer_backing=32,precision_digit_string=16,format_string=16,result_string=328)
assert sum(conversion_objects.values())==464
# Exact static template node census; default Open_box annotation is End_of_format.
nodes=['literal:<stats>','open_box:empty','string','literal:: ','float_f','literal:, ','int_d','close_box','flush_newline']
assert len(nodes)==9
assert f_spec['select']['camlCamlinternalFormat__convert_float_3481']==[
    'camlCamlinternalFormat__format_of_fconv_3442','caml_c_call','caml_call_gc','caml_format_float']
write('extension-spec.json',dict(
 imported_spec='docs/evidence/retained-why-save-binder-formatter-stack-20261020/formatter-spec.json',
 additional_float='Float_f with Float_flag_, No_padding, No_precision only',
 additional_annotation='',additional_box_type='Pp_box',additional_token_constructors=[],
 selection_reason_extensions={
  'camlCamlinternalFormat__convert_float_3481':'Float_f shares the retained Float_g branch and exact selected targets.',
  'camlCamlinternalFormat__make_printf_3510':'Same Float constructor; additional selected Float_f value.',
  'camlCamlinternalFormat__open_box_of_string_4522':'Empty string is valid and immediately returns(0,Pp_box); existing invalid continuations remain excluded.'},
 selected_target_changes={},added_own_bodies=[],static_main_nodes=nodes,
 static_annotation_nodes=[],output_acc_instances_upper=len(nodes)+1+1,
 global_state_callback_token_premises_supplied=False))
write('result.json',dict(
 scope='One normal timing Float_f conversion and static timing format extension; no global formatter-state theorem.',
 imported_F_result_sha256=identity(f_result)['sha256'],
 domain='Every IEEE binary64 value/bit pattern for which the selected GNU numeric conversion returns normally, including signed zero, infinities and NaNs.',
 assumptions=['Existing selected typed-source/native behavior relation',
   'Preserved effective C numeric locale and successful locale selection/restoration',
   'Retained GNU fixed-precision conversion contract and successful first/second formatting calls',
   'Runtime/allocator normal behavior and valid source representations'],
 observed_LC_ALL_C_cases=5,conditional_float_bytes_upper=317,
 actual_continued_service_join_established=False,actual_float_bytes_upper=None,
 float_format='%.6f',default_precision=6,normal_vsnprintf_calls_upper=2,
 first_pass_destination_bytes=128,second_pass_destination_bytes_upper=318,
 normal_C_saved_format_payload_bytes_upper=5,normal_C_saved_format_malloc_request_bytes_upper=21,
 normal_OCaml_result_bytes_upper=328,normal_OCaml_conversion_requested_blocks=conversion_objects,
 normal_OCaml_conversion_requested_bytes_upper=464,
 returned_float_argument_closure_bytes=64,accumulator_node_bytes=24,
 normal_OCaml_conversion_plus_argument_and_node_bytes_upper=552,
 result_block_increase_over_prior_unified_32_byte_scalar_allowance=296,
 added_OCaml_F_bodies=[],added_OCaml_F_own_stack_bytes=0,
 reusable_F_expression='2392*H + 176*J + 32*O, under its stated callback/token/state premises with Float_f and empty annotation now allowed',
 normal_C_wrapper_shell_to_explicit_services_bytes=512,C_shell_is_part_of_R=True,
 timing_template=TEMPLATE,static_main_accumulator_nodes=9,static_annotation_nodes=0,
 timing_template_output_acc_instances_upper=11,
 literal_and_conversion_data_bytes_excluding_name_and_formatter_indentation_upper=348,
 explicit_newline_requests_per_template=1,conditional_default_newline_bytes=1,
 environment_extensions=['Float_f, No_padding, No_precision, no flags; old Float_g remains allowed',
   'Empty default box annotation returns(0,Pp_box) without parsing; no new native body'],
 still_excluded=['Explicit/dynamic precision or width; other new conversion flags/constructors',
   'registered_stats %t callbacks and arbitrary registered output',
   'Global formatter callbacks, queue/token/box/tag/tab state and parameter preservation',
   'Timing-map/counter update totals or repetition bounds',
   'Numeric service failure, native allocator/libc internals, GC callbacks and physical sufficiency'],
 complete_exit_stack_established=False,complete_exit_capacity_established=False,
 complete_save_capacity_established=False,
 native=dict(bodies=len(OCAML)+len(CFRAMES),checked_instruction_bytes=checked),
 target_runs=0,new_captures=0,new_disassembly_runs=0,predecessor_checker_replays=0,solver_runs=0))
read(Path(__file__))
write('inputs.json',inputs)
print(json.dumps(dict(ok=True,native_bodies=len(OCAML)+len(CFRAMES),checked_instruction_bytes=checked,
 float_bytes_upper_conditional=317,OCaml_conversion_requested_bytes_upper=464,
 C_saved_format_request_bytes_upper=21,added_F_own_stack_bytes=0,C_wrapper_shell_bytes=512,
 complete_exit_capacity_established=False),sort_keys=True))
