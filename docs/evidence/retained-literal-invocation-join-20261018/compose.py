#!/usr/bin/env python3
"""Compute the selected native literal launch graph; execute no native tool.

The graph selects pinned Silver object/ALI configuration inputs. It has no
GPR or fixed-child compiler job, and makes no regenerated-object hash claim.
The companion source argument supplies the conditional interface transfers.
"""
import argparse
import ast
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import runpy
import tarfile
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
NATIVE = E/'unbounded-programs/retained-native-expansion-20261017'


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


def member(archive, name):
    with tarfile.open(archive) as stream:
        return stream.extractfile(name).read()


def pure_function(path, name, namespace):
    nodes = [node for node in ast.parse(Path(path).read_bytes()).body
             if isinstance(node, ast.FunctionDef) and node.name == name]
    require(len(nodes) == 1, 'one retained pure definition: '+name)
    exec(compile(ast.Module(body=nodes, type_ignores=[]), str(path), 'exec'), namespace)
    return namespace[name]


class Context:
    def __init__(self):
        pins = read(HERE/'inputs.json')
        for row in pins:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {key:row[key] for key in ('bytes', 'sha256')}, row['path'])
        self.input_count = len(pins)
        self.sources = {}
        for row in read(HERE/'sources.json'):
            raw = member(REPO/row['archive'], row['member'])
            require(identity(raw) == {key:row[key] for key in ('bytes','sha256')}, row['member'])
            self.sources[row['member']] = raw
        self.output_archive = E/'retained-linker-output-delta-20261018/artifacts.tar.gz'
        manifest = read(E/'retained-linker-output-delta-20261018/manifest.json')['artifacts']
        require(identity(self.output_archive.read_bytes()) ==
                {key:manifest[key] for key in ('bytes','sha256')}, 'output archive identity')
        self.artifacts = {}
        with tarfile.open(self.output_archive) as stream:
            for row in manifest['members']:
                raw = stream.extractfile(row['path']).read()
                require(identity(raw) == {key:row[key] for key in ('bytes','sha256')}, row['path'])
                self.artifacts[row['path']] = raw
        for name in ('silver_io.ads','silver_io.adb','silver_output_libc.ads'):
            raw = (REPO/'src'/name).read_bytes()
            require(raw == self.artifacts['indexed/'+name] ==
                    self.artifacts['options/literal-proposed/src/'+name], 'Silver source equality')
        for name in ('silver_io.o','silver_output_libc.o'):
            raw = self.artifacts['indexed/obj/'+name]
            require(all(raw == self.artifacts['objects/'+case+'/'+name] for case in
                        ('literal-baseline','literal-proposed','long_name-baseline','long_name-proposed')),
                    'reviewed fixed object correspondence')
        self.null = runpy.run_path(str(E/'retained-null-pipeline-20261018/compose.py'))
        self.emission = runpy.run_path(str(E/'retained-literal-emission-closure-20261018/derive.py'))
        self.link = runpy.run_path(str(E/'retained-literal-linker-20261018/compose.py'))
        self.link_context = self.link['Context']()
        self.link_capture = read(E/'retained-link-no-lto-20261018/capture/result.json')
        self.inventory = read(E/'retained-link-inputs-20261018/inventory.json')
        self.resolution = read(E/'retained-link-no-lto-20261018/ld-resolution/result.json')
        self.binder_options = read(E/'retained-binder-options-20261018/result.json')['cases']['output']
        self.checksum = read(E/'retained-binder-checksum-closure-20261018/result.json')
        self.binder_invocation = json.loads(member(E/'retained-binder-options-20261018/artifacts.tar.gz',
                                                  'output/invocation.json'))
        self.binder_generator = json.loads(member(E/'retained-binder-capacity-20261018/artifacts.tar.gz',
                                                  'controlled-capture/invocation.json'))
        # The only Main-varying binder scalar; no supplied checksum is assumed
        # to be the checksum of the author's actual source.
        self.spec = self.artifacts['indexed/obj/b__main~1.ads']
        require(len(re.findall(rb'u00001 : constant Version_32 := 16#[0-9a-f]{8}#;', self.spec)) == 1,
                'unique fixed-width Main checksum slot')
        require(b'pragma Export (C, u00001, "mainB");' in self.spec, 'checksum export binding')
        self.fixed_alis = {Path(name).name:raw for name,raw in self.artifacts.items()
                           if name.startswith('closure/') and name.endswith('.ali')
                           and name != 'closure/main.ali'}
        require(len(self.fixed_alis) == 82, 'fixed ALI closure')
        self.dependencies = {}
        for raw in self.fixed_alis.values():
            for line in raw.splitlines():
                if line.startswith(b'X '): break
                if line.startswith(b'D '):
                    _, name, stamp, checksum, *_ = line.split()
                    value = dict(timestamp=stamp.decode(), checksum=checksum.decode())
                    require(name.decode() not in self.dependencies or
                            self.dependencies[name.decode()] == value, 'coherent fixed dependencies')
                    self.dependencies[name.decode()] = value
        require(len(self.dependencies) == 163, 'fixed dependency metadata census')

        self.verify_installed_inputs()

    def verify_installed_inputs(self):
        """Check the selected current configuration, not a compiler build attestation."""
        tool = str(Path(self.link_capture['commands'][0]['argv'][0]).parent.parent)
        old_tool = str(Path(self.binder_invocation['argv'][0]).parent.parent)
        installed = {}
        for path, expected in self.binder_invocation['input_identities'].items():
            if path.startswith(old_tool+'/'):
                current = tool+path[len(old_tool):]
                require(identity(Path(current).read_bytes()) == expected, current)
                installed[current] = expected
        old_bind = self.binder_generator['argv'][0]
        current_bind = tool+'/bin/gnatbind'
        require(identity(Path(current_bind).read_bytes()) ==
                self.binder_generator['input_identities'][old_bind], 'selected binder tool')
        installed[current_bind] = self.binder_generator['input_identities'][old_bind]
        adalib = tool+'/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adalib'
        include = tool+'/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude'
        for name,raw in self.fixed_alis.items():
            if not name.startswith('silver_'):
                path = adalib+'/'+name
                require(Path(path).read_bytes() == raw, 'fixed runtime ALI: '+name)
                installed[path] = identity(raw)
        for row in self.inventory['files']:
            if row['role'] != 'generated-input':
                require(identity(Path(row['path']).read_bytes()) ==
                        {key:row[key] for key in ('bytes','sha256')}, row['path'])
                installed[row['path']] = {key:row[key] for key in ('bytes','sha256')}
        old_object_directory = self.link_capture['commands'][0]['cwd']
        for row in self.inventory['library_resolution']:
            for probe in row['ordered_probes']:
                if not probe['path'].startswith(old_object_directory+'/'):
                    require(Path(probe['path']).exists() == probe['exists'],
                            'fixed ordered lookup: '+probe['path'])
        for name in ('ada_source_path','ada_object_path'):
            require(not (Path(adalib).parent/name).exists(), 'selected absent default search file')
        linker = self.resolution['selected_linker']
        require(identity(Path(linker).read_bytes())['sha256'] ==
                self.resolution['selected_linker_sha256'], 'selected linker')
        for name,metadata in self.dependencies.items():
            if not name.startswith('silver_'):
                path = Path(include)/name
                stamp = datetime.fromtimestamp(path.stat().st_mtime,timezone.utc).strftime('%Y%m%d%H%M%S')
                require(stamp == metadata['timestamp'], 'fixed runtime source timestamp: '+name)
        self.installed_inputs = installed


