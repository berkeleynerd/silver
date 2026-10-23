"""Independent frozen source/routing/arithmetic audit; no author code import."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = 'docs/evidence/retained-backend-output-route-20261023/'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
CHECKS = 0
ARCHIVES = {}


def check(ok, label):
    global CHECKS
    CHECKS += 1
    if not ok:
        raise AssertionError(label)


def identity(raw):
    return {'bytes':len(raw), 'sha256':hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT/path).read_bytes())


def member(archive, name):
    if archive not in ARCHIVES:
        ARCHIVES[archive] = tarfile.open(ROOT/archive)
    item = ARCHIVES[archive].getmember(name)
    check(item.isfile(), 'complete named source member '+name)
    return ARCHIVES[archive].extractfile(item).read()


def source_audit():
    ranges = read(PACKET+'source-ranges.json')
    spans, complete, expected_rendered = 0, {}, []
    for row in ranges:
        key = row['archive']+' :: '+row['member']
        check(key not in complete, 'unique complete source key')
        raw = member(row['archive'],row['member'])
        check(identity(raw) == row['identity'], 'complete source identity '+key)
        complete[key] = identity(raw)
        lines = raw.decode().splitlines(keepends=True)
        for span in row['ranges']:
            first,last = span['start'],span['end']
            check(1 <= first <= last <= len(lines), 'strict source span '+key)
            excerpt = ''.join(lines[first-1:last]).encode()
            check(identity(excerpt) == span['identity'], 'strict source span bytes '+key)
            expected_rendered.append((row['archive'],row['member'],first,last,excerpt.decode()))
            spans += 1
    rendered = (ROOT/PACKET/'source-witnesses.md').read_text()
    actual_rendered = []
    for archive,name,body in re.findall(r'^## (.+?) :: (.+?)\n(.*?)(?=^## |\Z)',rendered,re.S|re.M):
        for first,last,excerpt in re.findall(r'### Lines (\d+)–(\d+)\n\n```text\n(.*?)```\n',body,re.S):
            actual_rendered.append((archive,name,int(first),int(last),excerpt))
    check(actual_rendered == expected_rendered, 'all rendered strict excerpts exactly match complete source members')
    live = {}
    for row in read(PACKET+'runtime-inputs.json')['source_members']:
        raw = member(PACKET+'gnat-runtime-sources.tar.gz',row['member'])
        installed = Path(row['installed_path']).read_bytes()
        check(raw == installed and identity(raw) == row['identity'], 'complete installed runtime source attachment '+row['member'])
        live[row['installed_path']] = identity(installed)
    return {'strict_source_ranges':spans,'complete_source_inputs':complete,'installed_runtime_sources':live}


def writer_audit():
    selected = ['arraylist.c','logging.c','options.c','proc.c','queue.c','readbuf.c','request.c','server-unix.c','writebuf.c']
    all_server = {m.name for m in ARCHIVES[WHY].getmembers() if m.isfile() and m.name.startswith('why3/src/server/') and m.name.endswith('.c')}
    expected = {'why3/src/server/'+x for x in selected}
    excluded = {'why3/src/server/cpulimit-unix.c','why3/src/server/cpulimit-win.c','why3/src/server/server-win.c'}
    check(all_server == expected|excluded, 'complete Unix server translation-unit selection')
    texts = {n:member(WHY,n).decode() for n in sorted(expected)}
    candidates = []
    matcher = re.compile(r'\b(?:printf|fprintf|vfprintf|perror|puts|fputs|putchar|fputc|write|writev|pwrite|fwrite|fflush|fclose|exit|_exit|atexit|on_exit|print_request)\s*\(')
    for name,text in texts.items():
        check(not re.search(r'\b(?:atexit|on_exit)\s*\(',text), 'no registered application exit hook '+name)
        check('__attribute__((constructor' not in text and '__attribute__((destructor' not in text, 'no constructor/destructor source attribute '+name)
        for lineno,line in enumerate(text.splitlines(),1):
            if matcher.search(line):
                candidates.append({'member':name,'line':lineno,'text':line.strip()})
    server = texts['why3/src/server/server-unix.c']
    child = server[server.index('pid_t create_process('):server.index('void write_to_client(')]
    locations = [child.index(x) for x in ('pid_t pid = fork ();','if (setpgid(0, 0) == -1)',
                  'if (usestdin) {','dup2(outfile, 1);','dup2(outfile, 2);','execvp(cmd,unix_argv);',
                  'fprintf(stderr, "%s: exec of')]
    # The first usestdin adjusts argc before fork; select the later open branch.
    locations[2] = child.index('int infile = open(argv[count], O_RDONLY);')
    check(locations == sorted(locations), 'actual fork, child failure and output-routing order')
    check('close(outfile)' not in child, 'original raw-file alias persists in actual stock child')
    check('unix_argv[0] = cmd;' in child and 'unix_argv[i + 1] = argv[i];' in child, 'argv0 and operand preservation')
    check(child.count('exit(1);') == 3, 'three mutually exclusive terminal child diagnostic branches')
    check('write(client->fd, buf, need_write)' in server and 'write(cpipe[1], "x", 1)' in server, 'socket and self-pipe destinations')
    check(sum(len(re.findall(r'\bprint_request\s*\(',s)) for s in texts.values()) == 1, 'print_request definition has no selected C call')
    logging = texts['why3/src/server/logging.c']
    check(logging.count('if (logging) {') == 3 and 'logging = false;' in texts['why3/src/server/options.c'], 'all logging families disabled by selected false flag')
    direct = '%s: exec of \'%s\' failed (%s)\n'
    group = '%s: creation of process group failed (%s)\n'
    check(len(direct.replace('%s','')) == 23 and len(group.replace('%s','')) == 38, 'direct format literal charges')
    inherited = read('docs/evidence/retained-adapter-launch-output-20261020/result.json')
    check(max(row['bytes'] for row in inherited['errno_strings']) == 49, 'reuse accepted strerror payload ceiling')
    return {'selected_server_units':len(expected),'source_writer_candidates':candidates,'direct_exec_fixed_bytes':23+49,'process_group_fixed_bytes':38+49}


def terminal_audit():
    runtime = PACKET+'gnat-runtime-sources.tar.gz'
    sources = {row['member']:member(runtime,row['member']).decode() for row in read(PACKET+'runtime-inputs.json')['source_members']}
    handler = sources['adainclude/a-elchha.adb']
    data = sources['adainclude/a-exexda.adb']
    spec = sources['adainclude/a-except.ads']
    params = sources['adainclude/s-parame.ads']
    check(re.search(r'Default_Exception_Msg_Max_Length\s*:\s*constant\s*:=\s*200',params) is not None, 'selected message maximum200')
    check(re.search(r'Max_Tracebacks\s*:\s*constant\s*:=\s*50',spec) is not None, 'selected traceback maximum50')
    check('Natural range 0 .. Max_Tracebacks' in spec and 'Msg : String (1 .. Exception_Msg_Max_Length)' in spec, 'occurrence representation bounds')
    check('Natural\'Min (Message\'Length, Exception_Msg_Max_Length)' in data, 'Ada exception message truncation')
    check(data.count('Excep.Msg_Length < Exception_Msg_Max_Length') >= 2, 'C-message append bounded by same maximum')
    check(handler.index('System.Standard_Library.Adafinal;') < handler.index('if Exception_Trace /= RM_Convention then'), 'finalization precedes all handler output branches')
    std = sources['adainclude/s-stalib.adb']
    check(std.index('Runtime_Finalized := True;') < std.index('System.Soft_Links.Adafinal.all;'), 'once-only finalizer flag before soft-link call')
    soft = sources['adainclude/s-soflin.adb']
    check('Task_Termination_Handler.all (Ada.Exceptions.Null_Occurrence);' in soft and 'Finalize_Library_Objects.all;' in soft, 'named finalizer hooks exposed')
    output = sources['adainclude/a-except.adb']
    check('Put_Char_Stderr (Character\'Pos (C));' in output and 'if S (J) /= ASCII.CR then' in output, 'at most one character-output request per input byte')
    check('Nobuf : String (1 .. 0);' in handler and data.count("if Info'Length = 0 then") >= 2, 'streaming append route selected')
    headers = {}
    for name in ('BEI_Name_Header','BEI_Msg_Header','BEI_PID_Header','BETB_Header','LDAD_Header'):
        match = re.search(name+r'\s*:\s*constant String\s*:=\s*"([^"]*)"',data)
        check(match is not None, 'literal header source '+name)
        headers[name] = match[1]
    check(len('Execution terminated by abort of environment task')+2 == 51, 'abort branch51')
    for literal in ('Execution terminated by abort of environment task','Execution of ',
                    ' terminated by unhandled exception','Execution terminated by unhandled exception','raised ',' : '):
        check('"'+literal+'"' in handler, 'exact LCH literal source '+literal)
    check('Space_Per_Address : constant := 2 + 16 + 1;' in data and 'S : String (1 .. 18);' in data, 'address rendering source extents')
    plain = 1+len('raised ')+len(' : ')+200+1
    heading = 1+len('Execution of ')+len(' terminated by unhandled exception')+1
    basic = len(headers['BEI_Name_Header'])+len(headers['BEI_Msg_Header'])+200+1+len(headers['BEI_PID_Header'])+15
    trace = len(headers['LDAD_Header'])+19+len(headers['BETB_Header'])+1+50*19+1
    check((plain,heading,basic,trace) == (212,49,231,1016), 'independent literal/helper bounds')
    check(heading+basic+trace == 1296, 'terminal constant1296')
    check(len('Execution terminated by unhandled exception')+2 <= heading, 'null-argv fallback dominated for nonnegativeA')
    names = re.findall(r'\w+_Name\s*:\s*constant String\s*:=\s*"([^"]+)"\s*& ASCII.NUL',sources['adainclude/s-stalib.ads'])
    check(len(names) == 6 and max(map(len,names)) == 16, 'standard-only name16 specialization is conditional')
    # Finite extremal construction checks the loops' actual byte accounting.
    # General bound follows: <=18 hex bytes per address, <=19 per slot,
    # <=200 message bytes and <=E name bytes, for every represented value.
    constructed = 0
    for traces in range(51):
        for msg_size in (0,1,199,200):
            for include_load in (False,True):
                for include_pid in (False,True):
                    actual_basic = 7+16+(3+msg_size if msg_size else 0)+1
                    if include_pid:
                        actual_basic += 5+len(str((1<<31)-1))+1
                    actual_trace = 0
                    if traces:
                        actual_trace = (14+18+1 if include_load else 0)+31+1+18*traces+(traces-1)+1
                    check(actual_basic <= 16+basic and actual_trace <= trace, 'extremal source output envelope')
                    check(heading+actual_basic+actual_trace <= 16+1296, 'combined terminal branch envelope')
                    constructed += 1
    # Sufficient configuration guard q<=I. These differences are nonnegative
    # coefficient polynomials in A,E, establishing implication universally.
    for lhs in ((1,0,1),(0,1,1),(0,1,231),(0,1,1247)):
        dominant = (1,1,1296)
        check(all(d>=x for d,x in zip(dominant,lhs)), 'q guard dominates helper/name/argv arithmetic')
    limit = (1<<31)-1
    check(2*((limit-72)//2)+72 <= limit and limit < (1<<63)-1, 'direct printf guard and off_t implication')
    authored = read(PACKET+'terminal-output.json')
    for key,value in {'abort_bytes':51,'no_traceback_constant':plain,'heading_with_argv_constant':heading,
                      'heading_without_argv_bytes':len('Execution terminated by unhandled exception')+2,
                      'basic_information_constant':basic,'untailored_traceback_bytes_upper':trace,
                      'message_bytes_upper':200,'tracebacks_upper':50,'standard_only_E':16}.items():
        check(authored[key] == value, 'independent terminal output agrees with author '+key)
    check(authored['terminal_formula'] == 'A+E+1296' and not authored['standard_only_origin_closure_established'], 'symbolic terminal scope retained')
    projection = read(PACKET+'projection.json')
    check(projection['q_backend_formula'] == 'max(2*A+72,A+E+1296)', 'correct frozen branch maximum')
    check(projection['sufficient_guard'] == 'A>=1 and E>=1 and q_backend(A,E)<=2147483647', 'explicit conservative arithmetic guard')
    check(projection['actual_A'] is None and projection['actual_E'] is None and projection['actual_numeric_q_backend'] is None, 'no invented actual configuration operands')
    check(not projection['production_refinement_established'] and not projection['whole_process_capacity_established'] and not projection['old_stock_solver_file_q_closed'], 'design acceptance is not production/whole-rule closure')
    check(not projection['new_trusted_capacity_premise'] and not projection['optional_raw_logging_selected'] and not projection['budget_renewed'], 'capacity and budget boundaries unchanged')
    check((projection['global_e_upper'],projection['save_entering_callbacks_upper'],projection['saves_upper']) == (2,2,3), 'single inherited global allowance')
    current = read('docs/evidence/retained-current-protocol-join-20261023/result.json')
    old = read('docs/evidence/retained-adapter-protocol-storage-20261020/result.json')
    check(sum(row['parallel_wire_entries_upper'] for row in current['cases']) == current['current_wire_entries_upper'] == projection['current_launch_entries_upper'] == 354, 'unchanged current launch count transport')
    check(current['retained_protocol_entries_upper'] == old['total_attempts_upper'] == projection['retained_protocol_entries_upper'] == 459, 'unchanged conservative protocol count transport')
    for case in read(PACKET+'guard-and-alias-check.json')['configurations']:
        q = max(2*case['A']+72,case['A']+case['E']+1296)
        check(q == case['q'] and (case['A']>=1 and case['E']>=1 and q<=limit) == case['sufficient_guard_pass'], 'authored configuration boundary arithmetic')
    return {'terminal_components':{'no_trace_constant':plain,'heading_constant':heading,'basic_constant':basic,'traceback_constant':trace,'combined_constant':heading+basic+trace},'extremal_terminal_cases':constructed,'configuration_int_limit':limit}


def main():
    started = time.monotonic()
    inputs = json.loads((HERE/'inputs.json').read_bytes())
    exact,providers = {},{}
    for path,expected in inputs['exact_inputs'].items():
        raw = (ROOT/path).read_bytes()
        frozen = subprocess.check_output(['git','show',inputs['author_freezes']['backend_output_route']+':'+path],cwd=ROOT)
        check(raw == frozen and identity(raw) == expected, 'exact frozen author file '+path)
        exact[path] = expected
    for path,expected in inputs['providers'].items():
        check(identity((ROOT/path).read_bytes()) == expected,'accepted provider identity '+path)
        providers[path] = expected
    result = {'status':'pass','author_freezes':inputs['author_freezes'],'exact_inputs':exact,'providers':providers,'audit_code_identity':identity(Path(__file__).read_bytes())}
    result.update(source_audit())
    result.update(writer_audit())
    result.update(terminal_audit())
    result.update({'checks':CHECKS,'elapsed_seconds':time.monotonic()-started,'author_or_predecessor_checker_runs':0,'target_runs':0,'disassembler_runs':0,'compiler_runs':0,'solver_runs':0,'proof_runs':0,'capture_runs':0,'source_fetches':0,'implementation_refinement_claimed':False,'finite_checks_are_universal_proof':False})
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('exact_inputs','providers','complete_source_inputs','installed_runtime_sources','source_writer_candidates')},indent=2,sort_keys=True))


if __name__ == '__main__':
    main()
