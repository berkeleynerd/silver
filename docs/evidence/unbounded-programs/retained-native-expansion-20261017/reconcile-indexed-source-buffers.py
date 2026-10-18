#!/usr/bin/env python3
"""Check indexed native Main's physical source-load correction offline."""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--ada', type=Path, required=True)
parser.add_argument('--native-runtime', type=Path, required=True)
parser.add_argument('--silver-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'indexed-source-buffer-identity.json').read_text())
roots = dict(ada=args.ada, silver=args.silver_root, evidence=root,
             closure=root.parent / 'retained-source-closure-20261017')
sources = {}
for row in identity['files']:
    raw = (roots[row['root']] / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row
    sources[row['root'] + '/' + row['path']] = raw.decode()

anchors = {
    'ada/lib-load.adb': [
        'if Unum > Units.Last and then Get_Unit_Index (Uname_Actual) = 0 then',
        'if Fname = Units.Table (J).Unit_File_Name then',
        'Unum := Unit_Names.Get (Uname_Actual);',
        'Src_Ind := Load_Source_File (Fname);',
        'Init_Unit_Name (Unum, Uname_Actual);'],
    'ada/lib.adb': ['Unit_Names.Set (Unit_Name (U), No_Unit);', 'Units.Decrement_Last;'],
    'ada/frontend.adb': ['if Source_File_Is_No_Body (Source_Index (Main_Unit)) then'],
    'ada/gnat1drv.adb': ['Check_Bad_Body (Main_Unit_Node, Main_Unit_Kind);',
                        'System_Source_File_Index := S;'],
    'ada/sem_ch3.adb': ['Find_Aspect (Id, Aspect_External_Initialization);'],
    'ada/sinput-l.adb': ['Source_File.Decrement_Last;',
                        'Alloc_Line_Tables (S, Opt.Table_Factor * Alloc.Lines_Initial);'],
    'ada/fname-uf.adb': ['return SFN_Table.Table (N).Index;'],
    'ada/alloc.ads': ['Lines_Initial                    : constant := 500;'],
    'ada/types.ads': ['Source_Align : constant := 2 ** 12;'],
}
for name, values in anchors.items():
    for value in values:
        assert value in sources[name], (name, value)

inventory = json.loads(sources['closure/source-inventory.json'])
loads = [x for x in inventory['gcc_inventory']['physical_load_occurrences']
         if x['operation'] == 'Load_Source_File' and x['file'] not in ['sinput-l.adb', 'sinput-l.ads']]
assert [(x['file'], x['line']) for x in loads] == [
    ('gnat1drv.adb', 809), ('gnat1drv.adb', 1066), ('lib-load.adb', 124),
    ('lib-load.adb', 332), ('lib-load.adb', 738), ('sem_ch3.adb', 4006)]
for item in loads:
    assert 'Load_Source_File' in sources['ada/' + item['file']].split('\n')[item['line'] - 1]
route_dispositions = [
    'Check_Bad_Body: only called on Main; subprogram body is outside load predicate',
    'Startup target parameters: one system.ads physical read before semantic unit load',
    'Change_Main_Unit_To_Spec: requires Main No_Body pragma; absent from admitted Main',
    'Load_Main_Source: one author source in this invocation',
    'Load_Unit: at most one successful physical read per non-indexed imported Fname',
    'External_Initialization: absent from admitted Main and selected fixed input bytes',
]

def digest(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
                git_blob_sha1=hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest())

def code_only(text):
    return re.sub(r'--[^\r\n]*|"(?:[^"]|"")*"|\'[^\'\r\n]\'',
                  lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), text)

runtime_rows = []
naming_pragmas = []
for path in sorted(args.native_runtime.rglob('*')):
    if not path.is_file():
        continue
    raw = path.read_bytes()
    name = path.relative_to(args.native_runtime).as_posix()
    runtime_rows.append(dict(path=name, **digest(raw)))
    if path.suffix.lower() not in ['.ads', '.adb']:
        continue
    code = code_only(raw.decode('latin-1'))
    assert not re.search(r'\bExternal_Initialization\b', code, re.I), name
    for match in re.finditer(r'\bpragma\s+Source_File_Name(?:_Project)?\s*\([^;]*;', code, re.I):
        naming_pragmas.append(dict(file=name, line=code.count('\n', 0, match.start()) + 1))
        assert not re.search(r'\bIndex\s*=>', match[0], re.I), name
assert naming_pragmas == [dict(file='memtrack.adb', line=69)]
manifest_digest = hashlib.sha256(json.dumps(runtime_rows, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
expected = inventory['installed_runtime_corpora']['native']
assert manifest_digest == expected['manifest_sha256']
assert len(runtime_rows) == expected['file_count'] == 1575
q = lambda b: 4096 * ((b + 4096) // 4096)
assert sum(q(x['bytes']) for x in runtime_rows) == expected['aligned_source_sum'] == 20496384
for name, text in sources.items():
    if name.startswith('silver/'):
        code = code_only(text)
        assert not re.search(r'\bExternal_Initialization\b|\bpragma\s+Source_File_Name', code, re.I), name

system = (args.native_runtime / 'system.ads').read_bytes()
assert len(system) == 7503
assert hashlib.sha256(system).hexdigest() == '545339a0b49ad059358dcfcc69d47d04dfb3e5acb245cb39a1d590b13d693c95'
assert not re.search(r'\bpragma\s+Source_Reference\b', code_only(system.decode()), re.I)
physical_lines = len(re.split(rb'\r\n|[\r\n]', system))
assert physical_lines <= 500
indexed = json.loads(sources['evidence/native-indexed-invocation.json'])
config_bytes = indexed['indexed_configuration_delta']['composed_configuration_bytes']
assert config_bytes == 327 and q(config_bytes) == q(244) == 4096

result = dict(
    scope='Native indexed single Main; physical source-buffer multiplicity correction only',
    gcc_commit=identity['gcc_commit'], checked_source_and_fixture_identities=len(identity['files']),
    source_load_routes=[dict(**row, disposition=why) for row, why in zip(loads, route_dispositions)],
    native_runtime_inventory=expected, nonindexed_runtime_naming_pragmas=naming_pragmas,
    imported_SFN_index_premise='Only generated main%b naming entry is indexed; all permitted imported unit indices are zero',
    request_name_premise='Retain controlled basename-to-source mapping and search closure; aliases must be counted separately',
    additional_nonnull_System_loads_upper_bound=1, additional_null_System_loads=0,
    additional_System_input=dict(**digest(system), physical_line_entries_bound=physical_lines,
                                 aligned_source_extent=q(len(system))),
    physical_runtime_aligned_extent_with_index_correction=20496384 + q(len(system)),
    additional_Source_File_records=1,
    additional_System_buffer_single_object_bytes_upper_bound=len(system) + 1 + 16,
    additional_System_line_table_capacity=500,
    additional_System_line_table_single_object_bytes=500 * 4,
    indexed_configuration_bytes=config_bytes, indexed_configuration_aligned_extent=q(config_bytes),
    source_union_formula='q(Main bytes) + 20504576 + selected Silver physical union + 4096 + aliases + virtual extents',
    source_cursor_limit=2147479551,
    prior_generic_one_buffer_per_request_name_premise_repaired_for_this_native_class=True,
    general_source_search_enforced=False, producer_scope_covered=False,
    frontend_all_tables_recomposed=False, complete_capacity_result=False,
    no_compiler_prover_or_capture_executed=True)
assert result['physical_runtime_aligned_extent_with_index_correction'] == 20504576
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(source_identities=len(identity['files']), runtime_files=1575,
                     source_load_routes=len(loads), added_System_aligned_extent=8192,
                     complete_capacity_result=False)))
