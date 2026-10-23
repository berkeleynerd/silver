"""Natural-number arithmetic for the source envelope in the companion note.

No source-operation total is treated as an OCaml counter or a RAM gate.
This consumes frozen projections, not their generating programs.
"""
from pathlib import Path
import json

HERE = Path(__file__).resolve().parent
EV = HERE.parent


def read(p):
    return json.loads(p.read_text())


def calculate():
    cases = []
    preceding = {c['case']: c for c in read(EV / 'retained-why-postinline-preparation-20261020/result.json')['domains']}
    for c in read(HERE / 'continuation-projection.json')['cases']:
        name = c['case']
        f = read(EV / 'retained-why-fixed-inline-family-20261020' / (name + '-family.json'))
        i = read(EV / 'retained-why-postinline-preparation-20261020' / (name + '-inventory.json'))
        g = read(HERE / (name + '-inventory.json'))
        rows = sum(c['routes'].values(), [])
        n = c['registered_roots']
        e = 3 * n + 2  # One process-wide allowance; not one per stage.
        m = max(99, max(r['goal_mass_after_inline_upper'] for r in rows))
        p = max(8, max(r['goal_bound_slots_after_inline_upper'] for r in rows))
        q = max(99, max(r['optional_inline_partial_let_potential_upper'] for r in rows))
        goal_k0 = max(r['candidate_saved_entries_upper'] for r in rows)
        k0 = max(6 + 16 * e * 8**2, goal_k0)
        data = len(g['data'])
        ranges = len(g['range_types'])
        context_mass = max(st['context']['sum_reconstructed_formula_mass_upper'] for st in f['stages'].values())
        # Before literal rewriting, allow every raw type and every possible
        # constructor/projection/inversion side formula, even if removed.
        literal_input_mass = 2 * (context_mass + m) + 128 * data + 32
        # Dominates original decls, literals, data axioms, right-split family,
        # Introduction parameters/premises/definitions, and intermediate decls.
        d = i['context_declarations'] + 16 * literal_input_mass + 16 * ranges + 8 * data + 8 * m + p + 4
        s = 24 * m + 32
        # 64 productive traversals per episode, each adding at most P^2 keys
        # along one lineage. The split component uses the frozen 4PL lemma.
        k = k0 + 64 * e * p**2
        v = 6 * q
        kopen = k + 2 * p**2
        stored = s * (1 + k * v)
        opened_stored = s * (1 + kopen * v)
        u = s + (p + 1) * opened_stored
        types = i['signature_maxima']['type_nodes']
        arity = i['signature_maxima']['arity']
        # R58 raw-chain/driver rule bound is retained, then side declarations
        # and their (at most eight) metadata/declaration wrappers are added.
        task0 = preceding[name]['task_nodes_upper']
        task = task0 + 9 * d
        # Introduction maps only the unique goal, before private returned
        # premises and simplification. Prior selected maps only rename images.
        intro_k = goal_k0 + 16 * p**2
        intro_stored = 2 * m * (1 + 6 * intro_k)
        forest = i['ground_data']['founded_type_entries'] + i['ground_data']['founded_constructor_entries']
        type_requests = 4 * types**2 * intro_stored + 64 * task * (forest + (arity + 1) * types)
        # 16 selected subpasses x 64 traversal/callback/constructor units.
        units = 1024 * d * (s + 1)
        # gen_fresh_vsymbol can register once for every bound slot, saved key
        # and free-variable prepass key: B + J + F <= 3 R_intro. Do not assume
        # physical type identity or retention of an older hashcons entry.
        intro_type_map_idents = 3 * intro_stored
        ordinary_idents = units * (p + 1)
        one = {
            'direct_Ident_registrations': ordinary_idents + intro_type_map_idents,
            'logical_decl_constructor_requests': 64 * d,
            'tdecl_constructor_requests': 64 * task,
            'task_add_requests': 64 * task,
            'task_fold_callback_entries': 64 * task,
            'term_and_opening_entries': units * u,
            'free_variable_scan_entries': units * s * u,
            'type_node_entries': units * (arity + 2) * types**2 * u,
            'successful_decl_equality_visible_entries': 128 * d * s,
            'metadata_argument_visits': 512 * task,
            'type_hashcons_requests': type_requests,
            # Conservative useful tag bound; mandatory-hit reductions are not
            # required to make the caller's initial-plus-demand sum finite.
            'new_type_tags': type_requests,
            'introduction_ls_queue_requests': 8 * m + p,
            'introduction_axiom_requests': 8 * m,
            'literal_map_inserts': literal_input_mass,
            'projection_empty_list_fresh_variables': 3,
        }
        total = {key: e * value for key, value in one.items()}
        scalar = {
            'visible_formula_mass_upper': s,
            'saved_image_mass_upper': v,
            'saved_map_cardinality_upper': kopen,
            'free_variable_occurrence_operand_upper': max(s, v),
            'free_variable_occurrence_product_upper': max(s, v)**2,
            'private_queue_length_upper': e * (8 * m + p),
            'private_axiom_table_insertions_upper': e * 8 * m,
            'task_chain_length_upper': task,
            'list_index_upper': max(task, kopen, d, s, v),
            'algebraic_projection_index_upper': 2,
            'algebraic_indexer_iterations': 0,
            'algebraic_material_array_length': 0,
        }
        assert max(scalar.values()) < 2**62
        # These are actual registration/constructor counters. Large overlapping
        # traversal categories above deliberately have no such assertion.
        for key in ['direct_Ident_registrations', 'logical_decl_constructor_requests',
                    'tdecl_constructor_requests', 'task_add_requests', 'type_hashcons_requests', 'new_type_tags']:
            assert total[key] < 2**62
        cases.append(dict(case=name, registered_roots=n, episodes_upper=e,
                          dimensions=dict(M=m, P=p, Q=q, K0=k0, K=k, V=v,
                                          S=s, D=d, task_nodes=task,
                                          unique_goal_pre_introduction_K=intro_k,
                                          unique_goal_pre_introduction_R=intro_stored,
                                          literal_input_mass=literal_input_mass,
                                          returned_stored_occurrences=stored,
                                          validator_U=u),
                          one_episode=one, process_demands=total,
                          direct_Ident_components={
                              'opening_and_generated_symbols': {
                                  'one_episode': ordinary_idents,
                                  'process_demand': e * ordinary_idents},
                              'introduction_type_map_variable_clones': {
                                  'one_episode': intro_type_map_idents,
                                  'process_demand': e * intro_type_map_idents}},
                          native_scalar_operands=scalar))
    return {'cases': cases,
            'combined_demands': {k: sum(c['process_demands'][k] for c in cases)
                                 for k in cases[0]['process_demands']},
            'process_global_e_upper': 2, 'save_callbacks_upper': 2, 'saves_upper': 3,
            'new_stage_escape_allowance': False,
            'source_theorem_machine_checked': False,
            'initial_counter_plus_whole_suffix_headroom_claimed': False,
            'aggregate_RAM_gate': False,
            'scope': 'additional selected preparation after R58 through entry to Driver.print_task_prepared',
            'excludes': ['printer execution', 'unsuccessful collision-comparand primitive costs',
                         'allocator/GC/stack physical sufficiency', 'whole quiet-capacity composition']}


if __name__ == '__main__':
    result = calculate()
    (HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    for c in result['cases']:
        print(c['case'], c['dimensions'], 'Ident', c['process_demands']['direct_Ident_registrations'])
