#!/usr/bin/env python3
"""Retain an inspected consumer table and exact local-source evidence."""
from pathlib import Path
import hashlib
import json
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]

# Each row records a semantic argument, not a conclusion inferred by matching
# tokens. The checker verifies the retained source and census correspondence.
ROWS = [
 ('M', 'main kind, priority, CPU, time slice, WC encoding', 'lib-writ.adb:1128-1207', 'ali.adb:1745-1898', 'bindgen.adb:538-539,940-961,1000-1004,1492-1507,1974-2229,2482-2484,3229-3255', 'Parameterless procedure Main; no priority/CPU/time-slice pragma or binder override; bracket encoding configuration. Main body statements do not write these fields.'),
 ('P-policy', 'DB, Ex, ID, Lx, Qx, Tx, UA', 'lib-writ.adb:1234-1294', 'ali.adb:1964-2140', 'bindgen.adb:578-600,681-689,931-1061,1179-1190', 'Fixed compiler/runtime configuration; no corresponding source or configuration pragma is admitted. All 82 fixed P records are ZX or SS ZX.'),
 ('P-mode', 'CE, GP, NC, NO, NR, NS, Ox, ZX', 'lib-writ.adb:1230-1302', 'ali.adb:1964-2165', 'bindgen.adb:1541-1542,1726-1727,2557-2559', 'Successful native object compilation under fixed target/mode/options; no new errors, proof mode, no-runtime, scalar-normalization or storage-order directive. Some fields are consistency inputs rather than direct bindgen reads; their selected values remain fixed.'),
 ('P-SS', 'SS -> Sec_Stack_Used', 'lib-writ.adb:1288-1290', 'ali.adb:2080-2113', 'bindgen.adb:646-657,703-735,798-802,1070-1106,2494-2495,2576-2580,2848-2867', 'SS is a P token, not a separate record. The fixed closure already sets it through non-exempt ALIs; the monotone True merge absorbs any Main contribution.'),
 ('T', 'Primary_Stack_Count, Sec_Stack_Count', 'lib-writ.adb:676-687', 'ali.adb:3023-3031', 'bindgen.adb:2487-2501', 'Main has no tasks or task allocators. No fixed closure ALI has a T record. The selected quantity override is absent, so secondary-stack count is one for the main task.'),
 ('R', 'Set, Value, Violated, Count, Unknown', 'lib-writ.adb:1305-1439;restrict.adb:390-560', 'ali.adb:2194-2514', 'bindgen.adb:931-937,1179-1185,1607-1626,2056-2057,2159-2215,2547-2555,2691-2710,2828-2833,2915-2927,2950-3024', 'Fixed restriction settings and parameter fields; Main contributes no checked parameter restriction. Boolean variation is absorbed by the 30 fixed closure violations. The complete 100-member restriction partition is retained separately.'),
 ('U-version', 'Version', 'lib-writ.adb:439-447', 'ali.adb:2746-2756', 'bindgen.adb:3039-3101', 'Only the canonical Main U token checksum varies semantically. Gen_Versions emits its eight hex digits in a fixed Version_32 declaration. Fixed dependency versions do not vary.'),
 ('U-name-kind', 'Uname, Sfile, Utype, Unit_Kind, Predefined, Internal, My_ALI, SAL_Interface, Directly_Scanned', 'lib-writ.adb:432-443,453-461,585-610', 'ali.adb:2628-2670,2865-2955,3176-3198', 'bindgen.adb:1283,1533-1563,1652-1663,1717-1739,1750-1763,1799-1822,1992-2002,2311-2316,2659-2670,3065-3097,3124-3218,3272-3275,3316-3318,3357-3407', 'Main remains the same non-generic library subprogram body and source-name role. No SAL/library/replay route is selected. All other units, file roles and order are the accepted fixed closure.'),
 ('U-elaboration', 'BD, BN, DE, EB, EE, NE, PR, PU', 'lib-writ.adb:449-557', 'ali.adb:2758-2804,2846-2875', 'bindgen.adb:1533-1694,1717-1739,3272-3275', 'Main executable statements occur inside its body and add no library elaboration code; NE stays true, EE is absent, and no package/generic/elaboration directive enters. Closure flags/order retain the accepted graph transfer. BD/BN/DE/EB/PR/PU have no direct bindgen field read; their graph/check consumers remain the inherited closure interface.'),
 ('U-finalization', 'PF, GE, Unit_Kind', 'lib-writ.adb:535-548,613-621', 'ali.adb:2806-2817,2860-2877', 'bindgen.adb:1769-1948,3261-3281', 'Main is a subprogram, never a non-generic package with a finalizer. The fixed packages alone determine Has_Finalizer and generated finalization routines.'),
 ('U-casing', 'IL, IU, KM, KU -> Icasing, Kcasing', 'lib-writ.adb:624-637', 'ali.adb:2819-2844', 'bindgen.adb:1551-1564,1652-1674', 'May vary with source casing. Main No_Elab takes the earlier branch, so its Icasing is not serialized; fixed units retain fixed casing. Kcasing has no bindgen consumer.'),
 ('U-scalars', 'IS -> Init_Scalars, Initialize_Scalars_Used', 'lib-writ.adb:640-642', 'ali.adb:2826-2831', 'bindgen.adb:1117-1126,2570-2572', 'No Initialize_Scalars setting or Invalid_Value use is admitted; the fixed ALIs contain no IS. No Main declaration can add scalar initialization.'),
 ('U-other', 'Ox, RA, RC, RT, SE, SP', 'lib-writ.adb:529-531,560-583', 'ali.adb:2878-2955', 'bindgen.adb:1-3656', 'Optimization alignment/configuration and successful compilation are fixed; no remote/shared-passive feature. These fields have no direct bindgen reader; their retained consistency/closure consumers are unchanged.'),
 ('fixed-auxiliary', 'W/Z closure; interrupt and dispatch tables; linker options; binding environment; target switches', 'lib-writ.adb:645-829; accepted invocation configuration', 'ali.adb:readers under retained binder row policy', 'bindgen.adb:1217-1486,2237-2461,2512-2943,3297-3407,3416-3430,3486-3511,3552-3573', 'No new with, pragma, CUDA, interrupt, dispatch, linker option or environment directive occurs. Fixed closure/configuration drives all other serializer branches; comments/path spellings retain the accepted width/renaming transfer.'),
]

