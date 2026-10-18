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
SPARK_ARCHIVE_SHA256 = 'f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952'


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
    spark_path = HERE.parent / 'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    assert hashlib.sha256(spark_path.read_bytes()).hexdigest() == SPARK_ARCHIVE_SHA256
    spark_snippets = {
        'spark-source/src/why/gnat2why-expr-loops.adb': (
            'Final_Stmts.Move (Source => Initial_Stmts);',
            'Body_Prog : W_Statement_Sequence_Id := Void_Sequence;',
            'Inv_Check : W_Prog_Id := +Void;',
            'Code_Before => Loop_Before,',
            'Code_After  => Loop_After)',
        ),
        'spark-source/src/why/why-gen-progs.adb': (
            'if not Is_Void (E) then',
            '(Ada_Node => Empty, Statements => (1 .. 1 => +Void))',
        ),
    }
    with tarfile.open(spark_path) as tar:
        for path, expected in spark_snippets.items():
            data = tar.extractfile(path).read()
            hashes[path] = hashlib.sha256(data).hexdigest()
            assert all(s in data.decode() for s in expected)
    # Arithmetic illustrations, not executions or an exhaustive shape proof.
    for b in range(1, 80):
        for s in range(b+1):
            for t in range(b-s+1):
                assert b+2*s+t+2 <= 3*b+2
    for a in range(1, 50):
        for b in range(1, 3):
            assert a+2*b+10 <= a+14
    reflow_examples = [dict(input=b, sequences=s, switches=t,
                            refined=b+2*s+t+2, coarse=3*b+2)
                       for b, s, t in [(1, 0, 0), (21, 10, 0),
                                       (33, 12, 4)]]
    result = dict(
        source_archive_sha256=ARCHIVE_SHA256,
        spark_archive_sha256=SPARK_ARCHIVE_SHA256,
        source_sha256=hashes,
        arithmetic_examples=reflow_examples,
        ordinary_main_loop=dict(code_before_max=2, retained_overhead=14,
                                source_body_coefficient=1),
        native_executions=0,
        scope='Pinned source and arithmetic only; no executable reflow model, typed-source extraction, full producer predicate or useful-domain claim')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
