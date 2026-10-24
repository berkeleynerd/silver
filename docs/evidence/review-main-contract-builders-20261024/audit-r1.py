#!/usr/bin/env python3
"""Narrow independent R1 audit; no author/predecessor checker imports or runs.

The finite diagrams challenge the implementation. The source-order argument
and exact AST permutation, recorded in the review, justify the general delta.
"""
import ast
from collections import Counter
import hashlib
import importlib.util
import itertools
import json
from pathlib import Path
import platform
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT/'docs/evidence/retained-main-construction-demand-20261024/contract-builders'
ORIGINAL = '49c18b7ef37967c8b6f486721fd006d61857a8fb'
REPAIR = '93fdabb2232e0fc7fe2fd7c39f167c1985991f5a'
REVIEW = '7fe4a33a75b5ed9346ca5cff4f72b14aa8bcf511'
COUNTS = Counter()


def check(ok, family):
    assert ok, family
    COUNTS[family] += 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def frozen(commit, path):
    rel = str(path.relative_to(ROOT))
    return subprocess.check_output(['git', 'show', commit+':'+rel], cwd=ROOT)


def identities():
    inputs, preserved = {}, {}
    for p in sorted(PACKET.iterdir()) + [ROOT/'docs/research/retained-main-construction-demand.md']:
        if not p.is_file():
            continue
        data = p.read_bytes()
        check(data == frozen(REPAIR, p), 'exact repaired author freeze')
        inputs[str(p.relative_to(ROOT))] = sha(data)
    for name in ('exports.json', 'sites.json', 'sites.py', 'identity.json', 'result.json', 'round.json'):
        p = PACKET/name
        check(p.read_bytes() == frozen(ORIGINAL, p), 'original author evidence preserved')
        preserved[str(p.relative_to(ROOT))] = sha(p.read_bytes())
    for name in ('audit.py', 'audit-result.json', 'receipt.json'):
        p = HERE/name
        check(p.read_bytes() == frozen(REVIEW, p), 'original review evidence preserved')
        preserved[str(p.relative_to(ROOT))] = sha(p.read_bytes())
    exports = json.loads((PACKET/'exports.json').read_text())
    check(len(exports) == 10, 'ten original exports retained')
    manifest = json.loads((PACKET/'identity.json').read_text())
    for row in manifest['providers']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'accepted provider identity retained')
    for row in manifest['archives']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'accepted archive identity retained')
    relevant = {'src/mlw/ity.ml': (1436, 1489),
                'src/mlw/dexpr.ml': (1486, 1489),
                'src/mlw/expr.ml': (841, 844)}
    sources, spans = {}, {}
    archive = manifest['archives'][0]
    with tarfile.open(ROOT/archive['path']) as tar:
        for row in archive['files']:
            if row['path'] not in relevant:
                continue
            data = tar.extractfile(row['path']).read()
            check(sha(data) == row['sha256'], 'relevant complete source identity')
            first, last = relevant[row['path']]
            lines = data.decode().splitlines()
            span = '\n'.join(lines[first-1:last])+'\n'
            sources[row['path']] = span
            spans[row['path']] = {'first': first, 'last': last,
                                  'complete_sha256': sha(data), 'span_sha256': sha(span.encode()),
                                  'text': span}
    check('apply gh same (match_v isb u v) (vsb_add vsb u v) ul vl' in sources['src/mlw/ity.ml'],
          'unordered current match and add source anchor')
    check('if vs_equal u v.pv_vs then vsb else Mvs.add u v vsb' in sources['src/mlw/ity.ml'],
          'source identity pair has no map add')
    check('let vsb = Mvs.map (fun v -> t_var v.pv_vs) vsb in' in sources['src/mlw/ity.ml'],
          'term map follows completed apply')
    check('try Expr.c_app s vl al res :: cl with' in sources['src/mlw/dexpr.ml']
          and '| TypeMismatch _ -> cl' in sources['src/mlw/dexpr.ml'],
          'candidate mismatch catch retains failed construction relevance')
    check('let cty = cty_apply s.rs_cty vl ityl ity in' in sources['src/mlw/expr.ml']
          and 'mk_cexp (Capp (s,vl)) cty' in sources['src/mlw/expr.ml'],
          'wrapper construction follows completed cty_apply')
    return inputs, preserved, spans, list(exports)


def exact_delta():
    old = ast.parse(frozen(ORIGINAL, PACKET/'builders.py'))
    new = ast.parse((PACKET/'builders.py').read_text())
    function = next(x for x in new.body if isinstance(x, ast.FunctionDef) and x.name == 'apply_same')
    loop = next(x for x in function.body if isinstance(x, ast.For))
    check(len(loop.body) == 5, 'only five pair statements in repaired fold')
    # Restore the old order; all other executable syntax must be identical.
    loop.body[2:] = [loop.body[3], loop.body[4], loop.body[2]]
    check(ast.dump(new) == ast.dump(old), 'entire builder AST differs only by current-add permutation')


