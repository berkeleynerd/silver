"""One independent offline changed-obligation audit; no native/checker replay.

Controls exercise a source model and arithmetic, not a running JSON lexer or
formatter. The human source/closure review remains essential to the conclusion.
"""
from collections import Counter, deque
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import random
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = '17b1b2b35e81b6244077de982331111b5f387e87'
PACKET = ROOT / 'docs/evidence/retained-main-construction-demand-20261024/prefix-consumers'
RESEARCH = 'docs/research/retained-main-construction-demand.md'
START = time.monotonic()
groups = Counter()


def check(ok, group):
    if not ok:
        raise AssertionError(group)
    groups[group] += 1


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


inputs = read(PACKET / 'inputs.json')
changed = git('diff', '--name-only', inputs['base_commit'], AUTHOR).decode().splitlines()
check(all(p.startswith(str(PACKET.relative_to(ROOT)) + '/') or p == RESEARCH for p in changed),
      'author changes confined to new packet and research')
exact_inputs = []
for path in sorted(PACKET.iterdir()) + [ROOT / RESEARCH]:
    if path.is_file():
        rel = str(path.relative_to(ROOT))
        data = path.read_bytes()
        check(data == git('show', AUTHOR + ':' + rel), 'exact committed author input')
        exact_inputs.append({'path': rel, **identity(data)})
