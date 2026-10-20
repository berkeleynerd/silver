#!/usr/bin/env python3
"""Retained-input checks for the reviewed source/control argument, not its proof."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
E=HERE.parent
inputs={}
def ident(raw):return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def read(p):
    p=Path(p);raw=p.read_bytes()
    inputs[str(p.relative_to(REPO)) if p.is_relative_to(REPO) else str(p)]=ident(raw)
    return raw
def js(p):return json.loads(read(p))
def write(n,v):(HERE/n).write_text(json.dumps(v,indent=2,sort_keys=True)+'\n')

S=E/'retained-why-session-helper-source-20261019'
manifest=js(S/'source-identities.json')
archive=S/'sources.tar.gz'
assert ident(read(archive))==manifest['identity']
with tarfile.open(archive) as t:
    sources={m.name:t.extractfile(m).read() for m in t.getmembers() if m.isfile()}
for n,raw in sources.items():assert ident(raw)==manifest['members'][n]['identity']
why={n[5:]:v.decode() for n,v in sources.items() if n.startswith('why3/')}
assert len(why)==603

RANGES={
 'why3/src/util/debug.ml':[(11,85),(117,144),(146,218)],
 'why3/src/util/debug.mli':[(11,46),(79,109)],
 'why3/src/gnat/gnat_main.ml':[(264,292),(298,360)],
 'why3/src/gnat/gnat_config.ml':[(1,60),(214,269),(341,403),(654,693)],
 'why3/src/gnat/gnat_util.ml':[(1,24),(110,151)],
 'why3/src/driver/whyconf.ml':[(1136,1208)],
 'why3/src/core/trans.ml':[(14,22),(314,355)],
 'why3/src/core/trans.mli':[(177,187)],
 'why3/src/printer/smtv2.ml':[(20,30),(228,236)],
 'why3/src/printer/why3printer.ml':[(28,54)],
 'why3/src/core/pretty.ml':[(114,133),(170,178),(340,346)],
 'why3/src/mlw/expr.ml':[(1362,1372),(1424,1431)],
 'why3/src/mlw/vc.ml':[(22,34),(1714,1772)],
 'why3/src/mlw/pinterp.ml':[(18,28),(384,392)],
 'why3/src/driver/call_provers.ml':[(480,493)],
 'why3/src/transform/libencoding.ml':[(14,20)],
 'why3/src/transform/encoding.ml':[(105,113)],
 'why3/src/transform/discriminate.ml':[(454,460)],
 'why3/src/gnat/gnat_report.ml':[(221,234)],
 'why3/src/jessie/register.ml':[(23,28)],
 'ocaml/stdlib/format.ml':[(461,464),(863,882),(893,908),(925,1008),(1354,1367)],
 'ocaml/stdlib/buffer.ml':[(16,38)],
 'ocaml/stdlib/camlinternalFormat.ml':[(1784,1895)],
 'ocaml/stdlib/stdlib.ml':[(550,572)],
}
witness=[]
for n,ranges in RANGES.items():
    raw=sources[n];lines=raw.decode().splitlines(keepends=True)
    for lo,hi in ranges:
        assert hi<=len(lines),(n,hi,len(lines))
        witness.append(dict(archive=str(archive.relative_to(REPO)),member=n,
          member_identity=ident(raw),first_line=lo,last_line=hi,
          text=''.join(lines[lo-1:hi])))
write('source-witnesses.json',witness)

# Deliberately lexical inventory. The note classifies comments, definitions,
# exports, argument routes and caller ownership; this is not an OCaml analyser.
patterns={
 'flag_writers':r'\b(?:set_flag|unset_flag|toggle_flag|set_flags_selected)\b',
 'formatter_aliases':r'\b(?:get_debug_formatter|set_debug_formatter|escape_formatter|escape_buffer)\b',
 'direct_debug_transform':r'\b(?:create_debugging_trans|print_task_goal)\b',
 'flag_representation':r'\bflag_value\b',
 'stats_registration':r'Stats\.(?:register|register_int|print)\b',
 'environment_writers':r'\b(?:putenv|setenv|unsetenv)\b',
 'debug_option_clients':r'Debug\.Args|Whyconf\.Args|\bcomplete_initialization\b',
}
inventory={k:[dict(file=n,line=i,text=l) for n,s in sorted(why.items())
 for i,l in enumerate(s.splitlines(),1) if re.search(p,l)] for k,p in patterns.items()}
assert {x['file'] for x in inventory['flag_representation']}=={'src/util/debug.ml'}
assert not inventory['stats_registration']
assert {x['file'] for x in inventory['direct_debug_transform']}=={'src/core/trans.ml','src/core/trans.mli'}
assert {x['file'] for x in inventory['formatter_aliases']}=={
 'src/util/debug.ml','src/util/debug.mli','src/gnat/gnat_main.ml','src/core/trans.ml','src/printer/smtv2.ml'}
assert not any(re.search(r'\b(?:open|include)\s+Debug\b|\bmodule\s+\w+\s*=\s*Debug\b',s) for s in why.values())
write('source-client-inventory.json',inventory)

# Resolve every lexical dprintf first argument to its source registration name.
# Comments are retained too, which is an overapproximation of the sink census.
quoted=r'"(?:\\.|[^"\\])*"'
binding=re.compile(r'let\s+(\w+)\s*=\s*Debug\.(?:register_info_flag|register_flag|lookup_flag)\s+(?:~desc:'+quoted+r'\s+)?('+quoted+r')',re.S)
bindings={n:{m[1]:json.loads(m[2]) for m in binding.finditer(s)} for n,s in why.items()}
imports={
 ('plugins/cfg/cfg_main.ml','debug'):('plugins/cfg/cfg_paths.ml','debug'),
 ('plugins/cfg/cfg_main.ml','Cfg_paths.debug'):('plugins/cfg/cfg_paths.ml','debug'),
 ('src/gnat/gnat_main.ml','Check_ce.debug_check_ce_categorization'):('src/mlw/check_ce.ml','debug_check_ce_categorization'),
 ('src/gnat/gnat_main.ml','Check_ce.debug_check_ce_rac_results'):('src/mlw/check_ce.ml','debug_check_ce_rac_results'),
 ('src/mlw/pinterp.ml','debug_trace_exec'):('src/mlw/pinterp_core.ml','debug_trace_exec'),
 ('src/tools/why3extract.ml','Pdriver.debug'):('src/extract/pdriver.ml','debug'),
 ('src/core/trans.ml','f'):('src/transform/libencoding.ml','debug'),
}
# The only polymorphic flag-argument sink is Trans.print_meta. Its three clients
# all pass Libencoding.debug; independent review checks that source flow.
print_meta=[(n,i,l) for n,s in why.items() for i,l in enumerate(s.splitlines(),1) if 'Trans.print_meta' in l]
assert len(print_meta)==3 and all('Trans.print_meta Libencoding.debug' in l for n,i,l in print_meta)
potential_enabled={'vc_sp','rac:execute_no_builtin_mach','stats','print_attributes'}
sinks=[]
for n,s in sorted(why.items()):
    for m in re.finditer(r'Debug\.dprintf\s+([\w.]+)',s):
        arg=m[1];origin=imports.get((n,arg),(n,arg));name=bindings[origin[0]][origin[1]]
        assert name not in potential_enabled,(n,arg,name)
        sinks.append(dict(file=n,line=s.count('\n',0,m.start())+1,argument=arg,
          registration_name=name,binding_file=origin[0],binding_name=origin[1]))
write('flag-flow.json',dict(sink_count=len(sinks),sink_names=sorted({s['registration_name'] for s in sinks}),
 potential_enabled_names=sorted(potential_enabled),dprintf_sinks=sinks,
 generic_print_meta_clients=[dict(file=n,line=i,text=l) for n,i,l in print_meta],
 completeness_basis='Audited full selected source clients and typed/reflection relation; lexical checks alone are not a control proof.'))

# Read accepted prefix attachment; do not replay its observer or checker.
prefix=js(E/'retained-why-path-initial-state-20261020/prefix-attachment.json')
js(E/'retained-why-path-initial-state-20261020/result.json')
initial=js(E/'retained-why-exit-initial-values-20261020/result.json')
read(REPO/'docs/research/retained-why-path-initial-state.md')
read(REPO/'docs/research/retained-why-native-effect-completeness.md')
read(REPO/'docs/research/retained-why-inline-callback-closure.md')
cap=E/'retained-why-save-state-capture-20261020'
cap_manifest=js(cap/'capture-manifest.json')
archives={a['path']:a for a in cap_manifest['archives']}
attached=[]
for c in prefix:
    name='capture-'+c['case'].replace('_','-')+'.tar.gz';rec=archives[name]
    assert ident(read(cap/name))=={k:rec[k] for k in ['bytes','sha256']}
    with tarfile.open(cap/name) as t:
        members={}
        for suffix in ['/process.json','/exit-hook-roots.json']:
            names=[n for n in t.getnames() if n.endswith(suffix)];assert len(names)==1
            raw=t.extractfile(names[0]).read()
            member=next(m for m in rec['members'] if m['path']==names[0])
            assert ident(raw)=={k:member[k] for k in ['bytes','sha256']}
            members[suffix]=(names[0],ident(raw),json.loads(raw))
    p=members['/process.json'][2];ex=members['/exit-hook-roots.json'][2]
    assert (p['pid'],p['argv'],p['environment'])==(c['pid'],c['argv'],c['environment'])
    assert p['initial_threads']==1 and c['new_threads']==[] and c['same_images_as_native_initialization_argument']
    assert {'WHY3DEBUG','GNATWHY3LOG'}.isdisjoint(p['environment'])
    assert not any(x.startswith('--debug') or x in ['--standalone','--replay','--prepare-shared'] for x in p['argv'])
    assert p['argv'][p['argv'].index('--prover')+1]=='cvc5,z3,altergo'
    assert p['argv'][p['argv'].index('--proof')+1]=='per_check'
    assert p['argv'][p['argv'].index('--counterexample')+1]=='off'
    assert ex['complete'] and not ex['failures'] and not ex['unknown_closures']
    gates=[x['gate'] for x in ex['exit_chain'] if 'gate' in x]
    assert gates==c['exit_gate_raw_values']==[3,3]
    assert ex['statistic_values']['roots']==c['registered_statistics_roots']==[]
    old=next(x for x in initial['cases'] if x['case']==c['case'])
    assert old['exit_once_gates_raw']==gates and old['formatter_address']==ex['formatter_record']
    attached.append(dict(case=c['case'],pid=p['pid'],argv=p['argv'],environment=p['environment'],
      captured_formatter_address=ex['formatter_record'],exit_gate_raw_values=gates,
      registered_statistics_roots=[],prefix_attachment_reused=True,
      members={k:dict(member=v[0],identity=v[1]) for k,v in members.items()}))
assert len(attached)==5
write('input-attachment.json',attached)

DIS=Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF=Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
raw=read(DIS);assert ident(raw)==dict(bytes=69046582,sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
bodies={m[1]:m[0] for m in re.finditer(r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)',raw.decode(),re.M|re.S)}
elf=read(ELF);assert ident(elf)==dict(bytes=24561432,sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
h=struct.unpack_from('<16sHHIQQQIHHHHHH',elf)
segments=[struct.unpack_from('<IIQQQQQQ',elf,h[5]+i*h[9]) for i in range(h[10])]
def at(a,n):
    s=next(s for s in segments if s[0]==1 and s[3]<=a and a+n<=s[3]+s[5])
    return elf[s[2]+a-s[3]:s[2]+a-s[3]+n]
NATIVE=['camlGnat_main__entry','camlWhy3__Debug__gen_register_flag_873',
 'camlWhy3__Debug__set_debug_formatter_1396','camlWhy3__Debug__fun_2950',
 'camlWhy3__Debug__get_debug_formatter_1401','camlWhy3__Debug__dprintf_1404',
 'camlWhy3__Debug__fun_3069','camlWhy3__Debug__entry',
 'camlStdlib__Format__ifprintf_1776','camlStdlib__Format__formatter_of_buffer_1161',
 'camlStdlib__Format__fun_2444','camlStdlib__Format__fun_2447',
 'camlStdlib__Format__fun_2407','camlStdlib__Format__pp_get_formatter_out_functions_1100',
 'camlStdlib__Format__pp_set_formatter_out_functions_1091',
 'camlWhy3__Trans__print_task_goal_3135','camlWhy3__Trans__create_debugging_trans_3142',
 'camlWhy3__Trans__create_debugging_trans_inner_8377','camlWhy3__Trans__print_3152',
 'camlWhy3__Smtv2__debug_print_term_1644']
checked=0
for n in NATIVE:
    for l in bodies[n].splitlines()[1:]:
        m=re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)',l)
        if not m:assert not l.strip(),l;continue
        bs=bytes.fromhex(m[2]);assert at(int(m[1],16),len(bs))==bs
        checked+=len(bs)
wrapper=bodies['camlWhy3__Debug__fun_2950']
assert re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp',wrapper)==['8']
assert 'call   *%rdi' in wrapper and 'jmp    *%rdi' in wrapper
assert 'call   9e3e2c <caml_call_gc>' in wrapper
assert 'jmp    98b240 <camlStdlib__Format__ifprintf_1776>' in bodies['camlWhy3__Debug__dprintf_1404']
assert bodies['camlGnat_main__entry'].count('call   559bc0 <camlWhy3__Debug__set_debug_formatter_1396>')==2
outside_setter=[n for n,v in bodies.items() if not n.startswith('camlWhy3__Debug__') and
 re.search(r'\b(?:call|jmp)\s+[0-9a-f]+ <camlWhy3__Debug__set_debug_formatter_1396>',v)]
assert outside_setter==['camlGnat_main__entry']
absent=['camlGconfig__','camlWhy3ide__','camlDoc_main__','camlWhy3shell__','camlPy_main__','camlRegister__']
assert all(not any(n.startswith(p) for n in bodies) for p in absent)
write('native-bodies.json',{n:bodies[n] for n in NATIVE})
write('native-control.json',dict(native_bodies=len(NATIVE),checked_instruction_bytes=checked,
 external_direct_setter_callers=outside_setter,unselected_frontend_native_prefixes_absent=absent,
 wrapper=dict(body='camlWhy3__Debug__fun_2950',own_stack_bytes_upper=16,
 call_site='0x559c8d',call_target='camlStdlib__Format__fun_2407',
 tail_site='0x559ca7',tail_target='camlStdlib__Format__fun_2447',
 poll_service='caml_call_gc',captured_old_functions_record=True),
 native_census_not_arbitrary_alias_proof=True))

write('result.json',dict(
 kind='Source/control theorem under the existing named source/runtime/loader relation, with checked retained-input attachment.',
 cases=[x['case'] for x in attached],source_members_checked=len(sources),why_source_members=603,
 dprintf_sink_records=len(sinks),source_witnesses=len(witness),
 native_bodies=len(NATIVE),native_instruction_bytes_checked=checked,
 debug_formatter_is_escape_formatter_under_named_relation=True,
 constructor_state_preserved_at_cuts_under_named_relation=True,
 constructor_state_preserved_until_first_stats_entry_under_selected_continuation=True,
 arbitrary_global_formatter_freshness_claimed=False,
 initial_escape_buffer=dict(position=0,capacity=42,backing_equals_initial=True),
 initial_formatter=dict(queue_length=1,queue_token='Pp_begin(0,Pp_hovbox), unknown size, length 0',
  scan_stack_entries=2,scan_stack='system-box entry left_total=1 above sentinel text-empty entry left_total=-1',
  format_stack_entries=0,tbox_stack_entries=0,tag_stack_entries=0,mark_stack_entries=0,
  margin=78,min_space_left=10,max_indent=68,space_left=78,current_indent=0,is_new_line=True,
  left_total=1,right_total=1,curr_depth=1,max_boxes=2**62-1,ellipsis='.',print_tags=False,mark_tags=False),
 callbacks=dict(out_string='Buffer.add_substring escape_buffer',out_flush='ignore',
  out_newline='one Debug.fun_2950 wrapper: captured default display_newline, then captured ignore flush',
  out_spaces='display_blanks escape_formatter',out_indent='display_blanks escape_formatter',
  mark_open_tag='default_pp_mark_open_tag',mark_close_tag='default_pp_mark_close_tag',
  print_open_tag='ignore',print_close_tag='ignore'),
 newline_wrapper_depth=1,newline_wrapper_own_stack_bytes=16,
 added_to_prior_F_automatically=False,
 callback_and_setting_preservation_under_selected_continuation=True,
 after_partial_stats_constructor_freshness=False,
 first_stats_entry_may_occur_inside_signal_save_or_exception_route=True,
 earlier_signals_excluded=False,service_success_assumed_for_future=False,
 global_save_budget_upper=3,global_callback_opportunities_upper=2,
 assumptions=['Selected typed-source/native behavior relation and valid representations',
  'Accepted fixed-load/reflection/one-worker/native-owner capability relation reattached by the five prefix records',
  'Selected fresh Per_Check, CE-off, non-replay, built-in-prover continuation; no new interactive/plugin/configuration client'],
 remaining=['Stats traversal, partial queue/Buffer mutation and numeric/capacity bounds',
  'Exception/failure continuation and standard/error global formatter phases',
  'Full R, ambient A_pre and complete exit/save composition'],
 full_debug_formatter_graph_directly_observed=False,complete_exit_stack=False,
 complete_exit_capacity=False,complete_save_capacity=False,
 target_runs=0,new_captures=0,new_disassembly=0,predecessor_replays=0,source_fetches=0,
 semantic_theorem_proved_by_checker=False))
read(Path(__file__))
write('inputs.json',inputs)
print(json.dumps(dict(ok=True,source_members=len(sources),why_members=603,sinks=len(sinks),
 native_bodies=len(NATIVE),checked_instruction_bytes=checked,cases=5,
 conditional_constructor_state_preserved=True,newline_wrapper_own_bytes=16,
 complete_exit_capacity=False),sort_keys=True))
