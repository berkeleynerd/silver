"""Independent changed-obligation path audit; no target or checker execution."""
from dataclasses import replace
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = 'bc889215882ea5e3725e593fd092d058504746b5'
PACKET = 'docs/evidence/retained-fixed-report-composition-20261024/'
START = time.perf_counter()


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return (ROOT/path).read_bytes()


def module(name,path):
    spec = importlib.util.spec_from_file_location(name,ROOT/path)
    result = importlib.util.module_from_spec(spec)
    sys.modules[name] = result
    spec.loader.exec_module(result)
    return result


targets = [PACKET+'paths/'+x for x in ('README.md','capacity.py','check.py',
    'configuration-snapshot.json','result.json','round.json','source-manifest.json')]
targets.append('docs/research/retained-fixed-report-composition.md')
target_hashes = {}
for path in targets:
    raw = read(path)
    assert raw == subprocess.check_output(['git','show',AUTHOR+':'+path],cwd=ROOT)
    target_hashes[path] = dict(bytes=len(raw),sha256=sha(raw))
manifest = json.loads(read(PACKET+'paths/source-manifest.json'))
for path,digest in manifest['repository_files'].items():
    assert sha(read(path)) == digest,path
prefix = manifest['accepted_research_prefix']
assert sha(read(prefix['path'])[:prefix['bytes']]) == prefix['sha256']
sources, archived = {},{}
for path,row in manifest['archives'].items():
    assert sha(read(path)) == row['sha256']
    archived[path] = {}
    with tarfile.open(ROOT/path) as stream:
        for member,digest in row['members'].items():
            raw = stream.extractfile(member).read()
            assert sha(raw) == digest,(path,member)
            archived[path][member] = raw
            if member.endswith(('.ads','.adb')):
                sources[Path(member).name] = raw.decode()
gcc = manifest['gcc_source']
known = {r['path']:r['sha256'] for r in json.loads(read(gcc['manifest']))['files']}
for path,digest in gcc['files'].items():
    raw = (Path(gcc['default_root'])/path).read_bytes()
    assert sha(raw) == digest == known[path]
    sources[Path(path).name] = raw.decode()

# Independent complete-corpus pass and Ada token extraction. Comments, String
# literals and character literals are excluded before identifying a pragma.
ada_token = re.compile(r'''--[^\r\n]*|"(?:[^"]|"")*"|'[^\r\n]'|[A-Za-z][A-Za-z_0-9]*''')


def has_source_reference(raw):
    words = [m.group().lower() for m in ada_token.finditer(raw.decode('latin-1'))
             if m.group()[0].isalpha()]
    return any(a == 'pragma' and b == 'source_reference'
               for a,b in zip(words,words[1:]))


runtime_root = Path(manifest['runtime_corpus']['root'])
runtime_files = sorted(Path(base)/name for base,_,names in os.walk(runtime_root)
                       for name in names if (Path(base)/name).is_file())
runtime_rows = []
source_reference_pragmas = []
for path in runtime_files:
    raw = path.read_bytes()
    relative = path.relative_to(runtime_root).as_posix()
    runtime_rows.append(dict(path=relative,bytes=len(raw),sha256=sha(raw),
        git_blob_sha1=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()))
    if has_source_reference(raw):
        source_reference_pragmas.append(relative)
runtime_digest = sha(json.dumps(runtime_rows,sort_keys=True,separators=(',',':')).encode())
assert runtime_digest == manifest['runtime_corpus']['accepted_manifest_sha256']
accepted = json.loads(read('docs/evidence/unbounded-programs/retained-source-closure-20261017/source-inventory.json'))
assert runtime_digest == accepted['installed_runtime_corpora']['producer']['manifest_sha256']
assert len(runtime_rows) == 1575 and source_reference_pragmas == []
runtime_names = tuple(x['path'] for x in runtime_rows)
assert max((len(x.encode()),x) for x in runtime_names) == (14,'standard.ads.h')

f = module('independent_path_target',PACKET+'paths/capacity.py')
silver = read('src/silver.adb').decode()
project_sources = re.search(r'for Source_Files use \((.*?)\);',silver).group(1)
source_names = tuple(re.findall(r'""([^"\n]+)""',project_sources))
assert source_names == f.SOURCES
for name in source_names[1:]:
    assert not has_source_reference(read('src/'+name))
assert 'for Body (""Main"") use ""main.adb"" at 1;' in silver
assert 'for Source_Dirs use (""."");' in silver
assert 'Silver_Build.Root_Directory & "/program-"' in read('src/silver_platform.ads').decode()
assert "Workspace_Prefix'Length + 6" in read('src/silver_platform.ads').decode()
units = ('main~1',)+tuple(dict.fromkeys(n.rsplit('.',1)[0] for n in source_names[1:]))
reports = tuple(u+'.spark' for u in units)
assert units == f.UNITS and reports == f.REPORTS
snapshot = json.loads(read(PACKET+'paths/configuration-snapshot.json'))
assert sha(snapshot['generated_source_utf8'].encode()) == snapshot['generated_source_sha256']
fields = dict(re.findall(r'(\w+) : constant String := "([^"]*)";',snapshot['generated_source_utf8']))
assert fields == snapshot['generated_fields']
root = fields['Root_Directory']
context = root+'/toolchain'
assert fields['Alire_Exec'].startswith('cd '+context+' && unset ')
assert snapshot['producer_runtime_root'] == str(runtime_root)
assert all(snapshot[k] is False for k in ('actual_physical_roots_observed',
    'effective_environment_observed','prospective_launcher_implemented'))
