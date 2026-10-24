"""Independent offline #212 review audit; no author checker or target execution."""
from dataclasses import asdict
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import struct
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
START = time.perf_counter()
ARGUMENTS = '6a29a2b8c241924f842fc1d6afeb2e1617c2d3f8'
NATIVE = '260af764d5'
PARENT_NATIVE = '9bb63660fd9e29c7b67b359f00acd844f19771cc'
PREVIOUS_REVIEW = 'd39dc7cff5985a24b81345f23e645e2a237c2a6d'
ARG = 'docs/evidence/retained-fixed-report-composition-20261024/arguments/'
NAT = 'docs/evidence/retained-fixed-report-native-inputs-20261024/'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def git_bytes(commit, path):
    return subprocess.check_output(['git', 'show', commit+':'+path], cwd=ROOT)


def read(path):
    return (ROOT/path).read_bytes()


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT/path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


# Only the new review targets are reconstructed below. Accepted dependencies
# are byte-bound, not replayed. The review assembly intentionally lacks some
# native dependency files; those are read from their exact accepted commits.
input_hashes = {}
for commit, paths in [
    (ARGUMENTS, [ARG+x for x in ('README.md', 'capacity.py', 'check.py',
        'source-manifest.json', 'message-census.json', 'result.json', 'round.json')]
        + ['docs/research/retained-fixed-report-composition.md']),
    (NATIVE, [NAT+'gnat2why/'+x for x in
              ('README.md', 'check.py', 'inputs.json', 'result.json')])]:
    for path in paths:
        raw = read(path)
        assert raw == git_bytes(commit, path), path
        input_hashes[path] = dict(commit=commit, bytes=len(raw), sha256=sha(raw))

manifest = json.loads(read(ARG+'source-manifest.json'))
for path, digest in manifest['repository_files'].items():
    assert sha(read(path)) == digest, path
prefix = manifest['accepted_research_prefix']
assert sha(read(prefix['path'])[:prefix['bytes']]) == prefix['sha256']
tool_sources = {}
archive = manifest['archive']
assert sha(read(archive['path'])) == archive['sha256']
with tarfile.open(fileobj=io.BytesIO(read(archive['path']))) as stream:
    for member, digest in archive['members'].items():
        raw = stream.extractfile(member).read()
        assert sha(raw) == digest, member
        tool_sources[member.removeprefix('spark-source/src/')] = raw.decode()
gcc = manifest['gcc_source']
gcc_known = {r['path']:r['sha256'] for r in json.loads(read(gcc['manifest']))['files']}
for path, digest in gcc['files'].items():
    raw = (Path(gcc['default_root'])/path).read_bytes()
    assert sha(raw) == digest == gcc_known[path]
    tool_sources['gcc/'+path] = raw.decode()
gnat = manifest['gnatcoll']
assert sha(read(gnat['path'])) == gnat['sha256']
with tarfile.open(fileobj=io.BytesIO(read(gnat['path']))) as stream:
    raw = stream.extractfile(gnat['member']).read()
    assert sha(raw) == gnat['member_sha256']
    tool_sources['gnatcoll-json-utility.adb'] = raw.decode()

# An independent lexical pass checks the added literal census. This checks
# literal arithmetic only; reachability and closure remain a source review.
ada_token = re.compile(r'''--[^\n]*|"(?:[^"]|"")*"|'[^\n]' ''', re.X)
census = json.loads(read(ARG+'message-census.json'))
for row in census:
    section = '\n'.join(tool_sources[row['file']].splitlines()[row['begin']-1:row['end']])
    text = ''.join(m.group()[1:-1].replace('""', '"')
                   for m in ada_token.finditer(section) if m.group().startswith('"'))
    assert all(32 <= ord(c) <= 126 for c in text)
    for key, value in [('literal_bytes', len(text)), ('ampersands', text.count('&')),
                       ('hashes', text.count('#')), ('ats', text.count('@'))]:
        assert row[key] == value, (row['name'], key, value)
assert [max(r[k] for r in census) for k in ('literal_bytes','ampersands','hashes')] == [1189,14,1]