TRACKED = '''Main_Program Main_Priority Main_CPU Time_Slice_Value WC_Encoding
Detect_Blocking Partition_Elaboration_Policy_Specified Interrupts_Default_To_System_Specified
Locking_Policy_Specified Queuing_Policy_Specified Task_Dispatching_Policy_Specified
Unreserve_All_Interrupts_Specified No_Run_Time_Mode Sec_Stack_Used Num_Sec_Stacks
Cumulative_Restrictions Initialize_Scalars_Used Uname Sfile Utype Unit_Kind
Predefined Internal My_ALI SAL_Interface Directly_Scanned Version No_Elab
Set_Elab_Entity Has_Finalizer Is_Generic Icasing Kcasing Sec_Stack_Count
Elaborate_Body_Desirable Body_Needed_For_SAL Dynamic_Elab Elaborate_Body Preelab Pure
Optimize_Alignment Has_RACW RCI Remote_Types Serious_Errors Shared_Passive Init_Scalars'''.split()
TRACKED += '''Elab_Position Ofile_Full_Name First_Unit Last_Unit First_Interrupt_State
Last_Interrupt_State First_Specific_Dispatching Last_Specific_Dispatching'''.split()

EXCERPTS = {
 'lib-writ.adb':[(432,645),(676,687),(1128,1207),(1226,1440)],
 'ali.adb':[(1745,1898),(1942,2167),(2194,2355),(2628,2670),(2746,2955),(3023,3031),(3176,3198)],
 'bindgen.adb':[(537,539),(931,1061),(1070,1126),(1515,1694),(1703,1742),(1799,1837),(2482,2505),(2547,2580),(2691,2710),(2811,2867),(2915,2927),(2950,3101),(3229,3281),(3335,3407)],
 'scng.adb':[(1099,1127),(1168,1227),(1259,1288)],
 'restrict.adb':[(390,560)],
 's-rident.ads':[(87,291)],
 'opt.ads':[(438,442),(855,866),(1027,1036),(1133,1140),(1319,1325),(1402,1410),(1546,1552),(1623,1628),(1708,1724)],
}

def source_bytes():
    with tarfile.open(HERE/'sources.tar.gz') as t:
        return {m.name:t.extractfile(m).read() for m in t.getmembers()}

