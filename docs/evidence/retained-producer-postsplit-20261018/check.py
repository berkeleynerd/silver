#!/usr/bin/env python3
"""Source identities and symbolic cost examples, without native execution."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent


def occurrences(t):
    if t[0] == 'var':
        return 1
    if t[0] == 'let':
        return 1 + occurrences(t[2]) + occurrences(t[3])
    return 1 + sum(map(occurrences, t[2:]))


def envelope(t, weights=None, definitions=None):
    """E0 with definitions=None; E1 otherwise. This is an arithmetic fixture.

    Only variable, let and generic application forms are needed by the
    examples; the record states the full binder/trigger accounting rule.
    """
    weights = {} if weights is None else weights
    if t[0] == 'var':
        return weights.get(t[1], 1)
    if t[0] == 'let':
        value = envelope(t[2], weights, definitions)
        return 1 + value + envelope(t[3], weights | {t[1]: value}, definitions)
    actuals = [envelope(a, weights, definitions) for a in t[2:]]
    unchanged = 1 + sum(actuals)
    if definitions is None or t[1] not in definitions:
        return unchanged
    formals, body = definitions[t[1]]
    assert len(formals) == len(actuals)
    substituted = weights | dict(zip(formals, actuals))
    return max(unchanged, envelope(body, substituted))


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['source_archive_sha256']
    with tarfile.open(archive) as source:
        for f in identity['files']:
            data = source.extractfile(f['path']).read()
            assert len(data) == f['bytes']
            assert hashlib.sha256(data).hexdigest() == f['sha256']

    atom = ('app', 'a')
    large = ('app', 'many', *([atom] * 99))
    definition = ('app', 'of_array', large, atom, atom)
    original = ('let', 'x', definition,
                ('app', 'and', ('app', 'to_array', ('var', 'x')),
                 ('app', 'to_array', ('var', 'x'))))
    rewritten = ('let', 'x', definition, ('app', 'and', large, large))
    assert (occurrences(original), occurrences(rewritten), envelope(original)) == (109, 305, 313)
    assert envelope(rewritten) <= envelope(original)

    definitions = {'f': (['x'], ('app', 'and', ('var', 'x'), ('var', 'x')))}
    nested = ('app', 'f', ('app', 'f', atom))
    unfolded = ('app', 'and', ('app', 'and', atom, atom), ('app', 'and', atom, atom))
    assert occurrences(nested) == 3
    assert occurrences(unfolded) == envelope(nested, definitions=definitions) == 7
    # The max arm is necessary when actual traversal skips an application.
    shrinking = {'f': (['x'], ('var', 'x'))}
    skipped = ('app', 'not', ('app', 'f', atom))
    assert envelope(skipped, definitions=shrinking) >= occurrences(skipped)

    result = dict(
        conversion_example=dict(before=109, after=305, lexical_envelope=313),
        nested_marked_example=dict(before=3, after=7, unfolding_envelope=7),
        native_executions=0,
        scope='Identity/arithmetic fixtures; semantic argument is source-reviewed, source-to-VC/first-split join remains open')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
