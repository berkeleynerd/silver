#!/usr/bin/env python3
"""Finite lexical lemma, not a model of the complete output/control trace.

No native programs, previous checkers, compiler or prover are executed.
The caller must separately establish the token-loss and writer premises.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
TARGET = "entity"
LOSS_LIMIT = 3


def advance(state: int, text: str) -> int:
    for char in text:
        word = TARGET[:state] + char
        if TARGET in word:
            return len(TARGET)
        state = max(i for i in range(len(TARGET)) if word.endswith(TARGET[:i]))
    return state


def string_tokens(text: str) -> list[str]:
    escapes = {'"': '\\"', '\\': '\\\\', '\n': '\\n'}
    assert all(32 <= ord(c) <= 126 or c == '\n' for c in text)
    return ['"'] + [escapes.get(c, c) for c in text] + ['"']


def abort_tokens(payload: str) -> list[str]:
    # Json_base.print_json sorts these keys. Layout whitespace is erased;
    # this strengthens the raw-word exclusion but is not a JSON parser model.
    return (['{'] + string_tokens('error') + [':'] + string_tokens(payload)
            + [','] + string_tokens('internal') + [':', 'true', ',']
            + string_tokens('results') + [':', '[', ']', '}'])


def extend(states: set[tuple[int, int]], tokens: list[str], *, allow_losses=True):
    """All prefixes with <=3 token suffix losses (including whole tokens).

    A lost token can keep any proper byte prefix, consuming one loss. Other
    tokens remain intact. Stopping the list at any token boundary is free:
    this overapproximates abandoning unexecuted serializer calls.
    """
    prefixes = set(states)
    for token in tokens:
        following = set()
        for state, losses in states:
            candidates = [(token, losses)]
            if allow_losses and losses < LOSS_LIMIT:
                candidates += [(token[:n], losses + 1) for n in range(len(token))]
            for emitted, count in candidates:
                nxt = advance(state, emitted)
                assert nxt != len(TARGET), (state, losses, token, emitted)
                following.add((nxt, count))
        states = following
        prefixes.update(states)
    return prefixes


def main():
    started = time.monotonic()
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    archives = {}
    try:
        for row in witnesses:
            archive = row['archive']
            if archive not in archives:
                archives[archive] = tarfile.open(ROOT / archive)
            raw_source = archives[archive].extractfile(row['member']).read()
            assert len(raw_source) == row['bytes']
            assert hashlib.sha256(raw_source).hexdigest() == row['sha256']
            lines = raw_source.decode().splitlines()
            for excerpt in row['excerpts']:
                assert '\n'.join(lines[excerpt['first']-1:excerpt['last']]) == excerpt['text']
    finally:
        for archive in archives.values():
            archive.close()
    path = ROOT / 'docs/evidence/retained-adapter-launch-output-20261020/result.json'
    raw = path.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == \
        'a01adc08a4f0beeee3d110827e79d2cbce2e9837215f95c8de850c8de4d6efff'
    rows = json.loads(raw)['errno_strings']
    errors = [row['text'] for row in rows if row['text'] is not None]
    assert len(errors) == 132
    assert all(not set(s) & set('"\\{}[]\n\r\t') for s in errors)
    assert [s for s in errors if not s[0].isupper()] == ['.lib section in a.out corrupted']

    # Digits/minus are self loops to state 0 in the target automaton. Keeping
    # one-to-eleven '#' characters is an abstraction of every signed-int32
    # unknown-error suffix, including zero; not a sampling of one errno.
    assert all(advance(s, c) == 0 for s in range(len(TARGET)) for c in '-0123456789#')
    errors += ['Unknown error'] + ['Unknown error ' + '#' * n for n in range(1, 12)]
    scalar = ['anomaly: Sys_error("' + e + '")' for e in errors]
    scalar += ['anomaly: Sys_blocked_io']
    missing_debug = '(Program not linked with -g, cannot print stack backtrace)\n'
    payloads = [s + '.\n' for s in scalar]
    payloads += [s + '\nBacktrace is the following:\n' + bt + '\n'
                 for s in scalar for bt in ('', missing_debug)]
    # Include every unfinished spelling at the normal-prefix seam, not just
    # a clean start. A full previous "entity" word is handled by the separate
    # delimiter/type argument in the note.
    states = {(n, 0) for n in range(len(TARGET))}
    stage_counts = []
    for _ in range(2):
        states = set().union(*(extend(states, abort_tokens(s)) for s in payloads))
        stage_counts.append(len(states))
    # Raw terminal stderr does not resume after its first ordinary exception.
    # Allow prefixes of both fallback lines anyway, an overapproximation.
    default_scalars = [s.removeprefix('anomaly: ') for s in scalar]
    for prefix in ('Fatal error: exception ',
                   'Fatal error in uncaught exception handler: exception '):
        states = set().union(*(extend(states, list(prefix + s + '\n' + bt),
                                     allow_losses=False)
                              for s in default_scalars
                              for bt in ('', missing_debug)))

    # A suffix begins with the first surviving one of {, quote, e, r: losing
    # <=3 prefix character tokens cannot expose a numeric delimiter or 'y'.
    first = '{"er'
    assert not set(first) & set(',:}]-0123456789ynti')
    result = {
        'status': 'pass', 'scope': 'two-abort raw-word exclusion only',
        'complete_response_provenance': False,
        'errno_strings': 132, 'payload_templates': len(payloads),
        'source_files': len(witnesses), 'partial_key_seams': len(TARGET),
        'max_token_suffix_losses': LOSS_LIMIT,
        'reachable_states_after_each_abort': stage_counts,
        'reachable_states_after_raw_fallback': len(states),
        'seconds': time.monotonic() - started,
        'retained_libc_result_sha256': hashlib.sha256(raw).hexdigest(),
    }
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
