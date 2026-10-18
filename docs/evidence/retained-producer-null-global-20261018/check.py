#!/usr/bin/env python3
"""Offline source checks and null GG/report arithmetic; no toolchain execution."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


def main():
    identity = json.loads((HERE/'identity.json').read_text())
    sources = {}
    for row in identity['archives']:
        path = PROJECT/row['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        with tarfile.open(path) as archive:
            for item in row['files']:
                data = archive.extractfile(item['member']).read()
                assert len(data) == item['bytes']
                assert hashlib.sha256(data).hexdigest() == item['sha256']
                sources[item['name']] = data.decode()
    for item in identity['local_files']:
        data = (PROJECT/item['path']).read_bytes()
        assert len(data) == item['bytes']
        assert hashlib.sha256(data).hexdigest() == item['sha256']
        sources[item['path']] = data.decode()

    def has(name, fragment):
        assert ' '.join(fragment.split()) in ' '.join(sources[name].split()), name

    has('driver', 'Action (Standard_Package_Node);')
    has('driver', 'if Present (Cunit (U)) and then Analyzed (Unit (Cunit (U))) then')
    has('compilation_units', 'SPARK_Implicit_Load (RE_Interrupt_Priority);')
    has('runtime_loading', 'Discard_Node (RTE (E));')
    has('runtime_loading', 'Semantics (Cunit (U.Unum));')
    has('runtime_loading', 'Maybe_Add_With (U);')
    has('subprogram_semantics', 'Analyze (Decl); Remove (Decl); Set_Has_Completion (Op_Name);')
    system_source = sources['docs/evidence/retained-producer-null-global-20261018/system.ads']
    assert re.findall(r'function\s+"([<>=]+)"', system_source) == ['<','<=','>','>=','=']
    historical_ali = sources['docs/evidence/retained-producer-fixed-20261018/main.ali']
    assert len(re.findall(r'^GG EK_FLOW_SCOPE ', historical_ali, re.M)) == 7
    assert 'Z system%s' in historical_ali
    installed_ali = sources['docs/evidence/retained-producer-null-global-20261018/system.ali']
    assert not re.search(r'^(?:W |Y |Z |QQ |GG )', installed_ali, re.M)
    has('visibility', 'Hierarchy_Info.Insert (E, Info);')
    has('visibility', 'if Unit_Node = Standard_Package_Node then')
    has('visibility', 'Process (Hierarchy_Info_Maps.Key (C), Hierarchy_Info (C));')
    has('traversal', 'Scope_Map.Insert (Key => E, New_Item => (Units => <>, Parent => P));')
    has('write', 'if E = Standard_Standard then "__standard" else Unique_Name (E)')
    has('unique_names', 'if Ekind (U) = E_Package or else Is_Subprogram (U) then return This_Name;')
    has('partial', 'GG_Register_Calls (E, Contr.Direct_Calls, EK_Direct_Calls);')
    has('partial', 'GG_Register_Calls (E, Contr.Proof_Dependencies, EK_Proof_Dependencies);')
    has('phase1', 'New_GG_Line (EK_End_Marker);')
    has('read', 'Set_Unbounded_String (Buffer, Line (Line\'First + 3 .. Line\'Last));')
    has('read', 'Token_Start := Last + 1;')
    has('phase2', 'Global_Contracts.Insert (Standard_Standard, Position => Position, Inserted => Inserted);')
    has('phase2', 'Phase_1_Info.Insert (Standard_Standard, Position => Position, Inserted => Inserted);')
    has('phase2', 'Patches.Append (Global_Patch\'(Entity => Folded, Contract => Update));')
    has('phase2', 'Name => Main_Entity_Name, Instances => 1, Node => S')
    has('phase2_traversal', 'Scope_Map (Outer_Pos).Units.Include (Entity);')
    has('phase2_visibility', 'Add (Map => Children, Key => Info.Parent, New_Item => E);')
    has('gnatprove', 'Args.Append ("-gnatR2js");')
    has('switches', 'Back_Annotate_Rep_Info := True;')
    has('switches', "when 'm' => List_Representation_Info_Mechanisms := True;")
    has('options', 'List_Representation_Info_Mechanisms : Boolean := False;')
    has('repinfo', 'if In_Extended_Main_Source_Unit (Cunit_Entity (U)) then')
    has('repinfo', 'if List_Representation_Info_Mechanisms and then Is_Subprogram_Or_Entry (Ent) and then not In_Subprogram then')
    has('repinfo', 'if List_Representation_Info_To_JSON then Write_Line ("]"); end if; Cancel_Special_Output; Close_Repinfo_File;')
    has('repinfo', "Write_Repinfo_Line (S (S'First .. S'Last - 1));")
    has('osint', "Write_With_Check (Info'Address, Info'Length); Write_With_Check (EOL'Address, 1);")
    has('data_decomposition', 'for Index in 1 .. Length (Entries) loop Handle_Entry (Get (Entries, Index)); end loop;')
    has('data_decomposition', 'File_Names.Insert (Source_File_Name);')
    has('gnatprove', 'Set_Field (JSON_Rec, "cmdline", Cmdline_JSON);')
    has('gnatprove', 'Set_Field (JSON_Rec, "proof_switches", FS_Switches_JSON);')
    has('gnatprove', 'if CL_Switches.Output_Header then')
    has('command_line_spec', 'Value : Boolean := True);')
    assert 'Output is always initially set to "not Value"' in sources['command_line_spec']
    has('mode', "return Create (GP_Mode'Image (M));")
    has('report', 'Generate_SARIF_Report (Ada.Directories.Compose')
    has('report', 'if Assumptions and then Has_Field (Dict, "assumptions") then')
    has('assumption_types', 'Subp_Map.Clear; Subp_Vector.Clear;')
    has('assumption_types', 'Subp_Vector.Replace_Element (Index, Elt);')
    has('database', 'Subp_Unit_Map.Include (Subp, Unit);')
    has('buffer', 'Result.Buffer_Str := new String (1 .. Integer (FD_Size));')
    has('table', 'Max_Width : Width_Array := (others => 10);')
    has('table', 'Length (T.Content (Line, Col).Content) + 3;')
    has('table', 'if S = 0 then Put_Cell (T, " .", Align);')

    gg = {
        'direct': ['EK_DIRECT_CALLS','main','0'],
        'proof': ['EK_PROOF_DEPENDENCIES','main','0'],
        'globals': ['EK_GLOBALS','main','local','FALSE','E_PROCEDURE','FALSE','ORIGIN_FLOW','0']
          + [x for prefix in ['proper_','refined_'] for kind in ['proof_in','input','output'] for x in [prefix+kind,'0']]
          + [x for kind in ['calls_proof','calls','calls_conditional'] for x in [kind,'0']]
          + ['FALSE']*6
          + [x for kind in ['ENTRY_CALLS','SUSPENDS_ON','UNSYNCH_ACCESSES'] for x in [kind,'0']],
        'scope': ['EK_FLOW_SCOPE','main']+['FALSE']*5+['__standard'],
        'scope_system': ['EK_FLOW_SCOPE','system']+['FALSE']*5+['__standard'],
        'end': ['EK_END_MARKER'],
    }
    # Full ten-digit homonym suffix is conservative; the selected fixed source
    # has one declaration per operator. Boolean width placeholders are not
    # claimed to be a parseable actual row.
    for name in ['Olt','Ole','Ogt','Oge','Oeq']:
        gg['scope_'+name] = ['EK_FLOW_SCOPE','system__'+name+'__2147483647']+['FALSE']*5+['system','VISIBLE_PART']
    gg_lines = {k:'GG '+' '.join(v) for k,v in gg.items()}
    lengths = {k:len(v) for k,v in gg_lines.items()}
    assert lengths == {'direct':25,'proof':31,'globals':288,'scope':62,'scope_system':64,'end':16,
                       **{'scope_'+name:90 for name in ['Olt','Ole','Ogt','Oge','Oeq']}}
    frontier = [{'line':sources['phase1'].count('\n',0,m.start())+1,'argument':m.group(1)}
                for m in re.finditer(r'New_GG_Line\s*\((\w+)\)',sources['phase1'])]

    # PATH is charged at six emitted JSON bytes for each path byte.
    path = object()
    args = ['gnatprove','-P',path,'-U','--mode=all','--report=all',
            '--warnings=error','--checks-as-errors=on','--level=2',
            '--prover=cvc5,z3,altergo','--steps=100000','--timeout=0',
            '--memlimit=1000','-j0','--no-loop-unrolling']
    for arg in args[3:]:
        assert arg in sources['src/silver.adb']
    configuration = {'obj_dirs':[path], 'cmdline':args, 'proof_switches':{},
                     'mode':'GPM_ALL','has_errors':False,'colors':False}

    def size(v):
        if v is path:
            return 2,6
        if isinstance(v,dict):
            children = [(len(json.dumps(k))+1+a,b) for k,value in v.items() for a,b in [size(value)]]
        elif isinstance(v,list):
            children = [size(x) for x in v]
        else:
            return len(json.dumps(v,separators=(',',':'))),0
        return 2+max(0,len(v)-1)+sum(a for a,b in children),sum(b for a,b in children)

    config_constant,config_coefficient = size(configuration)
    joined_constant = sum(len(v) for v in args if v is not path)+len(args)-1
    assert len(args) == 15 and joined_constant == 181

    # Reconstruct ordinary output using its actual formatting branches.
    labels = ['Data Dependencies','Flow Dependencies','Initialization',
              'Non-Aliasing','Run-time Checks','Assertions','Functional Contracts',
              'LSP Verification','Termination','Concurrency','Total']
    header = ['SPARK Analysis results','Total','Flow','Provers','Justified','Unproved']
    for label in labels+header:
        assert '"'+label+'"' in sources['report']
    cells = [header]+[[label]+[' .']*5 for label in labels]
    widths = [max(10,max(len(row[i])+3 for row in cells)) for i in range(6)]
    width = sum(widths)
    table = '-'*width+'\n'
    for index,row in enumerate(cells):
        table += ''.join(s.ljust(w) if i == 0 else s.rjust(w) for i,(s,w) in enumerate(zip(row,widths)))+'\n'
        if index in [0,len(cells)-2]:
            table += '-'*width+'\n'
    def ordinary(p):
        return ('=========================\nSummary of SPARK analysis\n=========================\n\n'
                +table+'\n\n'
                +'max steps used for successful proof: 0\n\n'
                +'============================\nMost difficult proved checks\n============================\n\n'
                +'No check found with max time greater than 1 second\n\n'
                +'========================\nDetailed analysis report\n========================\n\n'
                +'Analyzed 1 unit\n'
                +'in unit main, 1 subprograms and packages out of 1 analyzed\n'
                +'  Main at '+'F'*p+':2147483647'
                +' flow analyzed (0 errors, 0 checks, 0 warnings and 0 pragma Assume statements)'
                +' and proved (0 checks)\n')
    assert len(cells) == 12 and max(map(len,sum(cells,[]))) == 22 and width == 78
    result = {
        'native_or_proof_executions':0,
        'source_class':'Same Required_Tokens null family with permitted ASCII case/trivia and existing frontend location conditions',
        'visibility_vertices_per_graph':17, 'visibility_edges_per_graph':289,
        'visibility_hierarchy_entries':7,'visibility_children_keys':1,
        'visibility_children_set_entries':2,'visibility_nested_keys':1,
        'visibility_nested_set_entries':5,
        'generated_global_rows':gg_lines,
        'generated_global_line_byte_bounds':lengths,
        'generated_global_total_bytes_with_lf':sum(lengths.values())+len(lengths),
        'generated_global_row_count':len(lengths),
        'installed_system_ali_bytes':len(installed_ali.encode()),
        'installed_system_ali_longest_line':max(map(len,installed_ali.splitlines())),
        'installed_system_ali_invocation_constructs':len(re.findall(r'^G c ',installed_ali,re.M)),
        'installed_system_ali_has_gg_or_with_rows':False,
        'qq_header_bytes_with_lf':'16 + configured fixed version-string length',
        'gg_reader_buffer_bytes':max(lengths.values())-3,
        'gg_reader_cursor_maximum':max(lengths.values())-2,
        'gg_longest_token':max((s for row in gg.values() for s in row),key=len),
        'gg_emission_source_frontier':frontier,
        'phase1_scope_contract_entries':1,'phase2_scope_contract_entries':2,
        'global_fold_patch_count':2,'global_scope_recursion_depth':2,
        'main_task_instances':1,'main_only_call_graph_vertices':1,
        'data_representation_file_bytes':4,'data_representation_entries':0,
        'data_representation_read_filename_keys':1,
        'data_representation_uint_field_conversions':0,
        'data_representation_native_variant_requires_backannotation_join':True,
        'configuration_fields':len(configuration),
        'configuration_depth':2,'configuration_array_max':len(args),
        'configuration_array_backing_capacity':16,
        'configuration_compact_bytes':{'constant':config_constant,'path_byte_coefficient':config_coefficient},
        'configuration_file_bytes':{'constant':config_constant+1,'path_byte_coefficient':config_coefficient},
        'joined_command_bytes':{'constant':joined_constant,'project_path_byte_coefficient':1},
        'report_parser_and_wrappers_live_reference_bound':42+4,
        'report_consumer_live_reference_bound':8,
        'report_assumption_pool_finds':5,'report_assumption_pool_distinct_strings':3,
        'report_hashcons_main_records':1,'report_unit_subprogram_entries':1,
        'summary_table_rows':len(cells),'summary_table_columns':6,
        'summary_table_cells':len(cells)*6,'summary_table_max_cell_length':22,
        'summary_table_column_widths':widths,'summary_table_row_width':width,
        'ordinary_output_bytes':{'constant':len(ordinary(0)),'filename_byte_coefficient':1},
        'path_evaluations':[],
        'scope':'Selected GG metadata and ordinary report consumers, corrected for GNATprove implicit analyzed System; generic frontend ALI, SARIF/VSS, project/process orchestration and remaining fixed startup are separate joins.'
    }
    for p in [222,256,4096]:
        data = ordinary(p)
        config_bytes = config_constant+config_coefficient*p+1
        assert config_bytes <= 65536
        result['path_evaluations'].append({'path_bytes':p,'configuration_file_bytes':config_bytes,
            'joined_command_bytes':joined_constant+p,'ordinary_output_bytes':len(data),
            'ordinary_output_longest_line':max(map(len,data.split('\n'))),
            'configuration_fits_small_file_reader':config_bytes<=65536})
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['generated_global_total_bytes_with_lf','configuration_file_bytes','ordinary_output_bytes']}))


if __name__ == '__main__':
    main()
