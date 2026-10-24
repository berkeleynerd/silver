#!/usr/bin/env python3
"""Focused independent source/transfer audit; no author/provider checker replay."""
import argparse
from functools import cache
import hashlib
import io
import json
from pathlib import Path
import platform
import re
import subprocess
import tarfile
import time
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = 'docs/evidence/retained-response-parser-capacity-20261023/'
NOTE = 'docs/research/retained-response-parser-capacity.md'
parser = argparse.ArgumentParser()
parser.add_argument('--origins', action='store_true',
                    help='Also compare retained source archive and installed source snapshots')
args = parser.parse_args()
start = time.monotonic()
freeze = json.loads((HERE/'author-freeze.json').read_text())
commit = freeze['commit']
checks = 0
identities = []


def require(condition, label):
    global checks
    checks += 1
    assert condition, label


def sha(data):
    return hashlib.sha256(data).hexdigest()


@cache
def read(path, rev=commit):
    data = subprocess.check_output(['git', 'show', rev+':'+path], cwd=ROOT)
    return data


def archive(data):
    with tarfile.open(fileobj=io.BytesIO(data)) as tf:
        return {m.name: tf.extractfile(m).read() for m in tf if m.isfile()}


for pin in freeze['files']:
    data = read(pin['path'])
    require(sha(data) == pin['sha256'], pin['path'])
    require(len(data) == pin['bytes'], pin['path']+' length')
inputs = json.loads(read(PACKET+'inputs.json'))
for pin in inputs['providers']:
    data = read(pin['path'], pin.get('commit', commit))
    require(sha(data) == pin['sha256'], 'provider '+pin['path'])
manifest = json.loads(read(PACKET+'source-manifest.json'))
data = read(PACKET+'sources.tar.gz')
require(sha(data) == manifest['archive_sha256'], 'source archive')
src = archive(data)
require(set(src) == {f['member'] for f in manifest['files']}, 'complete manifest')
for f in manifest['files']:
    require(sha(src[f['member']]) == f['sha256'], f['member'])
    require(len(src[f['member']]) == f['bytes'], f['member']+' length')
for w in json.loads(read(PACKET+'source-witnesses.json')):
    chunk = b''.join(src[w['member']].splitlines(keepends=True)[w['first']-1:w['last']])
    require(sha(chunk) == w['sha256'], 'witness '+w['member'])

origin_counts = None
if args.origins:
    origin = Path('/tmp/silver-producer-auxiliary-20261018/gnatcoll-source.zip')
    data = origin.read_bytes()
    require(sha(data) == manifest['gnatcoll_complete_archive_sha256'], 'complete candidate origin')
    origin_counts = {'candidate_files': 0, 'installed_runtime_source_files': 0}
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        for f in manifest['files']:
            if f.get('origin') == 'gnatcoll_complete_archive':
                require(z.read(f['origin_member']) == src[f['member']], 'origin '+f['member'])
                origin_counts['candidate_files'] += 1
            else:
                require(Path(f['origin']).read_bytes() == src[f['member']], 'snapshot '+f['member'])
                origin_counts['installed_runtime_source_files'] += 1

identity = json.loads(read('docs/evidence/retained-producer-response-20261018/identity.json'))
require(identity['gnatcoll_complete_archive_sha256'] == manifest['gnatcoll_complete_archive_sha256'], 'old archive identity')
require(identity['premise'] == 'Candidate source behavior and current installed config/driver bytes; no historical binary-source identity claim.', 'source/native qualifier')
for f in identity['files']:
    if f['path'] in src:
        require(sha(src[f['path']]) == f['sha256'], 'old source '+f['path'])

def source(name):
    return src[name].decode()

buf = source('gnatcoll/core/src/gnatcoll-buffer.adb')
spec = source('gnatcoll/core/src/gnatcoll-buffer.ads')
js = source('gnatcoll/core/src/gnatcoll-json.adb')
offset = buf[buf.index('   function Next\n'):buf.index('   function Next (Self')]
require('Internal_Next' not in offset, '#187 no offset refill')
require('Offset < Self.Last' in offset and 'Self.EOF := True' in offset, '#187 zero endpoint')
for field in ('Current', 'First', 'Last'):
    require(any(field in line and ':= 0;' in line for line in spec.splitlines()), 'initial '+field)
