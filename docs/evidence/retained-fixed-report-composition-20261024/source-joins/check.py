"""Check new fixed source/string attachment; no predecessor audit replay."""
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
START = time.perf_counter()
checks = 0


def require(condition, description):
    global checks
    assert condition, description
    checks += 1


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    return json.loads(path.read_text())


inputs = read(HERE / 'inputs.json')
for row in inputs['files']:
    raw = (ROOT / row['path']).read_bytes()
    require(len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path'])

sources = read(HERE / 'sources.json')
texts = {}
span_count = 0
for archive in sources['archives']:
    path = ROOT / archive['path']
    require(sha(path.read_bytes()) == archive['sha256'], archive['path'])
    with tarfile.open(path) as tf:
        for row in archive['files']:
            raw = tf.extractfile(row['member']).read()
            require(sha(raw) == row['sha256'] and len(raw) == row['bytes'], row['member'])
            texts[row['member']] = raw.decode('utf-8')
            lines = raw.split(b'\n')
            for span in row['spans']:
                chunk = b'\n'.join(lines[span['first_lf_line']-1:span['last_lf_line']]) + b'\n'
                require(sha(chunk) == span['sha256'], span)
                span_count += 1

spec = importlib.util.spec_from_file_location('fixed_source_attachment', HERE / 'capacity.py')
c = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = c
spec.loader.exec_module(c)

inventory = read(ROOT / 'docs/evidence/unbounded-programs/retained-source-closure-20261017/source-inventory.json')
runtime = inventory['installed_runtime_corpora']['producer']
paths = read(ROOT / 'docs/evidence/retained-fixed-report-composition-20261024/paths/result.json')
require(runtime['manifest_sha256'] == paths['runtime_corpus']['manifest_sha256'],
        'reuse accepted complete corpus identity without rescanning')
require(runtime['file_count'] == 1575 and runtime['bytes'] == 17847599,
        'accepted complete physical-byte inventory')
silver_bytes = sum((ROOT / p).stat().st_size for p in inputs['silver_sources'])
span = runtime['bytes'] + silver_bytes + 8192
require(span + 1 < 2**31 - 1, 'fixed source-copy String and spare')

pprint = texts['gcc/ada/pprint.adb']
require(pprint.index('Buffer           : String (1 .. Natural (Right - Left + 1))')
        < pprint.index('if Index >= Threshold then'), 'allocate before truncation')
require("Src (Scn + 1) = '-'" in pprint and 'Scn := Scn + 1;' in pprint,
        'actual lookahead and loop spare remain in argument')
loader = texts['gcc/ada/osint.adb']
require('Hi := Lo + Source_Ptr (Len);' in loader and 'Var_Ptr (Hi) := EOF;' in loader,
        'physical size and EOF interpretation')
fem = texts['spark-source/src/flow/flow_error_messages.adb']
brief = fem.split('when GPO_Brief   =>', 1)[1].split('when GPO_Oneline =>', 1)[0]
require('Wrap_Error_Msg (Obj.Msg);' in brief and 'Obj.Fix' not in brief,
        'private fixes are constructed but absent from brief print')
handler = texts['spark-source/src/why/gnat2why-error_messages.adb'].split(
    'Emit_Proof_Result\n              (Node', 1)[1].split(');', 1)[0]
require('Explanation' not in handler, 'actual response uses empty formal default')
require('Explanation   : String := "";' in texts[
    'spark-source/src/why/gnat2why-error_messages.adb'], 'empty explanation default')
wrapper = texts['spark-source/src/utils/errout_wrapper.adb']
json_body = wrapper.split('procedure Add_Json_Msg', 1)[1].split('end Add_Json_Msg;', 1)[0]
require('Obj.Fix' not in json_body and 'Obj.Explanation' not in json_body,
        'no retained JSON history of private backing')
require('Shared_String' in texts['installed-runtime/a-strunb.ads'],
        'selected shared runtime rather than default GCC implementation')

exports = {}
for unit in c.FRONTEND:
    result = c.fixed_strings(unit=unit, fixed_source_span=span, path_bytes=188)
    require(all(result['guards'].values()), (unit, result['guards']))
    require(result['expression']['reset_levels'] == [15581, 376325, 9034181],
            'unchanged accepted generated-image recurrence')
    require(result['proof_variable_ids'] == 2*(c.FRONTEND[unit]+6)+1,
            'whole-process variable universe, not graph-local F')
    require(result['private_strings']['fix'] >= 14*9034181 + 188+14+1326,
            'eager range candidates and escaping paid')
    require(result['source_coordinate_provider_required']
            and not result['private_working_sets_and_traversal_storage_closed']
            and not result['complete_fixed_report_capacity'], 'scope stays explicit')
    require(result['string_backing']['separate_backing_bytes'] <= 2**31-1,
            'largest individual alignment/backing expression fits')
    exports[unit] = result

# Changed attachment controls: endpoints and rejection of unbound Main/invalid
# mathematical inputs. These do not execute Pprint or simulate an Ada frontend.
for size in [0, 1, 255, 256, 257, span]:
    require(c.backing(size)['separate_backing_bytes'] == size+size//2+192,
            'per-object retained runtime backing bound')
bad = c.fixed_strings(unit='Silver_IO', fixed_source_span=2**31-1, path_bytes=188)
require(not bad['guards']['image'], 'source-span boundary is not silently admitted')
bad = c.fixed_strings(unit='Silver_IO', fixed_source_span=span, path_bytes=2**31)
require(not bad['guards']['plain_string_and_loop_spare'], 'path overflow rejected')
for unit in ['Main', 'future_library']:
    try:
        c.fixed_strings(unit=unit, fixed_source_span=span, path_bytes=188)
    except KeyError:
        require(True, 'no arbitrary Main/future-library extrapolation')
    else:
        raise AssertionError(unit)
for value in [-1, True]:
    try:
        c.fixed_strings(unit='Silver_IO', fixed_source_span=value, path_bytes=188)
    except ValueError:
        require(True, 'invalid source operand rejected')
    else:
        raise AssertionError(value)

receipt = dict(status='passed', checks=checks, provider_files=len(inputs['files']),
    complete_source_files=len(texts), source_spans=span_count,
    runtime_bytes=runtime['bytes'], six_silver_source_bytes=silver_bytes,
    retained_configuration_allowance=8192, fixed_source_span_upper=span,
    path_bytes=188, exports=exports, predecessor_checkers_run=0,
    native_compiler_prover_Lean_capture_service_runs=0, runtime_corpus_rescans=0,
    complete_fixed_report_capacity=False, independent_review_pending=True,
    elapsed_seconds=time.perf_counter()-START, host=platform.platform())
(HERE / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({k:v for k,v in receipt.items() if k != 'exports'}, indent=2))