assert snapshot['actual_complete_common_path_bytes'] is None
config = f.Configuration(workspace_root=root,physical_workspace_root=root,
    initial_and_saved_cwds=(context,),runtime_roots=(str(runtime_root),),
    runtime_names=runtime_names,temporary_root='/tmp',normalized_temporary_root='/tmp')


def independent_hull(cfg):
    # This arithmetic follows the reviewed source constructors, with all roots
    # supplied already absolute and without trailing separators, as in the
    # selected generated-source and physical-directory relation.
    size = lambda x: len(x.encode('utf-8'))
    base = max(size(cfg.workspace_root),size(cfg.physical_workspace_root))
    work = base+len('/program-')+6
    obj = work+len('/obj/gnatprove/')
    cwd = max(map(size,cfg.initial_and_saved_cwds))
    runtime = max(size(r)+1+size(n) for r in cfg.runtime_roots for n in cfg.runtime_names)
    extra = max(map(size,cfg.additional_source_and_config_paths),default=0)
    trace = max(map(size,units))+len('__flow__')+10+len('.trace')
    temporary = max(size(cfg.temporary_root),size(cfg.normalized_temporary_root))+36
    demand = dict(project_argument=work+len('/program.gpr'),initial_and_saved_cwd=cwd,
        workspace_directory=work,producer_and_reporter_object_cwd=obj,object_directory=obj,
        copied_source_and_sloc=work+1+max(map(size,source_names)),
        runtime_source_and_reference=runtime,config_file=obj+len('gnatprove.alfad'),
        ordinary_summary=obj+len('gnatprove.out'),sarif_file=obj+len('gnatprove.sarif'),
        spark_files=obj+max(map(size,reports)),gnat2why_options=obj+8+len('.tmp'),
        relative_trace=trace,absolute_trace=obj+trace,
        gpr_configuration_and_naming=temporary,additional_source_and_config=extra)
    consumer = dict(project_argument=demand['project_argument'],
        initial_and_saved_cwd=max(cwd,obj),object_directory=obj,
        config_file=demand['config_file']+1,ordinary_summary=demand['ordinary_summary']+1,
        sarif_file=demand['sarif_file']+1,spark_files=demand['spark_files']+1,
        unit_source_paths=max(demand['copied_source_and_sloc'],runtime,extra))
    actual = f.domain(cfg)
    assert demand == actual['path_demands']
    assert consumer == actual['consumer_demands']
    assert actual['common_path_bytes'] == max(*demand.values(),*consumer.values())
    assert not actual['actual_configuration_relation_established']
    assert not actual['admission_decision']
    return actual


hull = independent_hull(config)
assert hull['common_path_bytes'] == 188
scenarios = {}
for name,cfg in [
    ('physical_workspace_expansion',replace(config,physical_workspace_root='/'+'w'*250)),
    ('normalized_temporary_expansion',replace(config,normalized_temporary_root='/'+'t'*400)),
    ('saved_cwd_expansion',replace(config,initial_and_saved_cwds=('/'+'c'*500,))),
    ('mapped_reference_expansion',replace(config,additional_source_and_config_paths=('/'+'m'*600,))),
    ('utf8_workspace_bytes',replace(config,physical_workspace_root='/'+'é'*100))]:
    got = independent_hull(cfg)
    scenarios[name] = dict(common_path_bytes=got['common_path_bytes'],
        sufficient_arguments_interval=got['frozen_arguments_interval_fits'],admission_decision=False)
assert scenarios['normalized_temporary_expansion']['common_path_bytes'] == 437
assert scenarios['mapped_reference_expansion']['common_path_bytes'] == 601
try:
    f.size('bad\0path')
    raise AssertionError('NUL pathname accepted')
except ValueError:
    pass

historical = []
for archive,entries in archived.items():
    for name,raw in entries.items():
        if name == 'run_case.py':
            assert "env=dict(os.environ);env.update(plan['environment'])" in raw.decode()
        if not name.endswith('/invocation.json'):
            continue
        unit = name.split('/')[0]
        invocation = json.loads(raw)
        opts = json.loads(entries[unit+'/options.json'])
        paths = [invocation['cwd'],invocation['phase1_origin'],opts['why3_dir']]
        for arg in invocation['argv']:
            if arg.startswith('/'):
                paths.append(arg)
            for prefix in ('-gnates=','-gnatec=','-gnateO=','-I'):
                if arg.startswith(prefix):
                    paths.append(arg[len(prefix):])
        paths += list(invocation['environment'].values())
        paths += entries[unit+'/object-paths.txt'].decode().splitlines()
        assert invocation['environment']['ADA_INCLUDE_PATH'] == str(runtime_root)
        assert opts['file_specific']['default']['why3_args'] == ['/usr/bin/false']
        maximum = max(len(s.encode()) for s in paths)
        assert maximum == 173
        historical.append(dict(archive=archive,unit=unit,recorded_operand_max=maximum,
            effective_environment_complete=False,physical_cwd_attached=False))
