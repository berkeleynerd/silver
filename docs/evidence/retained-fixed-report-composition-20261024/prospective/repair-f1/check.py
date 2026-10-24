"""Narrow F1/#215 regression; no provider checker or native execution."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
AUTHOR = '9432b9d69498cce7e2474d7a96c4adc37f97b7ae'
RECIPE = 'docs/evidence/retained-fixed-report-composition-20261024/prospective/recipe.py'
START = time.perf_counter()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def selected(raw):
    tree = ast.parse(raw)
    names = {'VENDOR', 'RTS', 'RUNTIME_SOURCE', 'RUNTIME_OBJECT', 'PHASES'}
    nodes = [node for node in tree.body
             if (isinstance(node, ast.Assign) and
                 any(isinstance(x, ast.Name) and x.id in names for x in node.targets))
             or (isinstance(node, ast.FunctionDef) and
                 node.name in {'workspace', 'pathfile_entries'})]
    env = {'re': re}
    exec(compile(ast.Module(body=nodes, type_ignores=[]), RECIPE, 'exec'), env)
    return tree, env


original = subprocess.check_output(['git', 'show', AUTHOR+':'+RECIPE], cwd=ROOT)
current = (ROOT/RECIPE).read_bytes()
old_tree, old = selected(original)
new_tree, new = selected(current)


def remainder(tree):
    return [ast.dump(node) for node in tree.body
            if not (isinstance(node, ast.FunctionDef) and node.name == 'pathfile_entries')]


assert remainder(old_tree) == remainder(new_tree), 'unrelated recipe semantics changed'
work = '/tmp/program-A1b2C3'
bad = old['RUNTIME_SOURCE']+'/'*256
assert old['pathfile_entries']((bad+'\n').encode(), work, 'source') == [bad]
assert len((bad+'system.ads').encode()) == 439

checks = 0
accepted = []
rejected = []


def reject(data, kind):
    global checks
    try:
        new['pathfile_entries'](data, work, kind)
    except (ValueError, UnicodeDecodeError):
        checks += 1
        rejected.append(dict(kind=kind, bytes=len(data), sha256=sha(data)))
    else:
        raise AssertionError(('accepted unsupported raw spelling', kind, data))


obj = work+'/obj/gnatprove'
families = dict(source=(work, new['RUNTIME_SOURCE']),
                object=(work+'/obj', new['RUNTIME_OBJECT'])+
                       tuple(obj+s for s in new['PHASES']))
for kind, directories in families.items():
    values = [p+suffix for p in directories for suffix in ('', '/')]
    # Preserve original raw values, order and multiplicity. Capacity for the
    # number of rows remains separately owned, as in the original interface.
    for rows in ([v] for v in values):
        data = ('\n'.join(rows)+'\n').encode()
        assert new['pathfile_entries'](data, work, kind) == rows
        checks += 1
        accepted.extend(rows)
    rows = values+list(reversed(values))
    assert new['pathfile_entries'](('\n'.join(rows)+'\n').encode(), work, kind) == rows
    checks += 1
    for p in directories:
        for suffix in ('//', '///', '/'*256, '/.', '/foreign', '\x00', '\r'):
            reject((p+suffix+'\n').encode(), kind)
    reject(b'', kind)
    reject(b'\n', kind)
    reject((directories[0]+'\n\n').encode(), kind)
    reject(directories[0].encode(), kind)
    reject(b'\xff\n', kind)
reject((work+'\n').encode(), 'unknown')
reject((new['RUNTIME_OBJECT']+'\n').encode(), 'source')
reject((new['RUNTIME_SOURCE']+'\n').encode(), 'object')

frozen = {}
paths = subprocess.check_output(['git', 'diff-tree', '--no-commit-id',
                                '--name-only', '-r', AUTHOR], cwd=ROOT, text=True)
excluded = {RECIPE, 'docs/evidence/retained-fixed-report-composition-20261024/prospective/README.md',
            'docs/research/retained-fixed-report-composition.md'}
for path in paths.splitlines():
    if path not in excluded:
        raw = (ROOT/path).read_bytes()
        assert raw == subprocess.check_output(['git', 'show', AUTHOR+':'+path], cwd=ROOT)
        frozen[path] = sha(raw)

result = dict(status='pass', finding='F1/#215', assertions=checks,
              original_author=AUTHOR, original_recipe_sha256=sha(original),
              repaired_recipe_sha256=sha(current), checker_sha256=sha(Path(__file__).read_bytes()),
              original_counterexample_path_bytes=439,
              accepted_raw_spellings=accepted, rejected_cases=rejected,
              unchanged_author_inputs=frozen, unrelated_recipe_AST_unchanged=True,
              complete_native_configuration=False, complete_issue119=False,
              predecessor_or_author_checker_runs=0, native_target_runs=0,
              compiler_prover_Lean_runs=0, service_queries=0,
              elapsed_seconds=time.perf_counter()-START)
(HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items()
                  if k not in ('accepted_raw_spellings','rejected_cases','unchanged_author_inputs')}, indent=2))
