#!/usr/bin/env python3
"""Narrow frozen-input audit; no model loading, suite or native execution."""
import argparse
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--ada-root', type=Path, required=True)
parser.add_argument('--gcc-root', type=Path, required=True)
args = parser.parse_args()
started = time.monotonic()
here = Path(__file__).resolve().parent
repo = here.parents[2]
target = '3a7d590389c3b3b71c368c7f9033b39d0d107606'
packet = repo / 'docs/evidence/retained-literal-ada-numeric-20261018'
prior = repo / 'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
roots = dict(repository=repo, ada=args.ada_root, gcc=args.gcc_root)
identity = json.loads((packet / 'inputs.json').read_bytes())

def verify(root, row):
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']

for row in identity['files']:
    verify(roots[row['root']], row)
frontend = json.loads((repo / 'docs/evidence/retained-literal-native-frontend-20261018/inputs.json').read_bytes())
for row in frontend['repository_inputs']:
    verify(repo, row)
complete = json.loads((repo / 'docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json').read_bytes())
extra_names = ['alloc.ads', 'types.ads', 'uintp.h', 'urealp.ads',
               'repinfo.adb', 'repinfo.ads', 'table.adb', 'table.ads',
               'libgnat/s-htable.adb']
extra = {row['path']: row for row in complete['files'] if row['path'] in extra_names}
assert len(extra) == len(extra_names)
for row in extra.values():
    raw = (args.ada_root / row['path']).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    assert hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest() == row['git_blob_sha1']

# The numeric return expressions do not depend on the two path/name arguments.
tree = ast.parse((prior / 'derive.py').read_text())
fixed = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'native_fixed_frontend')
returned = next(n.value for n in fixed.body if isinstance(n, ast.Return))
projection = {}
for kw in returned.keywords:
    if kw.arg in ('Uint_entries', 'Uint_digits', 'Ureal_entries'):
        assert isinstance(kw.value, ast.Subscript) and isinstance(kw.value.value, ast.Name)
        assert kw.value.value.id == 'raw' and isinstance(kw.value.slice, ast.Constant)
        projection[kw.arg] = kw.value.slice.value
assert len(projection) == 3
fixed_inputs = json.loads((prior / 'native-fixed-inputs.json').read_bytes())
fixed_counts = fixed_inputs['fixed_lifetime_table_growth']
capture = json.loads((repo / 'docs/evidence/retained-native-fixed-capture-20261018/summary.json').read_bytes())
assert fixed_counts == capture['phases']['main_return']
assert [fixed_counts[projection[k]] for k in ('Uint_entries', 'Uint_digits', 'Ureal_entries')] == [24324, 74958, 60]
assert fixed_counts['repinfo__rep_table__last_valX'] == 504

result = json.loads((packet / 'result.json').read_bytes())
assert result['demands'] == {k: sum(r[k] for r in result['demand_rows'].values()) for k in result['demands']}
assert all(result[k] is False for k in ('complete_native_frontend', 'complete_original_gigi', 'complete_native_capacity', 'production_admission_changed'))
hello = (repo / 'samples/hello_world.adb').read_bytes()
assert result['source']['sha256'] == hashlib.sha256(hello).hexdigest()
paths = subprocess.check_output(['git', 'diff-tree', '--no-commit-id', '--name-only', '-r', target], cwd=repo, text=True).splitlines()
assert len(paths) == 6
target_files = []
for name in paths:
    raw = (repo / name).read_bytes()
    frozen = subprocess.check_output(['git', 'show', target + ':' + name], cwd=repo)
    assert raw == frozen
    target_files.append(dict(path=name, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()))

output = dict(review_target=target, host='Linux x86_64',
              explicit_identity_records=dict(Counter(row['root'] for row in identity['files'])),
              frontend_repository_identity_records=len(frontend['repository_inputs']),
              additional_reviewed_source_identities=extra,
              numeric_projection=projection, fixed_counters_match_retained_capture=True,
              retained_hello_rows_reconcile=True, broad_completion_flags_false=True,
              target_files=target_files, elapsed_seconds=time.monotonic()-started,
              model_loaded=False, candidate_check_suite_rerun=False,
              predecessor_suites_rerun=False, native_tool_executions=0)
(here / 'result.json').write_text(json.dumps(output, indent=2) + '\n')
print(json.dumps({k: v for k, v in output.items() if k not in ('target_files', 'additional_reviewed_source_identities')}))
