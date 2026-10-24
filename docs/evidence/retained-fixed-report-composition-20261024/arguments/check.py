#!/usr/bin/env python3
"""Focused offline check for new Arguments source composition; no native run."""
import argparse
import ast
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
parser.add_argument('--gcc-source',type=Path,
                    default=Path(manifest['gcc_source']['default_root']))
args = parser.parse_args()


def sha(data):
    return hashlib.sha256(data).hexdigest()


for path,digest in manifest['repository_files'].items():
    assert sha((ROOT/path).read_bytes()) == digest,path
prefix = manifest['accepted_research_prefix']
assert sha((ROOT/prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
source = {}
archive = manifest['archive']
assert sha((ROOT/archive['path']).read_bytes()) == archive['sha256']
with tarfile.open(ROOT/archive['path']) as tar:
    for member,digest in archive['members'].items():
        data = tar.extractfile(member).read()
        assert sha(data) == digest,member
        source[member.removeprefix('spark-source/src/')] = data.decode()
gcc_manifest = json.loads((ROOT/manifest['gcc_source']['manifest']).read_text())
known = {x['path']:x['sha256'] for x in gcc_manifest['files']}
for path,digest in manifest['gcc_source']['files'].items():
    data = (args.gcc_source/path).read_bytes()
    assert sha(data) == digest == known[path],path
    source['gcc/'+path] = data.decode()
gnat = manifest['gnatcoll']
assert sha((ROOT/gnat['path']).read_bytes()) == gnat['sha256']
with tarfile.open(ROOT/gnat['path']) as tar:
    data = tar.extractfile(gnat['member']).read()
    assert sha(data) == gnat['member_sha256']
    source['gnatcoll-json-utility.adb'] = data.decode()


def section(file,begin,end):
    return '\n'.join(source[file].splitlines()[begin-1:end])


# Only extract the accepted lexical definition; never run a predecessor's
# top-level checker, native process, capture or evidence-producing program.
lex_path = ROOT/'docs/evidence/retained-producer-report-incoming-20261024/check.py'
tree = ast.parse(lex_path.read_text())
fn = next(x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name=='lex_ada')
namespace = {}
exec(compile(ast.Module(body=[fn],type_ignores=[]),str(lex_path),'exec'),namespace)
lex_ada = namespace['lex_ada']

census = json.loads((HERE.parent/'bodies/message-census.json').read_text())
for name,file,begin,end in [
    ('Function_Side_Effects','flow/flow-analysis-sanity.adb',58,110),
    ('Function_Volatility','flow/flow-analysis.adb',5764,5923),
    ('Always_Terminates','flow/flow-analysis.adb',6442,6725),
    ('No_Effect_Helper','flow/flow-analysis.adb',337,365)]:
    census.append(dict(name=name,file=file,begin=begin,end=end))
for row in census:
    _,literals = lex_ada(section(row['file'],row['begin'],row['end']))
    joined = ''.join(literals)
    assert all(32 <= ord(x) <= 126 for x in joined),row['name']
    calculated = dict(literal_bytes=len(joined),ampersands=joined.count('&'),
                      hashes=joined.count('#'),ats=joined.count('@'))
    for key,value in calculated.items():
        if key in row:
            assert row[key] == value,(row['name'],key)
        row[key] = value
assert max(x['literal_bytes'] for x in census) == 1189
assert max(x['ampersands'] for x in census) == 14
assert max(x['hashes'] for x in census) == 1

assert 'Ret := Make_Simple_Return_Statement (LocX, Expr);' in section('gcc/sem_ch6.adb',298,390)
assert 'Declarations               => Empty_List' in section('gcc/sem_ch6.adb',298,390)
assert 'Preanalyze (Iterator_Specification (N));' in section('gcc/sem_ch4.adb',4600,4812)
assert 'Do not inline expression functions' in section('gcc/inline.adb',1950,2030)
assert 'Set_Is_Return_Object (Defining_Identifier (Obj_Decl));' in section('gcc/sem_ch6.adb',780,980)
assert 'Analyze (Obj_Decl);' in section('gcc/sem_ch6.adb',780,980)
assert 'return Actual_Subtype (Entity (N));' in section('gcc/sem_util.adb',10270,10378)
assert 'for J in 1 .. Number_Dimensions (T) loop' in section('gcc/sem_util.adb',1192,1337)
assert 'and then Full_Analysis' in section('gcc/exp_util.adb',12618,12723)
assert 'if GNATprove_Mode then' in section('gcc/exp_util.adb',12949,13070)
assert 'Ref_Type := Typ;' in section('gcc/exp_util.adb',12949,13070)
assert 'Process_Statement_List (Ret_Object_L, FA, CM, Ctx);' in section('flow/flow-control_flow_graph.adb',2426,2533)
assert 'Make_Extended_Return_Attributes' in section('flow/flow-control_flow_graph.adb',2426,2533)
assert 'and then V.Node = E' in section('flow/flow_utility.adb',5335,5398)
assert 'Use_Deduced_Globals => False' in section('flow/flow-analysis.adb',3642,3725)

body = (ROOT/'src/silver_arguments.adb').read_text()
actual = {}
order = list(f.SOURCE)
for index,name in enumerate(order):
    start = re.search(r'\b(?:function|procedure)\s+'+name+r'\b',body).end()
    chunk = body[start:]
    if index+1 < len(order):
        chunk = re.split(r'\b(?:function|procedure)\s+'+order[index+1]+r'\b',chunk)[0]
    else:
        chunk = chunk.split('end '+name+';',1)[0]
    chunk = chunk.split('end '+name+';',1)[0]
    chunk = re.split(r'\bis\b',chunk,maxsplit=1)[1]
    code,literals = lex_ada(chunk)
    extended = len(re.findall(r'\breturn\s+Result\s*:',code))
    simple = len(re.findall(r'\breturn\b',code))-extended
    if name=='Is_Message':
        assert simple==0  # lowering contributes the one return in the table
        simple=1
    conditions = len(re.findall(r'^\s*(?:if|elsif)\b',code,re.M))
    pure = len(re.findall(r'\b(?:Silver_Runtime\.(?:Argument_Count|Argument)|Is_Message|Input_Is_Valid)\s*(?:\(|=|then|;)',code))
    # End names are excluded by requiring a call/condition token after name.
    statements = len(re.findall(r'Silver_Output_Libc\.Set_Exit_Status\b',code))
    objects = extended+len(re.findall(r'\bItem\s*:\s*constant\s+String\b',code))
    row = dict(conditions=conditions,simple_returns=simple,extended_returns=extended,
               objects=objects,statement_calls=statements,pure_calls=pure)
    for key in ('conditions','simple_returns','extended_returns','objects','statement_calls'):
        assert row[key] == f.SOURCE[name][key],(name,key,row)
    assert pure == dict(Is_Message=0,Input_Is_Valid=4,First_Or_Default=6,Reject=0)[name],(name,row)
    actual[name] = row
assert len(re.findall(r'for\s+all\s+Ch\s+of',body)) == 1
specification = (ROOT/'src/silver_arguments.ads').read_text()
assert len(re.findall(r'for\s+all\s+Ch\s+of',specification)) == 1
assert not re.search(r'\bfor\b[^\n]*\bloop\b',body)

graphs = f.graph_rows()
names = order+['Silver_Arguments']
assert [graphs[n]['flow_ids'] for n in names] == [11,13,31,3,1]
assert [graphs[n]['eligible_vertices'] for n in names] == [75,99,246,41,22]
assert [graphs[n]['flow_records'] for n in names] == [4651,7993,44380,875,144]
zero,one = (f.arguments_report(path_bytes=x) for x in (0,1))
assert (zero['flow'],zero['warning']) == (58687,13395)
assert zero['claim_domain'] == dict(claims=40,edges=448)
assert max(map(len,f.REPORT_NAMES)) == 34
assert len('silver_arguments__flow__')+10+len('.trace') == 40
assert max(4*128+64,760+2) == 762
assert 24*max(510,128,550,0+2,6,64)+2381 == 15581
canonical = json.loads((ROOT/'docs/evidence/retained-why-canonical-json-input-20261023/result.json').read_text())
cases = [r for r in canonical['cases'] if r['case'] in ('is_message','input_is_valid','first_or_default')]
assert [sum(row[key] for row in cases) for key in ('R','G','A')] == [11,39,95]


def checked(path):
    report = f.arguments_report(path_bytes=path)
    read = f.c.parsed_report(report['full'],path_bytes=path,max_path=4096,page_size=65536)
    guards = dict(report['writer']['guards'],**report['incoming']['guards'],
                  **report['flow_brief']['guards'],third_pool=report['third_pool']['guard'])
    return all(guards.values()) and read['all_guards'],report,read


assert checked(0)[0]
low,high = 0,4097
while high-low>1:
    middle = (low+high)//2
    if checked(middle)[0]:
        low=middle
    else:
        high=middle
assert low>=128
ok,endpoint,reader = checked(low)
assert ok
successor = None
if low<4096:
    ok,next_report,next_reader = checked(low+1)
    assert not ok
    successor = dict(path_bytes=low+1,
        failed_writer_guards=[k for k,v in next_report['writer']['guards'].items() if not v],
        failed_reader_guards=[k for k,v in next_reader['guards'].items() if not v])
affine = {}
for key in ('full','projected'):
    slope = one[key].pretty-zero[key].pretty
    assert endpoint[key].pretty == zero[key].pretty+low*slope
    affine[key] = dict(constant=zero[key].pretty,path_coefficient=slope)
assert not endpoint['path_configuration_bound']
assert not endpoint['whole_process_capacity_bound']

(HERE/'message-census.json').write_text(json.dumps(census,indent=2)+'\n')
result = dict(status='Arguments report source composition checked; #212 incomplete',
    actual_source_census=actual,graphs=graphs,incoming=endpoint['incoming'],
    frontend_entities=f.FRONTEND,report_entities=8,report_entity_names=f.REPORT_NAMES,
    full_name_bytes=34,metadata_location_depth=1,pretty_affine=affine,
    interval=dict(path_bytes_upper=low,native_max_path_upper=4096,
                  native_page_size_upper=65536,concrete_attachment_complete=False),
    first_failing_successor=successor,endpoint_writer=endpoint['writer'],
    endpoint_reader=reader,endpoint_flow_brief=endpoint['flow_brief'],
    third_pool=endpoint['third_pool'],claim_domain=endpoint['claim_domain'],
    proof=dict(records=11,goals=39,attempts=95,responses=3,printed_cp_bytes=15581,
               message_bytes=31439,source_span_allocation_join_complete=False),
    source_counts_bound=True,concrete_path_and_native_inputs_bound=False,
    native_warning_location_join_complete=False,whole_process_capacity_bound=False,
    whole_fixed_report_composition_complete=False,global_escape_budget=2,
    save_entering_callbacks=2,saves_upper=3,budget_renewed=False,
    checks=dict(repository_files=len(manifest['repository_files']),
                complete_tool_source_files=len(source),predecessor_checkers_run=0,
                native_compiler_solver_capture_runs=0,
                elapsed_seconds=round(time.monotonic()-started,3)))
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(status=result['status'],interval=result['interval'],
                      pretty_affine=affine,elapsed_seconds=result['checks']['elapsed_seconds']),indent=2))
