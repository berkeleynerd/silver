#!/usr/bin/env python3
"""Check retained identities and polynomial slack; execute no native tool."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent


def add(*polys):
    result = {}
    for p in polys:
        for term, coefficient in p.items():
            result[term] = result.get(term, 0) + coefficient
    return {t: c for t, c in result.items() if c}


def scale(k, p):
    return {t: k*c for t, c in p.items() if k*c}


def mul(p, q):
    result = {}
    for (a, b), c in p.items():
        for (x, y), d in q.items():
            term = a+x, b+y
            result[term] = result.get(term, 0) + c*d
    return {t: c for t, c in result.items() if c}


def square(p):
    return mul(p, p)


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['source_archive_sha256']
    with tarfile.open(archive) as source:
        for f in identity['files']:
            data = source.extractfile(f['path']).read()
            assert len(data) == f['bytes']
            assert hashlib.sha256(data).hexdigest() == f['sha256']

    # n1=a+1, n2=b+1, with a,b nonnegative. Compare polynomials exactly.
    one = {(0, 0): 1}
    n1, n2 = {(1, 0): 1, (0, 0): 1}, {(0, 1): 1, (0, 0): 1}
    n = add(one, n1, n2)
    one_flag = add(square(n1), square(n2), scale(4, n1))
    both_flags = add(one_flag, scale(2, add(n1, n2)))
    slack_one = add(square(n), scale(-1, one_flag))
    slack_both = add(scale(2, square(n)), scale(-1, both_flags))
    assert slack_one == {(1, 1): 2, (0, 1): 4, (0, 0): 3}
    assert slack_both == {(2, 0): 1, (0, 2): 1, (1, 1): 4,
                          (1, 0): 4, (0, 1): 8, (0, 0): 8}
    assert all(c >= 0 for p in [slack_one, slack_both] for c in p.values())

    # Unary quantifier replacement adds at most one count. n1>=1.
    unary = add(square(add(one, n1)), scale(-1, square(n1)), scale(-1, one))
    assert unary == scale(2, n1)
    # Disabled-mode binary recurrence uses at most two extra outputs.
    assert add(scale(2, n), scale(-2, add(n1, n2)), scale(-2, one)) == {}

    result = dict(
        source_files=len(identity['files']),
        first_split='q <= 2*n^2 under no-Tcase premise',
        each_output='E1(output) <= 3*E1(input)',
        terminal_goals='G(f) <= 6*n^2*E1(f)',
        one_flag_slack='2*a*b + 4*b + 3',
        both_flags_slack='a^2 + b^2 + 4*a*b + 4*a + 8*b + 8',
        native_executions=0,
        scope='Hashes and induction arithmetic only; source correspondence is a reviewed argument, whole source/VC and type frontier remain open')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
