#!/usr/bin/env python3
"""Verify cited source identity and arithmetic fixtures, not Why3 execution."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / 'retained-producer-main-types-20261018'
ARCHIVE_SHA256 = '194168fcfc9ebabae3702bb0782f49634d0c73eb808215482ae8a86823e57910'


def let(a, b):
    return 3 + a + a * b


def main():
    identity = json.loads((SOURCE / 'identity.json').read_text())
    archive = (SOURCE / 'sources.tar.gz').read_bytes()
    assert identity['source_archive_sha256'] == ARCHIVE_SHA256
    assert hashlib.sha256(archive).hexdigest() == ARCHIVE_SHA256
    with tarfile.open(fileobj=io.BytesIO(archive), mode='r:gz') as tar:
        entry = next(x for x in identity['files'] if x['path'] == 'why3/src/mlw/vc.ml')
        data = tar.extractfile(entry['path']).read()
    assert hashlib.sha256(data).hexdigest() == entry['sha256']
    source = data.decode()
    for snippet in (
        'let wrt_forall vl f = wrt_rename wp_forall vl f',
        'let wrt_exists vl f = wrt_rename sp_exists vl f',
        'if ity.ity_pure then regs else',
        'let fill o n regs = explore_paths kn aff regs (t_var n) o.pv_ity in',
        'let k = Mint.fold (fun i q k -> Kseq (k, i, Kstop q)) q k in',
    ):
        assert snippet in source
    # Finite illustrations of the displayed algebraic identities.
    # These are not a proof over all mathematical integers.
    for a in range(1, 12):
        for b in range(1, 12):
            assert let(a, b) - (1 + a + a*b) == 2
            assert let(a, b) - (3 + a + b) == (a-1)*b >= 0
            for h in range(6):
                costs = [2] + [j+3 for j in range(h)]
                expanded = sum(let(a, 1+b+c) for c in costs)
                closed = a*sum(costs) + (h+1)*(3+2*a+a*b)
                assert expanded == closed
    for h in range(6):
        wp1, wp2, sp0 = 5, 7, 11
        before1 = [13, 17]
        before2 = [j+19 for j in range(h)]
        safety = wp1 + sp0 + wp2 + 3
        after = sum(before1) + sum(sp0+s+2 for s in before2)
        w1 = wp1 + sp0 + sum(before1)
        w2 = wp2 + sum(before2)
        assert safety+after == w1+w2+h*sp0+3+2*h
    result = dict(
        source_archive_sha256=ARCHIVE_SHA256,
        vc_ml_sha256=entry['sha256'],
        native_executions=0,
        arithmetic_fixtures=['let closure', 'special let sequence',
                             'general sequence before outcome merging'],
        scope='Source identity and arithmetic fixtures only; typed-code inputs, shape-sensitive E1 join and whole-producer closure remain open')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
