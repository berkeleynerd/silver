#!/usr/bin/env python3
"""Focused new local-site/finite-traversal check; no predecessor main."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import platform
import re
import struct
import tarfile
import time
import sys
sys.dont_write_bytecode=True
from local import Demand,create_cty,c_app,b,k
from freeze import INSN,elf_symbols

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
counts=Counter()


def check(ok,name):
    if not ok:raise AssertionError(name)
    counts[name]+=1


def sha(data):return hashlib.sha256(data).hexdigest()
def read(name):return json.loads((HERE/name).read_text())
def write(name,data):(HERE/name).write_text(json.dumps(data,indent=2)+'\n')


def inputs():
    for p in read('inputs.json')['providers']:
        check(sha((ROOT/p['path']).read_bytes())==p['sha256'],'frozen provider identity')
    for a in read('source-witnesses.json'):
        check(sha((ROOT/a['path']).read_bytes())==a['sha256'],'source archive identity')
        with tarfile.open(ROOT/a['path']) as t:
            for f in a['files']:
                raw=t.extractfile(f['path']).read()
                check(sha(raw)==f['sha256'],'complete source identity')
                lines=raw.decode().splitlines()
                for s in f['spans']:
                    code='\n'.join(lines[s['first']-1:s['last']])+'\n'
                    check(code==s['source'] and sha(code.encode())==s['sha256'],'source span and excerpt identity')


def native():
    w=read('native-witnesses.json');binary=Path(w['executable']['path']).read_bytes()
    check(sha(binary)==w['executable']['identity']['sha256'],'retained Linux ELF identity')
    dis=Path(w['existing_disassembly']['path']).read_bytes()
    check(sha(dis)==w['existing_disassembly']['sha256'],'retained disassembly identity')
    bodies=read('native-bodies.json')
    check(set(bodies)==set(w['local_bodies'])|set(w['adapter_bodies']),'finite native body inventory')
    off=struct.unpack_from('<Q',binary,32)[0];size,n=struct.unpack_from('<HH',binary,54)
    loads=[]
    for i in range(n):
        kind,flags,p,addr,_,length,_,_=struct.unpack_from('<IIQQQQQQ',binary,off+i*size)
        if kind==1 and flags&1:loads.append((addr,addr+length,p))
    census={};total=0
    for name,body in bodies.items():
        ok=True;size=0
        for line in body.splitlines():
            if not (m:=INSN.match(line)):continue
            addr=int(m[1],16);raw=bytes.fromhex(m[2]);size+=len(raw)
            ok &= any(lo<=addr and addr+len(raw)<=hi and binary[p+addr-lo:p+addr-lo+len(raw)]==raw for lo,hi,p in loads)
        check(ok and size>0,'native body bytes match executable')
        total+=size
        heap=[int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15',body)]
        stack=[int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%rsp',body)]
        other=[line for line in body.splitlines() if re.search(r',%r15\s*$',line)
               and not re.search(r'\b(?:sub\s+\$0x[0-9a-f]+,|cmp\s+\(%r14\),|mov\s+0x8\(%r14\),)%r15',line)]
        check(not other,'all local heap pointer reservations are constant')
        check(not re.search(r'\bsub\s+[^\n$]*,%rsp',body),'no variable local stack reservation')
        check(not re.search(r'<caml_alloc(?:_shr|_small|_custom|_string|_array)',body),'no hidden size-scaled allocation primitive')
        census[name]={'heap_reservations_bytes':heap,'fixed_rsp_subtractions_bytes':stack,
                      'instruction_bytes':size}
    symbols=elf_symbols(binary)
    for name,r in w['constant_closure_targets'].items():
        addr,_,pos=symbols[name]
        header=struct.unpack_from('<Q',binary,pos-8)[0]
        check(addr==r['address'] and header==r['header'] and 8*(header>>10)==r['size'],
              'constant closure header and extent')
        vals=[struct.unpack_from('<Q',binary,pos+i)[0] for i in range(0,r['size'],8)]
        check(all(symbols[target][0] in vals for target in r['targets']),'constant closure callback target')
    boundary=read('native-boundary.json')
    check({r['target'] for r in boundary['direct_code_edges']}==set(w['external_code_references']),
          'every retained external code reference has a source disposition')
    heap=[x for r in census.values() for x in r['heap_reservations_bytes']]
    stack=[x for r in census.values() for x in r['fixed_rsp_subtractions_bytes']]
    check(max(heap)==104,'new local request ceiling is 104 bytes')
    check(census['camlWhy3__Ity__create_cty_inner_16877']['heap_reservations_bytes']==[24,40,48,40,40,80,80,80,80,80,80],
          'intermediate effects and closures retained as distinct sites')
    check(census['camlWhy3__Ity__reg_match_4582']['heap_reservations_bytes']==[104,24],
          'region freeze closure group supplies largest local reservation')
    check(census['camlWhy3__Ity__cty_unsafe_7343']['heap_reservations_bytes']==[80],
          'nine-field cty record has fixed native size')
    result={'bodies':census,'local_helper_bodies':len(w['local_bodies']),
            'adapter_bodies':len(w['adapter_bodies']),'constant_closures':len(w['constant_closure_targets']),
            'instruction_bytes':total,'maximum_heap_reservation_bytes':max(heap),
            'maximum_fixed_rsp_subtract_bytes':max(stack),
            'frame_number_is_not_peak_or_cumulative_stack_bound':True,
            'local_heap_header_payload_words_upper':max(heap)//8-1,
            'aggregate_physical_memory_or_stack_gate':False,
            'source_native_refinement_machine_proved':False}
    write('native-census.json',result)
    return result


def arity_frontier():
    original=ROOT/'docs/evidence/retained-main-construction-demand-20261024/contract-builders'
    identity=json.loads((original/'identity.json').read_text())
    a=identity['archives'][1]
    check(sha((ROOT/a['path']).read_bytes())==a['sha256'],'Main-origin library archive identity')
    sites=json.loads((original/'sites.json').read_text())
    rows=[]
    with tarfile.open(ROOT/a['path']) as t:
        for name,row in sites['main_clone_ancestor_inventory'].items():
            lines=t.extractfile(row['path']).read().decode().splitlines()
            hits=[{'line':i,'source':lines[i-1]} for i in range(row['first'],row['last']+1)
                  if re.search(r'\bexists\b',lines[i-1])]
            rows.append({'module':name,'existential_sites':hits})
    found=[h for r in rows for h in r['existential_sites']]
    check([x['line'] for x in found]==[1904,2003],'only two existential syntax sites in eleven-origin closure')
    check(all(re.search(r'\bexists i : I1\.t\.',x['source']) for x in found),
          'each reached origin existential binds one scalar witness')
    output={'current_Main_type_arity_bound':2,'origins':rows,
            'reason':'Accepted concrete type frontier is nullary snapshots/references, Unit and binary function types; these originals add no multiple-witness result tuple.',
            'general_fixed_origin_arity_claim':False}
    write('arity-frontier.json',output)


def diagrams():
    INT,BOOL=b.Ty('int'),b.Ty('bool');arrow=b.Ty('arrow',(INT,BOOL))
    d=Demand(10000,20000,30000)
    create_cty((),(),(),b.Effect(),arrow,{},d)
    e=d.local_export()
    check(e['accepted_request_vector']['owner_requests_upper']=={'Hsty':3,'Ident':0},'projection retains accepted owner requests')
    check(e['maximum_observed_type_argument_arity']==2 and e['new_local_representation_safety_closed'],'binary function type uses representable arity operands')

    shapes=[]
    for n in [0,37]:
        v=k.Var(101,INT);dead=k.Var(102,arrow)
        quant=k.Term('forall',binding=k.Binding((v,),k.node('true'),tuple(() for _ in range(n)),{}, {dead:k.node('app',ty=arrow,symbol='closed_projection')}))
        post=k.Term('eps',binding=k.Binding((k.Var(103,b.UNIT),),quant,(),{},{}),ty=b.UNIT)
        sd=Demand(10000,20000,30000);create_cty((),(),(post,),b.Effect(),b.UNIT,{},sd);shapes.append(sd)
    check(shapes[0].export()==shapes[1].export(),'empty trigger groups do not alter accepted constructor requests')
    check(shapes[1].input_shape['trigger_group_list_cells']==37,'finite traversal witness retains empty trigger list spines')
    check(shapes[1].input_shape['saved_bindings']==1,'dead saved image participates in finite traversal witness')

    effect=Demand(10000,20000,30000);fd=b.Field(400,INT);reg=b.Region(401,b.Ty('ref'),(fd,))
    pv=b.PV(k.Var(402,reg.ty),reg)
    ct=create_cty((),(),(),b.Effect(frozenset({pv}),{reg:frozenset({fd})},covers=frozenset({reg})),b.UNIT,{pv.var:pv},effect)
    check(ct.freeze==frozenset({reg}) and ct.effect.writes=={reg:frozenset({fd})},'fixed local effect records preserve state and region identities')
    check(effect.memo_reads['Ity.vs_to_pv.restore']==0 and effect.calls['reg_match']==1,'freeze callback is local without a fictitious restore lookup')

    case=Demand(10000,20000,30000)
    body=b.b.Case(k.node('const',ty=INT),((b.b.Pattern('wild',INT),k.Binding((),k.node('true'),(),{},{})),))
    post=k.Term('eps',binding=k.Binding((k.Var(410,b.UNIT),),body,(),{},{}),ty=b.UNIT)
    create_cty((),(),(post,),b.Effect(),b.UNIT,{},case)
    check(case.input_shape['case_branch_list_cells']==1 and case.input_shape['pattern_occurrences']==1,'context inspection has finite branch and pattern descent')
    check(not case.kernel.ident_increments,'context traversal never opens a binder')

    seq=Demand(10000,20000,30000);u=b.PV(k.Var(420,INT));v=b.PV(k.Var(421,INT));bad=b.PV(k.Var(422,BOOL))
    c=b.Contract((u,),(),(),b.Effect(),INT)
    for _ in range(2):
        try:c_app(c,(bad,),INT,seq)
        except b.SourceFailure:pass
        else:raise AssertionError('failed candidate expected')
    check(seq.map_events==[('formal_actual_add',0,1)]*2 and not seq.records['actual_tvar'],'both failed prefixes retain adds without later term maps')
    c_app(c,(v,),INT,seq)
    unit=b.Contract((),(),(),b.Effect(),b.UNIT)
    c_app(unit,(),b.UNIT,seq,unit=True);c_app(unit,(),b.UNIT,seq,unit=True)
    check(seq.kernel.ident_increments==2 and seq.owner_requests==Counter(Hsty=4,Hsity=2),'same owner histories continue through failures success and Unit')
    check(seq.local_export()['new_local_counter_increments']==0,'local closure extension introduces no owner increment')

    outside=Demand(10000,20000,30000)
    create_cty((),(),(),b.Effect(),b.Ty('outside_current_frontier',(INT,INT,INT)),{},outside)
    check(not outside.local_export()['new_local_representation_safety_closed'],'out-of-domain arity cannot export unconditional source closure')
    unsupported=Demand(10000,20000,30000)
    try:c_app(b.Contract((pv,),(),(),b.Effect(),b.UNIT),(pv,),b.UNIT,unsupported)
    except ValueError:pass
    else:raise AssertionError('reference application remains residual')
    check(not unsupported.local_export()['new_local_representation_safety_closed'],'rejected residual entry cannot export source closure')
    outputs={name:x.local_export() for name,x in [('projection',d),('saved_images_and_empty_triggers',shapes[1]),('external_effect',effect),('context_case',case),('candidate_sequence',seq),('outside_arity_frontier',outside),('reference_application_residual',unsupported)]}
    check(all(not x['aggregate_physical_memory_or_stack_gate'] and not x['cumulative_local_bytes_required_for_representation_safety'] for x in outputs.values()),'no aggregate memory gate or cumulative local-byte obligation')
    write('exports.json',outputs)


def main():
    start=time.monotonic();inputs();n=native();arity_frontier();diagrams()
    result={'status':'pass','assertions':sum(counts.values()),'families':dict(counts),
            'elapsed_seconds':time.monotonic()-start,'host':platform.platform(),
            'local_helper_bodies':n['local_helper_bodies'],'adapter_bodies':n['adapter_bodies'],
            'instruction_bytes':n['instruction_bytes'],'maximum_local_request_bytes':n['maximum_heap_reservation_bytes'],
            'local_representation_safety':'closed under the accepted source partition and stated guards',
            'cumulative_local_byte_pricing':'not required for representation safety; intentionally not computed',
            'whole_source_to_initial_vc_storage':False,'shared_owner_services_complete':False,
            'native_target_runs':0,'new_disassembler_runs':0,'predecessor_checker_main_runs':0}
    write('result.json',result);print(json.dumps(result,indent=2))


if __name__=='__main__':main()