require('while Next (Data, CC, Offset) loop' in js, 'initial scanner overload')
require('Data : Reader := Open (Path)' in js and 'return Read (Data => Data)' in js, 'Read_File route')
require('FD_Size > Long_Long_Integer (Integer\'Last)' in buf, 'stream threshold')
read_body = js[js.index('   function Read (Data'):js.index('   end Read;', js.index('   function Read (Data'))]
handler = read_body[read_body.rindex('   exception'):]
require('Free (Read_States)' in handler and 'Deallocate (Current_Key)' not in handler, 'error cleanup limitation')
require('when E : Invalid_JSON_Stream' in handler and 'Constraint_Error' not in handler, 'float exception escapes')
require('Tmp.all (1 .. Read_States.all\'Last) := Read_States.all' in js, 'stale full-array copy')
adjust = js[js.index('   overriding procedure Adjust'):js.index('   end Adjust;')]
require(adjust.count('Increment (') == 3 and 'Append' not in adjust, 'container handles share internals')

# Independently inspect the merged-file transport and the precise stderr format.
transport_path = 'docs/evidence/retained-why-save-artifact-dependency-20261020/source-excerpts.json'
transport = read(transport_path)
transport_text = ' '.join(re.sub(r'\s+', ' ', x['text']) for x in json.loads(transport))
require('Err_To_Out => True' in transport_text and 'Output_File_Map.Insert (Pid, Name)' in transport_text, '#188 merged publication')
require('Output_File_Map (Pid)' in transport_text and 'Parse_Why3_Results (Fn, Timing)' in transport_text, '#188 collector relation')
why_path = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
ocaml_path = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
why = archive(read(why_path))
ocaml = archive(read(ocaml_path))
merged_sources = {why_path: why, ocaml_path: ocaml}
for w in json.loads(read(PACKET+'merged-source-witnesses.json')):
    if w['archive'] not in merged_sources:
        with tarfile.open(fileobj=io.BytesIO(read(w['archive']))) as tf:
            merged_sources[w['archive']] = {w['member']: tf.extractfile(w['member']).read()}
    member = merged_sources[w['archive']][w['member']]
    require(sha(member) == w['member_sha256'], 'merged witness member '+w['role'])
    chunk = b''.join(member.splitlines(keepends=True)[w['first']-1:w['last']])
    require(sha(chunk) == w['sha256'] and chunk.decode() == w['text'], 'merged witness '+w['role'])
printer = why['why3/src/core/printer.ml'].decode()
fmt = next(v.decode() for k, v in ocaml.items() if k.endswith('/stdlib/format.ml'))
require('Format.eprintf "bad argument for int_of_string: %s@." s;' in printer, 'one stderr flush-newline')
require('Flush_newline             -> pp_print_newline ppf ()' in fmt, '@. meaning')
require('pp_flush_queue state true; state.pp_out_flush ()' in fmt, 'newline/reset owner')
require('pp_flush_queue state false; state.pp_out_flush ()' in fmt, 'exit flush adds no final newline')
for path in (transport_path, why_path, ocaml_path):
    data = read(path)
    identities.append({'path': path, 'sha256': sha(data), 'bytes': len(data)})

