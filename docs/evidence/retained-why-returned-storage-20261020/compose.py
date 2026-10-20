"""Natural-number closure and validator-support arithmetic; no native replay."""
import json
from context_model import HERE, R56, CASES

# Per complete preparation, overcharge the union of actual selected routes.
# These are productive opening sweeps along one retained representation lineage.
SWEEPS = dict(raw_or_CE_entry=1, first_inline=1, algebraic_or_projection_family=3,
              literal=1, guard_epsilon=2, general_epsilon=2,
              formula_simplification=2, singleton_premise_splitting=4)
assert sum(SWEEPS.values()) == 16

# All term-declaration branches are charged even though mutually exclusive.
# A unit is one complete stored/semantic traversal (including its binder opens).
VALIDATOR_SWEEPS = dict(mapper_and_outer_definition_open=2,
    definition_callback_comparison_operands=2,
    definition_closure_free_and_type_scans=3,
    termination_definition_open_and_walk=2,
    inline_and_known_map_used_symbol_scans=2,
    inlining_environment_definition_open=1,
    task_match_walk=1,
    inductive_prefix_and_positivity_walks=2,
    inductive_free_and_type_scans=3,
    declaration_hash_walk=1,
    proposition_free_variable_check=1)
assert sum(VALIDATOR_SWEEPS.values()) == 20
VALIDATOR_ALLOWANCE = 32


def compose(contexts):
    domains = []
    total = dict(term_and_opening_entries=0, free_variable_scan_entries=0,
                 type_node_entries=0)
    for c in contexts:
        f=json.loads((R56/f"{c['case']}-family.json").read_text())
        stages=list(c['stages'].values())
        P=max(s['bound_plus_formal_slots_max'] for s in stages)
        M=max(s['original_context_formula_mass_max'] for s in stages)
        K0=max(s['seed_storage']['maximum_binding_saved_entries'] for s in stages)
        V=max(s['seed_storage']['value_nodes'] for s in stages)
        T=max(s['seed_storage']['all_term_variable_key_value_signature_type_mass_max'] for s in stages)
        A=max(s['seed_storage']['signature_arity_max'] for s in stages)
        assert (P,M,K0,V)==(8,99,6,1)
        assert A<=7 and T<=5
        roots=f['registered_roots']; ordinary=3*roots; e=2; episodes=ordinary+e
        K=K0+sum(SWEEPS.values())*episodes*P*P
        R=M*(1+K*V)
        # Two extra fresh traversals cover independent temporary opening/closing
        # walks in a validator. They are scratch storage, not new producer episodes.
        Ko=K+2*P*P; Ro=M*(1+Ko*V)
        unit=M+(P+1)*Ro
        call_units=episodes*c['original_context_keys']*VALIDATOR_ALLOWANCE
        operations=dict(term_and_opening_entries=call_units*unit,
            free_variable_scan_entries=call_units*unit*M,
            type_node_entries=call_units*unit*(A+2)*T*T)
        for name,value in operations.items():total[name]+=value
        domains.append(dict(case=c['case'],registered_roots=roots,
            original_context_keys=c['original_context_keys'],ordinary_episodes=ordinary,
            shared_process_escape_upper=e,preparation_episodes_upper=episodes,
            P=P,M=M,K0=K0,V=V,T=T,A=A,returned_map_entries_upper=K,
            returned_stored_occurrences_upper=R,
            opened_scratch_map_entries_upper=Ko,
            opened_scratch_stored_occurrences_upper=Ro,
            validator_sweep_units_upper=call_units,validator_support_operations=operations))
    assert sum(d['original_context_keys'] for d in domains)==1238
    assert sum(d['preparation_episodes_upper'] for d in domains)==364
    assert all(v<2**62 for v in total.values())
    return dict(domains=domains,all_five_processes=total,
        source_productive_sweeps_per_episode=SWEEPS,
        validator_traversal_inventory=VALIDATOR_SWEEPS,
        conservative_validator_traversals_per_context_declaration=VALIDATOR_ALLOWANCE,
        episodes=dict(ordinary=354,upper=364,escape_is_process_global=True,
                      fresh_stage_escape_allowance=False),
        original_context_keys=1238,initial_leaf_images_and_type_inventory_checked=True,
        source_producer_and_validator_argument_machine_checked=False,
        complete_returned_storage_under_named_source_and_mutation_premises=True,
        goals=dict(hashcons='unique',reuse_R56_candidate_envelope=True,
                   R56_candidate_charges_must_not_be_discarded=True),
        remaining=dict(unsuccessful_hashcons_collision_comparands=True,
            map_and_table_primitive_costs=True,allocation_collection_and_stack=True,
            native_counter_initial_values_and_later_demands=True,
            later_stage_and_printer_total_work=True,whole_quiet_capacity=True))

if __name__=='__main__':
    data=compose([json.loads((HERE/f'{c}-context.json').read_text()) for c in CASES])
    (HERE/'result.json').write_text(json.dumps(data,sort_keys=True,indent=2)+'\n')
    print(json.dumps(data['all_five_processes'],sort_keys=True))