f = load_module('independent_arguments_target', ARG+'capacity.py')
p, c = f.p, f.c
# Independent source classification: roots, scalar captures, String temps,
# types, explicit objects, conditions, simple/extended returns, calls,
# blocks, joins, contracts, typed-call frontier. See the review for closure.
rows = {
    'Is_Message': (5,2,0,4,0,0,1,0,0,1,8,2,0),
    'Input_Is_Valid': (6,2,1,4,0,2,3,0,0,1,11,2,8),
    'First_Or_Default': (15,8,1,12,3,5,2,2,0,2,27,2,16),
    'Reject': (1,0,0,0,0,0,0,0,1,1,6,0,1),
}
graphs = {}
for name, (roots, captures, temps, types, objs, cond, simple, extended,
           calls, blocks, joins, contracts, frontier) in rows.items():
    F = 2*roots+1
    V = 10+2*F+5*(objs+captures+temps)+4*types+3*(cond+simple)+4*extended+15*calls+4*blocks+joins+contracts
    Q = 2*types
    # Sum the individual emitter families, including termination success.
    attempts = sum([1,F,Q*F,6*F,2*V*F,V,2*F,V+1,V,
                    2*V*F+2*F,F,0,0,13*frontier,V*F+1,
                    V*(1+frontier)+1,2])
    graphs[name] = dict(F=F,V=V,Q=Q,C=frontier,attempts=attempts)
    got = f.graph_rows()[name]
    assert (F,V,attempts) == (got['flow_ids'],got['eligible_vertices'],got['flow_records'])
graphs['Silver_Arguments'] = dict(F=1,V=22,Q=0,C=0,attempts=6*22+12)
flow_count = sum(r['attempts'] for r in graphs.values())+4+20*32
warning_count = 13070+13*sum(r['C'] for r in graphs.values())
traces = sum(r['V']*(1+2*r['F']) for r in graphs.values())
assert (flow_count,warning_count) == (58687,13395)
names = ('Silver_Arguments', 'Silver_Arguments.Is_Message',
    'Silver_Arguments.Input_Is_Valid', 'Silver_Arguments.First_Or_Default',
    'Silver_Arguments.Reject', 'Silver_Runtime.Argument_Count',
    'Silver_Runtime.Argument', 'Silver_Output_Libc.Set_Exit_Status')
assert tuple(f.REPORT_NAMES) == names and max(map(len,names)) == 34
canonical = json.loads(read('docs/evidence/retained-why-canonical-json-input-20261023/result.json'))
cases = [x for x in canonical['cases'] if x['case'] in ('is_message','input_is_valid','first_or_default')]
assert [sum(x[k] for x in cases) for k in ('R','G','A')] == [11,39,95]


def composed(P):
    # Rebuild the entire reached flow shape with trace length 40, rather than
    # adjusting the author's inherited shape by its stated byte difference.
    ascii_text = 1189+12+11+3*762+5*64+50
    encoded = 2+2*ascii_text+6*5*P
    message = p.Shape(pretty=encoded,compact=encoded,strings=1,string_max=ascii_text+5*P)
    row = p.object_fields([
        ('file',p.string(P)),('line',p.atom(10)),('col',p.atom(10)),
        ('message',p.object_fields([('text',message)])),('suppressed',p.literal('')),
        ('rule',p.string(64)),('severity',p.literal('warning')),('entity',p.atom(10)),
        ('check_tree',p.object_fields([])),
        ('unproved_status',p.object_fields([('status',p.literal('unknown'))])),
        ('tracefile',p.string(40)),('msg_id',p.atom(10)),('how_proved',p.literal('flow'))])
    assert row == f.flow_row(P)
    proof = p.canonical_proof(records=11,goals=39,attempts=95,answer_bytes=736,
        row_parameters=dict(path_bytes=P,text_bytes=2*(24*550+2381)+277,
        rule_bytes=64,stats_count=5,stats_key_bytes=7,aux_bytes=P+24))
    meta = p.metadata(entities=8,location_depth=1,name_bytes=34,path_bytes=P,
        spark_entities=8,skip_flow=0,skip_proof=0,pragma_assume=0,claims=40,
        claim_edges=448,edges_per_claim=40,timing_entities=9,timing_names=101,
        timing_fields=101,timing_key_bytes=59,progress_bytes=64,stop_bytes=64)
    target = f.arguments_report(path_bytes=P)
    shapes = {}
    for key in ('full','projected'):
        shape = p.report(meta,warnings=p.array(warning_count,f.io.warning_row(P)),
                         flow=p.array(flow_count,row),proof=proof[key])
        assert shape == target[key]
        shapes[key] = asdict(shape)
    writer = p.representation(target['full'],filename_bytes=P)
    reader = c.parsed_report(target['full'],path_bytes=P,max_path=4096,page_size=65536)
    guards = {**writer['guards'],**target['incoming']['guards'],
              **target['flow_brief']['guards'],'third_pool':target['third_pool']['guard']}
    failed = [k for k,v in guards.items() if not v]
    read_failed = [k for k,v in reader['guards'].items() if not v]
    assert target['incoming']['trace_attempts'] == traces
    assert target['claim_domain'] == dict(claims=40,edges=448)
    assert not target['whole_process_capacity_bound'] and not target['path_configuration_bound']
    return dict(P=P,shapes=shapes,failed_writer_and_incoming=failed,
                failed_reader=read_failed,all_pass=not failed and reader['all_guards'])


