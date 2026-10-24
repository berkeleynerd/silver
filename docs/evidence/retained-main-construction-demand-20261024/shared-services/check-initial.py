#!/usr/bin/env python3
"""New focused identity, native request and shared-interface checks only."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import platform
import re
import struct
import sys
import tarfile
import time
sys.dont_write_bytecode = True
from shared import Demand, backing, create_cty, c_app, b, k, INT_MAX, ARRAY_MAX, EPHE_MAX
from freeze import INSN, elf_symbols
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
COUNTS = Counter()


def check(ok, name):
    if not ok: raise AssertionError(name)
    COUNTS[name] += 1


def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(n): return json.loads((HERE/n).read_text())
def write(n,x): (HERE/n).write_text(json.dumps(x,indent=2)+'\n')


def identities():
    for p in read('inputs.json')['providers']:
        check(sha((ROOT/p['path']).read_bytes()) == p['sha256'], 'accepted provider identity')
    for a in read('source-witnesses.json'):
        check(sha((ROOT/a['path']).read_bytes()) == a['sha256'], 'source archive identity')
        with tarfile.open(ROOT/a['path']) as t:
            for f in a['files']:
                raw=t.extractfile(f['path']).read();lines=raw.decode().splitlines()
                check(sha(raw)==f['sha256'], 'complete source identity')
                for s in f['spans']:
                    code='\n'.join(lines[s['first']-1:s['last']])+'\n'
                    check(code==s['source'] and sha(code.encode())==s['sha256'], 'source excerpt identity')


def native():
    w=read('native-witnesses.json');raw=Path(w['executable']['path']).read_bytes()
    check(sha(raw)==w['executable']['identity']['sha256'], 'retained ELF identity')
    dis=Path(w['existing_disassembly']['path']).read_bytes()
    check(sha(dis)==w['existing_disassembly']['sha256'], 'retained disassembly identity')
    all_bodies={n:b for b,n in re.findall(r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)',dis.decode(),re.S)}
    bodies=read('native-bodies.json')
    check(set(bodies)==set(w['selected_bodies']), 'native inventory exact')
    offset=struct.unpack_from('<Q',raw,32)[0];size,n=struct.unpack_from('<HH',raw,54)
    loads=[]
    for i in range(n):
        typ,flags,p,addr,_,length,_,_=struct.unpack_from('<IIQQQQQQ',raw,offset+i*size)
        if typ==1 and flags&1: loads.append((addr,addr+length,p))
    census={}
    for name,body in bodies.items():
        check(body==all_bodies[name], 'complete labelled native body retained')
        chunks=[(int(m[1],16),bytes.fromhex(m[2])) for line in body.splitlines() if (m:=INSN.match(line))]
        check(bool(chunks) and all(a+len(v)==b for (a,v),(b,_) in zip(chunks,chunks[1:])), 'contiguous native bytes')
        addr=chunks[0][0];code=b''.join(v for _,v in chunks)
        check(any(lo<=addr and addr+len(code)<=hi and raw[p+addr-lo:p+addr-lo+len(code)]==code for lo,hi,p in loads), 'complete native body matches executable segment')
        heap=[int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15',body)]
        other=[line for line in body.splitlines() if re.search(r',%r15\s*$',line) and not re.search(r'\b(?:sub\s+\$0x[0-9a-f]+,|cmp\s+\(%r14\),|mov\s+0x8\(%r14\),)%r15',line)]
        check(not other, 'own native heap reservations are fixed')
        check(not re.search(r'\bsub\s+[^\n$]*,%rsp',body), 'own stack reservation fixed')
        census[name]={'instruction_bytes':len(code),'own_heap_reservations_bytes':heap}
    symbols=elf_symbols(raw)
    for name,v in w['constant_closures'].items():
        addr,_,pos=symbols[name];header=struct.unpack_from('<Q',raw,pos-8)[0]
        check(addr==v['address'] and header==v['header'] and 8*(header>>10)==v['size'], 'constant closure extent')
        slots=[struct.unpack_from('<Q',raw,pos+i)[0] for i in range(0,v['size'],8)]
        check(all(symbols[x][0] in slots for x in v['targets']), 'constant closure code pointer')
    check({r['target'] for r in read('native-boundary.json')['direct_code_edges']}==set(w['external_code_references']), 'direct native boundary dispositions complete')
    check(census['camlWhy3__Ty__tag_2290']['own_heap_reservations_bytes']==[24], 'Hsty tag copies two payload words')
    check(census['camlWhy3__Ity__tag_3788']['own_heap_reservations_bytes']==[32], 'Hsity tag copies three payload words')
    maximum=max(x for row in census.values() for x in row['own_heap_reservations_bytes'])
    check(maximum==152 and maximum//8-1<=ARRAY_MAX, 'shared local request header fits')
    check('camlStdlib__Ephemeron__find_730' in bodies['camlWhy3__Ity__restore_pv_14857'], 'restore dispatches to ephemeron find')
    check('camlStdlib__Hashtbl__find_1059' in bodies['camlWhy3__Exthtbl__fun_917'], 'warm memo dispatches to strong find')
    out={'selected_native_bodies':len(census),'instruction_bytes':sum(x['instruction_bytes'] for x in census.values()),
         'maximum_own_heap_reservation_bytes':maximum,'per_constituent_block_payload_words_upper':maximum//8-1,
         'scaled_array_weak_requests':'accepted weak_transfer lengths and shared.backing per-request header/byte guards',
         'bodies':census,'aggregate_bytes_or_stack_gate':False,'machine_checked_source_native_refinement':False}
    write('native-census.json',out)
    return out


def diagrams():
    state={o:{'outer_length':5003,'bucket_max':0,'allocated_slots':0} for o in ('Hsty','Hsity')}
    # Numbers are transparent arithmetic diagrams, not measured Main states.
    d=Demand(10000,20000,30000)
    create_cty((),(),(),b.Effect(),b.Ty('arrow',(b.Ty('int'),b.Ty('bool'))),{},d)
    first=d.shared_export(state)
    check(first['owner_counters']['Hsty']['increments_upper']==3, 'actual projection source fold supplies requests')
    check(first['conditional_shared_representation_interface_applies'], 'closed supplied projection diagram')
    check(not first['actual_Main_initial_process_attachment_established'], 'numeric states do not certify Main attachment')
    ct=b.Contract((),(),(),b.Effect(),b.UNIT)
    c_app(ct,(),b.UNIT,d,unit=True)
    second=d.shared_export(state)
    c_app(ct,(),b.UNIT,d,unit=True)
    third=d.shared_export(state)
    check(second['owner_counters']['Hsty']['increments_upper']==5 and third['owner_counters']['Hsty']['increments_upper']==7, 'repeated builders retain cumulative Hsty history')
    check(third['owner_counters']['Hsity']['final_upper']==30002 and third['owner_counters']['Ident']['final_upper']==10002, 'repeated Unit shares Hsity and Ident owners')
    check(third['lookup_only_services']['reads']=={'ts_tuple':4,'fs_tuple':2,'its_tuple':2,'fs_tuple_ids.mem':2}, 'warm memo multiplicity attached to Unit source fold')
    check(third['new_exception_or_save_allowance']==0, 'no renewed callback/save allowance')
    missing=d.shared_export()
    check(missing['weak_backing'] is None and not missing['conditional_shared_representation_interface_applies'], 'absent inherited backing does not close arithmetic')

    var=k.Var(41,b.Ty('int'));pv=b.PV(var)
    pre=k.node('app',k.var(var),symbol='P')
    lookup=Demand(10000,20000,30000)
    create_cty((),(pre,),(),b.Effect(),b.UNIT,{var:pv},lookup)
    le=lookup.shared_export(state)
    check(le['lookup_only_services']['reads']['Ity.vs_to_pv.restore']==1, 'actual free-variable restoration supplies Wvs read')
    check(le['lookup_only_services']['new_backing_arrays_or_bucket_nodes']==0, 'Wvs read has no fictitious growth charge')

    fail=Demand(10000,20000,30000)
    formal=b.PV(k.Var(61,b.Ty('int')));actual=b.PV(k.Var(62,b.Ty('bool')))
    try:c_app(b.Contract((formal,),(),(),b.Effect(),b.UNIT),(actual,),b.UNIT,fail)
    except b.SourceFailure:pass
    else:raise AssertionError('expected mismatch')
    fe=fail.shared_export(state)
    check(any(n=='apply_vsb_add' for n,_,_ in fe['accepted_local_export']['accepted_request_vector']['map_events']), 'R1 current failed-pair map remains charged')
    check(all(v['increments_upper']==0 for v in fe['owner_counters'].values()), 'failed application adds no fictitious hashcons request')

    limit=Demand(INT_MAX,INT_MAX,INT_MAX)
    c_app(ct,(),b.UNIT,limit,unit=True)
    ce=limit.shared_export(state)
    check(not ce['conditional_shared_representation_interface_applies'] and not ce['supplied_diagram_counter_guards'], 'owner overflow rejects conditional closure')
    near=Demand(INT_MAX-1,INT_MAX-2,INT_MAX-1)
    c_app(ct,(),b.UNIT,near,unit=True)
    check(near.shared_export(state)['conditional_shared_representation_interface_applies'], 'exact final owner maximum accepted')
    large={o:dict(v) for o,v in state.items()};large['Hsty']['allocated_slots']=ARRAY_MAX
    be=d.shared_export(large)
    check(not be['conditional_shared_representation_interface_applies'] and not be['supplied_diagram_backing_guards'], 'unrepresentable inherited-demand backing rejected')
    bad=Demand();bad.domain_supported=False
    check(not bad.shared_export(state)['conditional_shared_representation_interface_applies'], 'unsupported local source domain cannot close shared interface')
    for malformed in [True, -1, 1.0]:
        try:backing({'outer_length':5003,'bucket_max':0,'allocated_slots':malformed},0)
        except ValueError:check(True, 'invalid numeric state rejected')
        else:raise AssertionError('invalid state accepted')
    try:d.shared_export({'Hsty':state['Hsty']})
    except ValueError:check(True, 'partial owner state rejected')
    else:raise AssertionError('partial owners accepted')
    write('exports.json',{'projection':first,'one_unit_after_projection':second,'two_units_after_projection':third,
                         'Wvs_read':le,'failed_first_pair':fe,'missing_backing':missing,'owner_overflow':ce,'backing_overflow':be})


def main():
    started=time.perf_counter()
    if '--diagrams-only' in sys.argv:
        diagrams();n=None
    else:
        identities();n=native();diagrams()
    out={'status':'passed','assertions':sum(COUNTS.values()),'groups':dict(COUNTS),'elapsed_seconds':time.perf_counter()-started,
         'host':platform.platform(),'native_census':None if n is None else {k:n[k] for k in ('selected_native_bodies','instruction_bytes','maximum_own_heap_reservation_bytes')},
         'native_target_runs':0,'new_disassembler_runs':0,'compiler_prover_Lean_runs':0,'predecessor_checker_runs':0}
    write('diagram-result.json' if n is None else 'result.json',out)
    print(json.dumps(out,indent=2))


if __name__=='__main__':main()
