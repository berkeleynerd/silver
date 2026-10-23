"""New finite check only; no predecessor checker or target is executed."""
import ast
import hashlib
import json
import re
import tarfile
import time
from pathlib import Path
from compose import calculate, residuals, CASES, OWNERS, CATEGORY
from control import check_control

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def main():
    started = time.monotonic()
    manifest = read(HERE / 'inputs.json')
    for path, expected in manifest['files'].items():
        assert identity((REPO / path).read_bytes()) == expected, path
    witnesses = read(HERE / 'source-witnesses.json')
    archive_paths = {w['archive'] for w in witnesses}
    for archive in archive_paths:
        with tarfile.open(REPO / archive) as tar:
            for w in witnesses:
                if w['archive'] != archive:
                    continue
                raw = tar.extractfile(w['member']).read()
                assert identity(raw) == w['member_identity'], w['id']
                excerpt = b''.join(raw.splitlines(keepends=True)[w['first_line']-1:w['last_line']])
                assert identity(excerpt) == w['excerpt_identity'], w['id']
                assert excerpt.decode() == w['text'], w['id']
    source = {w['id']: w['text'] for w in witnesses}
    # Check key concrete syntax in addition to byte identity. These checks do
    # not replace the reviewed control-flow interpretation of the full bodies.
    assert 'if Gnat_config.parallel > 1 then begin' in source['parallel_callback']
    assert '| Controller_itp.Done pr ->' in source['parallel_callback']
    assert '| _ -> ()' in source['parallel_callback']
    assert '| InternalFailure _ -> "internalfailure"' in source['scalar_log']
    assert '| _ -> []' in source['scalar_log']
    assert 'with e when not (Debug.test_flag Debug.stack_trace) ->' in source['idle_catch']
    assert 'spa.spa_callback (InternalFailure e)' in source['idle_catch']
    assert 'create_vsymbol (id_clone v.vs_name) v.vs_ty' in source['unsafe_opening']
    assert 'Printexc.raise_with_backtrace (Finally_raised e) bt' in source['finally_secondary']

    # Read literal API constants without importing/running predecessor code.
    api_tree = ast.parse((REPO / 'docs/evidence/retained-why-shared-demand-20261020/compose.py').read_text())
    constants = {}
    for node in api_tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            if node.targets[0].id in ('OWNERS', 'RESIDUALS'):
                constants[node.targets[0].id] = ast.literal_eval(node.value)
    assert constants['OWNERS'] == OWNERS and CATEGORY in constants['RESIDUALS']
    attached = read(REPO / 'docs/evidence/retained-why-shared-demand-20261020/attachment.json')
    assert {r['case'] for r in attached} == set(CASES)
    model_meta = read(REPO / 'docs/evidence/retained-why-model-meta-control-20261020/result.json')
    assert model_meta['get_model_for_selected_saved_calls'] == 'None'
    result = calculate()
    assert result == read(HERE / 'result.json')
    assert [r['registered_roots'] for r in result['cases']] == [51, 42, 22, 2, 1]
    for escape in range(3):
        candidate = calculate(escape=escape)
        assert candidate['budgets']['process_global_escape'] == escape
        for row in candidate['cases']:
            assert row['same_process_preparation_episode_upper'] == 3*row['registered_roots'] + escape
            v = candidate['residuals'][row['case']][CATEGORY]
            assert set(v) == set(OWNERS)
            assert all(set(x) == {'increments', 'requests'} for x in v.values())
            assert all(type(n) is int and n == 0 for x in v.values() for n in x.values())
        assert candidate['residuals'] == result['residuals']
        assert all(set(r) == {CATEGORY} for r in candidate['residuals'].values())
    rejected = 0
    for invalid in (True, False, -1, 3, 2.0, '2', None):
        try:
            residuals(escape=invalid)
        except ValueError:
            rejected += 1
        else:
            raise AssertionError(('accepted invalid budget', invalid))
    assert rejected == 7
    # Every call returns independent owned dictionaries, including between cases.
    independent = residuals()
    independent[CASES[0]][CATEGORY]['Ident']['increments'] = 1
    assert residuals()[CASES[0]][CATEGORY]['Ident']['increments'] == 0
    assert independent[CASES[1]][CATEGORY]['Ident']['increments'] == 0
    control = check_control()
    assert control == read(HERE / 'control-result.json')

    note = REPO / 'docs/research/retained-why-callback-demand.md'
    links = 0
    for label, target in re.findall(r'\[([^\]]+)\]\(([^)]+)\)', note.read_text()):
        if not target.startswith(('http:', 'https:', '#')):
            assert (note.parent / target.split('#')[0]).resolve().exists(), (label, target)
            links += 1
    out = {'passed': True, 'input_files': len(manifest['files']),
           'source_witnesses': len(witnesses), 'source_archives': len(archive_paths),
           'status_cases': len(control['status_cases']), 'invalid_budgets_rejected': rejected,
           'process_vectors': len(result['cases']), 'local_links_checked': links,
           'elapsed_seconds': time.monotonic() - started,
           'source_simulation_machine_checked': False,
           'predecessor_checker_replays': 0, 'native_runs': 0, 'captures': 0,
           'solver_runs': 0, 'proof_runs': 0}
    (HERE / 'check-result.json').write_text(json.dumps(out, indent=2, sort_keys=True) + '\n')
    print(json.dumps(out, sort_keys=True))


if __name__ == '__main__':
    main()
