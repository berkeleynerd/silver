"""Uninstantiated, source-checkable contract for returned Hsdecl objects.

This module validates numeric *hypotheses*, not native state or coverage.
No argument can mark the representative contract established. In particular,
neither an arbitrary Boolean nor the captured-root inventory is such evidence.
"""

ENVELOPE_FIELDS = (
    'seed_saved_entries_per_formula',
    'delayed_value_nodes',
    'type_occurrence_nodes',
    'attribute_universe_entries',
)

CONTRACT = {
    'status': 'uninstantiated',
    'coverage_evidence': None,
    'quantification': (
        'Every old live declaration that any Decl.Hsdecl merge can return in '
        'this invocation, including a previously inserted local candidate; '
        'the candidate itself is covered by the mapper derivation. Include '
        'every stored edge, unused saved value, key identifier, type and '
        'attribute reached from each returned object.'
    ),
    'coverage_required': (
        'A complete initial Hsdecl representative projection or a source/process '
        'invariant, joined to the capture and every merge/return site. Establish '
        'closure under local insertions and weak clearing and exclude concurrent '
        'foreign insertions. A sample of returned objects is insufficient.'
    ),
    'numeric_envelope_meanings': {
        'seed_saved_entries_per_formula': (
            'E: upper bound on the sum of saved-map entries in any returned '
            'old declaration formula before its downstream opening; count '
            'occurrences, including unused entries. The captured-root baseline '
            'of eight is independently included using max(8,E).'
        ),
        'delayed_value_nodes': (
            'V: stored term occurrence bound for every seed saved value in '
            'that projection; include the captured six-node baseline.'
        ),
        'type_occurrence_nodes': (
            'T: occurrence bound for every stored type, variable type and '
            'symbol signature, including unused saved values and map keys; '
            'include the captured size-three baseline.'
        ),
        'attribute_universe_entries': (
            'A: cardinality of the union of attributes on all captured and '
            'selectable terms, symbols, variables and saved-map key identifiers; '
            'include the captured 80-attribute baseline.'
        ),
    },
    'required_invariants': [
        {
            'id': 'stored_well_formedness',
            'requirement': (
                'Finite acyclic stored term/type graphs; valid bv_vars and '
                'bv_subst records, integer counts, identifiers and declaration '
                'caches. Fresh identifiers cannot collide with any projected '
                'key or variable. All semantic free counts are the actual '
                'counts of the opened terms.'
            ),
            'source': 'term.ml:599-622,739-831; ident.ml:187-213',
        },
        {
            'id': 'delayed_value_closure',
            'requirement': (
                'Every seed saved value is binder-free, pattern-free and has '
                'at most one free-variable occurrence. Across all seed maps '
                'that can compose, no key with a non-leaf value occurs free '
                'in any seed saved value. Their entries and values obey E,V. '
                'Subsequent added entries are only fresh-variable renamings; '
                'independent validators restart from the immutable declaration.'
            ),
            'source': 'term.ml:739-831; decl.ml:518-535,621-634,741-748',
        },
        {
            'id': 'opened_body_and_eligibility_correspondence',
            'requirement': (
                'After real opening and t_attr_copy, each selected logic body '
                'and proposition corresponds, modulo fresh alpha names, to the '
                'accepted refinement alternatives at that declaration index. '
                'Preserve types, constants, triggers, patterns, free-variable '
                'multiplicities and attributes used by notdef/notls. Additional '
                'guard exclusions may be represented as optional misses, but '
                'there may be no extra eligible body or hit outside the accepted '
                '45-body/85-hit alternatives. Eligible bodies remain binder-free '
                'and pattern-free with formal coefficients at most one. '
                'Strict equality alone is not evidence for this requirement.'
            ),
            'source': 'term.ml:266-281,325-379,646-662; inlining.ml:64-80,119-145',
        },
        {
            'id': 'stored_symbols_types_and_attributes',
            'requirement': (
                'All stored logic/type symbols, including unused values and '
                'map-key types, belong to the captured validated symbol/signature '
                'universe. No extra hidden self-reference, alias expansion, '
                'recursive data dependency or signature variable is introduced. '
                'Types obey T, normalized Tyapp representation, signature '
                'type-variable bound two and application arity seven; attributes '
                'obey the union bound A. Environment constants retain builtin '
                'unbounded int behavior. No new named symbols/attributes arise.'
            ),
            'source': 'term.ml:1083-1205; ty.ml:126-143,234-254; decl.ml:699-826',
        },
        {
            'id': 'declaration_and_binder_shape',
            'requirement': (
                'Retain declaration index/kind/symbol, singleton nonrecursive '
                'logic shape, formal arities, d_news and validated cached fields. '
                'Opened root/body/trigger/binder/pattern coordinates lie within '
                'the accepted corresponding alternatives (not merely a global '
                'mass bound). Raw binder structure has no additional binders '
                'hidden in saved values; all patterns remain nullary constructors '
                'with empty variable sets. Reused ground Ddata/type/parameter '
                'declarations and their dependency graph remain the captured ones.'
            ),
            'source': 'decl.ml:350-419,526-535,621-634; pattern.ml:141-161',
        },
    ],
    'not_covered_by_this_contract': [
        'Unsuccessful Hsdecl collision comparands and their equality cost.',
        'Initial counters/table backing, other lifetime callers, and runtime allocation/GC composition.',
    ],
}


