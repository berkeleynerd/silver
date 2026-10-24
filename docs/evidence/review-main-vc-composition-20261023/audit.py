#!/usr/bin/env python3
"""Independent changed-seam audit. No native tool or predecessor checker runs."""
import argparse
from collections import Counter
from dataclasses import replace
from datetime import datetime, timezone
import hashlib
import importlib.util
import itertools
import json
from pathlib import Path
import platform
import random
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
COUNTS = Counter()


def check(ok, family):
    if not ok:
        raise AssertionError(family)
    COUNTS[family] += 1


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--target-root', type=Path, required=True)
    parser.add_argument('--commit', required=True)
    parser.add_argument('--write', type=Path)
    args = parser.parse_args()
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    root = args.target_root.resolve()
    rel = Path('docs/evidence/retained-main-vc-composition-20261023')
    packet = root / rel
    target = subprocess.check_output(['git', 'rev-parse', args.commit], cwd=root, text=True).strip()
    inputs = {}
    for path in [Path('docs/research/retained-main-vc-composition.md'),
                 *(rel / name for name in ('model.py', 'check.py', 'identity.json',
                                           'result.json', 'README.md', 'round.json'))]:
        raw = (root / path).read_bytes()
        frozen = subprocess.check_output(['git', 'show', target + ':' + str(path)], cwd=root)
        check(raw == frozen, 'exact author freeze bytes')
        inputs[str(path)] = digest(raw)
    manifest = json.loads((packet / 'identity.json').read_text())
    receipt = json.loads((packet / 'result.json').read_text())
    for name, key in [('model.py', 'model_sha256'), ('check.py', 'checker_sha256'),
                      ('identity.json', 'identity_sha256')]:
        check(receipt[key] == digest((packet / name).read_bytes()), 'author receipt attachment')

    # Read only the sources used for the new edges; do not import any accepted
    # provider checker, source-profile generator, native tool or compiler.
    selected = {'vc.ml', 'eval_match.ml', 'task.ml', 'pmodule.ml', 'pdecl.ml',
                'dexpr.ml', 'expr.ml', 'typing.ml', 'gnat_split_conj.ml',
                'gnat_ast_to_ptree.ml', 'theory.ml'}
    sources = {}
    identities = {}
    for archive in manifest['archives']:
        rows = [r for r in archive['selected_files'] if Path(r['path']).name in selected]
        if not rows:
            continue
        archive_path = root / archive['path']
        check(digest(archive_path.read_bytes()) == archive['sha256'], 'source archive identity')
        with tarfile.open(archive_path) as tar:
            for row in rows:
                raw = tar.extractfile(row['path']).read()
                check(digest(raw) == row['sha256'] and len(raw) == row['bytes'],
                      'complete changed-seam source identity')
                sources[Path(row['path']).name] = raw.decode()
                identities[archive['path'] + ':' + row['path']] = digest(raw)
    guards = {
        'task.ml': ['task_fold fn (fn acc task.task_decl) task.task_prev',
                    'Dprop (Plemma,pr,f) } -> add_prop_decl task Paxiom pr f',
                    'Dprop (Pgoal,_,_) } -> task'],
        'pmodule.ml': ['let dl = if vc then mk_vc uc d else []',
                       'add_pdecl_raw ~warn (List.fold_left add uc dl) d',
                       '| Uuse m -> use_export uc m'],
        'eval_match.ml': ['let find_inlineable kn ls = match ls.ls_args with',
                          '[arg] when destructible kn arg <> None',
                          't_ty_subst (oty_match mt e.t_ty ty) mv e'],
        'gnat_split_conj.ml': [
            '| Tquant (_, tb) -> let _,_,f = t_open_quant tb in has_pretty_labels f',
            '| Tapp (ls, []) when ls_equal ls fs_bool_true -> true',
            'let env = task_fold fold Mls.empty task'],
        'vc.ml': ['let f = wp_forall (Mvs.keys (t_freevars Mvs.empty f)) f',
                  'let f = simp_cast_projections env f',
                  'let f = if t_closed f then f else',
                  'List.fold_left unwind f st',
                  'Kpar (k_fun env lps ~xmap ce.c_cty e, k)'],
        'dexpr.ml': ['| (RKfunc | RKpred), ([], _) ->',
                     'let c = c_fun [] [] [] Mxs.empty Mpv.empty e in'],
        'pdecl.ml': ['begin match term_of_expr ~prop:(ls.ls_value = None) e with',
                    '| None when cty.cty_post = [] ->',
                    'try [create_logic_decl dl] with Decl.NoTerminationProof _ ->'],
    }
    for name, needles in guards.items():
        for needle in needles:
            check(needle in sources[name], 'independently selected source guard')

    spec = importlib.util.spec_from_file_location('reviewed_main_vc_model', packet / 'model.py')
    m = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = m
    spec.loader.exec_module(m)

    # A source-ordered prefix must select its first eligible entry, independently
    # of whether that entry is a Dlogic or an oriented quantified axiom.
    syms = {'f': m.Symbol('f', ('int',), 'int', ('GP_Inline',))}
    x = m.var('x')
    bodies = [m.app('body' + str(i), x, ty='int', attrs=('GP_Pretty_Ada:test',))
              for i in range(3)]
    for order in itertools.permutations(range(3)):
        for mask in range(8):
            entries = []
            for i in order:
                body = bodies[i]
                entries.append(m.Logic('f', ('x',), body) if mask & (1 << i) else
                    m.Axiom(m.node('forall', m.app('=', m.app('f', x, ty='int'), body), key='x')))
            check(m.marked_map(entries, syms)['f'][1] == bodies[order[0]],
                  'earliest accepted source entry wins across constructor kinds')
    hidden = m.node('forall', m.app('plain', x), bodies[0], key='x')
    check(not m.pretty(hidden), 'trigger-only pretty label ignored')
    check(m.pretty(replace(hidden, attrs=('GP_Pretty_Ada:root',))),
          'quantifier-root pretty label retained')
    check(m.pretty(m.node('forall', m.app('labelled-predicate', x,
          attrs=('GP_Pretty_Ada:body',)), m.app('plain-trigger', x, ty='int'), key='x')),
          'quantifier-body pretty label retained')
    check(not m.pretty(m.app('outer', bodies[0])), 'application-actual pretty label ignored')
    for attrs in [(), ('location:one',), ('GP_Pretty_Ada:true', 'annot:keep')]:
        bool_symbols = {'bf': m.Symbol('bf', ('int',), 'bool', ('GP_Inline',))}
        rhs = m.app('predicate', x, attrs=('GP_Pretty_Ada:predicate',))
        eq = m.app('=', m.app('bf', x, ty='bool'), replace(m.BTRUE, attrs=attrs))
        ax = m.Axiom(m.node('forall', m.node('iff', eq, rhs), key='x'))
        check(m.marked_map([ax], bool_symbols)['bf'][1].op == 'if',
              'annotated Boolean True uses Boolean wrapper')
    first = m.Logic('f', ('x',), bodies[0])
    later = m.Logic('f', ('x',), bodies[1])
    imported_lemma = m.Axiom(m.app('imported-lemma'), kind='lemma')
    imported_goal = m.Axiom(m.app('imported-goal'), kind='goal')
    local_lemma = m.Axiom(m.app('local-lemma'), kind='lemma')
    modules = {'a': [first, imported_lemma, imported_goal],
               'b': [m.Use('a')]}
    goals, prefix, used = m.task_prefixes(
        [m.Use('b'), m.Use('a'), local_lemma,
         m.Axiom(m.app('Main'), kind='goal'), later], modules)
    check(len(goals) == 2 and used == {'a', 'b'},
          'imports deduplicate and imported goals create no local candidate')
    check(len(goals[0][0]) == 2 and len(goals[1][0]) == 3,
          'local lemma becomes axiom only after its own goal snapshot')
    check(all(not isinstance(d, m.Axiom) or d.kind == 'axiom' for d in prefix),
          'flattened prefix has no lemma or goal declarations')
    check(later not in goals[1][0] and m.marked_map(goals[1][0], syms)['f'][1] == bodies[0],
          'goal prefix excludes later declaration updates')
    for weights in [(3, 17), (17, 3), (1, 50), (50, 1)]:
        body = m.app('plus', x, x, ty='int')
        expected = max(1 + sum(weights), 1 + 2 * weights[-1])
        check(m.application_cost('repeat', weights, {'repeat': (('x', 'x'), body)}) == expected,
              'duplicate formal has actual last-write cost')

    # Declared Tyvar arguments remain ineligible even if an occurrence would
    # instantiate them with Unit. Reference aliases stop at named projections.
    alias_syms = {
        'poly': m.Symbol('poly', ("'a",), "'a"),
        'u': m.Symbol('u', ('unit',), 'int'),
        'r': m.Symbol('r', ('ref',), 'int'),
        'field': m.Symbol('field', ('ref',), 'int', projection=True),
    }
    known = {'poly': m.Logic('poly', ('x',), m.var('x', "'a")),
             'u': m.Logic('u', ('x',), m.Term('const', key='1', ty='int')),
             'r': m.Logic('r', ('x',), m.app('field', m.var('x', 'ref'), ty='int'))}
    aliases, reached = m.alias_map({'poly', 'u', 'r'}, alias_syms, known, {'unit', 'ref'})
    check(set(aliases) == {'u', 'r'} and 'field' in reached,
          'declared-type eligibility and projection termination')

    # Independent term evaluation checks each extracted output under the saved
    # lexical definitions, including values used only by the predicate.
    def evaluate(t, env):
        if t.op == 'var':
            return env[t.key]
        if t.op == 'let':
            return evaluate(t.args[1], env | {t.key: evaluate(t.args[0], env)})
        if t.op == 'true':
            return True
        if t.op == 'app':
            vals = [evaluate(a, env) for a in t.args]
            if t.key == 'plus':
                return sum(vals)
            if t.key == 'lt':
                return vals[0] < vals[1]
        raise AssertionError('outside independent term evaluator')

    for length in range(1, 10):
        defs = []
        previous = m.var('input')
        for i in range(length):
            key = 'v' + str(i)
            definition = m.app('plus', previous, previous, ty='int')
            defs.append((key, definition))
            previous = m.var(key)
        code = m.k('let', key='result', terms=(previous, m.app('lt', previous, m.var('limit'))))
        for key, definition in reversed(defs):
            code = m.k('seq', m.k('let', key=key, terms=(definition, m.TRUE)), code, key=0)
        value, predicate, residual = m.term_of_kode(code, 'result')
        check(m.free(value) == {'input'} and m.free(predicate) == {'input', 'limit'},
              'both output scopes close every saved definition')
        for inp in (-3, 0, 5):
            for limit in (-10, 0, 1000):
                env = {'input': inp, 'limit': limit}
                expected = inp * 2 ** length
                check(evaluate(value, env) == expected and
                      evaluate(predicate, env) == (expected < limit),
                      'both extracted outputs preserve lexical meaning')
        check(m.attached(residual) == Counter(t for _, t in defs) + Counter({m.TRUE: length}),
              'saved definitions retain original residual occurrences')

    # The new nullary wrapper family has its own candidate formula, irrespective
    # of whether native simplification later discards it as a trivial VC.
    for definition in (None, m.app('source-initializer', x, ty='int')):
        for trace in (False, True):
            result = (m.k('val', key=('result',), terms=(m.TRUE,)) if definition is None else
                      m.k('let', key='result', terms=(definition, m.TRUE)))
            if trace:
                result = m.k('seq', result,
                    m.k('let', key='trace', terms=(m.var('result'), m.TRUE)), key=0)
            wrapper = m.k('seq', m.k('val', key=(), terms=(m.TRUE,)),
                m.k('seq', result, m.k('stop', terms=(m.TRUE,)), key=0), key=0)
            check(m.ksize(wrapper) <= 7 and m.ksize(m.reflow(wrapper, False)) <= 23,
                  'nullary helper candidate has separate bounded kode')
            candidate = m.wp_core(wrapper, {})
            check(m.free(candidate) == (set() if definition is None else {'x'}),
                  'nullary helper candidate carries exactly its initializer free variables')

    # Symbolic traces are independent of the model's outcome-map implementation.
    # This is a focused reflow routing check, not a full SP/WP semantics proof.
    def traces(code):
        if code.op == 'cont':
            return {(code.key, ())}
        if code.op in {'let', 'val', 'cut', 'stop'}:
            return {(None if code.op == 'stop' else 0, tuple(t.key for t in code.terms))}
        if code.op in {'par', 'if'}:
            return traces(code.args[0]) | traces(code.args[1])
        if code.op == 'tag':
            return traces(code.args[0])
        if code.op == 'seq':
            result = set()
            for outcome, prefix in traces(code.args[0]):
                if outcome == code.key:
                    result.update((tail, prefix + suffix) for tail, suffix in traces(code.args[1]))
                else:
                    result.add((outcome, prefix))
            return result
        raise AssertionError('outside independent trace vocabulary')

    rng = random.Random(6031)
    next_handler = 1000
    def gen(depth, site, available):
        nonlocal next_handler
        if depth == 0 or rng.randrange(4) == 0:
            choice = rng.randrange(3)
            if choice == 0:
                return m.k('cont', key=rng.choice((0,) + available))
            return m.k('stop' if choice == 1 else 'cut', terms=(m.app(site),))
        op = rng.choice(('seq', 'par', 'if'))
        if op == 'seq':
            if rng.randrange(2):
                next_handler += 1
                key = next_handler
                left_available = available + (key,)
            else:
                key = 0
                left_available = available
            # Native handler bodies use the outer xmap, so they cannot emit
            # their own catching label. Each positive catching label is fresh.
            return m.k(op, gen(depth - 1, site + 'L', left_available),
                       gen(depth - 1, site + 'R', available), key=key)
        return m.k(op, gen(depth - 1, site + 'L', available),
                   gen(depth - 1, site + 'R', available), key=site)
    for i in range(700):
        code = gen(5, str(i), (101, 102))
        expected = traces(code)
        for mode in (False, True):
            check(traces(m.reflow(code, mode)) == expected,
                  'reflow preserves symbolic outcome and check routes')

    result = {
        'target_commit': target, 'started_utc': started,
        'elapsed_seconds': time.perf_counter() - timer,
        'checks': sum(COUNTS.values()), 'checks_by_family': dict(COUNTS),
        'inputs': inputs, 'source_identities': identities,
        'author_retained_result': {'checks': receipt['checks'], 'elapsed_seconds': receipt['elapsed_seconds']},
        'platform': platform.platform(), 'machine': platform.machine(),
        'selected_model': 'GPT-6 Astra', 'selected_effort': 'Extra High',
        'runtime_confirmation': None, 'tokens': None, 'cost': None,
        'native_executions': 0, 'predecessor_checker_executions': 0,
        'scope': 'Exact-freeze attachment, changed-seam source guards and independent focused model probes; not a full VCgen implementation or universal proof by samples.',
    }
    if args.write:
        args.write.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
