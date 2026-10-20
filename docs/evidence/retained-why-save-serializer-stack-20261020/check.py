#!/usr/bin/env python3
"""Read-only retained source/ELF/arithmetic check. --write freezes local outputs.

No target/capture/disassembler/source-fetch/prover/predecessor checker is run.
The source-selected graph and multiplicity argument remain reviewed premises,
not a mechanized source-to-machine refinement proof.
"""
import argparse, hashlib, json, platform, re, struct, tarfile, time
from pathlib import Path
import interfaces as IF
import transfer
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
WRITE = argparse.ArgumentParser()
WRITE.add_argument('--write',action='store_true')
WRITE = WRITE.parse_args().write
start = time.monotonic()
inputs, outputs = {}, {}
def identity(raw): return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def read(p):
    p=Path(p); raw=p.read_bytes()
    inputs[str(p.relative_to(REPO)) if p.is_relative_to(REPO) else str(p)] = identity(raw)
    return raw
def js(p): return json.loads(read(p))
def out(name,data): outputs[name]=data
raw=read(DISASM)
assert identity(raw)==dict(bytes=69046582,sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
bodies={m[1]:m[0] for m in re.finditer(r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)',raw.decode(),re.M|re.S)}
elf=read(ELF)
assert identity(elf)==dict(bytes=24561432,sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
import json,re,struct
from pathlib import Path
b = bodies
e = elf
h=struct.unpack_from('<16sHHIQQQIHHHHHH',e);segs=[struct.unpack_from('<IIQQQQQQ',e,h[5]+i*h[9]) for i in range(h[10])]
def rd(a,n):
 s=next(s for s in segs if s[0]==1 and s[3]<=a and a+n<=s[3]+s[5]);return e[s[2]+a-s[3]:s[2]+a-s[3]+n]
addr={int(v.split(' ')[0],16):n for n,v in b.items()}
imports=set(['camlWhy3__Termcode__goal_expl_task_1184','camlWhy3__Task__used_theories_2572','camlWhy3__Task__used_symbols_2581','camlWhy3__Task__local_decls_2592','camlWhy3__Termcode__const_shape_2323','camlWhy3__Ident__sn_decode_2005','caml_tuplify3','caml_tuplify4'])
def imported(n):return n in imports or n.startswith(('camlStdlib__Format__','camlCamlinternalFormat'))
def tool(n):return n.startswith(('camlWhy3__','camlStdlib__','caml_apply','caml_curry','caml_tuplify','camlCamlinternalLazy__'))
exclude={'camlWhy3__Termcode__t_shape_task_2946':'SV6','camlWhy3__Termcode__ident_v4_2050':'SV6','camlWhy3__Termcode__br_shape_2370':'no Tcase'}
roots=['camlWhy3__Session_itp__save_session_4339']
# Source-bound static module / callback entries not constructed in the caller body.
semantic=['camlWhy3__Pp__html_string_1054','camlWhy3__Pp__space_762','camlWhy3__Session_itp__save_ident_4262','camlWhy3__Termcode__pp_sum_shape_version_1772','camlWhy3__Ident__same_3128','camlWhy3__Whyconf__compare_1159','camlWhy3__Whyconf__equal_1165','camlWhy3__Whyconf__hash_1169','camlWhy3__Wstdlib__compare_268','camlWhy3__Wstdlib__compare_1830','camlWhy3__Wstdlib__equal_271','camlWhy3__Wstdlib__equal_1382','camlWhy3__Wstdlib__equal_1826','camlWhy3__Wstdlib__hash_275','camlStdlib__Hashtbl__hash_1261','camlWhy3__Wstdlib__tag_2176','camlWhy3__Ident__tag_2120','camlStdlib__String__compare_594','camlStdlib__Hashtbl__hash_1177','camlStdlib__Ephemeron__hash_1334','camlStdlib__Ephemeron__equal_1252','camlStdlib__Ephemeron__get_data_1170','camlStdlib__Hashtbl__fun_1739','camlCamlinternalLazy__raise_undefined_269','caml_tuplify3','caml_tuplify4','camlWhy3__Termcode__const_shape_2323','camlWhy3__Ident__sn_decode_2005']
semantic += ['camlWhy3__Weakhtbl__hash_296','camlWhy3__Weakhtbl__equal_299','camlStdlib__Filename__is_dir_sep_473']
assert all(n in b for n in semantic)
seen=set();todo=roots+semantic;frontier=set();closures={}; rows={}
while todo:
 n=todo.pop()
 if n in seen or n in frontier:continue
 if imported(n) or not tool(n):frontier.add(n);continue
 if n in exclude:continue
 seen.add(n)
 refs=set(v.split('+')[0] for v in re.findall(r'<([^>]+)>',b[n]))
 static={}
 for a,s in re.findall(r'#\s*([0-9a-f]+) <([^>]+)>',b[n]):
  if s not in b and '+' not in s:
   a=int(a,16)
   header=struct.unpack('<Q',rd(a-8,8))[0]
   if header&255==247 and header>>10<128:
    ws=struct.unpack('<'+'Q'*(header>>10),rd(a,8*(header>>10)))
    code=[addr[x] for x in ws if x in addr]
    static[s]=dict(address=hex(a),words=[hex(x) for x in ws],code=code)
    refs.update(code)
 rows[n]=dict(refs=sorted(v for v in refs if v in b),static=static)
 todo.extend(v for v in refs if v in b and v not in exclude)
# Format roots supplied by the independently owned complete F interface.
frontier.update(IF.FORMAT_RETURNED+IF.FORMAT_SCALARS)
assert all(n in b for n in frontier)
# Every source-selected callback is a checked owned body or an imported root.
for n in IF.PRINTER_CALLBACKS:
    assert n in seen,n
for source,targets in (IF.CALLBACK_CONTEXTS|IF.INDIRECT).items():
    assert source in seen,source
    assert set(targets) <= seen|frontier,(source,set(targets)-seen-frontier)
# Static data words are compared to the ELF on every replay by the extraction
# above. Body bytes are checked separately, including dead branches retained.
adapter_targets=set()
for ts in list(IF.CALLBACK_CONTEXTS.values())+list(IF.INDIRECT.values()):
    adapter_targets.update(ts)
adapter_targets.update(['camlStdlib__Hashtbl__key_index_1028','camlStdlib__Hashtbl__key_index_1273'])
adapter_targets.update(n for n in seen if n.startswith('caml_curry'))
assert adapter_targets <= seen|frontier
checked=0; frames={}; closures={}; switches={}; application_sites=0; indirect_sites=0
for n in sorted(seen):
    body=b[n]; insns=[]
    for line in body.splitlines()[1:]:
        m=re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)',line)
        if not m:
            assert not line.strip(),line
            continue
        a,bs=int(m[1],16),bytes.fromhex(m[2])
        assert rd(a,len(bs))==bs,(n,hex(a)); checked+=len(bs)
        if m[3]:insns.append((m[1],m[3]))
    subs=re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp',body)
    pushes=re.findall(r'\bpush\s+[^\n]+',body)
    assert len(subs)<=1,(n,subs)
    if subs: assert insns[0][1]==f'sub    $0x{subs[0]},%rsp',n
    # Sum all syntactic trap pushes, even sequential handlers. This upper bound
    # deliberately exceeds the maximum simultaneously installed trap words.
    assert len(pushes)%2==0,(n,pushes)
    frames[n]=dict(prologue_reservation_bytes=sum(int(x,16) for x in subs),
       syntactic_trap_push_bytes=8*len(pushes), incoming_return_slot_bytes=8,
       own_bytes_upper=8+sum(int(x,16) for x in subs)+8*len(pushes),
       body_identity=identity(body.encode()))
    directs=[]; appl=[]
    for a,insn in insns:
        m=re.match(r'(call|jmp)\s+([0-9a-f]+) <([^>]+)>',insn)
        if not m:continue
        target=m[3].split('+')[0]
        classification='internal' if target==n else 'excluded' if target in exclude else 'owned' if target in seen else 'import' if imported(target) else 'runtime_service'
        assert target in seen|frontier|set(exclude),(n,target)
        directs.append(dict(site=a,operation=m[1],target=m[3],classification=classification))
        if target.startswith('caml_apply') and not n.startswith(('caml_apply','caml_curry')):
            assert n in IF.CALLBACK_CONTEXTS,(n,a)
            appl.append(dict(site=a,adapter=target,selected_context_targets=IF.CALLBACK_CONTEXTS[n]))
            application_sites+=1
    inds=[]
    for a,register in re.findall(r'^\s*([0-9a-f]+):.*\b(?:call|jmp)\s+\*([^\n]+)',body,re.M):
        indirect_sites+=1
        if n in IF.SWITCHES and a==IF.SWITCHES[n][0]:
            _,table,count=IF.SWITCHES[n]
            values=struct.unpack('<'+'i'*count,rd(table,4*count))
            targets=[table+v for v in values]
            lo=int(body.split(' ')[0],16);hi=max(int(x[0],16) for x in insns)
            assert all(lo<=v<=hi for v in targets),(n,targets)
            switches[n]=dict(site=a,table=hex(table),word_bytes=rd(table,4*count).hex(),targets=[hex(v) for v in targets])
            inds.append(dict(site=a,kind='same_body_variant_switch'))
        elif a in IF.OPENING_SITES:
            assert n=='camlWhy3__Termcode__t_shape_2345'
            inds.append(dict(site=a,kind='public_opening_import',targets=[IF.OPENING_SITES[a]]))
        elif n.startswith(('caml_apply','caml_curry')):
            inds.append(dict(site=a,kind='context_inherited_application_adapter',
                 selected_target_union=sorted(adapter_targets),
                 rule='Targets are the caller-site context plus its fixed curry construction/application stages; no arbitrary closure admitted.'))
        else:
            assert n in IF.INDIRECT,(n,a)
            inds.append(dict(site=a,kind='source_selected_callback',targets=IF.INDIRECT[n]))
    bridge_services = sorted(set(t for t in rows[n]['refs'] if t in frontier and not imported(t) and re.search(r'\b(?:lea|mov)\s+[^\n]*# [0-9a-f]+ <'+re.escape(t)+'>',body)))
    if any(c['target']=='caml_c_call' for c in directs): assert bridge_services,n
    closures[n]=dict(direct_transfers=directs,indirect_sites=inds,application_sites=appl,selected_c_bridge_primitive_targets=bridge_services,
       code_references=rows[n]['refs'],static_closure_data=rows[n]['static'])
# Source-side callback cases are exhaustive for the actual selected caller sites.
assert set(IF.CALLBACK_CONTEXTS)=={n for n,r in closures.items() if r['application_sites']}
assert set(IF.INDIRECT) <= {n for n,r in closures.items() if r['indirect_sites']}
# Exclude only named legacy/pattern branches, not their source callers or frames.
assert set(exclude)=={'camlWhy3__Termcode__t_shape_task_2946','camlWhy3__Termcode__ident_v4_2050','camlWhy3__Termcode__br_shape_2370'}
# Functional recursion outside finite forest/term/map/sort families would be new
# work. Assert it is absent, while tail backedges remain explicit in body bytes.
recursive_allowed={'camlWhy3__Termcode__t_shape_2345','camlWhy3__Extmap__add_397',
 'camlWhy3__Extmap__iter_460','camlWhy3__Extmap__fold_489',
 'camlStdlib__List__sort_831','camlStdlib__List__rev_sort_832'}
self_calls=[]
for n,r in closures.items():
    for call in r['direct_transfers']:
        if call['operation']=='call' and call['target']==n:
            assert n in recursive_allowed,(n,call)
            self_calls.append(dict(body=n,site=call['site']))
out('native-bodies.json',{n:b[n] for n in sorted(seen)})
out('native-frames.json',frames)
out('call-closures.json',dict(roots=roots,source_selected_module_and_callback_entries=semantic,
  imported_interfaces=sorted(n for n in frontier if imported(n)),
  service_frontier=sorted(n for n in frontier if not imported(n)),
  excluded_branches=exclude,source_selected_printer_callbacks=IF.PRINTER_CALLBACKS,
  closures=closures,internal_switches=switches,self_recursive_calls=self_calls))
# Retain relevant accepted control/input records without running their checkers.
for name in ['retained-why-save-table-contract-join-20261020/result.json',
 'retained-why-save-state-join-20261020/result.json',
 'retained-why-publication-composition-20261020/result.json',
 'retained-why-path-lookup-capacity-20261020/result.json']:
    js(E/name)
# Retained source witnesses; no network or source-fetch step.
source_selections={
 'src/session/session_itp.ml':[(11,15),(96,108),(146,183),(302,337),(371,388),(413,459),(748,767),(1939,2250)],
 'src/session/termcode.ml':[(240,276),(342,389),(412,506),(552,627)],
 'src/core/ident.ml':[(156,196),(224,290)],
 'src/core/theory.ml':[(470,492)],
 'src/driver/whyconf.ml':[(60,106)],
 'src/util/wstdlib.ml':[(13,98)],
 'src/util/weakhtbl.ml':[(59,96)],
 'src/util/extmap.ml':[(97,200),(216,249)],
 'src/util/exthtbl.ml':[(40,62)],
 'src/util/sysutil.ml':[(11,16),(124,140)],
 'src/util/pp.ml':[(17,42),(98,105),(214,230)],
 'src/session/compress_none.ml':[(1,80)],
}
ocaml_selections={'stdlib/hashtbl.ml':[(38,180),(180,196),(350,492),(500,560)],
 'stdlib/ephemeron.ml':[(241,268),(490,600)], 'stdlib/filename.ml':[(93,103),(279,296)],
 'stdlib/list.ml':[(45,125),(320,391)], 'stdlib/string.ml':[(45,90)],
 'stdlib/bytes.ml':[(55,105)],'stdlib/buffer.ml':[(77,109),(175,184)],
 'stdlib/stdlib.ml':[(300,320),(330,392)],'stdlib/random.ml':[(28,100)],
 'stdlib/camlinternalLazy.ml':[(19,45)],'stdlib/digest.ml':[(15,30)],'stdlib/obj.ml':[(120,165)]}
sources=[]
for archive,prefix,selections in [(E/'retained-why-session-helper-source-20261019/sources.tar.gz','why3/',source_selections),
 (E/'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz','ocaml-8eb41f72ded84df884c3671734c947f612091f84/',ocaml_selections)]:
    read(archive)
    with tarfile.open(archive) as stream:
        for path,ranges in selections.items():
            raw=stream.extractfile(prefix+path).read();lines=raw.decode().splitlines(keepends=True)
            for first,last in ranges:
                text=''.join(lines[first-1:last])
                sources.append(dict(archive=str(archive.relative_to(REPO)),member=prefix+path,
                   member_identity=identity(raw),first=first,last=min(last,len(lines)),text=text,
                   excerpt_identity=identity(text.encode())))
out('source-witnesses.json',sources)
sibling_dir=E/'retained-why-save-binder-formatter-stack-20261020'
sibling_result=js(sibling_dir/'result.json')
assert inputs[str((sibling_dir/'result.json').relative_to(REPO))] == dict(bytes=3380,sha256='cca726643bb9a8a45aa8f02058e7e362bb365f31193347d0b0e83a93606d3ff8')
sibling_binder=js(sibling_dir/'call-closures.json')
sibling_format=js(sibling_dir/'formatter-call-closures.json')
helper_closure=js(E/'retained-why-save-stack-helper-closure-20261020/call-closures.json')
provided=set(sibling_binder['bodies'])|set(sibling_format['bodies'])|set(helper_closure['task']['bodies'])
assert {n for n in frontier if imported(n)} <= provided
assert set(sibling_format['imports']) == set(IF.PRINTER_CALLBACKS)|{'camlWhy3__Termcode__check_2028'}
assert set(sibling_format['imports']) <= seen
sibling_by_case={r['case']:r for r in sibling_result['cases']}
out('import-interfaces.json',dict(binder_formatter_original_freeze='562b9a1d8d18da46e9017c9d49c097d1d9bf64f5',
   binder_formatter_result_identity=inputs[str((sibling_dir/'result.json').relative_to(REPO))],
   all_our_imports_provided_by_frozen_packets=True,
   all_formatter_callbacks_provided_here=True,
   imported_G_already_contains_collect_concat_X=True,
   imported_F_already_contains_const_shape_and_sn_decode=True,
   multiplicity='S, T, G and F each once per active save; shared symbols are disjoint call instances.',
   parent_composition_expression='r*(S+T+G+F)+r*4104+e*816 plus separately owned handler/exit/callback demand and R',
   parent_complete_save_stack_upper=None))
old=js(E/'retained-why-save-stack-composition-20261020/result.json')
shape={r['case']:r for r in js(E/'retained-why-save-shape-builder-allocation-20261020/result.json')['cases']}
structural={r['case']:r for r in js(E/'retained-why-save-structural-allocation-20261020/result.json')['cases']}
control={r['case']:r for r in js(E/'retained-why-save-printer-control-20261020/result.json')['cases']}
helpers={r['case']:r for r in js(E/'retained-why-save-stack-helper-closure-20261020/result.json')['cases']}
fs=transfer.factors(seen);out('multiplicities.json',fs)
cases=[]
for row in old['cases']:
    case=row['case'];sh=shape[case]['inputs'];st=structural[case]['inputs'];co=control[case]
    assert row['fresh_pid']==shape[case]['pid']==structural[case]['pid']==co['pid']==sibling_by_case[case]['fresh_pid']
    assert co['P']==sh['P']==row['max_task_opened_term_occurrences']
    assert co['under_named_existing_external_premises']['first_replace_no_resize_and_reused_printer_valid_under_supplied_premises']
    env=dict(row['forest'],D=row['binder_dynamic_transfer']['constructor_depth_upper'],
             K=row['dictionary_bindings_all_saves_upper'],P=sh['P'],A=sh['A'],V=st['V'],
             S=st['Axml']+st['T'])
    env.pop('Args')
    val=transfer.evaluate(frames,fs,env)
    cases.append(dict(case=case,fresh_pid=row['fresh_pid'],logical_pid=row['logical_pid'],**val,
      task_selection_import_T_bytes=helpers[case]['task_selection_complete_to_services_bytes'],
      goal_explanation_and_opening_import_G_bytes=sibling_by_case[case]['complete_goal_explanation_or_opening_to_services_bytes'],
      formatter_name_constant_import_F_bytes=sibling_by_case[case]['selected_formatter_and_internal_name_constant_to_imports_bytes'],
      printer_binding_bound=co['under_named_existing_external_premises']['candidate']['each_table_binding_and_scalar_size_upper'],
      complete_save_stack_upper=None,preexisting_stack=None,trusted_runtime_service_stack=None,
      complete_owned_serializer_shape_printer_to_imports_under_premises=True))
out('result.json',dict(scope='Complete save_session owned callers, serializer, Shape traversal and private printer to exact imported roots and runtime services',
    native=dict(bodies=len(seen),checked_instruction_bytes=checked,application_sites=application_sites,indirect_sites=indirect_sites),
    cases=cases,remaining_save_entry_tool_roots=['T: task selection','G: complete goal explanation and public binder openings','F: selected Format/name-decoder/constant closures'],
    handler_setter_exit_and_other_callback_owners_not_in_save_entry_scope=True,
    complete_save_capacity_established=False,source_machine_refinement_proved=False,
    captures=0,native_target_runs=0,new_disassembly_runs=0,predecessor_checker_replays=0,solver_runs=0))
for p in [HERE/'interfaces.py',HERE/'transfer.py']:
    read(p)
out('inputs.json',inputs)
for name,data in outputs.items():
    if WRITE:(HERE/name).write_text(json.dumps(data,indent=2,sort_keys=True)+'\n')
    else:assert json.loads((HERE/name).read_text())==data,name
summary=dict(ok=True,platform=platform.system()+' '+platform.machine(),cases=len(cases),
    native=outputs['result.json']['native'],source_excerpts=len(sources),
    owned_complete_to_imports_bytes=[r['owned_complete_to_imports_bytes'] for r in cases],
    mode='write' if WRITE else 'compare',elapsed_seconds=time.monotonic()-start)
if WRITE:(HERE/'check-result.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n')
print(json.dumps(summary,sort_keys=True))
