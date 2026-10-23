"""Source-attached author lookup-constructor closure; independent review pending.

Only frozen projections are read. No target, parser or predecessor checker runs.
The source transfer in the companion note is a separate review obligation.
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent
OWNERS = ('Ident', 'Decl.Hsdecl', 'Ty.Hsty', 'Theory.Hstdecl',
          'Task.Hstask', 'Task.Stdecl.Hcpt')
REMAINING = ('Ident', 'Ty.Hsty', 'Theory.Hstdecl')
INT_MAX = 2**62 - 1
ORDINARY_IDENT_PER_SLOT = 2**24
ORDINARY_TY_PER_SLOT = 2**24
ORDINARY_TDECL_PER_SLOT = 2**21


def read(path):
    return json.loads(path.read_text())


def natural(n):
    if type(n) is not int or n < 0:
        raise ValueError('expected a natural number, excluding bool')
    return n


def vector(ident=0, decl=0, ty=0, td=0):
    return {'Ident': dict(increments=ident, requests=0),
            'Decl.Hsdecl': dict(increments=decl, requests=decl),
            'Ty.Hsty': dict(increments=ty, requests=ty),
            'Theory.Hstdecl': dict(increments=td, requests=td),
            'Task.Hstask': dict(increments=0, requests=0),
            'Task.Stdecl.Hcpt': dict(increments=0, requests=0)}


def calculate(escape=2):
    natural(escape)
    if escape > 2:
        raise ValueError('the single process escape allowance is at most two')
    library = read(EV / 'retained-why-library-publication-bound-20261020/bound.json')
    states = read(EV / 'retained-why-shared-demand-20261020/attachment.json')
    rows = []
    for state in states:
        case = state['case']
        family = read(EV / 'retained-why-fixed-inline-family-20261020' / (case + '-family.json'))
        roots = family['registered_roots']
        episodes = 3 * roots + escape
        initial = state['owners']['Ident']['counter']
        arity = max(initial, library['source_bytes_all_files'])
        keys = 2 * initial + library['implicit_tuple']['lexical_arity_domain_size']
        per_root = {}
        for name, prior in library['direct_root_bounds'].items():
            ordinary = 4 * prior['expanded_source_bytes']
            callbacks = keys + prior['swallowed_clone_marker_upper_count'] + 1
            per_root[name] = {
                'expanded_source_bytes': prior['expanded_source_bytes'],
                'non_tuple_decl_constructor_entries_upper': ordinary,
                'each_publication_memo_callback_entries_upper': callbacks,
                'covered_sites_vector': vector(ident=2*callbacks,
                    decl=ordinary+callbacks, ty=(arity+1)*callbacks, td=2*callbacks),
            }
        # The two root calls are int and real. Taking the larger real envelope
        # twice also covers every prefix and a failure before the second read.
        ordinary = 2 * episodes * per_root['real']['non_tuple_decl_constructor_entries_upper']
        base = 2 * episodes * per_root['real']['each_publication_memo_callback_entries_upper']
        resize = library['implicit_tuple']['resize_assignments_both_tables_global_upper'] * keys
        signal = escape * (keys + 1)
        callbacks = base + resize + signal
        covered = vector(ident=2*callbacks, decl=ordinary+callbacks,
                         ty=(arity+1)*callbacks, td=2*callbacks)
        slots = 2 * episodes * per_root['real']['expanded_source_bytes']
        # Every lower memo CALL is charged as a miss. These are the
        # transitive lower-child costs of the publication bodies; the
        # publication callbacks themselves are already in covered.
        lower = dict(ident=(10*arity+10)*callbacks, ty=(6*arity+3)*callbacks)
        remainder = {
            'Ident': dict(increments=ORDINARY_IDENT_PER_SLOT*slots+lower['ident'], requests=0),
            'Ty.Hsty': dict(increments=ORDINARY_TY_PER_SLOT*slots+lower['ty'],
                            requests=ORDINARY_TY_PER_SLOT*slots+lower['ty']),
            'Theory.Hstdecl': dict(increments=ORDINARY_TDECL_PER_SLOT*slots,
                                  requests=ORDINARY_TDECL_PER_SLOT*slots),
        }
        complete = {owner: dict(demand) for owner, demand in covered.items()}
        for owner, demand in remainder.items():
            for field, value in demand.items():
                complete[owner][field] += value
        endpoint = state['owners']['Decl.Hsdecl']['counter'] + covered['Decl.Hsdecl']['increments']
        rows.append(dict(case=case, initial_registration_upper=initial,
            registered_roots=roots, episodes_upper=episodes,
            nonnegative_tuple_arity_upper=arity, tuple_key_cardinality_upper=keys,
            per_direct_root=per_root,
            whole_process_publication_memo_callbacks=dict(base=base, resize=resize,
                signal=signal, each_table_total=callbacks),
            non_tuple_decl_constructor_entries_upper=ordinary,
            decl_constructor_entries_upper=ordinary+callbacks,
            decl_hashcons_requests_upper=ordinary+callbacks,
            decl_unique_requests_upper=ordinary,
            decl_possible_increments_upper=ordinary+callbacks,
            decl_request_upper_bounds_are_not_additive=True,
            covered_sites_vector=covered,
            expanded_source_slots_whole_process=slots,
            publication_lower_children=lower,
            ordinary_coefficients=dict(Ident=ORDINARY_IDENT_PER_SLOT,
                Hsty=ORDINARY_TY_PER_SLOT, Hstdecl=ORDINARY_TDECL_PER_SLOT),
            remaining_sites_vector=remainder,
            lookup_vector=complete,
            complete_owners=list(OWNERS), incomplete_owners=[],
            native_operands=dict(decl_counter_endpoint_upper=endpoint,
                decl_counter_margin=INT_MAX-endpoint, decl_counter_fits=endpoint <= INT_MAX,
                tuple_for_loop_index_upper=arity, tuple_for_loop_index_fits=arity < INT_MAX),
            lookup_vector_complete=True))
    return dict(schema='silver.retained-why-library-constructors.author.v2',
        shape_interface=dict(ordinary_type_unfolded_nodes=64,
            failed_type_match_diagnostic_nodes=4096,
            original_callable_contract_skeleton_slots=1024,
            original_callable_contract_stored_slots=1024,
            original_callable_contract_expanded_skeleton_slots=632,
            original_callable_contract_binder_records=8,
            original_callable_contract_bv_subst_entries=0,
            cty_apply_origin_excludes_generated_lemma_wrappers=True,
            generated_cloned_any_contract_stored_slots=32768,
            instantiated_program_contract_stored_slots=65536,
            general_diagnostic_term_stored_slots=None,
            general_diagnostic_term_bound_needed_for_constructor_vector=False,
            ordinary_tuple_keys=[0, 2], lexical_declaration_units=128,
            clone_ancestry_modules=10, explicit_program_formals=8,
            lexical_free_or_bound_variables_per_scope=16,
            applies_before_first_combined_guard_violation=True),
        cases=rows, global_escape_upper=escape, save_callbacks_upper=2, saves_upper=3,
        initial_prefix_recharged=False, publication_W_relabelled_as_constructors=False,
        lower_tuple_memo_replay_discharged=True,
        lower_tuple_policy='charge every actual call; no lower memo persistence or loss allowance',
        complete_lookup_vector=True, independent_review_accepted=False,
        association_prefix_required=True, whole_process_headroom=False,
        source_transfer_machine_checked=False, native_execution=False)


def complete_lookup(case, remaining, escape=2):
    """Join only when the caller supplies the THREE still-missing site charges.

    These must exclude the covered sites named in the note. This function
    checks arithmetic shape, not the caller's source provenance.
    """
    if type(remaining) is not dict or set(remaining) != set(REMAINING):
        raise ValueError('missing Ident/Hsty/Hstdecl site charges are required')
    row = next(r for r in calculate(escape)['cases'] if r['case'] == case)
    out = row['covered_sites_vector']
    for owner in REMAINING:
        d = remaining[owner]
        if type(d) is not dict or set(d) != {'increments', 'requests'}:
            raise ValueError('each remaining owner needs increments and requests')
        for field in ('increments', 'requests'):
            out[owner][field] += natural(d[field])
        if owner == 'Ident' and out[owner]['requests']:
            raise ValueError('Ident has no hash-table requests')
    return out


def lookup_vector(case, escape=2):
    """Full E-weighted author vector, to join ONCE in the R60 residual API.

    Source transfer is conditional on the earliest-violation prefix and
    requires independent review. This function proves neither premise.
    """
    row = next(r for r in calculate(escape)['cases'] if r['case'] == case)
    return row['lookup_vector']


if __name__ == '__main__':
    (HERE / 'result.json').write_text(json.dumps(calculate(), indent=2, sort_keys=True) + '\n')
