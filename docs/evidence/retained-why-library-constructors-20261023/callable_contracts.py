"""Frozen source-body target annotation and checkable contract projection.

The mapping is a semantic author annotation, not a parser/name-resolution proof.
The checker verifies exhaustive selected outer let-row ownership and source bytes.
"""
import json
import re
from compose import HERE
from family_shapes import project as family_project
from freeze import identity

# Exact possible executable call origins, by installed source line. Annotation
# clauses are separately projected; their logical applications are not c_app.
# 'self' and 'local' denote the Dexpr denv/rsm binding, not namespace fallback.
TARGETS = {
 'int.Int:23': ['int.Int.(+)', 'int.Int.(-_)'],
 'int.Int:24': ['int.Int.(<)'],
 'int.Int:25': ['int.Int.(<)', 'int.Int.(=)'],
 'int.Int:26': ['int.Int.(<=)'],
 'int.Int:44': ['fixed unit'],
 'int.Abs:58': ['int.Int.(>=)', 'int.Int.(-_)'],
 'int.MinMax:80': ['int.Int.(<=)'],
 'int.MinMax:84': ['int.Int.(<=)'],
 'int.NumOf:380': ['int.Int.(<=)', 'int.Int.(-)', 'int.Int.(+)', 'self numof', 'rs_func_app on p'],
 'int.Sum:449': ['int.Int.(<=)', 'int.Int.(-)', 'int.Int.(+)', 'self sum', 'rs_func_app on f'],
 'int.Sum:481': ['int.Int.(<)', 'int.Int.(+)', 'self shift_left', 'fixed unit'],
 'int.SumParam:497': ['int.Int.(<=)', 'int.Int.(-)', 'int.Int.(+)', 'self sum', 'rs_func_app on f'],
 'int.SumParam:529': ['int.Int.(<)', 'int.Int.(+)', 'self shift_left', 'fixed unit'],
 'int.SumParam:538': ['int.Int.(=)', 'int.Int.(-)', 'self sum_middle_change', 'fixed unit'],
 'int.Fact:553': ['int.Int.(=)', 'int.Int.(*)', 'int.Int.(-)', 'self fact'],
 'int.Iter:567': ['int.Int.(=)', 'int.Int.(-)', 'self iter', 'rs_func_app on f'],
 'int.IntInf:586': ['int.Int.(+)', 'int.IntInf.Finite', 'int.IntInf.Infinite'],
 'int.IntInf:596': ['int.Int.(=)', 'pair tuple adapter', 'fixed bool'],
 'int.IntInf:603': ['int.Int.(<)', 'fixed bool'],
 'int.IntInf:613': ['int.IntInf.lt', 'int.IntInf.eq'],
 'int.HOInduction:665': ['int.Int.(>)', 'int.Int.(-)', 'local/self f', 'fixed unit'],
 'int.Fibonacci:680': ['int.Int.(=)', 'int.Int.(+)', 'int.Int.(-)', 'self fib'],
 'int.WFltof:700': ['int.Int.(>)', 'int.Int.(-)', 'self acc_ltof', 'fixed unit'],
 'real.Real:23': ['real.Real.(<)'],
 'real.Real:24': ['real.Real.(<)', 'real.Real.(=)'],
 'real.Real:25': ['real.Real.(<=)'],
 'real.Real:44': ['real.Real.(+)', 'real.Real.(-_)'],
 'real.RealInfix:69': ['real.Real.(+)'],
 'real.RealInfix:70': ['real.Real.(-)'],
 'real.RealInfix:71': ['real.Real.(*)'],
 'real.RealInfix:73': ['real.Real.(-_)'],
 'real.RealInfix:76': ['real.Real.(=)'],
 'real.RealInfix:77': ['real.Real.(<=)'],
 'real.RealInfix:78': ['real.Real.(>=)'],
 'real.RealInfix:79': ['real.Real.(<)'],
 'real.RealInfix:80': ['real.Real.(>)'],
 'real.Abs:94': ['real.Real.(>=)', 'real.Real.(-_)'],
 'real.Sum:449': ['int.Int.(<=)', 'int.Int.(-)', 'real.RealInfix.(+.)', 'self sum', 'rs_func_app on f'],
}


