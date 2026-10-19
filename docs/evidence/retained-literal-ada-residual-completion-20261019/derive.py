#!/usr/bin/env python3
"""Named Ada residual arithmetic. Never upgrades unproved completeness premises."""
from pathlib import Path
import argparse, copy, hashlib, json

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
I32=2**31-1
I64=2**63-1
PREMISES=('complete_selected_literal_source_route',
          'accepted_actual_frontend_tables_numeric_locations_names',
          'accepted_fixed_root_and_runtime_reduction',
          'selected_Linux_LP64_layout_and_default_Table_Factor',
          'accepted_no_frontend_diagnostic_attempt_source_partition')
DIAGNOSTIC_TABLES={
 'Non_Instance_Msgs':(100,100,32,1), 'Errors':(200,200,320,1),
 'Locations':(200,200,80,1), 'Edits':(200,200,48,1),
 'Fixes':(200,200,48,1), 'Warnings':(100,200,12,1),
 'Specific_Warnings':(100,200,112,1), 'List_Pragmas':(50,200,8,1),
 'Unreferenced_Entities':(1000,100,4,1), 'In_Out_Warnings':(100,100,4,1),
 'Warnings_Off_Pragmas':(500,100,12,0)}

def require(value,message):
    if not value: raise ValueError(message)

def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())

def table(d,i,g,b,low=0):
    p=max(d,i); cap=max(i,d+d//1000,p*(100+g)//100,p+10)
    checks=dict(initial=i<=I32,growth_product=p*(100+g)<=I64,
                length_successor=cap+1<=I32,low_and_sentinel=-I32-1<=low-1<=I32,
                largest_index=low+cap<=I32,logical_last=low+d-1<=I32,
                individual_allocation=(cap+1)*b<=I64)
    return dict(demand=d,initial=i,increment_percent=g,low=low,
                component_bytes_upper=b,capacity_upper=cap,
                individual_bytes_upper=(cap+1)*b,checks=checks,
                passed=all(checks.values()))

def arithmetic(c,n,path=512):
    require(type(c) is int and c>=1 and type(n) is int and n>=0,'C>=1 N>=0 integers')
    require(type(path) is int and 0<=path<=512,'accepted complete path spelling bound <=512')
    nodes=41234+41+19*c+4*n
    fixed=dict(Generic_Renamings=table(16,10,100,12),
               Instance_Envs=table(8,32,100,512),
               Generic_Flags=table(4,32,200,1))
    diagnostic={k:table(0,i,g,b,low) for k,(i,g,b,low) in DIAGNOSTIC_TABLES.items()}
    objects=dict(NCT_each_bucket_array=511*8,NCT_each_wrapper=16,
                 Type_Map_bucket_array=511*8,Type_Map_wrapper=16,
                 Generic_Renamings_hash_headers=37*4,
                 Suppress_Stack_Entry=5*16,
                 diagnostic_registry_each_String=39+16,
                 diagnostic_registry_three_id_array=3*4+16,
                 diagnostic_registry_static_array=10*3*16,
                 switch_registry_static_array=85*6*16,
                 Opt_Ada_Final_Name=8+16,Opt_Ada_Init_Name=7+16,
                 Opt_Ada_Main_Name=8+16,Opt_initial_preprocessing_pointer_array=4*16+16,
                 Errout_SARIF_name=path+11+16,Errout_first_filename=path+16,
                 Errout_SARIF_Printer=24,Warnings_As_Errors_pointer_array=10000*16,
                 Name_Buffer=4*32766,qualification_local_String=4*32766+16,
                 name_decode_Bounded_String=4096+16,name_decode_local_String=4096+16,
                 largest_stored_name_local_object=32767+16)
    checks=dict(all_named_fixed_tables=all(t['passed'] for t in fixed.values()),
                all_named_diagnostic_tables=all(t['passed'] for t in diagnostic.values()),
                all_named_objects=all(v<=I64 for v in objects.values()),
                diagnostic_filename_indices=path+12<=I32,
                inherited_node_domain=nodes+1<=I32,
                copy_map_hash_index=510<I32)
    return dict(counts=dict(C=c,N=n),frontend_node_allowance=nodes,
                named_fixed_tables=fixed,zero_attempt_diagnostic_tables=diagnostic,
                individual_objects_bytes_upper=objects,
                NCT_each_peak_distinct_keys_upper=nodes,
                NCT_lifetime_requests=None,NCT_pending_Elists_recharged=0,
                registry_literal_String_requests=177,registry_id_array_requests=1,
                source_call_or_null_diagnostic_attempts=0,
                new_variable_count_restrictions=0,checks=checks,passed=all(checks.values()),
                complete_Ada_frontend_capacity=False,complete_native_capacity=False,
                actual_source_adapter=False,aggregate_RAM_gate=False)

def apply(c,n,premises,path=512):
    require(type(premises) is dict and set(premises)==set(PREMISES),'exact source premises')
    require(all(v is True or v is False or v is None for v in premises.values()),'three-valued premises')
    a=arithmetic(c,n,path)
    computed=all(v is True for v in premises.values()) and a['passed']
    return dict(source_premises=copy.deepcopy(premises),computed=computed,
                derived=a if computed else None,
                complete_Ada_frontend_capacity=False,complete_native_capacity=False,
                unresolved_obligations_are_not_caller_settable_premises=True)

def verify_inputs(ada,gcc,manifest=None):
    m=json.loads((HERE/'inputs.json').read_text()) if manifest is None else manifest
    roots=dict(ada=Path(ada),gcc=Path(gcc),repository=REPO)
    for row in m['files']:
        require(identity((roots[row['root']]/row['path']).read_bytes())==row['identity'],'pin '+row['path'])
    for row in m['excerpts']:
        raw=(roots[row['root']]/row['path']).read_bytes().decode().split('\n')
        actual='\n'.join(raw[row['first_LF_line']-1:row['last_LF_line']])
        require(actual==row['text'],'LF excerpt '+row['path'])
        require(all(t in actual for t in row['operative_fragments']),'operative fragment '+row['path'])
    return dict(files=len(m['files']),literal_LF_excerpts=len(m['excerpts']))

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--ada-root',required=True)
    parser.add_argument('--gcc-root',required=True);args=parser.parse_args()
    output=dict(scope='Named Ada local/storage closures and explicit unclosed remainder; no actual-source attachment',
                arithmetic=arithmetic(1,0),input_verification=verify_inputs(args.ada_root,args.gcc_root),
                complete_Ada_frontend_capacity=False,complete_native_capacity=False,
                independent_review='pending',native_executions=0,predecessor_executions=0)
    (HERE/'result.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(output['input_verification']))

if __name__=='__main__':main()
