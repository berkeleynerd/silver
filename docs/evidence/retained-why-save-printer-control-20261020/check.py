#!/usr/bin/env python3
"""Focused frozen-evidence/source/native/control reconciliation; no replay."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import bounds, PREMISES, consume_signal_exception

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
WHY='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML='docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
ALLOC='docs/evidence/retained-why-save-shape-builder-allocation-20261020/'
STRUCT='docs/evidence/retained-why-save-structural-allocation-20261020/'
SHAPE='docs/evidence/retained-why-session-shape-transfer-20261020/bounds.json'
INPUTS=[WHY,OCAML,SHAPE,ALLOC+'result.json',ALLOC+'native-bodies.json',
    ALLOC+'native-witnesses.json',STRUCT+'native-bodies.json',
    'docs/evidence/retained-why-ordinary-ending-control-20261020/control-ledger.json',
    *['docs/research/'+n+'.md' for n in (
        'retained-why-save-shape-builder-allocation','retained-why-session-shape-transfer',
        'retained-why-ordinary-ending-control','retained-why-path-initial-state',
        'retained-why-native-effect-completeness','retained-why-inline-callback-closure',
        'retained-why-session-formatter-prefix-repair','retained-why-session-exception-prefix')]]
WSPECS=[('src/core/ident.ml',113,152),('src/core/ident.ml',225,305),
    ('src/core/ident.mli',111,139),('src/session/termcode.ml',340,409),
    ('src/session/termcode.ml',430,544),('src/session/termcode.ml',601,628),
    ('src/session/termcode.mli',14,99),('src/session/session_itp.ml',164,183),
    ('src/gnat/gnat_main.ml',298,309),('src/util/wstdlib.ml',26,30),
    ('src/util/wstdlib.ml',61,99),('src/util/exthtbl.ml',38,47)]
OSPECS=[('stdlib/hashtbl.ml',20,45),('stdlib/hashtbl.ml',69,78),
    ('stdlib/hashtbl.ml',113,153),('stdlib/hashtbl.ml',351,399),
    ('stdlib/hashtbl.ml',430,453),('stdlib/hashtbl.ml',477,499)]
NAMES={
    'camlWhy3__Ident__find_unique_3105','camlWhy3__Ident__specname_3109',
    'camlWhy3__Ident__testname_3112','camlWhy3__Ident__advance_3115',
    'camlWhy3__Ident__retreat_3117','camlWhy3__Ident__create_ident_printer_inner_6267',
    'camlWhy3__Ident__id_unique_inner_6286','camlWhy3__Ident__sn_decode_2005',
    'camlWhy3__Termcode__check_2028','camlWhy3__Termcode__ident_v5_2122',
    'camlWhy3__Termcode__t_bound_shape_task_2924','camlWhy3__Termcode__do_d_2936',
    'camlStdlib__Hashtbl__find_1059','camlStdlib__Hashtbl__find_rec_1053',
    'camlStdlib__Hashtbl__key_index_1028','camlStdlib__Hashtbl__replace_1107',
    'camlStdlib__Hashtbl__replace_bucket_1100','camlStdlib__Hashtbl__mem_1114',
    'camlStdlib__Hashtbl__insert_all_buckets_702','camlStdlib__Hashtbl__insert_bucket_710',
    'camlStdlib__Hashtbl__resize_721'}
INSN=re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')


def identity(raw):
    return {'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT/path).read_text())


def sources():
    excerpts=[]; origins=[]
    for archive,specs in ((WHY,WSPECS),(OCAML,OSPECS)):
        with tarfile.open(ROOT/archive) as t:
            members={m.name:m for m in t.getmembers() if m.isfile()}
            for suffix,a,b in specs:
                member=next(n for n in members if n.endswith('/'+suffix))
                raw=t.extractfile(member).read(); lines=raw.decode().splitlines(keepends=True)
                assert 1<=a<=b<=len(lines),(suffix,a,b,len(lines))
                excerpts.append({'archive':archive,'member':member,'member_identity':identity(raw),
                    'first':a,'last':b,'text':''.join(lines[a-1:b])})
            if archive==WHY:
                for name,m in sorted(members.items()):
                    if not name.endswith(('.ml','.mli')): continue
                    raw=t.extractfile(m).read()
                    for line,text in enumerate(raw.decode().splitlines(),1):
                        if 'ShapeTooLong' in text:
                            origins.append({'member':name,'member_identity':identity(raw),
                                'line':line,'text':text})
    assert [(x['member'],x['line']) for x in origins]==[
        ('why3/src/session/termcode.ml',n) for n in (342,347,539,618)]
    return excerpts,origins


def native():
    pool={**read(ALLOC+'native-bodies.json'),**read(STRUCT+'native-bodies.json')}
    assert NAMES<=pool.keys(),NAMES-pool.keys()
    bodies={n:pool[n] for n in sorted(NAMES)}
    meta=read(ALLOC+'native-witnesses.json')
    binary=Path(meta['executable']['path']).read_bytes()
    assert identity(binary)==meta['executable']['identity']
    off=struct.unpack_from('<Q',binary,32)[0]; size,count=struct.unpack_from('<HH',binary,54)
    loads=[]
    for i in range(count):
        kind,flags,p,addr,_,n,_,_=struct.unpack_from('<IIQQQQQQ',binary,off+i*size)
        if kind==1 and flags&1: loads.append((addr,addr+n,p))
    checked=0
    for name,body in bodies.items():
        for line in body.splitlines():
            if not (m:=INSN.match(line)):continue
            addr,raw=int(m[1],16),bytes.fromhex(m[2])
            assert any(lo<=addr and addr+len(raw)<=hi and
                binary[p+addr-lo:p+addr-lo+len(raw)]==raw for lo,hi,p in loads),name
            checked+=len(raw)
    facts=[
        ('camlWhy3__Ident__find_unique_3105','56d964','call','replace_1107','first update within trap'),
        ('camlWhy3__Ident__find_unique_3105','56d980','pop','0x10(%r14)','normal trap removal'),
        ('camlWhy3__Ident__find_unique_3105','56d9c6','call','replace_1107','final replacement after trap'),
        ('camlWhy3__Ident__id_unique_inner_6286','56de1e','call','replace_1107','values replacement in miss handler'),
        ('camlWhy3__Termcode__ident_v5_2122','7ea619','call','decoded_2037','decoder in map miss handler'),
        ('camlWhy3__Termcode__do_d_2936','7ebb04','call','t_shape_2345','shape traversal within ShapeTooLong trap'),
        ('camlStdlib__Hashtbl__replace_1107','983094','je','983130','found-key branch bypasses insertion/resize'),
        ('camlStdlib__Hashtbl__replace_1107','98311f','jmp','resize_721','resize reachable only on missing-key arm'),
        ('camlStdlib__Hashtbl__replace_bucket_1100','982fe1','call','caml_modify','existing slot key store'),
        ('camlStdlib__Hashtbl__replace_bucket_1100','982ff2','call','caml_modify','existing slot data store'),
        ('camlStdlib__Hashtbl__replace_bucket_1100','983017','jmp','982f84','bucket scan tail backedge'),
    ]
    rows=[]
    for name,addr,op,target,meaning in facts:
        line=next(l for l in bodies[name].splitlines() if l.lstrip().startswith(addr+':'))
        assert op in line and target in line,(name,line)
        rows.append({'body':name,'address':addr,'instruction':line,'inspected_meaning':meaning})
    return bodies,{'executable':meta['executable'],'body_count':len(bodies),
        'instruction_bytes':checked,'reused_retained_disassembly_only':True},rows


def compute():
    excerpts,origins=sources(); bodies,meta,facts=native()
    rows=[]
    for sh,alloc in zip(read(SHAPE),read(ALLOC+'result.json')['cases'],strict=True):
        assert sh['case']==alloc['case']
        P=max(t['P'] for t in sh['task_bounds'].values()); G=sh['G']
        assert alloc['inputs']['P']==P and alloc['inputs']['G']==G
        no=bounds(G,P); yes=bounds(G,P,{k:True for k in PREMISES})
        assert all(no['guards'].values())
        assert no['printer_structure_and_finite_tool_traversals_under_supplied_premises'] is None
        assert yes['first_replace_no_resize_and_reused_printer_valid_under_supplied_premises']
        assert yes['candidate']['specname_calls_upper_unchanged']==alloc['under_named_existing_external_premises']['candidate']['candidate_specname_calls_per_printer_upper']
        for absent in PREMISES:
            assert bounds(G,P,{k:True for k in PREMISES if k!=absent})['printer_structure_and_finite_tool_traversals_under_supplied_premises'] is None
        rows.append({'case':sh['case'],'pid':alloc['pid'],'G':G,'P':P,
            'without_external_assertion':no,'under_named_existing_external_premises':yes})
    remaining=2
    remaining=consume_signal_exception(remaining)
    remaining=consume_signal_exception(remaining)
    assert remaining==0
    try:consume_signal_exception(remaining)
    except ValueError:pass
    else:raise AssertionError('global exception budget renewed')
    assert bounds(1,4096)['candidate']['each_table_capacity_upper']==2048
    assert bounds(1,4097)['candidate']['each_table_capacity_upper']==4096
    assert bounds(1,1<<32,{k:True for k in PREMISES})['printer_structure_and_finite_tool_traversals_under_supplied_premises'] is None
    return {
        'inputs.json':{p:identity((ROOT/p).read_bytes()) for p in INPUTS},
        'source-witnesses.json':excerpts,'shape-exception-origins.json':origins,
        'native-bodies.json':bodies,'native-witnesses.json':meta,'native-control-facts.json':facts,
        'result.json':{'scope':'Selected private printer reusable-table preservation and finite tool traversal',
            'source_control_argument_machine_proved':False,
            'ordinary_primitive_errors_not_assumed_absent':True,
            'global_exception_budget_renewed_at_printer_or_root':False,
            'complete_save_capacity_established':False,'whole_pipeline_capacity_established':False,
            'cases':rows}}


def main():
    p=argparse.ArgumentParser(); p.add_argument('--write',action='store_true'); args=p.parse_args()
    start=time.monotonic(); outputs=compute()
    for name,obj in outputs.items():
        if args.write:(HERE/name).write_text(json.dumps(obj,indent=2,sort_keys=True)+'\n')
        else:assert json.loads((HERE/name).read_text())==obj,name
    result={'status':'passed','cases':len(outputs['result.json']['cases']),
        'source_excerpts':len(outputs['source-witnesses.json']),
        'exception_origin_references':len(outputs['shape-exception-origins.json']),
        'native_bodies':outputs['native-witnesses.json']['body_count'],
        'native_instruction_bytes':outputs['native-witnesses.json']['instruction_bytes'],
        'native_control_facts':len(outputs['native-control-facts.json']),
        'target_proof_capture_source_fetch_or_predecessor_replays':0,
        'elapsed_seconds':time.monotonic()-start}
    if args.write:(HERE/'check-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':main()
