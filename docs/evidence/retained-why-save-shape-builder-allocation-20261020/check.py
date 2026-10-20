#!/usr/bin/env python3
"""Read-only retained-input/source/ELF reconciliation; no target or old checker."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import bounds, PREMISES, map_request, table_requests, decoder_requests

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
SHAPE = 'docs/evidence/retained-why-session-shape-transfer-20261020/bounds.json'
STATE = 'docs/evidence/retained-why-save-state-join-20261020/result.json'
REG = 'docs/evidence/retained-why-initial-registration-bound-20261020/result.json'
STRUCT = 'docs/evidence/retained-why-save-structural-allocation-20261020/result.json'
STACK = 'docs/evidence/retained-why-save-stack-composition-20261020/'
STACK_FILES = [STACK + n for n in ('administrative-inputs.json.gz',
    'administrative-summary.json','result.json','source-witnesses.json')]
INPUTS = [WHY,OCAML,SHAPE,STATE,REG,STRUCT,
    'docs/evidence/retained-why-save-format-allocation-20261020/transfer.py',
    'docs/evidence/retained-why-save-format-allocation-20261020/native-witnesses.json',
    'docs/evidence/retained-why-save-format-allocation-20261020/native-bodies.json',
    'docs/evidence/retained-why-save-structural-allocation-20261020/native-witnesses.json',
    'docs/evidence/retained-why-interval-native-effects-20261019/caml_z.c',
    'docs/evidence/retained-why-interval-native-effects-20261019/z.ml',
    *['docs/research/'+n+'.md' for n in (
        'retained-why-session-shape-transfer','retained-why-save-format-allocation',
        'retained-why-save-structural-allocation','retained-why-initial-registration-bound',
        'retained-why-save-state-join','retained-why-save-table-contract-join')]]
WSPECS = [('src/session/termcode.ml',34,100),('src/session/termcode.ml',220,228),
    ('src/session/termcode.ml',340,506),('src/session/termcode.ml',601,628),
    ('src/core/ident.mli',64,78),('src/core/ident.ml',91,152),
    ('src/core/ident.ml',158,215),('src/core/ident.ml',225,290),
    ('src/core/task.ml',65,113),('src/core/task.ml',122,142),
    ('src/core/task.ml',225,276),('src/core/theory.ml',180,192),
    ('src/core/theory.ml',323,339),('src/core/term.ml',25,42),
    ('src/core/ty.ml',74,79),('src/core/ty.ml',294,302),
    ('src/core/term.ml',395,413),('src/core/term.ml',588,678),
    ('src/core/term.ml',739,831),('src/core/term.ml',1284,1296),
    ('src/util/extmap.ml',98,170),('src/util/extmap.ml',183,239),
    ('src/util/extmap.ml',254,345),('src/util/extmap.ml',366,413),
    ('src/util/extmap.ml',439,496),('src/util/extmap.ml',499,567),
    ('src/util/extset.ml',18,112),('src/util/hcpt.ml',310,360),
    ('src/util/hcpt.ml',529,547),('src/util/lists.ml',21,32),
    ('src/util/strings.ml',59,75)]
OSPECS = [('stdlib/hashtbl.ml',20,83),('stdlib/hashtbl.ml',113,153),
    ('stdlib/hashtbl.ml',351,365),('stdlib/hashtbl.ml',580,611),
    ('stdlib/format.ml',992,1007),('stdlib/format.ml',1375,1399),
    ('stdlib/option.ml',29,33),
    ('stdlib/list.ml',55,105),('stdlib/string.ml',40,74)]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')


def identity(raw):
    return {'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}


def read(path, root=ROOT):
    return json.loads((root/path).read_text())


def selected_names(all_bodies):
    names = set()
    # Retained helper ranges include a few unselected constructors/arms; the
    # source-selected argument, not an unconditional reachability claim, prunes
    # those arms. Functor factories and module initialization are excluded.
    ranges = {'Ident':[(1559,2022),(2922,3217)],
        'Task':[(2058,2058),(2077,2086),(2553,2602)],
        'Term':[(1409,1409),(3086,3086),(5591,5970),(6795,6795)],
        'Extmap':[(351,896)], 'Extset':[(520,625)],
        'Termcode':[(638,1184),(1745,1745),(2028,2135),(2323,2370)],
        'Hcpt':[(908,908),(947,947),(1265,1265),(1312,1312)]}
    for name in all_bodies:
        m = re.fullmatch(r'camlWhy3__([A-Za-z0-9]+)__.*_(\d+)',name)
        if m and any(lo<=int(m[2])<=hi for lo,hi in ranges.get(m[1],[])):
            names.add(name)
    explicit = {
        'Ident':['fun_6183','id_clone_inner_6205','create_ident_printer_inner_6267',
                 'id_unique_inner_6286'],
        'Lists':['rev_map_fold_left_277','map_fold_left_353','equal_371'],
        'Strings':['remove_prefix_576'],
        'Ty':['ty_equal_2001','oty_equal_3386'],
        'Weakhtbl':['create_tag_282'],
    }
    names |= {'camlWhy3__'+p+'__'+n for p,ns in explicit.items() for n in ns}
    other = {'caml_curry2','caml_curry3','caml_apply2','caml_apply3','caml_apply4',
        'camlStdlib__$5e_141','camlZ__fun_1785','ml_z_format',
        'camlStdlib__Option__equal_314'}
    other |= {'camlStdlib__List__'+n for n in ('map_482','iter_507','fold_left_521','rev_append_308')}
    # Resolve version-specific library labels by stable function prefix.
    for pref in ('camlStdlib__String__concat_', 'camlStdlib__Bytes__sub_',
        'camlStdlib__Bytes__make_', 'camlStdlib__String__index_from_',
        'camlStdlib__Hashtbl__create_inner_', 'camlStdlib__Hashtbl__resize_',
        'camlStdlib__Hashtbl__insert_all_buckets_', 'camlStdlib__Hashtbl__insert_bucket_',
        'camlStdlib__Hashtbl__replace_', 'camlStdlib__Hashtbl__replace_bucket_',
        'camlStdlib__Hashtbl__find_', 'camlStdlib__Hashtbl__find_rec_',
        'camlStdlib__Hashtbl__mem_', 'camlStdlib__Hashtbl__key_index_',
        'camlStdlib__Int__to_string_'):
        other |= {n for n in all_bodies if n.startswith(pref)}
    names |= other
    assert names <= all_bodies.keys(), names-all_bodies.keys()
    # Include local closure bodies referenced by these witnesses. No arbitrary
    # callee recursion or unused type/pattern/constant-compare graph expansion.
    while True:
        fresh = {n for root in names for n in re.findall(r'<([^>+]+)(?:\+[^>]+)?>',all_bodies[root])
            if n in all_bodies and re.match(r'camlWhy3__(?:Ident|Task|Term|Termcode|Extmap|Extset|Hcpt|Lists)__fun_',n)}
        if fresh <= names:
            break
        names |= fresh
    return names


def freeze_native():
    prior = read('docs/evidence/retained-why-save-structural-allocation-20261020/native-witnesses.json')
    raw = Path(prior['existing_disassembly']['path']).read_bytes()
    assert identity(raw) == {k:prior['existing_disassembly'][k] for k in ('bytes','sha256')}
    bodies = {n:b for b,n in re.findall(
        r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)',raw.decode(),re.S)}
    chosen = {n:bodies[n] for n in sorted(selected_names(bodies))}
    count = sum(len(bytes.fromhex(m[2])) for b in chosen.values()
                for line in b.splitlines() if (m:=INSN.match(line)))
    write('native-bodies.json',chosen)
    write('native-witnesses.json',{
        'executable':prior['executable'],'existing_disassembly':prior['existing_disassembly'],
        'body_count':len(chosen),'instruction_bytes':count,
        'new_disassembler_or_target_execution':False,
        'source_native_refinement_machine_proved':False})


def check_native():
    meta = read(str((HERE/'native-witnesses.json').relative_to(ROOT)))
    binary = Path(meta['executable']['path']).read_bytes()
    assert identity(binary) == meta['executable']['identity']
    assert binary[:6] == b'\x7fELF\x02\x01'
    off = struct.unpack_from('<Q',binary,32)[0]
    size,count = struct.unpack_from('<HH',binary,54)
    loads=[]
    for i in range(count):
        kind,flags,p,addr,_,n,_,_ = struct.unpack_from('<IIQQQQQQ',binary,off+i*size)
        if kind==1 and flags&1: loads.append((addr,addr+n,p))
    bodies=read(str((HERE/'native-bodies.json').relative_to(ROOT)))
    assert set(bodies)==selected_names(bodies)
    checked=0; census={}; refs={}
    for name,body in bodies.items():
        assert re.match(r'[0-9a-f]+ <'+re.escape(name)+r'>:',body)
        for line in body.splitlines():
            if not (m:=INSN.match(line)): continue
            addr,raw=int(m[1],16),bytes.fromhex(m[2])
            assert any(lo<=addr and addr+len(raw)<=hi and binary[p+addr-lo:p+addr-lo+len(raw)]==raw
                for lo,hi,p in loads),name
            checked+=len(raw)
        census[name]=[int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15',body)]
        refs[name]=sorted(set(re.findall(r'<([^>+]+)(?:\+[^>]+)?>',body))-{name})
    expected = {
        'camlWhy3__Extmap__map_467':[48], 'camlWhy3__Extmap__split_557':[48,32,32],
        'camlWhy3__Extmap__disjoint_772':[48,48],
        'camlWhy3__Extmap__cons_enum_643':[40], 'camlWhy3__Extmap__fold2_inter_890':[56],
        'camlWhy3__Ident__find_unique_3105':[136],
        'camlWhy3__Ident__create_ident_printer_inner_6267':[40,40],
        'camlWhy3__Ident__fun_6183':[40], 'camlWhy3__Ident__id_clone_inner_6205':[32],
        'camlWhy3__Task__dict_2584':[32], 'camlWhy3__Task__join_2588':[48],
        'camlWhy3__Task__local_decls_2592':[48], 'camlWhy3__Task__filter_2602':[24],
        'camlWhy3__Hcpt__min_binding_947':[24], 'camlWhy3__Hcpt__exists_908':[],
        'camlWhy3__Hcpt__exists_1265':[40],
        'camlWhy3__Term__t_subst_unsafe_5860':[80,24,24,16,40,24],
        'camlWhy3__Term__bv_subst_unsafe_5861':[40,24],
        'camlWhy3__Term__t_attr_copy_5723':[40],
        'camlWhy3__Term__t_open_quant_5970':[40,32],
        'camlWhy3__Termcode__goal_expl_task_1184':[32],
        'camlWhy3__Termcode__t_shape_2345':[64,64,32],
        'camlWhy3__Termcode__const_v2_1745':[],
    }
    for n,v in expected.items(): assert census[n]==v,(n,census[n])
    assert max(sum(v) for n,v in census.items() if n.startswith('camlWhy3__')) <= 4096
    assert len(bodies)==meta['body_count'] and checked==meta['instruction_bytes']
    return census,refs,len(bodies),checked


def source_witnesses():
    values=[]
    for archive,specs in ((WHY,WSPECS),(OCAML,OSPECS)):
        with tarfile.open(ROOT/archive) as t:
            members={m.name:m for m in t.getmembers() if m.isfile()}
            for suffix,a,b in specs:
                member=next(n for n in members if n.endswith('/'+suffix))
                raw=t.extractfile(member).read(); lines=raw.decode().splitlines(keepends=True)
                assert 1<=a<=b<=len(lines)
                values.append({'archive':archive,'member':member,'member_identity':identity(raw),
                    'first':a,'last':b,'text':''.join(lines[a-1:b])})
    p='docs/evidence/retained-why-interval-native-effects-20261019/caml_z.c'
    raw=(ROOT/p).read_bytes(); lines=raw.decode().splitlines(keepends=True)
    for a,b in ((351,357),(989,1092)):
        values.append({'file':p,'identity':identity(raw),'first':a,'last':b,'text':''.join(lines[a-1:b])})
    return values


def compute(stack_root):
    inputs={p:identity((ROOT/p).read_bytes()) for p in INPUTS}
    inputs.update({p:identity((stack_root/p).read_bytes()) for p in STACK_FILES})
    assert inputs[STACK+'administrative-inputs.json.gz']['sha256']=='a16911445bf252875473a5ca989c3c57a82b11a4621f4fcd9decfbf52f5cf30a'
    assert inputs[STACK+'result.json']['sha256']=='ceb45afe9251a8cb3d86cdc794d2717f27c28718ed23c7a661d4e8b989e5bc13'
    rows=[]
    for sh,st,reg,adm,old in zip(read(SHAPE),read(STATE)['cases'],read(REG)['cases'],
            read(STACK+'administrative-summary.json',stack_root),read(STRUCT)['cases'],strict=True):
        case=sh['case']; assert case==st['case']==reg['case']==adm['case']==old['case']
        assert reg['pid']==st['new_pid']==old['pid']
        atompath='docs/evidence/retained-why-fixed-session-atoms-20261020/'+case.replace('_','-')+'-atoms.json.gz'
        raw=(ROOT/atompath).read_bytes(); inputs[atompath]=identity(raw)
        atoms=json.loads(gzip.decompress(raw)); cert=atoms['saved_occurrence_certificate']
        assert atoms['typed_graph_complete'] and atoms['max_case_pattern_occurrences']==0
        assert adm['initial_substitution_values_are_variables']
        assert adm['all_substitution_values_in_accepted_typed_closure']
        ts=list(sh['task_bounds'].values()); dy=adm['dynamic_transfer']
        assert set(sh['task_bounds'])==set(cert['tasks'])
        for task,t in sh['task_bounds'].items():
            assert t['P']==t['T']==atoms['imported_shape_term_visits_per_task'][task] and t['Q']==0
            assert cert['formulas'][str(cert['tasks'][task]['goal_formula'])]['opened_term_occurrences']<=t['P']
        v={'G':sh['G'],'J':sh['J'],'P':max(t['P'] for t in ts),'A':max(t['A'] for t in ts),
            'M':max(t['original_name_bytes_upper'] for t in ts),
            'Cbytes':max(t['constant_bytes_upper'] for t in ts),
            'Cchain':max(t['chain_length'] for t in cert['tasks'].values()),
            'I':reg['initial_registration_count'],
            'B':adm['max_stored_administrative_term_mass'],
            'N':dy['opening_environment_cardinality_upper'],
            'U':sh['explanation']['attribute_union_count'],
            'Ubytes':sh['explanation']['attribute_union_bytes'],
            'L':dy['child_and_binder_list_length_upper'],
            'E':st['conditional_operational_transfer']['explanation_bytes_per_insertion']}
        no=bounds(v); yes=bounds(v,{k:True for k in PREMISES})
        assert all(no['guards'].values()),(case,no['guards'])
        assert no['pruned_shape_builder_direct_requests_under_supplied_premises'] is None
        assert yes['complete_pruned_shape_builder_direct_request_accounting_under_supplied_premises']
        for absent in PREMISES:
            p={k:True for k in PREMISES if k!=absent}
            assert bounds(v,p)['pruned_shape_builder_direct_requests_under_supplied_premises'] is None
            assert bounds(v,{**p,absent:False})['pruned_shape_builder_direct_requests_under_supplied_premises'] is None
        assert bounds({**v,'M':1<<58},{k:True for k in PREMISES})['pruned_shape_builder_direct_requests_under_supplied_premises'] is None
        prev=old['without_external_assertion']['candidate']['accounted_direct_requested_OCaml_bytes_interval_upper']
        fmt=old['accepted_formatter_and_file_direct_requested_bytes']
        rows.append({'case':case,'pid':reg['pid'],'inputs':v,
            'without_external_assertion':no,'under_named_existing_external_premises':yes,
            'round36_structural_subtotal':prev,'accepted_formatter_subtotal':fmt,
            'joined_direct_save_caller_object_bytes_upper':prev+fmt+yes['candidate']['direct_requested_bytes_interval_upper'],
            'joined_total_excludes_failed_service_and_runtime_internals':True})
    assert table_requests(4096)['capacity_upper']==2048
    assert table_requests(4097)['capacity_upper']==4096
    assert table_requests(8192)['capacity_upper']==4096
    assert table_requests(8193)['capacity_upper']==8192
    assert map_request(0,0)==4096 and map_request(3,4)==map_request(4,3)
    assert decoder_requests(0)['output_bytes_upper']==16
    return {'inputs.json':inputs,'source-witnesses.json':source_witnesses(),
        'result.json':{'scope':'Six pruned shape-builder direct request families, conditional on named behavior premises',
            'one_global_save_and_exception_budget':True,'new_raw_administrative_extraction':False,
            'source_argument_machine_proved':False,'complete_save_capacity_established':False,
            'whole_pipeline_capacity_established':False,'cases':rows}}


def write(name,obj):
    (HERE/name).write_text(json.dumps(obj,indent=2,sort_keys=True)+'\n')


def main():
    p=argparse.ArgumentParser(); p.add_argument('--stack-root',type=Path,default=ROOT)
    p.add_argument('--freeze-native',action='store_true'); p.add_argument('--write',action='store_true')
    args=p.parse_args(); start=time.monotonic()
    if args.freeze_native: freeze_native()
    census,refs,nb,ni=check_native(); outputs=compute(args.stack_root)
    outputs['native-allocation-sites.json']=census
    outputs['native-symbol-references.json']=refs
    for name,obj in outputs.items():
        if args.write: write(name,obj)
        else: assert read(str((HERE/name).relative_to(ROOT)))==obj,name
    result={'status':'passed','cases':len(outputs['result.json']['cases']),
        'source_excerpts':len(outputs['source-witnesses.json']),'native_bodies':nb,
        'native_instruction_bytes':ni,'target_or_proof_or_predecessor_replays':0,
        'elapsed_seconds':time.monotonic()-start}
    if args.write: write('check-result.json',result)
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__': main()
