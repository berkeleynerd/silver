#!/usr/bin/env python3
"""Check only new retained-source/native owner attachment and arithmetic."""
import hashlib
import json
from pathlib import Path
import platform
import struct
import sys
import tarfile
import time

sys.dont_write_bytecode=True
from project import HERE,ROOT,ARCHIVE,CASES,project,source_inventory,elf_symbols
COUNTS={}

def sha(b):return hashlib.sha256(b).hexdigest()
def checked(group,test):
    assert test,group
    COUNTS[group]=COUNTS.get(group,0)+1

def virtual_bytes(raw,va,n):
    off=struct.unpack_from('<Q',raw,32)[0];sz,num=struct.unpack_from('<HH',raw,54)
    for i in range(num):
        kind,_,pos,start,_,size,_,_=struct.unpack_from('<IIQQQQQQ',raw,off+i*sz)
        if kind==1 and start<=va and va+n<=start+size:return raw[pos+va-start:pos+va-start+n]
    raise AssertionError((va,n))

def main():
    started=time.perf_counter()
    pins=json.loads((HERE/'inputs.json').read_bytes())
    for group in ['archives','context_files','packet_files']:
        base=HERE if group=='packet_files' else ROOT
        for f,h in pins[group].items():checked(group,sha((base/f).read_bytes())==h)
    source=json.loads((HERE/'source-witnesses.json').read_bytes())
    with tarfile.open(ARCHIVE) as t:
        for w in source:
            raw=t.extractfile(w['member']).read()
            checked('source_witnesses',sha(raw)==w['member_sha256'] and ''.join(raw.decode().splitlines(keepends=True)[w['first_line']-1:w['last_line']])==w['text'])
    inventory=source_inventory()
    checked('complete_source_inventory',inventory==json.loads((HERE/'source-inventory.json').read_bytes()))
    checked('classified_allocation_sites',len(inventory['allocation_sites'])==28)
    gnat=[(r['member'],hit['text']) for r in inventory['ML_MLI_files'] if '/gnat/' in r['member'] for hit in r['hits']]
    checked('gnat_control_sender_inventory',gnat==[('why3/src/gnat/gnat_checks.ml','  Prove_client.connect_external Gnat_config.socket_name')])
    native=json.loads((HERE/'native-inputs.json').read_bytes())
    for w in native['inputs']:
        raw=Path(w['path']).read_bytes()
        checked('installed_identities',len(raw)==w['bytes'] and sha(raw)==w['sha256'])
    raw=Path(native['inputs'][1]['path']).read_bytes()
    symbols=elf_symbols(raw)
    checked('native_symbols',symbols==json.loads((HERE/'native-symbol-inventory.json').read_bytes()))
    checked('selected_translation_units',set(r['member'].rsplit('/',1)[-1] for r in inventory['selected_C_members']).issubset(set(symbols['source_file_symbols'])) and not any('cpulimit' in n for n in symbols['source_file_symbols']))
    instruction_bytes=0
    for rows in native['bodies'].values():
        for w in rows:
            b=bytes.fromhex(w['hex']);instruction_bytes+=len(b)
            checked('instruction_bytes',virtual_bytes(raw,w['va'],len(b))==b)
    for w in native['operand_witnesses'].values():
        b=bytes.fromhex(w['hex']);checked('native_operands',virtual_bytes(raw,w['va'],len(b))==b)
    result=project()
    checked('new_projection',result==json.loads((HERE/'projection.json').read_bytes()))
    shared=result['topologies']['prospective_shared'];single=result['topologies']['historical_singletons']
    checked('topology_attachment',shared['partition']==[CASES] and single['partition']==[[c] for c in CASES])
    checked('new_control_arithmetic',shared['fixed_new_control_bytes']==1016 and single['fixed_new_control_bytes']==3000)
    checked('ring_partition_attachment',shared['ring_old_new_backing_bytes']==41536 and single['ring_old_new_backing_bytes']==38336)
    checked('process_lifecycle_counts',shared['process_record_cumulative_bytes']==single['process_record_cumulative_bytes']==11016 and shared['process_record_live_bytes_upper']==288 and single['process_record_live_bytes_upper']==1152)
    native_int_max=2**31-1; native_size_max=2**64-1; native_uint_max=2**32-1
    for top in result['topologies'].values():
        for s in top['servers']:
            j=s['J'];c=s['accepted_connections_upper'];q=s['request_ring_capacity']
            checked('fixed_native_guards',1<=j and 2*j<=native_int_max and j+2<=native_int_max and c<=j and 12*j<=native_size_max and 8*(j+2)<=native_size_max and 2*q<=native_uint_max and 8*q<=native_size_max and c+2<=s['poll_capacity'])
    # New C_s + 12 path and joined response guards at native boundary values.
    max_c=native_int_max-45
    for c in (0,1,11,255,4096,max_c):
        checked('pathname_response_guards',c+12<=native_size_max and c+11+3+31<=native_int_max)
    checked('pathname_response_rejection',max_c+1+11+3+31>native_int_max)
    # Expand once using accepted counts; this is new family integration, not
    # a replay of parser, ring-resize or receive-buffer predecessor proofs.
    n=459; m=14
    constant=n*(8*m)+57714+8*n*(m+2)+41536+23628+1016+n*36
    checked('single_charge_integration',constant==250578 and n+n==918)
    return {'status':'pass','platform':platform.system()+' '+platform.machine(),'elapsed_seconds':round(time.perf_counter()-started,6),'checks':COUNTS,'direct_allocation_sites':28,'caller_inventory_sites':len(inventory['caller_sites']),'ML_MLI_inventory_members':len(inventory['ML_MLI_files']),'source_witnesses':len(source),'installed_function_bodies':len(native['bodies']),'installed_instruction_bytes':instruction_bytes,'native_operand_witnesses':len(native['operand_witnesses']),'direct_shared_m14_formula':'sum_d N_d*L_d + sum_d 2*R(M_d) + 918*C + 250578','library_service_allocations_closed':False,'shared_endpoint_prefix_transfer_proved_here':False,'source_semantics_machine_proved':False,'native_target_solver_proof_runs':0,'predecessor_checker_replays':0,'complete_q':None,'production_adopted':False}

if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