def projection_paths(runtime, context):
    require(set(runtime) == {'cwd','binder_temporary_root'}, 'native runtime roles')
    for value in runtime.values():
        require(isinstance(value,str) and value.startswith('/') and
                str(Path(value)) == value and '..' not in Path(value).parts and
                re.fullmatch(r'[A-Za-z0-9_./~-]+', value), 'normalized selected ASCII path')
    require(len(runtime['cwd']) == 109 and len(runtime['binder_temporary_root']) == 48,
            'accepted source and temporary path classes')
    # Reuse precisely the native subset of the accepted null graph. Empty
    # light-phase input deliberately makes no output-producer argv claim.
    return context.null['launch_graph'](runtime, SimpleNamespace(frontend_evidence={'plan':{'cases':[]}}))


def rebind_link(argv, old_object_directory, graph):
    result = []
    for arg in argv:
        if arg == 'main.o': arg = 'main~1.o'
        elif arg == 'b__main.o': arg = 'b__main~1.o'
        elif arg == '-L'+old_object_directory+'/': arg = '-L'+graph['native']['cwd']+'/'
        result.append(arg)
        if arg == 'b__main~1.o':
            result.extend([graph['native']['cwd']+'/silver_output_libc.o',
                           graph['native']['cwd']+'/silver_io.o'])
    result[result.index('-o')+1] = graph['project_root']+'/bin/main'
    return result


