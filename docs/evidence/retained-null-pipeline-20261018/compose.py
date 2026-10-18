#!/usr/bin/env python3
"""One offline, conditional null-pipeline conjunction from shared actual inputs.

No compiler/prover/server is launched. Closure is conditional on the explicit
selected source, launch graph and external-behavior premises; admission is unchanged.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy
import subprocess
import sys
import tarfile
import tempfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
NATIVE = E / 'unbounded-programs/retained-native-expansion-20261017'
I32, I64, U32 = 2**31-1, 2**63-1, 2**32-1


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(ok, message):
    if not ok:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def selected_record(name):
    return read(E / name)


def archive_member(archive, member):
    with tarfile.open(E / archive) as stream:
        return stream.extractfile(member).read()


def checks(values, **details):
    return dict(status='closed' if all(values.values()) else 'failed',
                conditions=values, **details)


def offline(script, arguments, output=None):
    # Every selected script is an offline evidence checker. Commands are fixed
    # by this module, never accepted from a descriptor or interpolated in a shell.
    result = subprocess.run([sys.executable, str(script), *map(str, arguments)],
                            check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return read(output) if output else json.loads(result.stdout)


class Context:
    def __init__(self, ada_root, frontend_packet):
        self.frontend_packet = Path(frontend_packet).resolve()
        pins = read(HERE / 'inputs.json')
        for row in pins:
            require(identity((REPO / row['path']).read_bytes()) ==
                    {k: row[k] for k in ('bytes', 'sha256')}, 'changed input: '+row['path'])
        self.pins = len(pins)
        self.native = runpy.run_path(str(NATIVE / 'compose-null-capacity.py'))
        self.model = self.native['load_model'](Path(ada_root))
        self.frontend = runpy.run_path(str(self.frontend_packet / 'compose.py'))
        self.frontend_evidence = self.frontend['retained']()
        self.why = runpy.run_path(str(E / 'retained-producer-composition-20261018/check.py'))
        why_record = selected_record('retained-producer-composition-20261018/result.json')
        for path, sha in why_record['input_sha256'].items():
            require(identity((E/path).read_bytes())['sha256'] == sha, 'Why input: '+path)
        self.fixed_counts, self.fixed_modules = self.why['fixed_envelope']()
        self.schema = selected_record('retained-producer-storage-20261018/serialization.json')['schema']
        self.parent = offline(E/'retained-producer-parent-20261018/check-parent.py', [])
        # Reexecute the existing complete offline joins once per Context. Source
        # variants share that successful evidence; none invokes a native tool.
        with tempfile.TemporaryDirectory(prefix='silver-null-pipeline-evidence-') as temp:
            temp = Path(temp)
            self.link = offline(E/'retained-linker-null-composition-20261018/check.py',
                                ['--prior-repo', REPO, '--output', temp/'link.json'], temp/'link.json')
            self.binder = offline(E/'retained-binder-options-20261018/check.py',
                                  ['--output', temp/'binder.json'], temp/'binder.json')
        self.frontend_identity = {
            name: identity((self.frontend_packet/name).read_bytes())
            for name in ('compose.py', 'identity.json', 'fixture.json')}
        self.parent_templates = {}
        for phase, archive, invocation, configuration in (
            ('native', 'retained-gpr-parent-20261018/witnesses.tar.gz',
             'retained-config/invocation.json', 'retained-config/work/selected.cgpr'),
            *[(phase, 'retained-producer-orchestration-20261018/observations.tar.gz',
               'complete_configs/invocation.json',
               'complete_configs/retained-temporaries/'+number+'-GNAT-TEMP-000001.TMP')
              for phase, number in (('datarep','2'),('phase1','12'),('phase2','22'))]):
            self.parent_templates[phase] = dict(
                invocation=json.loads(archive_member(archive,invocation)),
                configuration=archive_member(archive,configuration))
        # These source checks anchor the narrow shortening argument documented
        # in retained-null-pipeline.md; the complete archives are pinned above.
        back_end = archive_member('retained-binder-capacity-20261018/sources.tar.gz',
                                  'gcc/ada/back_end.adb')
        require(b'if Switch_Chars (First .. Last) = "o"' in back_end and
                b'Next_Arg := Next_Arg + 1;' in back_end,
                'binder assembly output must be skipped by GNAT')


def component_descriptor(template, shared, source_path, p, temp, label, graph):
    """Bind all compiler components to the same actual bytes, preserving roles."""
    template = template.resolve()
    d = read(template)
    d['files'] = {role: str((template.parent/path).resolve())
                  for role, path in d['files'].items()}
    for role in ('configuration', 'System'):
        require(Path(d['files'][role]).read_bytes() == shared[role].read_bytes(),
                label+' '+role+' differs from shared input')
        d['files'][role] = str(shared[role])
    d['files']['Main'] = str(source_path)
    d['launch_paths'].update(graph[label])
    mapping=temp/(label+'.map')
    mapping.write_bytes(('main%b\nmain.adb\n'+graph['Main']+'\n').encode('ascii'))
    d['files']['mapping']=str(mapping)
    d['complete_path_bound'] = p
    path = temp / (label+'.json')
    path.write_text(json.dumps(d))
    return path



def launch_graph(runtime, context):
    """Symbolic parent materialization, retaining source bytes in external files.

    The source read projection permits same-width project/source roots and the
    separately justified temporary-path substitution. This is not a capture.
    """
    root=runtime['cwd']; obj=root+'/obj'; proof=obj+'/gnatprove'
    temp=runtime['binder_temporary_root']; main=root+'/main.adb'
    def generated(pid,n):
        return temp+'/GPR.'+pid+'/GNAT-TEMP-'+str(n).zfill(6)+'.TMP'
    # Ten-digit placeholders bound every positive signed-32-bit Linux PID.
    # Materialization preserves the roles/equalities, not these numeric IDs.
    native=dict(Main=main,cwd=obj,configuration=generated('1000000001',2),
                mapping=generated('1000000001',3),assembly=temp+'/cc000000.s')
    rep=proof+'/data_representation'
    datarep=dict(Main=main,cwd=rep,configuration=generated('1000000002',2),
                 mapping=generated('1000000002',3),assembly=rep+'/main~1.o',
                 representation_json=rep+'/main.adb.json')
    phases=[]
    for i,case in enumerate(context.frontend_evidence['plan']['cases']):
        phase=case['name']; cwd=proof+'/phase1' if i==0 else proof
        pid='1000000003' if i==0 else '1000000004'
        retained_options=context.frontend_evidence['raw'][phase+'/options.tmp']
        options=json.loads(retained_options)
        require(json.dumps(options,separators=(',',':')).encode()==retained_options.rstrip(b'\n'),
                'retained options serialization changed')
        if i==1:
            options['why3_dir']=proof+'/'
            for settings in options['file_specific'].values():
                why_args=settings['why3_args']
                require(why_args.count('-j')==1, 'one Why3 worker argument required')
                why_args[why_args.index('-j')+1]=str(runtime['workers'])
        options_content=json.dumps(options,separators=(',',':'))
        options_digest=hashlib.sha1(options_content.encode()).hexdigest()
        options_path=proof+'/'+options_digest[:8]+'.tmp'
        args=[]
        for arg in case['argv']:
            if arg.startswith('-gnatec='):arg='-gnatec='+generated(pid,2)
            elif arg.startswith('-gnatem='):arg='-gnatem='+generated(pid,3)
            elif arg.startswith('-gnates='):arg='-gnates='+options_path
            elif arg.startswith('-gnateO='):arg='-gnateO='+generated(pid,4)
            elif arg.endswith('/main.adb'):arg=main
            args.append(arg)
        system=next(path for path in context.frontend_evidence['plan']['inputs']
                    if path.endswith('/adainclude/system.ads'))
        mapping=('main%b\nmain.adb\n'+main+'\nsystem%s\nsystem.ads\n'+system+'\n').encode()
        phases.append(dict(phase=phase,cwd=cwd,argv=args,
            mapping=mapping.decode(),mapping_identity=identity(mapping),
            options_path=options_path,options_content=options_content,
            options_hash_input_sha1=options_digest,
            options_identity=identity((options_content+'\n').encode()),
            phase2_why3_dir=options.get('why3_dir'),
            object_path_file=(cwd+'\n') if i else None))
    return dict(project_root=root,Main=main,native=native,datarep=datarep,light=phases,
        parent_configurations={phase:generated(str(1000000001+i),1)
                               for i,phase in enumerate(('native','datarep','phase1','phase2'))},
        process_ID_decimal_width_upper=10,
        native_Main_ALI=obj+'/main~1.ali',native_Main_object=obj+'/main~1.o',
        binder_source_directory=obj,binder_body=obj+'/b__main~1.adb',
        phase1_ALI=proof+'/phase1/main~1.ali',phase2_ALI=proof+'/main~1.ali',
        copied_ALI_edge=dict(source=proof+'/phase1/main~1.ali',destination=proof+'/main~1.ali'),
        datarep_ALI=rep+'/main~1.ali',report=proof+'/main~1.spark')


def parent_configuration_projection(context, graph, temporary_root):
    """Rebind only generated header comments, checking the actual fixed payload."""
    result = {}
    for phase, template in context.parent_templates.items():
        invocation, raw = template['invocation'], template['configuration']
        header, body = raw.split(b'configuration project', 1)
        old_root = invocation['cwd'].encode()
        old_temp = invocation['environment']['TMPDIR'].encode()
        require(old_root not in body and old_temp not in body,
                'selected parent path occurs outside its header comment')
        header = header.replace(old_root, graph['project_root'].encode())
        header = header.replace(old_temp, temporary_root.encode())
        header, replaced = re.subn(rb'(?<= --batch -o )[^ ]+',
                                   graph['parent_configurations'][phase].encode(), header)
        require(replaced == 1 and all(not line or line.startswith(b'--')
                for line in header.splitlines()), 'parent header projection')
        candidate = header + b'configuration project' + body
        result[phase] = dict(retained_bytes=len(raw), projected_bytes=len(candidate),
            aligned_extent=4096*((len(candidate)+1+4095)//4096),
            semantic_payload_unchanged=True, identity=identity(candidate))
    return result


def evaluate(descriptor_path, context, source_override=None):
    descriptor_path = Path(descriptor_path).resolve()
    d = read(descriptor_path)
    require(set(d) == {'scope','source','shared_inputs','complete_path_bound',
        'native_descriptor','datarep_descriptor','runtime'}, 'pipeline descriptor schema')
    require(d['scope'] == 'selected indexed null pipeline research', 'pipeline scope')
    resolve = lambda s: (descriptor_path.parent/s).resolve()
    source_path = Path(source_override).resolve() if source_override else resolve(d['source'])
    raw = source_path.read_bytes()
    p = d['complete_path_bound']
    require(type(p) is int and p >= 0, 'nonnegative integer path bound required')
    require(set(d['shared_inputs']) == {'configuration','System'}, 'shared file roles')
    shared = {k:resolve(v) for k,v in d['shared_inputs'].items()}
    lexical = context.native['null_source_counts'](raw)
    require(all(32 <= b <= 126 or b in (9,10,13) for b in raw), 'current ASCII alphabet required')
    frontend_data = context.frontend_evidence['raw']
    require(shared['configuration'].read_bytes() == frontend_data['phase1/GNAT-TEMP-000002.TMP'],
            'light and native naming configuration differ')
    require(shared['System'].read_bytes() == frontend_data['runtime/system.ads'],
            'light and native System bytes differ')
    runtime = d['runtime']
    require(set(runtime) == {'workers','host_page_bytes','socket_directory','cwd',
                            'binder_source_directory','binder_temporary_root'}, 'runtime input roles')
    j, page = runtime['workers'], runtime['host_page_bytes']
    require(type(j) is int and type(page) is int, 'integer workers/page inputs required')
    for key in ('socket_directory','cwd','binder_source_directory','binder_temporary_root'):
        value = runtime[key]
        require(isinstance(value,str) and value.startswith('/') and
                all(32 <= ord(c) <= 126 for c in value), 'absolute ASCII '+key+' required')
    graph=launch_graph(runtime,context)
    parent_configs=parent_configuration_projection(context,graph,runtime['binder_temporary_root'])
    obligations = {}
    obligations['shared_inputs'] = checks(dict(
        source_configuration_System_bytes_shared=True,
        runtime_paths_within_P=max(len(runtime[k]) for k in runtime if isinstance(runtime[k],str)) <= p,
        power_of_two_host_page=page > 0 and page & (page-1) == 0),
        source=identity(raw), configuration=identity(shared['configuration'].read_bytes()),
        System=identity(shared['System'].read_bytes()), complete_path_bound=p)
    with tempfile.TemporaryDirectory(prefix='silver-null-pipeline-') as td:
        temp = Path(td)
        native_descriptor = component_descriptor(resolve(d['native_descriptor']), shared, source_path,p,temp,'native',graph)
        datarep_descriptor = component_descriptor(resolve(d['datarep_descriptor']), shared, source_path,p,temp,'datarep',graph)
        native = context.native['compose'](native_descriptor, context.model)
        datarep = context.native['compose'](datarep_descriptor, context.model, producer_datarep=True)
        # The wrapper's prefix checks are essential: calling the generic native
        # formula with producer_datarep=True alone is not its prefix bridge.
        prefix = selected_record('retained-producer-parent-20261018/prefix-result.json')
        baseline = read(NATIVE/'native-gcc-prefix-witness.json')
        prefix_checks = dict(alternate_binary=datarep['inputs']['gnat1']['sha256'] == prefix['gnat1_sha256'],
            complete_replay=prefix['event_records_replayed'] == 47707 and prefix['hardware_write_watchpoints'] == 4,
            no_wrap_or_collection=not prefix['counter_wrap_or_reset'] and not prefix['collection_or_new_thread_observed'],
            event_projection=all(prefix['counters'][n][k] == baseline['counters'][n][k]
                for n in ('ggc_bytes','decl_uid','type_uid','debug_decl_uid')
                for k in ('events','positive_events','negative_events')),
            UID_projection=all(prefix['counters'][n] == baseline['counters'][n]
                for n in ('decl_uid','type_uid','debug_decl_uid')))
        parent = offline(E/'retained-producer-orchestration-20261018/check.py',
                         ['--source',source_path,'--output',temp/'parent.json'],temp/'parent.json')
    front_descriptor = read(context.frontend_packet/'fixture.json')
    front_descriptor['complete_path_bound'] = p
    frontend = context.frontend['compose'](raw,front_descriptor,context.model,context.frontend_evidence)
    obligations['native_compiler'] = checks(native['component_checks'],
        source=native['inputs']['Main'], source_counts=native['source_counts'],
        selected_GGC_events=native['GCC_GGC_events_upper_under_selected_read_projection'])
    obligations['datarep_compiler'] = checks(dict(**datarep['component_checks'], **prefix_checks),
        source=datarep['inputs']['Main'], representation_output=datarep['representation_output'])
    obligations['light_frontends'] = checks(frontend['component_checks'], source=frontend['source'],
        phase_name_demands={phase:{k:r['logical_table_demands'][k] for k in
            ('namet__name_entries__last_val','namet__name_chars__last_val')}
            for phase,r in frontend['phases'].items()})
    # Older native wrapper prices 24 gnat1 arguments. The selected split option
    # requires 25 and one additional A row. Price the changed interface here.
    argument = max(24,p+8)
    split = selected_record('retained-split-options-20261018/result.json')
    switches = context.model['native_table_backing_row'](50,1,30,100,16,I32)
    obligations['native_split_option_delta'] = checks(dict(
        original_argv_and_decoded=(26*8 <= I64 and 25*96 <= I64),
        canonical_argv_and_Ada=(51*8 <= I64 and 49*16 <= I64),
        option_obstack=4*(argument+67)+116 <= I32,
        stored_switches=switches['all_selected_checks_pass'],
        explicit_option_vector=4616 <= I64,
        Main_ALI_and_reader=split['ALI_delta']['null_complete_ALI_bound']+1 <= I32),
        gnat1_argc=25, canonical_switch_envelope=50,
        Main_ALI_bytes=split['ALI_delta']['null_complete_ALI_bound'],
        source_projection='retained-split-options.md; selected option preserves frontend/GIMPLE/pass-expand shape')
    parent_conditions = dict(parent['conditions'])
    parent_conditions['datarep_ALI_buffer'] = datarep['components']['ALI']['serialized_file_byte_bound']+1 <= I32
    obligations['parent_source_ALI_interfaces'] = checks(parent_conditions,
        actual_source_sha256=parent['source_sha256'],
        fixed_GPR_extent=parent['fixed_GPR_aligned_extent_per_process'],
        GPR_ALI_rows=parent['selected_GPR_ALI_rows'])
    # Source counters are obtained from the complete scanner above. The old
    # illustrative lexical() helper does not strip comments and is not used.
    counts = dict(W=lexical['word_tokens'], I=lexical['max_identifier_length'],
                  S=0,N=0,null=1,shape_regions=[dict(null=1)])
    why = context.why['compose'](counts,context.schema,context.fixed_counts,context.fixed_modules,p)
    a=why['auxiliary']; n,l,e,emitted=why['totals']
    obligations['Why_core'] = checks(dict(nodes=n<=2**30-1,lists=l<=2**30,elements=e<=I32,
        emitted=emitted<=I32,why_symbols=a['why_calls']<=1610612741,
        common_symbols=a['common_calls']<=1610612741,entity_symbols=a['why_symbol_map']<=1610612741,
        source_nodes=a['A_total']<=1610612741,undo=a['undo_peak']<=I32,
        string_lengths=max(v for k,v in why['string_lengths'].items() if k!='symbol_set_characters')<=1073741822,
        JSON=why['json_bytes']<=2147483646),
        source_counts=counts,A_Main=why['A_Main'],totals=why['totals'],JSON_bytes=why['json_bytes'])
    # Producer ALI: recompute formula with the current descriptor, never reuse
    # a pass flag or the older 9-row switch substitution.
    A,As,Am,C,Pali=10,77,24,0,10
    xrefs=50+16*11+2*(12784+1)+1
    F=17+64+64+As+3*A+110*56+5+(Pali+161)+(2*Pali+81)+(C+2)*(2*Pali+65)+6+10+xrefs*(Pali+1138)+26+947
    R=max(17,64,Am+3,Pali+161,2*Pali+81,2*Pali+65,789,335,Pali+14,289,26)
    ali_rows=dict(ALIs=2,Units=2,Withs=1,Args=A+10,Sdep=C+3,Invocation_Signatures=5,Invocation_Constructs=5)
    obligations['producer_ALI_GG'] = checks(dict(writer_record=R<=2112,reader=F+1<=I32,
        physical_lines=A+C+150+3*xrefs<=I32,GG_cursor=286<=I32,
        read_population=max(ali_rows.values())<=I32),
        ALI_file_bytes=F,ALI_record_bytes=R,ALI_lines=A+C+150+3*xrefs,
        GG_bytes=947,GG_rows=11,phase2_ALI_rows=ali_rows)
    # Report, options and SARIF share the same complete path bound and corrected
    # 17-argument parent command. Every formula is reevaluated at this P.
    B=1246+6*p; D=max(p,32); Dr=max(2*p,32); backing=B+B//2+128
    config=349+12*p; command=213+p; opts=(5711,6635+6*p); sarif=max(258,command,p,20)
    obligations['reports_options_storage'] = checks(dict(
        report_file=B+1<=min(262144,16777216,65536),
        producer_XString=D+4096<=I32,parser_XString=3*(3*Dr//2+4096)<2**32,
        report_backing=backing+64<=I32,Text_IO_column=B+1<=I32,
        JSON_refs=max(8,42,46,16)<2**32,
        parent_configuration=config<=65536,parent_command=command<=I32,
        options_files=max(opts)<=65536,options_backing=max(opts)+max(opts)//2+192<=I32,
        rebound_options_within_envelopes=all(phase['options_identity']['bytes']<=bound
            for phase,bound in zip(graph['light'],opts)),
        local_graph_counts=89**2+1<=I32,local_graph_backing=8192*16<=I64,
        dominator_size=178<=I32,visibility_graph=17**2<=I32,
        SARIF_character_count=sarif<=2**30-1,SARIF_segment=sarif+129<=I32,
        SARIF_arrays=max(921680,25312,88544)<=I64,SARIF_refs=56<=U32),
        report_file_bytes=B+1,report_backing_bytes=backing+64,
        parent_configuration_bytes=config,parent_command_bytes=command,
        options_file_bytes=list(opts),ordinary_report_bytes=1719+p,SARIF_text_bytes=sarif,
        no_Main_Why3_or_solver_clients=True)
    socket=len(runtime['socket_directory'])+27
    obligations['idle_why3server'] = checks(dict(worker_count=1<=j<=I32//2,
        socket_directory_matches_writable_TMPDIR=(
            runtime['socket_directory']==runtime['binder_temporary_root']),
        backlog=0<=2*j<=I32,poll_index=0<=j+2<=I32,
        independent_request=max(800,8*(j+2),socket+1,len(runtime['cwd'])+1)<=I64,
        socket_basename=26+1<=108),workers=j,poll_records=j+2,largest_request=max(800,8*(j+2)),
        socket_path_bytes=socket,
        source_projection='zero Main client launches; no external clients/logging under selected descriptor')
    assembly=selected_record('retained-assembler-capacity-20261018/event-check-results.json')
    obj=selected_record('retained-assembler-capacity-20261018/object-check-results.json')
    inner=selected_record('retained-assembler-capacity-20261018/inner-check-results.json')
    obligations['Main_assembler_object'] = checks(dict(
        scrub=assembly['assembly_file_bytes_upper']<65536,
        physical_line_counter=assembly['GAS_physical_line_counter_including_spare_sentinel_upper']<=I32,
        explicit_requests=max(inner['unchanged_notes_chunk_request_upper'],65539,p+1)<=I64,
        BFD_counter=32065<=2**64-1,
        ELF_object=obj['object_file_bytes_upper']<=I32,
        ordinary_ELF_indices=obj['section_headers_including_null']<0xff00,
        GAS_inventory=inner['selected_GAS_owned_parser_writer_dynamic_request_inventory_complete']),
        assembly_bytes=assembly['assembly_file_bytes_upper'],object_bytes=obj['object_file_bytes_upper'],
        output_path='main~1.o',selected_argc=5)
    binder=context.binder['cases']['null']; life=binder['lifetime']; before=binder['object']['before']; after=binder['object']['after']
    root_bytes=len(runtime['binder_temporary_root'])
    name_chars=792737+2*root_bytes
    name_table=context.model['native_table_backing_row'](name_chars,0,50000,100,1,I32)
    obligations['binder_generation_and_fixed_compiler'] = checks(dict(
        same_width_source_directory=len(runtime['binder_source_directory'])==113,
        same_width_full_source=len(runtime['binder_source_directory']+'/b__main~1.adb')==127,
        temporary_output_no_longer_than_witness=len(runtime['binder_temporary_root'])<=52,
        Name_Chars=name_table['all_selected_checks_pass'],Name_entries=8282<99999999,
        Gprbind_Main_ALI=split['ALI_delta']['null_complete_ALI_bound']+1<=I32,
        split_Args=split['ALI_delta']['indexed_combined_A_records']<=1000,
        generation_line=max(191,p+1)<=32767,statement=139<=1000,
        no_collection=life['counters']['ggc_bytes']['positive_sum']<5*1024**2,
        declaration_UID=life['counters']['decl_uid']['peak']<=I32,
        type_UID=life['counters']['type_uid']['peak']<=U32,
        collector_requests=max(life['each_page_pointer_vector_bytes_bound'],life['scalar_finalizer_vector_bytes_bound'],life['array_finalizer_vector_bytes_bound'])<=I64,
        split_object_dominated=all(after[k]<=before[k] for k in
            ('section_count','symbol_count','relocation_count','allocated_bytes','text_bytes','eh_frame_bytes','maximum_section_alignment'))),
        Name_character_demand=name_chars,binder_object=after['file'],
        first_collection_margin=5*1024**2-life['counters']['ggc_bytes']['positive_sum'],
        transfer='null lexical checksum fixed; same-width source path/comment projection; shorter temporary assembly output changes only ordinary argv/path requests; split-option object delta separately verified')
    link=context.link; bound=link['additional_bounds']
    obligations['linker'] = checks(dict(
        object_ID=bound['BFD_object_ID_events']<=U32,section_ID=bound['BFD_section_ID_peak']<=U32,
        start_stop=bound['start_stop_capacity']<=I64//8,
        reader=max(bound['Main_ELF_reader'].values())<=I64,
        addresses=2*link['retained_address_endpoint']<=I32,
        relocation=link['common_signed_relocation_bound']<=I32,
        file_offset=link['file_position_endpoint']<=I64,
        host_page_scratch=max(4*page,link['payload_union_bytes']+2*page)<=I64),
        Main_object_interface=dict(sections=obj['section_headers_including_null'],
            symbols=obj['outgoing_symbol_entries_including_null'],relocations=obj['relocations_upper']),
        binder_split_object_sha256=after['file']['sha256'],
        source_projection='selected no-LTO PIE fixed-input resolution plus reviewed Main and dominated split binder interfaces')
    obligations['parent_fixed_read_projection'] = checks(dict(
        indexed_GPR2_Main_parser_calls=context.parent['indexed_Main_source_parses_in_GPR2_discovery']==0,
        single_source=lexical['tokens'][0]=='procedure',
        source_ALI_interfaces=obligations['parent_source_ALI_interfaces']['status']=='closed',
        options_and_report_interfaces=obligations['reports_options_storage']['status']=='closed'),
        basis=['retained-gpr-parent.md: complete six-call Sinput frontier and final fixed-context projection',
               'retained-producer-parent.md: complete indexed discovery route',
               'retained-producer-orchestration.md: fresh directories, DW parser, remaining generated-input read frontier'],
        transferred='Fixed project/configuration parser, directory/queue cardinalities, tool selection and command structure under their retained path/option class.',
        descriptor_realization_separate=True)
    rebound_strings=[]
    def strings(value):
        if isinstance(value,str):rebound_strings.append(value)
        elif isinstance(value,dict):
            for key,item in value.items():
                if key not in ('mapping','mapping_identity','options_identity','options_content'):strings(item)
        elif isinstance(value,list):
            for item in value:strings(item)
    strings(graph)
    # argv values include the eight-character option prefix already charged;
    # count path payloads rather than silently requiring P to include switches.
    path_payloads=[v.split('=',1)[1] if v.startswith('-gnate') and '=' in v else v
                   for v in rebound_strings if v.startswith('/') or v.startswith('-gnate') and '=' in v]
    obligations['unified_launch_descriptor'] = checks(dict(
        fixed_parent_root_width=len(runtime['cwd'])==109,
        common_temporary_root_width=len(runtime['binder_temporary_root'])==48,
        safe_normalized_path_spelling=all(re.fullmatch(r'/[A-Za-z0-9_./~-]+',runtime[key])
            and '//' not in runtime[key] and
            all(part not in ('.','..') for part in runtime[key].split('/'))
            for key in ('cwd','binder_source_directory','binder_temporary_root','socket_directory')),
        GPR_configuration_extent=all(row['aligned_extent']<=8192 for row in parent_configs.values()),
        native_object_and_binder_directory=graph['native']['cwd']==runtime['binder_source_directory'],
        binder_source_width=len(graph['binder_body'])==127,
        native_naming_TMP=graph['native']['configuration'].endswith('.TMP'),
        datarep_naming_TMP=graph['datarep']['configuration'].endswith('.TMP'),
        all_launch_paths_bounded=max(map(len,path_payloads))<=p,
        light_argc=all(len(phase['argv'])-1==17 for phase in graph['light']),
        light_Main_binding=all(graph['Main'] in phase['argv'] for phase in graph['light']),
        two_light_map_triples=all(len(phase['mapping'].splitlines())==6 for phase in graph['light']),
        copied_ALI_source=graph['copied_ALI_edge']['source']==graph['phase1_ALI'],
        copied_ALI_destination=graph['copied_ALI_edge']['destination']==graph['phase2_ALI'],
        datarep_JSON_binding=graph['datarep']['representation_json']==graph['datarep']['cwd']+'/main.adb.json'),
        launch_graph=graph,
        parent_configuration_projection=parent_configs,
        temporary_path_transfer='One common 48-byte root preserves native parent width; producer roots shrink from 54, binder assembly output root from 52. Ten-digit PID names are bounded explicitly. Source/semantic path equality classes remain fixed.',
        path_substitution_basis='Existing 32-role frontend correction and documented parent/binder path projections; only phase2 option why3_dir changes.',
        no_capture_relabeling=True,
        native_TMP_ALI_dependency_delta='The standalone native .adc fixture overcharges one config dependency; TMP selects C_dependencies=0 and the independent 399-byte no-Xref specialization.',
        selected_native_split_option='GPR command String/argument vectors and the gprbind A-row String receive the explicit bounded one-element split-option delta; project-source syntax is unchanged.')
    for name,expected in context.frontend_identity.items():
        require(identity((context.frontend_packet/name).read_bytes())==expected,
                'frontend packet changed during evaluation: '+name)
    failed=[k for k,v in obligations.items() if v['status']=='failed']
    opened=[k for k,v in obligations.items() if v['status']=='open']
    return dict(scope=d['scope'],source=identity(raw),source_path=str(source_path),
        complete_path_bound=p,obligations=obligations,
        closed_obligations=[k for k,v in obligations.items() if v['status']=='closed'],
        failed_obligations=failed,open_obligations=opened,
        evaluated_predicates_pass=not failed,whole_null_pipeline_capacity_established=not failed and not opened,
        next_blocker=(failed+opened)[0] if failed or opened else None,
        next_research_blocker='non_null_source_to_pipeline_composition',
        retained_inputs_verified=context.pins,frontend_component_identity=context.frontend_identity,
        conditional_premises=[
            'Selected installed relevant behavior matches the reviewed external sources and retained fixed-input projections.',
            'Parent materializes the computed shared launch roles/equalities and fixed project/configuration semantic bytes; process IDs may use any positive signed-32-bit value, within the explicit ten-digit bounds. P covers raw/normalized/resolved/generated/search names.',
            'Selected runtime/search/option graph, no external Why3 clients, and ordinary supported Linux ABI/services/resources.',
            'Binder source filenames/comments are same-width; the common temporary root is 48 bytes and its assembly-output argv/path requests are dominated by the 52-byte-root witness.'],
        outside_this_research_component=['Production SPARK/Lean recognizer and counter correspondence; useful broader-language comparison required by #119.'],
        production_admission_changed=False,native_tool_executions=0,aggregate_RAM_gate=False)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--descriptor',type=Path,default=HERE/'fixture.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--ada-root',type=Path,required=True)
    parser.add_argument('--frontend-packet',type=Path,default=E/'retained-producer-null-frontend-20261018')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.descriptor,Context(args.ada_root,args.frontend_packet),args.source)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('evaluated_predicates_pass','whole_null_pipeline_capacity_established','failed_obligations','open_obligations','next_blocker')}))


if __name__=='__main__':
    main()
