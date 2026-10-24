#!/usr/bin/env python3
"""Independent F1/#215 repair audit; execute only the two leaf predicates.

Git object reads attach exact inputs. No author/reviewer predecessor checker,
provider import, fixture, installation query or native target is executed.
"""
from pathlib import Path
import ast
import hashlib
import json
import re
import subprocess
import time

START = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
AUTHOR = '9432b9d69498cce7e2474d7a96c4adc37f97b7ae'
REPAIR = '649d8293c74c56cccadcec74dec5a4bb96e7e335'
REVIEW = '3d0912369432c6aae081d3489b5178aa9ac3732a'
RECIPE = 'docs/evidence/retained-fixed-report-composition-20261024/prospective/recipe.py'
REPORT = 'docs/reviews/review-prospective-configuration-20261024.md'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def blob(commit, name):
    return git('show', commit + ':' + name)


old = blob(AUTHOR, RECIPE)
new = (ROOT / RECIPE).read_bytes()
assert new == blob(REPAIR, RECIPE)
old_tree, new_tree = ast.parse(old), ast.parse(new)


def without_predicate(tree):
    return [ast.dump(n) for n in tree.body
            if not (isinstance(n, ast.FunctionDef) and n.name == 'pathfile_entries')]


assert without_predicate(old_tree) == without_predicate(new_tree)
predicate = next(n for n in new_tree.body if isinstance(n, ast.FunctionDef) and n.name == 'pathfile_entries')
predicate_text = ast.unparse(predicate)
assert "allowed_spellings = allowed | {p + '/' for p in allowed}" in predicate_text
assert 'any((v not in allowed_spellings for v in values))' in predicate_text
assert 'return values' in predicate_text and '.rstrip(' not in predicate_text

# The constants are independently specified; compare their retained declarations
# through unchanged AST, and evaluate only the workspace/pathfile leaf functions.
vendor = '/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef'
rts = vendor + '/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0'
work = '/tmp/program-Z9y8X7'
obj = work + '/obj/gnatprove'


def leaf(tree):
    nodes = [n for n in tree.body if isinstance(n, ast.FunctionDef)
             and n.name in ('workspace', 'pathfile_entries')]
    env = dict(re=re, RUNTIME_SOURCE=rts + '/adainclude', RUNTIME_OBJECT=rts + '/adalib',
               PHASES=('', '/phase1', '/data_representation'))
    exec(compile(ast.Module(body=nodes, type_ignores=[]), RECIPE, 'exec'), env)
    return env['pathfile_entries']


original, repaired = leaf(old_tree), leaf(new_tree)
families = dict(source=[work, rts + '/adainclude'],
                object=[work + '/obj', rts + '/adalib', obj, obj + '/phase1', obj + '/data_representation'])
accepted, rejected = [], []
for kind, paths in families.items():
    legal = [p + suffix for p in paths for suffix in ('', '/')]
    for rows in [[p] for p in legal] + [legal + legal[::-1] + legal[:1]]:
        data = ('\n'.join(rows) + '\n').encode()
        assert repaired(data, work, kind) == rows
        accepted.append(dict(kind=kind, rows=rows, sha256=sha(data)))
    candidates = [((p + '/' * count + '\n').encode(), 'repeated slash')
                  for p in paths for count in [2, 3, 16, 256]]
    candidates += [((p + suffix + '\n').encode(), 'unsupported suffix')
                   for p in paths for suffix in ('/.', '/..', '/foreign', '\x00', '\r', '\v', '\f', '／')]
    candidates += [(data, 'malformed frame') for data in
                   [b'', b'\n', b'\xff\n', (paths[0] + '\n\n').encode(), paths[0].encode()]]
    candidates += [((p + '\n').encode(), 'wrong family') for p in families['object' if kind == 'source' else 'source']]
    for data, reason in candidates:
        try:
            repaired(data, work, kind)
        except ValueError:
            rejected.append(dict(kind=kind, reason=reason, bytes=len(data), sha256=sha(data)))
        else:
            raise AssertionError(('unexpectedly accepted', kind, data))

bad = (rts + '/adainclude' + '/' * 256 + '\n').encode()
assert original(bad, work, 'source') == [bad.decode()[:-1]]
assert len(bad[:-1] + b'system.ads') == 439
try:
    repaired(bad, work, 'source')
except ValueError:
    pass
else:
    raise AssertionError('original F1 counterexample survived repair')

# Bind all six repair inputs and ensure old evidence/history was preserved.
changed = git('diff-tree', '--no-commit-id', '--name-only', '-r', REPAIR).decode().splitlines()
assert len(changed) == 6
repair_hashes = {}
for name in changed:
    data = (ROOT / name).read_bytes()
    assert data == blob(REPAIR, name), name
    repair_hashes[name] = sha(data)
original_inputs = git('diff-tree', '--no-commit-id', '--name-only', '-r', AUTHOR).decode().splitlines()
mutable = {RECIPE,
           'docs/evidence/retained-fixed-report-composition-20261024/prospective/README.md',
           'docs/research/retained-fixed-report-composition.md'}
preserved_author = {}
for name in original_inputs:
    if name not in mutable:
        data = (ROOT / name).read_bytes()
        assert data == blob(AUTHOR, name), name
        preserved_author[name] = sha(data)
preserved_review = {}
for name in git('diff-tree', '--no-commit-id', '--name-only', '-r', REVIEW).decode().splitlines():
    data, baseline = (ROOT / name).read_bytes(), blob(REVIEW, name)
    assert (data.startswith(baseline) if name == REPORT else data == baseline), name
    preserved_review[name] = sha(baseline)
for name in mutable - {RECIPE}:
    assert (ROOT / name).read_bytes().startswith(blob(AUTHOR, name)), name

result = dict(status='pass_F1_resolved', original_author=AUTHOR, repair_commit=REPAIR,
    original_review_commit=REVIEW, repair_input_sha256=repair_hashes,
    original_recipe_sha256=sha(old), repaired_recipe_sha256=sha(new),
    independent_audit_sha256=sha(Path(__file__).read_bytes()),
    unchanged_author_artifacts=preserved_author, preserved_original_review=preserved_review,
    outside_pathfile_entries_AST_unchanged=True, raw_membership_and_raw_return_verified=True,
    original_counterexample_bytes=439, original_counterexample_reproduced=True,
    original_counterexample_rejected_after_repair=True,
    accepted_cases=accepted, rejected_cases=rejected, accepted_count=len(accepted), rejected_count=len(rejected),
    report_P_remains_conditional=188, actual_complete_common_path_bytes=None,
    worker_argv_and_configuration_coefficients_unchanged=True,
    author_or_predecessor_checker_runs=0, provider_imports=0, native_target_compiler_prover_lean_runs=0,
    fixture_runs=0, installation_queries=0, service_queries=0,
    selected_model='GPT-6 Astra', selected_effort='Extra High', runtime_model_confirmed=False,
    token_usage=None, cost=None, elapsed_seconds=time.monotonic() - START)
(HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({k: result[k] for k in ('status', 'repair_commit', 'accepted_count', 'rejected_count', 'elapsed_seconds')}, indent=2))