def diagrams():
    spec = importlib.util.spec_from_file_location('r1_reviewed_builders', PACKET/'builders.py')
    c = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = c
    spec.loader.exec_module(c)
    INT, BOOL = c.Ty('int'), c.Ty('bool')
    repair_exports = json.loads((PACKET/'exports-r1.json').read_text())
    cases = []
    for n in range(1, 5):
        formals = tuple(c.PV(c.k.Var(i+1, INT)) for i in range(n))
        for failure in range(n):
            for identities in itertools.product((False, True), repeat=failure):
                for alias in (False, True):
                    actuals = tuple(formals[i] if i < failure and identities[i]
                                    else c.PV(c.k.Var(900+i if i == failure else 100 if alias else 100+i,
                                                     BOOL if i == failure else INT))
                                    for i in range(n))
                    expected = [('formal_actual_add', i, 1)
                                for i in range(sum(not x for x in identities)+1)]
                    d = c.Demand(10000, 20000, 30000)
                    try:
                        c.c_app(c.Contract(formals, (), (), c.Effect(), INT), actuals, INT, d,
                                constructor_one=True)
                    except c.SourceFailure as exc:
                        check(str(exc) == 'TypeMismatch', 'fails at first mismatching pair')
                    else:
                        raise AssertionError('expected first argument mismatch')
                    check(d.map_events == expected, 'current nonidentity add plus exact earlier nonidentity prefix')
                    check(d.calls == Counter(c_app=1, cty_apply=1, apply_pair=failure+1, ity_match=failure+1),
                          'no later pair or downstream call')
                    check(d.records == Counter(exception_candidate=1), 'no term-map Tvar contract or wrapper records')
                    check(not d.owner_requests and not d.kernel.ident_increments and not d.memo_reads,
                          'failure leaves owners and tuple lookup untouched')
                    expected_bytes = sum(4096*(i+2)**3 for i in range(len(expected)))
                    check(d.kernel.map_bytes_upper == expected_bytes and d.kernel.local_bytes_upper == 0,
                          'accepted Extmap subtotal includes failing pair')
                    # A match-first failure can omit the last add. It cannot
                    # consume later pairs or exceed this add-first envelope.
                    match_first = sum(4096*(i+2)**3 for i in range(len(expected)-1))
                    check(expected_bytes >= match_first, 'either argument order bounded')
                    exported = json.loads(json.dumps(d.export()))
                    check(exported['owner_endpoints_upper'] == {'Ident': 10000, 'Hsty': 20000, 'Hsity': 30000},
                          'incoming owner endpoints preserved')
                    check(not exported['new_helper_native_bytes_complete']
                          and not exported['shared_hashcons_backing_bytes_complete']
                          and not exported['complete_main_builder_classification'], 'incomplete joins remain explicit')
                    if not alias and n == 1:
                        check(exported == repair_exports['failed_first_argument'], 'independent first diagram equals repair export')
                    if not alias and n == 3 and failure == 1 and identities == (False,):
                        check(exported == repair_exports['failed_later_argument'], 'independent later diagram equals repair export')
                    cases.append({'arity': n, 'failure_pair': failure+1, 'earlier_identity_pairs': identities,
                                  'aliased_nonidentity_actuals': alias, 'map_adds': len(expected), 'map_bytes_upper': expected_bytes})
    # A caller catches two failures and then selects a successful candidate.
    # Each candidate starts a fresh substitution map while spent demand adds.
    d = c.Demand(10000, 20000, 30000)
    formal = c.PV(c.k.Var(501, INT))
    for actual in (c.PV(c.k.Var(601, BOOL)), c.PV(c.k.Var(602, BOOL))):
        try:
            c.c_app(c.Contract((formal,), (), (), c.Effect(), INT), (actual,), INT, d)
        except c.SourceFailure:
            pass
        else:
            raise AssertionError('candidate must fail')
    check(d.map_events == [('formal_actual_add', 0, 1)]*2 and d.kernel.map_bytes_upper == 65536,
          'two caught candidates retain both spent map requests')
    before = d.kernel.map_bytes_upper
    c.c_app(c.Contract((formal,), (), (), c.Effect(), INT), (c.PV(c.k.Var(603, INT)),), INT, d)
    check([x for x in d.map_events if x[0] == 'formal_actual_add'] == [('formal_actual_add', 0, 1)]*3,
          'selected call starts fresh substitution while preserving previous candidates')
    check(d.kernel.map_bytes_upper > before and d.records['exception_candidate'] == 2
          and d.records['actual_tvar'] == 1 and d.records['cty'] == 1 and d.records['cexp'] == 1,
          'only selected candidate performs term map and completion')
    check(not d.owner_requests and not d.kernel.ident_increments, 'sequence has no added owner requests')
    return cases, json.loads(json.dumps(d.export()))


def main():
    start = time.monotonic()
    inputs, preserved, spans, exports = identities()
    exact_delta()
    cases, sequence = diagrams()
    result = {'status': 'pass', 'assertions': sum(COUNTS.values()), 'families': dict(COUNTS),
              'elapsed_seconds': time.monotonic()-start, 'host': platform.platform(),
              'original_author_commit': ORIGINAL, 'repair_author_commit': REPAIR,
              'original_review_commit': REVIEW, 'review_input_head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip(),
              'repair_input_sha256': inputs, 'preserved_evidence_sha256': preserved,
              'source_spans': spans, 'original_exports_retained': exports,
              'failure_diagrams': cases, 'candidate_sequence': sequence,
              'audit_script_sha256': sha(Path(__file__).read_bytes()),
              'native_runs': 0, 'author_checker_runs': 0, 'predecessor_checker_runs': 0,
              'original_independent_audit_runs': 0, 'whole_source_to_vc_storage': False,
              'complete_native_bytes': False, 'complete_main_builder_classification': False}
    (HERE/'audit-r1-result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('status', 'assertions', 'elapsed_seconds', 'host')}))


if __name__ == '__main__':
    main()