assert len(historical) == 8

base = module('path_review_specs',PACKET+'capacity.py')
io_report = module('path_review_io',PACKET+'bodies/capacity.py')
arguments = module('path_review_arguments',PACKET+'arguments/capacity.py')
P = hull['common_path_bytes']
joined_reports = []
for report in [*(base.spec_report(n,path_bytes=P) for n in base.SPECS),
               io_report.io_report(path_bytes=P),arguments.arguments_report(path_bytes=P)]:
    parsed = base.c.parsed_report(report['full'],path_bytes=P,max_path=4096,page_size=4096)
    assert report['writer']['sufficient'] and parsed['all_guards']
    assert all(report['incoming']['guards'].values())
    assert all(report['flow_brief']['guards'].values()) and report['third_pool']['guard']
    joined_reports.append(dict(unit=report['unit'],full_pretty_bytes=report['full'].pretty,
        writer_reader_incoming_brief_and_pool_guards=True,configuration_attached=False))
configurations = []
for worker in (3,2147483647):
    c = base.prospective_configuration(project_path_bytes=94,object_dir_bytes=97,workers=worker)
    args = ['gnatprove','-P','x'*94,'-U','--mode=all','--report=all',
        '--warnings=continue','--checks-as-errors=on','--prover=cvc5,z3,altergo',
        '--steps=0','--timeout=0','--memlimit=0','--counterexamples=off','-j'+str(worker),
        '--no-loop-unrolling','--output=brief','-cargs','-Wno-free-nonheap-object']
    assert [a if a is not None else 'x'*94 for a in c['argv']] == args
    assert c['argv_count'] == 18 and c['joined_command_bytes'] == len(' '.join(args))
    assert base.c.configuration_bounds(c,path_bytes=P,max_path=4096,page_size=4096)['all_guards']
    configurations.append(dict(worker_digits=len(str(worker)),argv_count=18,
        joined_command_bytes=c['joined_command_bytes'],config_file_bytes=c['config_file_bytes']))
native = [json.loads(read('docs/evidence/retained-fixed-report-native-inputs-20261024/'+x))
          for x in ('result.json','gnat2why/result.json')]
assert native[0]['native_max_path'] == native[1]['native_max_path'] == 4096
assert native[0]['observed_page_size'] == native[1]['page_size_from_retained_host_observation'] == 4096
why = json.loads(read('docs/evidence/retained-why-report-path-inputs-20261023/projection.json'))
probe = json.loads(read('docs/evidence/retained-why-library-probe-paths-20261023/projection.json'))
assert why['actual_R'] is None and why['all_FileTags_filename_upper'] == 180 and probe['P_stat'] == 167
for cwd,R in ((0,0),(500,1000)):
    got = f.why_domains(client_cwd_bytes=cwd,canonical_directory_bytes=R,provider=why['domains'])
    assert got == dict(PrecutP=max(180,cwd+10),P_file=180,P_stat=167,
        P_diag={name:max(row['request_path_upper_F'],R+24) for name,row in why['domains'].items()},
        canonical_path_bytes=R+24,response_frame_bytes=R+72)
recorded = json.loads(read(PACKET+'paths/result.json'))
assert recorded['conditional_installed_configuration'] == hull
assert [x['full_pretty_bytes'] for x in joined_reports] == [x['full_pretty_bytes'] for x in recorded['fixed_report_joins']]
assert recorded['actual_complete_common_path_bytes'] is None
result = dict(status='pass',author_commit=AUTHOR,exact_target_inputs=target_hashes,
    complete_tool_sources=len(sources),repository_inputs=len(manifest['repository_files']),
    runtime_corpus=dict(files=len(runtime_rows),manifest_sha256=runtime_digest,
        root_bytes=len(str(runtime_root).encode()),max_relative_bytes=14,
        source_reference_pragmas=source_reference_pragmas),
    conditional_hull=hull,adversarial_operand_scenarios=scenarios,
    historical_recorded_inputs=historical,fixed_report_interfaces=joined_reports,
    prospective_configurations=configurations,actual_complete_common_path_bytes=None,
    historical_environment_reconstruction_required=False,why_client_cwd=None,canonical_directory=None,
    global_e_upper=2,save_entering_callbacks_upper=2,saves_upper=3,physical_premises_unchanged=True,
    target_compiler_prover_Lean_capture_service_runs=0,author_or_predecessor_checker_runs=0,
    actual_configuration_or_whole_process_capacity_complete=False,
    elapsed_seconds=time.perf_counter()-START)
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps({k:result[k] for k in ('status','complete_tool_sources','repository_inputs','elapsed_seconds')},indent=2))
