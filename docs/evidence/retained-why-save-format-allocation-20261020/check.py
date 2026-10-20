#!/usr/bin/env python3
"""New allocation composition only; no predecessor checker or native execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import bounds, PREMISES, buffer_requests, string_block

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
ACC = 'docs/evidence/retained-why-save-format-accumulator-20261020/result.json'
JOIN = 'docs/evidence/retained-why-save-round32-20261020/result.json'
STATE = 'docs/evidence/retained-why-save-state-join-20261020/result.json'
INPUTS = [OCAML, WHY, ACC, JOIN, STATE,
    'docs/evidence/retained-why-save-file-capacity-20261020/result.json',
    'docs/evidence/retained-why-save-format-accumulator-20261020/native-witnesses.json',
    'docs/evidence/retained-why-save-format-accumulator-20261020/template-census.json',
    'docs/research/retained-why-save-formatter-core.md',
    'docs/research/retained-why-save-scalar-format.md',
    'docs/research/retained-why-save-formatter-ownership.md',
    'docs/research/retained-why-save-format-accumulator.md',
    'docs/research/retained-why-save-file-capacity.md',
    'docs/research/retained-why-save-path-input-join.md']
OSPECS = [('stdlib/format.ml',68,189),('stdlib/format.ml',218,225),
    ('stdlib/format.ml',257,535),('stdlib/format.ml',593,618),
    ('stdlib/format.ml',626,709),('stdlib/format.ml',894,1034),
    ('stdlib/format.ml',1249,1256),('stdlib/format.ml',1387,1396),
    ('stdlib/buffer.ml',18,95),('stdlib/buffer.ml',164,180),
    ('stdlib/queue.ml',19,82),('stdlib/stack.ml',16,46),
    ('stdlib/camlinternalFormat.ml',250,284),
    ('stdlib/camlinternalFormat.ml',1413,1422),
    ('stdlib/camlinternalFormat.ml',1449,1489),
    ('stdlib/stdlib.ml',325,339),('runtime/io.c',94,124),
    ('runtime/io.c',494,537),('runtime/custom.c',33,76),
    ('otherlibs/systhreads/st_stubs.c',255,295),
    ('otherlibs/systhreads/st_posix.h',219,240)]
WSPECS = [('src/session/session_itp.ml',2019,2209),
    ('src/session/termcode.ml',249,269),('src/util/pp.ml',29,40),
    ('src/util/pp.ml',93,121),('src/util/pp.ml',216,228),
    ('src/util/sysutil.ml',131,135)]
FIXED_NAMES = [
    'camlStdlib__Format__pp_make_formatter_1137',
    'camlStdlib__Format__make_formatter_1152',
    'camlStdlib__Format__formatter_of_out_channel_1157',
    'camlStdlib__Format__formatter_of_buffer_1161',
    'camlStdlib__Format__initialize_scan_stack_691',
    'camlStdlib__Format__set_size_695', 'camlStdlib__Format__scan_push_702',
    'camlStdlib__Format__pp_open_box_gen_708', 'camlStdlib__Format__pp_close_box_718',
    'camlStdlib__Format__pp_rinit_772', 'camlStdlib__Format__clear_tag_stack_775',
    'camlStdlib__Format__pp_flush_queue_779',
    'camlStdlib__Format__pp_print_custom_break_953', 'camlStdlib__Format__pp_print_break_965',
    'camlStdlib__Format__format_pp_token_631', 'camlStdlib__Format__advance_left_671',
    'camlStdlib__Format__enqueue_string_as_682', 'camlStdlib__Format__pp_force_break_line_621',
    'camlStdlib__Stack__push_280', 'camlStdlib__Stack__pop_opt_289',
    'camlStdlib__Stack__top_opt_298', 'camlStdlib__Queue__add_283',
    'camlStdlib__Queue__peek_opt_294', 'camlStdlib__Queue__take_299',
    'camlStdlib__Buffer__create_272', 'camlStdlib__Buffer__resize_482',
    'camlStdlib__Buffer__add_substring_564', 'camlStdlib__Buffer__contents_451',
    'camlCamlinternalFormat__buffer_create_603',
    'camlCamlinternalFormat__format_of_fconv_3442',
    'camlCamlinternalFormat__convert_float_3481',
    'camlWhy3__Termcode__string_of_shape_1782',
    'camlWhy3__Termcode__fun_9373', 'camlWhy3__Termcode__fun_9383',
    'camlWhy3__Session_itp__save_session_4339',
    'caml_alloc_channel', 'caml_alloc_custom_mem', 'alloc_custom_gen',
    'caml_io_mutex_lock', 'st_mutex_init', 'caml_open_descriptor_in',
]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(p):
    return json.loads((ROOT/p).read_text())


def freeze_native():
    meta = read('docs/evidence/retained-why-save-format-accumulator-20261020/native-witnesses.json')
    raw = Path(meta['existing_disassembly']['path']).read_bytes()
    assert identity(raw) == {k: meta['existing_disassembly'][k] for k in ('bytes','sha256')}
    all_bodies = {n:b for b,n in re.findall(r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)',raw.decode(),re.S)}
    # The complete save-printer region includes generated caller closure bodies.
    names = set(FIXED_NAMES) | {n for n,b in all_bodies.items()
        if 0x7fad40 <= int(b.split()[0],16) < 0x7fc850}
    selected = {n:all_bodies[n] for n in sorted(names)}
    count = sum(len(bytes.fromhex(m[2])) for b in selected.values()
                for line in b.splitlines() if (m := INSN.match(line)))
    (HERE/'native-bodies.json').write_text(json.dumps(selected,indent=2)+'\n')
    (HERE/'native-witnesses.json').write_text(json.dumps({
        'executable':meta['executable'],'existing_disassembly':meta['existing_disassembly'],
        'instruction_bytes':count,'body_count':len(selected),
        'source_native_refinement_proved':False},indent=2)+'\n')


def native_check():
    meta = json.loads((HERE/'native-witnesses.json').read_text())
    binary = Path(meta['executable']['path']).read_bytes()
    assert identity(binary) == meta['executable']['identity']
    assert binary[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q',binary,32)[0]
    size,count = struct.unpack_from('<HH',binary,54)
    loads = []
    for i in range(count):
        kind,flags,off,address,_,filesz,_,_ = struct.unpack_from('<IIQQQQQQ',binary,phoff+i*size)
        if kind == 1 and flags & 1:
            loads.append((address,address+filesz,off))
    bodies = json.loads((HERE/'native-bodies.json').read_text())
    assert set(FIXED_NAMES) <= set(bodies)
    checked = 0
    census = {}
    for name,body in bodies.items():
        assert re.match(r'[0-9a-f]+ <'+re.escape(name)+r'>:',body)
        for line in body.splitlines():
            m=INSN.match(line)
            if not m:
                continue
            address,raw=int(m[1],16),bytes.fromhex(m[2])
            assert any(lo <= address and address+len(raw) <= hi and
                       binary[off+address-lo:off+address-lo+len(raw)] == raw for lo,hi,off in loads),name
            checked += len(raw)
        # Site totals, not dynamic counts; unreachable generic branches remain visible.
        census[name] = {'constant_minor_reservation_site_bytes':
            [int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15',body)],
            'heap_header_literals': re.findall(r'movq\s+\$(0x[0-9a-f]+),-0x8\(',body)}
    assert checked == meta['instruction_bytes'] and len(bodies) == meta['body_count']
    expected = {
        'camlStdlib__Format__pp_make_formatter_1137':[64,24,24,328],
        'camlStdlib__Format__make_formatter_1152':[40,40,40],
        'camlStdlib__Format__formatter_of_out_channel_1157':[80],
        'camlStdlib__Format__formatter_of_buffer_1161':[48],
        'camlStdlib__Format__initialize_scan_stack_691':[56],
        'camlStdlib__Stack__push_280':[24],
        'camlStdlib__Stack__pop_opt_289':[16],
        'camlStdlib__Stack__top_opt_298':[16],
        'camlStdlib__Queue__add_283':[24],
        'camlStdlib__Queue__peek_opt_294':[16],
        'camlStdlib__Queue__take_299':[],
        'camlStdlib__Format__clear_tag_stack_775':[32],
        'camlStdlib__Buffer__create_272':[40],
        'camlCamlinternalFormat__buffer_create_603':[24],
        'camlWhy3__Termcode__string_of_shape_1782':[104],
        'camlWhy3__Session_itp__save_prover_4202':[16,56],
        'camlWhy3__Session_itp__save_result_4237':[16,56],
        'camlWhy3__Session_itp__save_file_path_4247':[32],
        'camlWhy3__Session_itp__save_proof_attempt_4252':[224],
        'camlWhy3__Session_itp__save_goal_4268':[104,48,40,40,56],
        'camlWhy3__Session_itp__save_trans_4269':[112,56,56],
        'camlWhy3__Session_itp__save_theory_4306':[56,56],
        'camlWhy3__Session_itp__save_file_4312':[104,56],
        'camlWhy3__Session_itp__save_4319':[48,48,88],
        'camlWhy3__Session_itp__save_session_4339':[40,40],
    }
    for name,sizes in expected.items():
        assert census[name]['constant_minor_reservation_site_bytes'] == sizes,(name,census[name])
    assert 'mov    $0x28,%edi' in bodies['caml_io_mutex_lock']
    assert 'mov    $0x8,%esi' in bodies['caml_alloc_channel']
    assert 'mov    $0x10050,%edx' in bodies['caml_alloc_channel']
    assert '$0x7000,-0x8(%rax)' in bodies['camlStdlib__Format__pp_make_formatter_1137']
    return census, len(bodies), checked


def compute():
    witnesses=[]
    for archive,specs in [(OCAML,OSPECS),(WHY,WSPECS)]:
        with tarfile.open(ROOT/archive) as t:
            members={m.name:m for m in t.getmembers() if m.isfile()}
            for suffix,a,b in specs:
                member=next(n for n in members if n.endswith('/'+suffix))
                raw=t.extractfile(member).read(); lines=raw.decode().splitlines(keepends=True)
                assert 1 <= a <= b <= len(lines)
                witnesses.append({'archive':archive,'member':member,'member_identity':identity(raw),
                    'first':a,'last':b,'text':''.join(lines[a-1:b])})
    acc=read(ACC)['cases']; join=read(JOIN)['under_named_existing_external_premises']['cases']
    state=read(STATE)['cases']; rows=[]
    for a,j,s in zip(acc,join,state,strict=True):
        assert a['case'] == j['case'] == s['case']
        args=(a['occurrences'],j['candidate_B'],j['candidate_E'],
              s['conditional_operational_transfer']['bound_shape_text_bytes_upper'],
              s['captured_entry']['session_dir_bytes'],
              j['path_construction']['candidate']['aggregate_requested_string_block_bytes_upper'])
        no=bounds(*args); yes=bounds(*args,premises={p:True for p in PREMISES})
        assert all(no['guards'].values())
        c=no['candidate']; prior=a['without_external_assertion']['candidate']
        assert c['C'] == prior['formatted_calls_per_save_upper']
        assert c['O'] == prior['box_annotation_helpers_per_save_upper']
        assert c['ocaml_requested_block_bytes_by_disjoint_owner']['accepted_accumulators_and_Format_continuations'] == prior['accumulator_and_format_continuation_requested_bytes_interval_upper']
        for p in PREMISES:
            missing={q:True for q in PREMISES if q != p}
            assert bounds(*args,premises=missing)['direct_request_accounting_under_supplied_premises'] is None
            assert bounds(*args,premises={**missing,p:False})['direct_request_accounting_under_supplied_premises'] is None
        # Guard failure cannot produce an actual bound even with all premises.
        oversized=(args[0],1000000010,args[2],*args[3:])
        assert bounds(*oversized,premises={p:True for p in PREMISES})['direct_request_accounting_under_supplied_premises'] is None
        rows.append({'case':a['case'],'pid':a['pid'],'B':args[1],'E':args[2],
                     'without_external_assertion':no,'under_named_existing_external_premises':yes})
    return {'inputs.json':{p:identity((ROOT/p).read_bytes()) for p in INPUTS},
        'source-witnesses.json':witnesses,
        'result.json':{'scope':'Complete direct requested-object accounting for selected formatter/printer operations plus stated file/channel objects; external owners explicit',
            'global_r_is_three_not_per_recursive_entry':True,
            'source_argument_machine_proved':False,
            'physical_GC_allocator_sufficiency_established':False,
            'complete_save_capacity_established':False,'whole_pipeline_capacity_established':False,
            'cases':rows}}


def main():
    start=time.monotonic(); parser=argparse.ArgumentParser()
    parser.add_argument('--write',action='store_true'); parser.add_argument('--freeze-native',action='store_true')
    args=parser.parse_args()
    if args.freeze_native:
        freeze_native()
    census,native_count,native_bytes=native_check()
    computed=compute(); computed['native-allocation-sites.json']=census
    for n,v in computed.items():
        path=HERE/n
        if args.write:
            path.write_text(json.dumps(v,indent=2)+'\n')
        else:
            assert json.loads(path.read_text()) == v,n
    # Focused arithmetic boundary checks: capacity jumps and independent guards.
    assert buffer_requests(0)['capacity_upper'] == 512
    assert buffer_requests(512)['resize_calls_upper'] == 0
    assert buffer_requests(513)['capacity_upper'] == 1024
    assert buffer_requests(1025)['all_backing_blocks_bytes_upper'] == sum(string_block(n) for n in (512,1024,2048))
    for L in (0,1,7,8,16,20,512,111475):
        assert string_block(L) >= L+9 and string_block(L)%8 == 0
    for bad in (-1,True,1.5):
        try:
            bounds({k:0 for k in ('F','Th','G','T','A','Axml','Args','Paths')},0,0,bad,0,0)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid extent accepted')
    print(json.dumps({'status':'ok','json_comparisons':len(computed),'source_excerpts':len(computed['source-witnesses.json']),
        'native_bodies':native_count,'native_instruction_bytes':native_bytes,
        'case_count':len(computed['result.json']['cases']),'predecessor_checkers_replayed':0,
        'elapsed_seconds':round(time.monotonic()-start,3)},sort_keys=True))


if __name__ == '__main__':
    main()
