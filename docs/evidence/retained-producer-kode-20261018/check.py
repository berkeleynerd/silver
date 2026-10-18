#!/usr/bin/env python3
"""Check pinned source and arithmetic only, without executing Why3."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / 'retained-producer-main-types-20261018'
ARCHIVE_SHA256 = '194168fcfc9ebabae3702bb0782f49634d0c73eb808215482ae8a86823e57910'


def main():
    identity = json.loads((SOURCE / 'identity.json').read_text())
    archive = (SOURCE / 'sources.tar.gz').read_bytes()
    assert hashlib.sha256(archive).hexdigest() == ARCHIVE_SHA256
    snippets = {
        'why3/src/mlw/vc.ml': (
            'let join _ _ _ = Some false in',
            'if i = 0 || cl then push k1 q else',
            'Kseq (push k1 q, i, Kcont 0)',
            'Ktag (tag, push k Mint.empty)',
            'let k = if vc_wp then k else Ktag (SP, k) in',
            'Kpar (k_fun env lps ~xmap ce.c_cty e, k)',
            'let cty_enrich_post c = match c with',
        ),
        'why3/plugins/gnat_json/gnat_ast_to_ptree.ml': (
            'let loop = E.mk_while true_expr invariants [] loop_body in',
            'E.mk_seq code_before loop)',
            'mk_fun [] None pat Ity.MaskVisible spec body)',
        ),
    }
    hashes = {}
    with tarfile.open(fileobj=io.BytesIO(archive), mode='r:gz') as tar:
        for path, expected in snippets.items():
            entry = next(x for x in identity['files'] if x['path'] == path)
            data = tar.extractfile(path).read()
            hashes[path] = hashlib.sha256(data).hexdigest()
            assert hashes[path] == entry['sha256']
            source = data.decode()
            assert all(s in source for s in expected)
    # Arithmetic illustrations, not executions or an exhaustive shape proof.
    for b in range(1, 80):
        for s in range(b+1):
            for t in range(b-s+1):
                assert b+2*s+t+2 <= 3*b+2
    reflow_examples = [dict(input=b, sequences=s, switches=t,
                            refined=b+2*s+t+2, coarse=3*b+2)
                       for b, s, t in [(1, 0, 0), (21, 10, 0),
                                       (33, 12, 4)]]
    result = dict(
        source_archive_sha256=ARCHIVE_SHA256,
        source_sha256=hashes,
        arithmetic_examples=reflow_examples,
        native_executions=0,
        scope='Pinned source and arithmetic only; no executable reflow model, typed-source extraction, full producer predicate or useful-domain claim')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