ns = {}
exec(compile(read(PACKET+'capacity.py'), 'frozen-capacity.py', 'exec'), ns)
author = json.loads(read(PACKET+'result.json'))
j = json.loads(read('docs/evidence/retained-why-canonical-json-input-20261023/result.json'))
r = json.loads(read('docs/evidence/retained-reporting-composition-20261023/result.json'))
reports = {x['case']: x for x in r['cases']}
terminal = json.loads(read('docs/evidence/retained-why-terminal-diagnostic-bytes-20261023/result.json'))['configuration_range_example_only']
rows = []
for x in j['cases']:
    y = reports[x['case']]
    normal = ns['normal'](x['R'], x['G'], x['A'], x['N'], y['W_o'], y['L_o'], other_warning_max=422, debug_bytes=26619)
    base = x['JSON_B']['constant'] + 3*y['W_o'] + 6*y['L_o']
    require(normal['B'] == base-84, 'normal affine transfer '+x['case'])
    require(normal['key'] == 61 and normal['decoded'] == 79152, 'normal string maxima '+x['case'])
    require(ns['guard'](normal, 416, 4096, 4096)['all_guards'], 'normal guards '+x['case'])
    orient = y['orientation_only']
    # Sources give 10a user begin/break tokens, 2 initial system begins,
    # Q+2 resets, <=Q+2 final newlines; direct writes have distinct owners.
    Q = x['E']
    require(orient['X'] == terminal['X_abort_payload_sum'], 'terminal orientation')
    b = base + 6*orient['X'] + 64*Q + 69*(20+Q+4) + Q+2 + 2*terminal['Y_single_dispatch']+371
    stored = next(z for z in author['normal_and_postcut'] if z['case'] == x['case'])['orientation_only']
    require(b == stored['malformed_merged_file_bytes'], 'author merged-byte result '+x['case'])
    require(ns['guard'](ns['arbitrary_stream'](b), 416, 4096, 4096)['all_guards'], 'merged guard '+x['case'])
    rows.append({'case': x['case'], 'merged_bytes': b})

pre = []
for P in (180, 416, 1927):
    C = 8*(723+12*max(467,189+256,4*P+2048))+65536
    R4 = 31*C
    X = 4*(R4+P+1024)
    b = 6*X+576 + 69*(40+1+4)+1+2 + 2*R4+253
    got = ns['precut'](P,189)
    require(b in got.values(), 'precut merged transfer')
    require(ns['guard'](ns['arbitrary_stream'](b),416,4096,4096)['all_guards'], 'precut merged guard')
    pre.append({'P': P, 'merged_bytes': b})

# Adjacent power-of-two/page/unsigned-intermediate countermodels.
boundary_rows = []
for b in (0,1,23,24,31,32,33,63,64,65,4095,4096,4097,8191,8192,8193,2**29-1,2**29,2**30-1,2**30):
    got = ns['guard'](ns['arbitrary_stream'](b),416,4096,4096)
    q = max(32, 1 << max(0,b).bit_length())
    require(got['operands']['parser_state_backing'] == q, 'sentinel rounding')
    require(got['operands']['json_counter'] == 3*q+32, 'stale and temporary slots')
    require(got['all_guards'] == (b <= 2**30-1), 'sufficient byte endpoint')
    boundary_rows.append({'bytes': b, 'all_guards': got['all_guards']})
require(ns['round_x'](8192) == 12288, 'strict-next-page discontinuity')
require(3*((2**32-1)//3) <= 2**32-1 < 3*((2**32-1)//3+1), 'unsigned product boundary')
require(3*2**30+32 < 2**32-1, 'JSON maximum alias envelope')
for P, expected in ((2771, True),(2772, False)):
    b = ns['precut'](P,189)['merged_file']
    require(ns['guard'](ns['arbitrary_stream'](b),416,4096,4096)['all_guards'] == expected, 'precut path boundary')
require(author['precut_parser_guard_P_upper_only'] == 2771 and author['composed_with_provider_P_upper'] == 1927, 'provider guard intersection')
require(author['global_e'] == 2 and author['save_callbacks'] == 2 and author['saves'] == 3, 'global allowances')
require(not author['allowance_renewed'] and not author['whole_119_complete'], 'scope')

result = dict(status='pass', checks=checks, reviewed_commit=commit,
              earlier_rejected_freeze=freeze['earlier_rejected_freeze'],
              elapsed_seconds=time.monotonic()-start,
              host={'system':platform.system(),'machine':platform.machine(),'release':platform.release()},
              new_source_files=len(src), provider_pins=len(inputs['providers']),
              original_source_comparison=origin_counts,
              additional_source_inputs=identities, postcut_rows=rows, precut_rows=pre,
              boundary_rows=boundary_rows, author_check_replayed=False,
              predecessor_checks_replayed=False, native_runs=0,
              actual_configuration_attached=False, whole_119_complete=False)
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ('status','checks','reviewed_commit','elapsed_seconds')}))