def fixed_ali():
    out = {}
    archive = 'docs/evidence/retained-linker-output-delta-20261018/artifacts.tar.gz'
    with tarfile.open(ROOT/archive) as t:
        for m in t.getmembers():
            if m.name.startswith('closure/') and m.name.endswith('.ali') and m.name != 'closure/main.ali':
                b=t.extractfile(m).read()
                lines=b.decode().splitlines()
                out[m.name]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),
                    projection=[x for x in lines if x.startswith(('P','R','U ','T '))])
    return out

def make():
    sources=source_bytes()
    excerpts=[]
    for name,ranges in EXCERPTS.items():
        lines=sources[name].decode().splitlines(keepends=True)
        for first,last in ranges:
            assert 1 <= first <= last <= len(lines),(name,first,last,len(lines))
            text=''.join(lines[first-1:last])
            excerpts.append(dict(member=name,first=first,last=last,text=text,
                sha256=hashlib.sha256(text.encode()).hexdigest()))
    # Strip Ada strings/comments for identifier occurrence census. It is not an
    # Ada parser: the semantic role of each hit is established by the table.
    code=re.sub(r'\'"\'|"(?:""|[^"\n])*"|--[^\n]*',lambda m:' '*len(m[0]),sources['bindgen.adb'].decode())
    census={token:[i for i,line in enumerate(code.splitlines(),1)
        if re.search(r'\b'+token+r'\b',line,re.I)] for token in TRACKED}
    closure=fixed_ali()
    violations={}
    for name,row in closure.items():
        for line in row['projection']:
            m=re.fullmatch(r'RV ([A-Z_]+)',line)
            if m:violations.setdefault(m[1],[]).append(name)
    enum=sources['s-rident.ads'].decode()
    enum=enum[enum.index('(Simple_Barriers,'):enum.index('Not_A_Restriction_Id);')]
    members=re.findall(r'^\s*\(?([A-Za-z][A-Za-z_0-9]*),',enum,re.M)
    parameter=members[members.index('No_Specification_Of_Aspect'):]
    partition=[]
    for name in members:
        if name.upper() in violations:
            classification='absorbed by fixed closure boolean violation'
        elif name in parameter:
            classification='no new setting or parameter contribution: no source restriction/aspect/attribute or task/protected/select construct'
        elif name=='No_Wide_Characters':
            classification='excluded by ASCII alphabet and doubled-quote/bracket-scanner argument'
        elif name in {'No_Initialize_Scalars','No_Multiple_Elaboration','No_Reentrancy',
                      'Immediate_Reclamation','Static_Dispatch_Tables','SPARK_05',
                      'No_Implementation_Restrictions','No_Unrecognized_Aspects','No_Unrecognized_Pragmas'}:
            classification='unchanged mode/directive; fixed SPARK pragma and naming configuration; no new aspect, restriction, unit, instantiation or elaboration route'
        elif name in {'No_Implementation_Identifiers','No_Implementation_Units','No_Calendar'}:
            classification='fixed source names Main/Silver_IO/Put/Put_Line and fixed with closure; literal contents are not identifiers or with clauses'
        elif name in {'No_Default_Stream_Attributes','No_Streams','No_Stream_Optimizations','No_Fixed_IO','No_Enumeration_Maps'}:
            classification='no attribute/stream/fixed-point/enumeration operation; only the two fixed String-accepting subprogram calls'
        elif name in {'No_Access_Parameter_Allocators','No_Anonymous_Allocators','No_Coextensions',
                      'No_Dynamic_Accessibility_Checks','No_Implicit_Dynamic_Code','No_Implicit_Heap_Allocations',
                      'No_Local_Tagged_Types','No_Nested_Finalization','No_Standard_Allocators_After_Elaboration',
                      'No_Tagged_Type_Registration','No_Exception_Registration'}:
            classification='no source declaration, allocator, access/tagged/controlled/exception object or nested callback; accepted literal lowering has no transient block, secondary-stack action, finalizer or variable-size temporary'
        else:
            classification='no task/protected/entry/select/abort/delay/interrupt/priority/timing feature or generated task object in the selected literal/null projection'
        partition.append(dict(restriction=name,classification=classification,
            fixed_witnesses=violations.get(name.upper(),[])))
    return {'consumer-inventory.json':[dict(id=i,fields=f,writer=w,reader=r,consumer=c,argument=a) for i,f,w,r,c,a in ROWS],
        'source-excerpts.json':excerpts,'bindgen-occurrences.json':census,
        'fixed-ali-projection.json':closure,'restriction-partition.json':partition}

if __name__=='__main__':
    for name,value in make().items():
        (HERE/name).write_text(json.dumps(value,indent=2)+'\n')