def numeric_hypothesis(value):
    """Check the arithmetic domain only; return no coverage verdict."""
    assert type(value) is dict and set(value) == set(ENVELOPE_FIELDS)
    assert all(type(value[k]) is int and value[k] >= 0 for k in ENVELOPE_FIELDS)
    assert value['delayed_value_nodes'] >= 1
    assert value['type_occurrence_nodes'] >= 1
    return dict(value)


def returned_old_map_witness(steps=37):
    """Source-rule specialization, not a native Why3 experiment.

    Repeated x_i -> x_(i+1) substitutions on forall z. P(x_0).
    Model bv_vars restriction, old-value rewriting and saved-map union;
    then use the equal opened form to select the old object and fold its map.
    """
    assert type(steps) is int and steps >= 1
    saved, free = {}, {0: 1}
    for i in range(steps):
        substitution = {i: i + 1}
        restricted = {k: v for k, v in substitution.items() if k in free}
        new_free = {k: v for k, v in free.items() if k not in restricted}
        for k, v in restricted.items():
            new_free[v] = new_free.get(v, 0) + free[k]
        saved = {k: restricted.get(v, v) for k, v in saved.items()}
        saved.update(restricted)
        free = new_free
    old = {'raw_variable': 0, 'saved': saved, 'free': free}
    candidate = {'raw_variable': steps, 'saved': {}, 'free': {steps: 1}}

    def opened_alpha_key(rep):
        # The outer formal closes x_steps. z is the unused inner binder.
        variable = rep['saved'].get(rep['raw_variable'], rep['raw_variable'])
        assert variable == steps
        return ('forall_outer', 'forall_z', 'P', ('bound', 0))

    # Weak.Make returns the old representative on an equal-hash/equality hit.
    assert opened_alpha_key(candidate) == opened_alpha_key(old)
    selected = old
    # Opening the outer formal substitutes x_steps -> a fresh variable in
    # the inner binding: all old values are renamed and one more key is saved.
    fresh = steps + 1
    opened_outer_saved = {k: fresh for k in selected['saved']}
    opened_outer_saved[steps] = fresh
    # Downstream t_gen_fold/used-symbol work includes every saved value.
    visited_values = [v for _, v in sorted(opened_outer_saved.items())]
    return {
        'steps': steps,
        'candidate_saved_entries': len(candidate['saved']),
        'returned_old_saved_entries': len(selected['saved']),
        'inner_saved_entries_after_outer_open': len(opened_outer_saved),
        'downstream_saved_value_visits': len(visited_values),
        'saved_value_nodes_max': 1,
        'semantic_free_occurrences': sum(free.values()),
        'same_opened_alpha_form': True,
        'returned_old_is_selected': selected is old,
        'native_observation': False,
    }