for row in inputs['providers'] + inputs['immutable_prior_packets']:
    check(identity((ROOT / row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')},
          'accepted provider or earlier packet identity')
check(len(inputs['immutable_prior_packets']) == 96, 'all 96 earlier packet files retained')
pin = inputs['research_prefix']
prior = git('show', inputs['base_commit'] + ':' + RESEARCH)
check((ROOT / RESEARCH).read_bytes().startswith(prior) and
      identity(prior) == {k: pin[k] for k in ('bytes', 'sha256')}, 'research append preserves exact prior argument')

sources = {}
archives = {}
try:
    for row in read(PACKET / 'source-witnesses.json'):
        if row['archive']:
            if row['archive'] not in archives:
                archives[row['archive']] = tarfile.open(ROOT / row['archive'])
            data = archives[row['archive']].extractfile(row['path']).read()
        else:
            data = (ROOT / row['path']).read_bytes()
        sources[row['path']] = data.decode()
        check(identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, 'complete selected source identity')
        lines = data.splitlines(keepends=True)
        for span in row['spans']:
            chunk = b''.join(lines[span['first'] - 1:span['last']])
            check(chunk.decode() == span['text'] and identity(chunk)['sha256'] == span['sha256'],
                  'exact selected source excerpt')
finally:
    for archive in archives.values():
        archive.close()


def source(suffix):
    values = [v for k, v in sources.items() if k.endswith(suffix)]
    assert len(values) == 1, suffix
    return values[0]


ret = read(PACKET / 'retrieval.json')
check(identity((PACKET / 'yojson-3.0.0.tar.gz').read_bytes()) == {k: ret[k] for k in ('bytes', 'sha256')} and
      ret['url'].endswith('/ocaml-community/yojson/tar.gz/refs/tags/3.0.0'), 'retained official source retrieval identity')
version = read(PACKET / 'binary-version-path.json')
binary = Path(version['accepted_binary']['path']).read_bytes()
check(identity(binary) == version['accepted_binary']['identity'], 'same accepted binary bytes without execution')
offsets=[]
position=0
while True:
    position=binary.find(version['needle'].encode(),position)
    if position<0:
        break
    offsets.append(position)
    position+=1
check(offsets == version['offsets'],
      'complete retained Yojson build-path window')
check('correspondence remains' in version['interpretation'] and 'family only' in version['interpretation'],
      'build path is corroboration rather than standalone provenance')

reader = source('/lib/read.mll')
converter = source('/gnat_ast_to_ptree.ml')
lex = source('/stdlib/lexing.ml')
native_lex = source('/runtime/lexing.c')
fmt = source('/stdlib/format.ml')
check('let json = Yojson.Safe.from_channel c in' in converter and
      'let from_channel ?buf ?fname ?lnum ic =' in reader and
      'let lexbuf = Lexing.from_channel ic in' in reader and 'let v = init_lexer ?buf ?fname ?lnum () in' in reader and
      'if not stream then\n      finish v lexbuf' in reader,
      'selected fresh default parser and final EOF route')
check(all('#define ' + flag + '\n' in source('/lib/safe.cppo.ml') for flag in ('INT','INTLIT','FLOAT','STRING')) and
      '#define FLOATLIT' not in source('/lib/safe.cppo.ml') and
      '(ocamllex read lexer_utils)' in source('/lib/dune'), 'Safe selection and generated-table interface')
check('Buffer.create 256' in source('/lib/common.ml') and '?(lnum = 1)' in source('/lib/common.ml') and
      'Bytes.create 512' in lex and 'Bytes.create 1024' in lex and
      'Int.min (2 * Bytes.length lexbuf.lex_buffer)' in lex,
      'fresh lexbuf string accumulator and geometric growth source')
check(native_lex.count('Long_val(lexbuf->lex_curr_pos)') == 2 and
      native_lex.count('lexbuf->lex_curr_pos += 2') == 2 and
      'int state, base, backtrk, c' in native_lex, 'native input indices separate from fixed-table state indices')
check('`Assoc (List.rev !acc)' in reader and '`List (List.rev !acc)' in reader and
      'let buf_size = 32' in reader and 'lexbuf.lex_start_pos <- lex_start_pos + 1' in source('/lib/lexer_utils.mll'),
      'fixed parser containers and stopping error-position repair')
check('let rec normalize v p e =' in source('/number.ml') and
      'normalize d (BigInt.mul p p) e2' in source('/number.ml') and
      'then { rv_sig = i; rv_pow2 = i; rv_pow5 = i }' in source('/number.ml') and
      'then (pred q, add r y)' in source('/bigInt.ml') and 'else (succ q, sub r y)' in source('/bigInt.ml'),
      'normalization squaring zero bypass and second signed correction')
check('if sign b >= 0 then (pred q, add r b)' in source('/z.ml') and
      'let quomod_big_int = Z.ediv_rem' in source('/big_int_Z.ml'), 'first Euclidean correction source attachment')
check('ml_z_alloc(1 + j / (2 * sizeof(mp_limb_t)))' in source('/caml_z.c') and
      'malloc(num_digits+1)' in source('/caml_z.c') and
      'ml_z_alloc(size_arg1 + size_arg2)' in source('/caml_z.c') and
      'ml_z_alloc(size_arg1 - size_arg2 + 1)' in source('/caml_z.c') and
      '#define Z_CUSTOM_BLOCK 1' in source('/caml_z.c') and '#define Z_PERFORM_CHECK 0' in source('/caml_z.c'),
      'native provisional parse multiply divide and custom request shapes')
check('wosize = 1 + (bsz + sizeof(value) - 1) / sizeof(value)' in source('/runtime/custom.c'),
      'custom operations pointer included before block header')
check('let pp_sep _ () = ()' in converter and 'fprintf fmt "[%d]" d' in converter and
      'fprintf fmt ".%a" (pp_print_list ~pp_sep pp)' in converter and
      converter.index('let print_mlw_file ?mark () =') < converter.index('match Typing.type_mlw_file'),
      'path printer has no breaks and later printer remains deferred')
check(fmt.count('let b = pp_make_buffer () in') >= 2 and
      'let ppf = formatter_of_buffer b in' in fmt and 'let pp_buffer_size = 512' in fmt and
      'Buffer.create 64' in source('/stdlib/printf.ml') and
      'state.pp_right_total <- pp_infinity' in fmt and 'Size.is_known size || pending_count >= state.pp_space_left' in fmt,
      'private string formatter creation and known-token flush rule')

# New tuple projection from accepted decoded snapshots; no raw-byte predecessor replay.
origin = read(PACKET / 'numeric-origins.json')
union = set()
with tarfile.open(ROOT / origin['archive']) as archive:
    members = sorted(n for n in archive.getnames() if '/numeric-' in n and n.endswith('.json'))
    check(members == sorted(row['path'] for row in origin['snapshots']) and len(members) == 18,
          'projection includes every accepted numeric snapshot')
    for row in origin['snapshots']:
        data = archive.extractfile(row['path']).read()
        check(identity(data) == {k: row[k] for k in ('bytes','sha256')}, 'accepted numeric snapshot identity')
        snap = json.loads(data)
        codes = {f['code'] for f in snap['numeric_fields'] if f['type'] == 'urealp__ureal'}
        projected = {}
        for code in codes:
            u = snap['ureals'][str(code)]
            projected[code] = (int(snap['uints'][str(u['num'])]['value']),
                               int(snap['uints'][str(u['den'])]['value']), u['rbase'], u['negative'])
        check(codes == set(map(int, snap['ureals'])) and
              projected == {v['ureal_code']: tuple(v['tuple']) for v in row['values']}, 'complete referenced Ureal tuple projection')
        union.update(projected.values())
check(sorted(union) == list(map(tuple, origin['distinct_tuples'])) and len(union) == 10 and
      all(0 < n < 2**64 and abs(d) <= 4080 and base in (2,16) and sign in (0,1) for n,d,base,sign in union),
      'all ten fixed origins supply selected compact exponents')
numeric_source = (ROOT / 'docs/research/retained-producer-numerics.md').read_text()
check('No Main route emits a Ureal.' in numeric_source and 'Numeric Why nodes are immutable' in numeric_source and
      'Import growth adds module references and does not synthesize numeric' in numeric_source,
      'source induction and immutable complete fixed reduction attach projection')

spec = importlib.util.spec_from_file_location('reviewed_consumer_math', PACKET / 'consumers.py')
api = importlib.util.module_from_spec(spec)
spec.loader.exec_module(api)

# Independent repeated division, checked against the author's squaring recurrence.
values = {(-n if sign else n) for n,d,base,sign in union}
values.update((1,-1,2**63,-2**63,2**64-1,1-2**64,5**27,-5**27,2**62*3,-2**62*3))
numeric_controls = []
for value in sorted(values):
    for prime in (2,5):
        answer, valuation = value, 0
        while answer % prime == 0:
            answer //= prime
            valuation += 1
        result = api.normalize_trace(value, prime)
        check((answer,valuation) == (result['value'],result['valuation']), 'normalizer equals independent prime valuation')
        for event in result['trace']:
            if 'p_squared' in event:
                check(event['p_squared'] < 2**128 and event['e2'] <= 64, 'trial square and doubled valuation intermediate')
            else:
                v,p = event['v'],event['p']
                # Python floor division by positive p yields the Euclidean pair.
                eq, er = divmod(v,p)
                tq = abs(v)//p * (-1 if v<0 else 1)
                tr = v-tq*p
                back = (eq+1, er-p) if v<0 and er else (eq,er)
                check(back == (tq,tr) and (tq,tr) == (event['d'],event['m']), 'both signed correction layers return truncating division')
                check(max(abs(v),p,abs(eq),er,abs(tq),abs(tr)) < 2**129 and abs(v)<=abs(value),
                      'failed trial and signed correction operands fit three limbs')
        numeric_controls.append({'value':value,'prime':prime,'normalized':answer,'valuation':valuation,
                                 'max_trial_divisor':max(e.get('p',0) for e in result['trace'])})
check(10**40 < 2**133 and 1+40//16 == 3 and 10**18-1 < 2**62, 'decimal parsing bit limb and small-native bounds')
check(16320+63 < 16384 and 8*(1+1+6+1) == 72, 'normalized exponent and six-limb total native request')

# Exact lex_refill scalar equations with no byte buffers allocated.
lex_controls = 0
for power in range(10,32):
    cap = 2**power
    for occupied in (cap//2, cap-1, cap):
        for start in (0,occupied//2,occupied):
            for amount in (0,1,511,512):
                abspos=37
                total=abspos+occupied+amount
                newcap,newabs,newlen,newstart=cap,abspos,occupied,start
                if occupied+amount > cap:
                    if occupied-start+amount > cap:
                        newcap=2*cap
                    newabs+=start
                    newlen-=start
                    newstart=0
                newlen+=amount
                check(newcap<=max(1024,2*total) and 0<=newstart<=newlen<=newcap and
                      newabs+newlen==total and newcap*2<=4*total+2048,
                      'refill compaction growth and absolute-position controls')
                lex_controls+=1

# Text-only formatter model includes the system-box state and reinitialization.
# Cases straddle margin, sentinel, word boundaries and the maximum L, using lengths.
def format_lengths(lengths):
    queue=deque([('system',-1,0)])
    left=right=1
    space=78
    emitted=0
    box_width=None
    maximum_queue=1
    def drain():
        nonlocal left,space,emitted,box_width
        while queue:
            kind,size,length=queue[0]
            if size<0 and right-left<space:
                break
            queue.popleft()
            if kind=='system':
                # It is first: no text has advanced the insertion point.
                assert 78-space==0
                box_width=space
            else:
                space-=size
                emitted+=length
            left+=length
    for length in lengths:
        right+=length
        queue.append(('text',length,length))
        maximum_queue=max(maximum_queue,len(queue))
        drain()
    before=(left,right,space,len(queue))
    right=1000000010
    drain()
    drained=(left,right,space,len(queue),emitted,box_width)
    # pp_rinit clears counters and recreates one system box.
    left=right=1
    space=78
    queue=deque([('system',-1,0)])
    return before,drained,maximum_queue,(left,right,space,len(queue))

format_controls=[]
rng=random.Random(20261024)
for total in (0,1,7,8,77,78,79,1000000009,1000000010,1000000011,2**37):
    layouts=[[total],[0,0,total,0],[min(77,total),total-min(77,total)]]
    cuts=sorted([0,total]+[rng.randrange(total+1) for _ in range(8)])
    layouts.append([b-a for a,b in zip(cuts,cuts[1:])])
    for lengths in layouts:
        before,drained,maxqueue,reset=format_lengths(lengths)
        check(drained[0]==total+1 and drained[2]==78-total and drained[3]==0 and drained[4]==total and
              drained[5]==78 and reset==(1,1,78,1), 'formatter flush drains and resets across pp_infinity')
        check((total<78 or before[3]==0) and maxqueue<=len(lengths)+1 and
              max(map(abs,before[:3]+drained[:3]))<=2*max(256,total)+2*1000000010+256,
              'system-box force and private formatter arithmetic')
        format_controls.append({'lengths':lengths,'before_flush':before,'after_drain':drained,'maximum_queue':maxqueue})

frozen=read(PACKET/'exports.json')['producer_maximum']
B=2**31-2
I=2**62-1
for role in api.AUXILIARY:
    out=api.producer_envelope(role)
    check(out==frozen[role], 'five role frozen exports match pure callable')
    N=B+1
    L=max(64*B+128,N+256)
    check(N==2**31-1 and L==2**37 and
          out['Yojson']['lexbuf_capacity_upper']==max(1024,2*N) and
          out['Yojson']['decoded_string_buffer_capacity_upper']==max(256,2*N) and
          out['Format_Printf_Buffer']['private_buffer_capacity_upper']==max(512,2*L),
          'independent body file and private buffer endpoint arithmetic')
    for request in out['individual_strings'].values():
        length=request['length']
        words=(length+1+7)//8
        check(request['payload_words']==words and request['request_bytes']==8*(words+1) and
              length<=2**57-9 and words<=2**54-1 and 8*(words+1)<2**64,
              'independent individual string padding header and byte request')
    check(all(out['guards'].values()) and max(4*N+2048,4*N+8,4*B+64,2*L+2*1000000010+256,4*L)<=I,
          'independent parser formatter tagged arithmetic guards')
    check(out['source_provider_relation_required'] and
          out['complete_C_to_T_representation_when_joined_to_accepted_prefix_and_auxiliary'] and
          not out['T_to_builder_transport'] and not out['cumulative_physical_bytes_or_stack_bound_claimed'] and
          (out['process_global_exception_allowance'],out['save_entering_callbacks'],out['save_calls'])==(2,2,3),
          'conditional C-to-T join and unchanged scope and control budget')
for data in (b'0\n',b'[]\n',b'{}\n\n'):
    out=api.from_serialized_json('put',data)
    check(out['producer_body_bytes_upper']==len(data)-1 and out['Yojson']['file_bytes_including_Close_LF']==len(data),
          'actual-byte interface removes exactly one LF')

result={'status':'passed','author_commit':AUTHOR,'assertions':sum(groups.values()),'groups':dict(groups),
        'elapsed_seconds':time.monotonic()-START,'host':platform.platform(),
        'source_files':len(sources),'numeric_controls':numeric_controls,'lex_refill_controls':lex_controls,
        'formatter_controls':format_controls,'review_inputs':exact_inputs,'author_changed_files':changed,
        'audit_identity':identity(Path(__file__).read_bytes()),
        'source_argument_machine_proved':False,'actual_native_parser_or_formatter_executed':False,
        'native_capture_compiler_prover_Lean_disassembler_service_runs':0,'author_predecessor_checker_extractor_runs':0,
        'conditional_C_to_T_representation_join_accepted':True,'T_to_builder_transport':False}
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('numeric_controls','formatter_controls','review_inputs','author_changed_files')},indent=2))