points = [composed(P) for P in (0,1,395,396)]
assert [x['all_pass'] for x in points] == [True,True,True,False]
assert points[-1]['failed_writer_and_incoming'] == ['unbounded_alignment_intermediates']
assert points[-1]['failed_reader'] == []
for key,constant in [('full',564586270),('projected',564143292)]:
    assert all(x['shapes'][key]['pretty'] == constant+2193744*x['P'] for x in points)

# Independently parse the producer ELF's symbol/segment tables. No imported
# author ELF implementation or masked reporter instruction template is used.
native_inputs = json.loads(read(NAT+'gnat2why/inputs.json'))
inherited = {}
for r in native_inputs['repository']:
    path = r['path']
    commit = PREVIOUS_REVIEW if '/review-fixed-io-configuration-' in path else PARENT_NATIVE
    raw = git_bytes(commit,path)
    assert sha(raw) == r['sha256']
    inherited[path] = dict(commit=commit,sha256=sha(raw))
prior = json.loads(git_bytes(PARENT_NATIVE,NAT+'result.json'))
assert prior['observed_page_size'] == 4096
target = native_inputs['target']
raw = Path(target['path']).read_bytes()
assert len(raw) == target['bytes'] and sha(raw) == target['sha256']
h = struct.unpack_from('<16sHHIQQQIHHHHHH',raw)
assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
ph = [struct.unpack_from('<IIQQQQQQ',raw,h[5]+i*h[9]) for i in range(h[10])]
sh = [struct.unpack_from('<IIQQQQIIQQ',raw,h[6]+i*h[11]) for i in range(h[12])]


def mapped(address,size):
    segments = [s for s in ph if s[0] == 1 and s[3] <= address and address+size <= s[3]+s[5]]
    assert len(segments) == 1
    s = segments[0]
    offset = s[2]+address-s[3]
    return raw[offset:offset+size]


def symbols(section):
    strings = sh[section[6]]
    names = raw[strings[4]:strings[4]+strings[5]]
    out = []
    for off in range(section[4],section[4]+section[5],section[9]):
        name,info,other,index,address,size = struct.unpack_from('<IBBHQQ',raw,off)
        out.append((names[name:names.index(0,name)].decode(),address,size,index))
    return out


syms = {name:(address,size,index) for s in sh if s[1] == 2
        for name,address,size,index in symbols(s) if name}


def sym(name):
    address,size,index = syms[name]
    assert size > 0 and index != 0
    return mapped(address,size)


