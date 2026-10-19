#!/usr/bin/env python3
"""Offline extraction only; imports no predecessor module and executes no tools."""
import argparse, hashlib, json, re
from pathlib import Path
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
ADAPTER='docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json'
FIXED='docs/evidence/unbounded-programs/retained-native-expansion-20261017/native-fixed-inputs.json'
SPANS='''sem_util.adb|24064|24125|NCT_Table_Max;Key mod NCT_Table_Max
sem_util.adb|24317|24422|NCT_New_Entities.Set;New_Elmt_List;Append_Unique_Elmt;Build_NCT_Tables
sem_util.adb|24443|24622|Copy_Elist_With_Replacement;Copy_List_With_Replacement;Next (Elmt)
sem_util.adb|24913|24962|Update_New_Entities;Update_Semantic_Fields;Next_Elmt
sem_util.adb|25108|25159|NCT_New_Entities.Get;New_Copy (Id);Visit_Semantic_Fields
sem_util.adb|25255|25356|NCT_New_Entities.Get;New_Copy (Itype);Add_Pending_Itype
sem_util.adb|25567|25624|NCT_New_Entities.Reset;NCT_Pending_Itypes.Reset;Visit_Any_Node;Copy_Node_With_Replacement
libgnat/s-htable.adb|40|119|Iterator_Index;Table'Last;Iterator_Index + 1
libgnat/s-htable.adb|225|258|type Element_Wrapper is record;Next : Elmt_Ptr
libgnat/s-htable.adb|357|387|Free (E1);new Element_Wrapper
exp_util.adb|106|117|Type_Map_Size;Simple_HTable;Node_Or_Entity_Id
sem.ads|386|410|type Suppress_Stack_Entry;Prev :;Next :
sem.adb|1387|1421|new Suppress_Stack_Entry
sem_ch12.adb|999|1042|type Assoc is record;Table_Initial;HTable_Size
sem_ch12.adb|1075|1128|type Instance_Env is record;Config_Switches_Type;Table_Initial
opt.ads|2082|2109|type Config_Switches_Type is record;Warnings_As_Errors_Count
opt.ads|135|155|new String;Ada_Main_Name
opt.ads|1284|1293|new String_List (1 .. 4);Preprocessing_Symbol_Last
errid-diagnostic_repository.ads|30|98|Diagnostics_Registry_Type;new String
errid-switch_repository.ads|30|662|Switches : constant array;new String;new Diagnostic_Id_Array
errid.ads|26|147|type Diagnostic_Id;type Switch_Id
atree.adb|275|285|Node_Field_Sets;Entity_Field_Sets
atree.adb|332|352|new Node_Field_Sets;new Entity_Field_Sets;pragma Debug
exp_dbug.adb|1214|1240|Full_Qualify_Name : String;Recursive
exp_dbug.adb|1270|1317|Fully_Qualify_Name (Scope (E));Full_Qualify_Len
exp_dbug.adb|1381|1422|Set_Entity_Name (S);Add_Str_To_Name_Buffer
namet.adb|169|212|Temp : Bounded_String;New_Buf : String
namet.adb|1546|1583|Length_Of_Name;Bounded_String
errout.adb|2912|2940|.gnat.sarif;SARIF_Printer
errout.adb|2960|3035|Sarif
erroutc-sarif_emitter.ads|59|71|SARIF_Printer;record
lib-writ.adb|225|260|With_Flags;Has_Implicit_With
lib-writ.adb|28|80|with
sem_case.adb|3379|3388|new Link;Num_Choices := Num_Choices + 1
sem_ch6.adb|7503|7535|Style_Check;new String
sem_elim.adb|812|827|new Elim_Data
sem_elim.adb|202|250|Check_Eliminated
sem_res.adb|10283|10300|Alts;List_Length
sem_util.adb|31262|31282|Unmerged_Choice_Count;Discrete_Interval_List
table.adb|128|154|Table_Initial * Table_Factor;Reallocate
table.adb|167|218|New_Length;Table_Type'Component_Size
table.adb|413|416|Init;end Table
erroutc.ads|187|374|Errors;Locations;Warnings
erroutc.ads|457|504|Specific_Warnings;Table_Initial
errout.ads|640|659|List_Pragmas;Table_Initial
sem_warn.ads|40|62|Warnings_Off_Pragmas;Table_Initial
sem_warn.adb|63|87|In_Out_Warnings;Unreferenced_Entities
alloc.ads|55|165|Warnings_Off;Initial
'''
REPO_FILES=[ADAPTER,FIXED,
'docs/research/retained-literal-frontend-storage.md',
'docs/research/retained-literal-native-frontend.md',
'docs/research/retained-native-expansion.md',
'docs/research/retained-main-semantics.md',
'docs/research/retained-literal-ada-numeric.md',
'docs/research/retained-literal-invocation-join.md',
'docs/research/retained-literal-original-main-storage.md',
'docs/research/retained-literal-string-layout-storage.md']

