#!/usr/bin/env python3
"""Attach the reviewed GCC-driver/collect2-shell transfer to actual source bytes.

This is offline research evidence, not a production launcher or proof checker.
No native executable is invoked. Source arguments in the companion report are
required; source/hash checks and arithmetic alone do not establish the theorem.
"""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import runpy
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
I32, I64 = 2**31-1, 2**63-1


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


def vector(demand):
    require(type(demand) is int and 0 <= demand <= I32, 'vector demand')
    cap = 10
    while cap < demand:
        cap = cap*2 if cap < 16 else cap*3//2
    require(8+8*cap <= I64, 'vector request')
    return dict(demand=demand, capacity=cap, request_bytes=8+8*cap)


def chunk(size):
    require(type(size) is int and 0 <= size <= I32, 'partial obstack size')
    result = max(4064, size+15+size//8+100)
    require(result+15 <= I64, 'obstack chunk and alignment')
    return result


def partition(argv):
    """Specialize process_command only after exact invocation attachment."""
    switches, operands, infiles = [], [], []
    i = 1
    while i < len(argv):
        arg = argv[i]
        if arg == '-x':
            require(argv[i+1] == 'ada', 'selected explicit language')
            i += 2
        elif arg == '-o':
            switches.append(arg); operands.append(argv[i+1]); i += 2
        elif arg.startswith('-Wl,'):
            infiles.extend(arg[4:].split(',')); i += 1
        elif arg.startswith('-l'):
            infiles.append(arg); i += 1
        elif arg.startswith('-'):
            switches.append(arg); i += 1
        else:
            infiles.append(arg); i += 1
    defaults = [s for s in ('-mtune=generic','-march=x86-64')
                if not any(a.startswith(s.split('=')[0]+'=') for a in switches)]
    return switches+defaults, operands, infiles, defaults



def frontend_interface(process, switches, operands, infiles):
    """Source specialization of Ada lang-specs + dumps/give_switch; no capture."""
    tool_bin = str(Path(process['argv'][0]).parent)
    executable = tool_bin+'/../libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1'
    source, output = infiles[0], operands[0]
    base = Path(output).name.rsplit('.',1)[0]+'.adb'
    forwarded = [s for s in switches if s.startswith(('-g','-m','-f'))]
    argv = [executable,'-quiet','-Wno-free-nonheap-object','-dumpbase',base,
            '-dumpbase-ext','.adb',*forwarded,'-gnatO',output,source,'-o',process['assembler_argv'][-1]]
    fields = []
    for switch in switches:
        fields.append(switch)
        if switch == '-o': fields.append(output)
    require(all("'" not in field for field in fields), 'selected unescaped collected fields')
    env = dict(process['environment'],GCC_EXEC_PREFIX=tool_bin+'/../lib/gcc/',
               COLLECT_GCC=process['argv'][0],COLLECT_GCC_OPTIONS=' '.join("'"+field+"'" for field in fields))
    actual = 23 if process['role']=='Main_compile' else 20
    upper = 25 if process['role']=='Main_compile' else 20
    require(len(argv)==actual and len(env)==(10 if process['role']=='Main_compile' else 6), 'source-expanded frontend interface')
    return dict(argv=argv,environment=env,argv_positions_exact_from_source=actual,
                argv_positions_accepted_upper=upper,argv_max_bytes_including_NUL=max(len(a.encode())+1 for a in argv),
                environment_entries=len(env),environment_entry_max_bytes_including_NUL=max(len((k+'='+v).encode())+1 for k,v in env.items()),
                argv_total_bytes_including_NUL=sum(len(a.encode())+1 for a in argv),
                environment_total_bytes_including_NUL=sum(len((k+'='+v).encode())+1 for k,v in env.items()),
                argument_character_upper=max(24,512+8),temporary_nonce='six characters, graph placeholder; same .s passed to assembler',
                option_source='exact retained switch order; Ada g*&m*&f* and separate W*, explicit -gnatO',
                main_contents_read_by_driver=False,observed_new_native_capture=False,
                frontend_theme=('ASCII' if env.get('LANG')=='C' else 'emoji'))


def verify_lifecycle(record, raw):
    require(identity(raw) == {k:record[k] for k in ('bytes','sha256')}, 'selected '+record['role'])
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
    require(h[0][:7] == b'\x7fELF\x02\x01\x01' and h[2] == 62, 'LP64 x86-64 ELF')
    sections = [struct.unpack_from('<IIQQQQIIQQ',raw,h[6]+i*h[11]) for i in range(h[12])]
    st = sections[h[13]]; names = raw[st[4]:st[4]+st[5]]
    z = lambda buf,at: buf[at:buf.index(b'\0',at)].decode()
    named = {z(names,row[0]):row for row in sections}
    def at(addr,size):
        owners = [s for s in sections if s[1] != 8 and s[3] <= addr and addr+size <= s[3]+s[5]]
        require(len(owners) == 1, 'one ELF byte interval')
        s = owners[0]; return raw[s[4]+addr-s[3]:s[4]+addr-s[3]+size]
    def array(name):
        s = named[name]; return list(struct.unpack_from('<'+'Q'*(s[5]//8),raw,s[4]))
    require(array('.init_array') == record['init_array'] and array('.fini_array') == record['fini_array'], 'ELF lifecycle roots')
    require('.preinit_array' not in named and not record['preinit_array_present'], 'no preinit root')
    require([r['address'] for r in record['roots']] == [r for r in record['init_array'] if r not in
            (record['CRT_init'],record['Cxx_runtime_init'])], 'exact GCC versus runtime root partition')
    registrations, calls, instruction_count = [], [], 0
    for root in record['roots']:
        next_address = root['address']; edi = None
        for ins in root['instructions']:
            addr, code, op, operands = ins['address'], bytes.fromhex(ins['hex']), ins['mnemonic'], ins['operands']
            require(addr == next_address and at(addr,len(code)) == code, 'complete initializer instruction bytes')
            instruction_count += 1; next_address += len(code)
            match = re.fullmatch(r'\$0x([0-9a-f]+), %edi',operands)
            if op == 'movl' and match: edi = int(match[1],16)
            elif op == 'leaq' and operands.endswith('(%rip), %rdi'):
                require(code[:3] == b'\x48\x8d\x3d' and len(code)==7, 'RIP-relative callback')
                edi = addr+7+struct.unpack_from('<i',code,3)[0]
            elif re.search(r', %[er]di$',operands): edi = None
            require(not(op.startswith('j') and op != 'jmp'), 'straight-line GCC initializer')
            if op in ('callq','jmp'):
                require(code[0] in (0xe8,0xe9) and len(code)==5, 'direct initializer call')
                target = addr+5+struct.unpack_from('<i',code,1)[0]
                require(target == int(operands,16), 'retained call decoding')
                if target == record['cxa_atexit_plt']:
                    require(edi is not None, 'constant destructor address')
                    registrations.append(dict(site=addr,root=root['address'],destructor=edi))
                else: calls.append(dict(site=addr,root=root['address'],target=target))
                edi = None
        require(root['instructions'][-1]['mnemonic'] in ('retq','jmp'), 'complete root through return/tail')
    require(registrations == record['registrations'] and calls == record['calls'], 'root registration/call census')
    for window in record['windows']+record['other_direct_registration_candidates']:
        code = bytes.fromhex(window['hex']); addr = window.get('address',window.get('start'))
        require(at(addr,len(code)) == code, 'retained lifecycle source-correspondence window')
    s = named['.text']; code = raw[s[4]:s[4]+s[5]]
    hits = [s[3]+i for i in range(len(code)-4) if code[i] in (0xe8,0xe9)
            and s[3]+i+5+struct.unpack_from('<i',code,i+1)[0] == record['cxa_atexit_plt']]
    require(hits == sorted([r['site'] for r in registrations]+[r['site'] for r in record['other_direct_registration_candidates']]), 'all direct registration byte candidates')
    expected = (8,30,9) if record['role']=='gcc' else (4,3,3)
    require((len(record['roots']),len(registrations),len({r['destructor'] for r in registrations})) == expected, 'selected source groups')
    return dict(role=record['role'],GCC_initializer_roots=len(record['roots']),GCC_static_registrations=len(registrations),
                GCC_destructor_targets=expected[2],verified_initializer_instructions=instruction_count,
                other_direct_candidates=2,existing_CRT_and_Cxx_boundaries=True,
                statistics_maps=3,statistics_map_control_upper=96,statistics_map_backing_upper=312,
                selected_static_exit_new_requests=0)


class Context:
    def __init__(self):
        pins = read(HERE/'inputs.json')
        for row in pins:
            require(identity((REPO/row['path']).read_bytes()) == {k:row[k] for k in ('bytes','sha256')},row['path'])
        self.repository_pins = len(pins)
        manifest = read(HERE/'sources.json')
        require(identity((HERE/'sources.tar.gz').read_bytes())['sha256'] == manifest['archive_sha256'], 'source archive identity')
        corpus = json.loads(gzip.decompress((E/'retained-split-options-20261018/gcc-corpus-manifest.json.gz').read_bytes()))
        known = {r['path']:r for r in corpus['files']}
        for prior in ('retained-native-driver-20261018','retained-native-environment-20261018'):
            known.update({r['path']:r for r in read(E/prior/'sources.json')['files']})
        for row in manifest['files']:
            if 'installed_path' not in row:
                require(row['path'] in known and all(row[k] == known[row['path']][k] for k in ('bytes','sha256')), 'source correspondence to retained revision')
        self.sources = {}
        with tarfile.open(HERE/'sources.tar.gz') as archive:
            require(set(archive.getnames()) == {r['path'] for r in manifest['files']}, 'complete selected source set')
            for row in manifest['files']:
                raw = archive.extractfile(row['path']).read()
                require(identity(raw) == {k:row[k] for k in ('bytes','sha256')},row['path'])
                if 'installed_path' in row:
                    require(Path(row['installed_path']).read_bytes() == raw, 'selected installed header')
                self.sources[row['path']] = raw.decode()
        self.api = runpy.run_path(str(E/'retained-literal-invocation-join-20261018/compose.py'))
        self.join = self.api['Context']()
        self.paths = read(E/'retained-native-environment-20261018/path-configuration.json')
        self.verify_specs_absence()
        dump = gzip.decompress((E/'unbounded-programs/retained-native-expansion-20261017/fixed-gcc-prefix-witness/dumpspecs.stdout.gz').read_bytes()).decode()
        self.specs = {k:v.removesuffix('\n\n') for k,v in re.findall(r'^\*([^:\n]+):\n(.*?)(?=^\*|\Z)',dump,re.M|re.S)}
        require(len(self.specs)==47 and max(map(len,self.specs.values()))==2901,'fixed spec inventory')
        require(all(self.specs[k]=='' for k in ('self_spec','startfile_prefix_spec','sysroot_suffix_spec','sysroot_hdrs_suffix_spec')), 'empty override spec routes')
        gcc = self.sources['gcc/gcc.cc']
        table = gcc.split('static const struct compiler default_compilers[] =',1)[1].split('static const int n_default_compilers',1)[0]
        counts = [len(re.findall(r'\{\s*"[^"\n]+"\s*,',v)) for v in (table,
                  self.sources['gcc/ada/gcc-interface/lang-specs.h'],self.sources['gcc/cp/lang-specs.h'])]
        require(counts == [50,5,27], 'configured compiler table census')
        self.compiler_records = sum(counts)+1
        static = gcc.split('static struct spec_list static_specs[] =',1)[1].split('#ifdef EXTRA_SPECS',1)[0]
        require(static.count('INIT_STATIC_SPEC (')==45, 'static spec-list census')
        require('diagnostic_initialize (global_dc, 0);' in gcc and 'diagnostic_initialize (global_dc, 0);' in self.sources['gcc/collect2.cc'], 'fresh driver and collect2 diagnostic roots')
        require('driver d (false, /* can_finalize */' in self.sources['gcc/gcc-main.cc'], 'standalone driver destructor selection')
        require('#define GATHER_STATISTICS 0' in self.sources['installed/auto-host.h'], 'no statistics population')
        self.lifecycle = [verify_lifecycle(r,Path(r['path']).read_bytes()) for r in read(HERE/'lifecycle.json')]

    def verify_specs_absence(self):
        rows = self.paths['implicit_specs_candidates']
        require(len(rows)==5, 'all five selected initial specs candidates')
        for row in rows:
            require(not row['exists_without_following_symlinks'] and not row['readable'] and
                    not os.path.lexists(row['path']) and not os.access(row['path'],os.R_OK), 'absent implicit specs: '+row['path'])


def evaluate(raw, context, runtime=None, invocation=None):
    """Actual recognized bytes and exact accepted native graph are mandatory."""
    require(isinstance(raw,bytes), 'actual source bytes')
    graph = context.api['build'](raw,context.join,runtime=runtime,path_bytes=512)
    if invocation is not None:
        require(invocation == graph, 'actual invocation equals the accepted source-bound graph')
    P = graph['path_bytes']; A=max(24,P+8); W=4*(A+67)
    rows=[]
    for process in graph['processes']:
        role=process['role']
        if role=='binder_generate': continue
        argv,env=process['argv'],process['environment']
        require(len(argv)==17 and not any(x.startswith('@') for x in argv), 'exact driver argv domain')
        require(set(env)==({'PATH','LC_ALL','TMPDIR'} if role=='binder_compile' else
                {'PATH','LC_ALL','LANG','TERM','TMPDIR','ADA_INCLUDE_PATH','ADA_OBJECTS_PATH'}), 'exact driver environment')
        switches,operands,infiles,defaults=partition(argv)
        expected={'Main_compile':(14,1,2),'binder_compile':(12,1,0),'link':(9,12,2)}[role]
        require((len(switches),len(infiles),len(defaults))==expected and len(operands)==1, 'driver source projection')
        require(len(switches)+1<=16 and len(infiles)+1<=16, 'switch/infile sentinels')
        child_upper=47 if role=='link' else (25 if role=='Main_compile' else 20)
        require(role!='Main_compile' or process['child_frontend']['argv_positions_upper']==25,'accepted frontend envelope retained')
        if role=='link': require(len(process['collect2_argv'])==47 and len(process['ld_argv'])==46,'accepted link child interfaces')
        # Each switch, plus the separated -o operand, plus optional dumpdir.
        collect_options=20+(len(switches)+1)*(4*(P+8)+4)+4*P+14
        T=max(len(env['TMPDIR']),len('/var/tmp'))
        strings=dict(option_canonical_object=W,options_obstack_chunk=max(4096,W+116),
            local_spec_or_helper_object=max(2902,P+9,6*P+37),COLLECT_GCC_OPTIONS=collect_options,
            COLLECT_GCC=P+13,COLLECT_LTO_WRAPPER=(P+20 if role=='link' else 0),
            GCC_EXEC_PREFIX=P+17,COMPILER_PATH=14+6*(P+1),LIBRARY_PATH=14+19*(P+1),
            search_buffer=P+1,quote_path=2*P+1,relocation_result=5*P+1,
            relocation_component=P+1,relocation_pointer_array=8*(P+2),canonical_local=4096,
            canonical_result=P+1,temp_directory=T+2,temp_name=T+12,
            copied_path_or_temp_queue_name=P+1)
        require(all(v<=I32 for v in strings.values()),'all narrowed string/path arithmetic')
        partial=max(strings['local_spec_or_helper_object'],strings['COLLECT_GCC_OPTIONS'],
                    strings['COMPILER_PATH'],strings['LIBRARY_PATH'],strings['COLLECT_LTO_WRAPPER'])
        rows.append(dict(role=role,argv_positions=len(argv),frontend=(None if role=='link' else frontend_interface(process,switches,operands,infiles)),retained_switches=switches,input_records=infiles,
            inserted_defaults=defaults,separated_operand_pointer_request=16,
            decoded_option_request=17*96,per_default_decode_request=192,per_default_temporary_argv_request=16,
            switch_request=16*24,infile_request=16*32,outfile_request=8*len(infiles),
            explicit_link_file_request=len(infiles),compiler_table_request=32*context.compiler_records,
            extra_spec_list_request=48,prefix_list_record=32,program_prefix_records=2,library_prefix_records=5,include_prefix_records=0,argbuf=vector(child_upper+1),
            at_file_argbuf_initial_request=88,spec_function_argbuf_request=88,
            selected_helper_calls=(11 if role=='link' else 3),spec_helper_nesting=1,
            spec_expansion_nesting_upper=64,selected_argument_or_queue_events_upper=128,
            temp_associations=(0 if role=='link' else 1),temp_association_record=40,temp_association_suffix_copy=3,temp_queue_record=16,
            distinct_temp_queue_names_upper=(1 if role=='link' else 2),
            successful_child_commands=(1 if role=='link' else 2),per_child_command_record=16,
            per_child_pex=144,per_child_PID_array=4,per_child_status_array=4,local_wait_status=4,
            per_child_posix_file_actions=0,driver_copies_of_child_stdout_or_stderr=0,
            strings=strings,largest_partial_obstack_object=partial,largest_obstack_chunk=chunk(partial),
            jobserver=dict(MAKEFLAGS_present=False,largest_string_value=71,library_string_interface_bound=72,
                           control_upper=128,connect_or_token_calls=0),
            diagnostic=dict(option_classifier_requested_bytes=0,file_cache_slot_array=4104,
                recent_line_array_each=6152,control_object_each_upper=512,initial_obstack_chunk_each_upper=4096,
                sink_vector=40,owned_urlifier_vector=72,source_cache_contents_read=False,
                theme=('emoji' if role=='binder_compile' else 'ASCII'),selected_success_messages=0)))
    # Fresh collect2 diagnostic initialization and static roots; no reuse of a
    # frontend root. Existing collect2 selected early-exit argument/launch proof
    # receives its current 47 positions, as opposed to its historical 45.
    collect=dict(argv_positions=47,ld_argv_positions=46,first_ld_pointer_request=(47+4)*8,
        second_ld_pointer_request=(47+11)*8,input_object_pointer_request=47*8,
        unused_C_pointer_request=(47+9+8+4)*8,first_ld_write_slots_upper=48,
        second_ld_write_slots_upper=49,input_object_write_slots_upper=47,unused_C_write_slots_upper=20,
        compiler_path_nodes_upper=6,PATH_nodes=3,prefix_node=16,
        finder_request=2*P+1,splitter_scratch_upper=14+19*(P+1)+3,
        field_object_upper=rows[-1]['strings']['COLLECT_GCC_OPTIONS'],
        field_obstack_chunk_upper=chunk(rows[-1]['strings']['COLLECT_GCC_OPTIONS']),
        temporary_names=2,temporary_name_request=48+18,
        diagnostic=dict(option_classifier_requested_bytes=0,file_cache_slot_array=4104,
            recent_line_array_each=6152,control_object_each_upper=512,initial_obstack_chunk_each_upper=4096,
            sink_vector=40,owned_urlifier_vector=0,source_cache_contents_read=False,theme='ASCII',selected_success_messages=0),
        no_LTO_no_collecting_early_exit=True,linker_launches=1,per_launch_pex=144,
        per_launch_PID_array=4,per_launch_status_array=4)
    return dict(scope='exact literal Main/binder/link GCC drivers and shared collect2 shell initialization',
        source_identity=identity(raw),source_counts=graph['source_counts'],path_bytes=P,
        invocation_identity=identity(json.dumps(graph,sort_keys=True,separators=(',',':')).encode()),
        drivers=rows,collect2=collect,configured_named_specs=47,configured_compiler_records_including_sentinel=context.compiler_records,
        multilib=dict(max_partial_string=85,default_record=16,temporary_match_array=48,
                      retained_match_array=24*(14+1),os_directory_string=9,multiarch_string=17),
        static_lifecycle=context.lifecycle,source_files_checked=len(context.sources),repository_inputs_checked=context.repository_pins,
        driver_source_or_object_content_reads=0,selected_driver_GGC_events=0,
        driver_and_collect2_shell_capacity_closed_under_documented_source_projection=True,
        actual_source_and_exact_accepted_invocation_attached=True,
        aggregate_RAM_or_parent_arena_used_as_child_bound=False,native_tool_executions=0,
        production_launcher_adopted=False,SPARK_or_Lean_correspondence_established=False,
        whole_native_pipeline_capacity_established=False,remaining_driver_capacity_obligations=[],
        separate_interfaces=['Main and binder frontend bodies','GAS','binder generator','ld/BFD',
            'production adoption and verified-SPARK/Lean correspondence'],
        established_boundaries=['successful allocation and standard-library/OS interfaces',
            'stable selected files/configuration and relevant source-tool behavior',
            'external allocation/service failure is terminal failure, not success or language rejection'])


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();a.output.write_text(json.dumps(evaluate(a.source.read_bytes(),Context()),indent=2)+'\n')
