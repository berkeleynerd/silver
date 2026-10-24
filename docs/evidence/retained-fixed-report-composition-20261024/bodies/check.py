#!/usr/bin/env python3
"""One focused offline source/arithmetic check for the new IO overlay."""
import argparse
import ast
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time

import capacity as f

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
started = time.monotonic()
manifest = json.loads((HERE/'source-manifest.json').read_text())
parser = argparse.ArgumentParser()
parser.add_argument('--gcc-source', type=Path,
                    default=Path(manifest['gcc_source']['default_root']))
args = parser.parse_args()


def sha(data):
    return hashlib.sha256(data).hexdigest()


for path, digest in manifest['repository_files'].items():
    assert sha((ROOT/path).read_bytes()) == digest, path
prefix = manifest['accepted_research_prefix']
assert sha((ROOT/prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
source = {}
archive = manifest['archive']
assert sha((ROOT/archive['path']).read_bytes()) == archive['sha256']
with tarfile.open(ROOT/archive['path']) as tar:
    for member, digest in archive['members'].items():
        data = tar.extractfile(member).read()
        assert sha(data) == digest, member
        source[member.removeprefix('spark-source/src/')] = data.decode()
gcc_manifest = json.loads((ROOT/manifest['gcc_source']['manifest']).read_text())
gcc_known = {row['path']:row['sha256'] for row in gcc_manifest['files']}
for path, digest in manifest['gcc_source']['files'].items():
    data = (args.gcc_source/path).read_bytes()
    assert sha(data) == digest == gcc_known[path], path
    source['gcc/'+path] = data.decode()
gnat = manifest['gnatcoll']
assert sha((ROOT/gnat['path']).read_bytes()) == gnat['sha256']
with tarfile.open(ROOT/gnat['path']) as tar:
    data = tar.extractfile(gnat['member']).read()
    assert sha(data) == gnat['member_sha256']
    source['gnatcoll-json-utility.adb'] = data.decode()


def section(file, begin, end):
    return '\n'.join(source[file].splitlines()[begin-1:end])


# Extract just the accepted lexical function, never execute the checker body.
lex_path = ROOT/'docs/evidence/retained-producer-report-incoming-20261024/check.py'
tree = ast.parse(lex_path.read_text())
definition = next(x for x in tree.body if isinstance(x, ast.FunctionDef)
                  and x.name == 'lex_ada')
namespace = {}
exec(compile(ast.Module(body=[definition],type_ignores=[]),str(lex_path),'exec'),namespace)
lex_ada = namespace['lex_ada']

regions = [
    ('Check_Expressions', 'flow/flow-analysis-sanity.adb', 113, 1507),
    ('Illegal_Writes', 'flow/flow-analysis-sanity.adb', 1513, 1839),
    ('Generated_Globals', 'flow/flow-analysis-sanity.adb', 1845, 2083),
    ('Unwritten', 'flow/flow-analysis.adb', 795, 1037),
    ('Ineffective_Imports', 'flow/flow-analysis.adb', 1043, 1564),
    ('Ineffective_Statements', 'flow/flow-analysis.adb', 1570, 2062),
    ('Dead_Code', 'flow/flow-analysis.adb', 2068, 2097),
    ('Initialization', 'flow/flow-analysis.adb', 2103, 3397),
    ('Assertion_Inputs', 'flow/flow-analysis.adb', 3520, 3636),
    ('Constant_Global', 'flow/flow-analysis.adb', 6836, 6891),
    ('Required_Contracts', 'flow/flow-analysis.adb', 6897, 7077),
    ('Antialiasing', 'flow/flow-analysis-antialiasing.adb', 1, 100000),
    ('CFG', 'flow/flow-control_flow_graph.adb', 1, 100000),
    ('Incomplete_Globals', 'flow/flow_sanity.adb', 1, 100000),
    ('Dependency_Status', 'flow/flow.adb', 1869, 1908),
]
census = []
for name, file, begin, end in regions:
    end = min(end,len(source[file].splitlines()))
    _, literals = lex_ada(section(file,begin,end))
    joined = ''.join(literals)
    assert all(32 <= ord(ch) <= 126 for ch in joined), name
    row = dict(name=name,file=file,begin=begin,end=end,
               literal_bytes=len(joined),ampersands=joined.count('&'),
               hashes=joined.count('#'),ats=joined.count('@'))
    census.append(row)
assert max(x['literal_bytes'] for x in census) == 1189
assert max(x['ampersands'] for x in census) == 14
assert max(x['hashes'] for x in census) == 1

# Correspondence assertions complement the manual source closure, not prove it.
assert 'when others =>' in source['gcc/exp_spark.adb']
assert 'Iterator_Specification (Scheme)' in section('gcc/exp_spark.adb',896,919)
assert 'and then Full_Analysis' in section('gcc/exp_util.adb',12618,12723)
assert 'if Expander_Active or GNATprove_Mode then' in section('gcc/sem_ch3.adb',22588,22835)
assert 'Force_Evaluation (Low_Bound  (Drange));' in section('gcc/sem_res.adb',11945,12015)
assert 'Quantified_Var' in section('flow/flow_utility.adb',5335,5398) or 'Quantified_Expr' in section('flow/flow_utility.adb',5335,5398)
assert 'Use_Deduced_Globals => False' in section('flow/flow-analysis.adb',3642,3725)
assert 'if Get_Termination_Condition (FA.Spec_Entity) = (Static, True)' in section('flow/flow-analysis.adb',6442,6485)
assert 'Atr.Is_Null_Node and then Atr.Is_Program_Node' in section('flow/flow-control_flow_graph.adb',7688,7725)
assert 'Clear_Vertex_And_Attributes (FA, V)' in section('flow/flow-control_flow_graph.adb',7962,7999)
assert 'How_Proved    => PC_Flow' in section('flow/flow_error_messages.adb',300,499)
assert 'Msg           => Create (Msg3, Explain_Code => Explain_Code)' in section('flow/flow_error_messages.adb',300,499)
assert 'How_Proved    : Prover_Category := PC_Trivial;' in source['utils/errout_wrapper.ads']
assert 'if not M.Names.Is_Empty and then Contains_Placeholder then' in source['utils/errout_wrapper.adb']
assert 'Counter := Counter + 1;' in section('utils/errout_wrapper.adb',698,737)
assert 'when NUL =>' in section('gnatcoll-json-utility.adb',87,146)

body = (ROOT/'src/silver_io.adb').read_text()
actual_census = {}
for name, row in f.SOURCE.items():
    chunk = body.split('procedure '+name+' (',1)[1].split('end '+name+';',1)[0]
    code, _ = lex_ada(chunk)
    calls = len(re.findall(r'Silver_Output_Libc\.(?:Put_Byte|Flush)\b',code))
    counts = dict(ordinary_assignments=code.count(':=')-calls,
                  side_effect_assignments=calls,
                  procedure_calls=len(re.findall(r'Silver_Output_Libc\.Set_Exit_Status\b',code)),
                  conditions=len(re.findall(r'^\s*if\b',code,re.M)),
                  returns=len(re.findall(r'\breturn\s*;',code)))
    assert all(row[k] == v for k,v in counts.items()), (name,counts)
    assert len(re.findall(r'for\s+Index\s+in\b',code)) == 1
    assert len(re.findall(r'pragma\s+Loop_Invariant\b',code)) == 2
    actual_census[name] = counts

graphs = f.graph_rows()
assert [graphs[n]['eligible_vertices'] for n in ('Put_Line','Put','Silver_IO')] == [286,241,75]
assert [graphs[n]['flow_records'] for n in ('Put_Line','Put','Silver_IO')] == [20724,17503,2338]
zero = f.io_report(path_bytes=0)
one = f.io_report(path_bytes=1)
assert (zero['flow'],zero['warning']) == (40711,16741)
assert zero['claim_domain'] == dict(claims=30,edges=42)
assert zero['proof_message_bytes'] == 31439
assert max(map(len,f.REPORT_NAMES)) == 34


def checked(path):
    report = f.io_report(path_bytes=path)
    reader = f.c.parsed_report(report['full'],path_bytes=path,
                               max_path=4096,page_size=65536)
    success = (report['writer']['sufficient'] and reader['all_guards']
               and all(report['incoming']['guards'].values())
               and report['third_pool']['guard']
               and all(report['flow_brief']['guards'].values()))
    return success, report, reader


# Find the full conditional interval, rather than select a favorable fixture.
assert checked(0)[0]
low, high = 0, 4097
while high-low > 1:
    middle = (low+high)//2
    if checked(middle)[0]:
        low = middle
    else:
        high = middle
ok, endpoint, reader = checked(low)
assert ok and low >= 128
if low < 4096:
    assert not checked(low+1)[0]
slope = one['full'].pretty-zero['full'].pretty
projected_slope = one['projected'].pretty-zero['projected'].pretty
assert endpoint['full'].pretty == zero['full'].pretty+low*slope
assert endpoint['projected'].pretty == zero['projected'].pretty+low*projected_slope

# Independent serializer witnesses for the mixed-character bound. These are
# small checks of the encoding equation, not observations of native reports.
for fixed in ('fixed template "name"', 'line\nnext\t\\end', "'& # punctuation"):
    for path in ('/tmp/a', '/tmp/é/漢', '/tmp/\x01/😀'):
        actual = json.dumps(fixed+path,ensure_ascii=True,separators=(',',':'))
        shape = f.mixed_string(len(fixed),len(path.encode('utf-8')))
        assert len(actual.encode()) <= shape.pretty
assert not endpoint['path_configuration_bound']
assert not endpoint['whole_process_capacity_bound']

(HERE/'message-census.json').write_text(json.dumps(census,indent=2)+'\n')
result = dict(status='IO report source composition checked; #212 incomplete',
    actual_source_census=actual_census,graphs=graphs,
    incoming=endpoint['incoming'],report_entity_names=f.REPORT_NAMES,
    report_entities=6,frontend_entities=f.FRONTEND,
    full_name_bytes=34,metadata_location_depth=1,
    full_pretty_affine=dict(constant=zero['full'].pretty,path_coefficient=slope),
    projected_pretty_affine=dict(constant=zero['projected'].pretty,path_coefficient=projected_slope),
    interval=dict(path_bytes_upper=low,native_max_path_upper=4096,
                  native_page_size_upper=65536,concrete_attachment_complete=False),
    endpoint_writer=endpoint['writer'],endpoint_reader=reader,
    endpoint_flow_brief=endpoint['flow_brief'],third_pool=endpoint['third_pool'],
    proof=dict(records=40,goals=117,attempts=309,responses=2,
               printed_cp_bytes=15581,message_bytes=31439,
               source_span_allocation_join_complete=False),
    source_counts_bound=True,concrete_path_and_native_inputs_bound=False,
    native_warning_location_join_complete=False,whole_process_capacity_bound=False,
    whole_fixed_report_composition_complete=False,global_escape_budget=2,
    save_entering_callbacks=2,saves_upper=3,budget_renewed=False,
    checks=dict(repository_files=len(manifest['repository_files']),
                complete_tool_source_files=len(source),
                native_compiler_solver_capture_runs=0,predecessor_checkers_run=0,
                elapsed_seconds=round(time.monotonic()-started,3)))
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(status=result['status'],interval=result['interval'],
    full_pretty_affine=result['full_pretty_affine'],
    elapsed_seconds=result['checks']['elapsed_seconds']),indent=2))
