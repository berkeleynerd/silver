#!/usr/bin/env python3
"""One focused offline changed-input check; not an Ada proof or native run."""
from dataclasses import asdict, is_dataclass
import hashlib
import json
from pathlib import Path
import tarfile
import time

import capacity as f

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
started = time.monotonic()
manifest = json.loads((HERE/'source-manifest.json').read_text())


def sha(data):
    return hashlib.sha256(data).hexdigest()


for path, digest in manifest['repository_files'].items():
    assert sha((ROOT/path).read_bytes()) == digest, path
archive = ROOT/manifest['archive']['path']
assert sha(archive.read_bytes()) == manifest['archive']['sha256']
with tarfile.open(archive) as source:
    texts = {}
    for member, digest in manifest['archive']['members'].items():
        data = source.extractfile(member).read()
        assert sha(data) == digest, member
        texts[member.removeprefix('spark-source/src/')] = data.decode()


def section(file, begin, end):
    lines = texts[file].splitlines()
    return '\n'.join(lines[begin-1:end])


# These are correspondence checks on exact complete-source inputs. The proof
# of reachability and the emission/metadata domain is in the companion note.
assert 'when E_Package' in section('flow/flow.adb',1561,1576)
assert 'Entity_Spec_In_SPARK (E)' in section('flow/flow.adb',1561,1576)
assert 'N_Subprogram_Declaration' in section('flow/flow-control_flow_graph.adb',114,148)
assert 'Pragma_Relevant_To_Flow (N)' in section('flow/flow-control_flow_graph.adb',5684,5750)
assert 'Atr.Is_Null_Node and then Atr.Is_Program_Node' in section('flow/flow-control_flow_graph.adb',7688,7725)
assert 'Clear_Vertex_And_Attributes (FA, V)' in section('flow/flow-control_flow_graph.adb',7962,7999)
assert 'Is_Original_Program_Node => Atr.Is_Original_Program_Node' in section('flow/flow-control_flow_graph.adb',8388,8403)
assert texts['flow/flow-control_flow_graph.adb'].index('Simplify_CFG (FA);', texts['flow/flow-control_flow_graph.adb'].index('procedure Create (FA')) < texts['flow/flow-control_flow_graph.adb'].index('FA.Full_CFG := FA.CFG;')
assert 'return Encl_Unit in Main_Unit_Node | Library_Unit (Main_Unit_Node);' in texts['spark/spark_util.adb']
assert 'Full_Source_Name (Scope (E)) & "." & Name' in texts['spark/spark_util.adb']
assert 'if Is_Imported (E) then\n               return;' in texts['flow/flow-analysis.adb']
assert 'Get_Variables_For_Proof (N, N)' in texts['flow/flow_sanity.adb']

rows = {}
for unit in f.SPECS:
    at0 = f.spec_report(unit,path_bytes=0)
    at1 = f.spec_report(unit,path_bytes=1)
    top = f.spec_report(unit,path_bytes=4096)
    # Bounds are monotone; this is the closed endpoint of a proved interval,
    # not an observed path length or an assertion about native services.
    read = f.c.parsed_report(top['full'],path_bytes=4096,
                             max_path=4096,page_size=65536)
    assert all(top['incoming']['guards'].values())
    assert top['writer']['sufficient']
    assert top['third_pool']['guard']
    assert all(top['flow_brief']['guards'].values())
    assert read['all_guards']
    assert top['claim_domain']['edges'] == 0
    assert top['source_counts_bound'] and not top['path_configuration_bound']
    assert not top['whole_process_capacity_bound']
    slope = at1['full'].pretty-at0['full'].pretty
    assert top['full'].pretty == at0['full'].pretty+4096*slope
    assert top['projected'] == top['full']
    rows[unit] = dict(incoming=top['incoming'],
        report_entity_names=[unit]+[unit+'.'+s for s in f.CALLABLES[unit][1:]],
        full_name_bytes=top['source']['full_name_bytes'],
        pretty_affine=dict(constant=at0['full'].pretty,path_coefficient=slope),
        interval_writer=top['writer'],interval_reader=read,
        interval_flow_brief=top['flow_brief'],third_pool=top['third_pool'])

# Source-profile differential: preserve command order, all obligations and
# compiler forwarding while replacing the four old policy choices.
for workers in (3, f.p.I):
    new = f.prospective_configuration(project_path_bytes=7,
                                      object_dir_bytes=9,workers=workers)
    args = [x if x is not None else 'p'*7 for x in new['argv']]
    actual = dict(obj_dirs=['o'*9], cmdline=args, proof_switches={},
                  mode='GPM_ALL',has_errors=False,colors=False)
    encoded = json.dumps(actual,separators=(',',':'))+'\n'
    assert len(encoded) <= new['config_file_bytes']
    assert len(' '.join(args)) == new['joined_command_bytes']
    assert len(args)==18 and '--level=2' not in args and '-j0' not in args
    assert '--report=all' in args and '--counterexamples=off' in args
    assert all(x in args for x in ('--steps=0','--timeout=0','--memlimit=0'))
    assert args[-2:]==['-cargs','-Wno-free-nonheap-object']

conf = f.prospective_configuration(project_path_bytes=0,object_dir_bytes=0,workers=3)
result = dict(status='two specification report domains checked; #212 incomplete',
    source_counts_bound=True, concrete_paths_and_native_services_bound=False,
    whole_fixed_report_composition_complete=False,
    useful_interval=dict(path_bytes_upper=4096,native_max_path_upper=4096,
                         native_page_size_upper=65536,
                         native_services_are_conditions_not_observations=True),
    callable_census=f.CALLABLES, analyzed_graph_upper=f.GRAPH_UPPER,
    specification_processes=rows,
    prospective_command=dict(argv=conf['argv'],argv_count=conf['argv_count'],
        joined_bytes='project_path_bytes + decimal_digits(workers) + '+str(conf['joined_command_bytes']-1),
        launcher_implemented=False, concrete_paths_bound=False),
    checks=dict(source_correspondence_files=len(manifest['repository_files'])+len(texts),
                native_runs=0, predecessor_checkers_run=0,
                checker_elapsed_seconds=round(time.monotonic()-started,3)))
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(status=result['status'],
    pretty_affine={k:v['pretty_affine'] for k,v in rows.items()},
    elapsed_seconds=result['checks']['checker_elapsed_seconds']),indent=2))
