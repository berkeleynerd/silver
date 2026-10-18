#!/usr/bin/env python3
"""Check source identity and formula-interface arithmetic; execute no Why3."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent


def skeleton(t):
    kind, *children = t
    if kind in ('atom', 'true', 'false'):
        return 1
    if kind in ('let', 'forall', 'exists'):
        return 1+skeleton(children[-1])
    return 1+sum(skeleton(child) for child in children)


def main():
    manifest = json.loads((HERE/'identity.json').read_text())
    archive = HERE/'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == manifest['source_archive_sha256']
    with tarfile.open(archive) as tar:
        sources = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
    assert set(sources) == {row['path'] for row in manifest['files']}
    for row in manifest['files']:
        data = sources[row['path']]
        assert len(data) == row['bytes']
        assert hashlib.sha256(data).hexdigest() == row['sha256']
    decl = sources['src/core/decl.ml'].decode()
    matcher = sources['src/mlw/eval_match.ml'].decode()
    split = sources['src/transform/split_goal.ml'].decode()
    assert 'let ldl = check_termination ldl in' in decl
    assert 'if res = [] then raise exn;' in decl
    assert 'Mvs.add v (Equal !i)' in decl
    assert '| Equal i -> Array.get v2 i' in decl
    assert '| Tapp (_, [{t_node = Tvar _}]) -> Some res' in matcher
    assert 'with Exit -> t_equ t1 t2' in matcher
    assert '| Tapp _ -> let uf = !+f in ret uf uf f f Unit false false' in split
    # Argument/definition/trigger sizes do not belong to the splitter skeleton.
    atom = ('atom', 10000)
    assert skeleton(atom) == 1
    assert skeleton(('forall', 10000, atom)) == 2
    assert skeleton(('let', 10000, atom)) == 2
    tree = atom
    for _ in range(127):
        tree = ('and', atom, tree)
    assert skeleton(tree) == 255
    # Main refinements preserve the already checked four-mode arithmetic.
    for s1 in range(1, 24):
        for s2 in range(1, 24):
            s = 1+s1+s2
            assert s1*s1+s2*s2+4*s1 <= s*s
            assert s1*s1+s2*s2+4*s1+2*max(s1, s2) <= 2*s*s
    range_checks, ordinary_checks = 64, 64
    goals = 2*range_checks+ordinary_checks
    records = range_checks+ordinary_checks
    projected_bytes = 212+3732*records+2601*goals
    assert (goals, records, projected_bytes) == (192, 128, 977300)
    result = dict(
        source_archive_sha256=manifest['source_archive_sha256'],
        native_executions=0,
        skeleton_fixtures=dict(large_argument_atom=1, quantified_atom=2,
                               let_atom=2, conjunction_128_atoms=255),
        check_formula_fixture=dict(range_checks=range_checks,
            ordinary_checks=ordinary_checks, terminal_goal_bound=goals,
            assumed_result_record_bound=records, warning_count=0,
            proposed_projected_response_bytes=projected_bytes),
        scope='Source identities and formula-interface arithmetic only; no source-to-formula or complete new admission-predicate claim')
    (HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
