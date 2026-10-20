#!/usr/bin/env python3
"""New scoped reconciliation; never execute a predecessor checker or target."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import bounds, PREMISES, frequency_table, shape_backings

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
STATE = 'docs/evidence/retained-why-save-state-join-20261020/result.json'
TABLE = 'docs/evidence/retained-why-save-table-contract-join-20261020/result.json'
PUB = 'docs/evidence/retained-why-publication-composition-20261020/result.json'
LOOKUP = 'docs/evidence/retained-why-path-lookup-capacity-20261020/result.json'
OCC = 'docs/evidence/retained-why-save-format-accumulator-20261020/result.json'
FORMAT = 'docs/evidence/retained-why-save-format-allocation-20261020/result.json'
INPUTS = [WHY,OCAML,STATE,TABLE,PUB,LOOKUP,OCC,FORMAT,
    'docs/evidence/retained-why-save-format-allocation-20261020/native-witnesses.json',
    'docs/evidence/retained-why-save-operational-bounds-20261020/transfer.py',
    'docs/evidence/retained-why-path-lookup-capacity-20261020/native-witnesses.json',
    *['docs/research/'+n+'.md' for n in (
        'retained-why-save-operational-bounds','retained-why-save-table-contract-join',
        'retained-why-save-state-join','retained-why-save-format-allocation',
        'retained-why-publication-composition','retained-why-path-lookup-capacity',
        'retained-why-session-shape-transfer','retained-why-save-scalar-format')]]
WSPECS = [('src/session/session_itp.ml',164,201),
    ('src/session/session_itp.ml',300,311),('src/session/session_itp.ml',324,387),
    ('src/session/session_itp.ml',415,459),('src/session/session_itp.ml',750,764),
    ('src/session/session_itp.ml',1954,2017),('src/session/session_itp.ml',2096,2147),
    ('src/session/session_itp.ml',2170,2250),('src/session/termcode.ml',34,100),
    ('src/session/termcode.ml',566,628),('src/core/task.ml',240,278),
    ('src/util/extmap.ml',98,170),('src/util/extmap.ml',213,218),
    ('src/driver/whyconf.ml',80,105),('src/util/sysutil.ml',131,135)]
OSPECS = [('stdlib/hashtbl.ml',20,83),('stdlib/hashtbl.ml',113,174),
    ('stdlib/hashtbl.ml',206,226),('stdlib/hashtbl.ml',351,365),
    ('stdlib/hashtbl.ml',580,601),('stdlib/list.ml',320,391),
    ('stdlib/random.ml',28,100),('stdlib/camlinternalLazy.ml',19,41),
    ('runtime/sys.c',564,620),('runtime/md5.c',20,50)]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')


def ident(raw):
    return {'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}


def read(p):
    return json.loads((ROOT/p).read_text())


def selected_names(all_bodies):
    prefixes = {
        'camlWhy3__Extmap__': ['create_355','bal_367','add_397','iter_460','fold_489','find_409'],
        'camlWhy3__Termcode__': ['add_shape_2883','add_and_prepend_2887',
            'write_shape_to_file_2896','fun_9793','t_bound_shape_task_2924','do_d_2936'],
        'camlWhy3__Session_itp__': ['get_shape_1636','find_sum_1653','clear_only_shape_1665',
            'compute_and_add_shape_1642','get_proof_attempt_node_1714','get_proofNode_1718',
            'get_task_1722','get_transfNode_1750','get_proof_parent_1794','goal_is_detached_1807',
            'is_detached_1820','fold_all_any_of_transn_1848','fun_8393',
            'fold_all_any_of_proofn_1849','fun_8403','fun_8412','fold_all_any_of_theory_1931',
            'fun_8422','fold_all_any_of_file_1938','fun_8437','fold_all_any_1945',
            'fold_all_session_1955','fun_8446','th_proved_2199','file_proved_2204',
            'get_used_provers_with_stats_4069','fun_9928','get_prover_to_save_4166',
            'fun_9947','fun_9949','fun_9951','fun_9955','fun_10184','fun_10201',
            'fun_10367','save_session_4339','fun_10397','fun_10400'],
        'camlStdlib__Hashtbl__': ['create_inner_1743','insert_all_buckets_702',
            'insert_bucket_710','resize_721','iter_730','do_bucket_734','fold_764','do_bucket_769',
            'add_1032','add_1277','replace_1352','replace_bucket_1345','key_index_1273',
            'find_1059','find_rec_1053','find_1304','find_rec_1298'],
        'camlStdlib__List__': ['stable_sort_807','rev_merge_811','rev_merge_rev_821',
            'sort_831','rev_sort_832','rev_append_308'],
        'camlStdlib__Random__': ['new_state_271','full_init_325','make_473','make_self_init_477','bits_484'],
        'camlCamlinternalLazy__': ['force_lazy_block_362'],
        'camlStdlib__Int__': ['to_string_303'],
        'camlStdlib__Digest__': ['string_349'],
    }
    names = {p+n for p, ns in prefixes.items() for n in ns}
    names |= {'caml_curry2','caml_apply2','caml_apply3','caml_sys_random_seed',
              'caml_unix_random_seed','caml_md5_string','camlStdlib__$5e_141'}
    assert names <= all_bodies.keys(), names-all_bodies.keys()
    return names


def freeze_native():
    prior = read('docs/evidence/retained-why-save-format-allocation-20261020/native-witnesses.json')
    raw = Path(prior['existing_disassembly']['path']).read_bytes()
    assert ident(raw) == {k:prior['existing_disassembly'][k] for k in ('bytes','sha256')}
    bodies = {n:b for b,n in re.findall(
        r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)',raw.decode(),re.S)}
    chosen = {n:bodies[n] for n in sorted(selected_names(bodies))}
    count = sum(len(bytes.fromhex(m[2])) for body in chosen.values()
                for line in body.splitlines() if (m:=INSN.match(line)))
    (HERE/'native-bodies.json').write_text(json.dumps(chosen,indent=2)+'\n')
    (HERE/'native-witnesses.json').write_text(json.dumps({
        'executable':prior['executable'],'existing_disassembly':prior['existing_disassembly'],
        'body_count':len(chosen),'instruction_bytes':count,
        'new_disassembler_or_target_execution':False,
        'source_native_refinement_machine_proved':False},indent=2)+'\n')


def check_native():
    meta=read(str((HERE/'native-witnesses.json').relative_to(ROOT)))
    binary=Path(meta['executable']['path']).read_bytes()
    assert ident(binary)==meta['executable']['identity']
    assert binary[:6]==b'\x7fELF\x02\x01'
    phoff=struct.unpack_from('<Q',binary,32)[0]
    size,count=struct.unpack_from('<HH',binary,54)
    loads=[]
    for i in range(count):
        kind,flags,off,addr,_,n,_,_=struct.unpack_from('<IIQQQQQQ',binary,phoff+i*size)
        if kind==1 and flags & 1: loads.append((addr,addr+n,off))
    bodies=json.loads((HERE/'native-bodies.json').read_text())
    assert set(bodies)==selected_names(bodies)
    checked=0; census={}
    for name,body in bodies.items():
        assert re.match(r'[0-9a-f]+ <'+re.escape(name)+r'>:',body)
        for line in body.splitlines():
            if not (m:=INSN.match(line)): continue
            addr,raw=int(m[1],16),bytes.fromhex(m[2])
            assert any(lo<=addr and addr+len(raw)<=hi and
                binary[off+addr-lo:off+addr-lo+len(raw)]==raw for lo,hi,off in loads),name
            checked+=len(raw)
        census[name]=[int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15',body)]
    expected = {
        'camlWhy3__Extmap__create_355':[48], 'camlWhy3__Extmap__bal_367':[48],
        'camlWhy3__Extmap__add_397':[48,48],
        'camlWhy3__Session_itp__save_session_4339':[40,40],
        'camlWhy3__Session_itp__fold_all_session_1955':[48],
        'camlWhy3__Session_itp__fold_all_any_of_proofn_1849':[56,40,16],
        'camlWhy3__Session_itp__fold_all_any_of_theory_1931':[56,16],
        'camlWhy3__Session_itp__fold_all_any_of_file_1938':[56,16],
        'camlWhy3__Session_itp__fold_all_any_of_transn_1848':[56,16],
        'camlWhy3__Session_itp__get_used_provers_with_stats_4069':[40],
        'camlWhy3__Session_itp__fun_9928':[32],
        'camlWhy3__Session_itp__get_prover_to_save_4166':[40,24,40],
        'camlWhy3__Session_itp__fun_9947':[24],
        'camlWhy3__Session_itp__fun_9949':[24],
        'camlWhy3__Session_itp__fun_9951':[24],
        'camlWhy3__Session_itp__fun_10184':[48],
        'camlWhy3__Session_itp__fun_10201':[48],
        'camlWhy3__Session_itp__fun_10367':[40],
        'camlWhy3__Termcode__t_bound_shape_task_2924':[24,16,32,72],
        'camlWhy3__Termcode__add_and_prepend_2887':[24],
        'camlWhy3__Termcode__write_shape_to_file_2896':[40],
        'camlStdlib__Hashtbl__create_inner_1743':[40],
        'camlStdlib__Hashtbl__iter_730':[32],
        'camlStdlib__Hashtbl__fold_764':[40],
        'camlStdlib__Hashtbl__insert_all_buckets_702':[56],
        'camlStdlib__Hashtbl__insert_bucket_710':[32],
        'camlStdlib__Hashtbl__add_1032':[32],
        'camlStdlib__Hashtbl__add_1277':[32],
        'camlStdlib__Hashtbl__replace_1352':[32],
        'camlStdlib__List__stable_sort_807':[168],
        'caml_curry2':[40], 'camlStdlib__Random__new_state_271':[24],
        'camlStdlib__Random__full_init_325':[16],
        'camlCamlinternalLazy__force_lazy_block_362':[16,32],
    }
    for n,values in expected.items(): assert census[n]==values,(n,census[n])
    assert len(bodies)==meta['body_count'] and checked==meta['instruction_bytes']
    return census,len(bodies),checked


def compute():
    excerpts=[]
    for archive,specs in [(WHY,WSPECS),(OCAML,OSPECS)]:
        with tarfile.open(ROOT/archive) as t:
            members={m.name:m for m in t.getmembers() if m.isfile()}
            for suffix,a,b in specs:
                member=next(n for n in members if n.endswith('/'+suffix))
                raw=t.extractfile(member).read(); lines=raw.decode().splitlines(keepends=True)
                assert 1<=a<=b<=len(lines)
                excerpts.append({'archive':archive,'member':member,'member_identity':ident(raw),
                    'first':a,'last':b,'text':''.join(lines[a-1:b])})
    rows=[]
    for s,t,p,l,o,f in zip(*(read(n)['cases'] for n in
                            (STATE,TABLE,PUB,LOOKUP,OCC,FORMAT)),strict=True):
        assert s['case']==t['case']==p['case']==l['case']==o['case']==f['case']
        assert s['new_pid']==t['pid']==p['pid']==l['pid']==o['pid']==f['pid']
        q=t['usable_under_external_premises']; op=s['conditional_operational_transfer']
        occ=o['occurrences']; th=next(x for x in t['tables'] if x['table']=='th_state')
        look=l['under_named_existing_external_premises']['direct_lookup_bounds']
        assert q['A_stats_upper']==occ['A'] and q['A_xml_upper']==occ['Axml']
        assert op['gshape_add_calls']%3==0 and look['lookup_attempts_upper']%3==0
        inputs={k:occ[k] for k in ('F','Th','G','T','A','Axml')}
        inputs.update(P=q['private_prover_map_keys_upper'],B=q['private_stats_table_bindings_upper'],
            V=q['private_occurs_binding_visits_upper'],N=look['lookup_attempts_upper']//3,
            J=op['gshape_add_calls']//3,X=op['shape_append_bytes'],
            D=max(op['hyp_map_bindings_upper'],op['index_map_bindings_upper']),
            buffer_initial=s['captured_entry']['shape_buffer_capacity'],
            theory_capacity=th['capacity_upper'],theory_visits=th['binding_visits_per_invocation_upper'],
            W=p['publications_upper'])
        no=bounds(inputs); yes=bounds(inputs,{k:True for k in PREMISES})
        assert all(no['guards'].values())
        assert no['candidate']['frequency_table']['capacity_upper']==q['each_private_frequency_table_capacity_upper']
        assert no['candidate']['direct_requested_OCaml_bytes_by_disjoint_owner']['persistent_global_shape_map_nodes']==48*op['new_extmap_node_allocations_upper']
        assert min(1<<59,7+inputs['W'])==p['writer_bounds']['bucket_nodes_upper']
        for absent in PREMISES:
            pre={k:True for k in PREMISES if k!=absent}
            assert bounds(inputs,pre)['accounted_structural_requests_under_supplied_premises'] is None
            assert bounds(inputs,{**pre,absent:False})['accounted_structural_requests_under_supplied_premises'] is None
        bad={**inputs,'X':(1<<57)}
        assert bounds(bad,{k:True for k in PREMISES})['accounted_structural_requests_under_supplied_premises'] is None
        assert yes['shape_builder_residual_requested_bytes'] is None
        assert not yes['complete_nonformatter_save_allocation_established']
        formatter=f['under_named_existing_external_premises']['candidate']['direct_requested_bytes_interval_upper']
        rows.append({'case':s['case'],'pid':s['new_pid'],'inputs':inputs,
            'without_external_assertion':no,'under_named_existing_external_premises':yes,
            'accepted_formatter_and_file_direct_requested_bytes':formatter,
            'formatter_plus_accounted_structural_direct_requested_bytes':
                formatter+no['candidate']['accounted_direct_requested_OCaml_bytes_interval_upper'],
            'this_sum_excludes_shape_builder_residual_and_is_not_complete_save':True})
    # Deterministic threshold cases detect an off-by-one resize or backing charge.
    assert frequency_table(32)['capacities']==[16]
    assert frequency_table(33)['capacities']==[16,32]
    assert frequency_table(64)['capacities']==[16,32]
    assert frequency_table(65)['capacities']==[16,32,64]
    assert shape_backings(1088,1088)['new_capacities']==[]
    assert shape_backings(1089,1088)['new_capacities']==[2176]
    return {'inputs.json':{p:ident((ROOT/p).read_bytes()) for p in INPUTS},
        'source-witnesses.json':excerpts,
        'result.json':{'scope':'Scoped structural direct object requests, with exact pruned shape-builder residual',
            'one_global_save_and_exception_budget':True,'source_argument_machine_proved':False,
            'complete_nonformatter_save_allocation_established':False,
            'complete_save_capacity_established':False,'whole_pipeline_capacity_established':False,
            'cases':rows}}


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--freeze-native',action='store_true'); parser.add_argument('--write',action='store_true')
    args=parser.parse_args(); start=time.monotonic()
    if args.freeze_native: freeze_native()
    census,nb,ni=check_native(); values=compute(); values['native-allocation-sites.json']=census
    for name,value in values.items():
        path=HERE/name
        if args.write: path.write_text(json.dumps(value,indent=2)+'\n')
        else: assert json.loads(path.read_text())==value,name
    print(json.dumps({'status':'passed','elapsed_seconds':time.monotonic()-start,
        'cases':5,('json_generated' if args.write else 'json_comparisons'):len(values),
        'source_excerpts':len(values['source-witnesses.json']),
        'native_bodies':nb,'native_instruction_bytes':ni,'predecessor_checkers_replayed':0,
        'target_capture_disassembler_or_proof_runs':0}))


if __name__=='__main__': main()