def build(raw, context, runtime=None, path_bytes=512, host_page_bytes=4096):
    require(type(path_bytes) is int and path_bytes >= 1, 'positive complete path bound')
    require(type(host_page_bytes) is int and host_page_bytes > 0 and
            host_page_bytes & (host_page_bytes-1) == 0, 'power-of-two host page')
    if runtime is None:
        old = read(E/'retained-null-pipeline-20261018/fixture.json')['runtime']
        runtime = {key:old[key] for key in ('cwd','binder_temporary_root')}
    graph = projection_paths(runtime, context)
    emission = context.emission['evaluate_source'](raw)
    link = context.link['evaluate'](raw, context.link_context, path_bytes, host_page_bytes)
    source_id = identity(raw)
    root, obj, temp = graph['project_root'], graph['native']['cwd'], runtime['binder_temporary_root']
    tool = str(Path(context.link_capture['commands'][0]['argv'][0]).parent.parent)
    include = tool+'/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude'
    adalib = tool+'/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adalib'
    environment = dict(context.link_capture['environment'], TMPDIR=temp)
    naming = (NATIVE/'null-capacity-fixture.adc').read_bytes()
    require(len(naming) == 327, 'indexed naming bytes')
    mapping = 'main%b\nmain.adb\n'+graph['Main']+'\n'
    files = [dict(role='Main', path=graph['Main'], kind='supplied_source', identity=source_id),
             dict(role='naming', path=graph['native']['configuration'], kind='generated_text',
                  text=naming.decode(), identity=identity(naming))]
    for name in ('silver_io.ads','silver_io.adb','silver_output_libc.ads'):
        unit = name[:-4]+('%b' if name.endswith('.adb') else '%s')
        mapping += unit+'\n'+name+'\n'+root+'/'+name+'\n'
        files.append(dict(role=name,path=root+'/'+name,kind='fixed_source_copy',
                          member='indexed/'+name,identity=identity(context.artifacts['indexed/'+name]),
                          timestamp=context.dependencies[name]['timestamp']))
    files.append(dict(role='source_mapping',path=graph['native']['mapping'],kind='generated_text',
                      text=mapping,identity=identity(mapping.encode())))
    fixed_alis = []
    for name, content in sorted(context.fixed_alis.items()):
        if name.startswith('silver_'):
            require(content == context.artifacts['options/literal-proposed/obj/'+name], 'bound fixed ALI equality')
            path = obj+'/'+name
            files.append(dict(role=name,path=path,kind='fixed_ALI_copy',
                              member='closure/'+name,identity=identity(content)))
        else: path = adalib+'/'+name
        fixed_alis.append(dict(path=path,identity=identity(content)))
    for name in ('silver_io.o','silver_output_libc.o'):
        files.append(dict(role=name,path=obj+'/'+name,kind='fixed_object_copy',
                          member='indexed/obj/'+name,identity=identity(context.artifacts['indexed/obj/'+name])))
    gcc = tool+'/bin/gcc'
    main_argv = [gcc,'-c','-x','ada','-gnatA','-gnat2022','-gnata','-gnato',
                 '-gnatx','-Wno-free-nonheap-object','-fsplit-wide-types',
                 '-gnatec='+graph['native']['configuration'], '-gnatem='+graph['native']['mapping'],
                 graph['Main'],'-o','main~1.o','-gnateI1']
    binder_temp = temp+'/GPR.1000000002/GNAT-TEMP-'
    bmap, bdirs, blist = (binder_temp+suffix+'.TMP' for suffix in ('000001','000002','000003'))
    for role,path,content in [('binder_mapping',bmap,''),('binder_object_path',bdirs,obj+'/\n')]:
        files.append(dict(role=role,path=path,kind='generated_text',text=content,
                          identity=identity(content.encode())))
    gen_env = dict(PATH=environment['PATH'],LC_ALL='C',TMPDIR=temp,ADA_PRJ_OBJECTS_FILE=bdirs)
    gen_argv = [tool+'/bin/gnatbind','-o','b__main~1.adb',graph['native_Main_ALI'],
                '-x','-F='+bmap,'-O='+blist]
    binder_argv = [gcc,*context.binder_invocation['argv'][1:]]
    binder_env = dict(PATH=environment['PATH'],LC_ALL='C',TMPDIR=temp)
    old_obj = context.link_capture['commands'][0]['cwd']
    driver = context.link_capture['commands'][0]['argv']
    require(driver[1] == '-###', 'driver-only historical marker')
    driver = rebind_link([driver[0],*driver[2:]],old_obj,graph)
    # Source-proved removal of exactly the ten plugin fields, with one explicit
    # no-LTO collect2 field, from the retained target expansion.
    old = context.inventory['collect2_argv']
    require(old[1] == '-plugin' and all(x.startswith('-plugin-opt=') for x in old[3:11]),
            'retained plugin field block')
    collect = rebind_link([old[0],'-fno-lto',*old[11:]],old_obj,graph)
    ld = [context.resolution['selected_linker'],*collect[2:]]
    require(len(collect) == 47 and len(ld) == 46, 'two fixed object operands added')
    require(not any(s.startswith(('@','-plugin')) for s in collect), 'no response/plugin arguments')
    asm = tool+'/bin/../lib/gcc/x86_64-pc-linux-gnu/16.1.0/../../../../x86_64-pc-linux-gnu/bin/as'
    processes = [
        dict(role='Main_compile',cwd=obj,argv=main_argv,environment=environment,
             child_frontend=dict(executable=tool+'/bin/../libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1',
                 argv_positions_upper=25,split_option_forwarded=True,output_role='Main_assembly'),
             assembler_argv=[asm,'--64','-o','main~1.o',graph['native']['assembly']],
             outputs=[graph['native_Main_ALI'],graph['native_Main_object']]),
        dict(role='binder_generate',cwd=obj,argv=gen_argv,environment=gen_env,
             outputs=[graph['binder_body'],obj+'/b__main~1.ads',blist]),
        dict(role='binder_compile',cwd=obj,argv=binder_argv,environment=binder_env,
             assembler_argv=[asm,'--64','-o','b__main~1.o',temp+'/cc000001.s'],
             outputs=[obj+'/b__main~1.o',obj+'/b__main~1.ali']),
        dict(role='link',cwd=obj,argv=driver,environment=environment,collect2_argv=collect,
             ld_argv=ld,outputs=[root+'/bin/main'])]
    fixed_link = [{key:row[key] for key in ('path','resolved','role','bytes','sha256')}
                  for row in context.inventory['files'] if row['role'] != 'generated-input']
    probes = []
    for row in context.inventory['library_resolution']:
        converted = json.loads(json.dumps(row))
        for probe in converted['ordered_probes']:
            probe['path'] = probe['path'].replace(old_obj+'/', obj+'/')
        probes.append(converted)
    paths = [f['path'] for f in files]+[r['path'] for r in fixed_alis+fixed_link]
    paths += [probe['path'] for row in probes for probe in row['ordered_probes']]
    paths += [a for p in processes for a in p['argv']+p.get('assembler_argv',[]) if a.startswith('/')]
    paths += [a for a in collect if a.startswith('/')]
    require(all(len(path.encode())+1 <= path_bytes for path in paths), 'complete path envelope')
    bound = context.binder_options['object']
    family = {key:bound['after'][key] for key in ('section_count','symbol_count','relocation_count',
              'maximum_section_alignment','eh_frame_bytes','text_bytes','allocated_bytes')}
    family['file_bytes_upper'] = bound['before']['file']['bytes']
    return dict(scope='selected native literal invocation and pinned fixed-library configuration',
        source_identity=source_id,source_counts=emission['source_counts'],
        path_bytes=path_bytes,host_page_bytes=host_page_bytes,graph=graph,materialization=files,
        processes=processes,
        execution_order=['materialize_fixed_inputs','Main_compile','binder_generate','binder_compile','link'],
        directory_policy='fresh owned root and TMPDIR; create root/obj and root/bin; only listed initial files; no rebuild or fallback jobs',
        compiler_input_policy='one Main source operand; binder body source and companion spec only; imported sources are read, never compiled as jobs',
        common_Main_bindings={phase:dict(path=graph['Main'],identity=source_id)
                     for phase in ('native','datarep','phase1','phase2')},
        shared_System=dict(path=include+'/system.ads',identity=identity(Path(include+'/system.ads').read_bytes())),
        fixed_ALI_inputs=fixed_alis,fixed_link_inputs=fixed_link,ordered_library_resolution=probes,
        fixed_dependency_metadata=context.dependencies,
        compile_jobs=['Main','binder'],fixed_Silver_compile_jobs=0,
        GPR_or_Gprbind_jobs=0,regenerate_fixed_children_selected=False,
        binder_object_family=dict(interface=family,identity_is_variable=True,
            equals_captured_fixture=False,checksum_source=graph['native_Main_ALI']+': U main%b version',
            checksum_domain=[0,2**32-1],GGC_rounded_bytes_upper=context.checksum[
                'universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection'],
            GGC_events_upper=context.checksum['allocation_event_bound'],
            GGC_largest_rounded_request=context.checksum['maximum_rounded_request_bound']),
        emission_interface=emission,link_interface=link,
        selected_native_launch_graph_computable=True,
        selected_main_emission_to_GAS_object_route_bound=True,
        selected_fixed_link_input_materialization_computable=True,
        production_launcher_adopted=False,whole_literal_pipeline_capacity_established=False,
        complete_parent_storage_or_fixed_child_regeneration_closed=False,
        proof_library_verification_waived=False,native_tool_executions=0,
        runtime_placeholders=dict(PID='positive signed-32-bit value; ten decimal positions dominate',
            assembly_nonce='six driver-generated characters; same output/input role, distinct live files'),
        installed_configuration_inputs_checked=len(context.installed_inputs),
        pinned_repository_inputs_checked=context.input_count,
        complete_retained_source_files_checked=len(context.sources),
        remaining=['Aggregate integration must bind its actual source and common launch paths to this result.',
                   'All other native/producer storage, counter and proof obligations remain separate.',
                   'Production adoption and a regenerating fixed-child route are separate configurations.'])


