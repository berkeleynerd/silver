#!/usr/bin/env python3
"""Focused #194 source/shape/arithmetic checks; no native or predecessor replay."""
from dataclasses import replace
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time
import capacity as c

start = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = json.loads((HERE/'source-manifest.json').read_text())
sources = {}
with tarfile.open(HERE/'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(x['path'] for x in manifest['files'])
    for row in manifest['files']:
        data = archive.extractfile(row['path']).read()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
        if 'repository_path' in row:
            assert data == (ROOT/row['repository_path']).read_bytes()
        sources[row['path']] = data.decode()
for row in json.loads((HERE/'inputs.json').read_text())['files']:
    assert sha((ROOT/row['path']).read_bytes()) == row['sha256'], row['path']
S=lambda p:sources['spark-source/src/'+p]
A=lambda p:sources['silver/src/'+p]
reporter=S('gnatprove/spark_report.adb')
sarif=S('gnatprove/spark_report-generate_sarif_report.adb')
parent=S('gnatprove/gnatprove.adb')
assert reporter.index('Generate_SARIF_Report\n     (Ada.Directories.Compose') < reporter.index('GNAT.OS_Lib.OS_Exit (Error_Code)')
assert 'elsif Status /= 0 and then Status /= Unproved_Checks_Error_Status then' in parent
assert 'Success_Exit_Code := Ada.Command_Line.Exit_Status (Status);' in parent
for source in (reporter,sarif):
    block=source[source.index('      procedure Local_Handle_SPARK_File\n        (Item'):]
    block=block[:block.index('      end Local_Handle_SPARK_File;')]
    assert 'when ' in block and 'others =>' in block and 'skipping' in block
    assert 'Error_Code :=' not in block
assert 'Has_Field (Info, "assumptions") and then Get (Info, "assumptions") = True' in reporter
assert 'if Assumptions and then Has_Field (Dict, "assumptions") then' in reporter
assert 'if Assumptions then\n      Compute_Assumptions;' in reporter
assert 'return Integer ((Float (100 * Part)) / Float (Total));' in reporter
assert 'Max_Time : constant Natural := Integer (PC.Max_Time);' in reporter
assert 'Elt.Count := Integer_Percent (Elt.Count, VC_Total);' in reporter
assert 'Map : Prover_Stat_Maps.Map := Prover_Stat_Maps.Empty_Map;' in reporter
assert 'Most_Difficult_Proved_Checks.Length > 10' in S('gnatprove/report_database.adb')
assert "Integer'Image (S)'Length <= 10" in S('gnatprove/print_table.adb')
assert len(' '+str(c.I)) == 11  # do not inherit that source assumption
ass=S('common/assumption_types.adb')
assert 'Subp_Map.Clear;\n      Subp_Vector.Clear;' in ass
assert 'Index : constant Positive := Positive\'Value (Name);' in ass
assert 'Subp_Vector.Set_Length (Ada.Containers.Count_Type (Index));' in ass
assert 'Find (Symbol_Table, Name)' in ass and 'Find (Symbol_Table, File)' in ass
why=sources['why3/src/gnat/gnat_checks.ml']
assert 'stat.Gnat_report.count <- stat.Gnat_report.count + 1;' in why
assert 'stat_checkers := !stat_checkers + 1' in why
assert 'GoalSet.iter (extract_stat_goal c stats stat_checkers) check_rec.toplevel;' in why
assert 'prover_name = "Checker"' in sources['why3/src/gnat/gnat_report.ml']
assert 'stats_count=5, stats_key_bytes=7' in (HERE.parent/'retained-producer-report-capacity-20261024/capacity.py').read_text()

# Complete required set/control, current implementation guards and erased state.
lib=A('silver_libraries.adb')
assert 'for Kind in Silver_Library_Reports.Report_Kind loop' in lib
for name in c.REQUIRED_OUTPUT[1:]: assert '"'+name+'"' in lib
assert 'main~1.spark' in A('silver.adb')
reader=A('silver_report_reader.adb')
assert "Next.Length > Buffer'Length - Last" in reader
assert all(x in reader for x in ('C_Get (File)', 'C_Error (File)', 'C_Close (File)'))
assert all(x in A('silver_libc.ads') for x in ('fgetc','ferror','fclose'))
assert 'Ghost => Static' in A('silver_report_reader.ads')
assert 'Ghost => Static' in A('silver_report_projection_audit.ads')
assert 'if Space (Item) then\n            if Keeping then Emit (Item); end if;' in A('silver_report_projection.adb')
assert 'Max_Depth : constant Positive := 64' in A('silver_report_projection_types.ads')
assert 'Max_Report_Length : constant Positive := 16_777_216' in A('silver_library_reports.ads')
assert 'Max_Runtime_Report_Length : constant Positive := 262_144' in A('silver_library_reports.ads')
audit=A('silver_library_reports.adb')
for term in ['Tail /= Text\'Length + 1','JSON_skip_flow_proof','JSON_skip_proof','JSON_pragma_assume',
             'Entities_OK (Text, Entities, Kind)', 'Coverage_OK', 'Dependencies_OK', 'Postconditions']:
    assert term in audit
assert 'Number : constant String := Text (Arg.First .. Arg.Last);' in audit
assert 'return " " & Text (Arg.First .. Arg.Last);' in audit
assert 'Default_Exception_Msg_Max_Length : constant := 200;' in sources['installed-runtime/s-parame.ads']
assert 'Msg : String (1 .. Exception_Msg_Max_Length);' in sources['installed-runtime/a-except.ads']
wild=sources['installed-runtime/g-diopit.adb']
assert 'Buffer : String (1 .. 2_048);' in wild
assert 'if Suffix_Pattern = "" then' in wild and 'Index := Index + 1;' in wild

# Newly populated record layouts, using the accepted selected-ABI method.
# Recheck new types only; fixed layouts are imported provider results below.
spec=re.sub(r'--[^\n]*|"(?:[^"]|"")*"',lambda m:'' if m[0].startswith('--') else m[0],
            sources['sarif-ada/src/generated/sarif-types.ads'])
records={}
for m in re.finditer(r'\btype\s+(\w+)(\s*\([^;]*?\))?\s+is\s+record\s+(.*?)end record;',spec,re.S):
    records[m[1].lower()]=(bool(m[2]),re.findall(r'^\s*\w+\s*:\s*([\w.]+)',m[3],re.M))
assert 'type suppression_kind is (inSource, external);' in spec
leaves=set()
def size(name):
    name=name.lower().removeprefix('sarif.types.')
    if name not in records:
        assert (name in {'boolean','integer','float','any_object','vss.strings.virtual_string','enum.suppression_kind'}
                or name.startswith('enum.optional_') or name.endswith('_vector')),name
        leaves.add(name)
        return 128
    discr,fields=records[name]
    return 16+16*discr+sum(size(x) for x in fields)
for name in ['result','location','logicalLocation','suppression']:
    assert size(name)==c.SARIF_SIZES[name]
old=json.loads((HERE.parent/'retained-producer-sarif-capacity-20261018/check-results.json').read_text())
for name in ['reportingDescriptor','invocation','run']:
    assert old['selected_ABI_record_upper_bounds'][name]==c.SARIF_SIZES[name]
body=sources['sarif-ada/src/generated/sarif-types.adb']
for name in ['result','location','logicalLocation','suppression']:
    assert f'new {name}_Array (1 .. 3 * Self.Length / 2)' in body
    assert f"new {name}_Array'(Self.Data (1 .. Self.Length))" in body
vss=sources['vss-text/source/text/implementation/vss-implementation-string_vectors.adb']
assert 'Mutate (Self, 1, 0);' in vss
assert 'Required > Natural\'Last - Reserved' in vss
assert 'Required + Reserved' in vss and 'Min_Mul_Alloc - 1' in vss
assert 'Reference (Self.Data (Self.Last));' in vss
assert 'raise Ada.Assertions.Assertion_Error;' in sources['vss-extra/source/json/implementation/vss-json-content_handlers.adb']
# #203: JSON serializer output stays ASCII; decoded ordinary text can encode.
assert "Wide_Wide_Character'Pos (W_Chr) >= 16#80#" in sources['gnatcoll/core/src/gnatcoll-json-utility.adb']
assert "File.Col := File.Col + 1;" in sources['installed-runtime/a-textio.adb']
assert 'Put_Encoded (File, Item);' in sources['installed-runtime/a-textio.adb']
assert 'WCEM_UTF8' in sources['gcc/ada/libgnat/s-wchcnv.adb']
# #205: default iteration excludes runtime/config; artifact is selected object dir.
assert 'Kind   : Project.Iterator_Control := Project.Default_Iterator;' in sources['gpr2/src/lib/gpr2-project-tree.ads']
assert 'I_Runtime       => False' in sources['gpr2/src/lib/gpr2-project.ads']
assert 'I_Configuration => False' in sources['gpr2/src/lib/gpr2-project.ads']
assert 'return Tree.Root_Project.Object_Directory.Virtual_File;' in S('gnatprove/configuration.adb')
assert 'My_Run.results := My_Results;' in sarif and 'Root.runs.Append (My_Run);' in sarif
assert 'Result.arguments.Append (To_Virtual_String (Arg));' in sarif

# Small exact configuration serialization witnesses; path escaping is charged.
configs=[]
for output,brief in [(False,False),(True,False),(False,True),(True,True)]:
    conf=c.configuration(project_path_bytes=7,object_dir_bytes=9,output_mode=output,brief=brief)
    args=['p'*7 if x is None else x for x in conf['argv']]
    actual={'obj_dirs':['o'*9],'cmdline':args,'proof_switches':{},'mode':'GPM_ALL',
            'has_errors':False,'colors':False}
    encoded=json.dumps(actual,separators=(',',':'))+'\n'
    assert len(encoded)<=conf['config_file_bytes']
    assert len(' '.join(args))==conf['joined_command_bytes']
    assert conf['parent_summary_output_bytes']==2*conf['parent_summary_line_characters']+1
    assert conf['parent_counter_join_required']
    configs.append(dict(output=output,brief=brief,argv_count=conf['argv_count'],
                        joined_constant=conf['joined_command_bytes']-7,
                        config_constant=conf['config_file_bytes']-6*(7+9)))
assert [x['joined_constant'] for x in configs]==[213,216,228,231]
assert [x['config_constant'] for x in configs]==[349,352,366,369]

# Mathematical boundary checks; no native allocation and no source-limit choice.
v=c.vector(167,c.SARIF_SIZES['reportingDescriptor'])
assert v['capacity']==211 and v['multiply']==423
assert c.vector(c.I,c.SARIF_SIZES['result'])['guards']['length']
assert not c.vector(c.I,c.SARIF_SIZES['result'])['guards']['growth']
assert 100*(c.I//100)<=c.I and 100*(c.I//100+1)>c.I
example_source=dict(frontend_nodes=0,entities=0,list_headers=0,why_allocations=0,
     name_bytes=4,full_name_bytes=4,magic_bytes=6,path_bytes=416,instantiation_edges=0,
     records=0,goals=0,attempts=0,launches=0,expression_bytes=0)
unit=c.selected_unit(**example_source)
example=c.compose({n:example_source for n in c.REQUIRED_OUTPUT},output_mode=True,brief=True,
     project_path_bytes=416,object_dir_bytes=416,path_bytes=512,initial_cwd_bytes=128,max_path=4096,page_size=4096,
     version_bytes=258,duration_ceiling=1_000_000)
assert example['required']==list(c.REQUIRED_OUTPUT)
assert example['source_inputs_bound'] is False and example['admission_decision'] is False
assert example['collector']['find_calls']==5
assert example['collector']['prover_cell_bytes']==82
assert example['path_domain_join'] and max(example['path_demands'].values()) <= 512
assert example['collector']['failure_explicit_lines']==5*5+3
assert example['collector']['no_check_output_characters']>0
assert example['collector']['text_output_bytes']==2*example['collector']['text_output_characters']
assert example['collector']['failure_output_bytes']==2*example['collector']['failure_output_characters']
# Common path scalar is checked against every named source/configuration role.
short_path=c.compose({n:example_source for n in c.REQUIRED_OUTPUT},output_mode=True,brief=True,
     project_path_bytes=416,object_dir_bytes=416,path_bytes=416,initial_cwd_bytes=128,
     max_path=4096,page_size=4096,version_bytes=258,duration_ceiling=1_000_000)
assert not short_path['path_domain_join'] and not short_path['consumer_native_guards']
# This tests arithmetic for a deliberately unbound descriptor, not a fixed-unit fit.
try:
    c.compose({},output_mode=True,brief=True,project_path_bytes=416,object_dir_bytes=416,
        path_bytes=512,initial_cwd_bytes=128,max_path=4096,page_size=4096,version_bytes=258,duration_ceiling=1)
except ValueError: pass
else: raise AssertionError('missing required source binding accepted')
# Independent raw/projected guards: discarded raw bytes do not consume buffer;
# discarded raw depth remains checked.
large=dict(unit,full=replace(unit['full'],pretty=20_000_000,depth=65))
test=c.silver_reader(large,kind='main',path_bytes=416)
assert test['guards']['current_buffer'] and not test['guards']['raw_projection_depth']
assert test['raw_native_byte_counter'] is False
assert unit['silver_projected_file_bytes']==unit['projected'].pretty+1
# Keep supplied error/callback/save accounting entirely outside this consumer.
assert 'abort_attempts' not in (HERE/'capacity.py').read_text()
result=dict(status='focused source/shape/arithmetic checks passed; source bindings remain conditional',
    complete_source_files=len(sources),new_layout_bytes={k:c.SARIF_SIZES[k] for k in ['result','location','logicalLocation','suppression']},
    imported_fixed_layouts={k:c.SARIF_SIZES[k] for k in ['reportingDescriptor','invocation','run']},
    scalar_handle_leaves=sorted(leaves),configuration_cases=configs,
    orientation_example=example,
    compiler_runs=0,prover_runs=0,solver_runs=0,predecessor_checker_replays=0,
    elapsed_seconds=round(time.monotonic()-start,6))
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['status','complete_source_files','elapsed_seconds']}))
