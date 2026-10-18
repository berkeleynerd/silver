#!/usr/bin/env python3
"""Reconcile the indexed Main invocation delta offline; execute no compiler.

Whole-file identities and source assertions bind a manually reviewed argument.
This is not a verified GPR/GCC evaluator or a complete capacity predicate.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--ada', type=Path, required=True)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--gpr-root', type=Path, required=True)
parser.add_argument('--repair-tree', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'indexed-invocation-source-identity.json').read_text())
roots = dict(ada=args.ada, gcc=args.gcc_root, gpr=args.gpr_root,
             repair=args.repair_tree, evidence=root,
             closure=root.parent / 'retained-source-closure-20261017')
sources = {}
for row in identity['files']:
    raw = (roots[row['root']] / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row
    name = row['path']
    if row.get('compression') == 'gzip':
        raw = gzip.decompress(raw)
        assert len(raw) == row['decoded_bytes'], row
        assert hashlib.sha256(raw).hexdigest() == row['decoded_sha256'], row
        name = name.removesuffix('.gz')
    sources[row['root'] + '/' + name] = raw.decode()

anchors = {
    'repair/src/silver.adb': [
        'for Body (""Main"") use ""main.adb"" at 1;',
        '""-gnat2022"", ""-gnata"", ""-gnato""'],
    'gpr/src/gprbuild-compile.adb': [
        'elsif Id.Index /= 0 then', 'Get_Name_String (Id.Object)',
        'Add_Str_To_Name_Buffer (Index_Img (2 .. Index_Img\'Last));',
        "Source.Index'Img;", 'Config.Config_Body_Index',
        'Add_Object_File_Switches (Id);', 'Add_Multi_Unit_Switches (Id);'],
    'ada/gcc-interface/lang-specs.h': ['%{!S:%{o*:%w%*-gnatO}}'],
    'gcc/gcc/gcc.cc': ['give_switch (i, 1);', '/* Pass any arguments this switch has.  */'],
    'ada/gcc-interface/misc.cc': [
        'save_argv = XNEWVEC (const char *, 2 * decoded_options_count + 1);'],
    'ada/switch-c.adb': [
        'Scan_Pos (Switch_Chars, Max, Ptr, Multiple_Unit_Index, C);',
        "when 'O' =>\n               Store_Switch := False;"],
    'ada/back_end.adb': ['Arg_Count : constant Natural := Natural (save_argc - 1);',
                         'Set_Output_Object_File_Name (Argv);'],
    'ada/par-prag.adb': ['Unam := Get_Unit_Name (Expr1);',
                       'Set_File_Name\n                    (Unam, Get_Fname (Arg2), Index);'],
    'ada/uname.adb': ['return Name_Find (Unit_Name_Buffer);'],
    'ada/fname-uf.adb': ['SFN_Table.Increment_Last;',
                       'SFN_HTable.Set (U, SFN_Table.Last);',
                       'type SFN_Header_Num is range 0 .. 100;'],
    'ada/alloc.ads': ['SFN_Table_Initial                : constant := 10;',
                     'SFN_Table_Increment              : constant := 200;'],
    'ada/libgnat/s-htable.adb': ["Tab.Set (new Element_Wrapper'(K, E, null));"],
    'ada/osint-c.adb': ["Output_Object_File_Name := new String'(Name);",
                       'Add_Char_To_Name_Buffer (Multi_Unit_Index_Character);'],
    'ada/sinput-l.adb': ['if Multiple_Unit_Index = 0 then',
                       'if Source_File.Table (J).File_Name = N then'],
    'ada/lib-load.adb': ['Src_Ind := Load_Source_File (Fname);',
                        'Multiple_Unit_Index := Get_Unit_Index (Uname_Actual);'],
    'ada/lib-writ.adb': ['Source_Index           => System_Source_File_Index,',
                        'Initialize_Scanner (Units.Last, System_Source_File_Index);'],
    'ada/par.adb': ['if Ucount < Multiple_Unit_Index then', 'exit when Token = Tok_EOF;'],
    'ada/sem_prag.adb': ['when Pragma_Source_File_Name_Project =>'],
}
for name, values in anchors.items():
    for value in values:
        assert value in sources[name], (name, value)

historical = json.loads(sources['evidence/native-invocation-inputs.json'])
assert historical['native_GCC_argument_count'] == 10
assert historical['gnat1_argc_bound'] == 19
assert historical['Compilation_Switches_count'] == 6
launch = historical['native_GCC_argv_excluding_executable'] + ['-o', 'main~1.o', '-gnateI1']
assert len(launch) == 13
gnat1 = dict(historical['source_derived_gnat1_argv_allowance'])
gnat1['indexed_unit_switch'] = 1
gnat1['explicit_object_output_pair'] = 2
argc = sum(gnat1.values())
assert argc == 22
stored = [s[2:] for s in sources['evidence/indexed-main-observation/main~1.ali'].split('\n')
          if s.startswith('A ')]
assert stored == historical['Compilation_Switches'][:4] + ['-gnateI1'] + historical['Compilation_Switches'][4:]
assert 'U main%b\t\tmain.adb\t' in sources['evidence/indexed-main-observation/main~1.ali']
assert 'for Body ("Main") use "main.adb" at 1;' in sources['evidence/indexed-main-observation/program.gpr']
assert len(stored) == 7
ali_a_bytes = sum(3 + len(s) for s in stored)
assert ali_a_bytes == 83

# Source-derived new config line, not a retained generated temporary file.
xml = sources['closure/driver-snapshots/native-gnat.xml']
template, = re.findall(r'Config_Body_File_Name_Index\s*\("Ada"\)\s*use\s*\n\s*"(.*?)";', xml)
template = template.replace('""', '"')
line = template.replace('%u', 'main').replace('%f', 'main.adb').replace('%i', ' 1') + '\n'
assert line == (root / 'indexed-naming-pragma-derived.adc').read_text()
assert len(line) == 83
old_config = sources['closure/driver-snapshots/293256/GNAT-TEMP-000002.TMP']
assert len(old_config) == 244
tokens = re.findall(r'"(?:""|[^"])*"|[A-Za-z][A-Za-z_0-9]*|[0-9]+|=>|[^\s]', line)
words = [t for t in tokens if re.fullmatch('[A-Za-z][A-Za-z_0-9]*', t)]
strings = [t[1:-1] for t in tokens if t.startswith('"')]
numerals = [t for t in tokens if t.isdigit()]
assert len(words) == 5 and strings == ['main.adb'] and numerals == ['1']
assert tokens.count('=>') == 2 and tokens.count(',') == 2
nodes = 2 * (len(words) + len(strings) + len(numerals)) + 1 + 3
assert nodes == 18
config_delta = dict(
    evidence_kind='source-derived additive line; no generated indexed .adc was retained',
    source_bytes=83, composed_configuration_bytes=244 + 83,
    LF_count=1, maximum_line_characters=82,
    ordinary_node_allowance=nodes, dynamic_slot_allowance=9 * nodes,
    syntax_list_header_allowance=2,
    scanner_Name_entries=len(words), scanner_Name_characters=sum(map(len, words)) + len(words),
    helper_Name_spellings=['main%b', 'main.adb'], helper_Name_entries=2,
    helper_Name_characters=sum(len(s) + 1 for s in ['main%b', 'main.adb']),
    String_descriptors=2, String_characters=16,
    Uint_entries=0, Uint_digits=0, SFN_Table_entries=1, SFN_Patterns_entries=0,
    SFN_Table_record_bytes=12, SFN_Table_low=0, SFN_Table_initial=10,
    SFN_Table_increment_percent=200, SFN_Table_initial_object_bytes=120,
    SFN_hash_static_bucket_bytes=101 * 8, SFN_hash_new_wrapper_bytes=16,
    pattern_String_allocations=0,
    configured_source_cursor_alignment_delta_upper_bound=83 + 4095,
    observed_generated_config_file=False)

assert config_delta['scanner_Name_characters'] == 58
objects = dict(decoded_options=22 * 96, pruned_decoded_options=22 * 96,
               reconstructed_C_argv=(2 * 22 + 1) * 8,
               Ada_argument_pointer_array=(2 * 22 - 1) * 16 + 16,
               explicit_object_name_String=8 + 16)
assert objects == dict(decoded_options=2112, pruned_decoded_options=2112,
                      reconstructed_C_argv=360, Ada_argument_pointer_array=704,
                      explicit_object_name_String=24)
result = dict(
    scope='Current indexed native Main descriptor delta relative to historical unindexed descriptor; conditional research only',
    repair_commit=identity['repair_commit'], gcc_commit=identity['gcc_commit'], gpr_commit=identity['gpr_commit'],
    checked_source_and_fixture_identities=len(identity['files']),
    historical_descriptor='native-invocation-inputs.json',
    historical_arithmetic_outputs_are_current_indexed_evidence=False,
    native_GCC_argv_excluding_executable=launch, native_GCC_argument_count=len(launch),
    source_derived_gnat1_argv_allowance=gnat1, gnat1_argc_bound=argc,
    decoded_option_count_bound=argc, canonical_save_argc_bound=2 * argc,
    canonical_save_argv_pointer_count_including_sentinel=2 * argc + 1,
    Ada_argument_pointer_count_bound=2 * argc - 1,
    Compilation_Switches=stored, Compilation_Switches_count=len(stored),
    ALI_A_total_bytes_including_LF=ali_a_bytes,
    ALI_A_record_max_characters=max(2 + len(s) for s in stored),
    selected_single_object_bytes=objects, indexed_configuration_delta=config_delta,
    unchanged_author_source_filename='main.adb', unchanged_Main_entity='Main',
    changed_object_and_ALI_stem='main~1',
    null_source_buffer_reload_delta=0,
    null_source_buffer_premise='No semantic runtime load; Ensure_System_Dependency scans the saved startup System_Source_File_Index',
    general_indexed_Main_source_buffer_multiplicity_closed=False,
    required_controlled_environment=historical['required_controlled_environment'],
    required_default_search=historical['required_default_search'],
    required_path_premise=historical['required_path_premise'],
    actual_indexed_config_map_or_full_argv_retained=False,
    proof_producer_invocation_covered=False,
    fixed_capture_repeated=False,
    pending=['Join indexed config/tables/output-name metadata into full frontend and backend source-location accounting',
             'Reconcile general indexed Main source-load multiplicity before inheriting physical-runtime union',
             'Validate actual generated configuration/map/search inputs before launch',
             'Complete metadata/Main/unit shared-pool and downstream tool joins'],
    complete_capacity_result=False)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(identities=len(identity['files']), native_GCC_arguments=13,
                     gnat1_argc_bound=22, stored_switches=7, config_delta_bytes=83,
                     complete_capacity_result=False)))
