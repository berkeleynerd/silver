"""Independent library-probe/logging review audit; no provider program imports."""
from pathlib import Path, PurePosixPath
import hashlib
import json
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PATH = 'docs/evidence/retained-why-library-probe-paths-20261023/'
LOG = 'docs/evidence/retained-why-logging-capacity-20261023/'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
CHECKS = 0
ARCHIVES = {}
MEMBERS = {}


def check(condition, label):
    global CHECKS
    CHECKS += 1
    if not condition:
        raise AssertionError(label)


def identity(raw):
    return {'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT/path).read_bytes())


def member(archive,name):
    key = archive,name
    if key not in MEMBERS:
        if archive not in ARCHIVES:
            ARCHIVES[archive] = tarfile.open(ROOT/archive)
        MEMBERS[key] = ARCHIVES[archive].extractfile(name).read()
    return MEMBERS[key]


def source_audit():
    spans = 0
    names = set()
    rendered = ['# Raw pathname source witnesses\n']
    for row in read(PATH+'source-ranges.json'):
        raw = member(row['archive'],row['member'])
        check(identity(raw) == row['identity'],'path complete source member')
        lines = raw.decode().splitlines(keepends=True)
        rendered.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row['ranges']:
            a,b = span['start'],span['end']
            check(1 <= a <= b <= len(lines),'path strict source range')
            text = ''.join(lines[a-1:b])
            check(identity(text.encode()) == span['identity'],'path range identity')
            rendered.append(f'### Lines {a}–{b}\n\n```text\n{text}```\n')
            spans += 1
        names.add((row['archive'],row['member']))
    check((ROOT/(PATH+'source-witnesses.md')).read_text() == '\n'.join(rendered),'path rendered witnesses')
    for row in read(LOG+'source-witnesses.json'):
        raw = member(row['archive'],row['member'])
        check(identity(raw) == row['member_identity'],'logging complete source member')
        lines = raw.decode().splitlines(keepends=True)
        a,b = row['first'],row['last']
        check(1 <= a <= b <= len(lines),'logging strict source range')
        check(''.join(lines[a-1:b]) == row['text'],'logging source text')
        spans += 1
        names.add((row['archive'],row['member']))
    return {'strict_source_ranges':spans,'complete_source_members':len(names)}


class NativeImage:
    """Independent ELF address mapping through load segments, not author reader."""
    def __init__(self,raw):
        self.raw = raw
        h = struct.unpack_from('<16sHHIQQQIHHHHHH',raw)
        check(h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62,'ELF64 little-endian x86_64')
        self.segments = []
        for i in range(h[10]):
            ph = struct.unpack_from('<IIQQQQQQ',raw,h[5]+i*h[9])
            if ph[0] == 1:
                self.segments.append((ph[3],ph[2],ph[5]))
        sections = [struct.unpack_from('<IIQQQQIIQQ',raw,h[6]+i*h[11]) for i in range(h[12])]
        self.symbols = {}
        for section in sections:
            if section[1] != 2:
                continue
            table = sections[section[6]]
            strings = raw[table[4]:table[4]+table[5]]
            for off in range(section[4],section[4]+section[5],section[9]):
                name,info,other,index,address,size = struct.unpack_from('<IBBHQQ',raw,off)
                if name:
                    text = strings[name:strings.index(0,name)].decode()
                    self.symbols[text] = {'address':address,'bytes':size,'section_index':index,'info':info}

    def at(self,address,length):
        matches = [(offset+address-start,length) for start,offset,size in self.segments
                   if start <= address and address+length <= start+size]
        check(len(matches) == 1 and length >= 0,'unique native load-segment range')
        offset,length = matches[0]
        return self.raw[offset:offset+length]


def native_audit():
    record = read(PATH+'native-inspection.json')
    raw = Path(record['target']).read_bytes()
    check(identity(raw) == record['target_identity'],'new native witnesses pinned ELF')
    prior = read('docs/evidence/retained-why-terminal-diagnostic-bytes-20261023/result.json')
    check(record['target_identity'] == {'bytes':prior['elf_bytes'],'sha256':prior['elf_sha256']},'accepted ELF identity reused, no ASCII rescan')
    image = NativeImage(raw)
    for name,row in record['functions'].items():
        check(image.symbols[name] == {k:row[k] for k in ['address','bytes','section_index','info']},'exact native symbol '+name)
        code = image.at(row['address'],row['bytes'])
        check(code.hex() == row['hex'] and identity(code) == row['identity'],'new native function correspondence '+name)
    for name,row in record['literals'].items():
        address = image.symbols[name]['address']
        header, = struct.unpack('<Q',image.at(address-8,8))
        check(header & 255 == 252,'OCaml string block tag')
        storage = 8*(header >> 10)
        payload = image.at(address,storage)
        length = storage-1-payload[-1]
        check(0 <= length < storage and payload[length] == 0,'OCaml string padding/terminator')
        expected = {'address':address,'header':header,'storage_bytes':storage,
                    'value':payload[:length].decode('ascii'),
                    'identity':identity(image.at(address-8,storage+8))}
        check(row == expected,'generated Config literal '+name)
    check([record['literals'][f'camlWhy3__Config__{i}']['value'] for i in [3,4,5]] == ['lib','why3','share'],'Config literal meanings')
    # Preserve each exact disassembler response, including wrapped-line spaces.
    text = (ROOT/(PATH+'native-disassembly.txt')).read_bytes()
    offset = 0
    for invocation in record['invocations']:
        size = invocation['stdout_identity']['bytes']
        check(identity(text[offset:offset+size]) == invocation['stdout_identity'],'exact retained objdump response')
        check(invocation['exit_code'] == 0 and not invocation['stderr'],'successful retained extraction')
        offset += size
        if offset < len(text):
            check(text[offset:offset+1] == b'\n','raw response separator')
            offset += 1
    check(offset == len(text),'all raw disassembly bytes owned')
    rows = 0
    for line in text.decode().splitlines():
        fields = line.split('\t')
        if len(fields) < 2 or not fields[0].strip().endswith(':'):
            continue
        addr = fields[0].strip()[:-1]
        if not re.fullmatch('[0-9a-f]+',addr):
            continue
        hexbytes = fields[1].split()
        if not hexbytes or not all(re.fullmatch('[0-9a-f]{2}',x) for x in hexbytes):
            continue
        data = bytes(int(x,16) for x in hexbytes)
        check(image.at(int(addr,16),len(data)) == data,'disassembly instruction-byte row')
        rows += 1
    for site,name in [(0x5277c4,'camlWhy3__Lexer__entry'),(0x5277e4,'camlWhy3__Sexp_parser__entry')]:
        instruction = image.at(site,5)
        check(instruction[0] == 0xe8 and site+5+int.from_bytes(instruction[1:],'little',signed=True) == image.symbols[name]['address'],'selected initialized extension module')
    # The reviewer read these complete function bodies; these checks attach
    # decisive stores/allocation operands, not a machine-generated semantics.
    for site,expected in [(0x543030,'48894318'),(0x5cb208,'488b771848897308'),
                          (0x5ad0cd,'4983ef20'),(0x5ad12d,'4983ef20'),
                          (0x5ad34f,'4983ef28'),(0x9a4c5a,'4983ef48'),
                          (0x949cc4,'4983ef50'),(0x5ad210,'4983ef20')]:
        check(image.at(site,len(bytes.fromhex(expected))).hex() == expected,'decisive native field/allocation operand')
    check(record['target_executions'] == 0 and len(record['functions']) == 12 and len(record['invocations']) == 12,'narrow extraction scope')
    check(rows == 2888,'complete retained disassembly rows')
    return {'native_function_witnesses':len(record['functions']),'native_literal_blocks':len(record['literals']),'native_instruction_rows':rows,'reviewer_disassembler_invocations':0,'target_executions':0}


def all_source_members():
    if WHY not in ARCHIVES:
        ARCHIVES[WHY] = tarfile.open(ROOT/WHY)
    for info in ARCHIVES[WHY].getmembers():
        if info.isfile() and info.name.endswith(('.ml','.mli','.mly','.mll')):
            yield info.name,member(WHY,info.name).decode()


def census_audit():
    registration = []
    logging = {'logging_calls':[],'prover_field_writers':[],
               'controller_interrupt_clients':[],'logging_module_aliases':[]}
    for name,text in all_source_members():
        if name.startswith(('why3/src/','why3/plugins/')) and name.endswith(('.ml','.mll')):
            registration.extend({'member':name,'line':i,'text':line}
                for i,line in enumerate(text.splitlines(),1) if 'register_format' in line)
        if not name.endswith(('.ml','.mli','.mly','.mll')):
            continue
        for i,line in enumerate(text.splitlines(),1):
            row = {'member':name,'line':i,'text':line}
            if re.search(r'\bLogging\.(init|log)\b',line):logging['logging_calls'].append(row)
            if re.search(r'\.prover\s*<-',line):logging['prover_field_writers'].append(row)
            if re.search(r'\b(?:C|Controller_itp)\.interrupt\s',line):logging['controller_interrupt_clients'].append(row)
            if re.search(r'\bmodule\s+\w+\s*=\s*(?:Gnat_checks\.)?Logging\b',line):logging['logging_module_aliases'].append(row)
    check(registration == read(PATH+'registration-census.json'),'complete registration census')
    check(logging == read(LOG+'writer-census.json'),'complete logging/prover-writer/interrupt census')
    check([(r['member'],r['line']) for r in logging['logging_calls']] == [('why3/src/gnat/gnat_checks.ml',415),('why3/src/gnat/gnat_checks.ml',1064)],'only init and scheduling logging clients')
    check([(r['member'],r['line']) for r in logging['prover_field_writers']] == [('why3/src/session/session_itp.ml',893)],'only mutable prover writer')
    check(not logging['logging_module_aliases'],'no module alias conceals logger client')
    return {'format_registration_references':len(registration),'logging_client_references':len(logging['logging_calls'])}


def parse_config(text):
    sections = []
    current = None
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if line.startswith('[') and line.endswith(']'):
            current = [line[1:-1],{}]
            sections.append(current)
        elif '=' in line and current is not None:
            name,value = line.split('=',1)
            check(name.strip() not in current[1],'unique retained config key')
            current[1][name.strip()] = value.strip()
    return sections


def path_audit():
    provider = read(PATH+'providers.json')
    projection = read(PATH+'projection.json')
    roles = read('docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json')
    combined = read('docs/evidence/retained-combined-parallel-startup-20261020/projection.json')['domains']
    native = read(PATH+'native-inspection.json')
    common_dirs = None
    for case,row in provider.items():
        cap = roles[case]['captures'][1]
        archive = row['archive']
        check(archive == cap['archive'],'current J12 capture archive')
        raw = member(archive,row['process_member'])
        check(identity(raw) == row['process_identity'],'current process exact bytes')
        check(identity(raw)['sha256'] == cap['members_sha256'][row['process_member']],'process retained role hash')
        process = json.loads(raw)
        executable = process['executable']
        check(process['argv'] == cap['argv'] and process['argv'][0] == executable == row['executable'] == native['target'],'resolved executable and absolute fallback')
        check(cap['mapped_files'][executable] == native['target_identity'],'current loaded executable identity')
        check(set(process['environment']) == {'PATH','LC_ALL','TMPDIR','OCAMLRUNPARAM'},'no hidden environment loadpath/plugin overrides')
        mapped = {PurePosixPath(name).name:ident for name,ident in cap['mapped_files'].items() if name.endswith('.cmxs')}
        check(mapped == row['mapped_plugins'] and set(mapped) == {'ada_terms.cmxs','gnat_json.cmxs'},'exact dynamic plugin set')
        argv = combined[case]['candidate_argv']
        check(argv[argv.index('--prover')+1] == 'cvc5,z3,altergo' and '--proof-dir' not in argv,'selected configuration branch')
        collector = member(archive,'collector/probe.py')
        check(identity(collector) == row['collector_identity'],'collector exact identity')
        check(b"'executable':str((proc/'exe').resolve())" in collector,'resolved /proc executable collector')
        for name,config in row['configs'].items():
            raw_conf = member(archive,name)
            check(identity(raw_conf) == config['identity'],'complete actual config bytes')
            sections = parse_config(raw_conf.decode())
            main = [fields for title,fields in sections if title == 'main']
            check(len(main) == 1 and main[0] == config['main_fields'],'all main config fields')
            check(not set(main[0]) & {'datadir','loadpath','stdlib','plugin','load_default_plugins'},'no main configuration override')
            role_index = 0 if name == case+'/why3.conf' else 1
            check(config['identity'] == cap['ordered_opens'][role_index]['identity'],'configuration actual ordered-open attachment')
        parts = executable.split('/')
        why_prefix = '/'.join(parts[:-2])
        spark_prefix = '/'.join(parts[:-4])
        datadir = why_prefix+'/share/why3'
        directories = sorted([why_prefix+'/share/why3/theories',why_prefix+'/share/why3/modules',spark_prefix+'/share/spark/theories',datadir+'/stdlib'])
        check(datadir == row['Config_datadir'] and directories == row['loadpath_sorted'],'generated and configured loadpath bytes')
        check(sorted(map(len,directories)) == [134,145,146,147] and len(set(directories)) == 4,'four actual distinct directory sizes')
        if common_dirs is None:
            common_dirs = directories
        check(directories == common_dirs,'same exact directory provider across five inputs')
    extensions = ['adb','gnat-json','mlw','sexp','why']
    bases = ['int','real','algebra','relations']
    check(projection['extensions'] == extensions and projection['logical_bases'] == bases,'complete extensions and selected logical bases')
    check(projection['loadpath_sorted'] == common_dirs,'exported directory set')
    for base in bases:
        row = projection['per_base'][base]
        candidates = [directory+'/'+base+'.'+ext for directory in common_dirs for ext in extensions]
        check(row['candidates'] == candidates and len(set(candidates)) == 20,'all complete candidate spellings '+base)
        allocations = [len(base),len(base)]
        allocations.extend(1+len(ext) for ext in extensions)
        allocations.extend(len(base)+1+len(ext) for ext in extensions)
        for directory in common_dirs:
            for ext in extensions:
                allocations.extend([len(base)+2+len(ext),len(directory)+len(base)+2+len(ext)])
        # Author order uses source directory-list order, while the pure set
        # provider is sorted. Allocation multiset and exact aggregate coincide.
        check(sorted(allocations) == sorted(row['all_string_allocation_lengths']),'all intermediate string allocation multiset '+base)
        words = sum(2+n//8 for n in allocations)
        c_copy = sum(len(name)+1 for name in candidates)
        expected = {'candidate_count':20,'maximum_path_bytes':max(map(len,candidates)),
                    'string_blocks_upper':52,'summed_string_payload_bytes':sum(allocations),
                    'summed_string_allocation_words':words,'new_cons_cells_upper':98,
                    'closure_words_upper':47,'exception_record_words_upper':4,
                    'managed_words_per_invocation_upper':words+3*98+47+4,
                    'C_copy_bytes_per_invocation_upper':c_copy,
                    'C_copy_single_request_upper':max(map(len,candidates))+1}
        for key,value in expected.items():check(row[key] == value,'path local arithmetic '+base+' '+key)
        check(all(name.isascii() and chr(0) not in name for name in candidates),'all C-safe filename bytes')
        for n in allocations:
            check(0 <= n <= 167 and 0 <= 8*(n//8+1)-1-n <= 7 and n//8+2 <= 22,'every allocation representation guard')
    for key,value in {'P_stat':167,'loadpath_cardinality':4,'registered_extension_cardinality':5,'candidate_count_upper':20,'managed_words_per_invocation_upper':870,'C_copy_single_request_upper':168,'C_copy_bytes_per_invocation_upper':3188}.items():
        check(projection[key] == value,'complete path export '+key)
    check(projection['representation_guards_established'],'local path representation')
    check(projection['global_locate_call_count'] is None,'global producer count remains separate')
    for key in ['whole_process_capacity_established','FileTags_counter_or_table_capacity_established','diagnostic_path_theorem_changed','admission_changed']:
        check(not projection[key],'path remaining scope '+key)
    check((projection['global_e_upper'],projection['save_entering_callbacks_upper'],projection['saves_upper']) == (2,2,3),'path unchanged global budgets')
    return {'path_input_cases':len(provider),'complete_candidate_spellings':80,'P_stat':167,'managed_words_per_locate_upper':870,'C_copy_bytes_per_locate_upper':3188}



def logging_audit():
    projection = read(LOG+'name-origin-projection.json')
    bounds = read(LOG+'bounds.json')
    paths = read(PATH+'providers.json')
    prefix = read('docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json')
    canon = {row['case']:row for row in read('docs/evidence/retained-why-canonical-json-input-20261023/result.json')['cases']}
    for row in projection:
        raw = member(row['archive'],row['member'])
        check(identity(raw) == row['member_identity'],'logging complete config identity')
        config = paths[row['case']]['configs'][row['member']]
        check(config['identity'] == row['member_identity'] and row['archive'] == paths[row['case']]['archive'],'cross-owner exact config join')
        provers = []
        for title,fields in parse_config(raw.decode()):
            if title != 'prover':
                continue
            selected = {}
            for name in ['name','shortcut']:
                value = fields[name]
                check(value.startswith('"') and value.endswith('"'),'quoted configured prover field')
                selected[name] = value[1:-1]
            provers.append(selected)
        check(provers == row['configured_provers'] and len(provers) == 9,'all configured prover-name origins')
        check(max(len(p['name'].encode()) for p in provers) == row['all_name_bytes_upper'] == 8,'all-origin prover length')
        check(all(p['name'].isascii() for p in provers) and row['initial_synthetic_name'] == 'Trivial' and len('Trivial') <= 8,'prover scalar origins')
        old = prefix[row['case']]
        check(row['log_path'] == old['log_path'] and row['log_path_bytes'] == old['log_path_bytes'] == len(row['log_path'].encode()),'fresh logger path relation')
    keys = ['timestamp','goal_id','prover','pas','kind','answer','time']
    kinds = ['undone','scheduled','running','done','interrupted','detached','internalfailure','uninstalled','upgradeprover','removed']
    answers = ['valid','invalid','timeout','outofmemory','steplimitexceeded','unknown','failure','highfailure']
    total = sum(map(len,keys))+20+8+max(map(len,kinds))+max(map(len,answers))
    b = 4+5+21+8+6*total+2*317
    e = 4+5+21+8+2*total+2
    check((total,b,e) == (99,1266,238),'independent maximal JSON schema')
    check(bounds['maximum_log_tree'] == {'containers':2,'fields':7,'commas':5,'string_values':4,'float_values':2,'all_key_and_string_bytes':total,'exact_schema_B':b,'exact_schema_E':e},'exact schema export')
    check(bounds['per_entry'] == {'B':1280,'E':256,'direct_newline':1,'default_margin':78,'max_indent':68,'guard_lhs':1615,'formatter_flushes':0,'Buffer_objects':0,'fixed_object_payload_words_upper':128},'per-entry geometry and representation exports')
    check(b <= 1280 and e <= 256 and 1280+256+79 == 1615 < 1000000010,'small fresh-core guard')
    exports = {}
    for row in bounds['cases']:
        case = row['case']
        q = canon[case]['E']
        h = q+2*q+q+q*q
        x = 1281*h
        expected = {'Q':q,'scheduled_callbacks_upper':q,'build_idle_failure_callbacks_upper':2*q,
                    'terminal_update_callbacks_upper':q,'queue_interruption_callbacks_upper':q*q,
                    'log_invocations_upper_H':h,'formatter_text_bytes_upper':1280*h,
                    'formatter_events_upper':256*h,'direct_newline_bytes_upper':h,
                    'channel_offered_bytes_upper_X':x,'initial_debt_P0':0,
                    'initial_cached_offset_O0':0,'cached_offset_upper':x,
                    'signed_offset_margin':2**63-1-x,'native_buffer_bytes':65536,
                    'native_channel_record_bytes':65616,'postcut_log_channel_creations':0,
                    'postcut_log_channel_wrapper_increments_upper':6,'log_channel_refcount_upper':7,
                    'per_entry_buffer_objects':0,'log_path_bytes':prefix[case]['log_path_bytes']}
        for key,value in expected.items():check(row[key] == value,case+' logging '+key)
        check(h < 2**62 and x < 2**63 and 7 < 2**31,'integer/offset/refcount margins')
        check(row['numeric_guards_pass'] and not row['complete_JSON_lines_or_delivery_established'] and row['syscall_attempt_count_upper'] is None,'logging conditional output boundary')
        check('positive-write' in row['channel_capacity_condition'] and 'lifetime' in row['channel_capacity_condition'],'log-specific service/lifetime requirement retained')
        exports[case] = {'Q':q,'H':h,'X':x}
    for row in bounds['string_layouts']:
        n = row['string_bytes']; w = n//8+1
        check(row['payload_words'] == w and row['header_and_payload_bytes'] == 8*(w+1),'logger small string rounding')
        check(0 <= 8*w-1-n <= 7 and w < 2**54,'logger string representation')
    check((bounds['shared_e'],bounds['save_entering_callbacks'],bounds['saves']) == (2,2,3),'logger shared budgets')
    check(not bounds['aggregate_RAM_or_stack_quota'] and not bounds['production_or_whole_goal_complete'],'logger scope boundary')
    return {'logging_cases':len(exports),'logging_exports':exports,'maximum_channel_offer':max(row['X'] for row in exports.values())}



def main():
    start = time.monotonic()
    targets = read(str(HERE.relative_to(ROOT)/'targets.json'))
    files,providers = {},{}
    for component in targets['components'].values():
        for path,expected in component['files'].items():
            check(identity((ROOT/path).read_bytes()) == expected,'frozen author file '+path)
            files[path] = expected
        for path,expected in component['providers'].items():
            check(path not in providers or providers[path] == expected,'provider agreement '+path)
            providers[path] = expected
    for path,expected in targets['accepted_evidence'].items():
        check(path not in providers or providers[path] == expected,'accepted evidence agreement')
        providers[path] = expected
    for path,expected in providers.items():
        check(identity((ROOT/path).read_bytes()) == expected,'provider identity '+path)
    result = {'status':'pass','author_freezes':{k:v['commit'] for k,v in targets['components'].items()},
              'exact_inputs':files,'providers':providers,'audit_code_identity':identity(Path(__file__).read_bytes())}
    result.update(source_audit())
    result.update(native_audit())
    result.update(census_audit())
    result.update(path_audit())
    result.update(logging_audit())
    result.update({'checks':CHECKS,'author_files':len(files),'provider_files':len(providers),
                   'elapsed_seconds':time.monotonic()-start,'author_or_predecessor_checker_runs':0,
                   'native_target_runs':0,'compiler_runs':0,'solver_runs':0,'proof_runs':0,
                   'capture_runs':0,'source_fetches':0,'reviewer_disassembler_runs':0})
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ['exact_inputs','providers']},sort_keys=True))


if __name__ == '__main__':
    try:
        main()
    finally:
        for archive in ARCHIVES.values():
            archive.close()
