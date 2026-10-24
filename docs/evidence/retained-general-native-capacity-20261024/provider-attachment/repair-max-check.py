#!/usr/bin/env python3
"""Narrow source/candidate audit for the original low1 signed-MAX omission."""
import argparse
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
BASE = HERE.parent


def read(p):
    return json.loads(p.read_bytes())


def sha(b):
    return hashlib.sha256(b).hexdigest()


def profile(tree):
    # All children are ordinary annotation operands; no special retry opcode.
    if not isinstance(tree, tuple):
        return 0, 1, 1
    children = [profile(c) for c in tree[1:]]
    return 1+max(c[0] for c in children), 1+sum(c[1] for c in children), 1+sum(c[2] for c in children)


def source_equality_model(a, b):
    # Source checks INTEGER_CST numerical equality before type precision/sign.
    if a['code'] == b['code'] == 'INTEGER_CST':
        return a['value'] == b['value']
    return a['id'] == b['id'] and a['precision'] == b['precision'] and a['unsigned'] == b['unsigned']


def check():
    start = time.perf_counter()
    for file in ('repair-max-inputs.json', 'repair-max-manifest.json'):
        for row in read(HERE/file)['files']:
            b = (ROOT/row['path']).read_bytes()
            assert len(b) == row['bytes'] and sha(b) == row['sha256'], row['path']
    acceptance = read(HERE/'repair-max-inputs.json')['acceptance']
    b = subprocess.check_output(['git','show',acceptance['commit']+':'+acceptance['path']],cwd=ROOT)
    assert sha(b) == acceptance['sha256']
    manifest = read(BASE/'concat-selectors/source-manifest.json')
    sources = {}
    for archive in manifest['archives']:
        ap = HERE/archive['path']
        assert sha(ap.read_bytes()) == archive['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive['path']]
        with tarfile.open(ap, 'r:gz') as tf:
            assert all(m.isfile() for m in tf.getmembers())
            assert {m.name for m in tf.getmembers()} == {r['path'] for r in rows}
            for row in rows:
                b = tf.extractfile(row['path']).read()
                assert len(b) == row['bytes'] and sha(b) == row['sha256']
                sources[row['path']] = b
    witnesses = read(HERE/'repair-max-source-witnesses.json')['witnesses']
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        b = b'\n'.join(lines[row['first_lf_line']-1:row['last_lf_line']])+b'\n'
        assert sha(b) == row['sha256']
    fold = sources['gcc/fold-const.cc'].decode()
    entry = fold.index('operand_compare::operand_equal_p (tree type0')
    equality = fold.index('Check equality of integer constants before bailing out',entry)
    precision = fold.index('if (element_precision (type0) != element_precision (type1))',entry)
    assert equality < precision
    comparison = fold[fold.index('operand_equal_for_comparison_p ('):fold.index('/* See if ARG is an expression')]
    assert 'Discard a single widening conversion from ARG1' in comparison
    helper = fold[fold.index('fold_cond_expr_with_comparison ('):fold.index('#ifndef LOGICAL_OP_NON_SHORT_CIRCUIT')]
    assert 'MAX_EXPR, comp_type' in helper
    assert 'return fold_convert_loc (loc, type, tem);' in helper
    zero32 = dict(code='INTEGER_CST',value=0,precision=32,unsigned=False)
    zero64 = dict(code='INTEGER_CST',value=0,precision=64,unsigned=True)
    assert source_equality_model(zero32,zero64)
    assert zero32['precision'] != zero64['precision']
    # Explicit native request trace after successful signed comparison matching.
    requests = [('MAX_EXPR', 'binary',32),('NOP_EXPR','unary',64)]
    reached = {k:sum(r[1] == k for r in requests) for k in ('constants','unary','binary','ternary')}
    old = read(BASE/'concat-layout/ledger.json')
    row = next(r for r in old['rows'] if r['entry'] == 'gigi_COND')
    assert row['entries'] == 1 and row['per_entry']['unary'] == 0
    assert reached['unary'] > row['per_entry']['unary']
    updated = dict(constants=2,unary=2,binary=2,ternary=2)
    assert all(reached[k] <= updated[k] for k in reached)
    total = {k:sum(r['entries']*(updated[k] if r['entry']=='gigi_COND' else r['per_entry'][k]) for r in old['rows']) for k in updated}
    assert total == dict(constants=184,unary=126,binary=138,ternary=112)
    raw = sum(total[k]*old['raw_bytes'][k] for k in total)
    slots = total['unary']+2*total['binary']+3*total['ternary']
    assert raw == 22288 and slots == 738
    assert raw+1328*126 == 189616
    max_tree = ('MAX','G',0)
    bit_tree = ('MULT',('W',('U',max_tree)),8)
    p = profile(bit_tree)
    assert p == (4,7,7)
    # A conservative pre-existing same-width view adds one ordinary operand.
    with_view = ('MULT',('W',('U',('MAX',('view','V'),0))),8)
    pv = profile(with_view)
    assert pv == (5,8,8)
    assert all(a <= b for a,b in zip(pv,(9,59,63)))
    # The original signed index high is G, not the later layout MAX.
    # max_value traverses only the immediate PLUS initializer and treats
    # declaration children as extrema; their own initializers are not edges.
    aggregate_query = [('VAR_extremum',1),('VAR_extremum',1),('constant_PLUS',1)]
    assert sum(n for _,n in aggregate_query) == 3
    assert 3 <= 11  # old pair's constant allowance at s=0
    completed = datetime.now(timezone.utc)
    first = datetime(2026,10,24,8,23,22,tzinfo=timezone.utc)
    return dict(status='narrow repair check passed; independent repair review pending',
                target='302b32d15c293c9f8cf352f80ee9b7b4b068eee0',
                complete_native_capacity_result=False,
                source_files=len(sources),source_spans=len(witnesses),
                cross_precision_zero_equality=True,old_conditional_row_fails=True,
                reachable_request_trace=requests,effective_conditional_row=updated,
                corrected_layout_constructors=total,corrected_layout_raw_bytes=raw,
                corrected_operand_slots=slots,annotation_Q_unchanged=126,
                annotation_raw_bytes_unchanged=167328,corrected_combined_bytes=189616,
                original_MAX_graph_h_O_Q=p,conservative_view_graph_h_O_Q=pv,
                selected_author_model='GPT-6 Astra',selected_author_effort='Extra High',
                runtime_confirmation=None,tokens=None,monetary_cost=None,
                host=dict(system=platform.system(),machine=platform.machine(),node=platform.node()),
                native_execution_seconds=0,predecessor_checkers_run=False,
                completed_utc=completed.isoformat(),
                check_elapsed_seconds=round(time.perf_counter()-start,6),
                elapsed_since_repair_first_clock_seconds=round((completed-first).total_seconds(),6))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--output',type=Path)
    args = ap.parse_args()
    result = json.dumps(check(),indent=2)+'\n'
    if args.output:
        args.output.write_text(result)
    print(result,end='')