version_name = 'spark2014vsn__spark2014_version_string'
version = sym(version_name)
assert len(version) == 66
# Decode the request arguments and then pin the straight-line stores/return.
assert version[:5] == bytes.fromhex('4883ec08be')
assert struct.unpack_from('<I',version,5)[0] == 4
assert version[9] == 0xbf and struct.unpack_from('<I',version,10)[0] == 20
assert version[14] == 0xe8
allocator = syms[version_name][0]+19+struct.unpack_from('<i',version,15)[0]
assert allocator == syms['system__secondary_stack__ss_allocate'][0]
assert version[19:] == bytes.fromhex('48ba010000000a00000048b94653462031362e31488910ba2e30000066895010488d50084889480848924883c408c3')
assert sym('spark2014vsn__spark2014_static_version_string') == b'FSF 16.1.0'+bytes(6)
assert sym('__gnat_max_path_len') == struct.pack('<i',4096)
page_name = 'gnatcoll__mmap__system__get_page_size'
page = sym(page_name)
assert len(page) == 25 and page[:5] == bytes.fromhex('4883ec08e8')
assert page[9:21] == bytes.fromhex('85c0780789c04883c408c3e8')
plt = syms[page_name][0]+9+struct.unpack_from('<i',page,5)[0]
jump = mapped(plt,6)
assert jump[:2] == bytes.fromhex('ff25')
slot = plt+6+struct.unpack_from('<i',jump,2)[0]
imports = []
for s in sh:
    if s[1] != 4 or sh[s[6]][1] != 11:
        continue
    dynamic = symbols(sh[s[6]])
    for off in range(s[4],s[4]+s[5],s[9]):
        address,info,addend = struct.unpack_from('<QQq',raw,off)
        if address == slot:
            assert info & 0xffffffff == 7 and addend == 0
            imports.append(dynamic[info >> 32][0])
assert imports == ['getpagesize']
failure_address = syms[page_name][0]+25+struct.unpack_from('<i',page,21)[0]
failure_symbols = [name for name,(address,_,_) in syms.items() if address == failure_address]
assert 'gnatcoll__mmap__system__get_page_size.part.0' in failure_symbols

# Verify the inherited source interface attachment without replaying its check.
native_provider = json.loads(git_bytes(PARENT_NATIVE,NAT+'inputs.json'))
native_sources = {}
for a in native_provider['archives']:
    data = git_bytes(PARENT_NATIVE,a['path'])
    assert sha(data) == a['sha256']
    with tarfile.open(fileobj=io.BytesIO(data)) as stream:
        for member,digest in a['members'].items():
            data = stream.extractfile(member).read()
            assert sha(data) == digest
            native_sources[member] = data.decode()
assert 'int __gnat_max_path_len = GNAT_MAX_PATH_LEN;' in native_sources['gcc/ada/adaint.c']
assert 'pragma Import (C, Max_Path, "__gnat_max_path_len")' in native_sources['runtime/s-os_lib.adb']
assert 'pragma Import (C, Internal, "getpagesize")' in native_sources['gnatcoll/core/src/gnatcoll-mmap-system__unix.adb']

objdump = Path(target['path']).parents[1]/'x86_64-pc-linux-gnu/bin/objdump'
disassembly = []
for name in (version_name,page_name):
    address,size,_ = syms[name]
    disassembly.append(subprocess.check_output([str(objdump),'-d',
        '--start-address='+str(address),'--stop-address='+str(address+size),target['path']],text=True))
(HERE/'native-disassembly.txt').write_text(
    '\n'.join(line.rstrip() for line in '\n'.join(disassembly).splitlines())+'\n')
result = dict(status='pass',author_inputs=input_hashes,inherited_native_inputs=inherited,
    source_identity=dict(repository_files=len(manifest['repository_files']),
        complete_arguments_tool_files=len(tool_sources),native_interface_files=len(native_sources)),
    graphs=graphs,flow_attempts=flow_count,warning_attempts=warning_count,
    trace_attempts=traces,points=points,
    native=dict(target=target,max_path=4096,version_bytes=10,version_text='FSF 16.1.0',
        allocation_bytes=20,alignment=4,allocator_address=allocator,page_plt=plt,
        page_got=slot,page_import=imports[0],negative_branch_symbols=failure_symbols,
        retained_service_value=4096,service_query_repeated=False,
        version_hex=version.hex(),page_hex=page.hex()),
    author_or_predecessor_checker_executions=0,target_binary_executions=0,
    libc_service_queries=0,compiler_prover_Lean_runs=0,
    whole_process_capacity_closed=False,common_path_closed=False,
    global_escape_budget=2,save_entering_callbacks=2,saves_upper=3,budget_renewed=False,
    elapsed_seconds=time.perf_counter()-START)
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps({k:result[k] for k in ('status','source_identity','flow_attempts',
    'warning_attempts','trace_attempts','elapsed_seconds')},indent=2))
