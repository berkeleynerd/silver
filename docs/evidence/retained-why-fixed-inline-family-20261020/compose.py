"""Compose finite first-inline bounds with ONE escape allowance per process."""
from family_model import calculate
from project import CASES

def compose(families):
    cases=[]
    for family in families:
        raw=family['stages']['raw']['roots'];ce=family['stages']['ce']['roots']
        assert [r['goal'] for r in raw]==[r['goal'] for r in ce]
        normal=raw+ce+ce;allrows=raw+ce
        def total(group):
            names=sorted(set().union(*(r[group] for r in normal)))
            return {k:dict(ordinary=sum(r[group][k] for r in normal),
                one_episode_max=max(r[group][k] for r in allrows),
                with_global_e_le_2=sum(r[group][k] for r in normal)+2*max(r[group][k] for r in allrows)) for k in names}
        cases.append(dict(case=family['case'],registered_roots=family['registered_roots'],
            nontrivial_registered_roots=family['nontrivial_registered_roots'],
            ordinary_root_driver_pairs=len(normal),episodes_with_e_le_2=len(normal)+2,
            driver_Ident=dict(z3=sum(r['Ident']['total'] for r in raw),cvc5=sum(r['Ident']['total'] for r in ce),altergo=sum(r['Ident']['total'] for r in ce)),
            per_invocation_Ident_max=dict(raw=max(r['Ident']['total'] for r in raw),ce=max(r['Ident']['total'] for r in ce)),
            maximum_formula_mass=max(r['maximum_reconstructed_formula_mass_upper'] for r in allrows),
            maximum_candidate_stored_formula_occurrences=max(r['candidate_storage']['stored_formula_occurrences_upper'] for r in allrows),
            Ident=total('Ident'),kernel=total('kernel'),candidate_operations=total('candidate_operations')))
    return dict(scope='Five fixed domains, all registered roots, three selected first-inline routes; conditional guarded source attachment',
        cases=cases,registered_roots=sum(c['registered_roots'] for c in cases),
        nontrivial_registered_roots=sum(c['nontrivial_registered_roots'] for c in cases),
        ordinary_root_driver_pairs=sum(c['ordinary_root_driver_pairs'] for c in cases),
        first_inline_episodes_all_five_processes_upper=sum(c['episodes_with_e_le_2'] for c in cases),
        all_five_processes=dict(Ident=sum(c['Ident']['total']['with_global_e_le_2'] for c in cases),
            kernel={k:sum(c['kernel'][k]['with_global_e_le_2'] for c in cases) for k in cases[0]['kernel']},
            candidate_operations={k:sum(c['candidate_operations'][k]['with_global_e_le_2'] for c in cases) for k in cases[0]['candidate_operations']}),
        budgets=dict(per_process_save_callbacks=2,per_process_saves=3,per_process_escape_e=2,
            stage_receives_new_escape_allowance=False,all_five_process_sum_uses_five_distinct_process_allowances=True),
        established_under_named_guards=dict(root_driver_coverage=True,weighted_semantic_shape=True,
            all_direct_inline_Ident=True,kernel_term_and_type_operations=True,candidate_storage_and_candidate_operations=True),
        open=dict(returned_old_hidden_storage=True,returned_old_stored_type_and_validator_operations=True,
            unsuccessful_collision_comparand_cost=True,aggregate_allocation_stack_cache_and_counter_state=True,
            later_transforms_and_printers=True,whole_quiet_capacity_rule=True),
        source_argument_machine_checked=False,new_native_runs=0,predecessor_checkers_replayed=0)

if __name__=='__main__':
    from project import HERE
    import json
    families=[json.loads((HERE/f'{c}-family.json').read_text()) for c in CASES]
    print(json.dumps(compose(families),sort_keys=True,indent=2))
