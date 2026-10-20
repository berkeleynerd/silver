#!/usr/bin/env python3
"""Focused retained-source/ELF closure join; no target or predecessor execution."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
from formatter import closure as formatter_closure

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
inputs = {}

def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())

def read(path):
    path = Path(path)
    raw = path.read_bytes()
    inputs[str(path.relative_to(REPO)) if path.is_relative_to(REPO) else str(path)] = identity(raw)
    return raw

def js(path):
    return json.loads(read(path))

def write(name, value):
    (HERE/name).write_text(json.dumps(value, indent=2, sort_keys=True)+'\n')

# Source-selected edges. Generic adapter entries below use this closed finite
# callback environment, not arbitrary closures of the same arity.
EXTRA = {
 'camlWhy3__Term__t_fold_6795':['caml_tuplify3','caml_tuplify4'],
 'caml_tuplify3':['camlWhy3__Term__t_open_bound_5946'],
 'caml_tuplify4':['camlWhy3__Term__t_open_quant_5970'],
 'camlWhy3__Term__t_attr_copy_5723':['camlWhy3__Extmap__is_empty_394','camlWhy3__Extmap__set_union_786'],
 'camlWhy3__Ident__id_clone_inner_6205':['camlWhy3__Extmap__set_union_786'],
 'camlWhy3__Term__t_open_quant_5970':['camlWhy3__Term__vs_rename_5924','camlWhy3__Term__fun_13793'],
 'camlWhy3__Termcode__aux_1081':['camlWhy3__Extmap__mem_417','camlWhy3__Termcode__collect_expls_927'],
 'camlStdlib__Option__equal_314':['camlWhy3__Ty__ty_equal_2001'],
 'camlWhy3__Extmap__fold2_inter_890':['camlWhy3__Term__add_nt_vars_5653'],
 'camlWhy3__Wstdlib__compare_1830':['camlWhy3__Wstdlib__tag_2176','camlWhy3__Ident__tag_370'],
 'camlWhy3__Wstdlib__tag_2176':['camlWhy3__Term__tag_475'],
 'camlStdlib__List__map_482':['camlWhy3__Term__t_subst_5864','camlWhy3__Term__fun_13787','camlWhy3__Term__fun_14088'],
 'camlWhy3__Extmap__map_467':['camlWhy3__Term__fun_14033','camlWhy3__Term__fun_13856'],
 'camlWhy3__Term__t_map_unsafe_5744':['camlWhy3__Term__t_subst_5864'],
}
APPLY2 = ['camlWhy3__Wstdlib__compare_1830','camlWhy3__Extmap__set_union_786',
 'camlWhy3__Extmap__mem_417','camlWhy3__Term__vs_rename_5924',
 'camlWhy3__Termcode__aux_1081','camlWhy3__Term__fun_13801',
 'camlWhy3__Term__fun_13808','camlWhy3__Lists__fun_582',
 'camlWhy3__Term__fun_13555','camlWhy3__Term__fun_13557',
 'camlWhy3__Ty__ty_equal_2001','caml_curry2','caml_curry2_1']
APPLY3 = ['camlWhy3__Extmap__fun_1812','camlWhy3__Extmap__fun_1822',
 'camlWhy3__Extmap__fun_1832','camlWhy3__Extmap__fun_1852',
 'camlWhy3__Term__fun_13836','caml_curry3','caml_curry3_1',
 'caml_curry3_1_app','caml_curry3_2','caml_curry2','caml_curry2_1']
EXTRA.update(caml_apply2=APPLY2, caml_apply3=APPLY3,
 caml_apply4=['camlWhy3__Term__add_nt_vars_5653'],
 caml_curry2_1=APPLY2[:-2]+['camlWhy3__Term__t_subst_unsafe_5896'],
 caml_curry3_1_app=APPLY3[:5], caml_curry3_2=APPLY3[:5])
# A local constructor-table jump is not an arbitrary indirect call.
SWITCH = {'camlWhy3__Term__t_similar_3086':'574c13',
 'camlWhy3__Term__t_map_unsafe_5744':'576e95',
 'camlWhy3__Term__t_subst_unsafe_5860':'577dc2',
 'camlWhy3__Term__t_vars_5634':'5765e2',
 'camlWhy3__Term__t_fold_6795':'57bece',
 'camlWhy3__Termcode__aux_1081':'7e959f'}
EXCLUDE = {
 'camlWhy3__Term__t_similar_3086':{
 'camlWhy3__Constant__compare_const_inner_1282':'Tconst is unchanged; t_attr_copy exits at physical equality.'},
 'camlWhy3__Term__t_vars_5634':{
 'camlStdlib__List__fold_left_521':'Only add_nt_vars variable images reach t_vars.',
 'camlWhy3__Term__add_t_vars_5635':'Only variable images.',
 'camlWhy3__Term__vars_union_5622':'Only variable images.'},
 'camlWhy3__Term__t_fold_6795':{
 'camlWhy3__Term__t_fold_unsafe_5774':'search_attrs selects let/forall only; no Tcase.',
 'camlWhy3__Term__brn_6807':'No Tcase in initial or opened terms.'},
 'camlWhy3__Term__t_map_unsafe_5744':{
 'camlWhy3__Term__bnd_map_5600':'t_subst intercepts let/eps/quant; no Tcase.',
 'camlWhy3__Term__bound_map_5737':'t_subst intercepts binders; no Tcase.',
 'camlWhy3__Term__tr_map_5591':'t_subst intercepts quant.',
 'camlWhy3__Term__fun_13900':'No Tcase.'},
}
ROOTS = ['camlWhy3__Termcode__goal_expl_task_1184',
 'camlWhy3__Term__t_open_bound_5946','camlWhy3__Term__t_open_quant_5970']
IMPORTS = ['camlWhy3__Termcode__collect_expls_927','camlWhy3__Termcode__concat_expls_995']
SERVICES = ['caml_call_gc','caml_raise_exn']

def source_witnesses():
    selections = {
      'why3/': ('retained-why-session-helper-source-20261019/sources.tar.gz', {
        'src/core/term.ml':[(30,40),(402,417),(588,675),(739,831),(1284,1294)],
        'src/core/ident.ml':[(75,226)],
        'src/core/task.ml':[(103,145)],
        'src/session/termcode.ml':[(20,98),(189,229),(535,545)],
        'src/util/extmap.ml':[(97,555)],
        'src/util/lists.ml':[(15,105)],
        'src/util/wstdlib.ml':[(13,18),(45,100)],
      }),
      'ocaml-8eb41f72ded84df884c3671734c947f612091f84/':
      ('retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz', {
        'stdlib/list.ml':[(45,125)], 'stdlib/option.ml':[(1,70)],
        'stdlib/format.ml':[(245,510),(520,675),(890,1038),(1249,1311),(1354,1400)],
        'stdlib/camlinternalFormat.ml':[(1380,1514),(1515,1605),(1665,1770),(1968,2005)],
        'stdlib/buffer.ml':[(1,185)],
        'stdlib/string.ml':[(100,170)], 'stdlib/bytes.ml':[(55,125)],
      }),
    }
    out=[]
    for prefix,(file,paths) in selections.items():
        archive=E/file
        read(archive)
        with tarfile.open(archive) as t:
            for path,ranges in paths.items():
                raw=t.extractfile(prefix+path).read()
                lines=raw.decode().splitlines(keepends=True)
                for first,last in ranges:
                    text=''.join(lines[first-1:last])
                    out.append(dict(archive=str(archive.relative_to(REPO)),member=prefix+path,
                        member_identity=identity(raw),first=first,last=min(last,len(lines)),
                        text=text,excerpt_identity=identity(text.encode())))
    write('source-witnesses.json',out)

def native():
    raw=read(DISASM)
    assert identity(raw)==dict(bytes=69046582,sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
    bodies={m[1]:m[0] for m in re.finditer(r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)',raw.decode(),re.M|re.S)}
    names={int(v.split()[0],16):n for n,v in bodies.items()}
    elf=read(ELF)
    assert identity(elf)==dict(bytes=24561432,sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
    h=struct.unpack_from('<16sHHIQQQIHHHHHH',elf)
    segments=[struct.unpack_from('<IIQQQQQQ',elf,h[5]+i*h[9]) for i in range(h[10])]
    def bytes_at(address,length):
        seg=next(s for s in segments if s[0]==1 and s[3]<=address and address+length<=s[3]+s[5])
        return elf[seg[2]+address-seg[3]:seg[2]+address-seg[3]+length]
    def created(v):
        entries,constants=set(),[]
        for a,n in re.findall(r'# ([0-9a-f]+) <([^>+]+)>',v):
            if n in bodies: entries.add(n)
            elif re.fullmatch(r'caml\w+__\d+',n):
                words=struct.unpack('<3Q',bytes_at(int(a,16),24))
                targets=[names[x] for x in words if x in names]
                if targets:
                    entries.update(targets)
                    constants.append(dict(address=a,symbol=n,words=list(words),code_entries=targets))
        return entries,constants
    todo=ROOTS[:];seen=set();front=set();rows={}
    while todo:
        n=todo.pop()
        if n in IMPORTS+SERVICES: front.add(n);continue
        if n in seen:continue
        assert n.startswith(('camlWhy3__','camlStdlib__','caml_apply','caml_curry','caml_tuplify')),n
        seen.add(n);v=bodies[n]
        direct=set(x.split('+')[0] for x in re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>',v))
        factories,constants=created(v)
        sites=re.findall(r'^\s*([0-9a-f]+):.*\b(?:call|jmp)\s+\*([^\n]+)',v,re.M)
        true_sites=[site for site in sites if site[0]!=SWITCH.get(n)]
        assert not true_sites or n in EXTRA,(n,true_sites)
        excluded=EXCLUDE.get(n,{})
        assert set(excluded)<=direct|factories,(n,excluded)
        selected=(direct|factories|set(EXTRA.get(n,[])))-set(excluded)
        rows[n]=dict(direct=sorted(direct),created_closure_entries=sorted(factories),
            static_closures=constants,indirect_sites=sites,local_constructor_switch=SWITCH.get(n),
            selected_indirect_targets=EXTRA.get(n,[]),source_excluded_targets=excluded,
            selected_successors=sorted(selected),
            source_context_note=('Tcase-only List.map b_subst branch excluded; List.map is separately reachable through argument/trigger maps.'
              if n=='camlWhy3__Term__t_subst_unsafe_5860' else None))
        todo+=list(selected-{n})
    assert front==set(IMPORTS+SERVICES),front
    assert set(EXTRA)<=seen
    fmt=formatter_closure(bodies,names,bytes_at,js(HERE/'formatter-spec.json'))
    fmt_seen=set(fmt['bodies'])
    write('formatter-call-closures.json',fmt)
    keep=sorted(seen|fmt_seen|{'camlWhy3__Term__entry','camlStdlib__Format__entry'})
    frames={};checked=0
    for n in keep:
        v=bodies[n];code=[]
        for line in v.splitlines()[1:]:
            m=re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)',line)
            if not m:
                assert not line.strip(),line
                continue
            address,bs=int(m[1],16),bytes.fromhex(m[2])
            assert bytes_at(address,len(bs))==bs,(n,address)
            checked+=len(bs)
            if m[3]:code.append(m[3])
        if n not in seen|fmt_seen:continue
        subs=re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp',v)
        pushes=re.findall(r'\bpush\s+[^\n]+',v)
        assert len(subs)<=1,(n,subs)
        assert len(pushes)%2==0,(n,pushes)
        if n in seen:assert len(pushes) in [0,2],(n,pushes)
        if subs: assert code[0]==f'sub    $0x{subs[0]},%rsp',n
        base=8+(int(subs[0],16) if subs else 0)
        frames[n]=dict(base_own_bytes=base,trap_bytes=8*len(pushes),
            own_high_water_upper=base+8*len(pushes),body_identity=identity(v.encode()))
    closures=[]
    for a,adapter,target,store in [(0xb49040,'caml_tuplify3','camlWhy3__Term__t_open_bound_5946','5824b7'),
                                  (0xb490a0,'caml_tuplify4','camlWhy3__Term__t_open_quant_5970','5824e1')]:
        words=struct.unpack('<3Q',bytes_at(a,24))
        assert names[words[0]]==adapter and names[words[2]]==target
        line=next(l for l in bodies['camlWhy3__Term__entry'].splitlines() if l.lstrip().startswith(store+':'))
        closures.append(dict(address=hex(a),words=list(words),adapter=adapter,target=target,module_store=line))
    arity_words=struct.unpack('<3Q',bytes_at(0xb48be8,24))
    assert names[arity_words[0]]=='caml_curry4'
    assert arity_words[1]==0x400000000000007
    assert names[arity_words[2]]=='camlWhy3__Term__add_nt_vars_5653'
    write('call-closures.json',dict(roots=ROOTS,bodies=sorted(seen),frontier=sorted(front),transfers=rows,
        public_opening_closures=closures,
        fold2_callback_closure=dict(address='0xb48be8',words=list(arity_words),raw_arity=4,
          target='camlWhy3__Term__add_nt_vars_5653',
          selected_application='caml_apply4 exact-arity branch; curry4 entry is not executed'),claim='Source-selected binder/explanation closure, to named imports and services.'))
    write('native-bodies.json',{n:bodies[n] for n in keep})
    write('native-frames.json',frames)
    return {n:frames[n] for n in seen},{n:frames[n] for n in fmt_seen},dict(bodies=len(keep),binder_closure_bodies=len(seen),formatter_closure_bodies=len(fmt_seen),checked_instruction_bytes=checked)

def bounds(frames,fmt_frames,native_facts):
    old=js(E/'retained-why-save-stack-composition-20261020/result.json')
    prior=js(E/'retained-why-save-stack-helper-closure-20261020/result.json')
    admin=E/'retained-why-save-stack-composition-20261020/administrative-inputs.json.gz'
    assert identity(read(admin))==dict(bytes=587126,sha256='a16911445bf252875473a5ca989c3c57a82b11a4621f4fcd9decfbf52f5cf30a')
    factors={}
    for n in frames:
        if n.startswith('camlWhy3__Extmap__'): f='3*(2*K+1)'
        elif n=='camlStdlib__List__map_482': f='(D+3)*(L+1)'
        elif n=='camlStdlib__List__fold_left_521': f='2*(D+2)'
        elif n.startswith(('caml_apply','caml_curry','caml_tuplify')): f='8*(D+2)*(L+1)+32'
        else: f='D+2'
        factors[n]=f
    fmt_factors={n:(68 if n=='camlStdlib__Format__output_acc_1688' else
         64 if n.startswith(('caml_apply','caml_curry')) else 4) for n in fmt_frames}
    F=sum(fmt_frames[n]['own_high_water_upper']*count for n,count in fmt_factors.items())
    # Import successful retained format/state transfers; do not replay them.
    acc=js(E/'retained-why-save-format-accumulator-20261020/result.json')
    assert acc['max_main_acc_nodes']==26 and acc['max_all_acc_nodes']==27
    assert acc['max_synchronously_nested_formatted_calls_per_save']==2
    assert acc['static_template_AST_construction_is_before_selected_interval']
    assert acc['selected_accumulator_construction_evaluation_argument_complete_under_named_relation']
    js(E/'retained-why-save-formatter-core-20261020/result.json')
    js(E/'retained-why-save-format-allocation-20261020/result.json')
    js(E/'retained-why-save-shape-builder-allocation-20261020/result.json')
    js(E/'retained-why-save-format-accumulator-20261020/template-census.json')
    js(E/'retained-why-session-shape-transfer-20261020/bounds.json')
    write('multiplicities.json',dict(binder_and_enclosing_search=factors,selected_formatter=fmt_factors,
        K='N+A+L+1',rationale='Source context induction in accompanying note; no unknown-frame maximum.'))
    out=[]
    for row,p in zip(old['cases'],prior['cases'],strict=True):
        assert row['case']==p['case'] and row['fresh_pid']==p['fresh_pid']
        # Read actual field names from frozen packet rather than reconstructing captures.
        transfer=row['binder_dynamic_transfer']
        D=transfer['constructor_depth_upper']
        N=transfer['opening_environment_cardinality_upper']
        L=transfer['child_and_binder_list_length_upper']
        A=p['explanation_attribute_union'];K=N+A+L+1
        expected={'put_line':(197,2773,7,195),'put':(197,2379,7,171),
          'first_or_default':(89,631,7,193),'is_message':(37,266,7,42),
          'input_is_valid':(39,281,7,44)}
        assert (D,N,L,A)==expected[row['case']]
        env=dict(D=D,N=N,L=L,A=A,K=K)
        subtotal=sum(frames[n]['own_high_water_upper']*eval(f,{'__builtins__':{}},env) for n,f in factors.items())
        X=p['explanation_helpers_complete_to_services_bytes']
        out.append(dict(case=row['case'],fresh_pid=row['fresh_pid'],logical_pid=row['logical_pid'],
            D=D,N=N,L=L,A=A,K=K,binder_and_enclosing_search_to_imports_bytes=subtotal,
            imported_collect_concat_bytes=X,complete_goal_explanation_or_opening_to_services_bytes=subtotal+X,
            selected_formatter_and_internal_name_constant_to_imports_bytes=F,
            complete_save_added_stack_upper=None))
    write('result.json',dict(cases=out,native=native_facts,
        goal_explanation_and_public_opening_closed_to_services=True,
        selected_formatter_and_internal_name_constant_closed_to_imports=True,
        selected_formatter_bytes=F,
        complete_save_stack_established=False,complete_save_added_stack_upper=None,
        target_runs=0,captures=0,new_disassembly_runs=0,solver_runs=0,predecessor_checker_replays=0,
        unresolved_tool_owned_instances=[
          'Imported serializer/identifier/shape caller and callback instances (separate author packet)',
          'Handler setter phase, exit and channel/callback owners outside dispatch-to-save shell (root packet)'],
        imported_dispatch_to_save_shell_bytes=816,
        handler_setter_phase_included_in_dispatch_shell=False,
        trusted_service_stack=None,preexisting_preparation_stack=None))
    write('inputs.json',inputs)
    print(json.dumps(dict(ok=True,native=native_facts,binder_bytes=[r['complete_goal_explanation_or_opening_to_services_bytes'] for r in out],formatter_bytes=F,complete_save_added_stack_upper=None)))

source_witnesses()
bounds(*native())
