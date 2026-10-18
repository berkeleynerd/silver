#!/usr/bin/env python3
"""Check cited source identity and arithmetic fixtures, not Why3 execution."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / 'retained-producer-main-types-20261018'


def size(t):
    return 1 + sum(size(c) for c in t[1:])


def main():
    identity = json.loads((SOURCE / 'identity.json').read_text())
    assert identity['source_archive_sha256'] == '194168fcfc9ebabae3702bb0782f49634d0c73eb808215482ae8a86823e57910'
    assert hashlib.sha256((SOURCE / 'sources.tar.gz').read_bytes()).hexdigest() == identity['source_archive_sha256']
    atom = lambda name: (name,)
    box = lambda name: ('Box', atom(name))
    eq = lambda a, b: ('eq', atom(a), atom(b))
    left = ('if', atom('p'), box('x'), box('y'))
    right = ('if', atom('q'), box('z'), box('w'))
    original = ('eq', left, right)
    distributed = ('if', atom('p'),
                   ('if', atom('q'), eq('x', 'z'), eq('x', 'w')),
                   ('if', atom('q'), eq('y', 'z'), eq('y', 'w')))
    assert (size(left), size(right), size(original), size(distributed)) == (6, 6, 13, 18)
    assert size(distributed) <= 3 * size(left) * size(right)
    assert size(distributed) > size(original)
    # With x=a+1,y=b+1, fallback slack is 3*a*b+2*a+2*b.
    # These values illustrate the exact identity; they do not prove it.
    for a in range(20):
        for b in range(20):
            x, y = a+1, b+1
            assert 3*x*y-(1+x+y) == 3*a*b+2*a+2*b >= 0
    result = dict(source_archive_sha256=identity['source_archive_sha256'],
                  equality_fixture=dict(input=13, distributed=18, envelope=108),
                  quantifier_profiles=dict(unit=dict(weight=1, overhead=2),
                                           flat_ref=dict(weight=2, overhead=3)),
                  native_executions=0,
                  scope='Arithmetic illustration and source archive identity only; source-to-SP/WP, E1 and whole-process allocation joins remain open')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