def project():
    family = family_project()
    rows, bodies, literal_lemma_names, implicit_posts = [], [], [], []
    propositions = sorted({m[1] for row in family['declarations']
        if (m := re.match(r'(?:axiom|lemma)\s+([A-Za-z_][A-Za-z0-9_\']*)\b', row['source']))})
    for row in family['declarations']:
        source = row['source']
        literal_lemma_names += re.findall(r"\b[A-Za-z_][A-Za-z0-9_']*'lemma\b", source)
        if not re.match(r'(?:let|val)\b', row['first']):
            continue
        clauses = []
        pattern = r'\b(requires|ensures|variant)\s*\{([^{}]*)\}'
        for m in re.finditer(pattern, source):
            units = re.findall(r"[A-Za-z_][A-Za-z0-9_']*|[0-9]+|\S", m[2])
            clauses.append(dict(kind=m[1], source=m[2], lexical_units=len(units),
                quantified_binders=len(re.findall(r'\b(?:forall|exists|epsilon|fun)\b', m[2]))))
        # No other brace-bearing form occurs in these source program rows.
        assert source.count('{') == source.count('}') == len(clauses)
        boundaries = sum(c['quantified_binders'] + (c['kind'] == 'ensures') for c in clauses)
        key = f"{row['module']}:{row['line']}"
        rows.append(dict(key=key, declaration_identity=identity(source.encode()),
            clauses=clauses, source_quantifier_and_post_boundaries=boundaries,
            annotation_lexical_units=sum(c['lexical_units'] for c in clauses)))
        if not source.startswith('let '):
            continue
        bare = re.sub(pattern, lambda m: ' ' * len(m[0]), source)
        depth = 0
        for i, char in enumerate(bare):
            if char == '(': depth += 1
            elif char == ')': depth -= 1
            elif char == '=' and depth == 0:
                body = source[i+1:].strip()
                break
        else:
            raise AssertionError('missing program body: '+key)
        bodies.append(dict(key=key, body=body, body_identity=identity(body.encode()),
            semantic_possible_call_origins=TARGETS[key],
            all_body_identifier_runs=sorted(set(re.findall(r"[A-Za-z_][A-Za-z0-9_']*", body)))))
        if (re.match(r'let\s+(?:ghost\s+)?(?!(?:function|predicate|lemma|rec)\b)', source)
                and not any(c['kind']=='ensures' for c in clauses)):
            implicit_posts.append(key)
    assert {r['key'] for r in bodies} == set(TARGETS)
    intersections = [dict(key=r['key'], names=sorted(set(r['all_body_identifier_runs']) & set(propositions)))
        for r in bodies if set(r['all_body_identifier_runs']) & set(propositions)]
    return dict(schema='silver.retained-why-callable-contracts.v1',
        program_declarations=rows, executable_bodies=bodies,
        explicit_program_declarations=len(rows), executable_outer_let_declarations=len(bodies),
        maximum_annotation_lexical_units=max(r['annotation_lexical_units'] for r in rows),
        maximum_source_quantifier_and_post_boundaries=max(r['source_quantifier_and_post_boundaries'] for r in rows),
        literal_generated_lemma_name_references=literal_lemma_names,
        lexical_proposition_head_names=propositions,
        body_identifier_intersections_with_lexical_proposition_heads=intersections,
        implicit_RKnone_post_origins=implicit_posts,
        literal_name_absence_alone_does_not_exclude_tick_lemma_fallback=True,
        body_target_annotation_requires_semantic_review=True,
        ordinary_callable_stored_bound_derivation=dict(
            lexical_skeleton=512, logical_mapping_wrapper=64, generated_post=32,
            DECR_overhead=8, formal_and_list_slots=16, binder_records=8,
            bv_vars_per_record=16, bv_subst_entries=0,
            expanded_skeleton=632, complete_stored_slots=760, exported_upper=1024))


if __name__ == '__main__':
    (HERE / 'callable-contracts.json').write_text(json.dumps(project(),indent=2,sort_keys=True)+'\n')