def ident(raw):return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def clean(s):
    return re.sub(r"'\"'|--[^\n]*|\"(?:[^\"\n]|\"\")*\"",lambda m:''.join('\n' if c=='\n' else ' ' for c in m[0]),s)

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--ada-root',required=True)
    parser.add_argument('--gcc-root',required=True);args=parser.parse_args()
    ada=Path(args.ada_root);gcc=Path(args.gcc_root)
    spans=[]
    for line in SPANS.strip().split('\n'):
        file,a,b,terms=line.split('|');a,b=int(a),int(b)
        value='\n'.join((ada/file).read_bytes().decode().split('\n')[a-1:b])
        terms=terms.split(';')
        if not all(t in value for t in terms):raise ValueError((file,a,b,[t for t in terms if t not in value]))
        spans.append(dict(root='ada',path=file,first_LF_line=a,last_LF_line=b,text=value,operative_fragments=terms))
    files=[dict(root='ada',path=f,identity=ident((ada/f).read_bytes())) for f in sorted({r['path'] for r in spans})]
    files += [dict(root='repository',path=f,identity=ident((REPO/f).read_bytes())) for f in REPO_FILES]
    make='gcc/ada/gcc-interface/Make-lang.in'
    files.append(dict(root='gcc',path=make,identity=ident((gcc/make).read_bytes())))
    registries=[]
    for file in ['errid-diagnostic_repository.ads','errid-switch_repository.ads']:
        raw=(ada/file).read_bytes().decode()
        literals=[]
        for m in re.finditer(r'new\s+String\s*\'\s*\(\s*"((?:[^"\n]|"")*)"\s*\)',raw,re.I):
            text=m[1].replace('""','"')
            literals.append(dict(LF=raw.count('\n',0,m.start())+1,characters=len(text),value=text))
        registries.append(dict(path=file,literals=literals,count=len(literals),maximum_characters=max(v['characters'] for v in literals)))
    fixed=json.loads((REPO/FIXED).read_text())['fixed_lifetime_table_growth']
    existing={'node_offsets','slots','orig_nodes','paren_counts','parents_stack','elists','elmts','name_qualify_units','expander_flags','file_mapping','path_mapping','sfn_patterns','sfn_table','xrefs','name_chars','name_entries','lists','next_node','prev_node','lib_search_directories','src_search_directories','rep_table','scope_stack','active_scenario_stack','elaboration_attributes','scenario_reps','target_reps','all_interp','instances','source_file','string_chars','strings','udigits','uints','ureals','invocation_constructs','invocation_relations','invocation_signatures'}
    diag={'list_pragmas','non_instance_msgs','edits','errors','fixes','locations','specific_warnings','warnings','in_out_warnings','unreferenced_entities','warnings_off_pragmas'}
    generic={'generic_renamings','instance_envs','generic_flags'}
    rows=[]
    for symbol,total in fixed.items():
        name=symbol.split('__')[-2]
        if name in existing:owner='inherited named frontend component'
        elif symbol=='lib__units__last_val':owner='inherited Main_ALI_writer.Units_table (demand 41)'
        elif name in diag:owner='named zero-attempt diagnostic table transfer in this packet'
        elif name in generic:owner='named fixed generic table transfer in this packet'
        else:owner=None
        rows.append(dict(symbol=symbol,retained_positive_lifetime_growth=total,
                         owner=owner,backing_and_caller_closure_exported=owner is not None,
                         zero_growth_does_not_erase_initial_allocation=True))
    census=dict(scope='Owner reconciliation of the accepted120-symbol fixed census; not a complete allocator/callgraph census',
                rows=rows,unreconciled=[r['symbol'] for r in rows if r['owner'] is None],
                inherited_count=sum(r['owner'] is not None and r['owner'].startswith('inherited') for r in rows),
                newly_priced_named_count=sum(r['owner'] is not None and r['owner'].startswith('named') for r in rows),
                complete_static_table_census_established=False)
    (HERE/'fixed-table-census.json').write_text(json.dumps(census,indent=2)+'\n')
    (HERE/'registry-literals.json').write_text(json.dumps(registries,indent=2)+'\n')
    output=dict(GCC_revision='6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea',
                integration_base='a75f4c28ed',files=files,excerpts=spans,
                repository_inputs_are_reused_not_executed=True,
                literal_LF_positions_preserve_form_feeds=True)
    (HERE/'inputs.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(dict(files=len(files),excerpts=len(spans),table_rows=len(rows),unreconciled=len(census['unreconciled']),registry_Strings=sum(r['count'] for r in registries))))

if __name__=='__main__':main()
