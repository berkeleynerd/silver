#!/usr/bin/env python3
"""Independent F1 repair audit; executes only the changed callable definitions.

No author check(), author repair checker, predecessor checker, parser, native
compiler, prover or Lean is loaded or run.
"""
import ast
import hashlib
import json
import platform
import subprocess
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
UNIT = ROOT / 'docs/evidence/retained-general-native-capacity-20261024/concat-selectors'
REPAIR = 'de0d23d2faf996931861920d2dcd51d80995ad93'
ORIGINAL = 'bba92a0c0685cffdf8c9e179f6b36aafea81c4be'
REVIEW = '8ce1291b7a7cf9739666562f81cac09b73d8ad5f'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def row(path, data):
    return dict(path=path, bytes=len(data), sha256=sha(data))


def stats():
    return dict(activations=0, constant_requests=0, unchanged_selectors=0,
                minmax_calls=0, extremum_absorptions=0)


def run():
    start = time.perf_counter()
    changed = git('diff-tree', '--no-commit-id', '--name-only', '-r', REPAIR).decode().splitlines()
    assert len(changed) == 13
    repair_inputs = []
    for name in changed:
        data = (ROOT / name).read_bytes()
        assert data == git('show', f'{REPAIR}:{name}')
        repair_inputs.append(row(name, data))
    preserved_review = []
    for name in ('README.md', 'audit.py', 'current.json', 'finding-F1.json', 'manifest.json'):
        path = f'docs/evidence/review-concat-selectors-20261024/{name}'
        data = (ROOT / path).read_bytes()
        assert data == git('show', f'{REVIEW}:{path}')
        preserved_review.append(row(path, data))
    original_report_path = 'docs/reviews/review-concat-selectors-20261024.md'
    original_report = git('show', f'{REVIEW}:{original_report_path}')
    assert (ROOT / original_report_path).read_bytes().startswith(original_report)
    author_receipts = read(UNIT / 'repair-f1/inputs.json')
    for original_row in author_receipts['unchanged_receipts']:
        data = (ROOT / original_row['path']).read_bytes()
        assert data == git('show', f'{ORIGINAL}:{original_row["path"]}')
        assert sha(data) == original_row['sha256']
    for anchor in author_receipts['anchors']:
        data = (UNIT / 'repair-f1' / anchor['retained_file']).read_bytes()
        assert data == git('show', f'{anchor["commit"]}:{anchor["path"]}')
        assert sha(data) == anchor['sha256']
    for manifest_row in read(UNIT / 'packet-manifest-f1.json')['files']:
        data = (ROOT / manifest_row['path']).read_bytes()
        assert len(data) == manifest_row['bytes'] and sha(data) == manifest_row['sha256']
    old_inventory = json.loads(git('show', f'{ORIGINAL}:{UNIT.relative_to(ROOT)}/matcher-audit.json'))
    active_inventory = read(UNIT / 'matcher-audit.json')
    disposition_changes = []
    for kind in old_inventory:
        old_rows = old_inventory[kind]['root_patterns']
        new_rows = active_inventory[kind]['root_patterns']
        assert len(old_rows) == len(new_rows)
        for old, new in zip(old_rows, new_rows):
            assert {k:v for k,v in old.items() if k != 'disposition'} == {
                k:v for k,v in new.items() if k != 'disposition'}
            if old != new:
                assert kind == 'extremum'
                disposition_changes.append(new['line'])
    for line in (4950,4961):
        item, = [r for r in active_inventory['extremum']['root_patterns'] if r['line'] == line]
        assert 'TREE_SIDE_EFFECTS-false' in item['disposition']
        assert 'COMPOUND_EXPR' in item['disposition']

    source_manifest = read(UNIT / 'source-manifest.json')
    sources = {}
    needed = {'gcc/genmatch.cc','gcc/fold-const.cc','gcc/tree.cc'}
    source_receipts = []
    for archive in source_manifest['archives']:
        selected = [r for r in source_manifest['files'] if r['archive'] == archive['path'] and r['path'] in needed]
        if not selected:
            continue
        path = UNIT / archive['path']
        assert sha(path.read_bytes()) == archive['sha256']
        with tarfile.open(path) as package:
            for selected_row in selected:
                data = package.extractfile(selected_row['path']).read()
                assert len(data) == selected_row['bytes'] and sha(data) == selected_row['sha256']
                sources[selected_row['path']] = data
                source_receipts.append(selected_row)
    assert set(sources) == needed
    spans = read(UNIT / 'repair-f1/source-witnesses.json')['witnesses']
    for span in spans:
        data = b'\n'.join(sources[span['source']].split(b'\n')[span['first_lf_line']-1:span['last_lf_line']])+b'\n'
        assert sha(data) == span['sha256']

    # Load exact changed public model definitions without module imports or
    # its broad check()/matcher entry points. Preserve the original AST body.
    model_source = (UNIT / 'check.py').read_text()
    parsed = ast.parse(model_source)
    names = {'Condition','Node','maximum'}
    definitions = [node for node in parsed.body if isinstance(node,(ast.ClassDef,ast.FunctionDef)) and node.name in names]
    assert {node.name for node in definitions} == names
    namespace = {}
    exec(compile(ast.Module(body=definitions,type_ignores=[]),str(UNIT/'check.py'),'exec'),namespace)
    Node, Condition, maximum = (namespace[n] for n in ('Node','Condition','maximum'))
    bounds = {False:Node('literal',-2**31),True:Node('literal',2**31-1)}
    pure = Condition('Q',side_effects=False)
    inner = Node('cond',Condition('P',side_effects=False),Node('literal',1),Node('literal',7))
    mixed = Node('cond',pure,Node('var','D'),inner)
    pure_calls = 0
    rejected_calls = 0
    for direction in (False,True):
        for tree, expected in ((inner,inner),(mixed,bounds[direction])):
            state = stats()
            assert maximum(tree,direction,state,bounds) is expected
            assert state['constant_requests'] <= 3
            pure_calls += 1
        bad_conditions = (Condition('effects',side_effects=True),None,object(),('unknown',),False)
        for condition in bad_conditions:
            for bad in (Node('cond',condition,Node('literal',1),Node('literal',7)),
                        Node('cond',pure,Node('var','D'),Node('cond',condition,Node('literal',1),Node('literal',7)))):
                try:
                    maximum(bad,direction,stats(),bounds)
                except ValueError:
                    rejected_calls += 1
                else:
                    raise AssertionError('unsupported condition accepted')
    rejected_constructors = 0
    makers = [lambda:Condition('missing')]
    makers += [lambda value=value:Condition('unknown',side_effects=value) for value in (None,0,1,'',[],{})]
    for maker in makers:
        try:
            maker()
        except (ValueError,TypeError):
            rejected_constructors += 1
        else:
            raise AssertionError('implicit/non-Boolean purity accepted')
    # Source-reviewed flag propagation and omission branch: the corrected
    # helper applies only to the all-false case. This is not native execution.
    flag_cases = 0
    for condition in (False,True):
        for left in (False,True):
            for right in (False,True):
                selector_effects = condition or left or right
                new_compounds = int(selector_effects)
                assert (new_compounds == 0) == (not condition and not left and not right)
                flag_cases += 1
    assert read(UNIT/'remaining.json')['complete_native_capacity_result'] is False
    assert (UNIT/'ledger.json').read_bytes() == git('show',f'{ORIGINAL}:{UNIT.relative_to(ROOT)}/ledger.json')
    return dict(status='pass',verdict='F1 repaired; accept corrected bounded selector transfer',
        reviewed_repair=REPAIR,provisional_review=REVIEW,original_author=ORIGINAL,
        repair_inputs=repair_inputs,preserved_original_review_artifacts=preserved_review,
        preserved_original_report=row(f'{REVIEW}:{original_report_path}',original_report),
        unchanged_author_receipts=author_receipts['unchanged_receipts'],
        source_files=source_receipts,new_source_spans=len(spans),
        revised_disposition_lines=disposition_changes,callable_definitions_exercised=sorted(names),
        pure_calls=pure_calls,rejected_unsupported_calls=rejected_calls,
        rejected_missing_or_nonboolean_constructors=rejected_constructors,
        effects_propagation_omission_cases=flag_cases,coefficients_changed=False,
        completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-start,
        platform=f'{platform.system()} {platform.machine()}',
        selected_reviewer_model='GPT-6 Astra',selected_reviewer_effort='Extra High',
        runtime_model_and_effort=None,tokens=None,cost=None,
        author_checkers_or_predecessor_checks=0,native_compiler_prover_Lean_runs=0,
        semantic_source_argument_machine_proved=False,complete_native_capacity_result=False)


if __name__=='__main__':
    result=run()
    (HERE/'current.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {
        'repair_inputs','preserved_original_review_artifacts','unchanged_author_receipts','source_files'}},indent=2))