def binder_source_from_ali(raw_ali, result, context):
    """Exhibit the accepted binder family from the actual compiler-output edge.

    Not a replacement binder or a validator for arbitrary ALIs: the caller must
    supply the Main_compile result under the established ALI writer contract.
    """
    units = re.findall(rb'^U main%b\s+main\.adb\s+([0-9a-f]{8})(?:\s|$)',raw_ali,re.M)
    require(len(units) == 1, 'one actual Main U/version field')
    spec = re.sub(rb'(?<=u00001 : constant Version_32 := 16#)[0-9a-f]{8}(?=#;)',units[0],context.spec)
    body = context.artifacts['indexed/obj/b__main~1.adb']
    start = body.index(b'--  BEGIN Object file/option list')
    prefix,comments = body[:start],body[start:]
    old_obj = next(re.finditer(rb'--   (.+)/silver_output_libc\.o',comments))[1]
    new_obj = result['graph']['native']['cwd'].encode()
    require(len(old_obj) == len(new_obj) == 113, 'same-width binder object paths')
    comments = comments.replace(old_obj,new_obj)
    old_tool = str(Path(context.binder_invocation['argv'][0]).parent.parent).encode()
    new_tool = str(Path(result['processes'][0]['argv'][0]).parent.parent).encode()
    comments = comments.replace(old_tool,new_tool)
    require(len(comments) <= len(body[start:]), 'non-growing trailing comments')
    return dict(spec=spec,body=prefix+comments,Main_checksum=int(units[0],16),
                caller_requires_selected_Main_ALI_writer_edge=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    args.output.write_text(json.dumps(build(args.source.read_bytes(),Context()),indent=2)+'\n')
