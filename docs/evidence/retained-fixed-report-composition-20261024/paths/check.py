#!/usr/bin/env python3
"""Changed-input path/source join only. Executes no target or old checker."""
import argparse
from dataclasses import replace
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
import tarfile
import time

import capacity

started = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
manifest = json.loads((HERE/'source-manifest.json').read_text())
parser = argparse.ArgumentParser()
parser.add_argument('--gcc-source',type=Path,
                    default=Path(manifest['gcc_source']['default_root']))
parser.add_argument('--runtime-source',type=Path,
                    default=Path(manifest['runtime_corpus']['root']))
args = parser.parse_args()
sha = lambda b: hashlib.sha256(b).hexdigest()

for path,digest in manifest['repository_files'].items():
    assert sha((ROOT/path).read_bytes()) == digest,path
prefix = manifest['accepted_research_prefix']
assert sha((ROOT/prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
source,archive_data = {},{}
for path,row in manifest['archives'].items():
    assert sha((ROOT/path).read_bytes()) == row['sha256'],path
    archive_data[path]={}
    with tarfile.open(ROOT/path) as archive:
        for member,digest in row['members'].items():
            data=archive.extractfile(member).read()
            assert sha(data)==digest,member
            archive_data[path][member]=data
            if member.endswith(('.adb','.ads')):
                assert Path(member).name not in source
                source[Path(member).name]=data.decode()
known={x['path']:x['sha256'] for x in json.loads(
    (ROOT/manifest['gcc_source']['manifest']).read_text())['files']}
for path,digest in manifest['gcc_source']['files'].items():
    data=(args.gcc_source/path).read_bytes()
    assert sha(data)==digest==known[path],path
    source[Path(path).name]=data.decode()


def code_only(text):
    return re.sub(r'--[^\r\n]*|"(?:[^"]|"")*"',
                  lambda m:' '*len(m[0]),text)


# Complete corpus correspondence first; a directory listing/sample alone is
# not the filename universe. This reproduces only the accepted digest format.
runtime_rows,source_references=[],[]
for path in sorted(args.runtime_source.rglob('*')):
    if not path.is_file():
        continue
    data=path.read_bytes()
    name=path.relative_to(args.runtime_source).as_posix()
    runtime_rows.append(dict(path=name,bytes=len(data),sha256=sha(data),
        git_blob_sha1=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()))
    if re.search(r'\bpragma\s+Source_Reference\b',code_only(data.decode('latin-1')),re.I):
        source_references.append(name)
runtime_digest=sha(json.dumps(runtime_rows,sort_keys=True,separators=(',',':')).encode())
accepted=json.loads((ROOT/'docs/evidence/unbounded-programs/retained-source-closure-20261017/source-inventory.json').read_text())
assert runtime_digest==manifest['runtime_corpus']['accepted_manifest_sha256']
assert runtime_digest==accepted['installed_runtime_corpora']['producer']['manifest_sha256']
assert len(runtime_rows)==1575 and not source_references
runtime_names=tuple(x['path'] for x in runtime_rows)
assert max((len(x),x) for x in runtime_names)==(14,'standard.ads.h')
for name in capacity.SOURCES[1:]:
    assert not re.search(r'\bpragma\s+Source_Reference\b',
                        code_only((ROOT/'src'/name).read_text()),re.I)

# Local source correspondence assertions corroborate the manual closure; they
# do not purport to prove Ada semantics or all branch exclusions by matching.
assert 'Source_File.Append (Source_File.Table (Xold));' in source['sinput-l.adb']
assert 'Reference_Name      => N' in source['sinput-l.adb']
assert 'Full_Ref_Name       => Osint.Full_Source_Name' in source['sinput-l.adb']
assert 'SFR.Full_Ref_Name  := File_Name;' in source['sinput.adb']
assert 'Dir_Name.all & Name & ASCII.NUL' in source['osint.adb']
assert 'Name_Buffer (1 .. Name_Len) := File_Name (Fptr .. File_Name\'Last);' in source['osint.adb']
assert 'is (Get_Name_String (File_Name (Get_Source_File_Index (Loc))));' in source['spark_util.ads']
assert 'File  : constant String := File_Name (Obj.Span.Ptr);' in source['errout_wrapper.adb']
assert 'File   : constant String := File_Name (Slc);' in source['spark_util.adb']
assert 'Unit_Name & "__flow__" & Image (File_Counter, 1) & ".trace"' in source['flow_error_messages.adb']
assert 'Name => Unit_Name, Extension => VC_Kinds.SPARK_Suffix' in source['gnat2why-driver.adb']
assert 'Phase2_Subdir              : Virtual_File := Create ("gnatprove");' in source['configuration.ads']
assert 'return Tree.Root_Project.Object_Directory.Virtual_File;' in source['configuration.adb']
assert 'Save_Dir : constant String := Ada.Directories.Current_Directory;' in source['spark_report.adb']
assert 'Save_Dir : constant String := Ada.Directories.Current_Directory;' in source['spark_report-generate_sarif_report.adb']
assert 'Resolve_Links : Boolean := False' in source['gpr2-path_name.adb']
assert 'Resolve_Links  : Boolean := True' in source['s-os_lib.adb']
assert 'GNAT.SHA1.Digest (Write_Cont) (1 .. 8) & ".tmp"' in source['gnat2why_opts-writing.adb']
assert 'Set_Field (Obj, Why3_Dir_Name, Obj_Dir);' in source['gnat2why_opts-writing.adb']
assert 'new String\'(Dir.all & Directory_Separator & "GPR."' in source['gpr-tempdir.adb']
for name in ('TMPDIR','TEMP','TMP'):
    assert '"'+name+'"' in source['gpr-tempdir.adb']
for name in ('ADA_INCLUDE_PATH','ADA_OBJECTS_PATH','ADA_PRJ_INCLUDE_FILE','ADA_PRJ_OBJECTS_FILE'):
    assert '"'+name+'"' in source['osint.ads']
assert 'Set_Env_For_Include_Dirs (Id, Source_Project);' in source['gprbuild-compile.adb']
assert '"GNAT-TEMP-000000.TMP"' in source['s-os_lib.adb']
assert len('/GPR.'+'9'*10+'/GNAT-TEMP-999999.TMP')==36

snapshot=json.loads((HERE/'configuration-snapshot.json').read_text())
text=snapshot['generated_source_utf8']
assert sha(text.encode())==snapshot['generated_source_sha256']
fields=dict(re.findall(r'(\w+) : constant String := "([^"]*)";',text))
assert fields==snapshot['generated_fields']
root=fields['Root_Directory']
context=root+'/toolchain'
assert fields['Alire_Exec'].startswith('cd '+context+' && unset ')
assert all(not snapshot[k] for k in ('actual_physical_roots_observed',
    'effective_environment_observed','prospective_launcher_implemented'))
assert snapshot['actual_complete_common_path_bytes'] is None
rt=snapshot['producer_runtime_root']
assert rt==manifest['runtime_corpus']['root'] and capacity.size(rt)==173

nominal=capacity.Configuration(workspace_root=root,physical_workspace_root=root,
    initial_and_saved_cwds=(context,),runtime_roots=(rt,),runtime_names=runtime_names,
    temporary_root='/tmp',normalized_temporary_root='/tmp')
hull=capacity.domain(nominal)
assert hull['common_path_bytes']==188
assert hull['project_path_bytes']==94 and hull['object_dir_bytes']==97
assert hull['path_demands']['absolute_trace']==139
assert hull['consumer_demands']['spark_files']==122
assert hull['path_demands']['gpr_configuration_and_naming']==40
assert hull['source_path_bytes']==188
# The source function retains arbitrary configuration operands. Long physical
# cwd/ref/temp spellings increase P and remain representable mathematical
# results; they are not rejected as nonmembers of Silver.
expanded=capacity.domain(replace(nominal,
    initial_and_saved_cwds=('/'+'x'*500,),
    additional_source_and_config_paths=('/'+'y'*600,)))
assert expanded['common_path_bytes']==601
assert not expanded['frozen_arguments_interval_fits']
assert not expanded['admission_decision']

recorded=[]
for archive,entries in archive_data.items():
    if not any(n.endswith('invocation.json') for n in entries):
        continue
    if 'run_case.py' in entries:
        assert "env=dict(os.environ);env.update(plan['environment'])" in entries['run_case.py'].decode()
    for unit in ('silver_io','silver_arguments','silver_output_libc','silver_runtime'):
        invocation=json.loads(entries[unit+'/invocation.json'])
        opts=json.loads(entries[unit+'/options.json'])
        values=[invocation['cwd'],opts['why3_dir'],invocation['phase1_origin']]
        for arg in invocation['argv']:
            if arg.startswith('/'):
                values.append(arg)
            for pre in ('-gnates=','-gnatec=','-gnateO=','-I'):
                if arg.startswith(pre):
                    values.append(arg[len(pre):])
        values+=list(invocation['environment'].values())
        values+=entries[unit+'/object-paths.txt'].decode().splitlines()
        values += [invocation['cwd']+'/'+unit+'.spark',
                   invocation['cwd']+'/'+unit+'__flow__'+'9'*10+'.trace']
        assert invocation['environment']['ADA_INCLUDE_PATH']==rt
        assert opts['file_specific']['default']['why3_args']==['/usr/bin/false']
        maximum=max(map(capacity.size,values))
        assert maximum<=188
        recorded.append(dict(archive=archive,unit=unit,
            recorded_path_operand_max=maximum,
            with_selected_runtime_corpus=188,
            cwd=invocation['cwd'],why3_dir=opts['why3_dir'],
            effective_environment_complete=False,
            historical_physical_cwd_bound=False))
assert len(recorded)==8


def provider(name,path):
    spec=importlib.util.spec_from_file_location(name,ROOT/path)
    module=importlib.util.module_from_spec(spec)
    sys.modules[name]=module
    spec.loader.exec_module(module)
    return module


base=provider('path_fixed','docs/evidence/retained-fixed-report-composition-20261024/capacity.py')
io=provider('path_io','docs/evidence/retained-fixed-report-composition-20261024/bodies/capacity.py')
arg=provider('path_arguments','docs/evidence/retained-fixed-report-composition-20261024/arguments/capacity.py')
parent=json.loads((ROOT/'docs/evidence/retained-fixed-report-native-inputs-20261024/result.json').read_text())
producer=json.loads((ROOT/'docs/evidence/retained-fixed-report-native-inputs-20261024/gnat2why/result.json').read_text())
assert parent['native_max_path']==producer['native_max_path']==4096
assert parent['observed_page_size']==producer['page_size_from_retained_host_observation']==4096
P=hull['common_path_bytes']
reports=[base.spec_report(n,path_bytes=P) for n in base.SPECS]
reports += [io.io_report(path_bytes=P),arg.arguments_report(path_bytes=P)]
bound=[]
for report in reports:
    parsed=base.c.parsed_report(report['full'],path_bytes=P,max_path=4096,page_size=4096)
    assert report['writer']['sufficient'] and parsed['all_guards']
    assert all(report['incoming']['guards'].values())
    bound.append(dict(unit=report['unit'],common_path_bytes=P,
        full_pretty_bytes=report['full'].pretty,
        writer_sufficient=report['writer']['sufficient'],reader_sufficient=parsed['all_guards'],
        actual_configuration_relation_established=False))
configs=[]
# Endpoint worker widths cover the accepted symbolic represented range; no
# worker is reserved or process started and no host headroom is inferred.
for workers in (3,base.p.I):
    config=base.prospective_configuration(project_path_bytes=hull['project_path_bytes'],
        object_dir_bytes=hull['object_dir_bytes'],workers=workers)
    result=base.c.configuration_bounds(config,path_bytes=P,max_path=4096,page_size=4096)
    assert result['all_guards']
    configs.append(dict(worker_width=len(str(workers)),argv_count=config['argv_count'],
        joined_command_bytes=config['joined_command_bytes'],
        config_file_bytes=config['config_file_bytes'],all_guards=result['all_guards']))
why=json.loads((ROOT/'docs/evidence/retained-why-report-path-inputs-20261023/projection.json').read_text())
probe=json.loads((ROOT/'docs/evidence/retained-why-library-probe-paths-20261023/projection.json').read_text())
assert why['all_FileTags_filename_upper']==180 and probe['P_stat']==167
assert why['actual_R'] is None
why_exports={name:dict(request_F=row['request_path_upper_F'],
    P_diag='max(F, R+24)',canonical_path='R+24',response_frame='R+72')
    for name,row in why['domains'].items()}
assert sorted(r['request_F'] for r in why_exports.values())==[775,802,829,841,853]

result=dict(status='pass',scope='conditional report pathname hull and exact recorded operands; no complete effective configuration attachment',
    source_files=len(source),repository_inputs=len(manifest['repository_files']),
    runtime_corpus=dict(files=len(runtime_rows),manifest_sha256=runtime_digest,
        runtime_root_bytes=173,max_relative_bytes=14,max_relative_name='standard.ads.h',
        source_reference_pragmas=source_references,full_path_bytes=188),
    recorded_invocations=recorded,conditional_installed_configuration=hull,
    fixed_report_joins=bound,prospective_configuration_joins=configs,
    why_client_exports=why_exports,why_client_cwd=None,canonical_directory=None,
    actual_complete_common_path_bytes=None,
    source_configuration_predicates_required=True,
    complete_fixed_report_capacity=False,complete_five_report_collector=False,
    native_warning_storage_join_complete=False,
    native_max_path=4096,page_size=4096,global_e_upper=2,
    save_entering_callbacks_upper=2,saves_upper=3,physical_resources_assumed=True,
    admission_changed=False,predecessor_checker_replays=0,target_executions=0,
    compiler_prover_runs=0,service_queries=0,elapsed_seconds=time.monotonic()-started)
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(status='pass',conditional_P=P,reports=len(bound),
    runtime_files=len(runtime_rows),actual_complete_common_path_bytes=None,
    elapsed_seconds=result['elapsed_seconds'])))
