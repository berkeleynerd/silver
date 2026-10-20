"""Source-operation interfaces for the three post-inline stages, natural integers."""
import json
from inventory import HERE,R56,R57,CASES,read

# Separate later-stage allowances. No R57 first-inline validator unit is reused.
# A traversal unit includes its opening substitutions and copied saved images.
TRAVERSALS={
 'eliminate_builtin':dict(context=16,goal=4,
   source_sites=dict(termination_open_and_walk=2,inductive_free_check=1,
     inductive_prefix_and_positivity=2,inductive_type_scans=2,
     declaration_hash=1,successful_declaration_comparison_operands=2,
     known_map_definition_open_and_symbol_fold=2,match_definition_open_and_walk=2)),
 'remove_unused':dict(context=8,goal=4,
   source_sites=dict(dependency_definition_open_and_symbol_fold=2,
     known_map_definition_open_and_symbol_fold=2,match_definition_open_and_walk=2)),
 'detect_polymorphism':dict(context=2,goal=4,
   source_sites=dict(proposition_type_fold=1,goal_known_symbol_fold=1,goal_match_walk=1))}

def unit(M,P,K,V,T,A):
    Ko=K+2*P*P
    Ro=M*(1+Ko*V)
    U=M+(P+1)*Ro
    return dict(M=M,P=P,K=K,V=V,T=T,A=A,K_open=Ko,R_open=Ro,
      term_and_opening_entries=U,free_variable_scan_entries=M*V*U,
      type_node_entries=(A+2)*T*T*U)

def compose(inventories,driver):
    envelopes={d['case']:d for d in read(R57/'result.json')['domains']}
    stages=list(TRAVERSALS)
    totals={s:{} for s in stages};domains=[]
    for inv in inventories:
        case=inv['case'];env=envelopes[case];f=read(R56/f'{case}-family.json')
        counts={int(k):v for k,v in inv['context_kind_counts'].items()}
        C=inv['context_declarations']+1
        context_keys=env['original_context_keys']
        T=env['T'];A=env['A']
        uc=unit(env['M'],env['P'],env['returned_map_entries_upper'],env['V'],T,A)
        # Immutable raw task history plus all Z3 additions and at most one
        # extra metadata tdecl per non-expanding rule/history pair. Expanding
        # remove-all rules are already covered by Z3's exact event inventory.
        H=inv['raw_task_nodes_upper']*(1+driver['extra_rules_per_history_upper'])+inv['z3_metadata_add_events']+1
        S=inv['symbol_universe_upper'];D=inv['raw_dependency_events']
        closure_writes=C*(S+D)
        closure_fold_entries=S*(C+closure_writes)
        nonterm_type=16*(C*(A+1)*T+inv['ground_data']['founded_type_entries']+inv['ground_data']['founded_constructor_entries'])
        routes={}
        for route in ('raw','ce'):
            r=inv['routes'][route];rows=[]
            af=r['logic_formals'];bl=r['logic_body_slots'];bi=r['inductive_slots'];ba=r['axiom_slots']
            for root in f['stages'][route]['roots']:
                p=root['maximum_body_bound_plus_formal_slots_upper'];m=root['maximum_reconstructed_formula_mass_upper']
                cs=root['candidate_storage']
                ug=unit(m,p,cs['delayed_map_entries_upper'],cs['seed_value_nodes_upper'],T,A)
                bg=root['goal_output'][1]
                direct_ident=dict(eliminate_builtin=3*af+2*bl+3*bi+ba+bg,
                    remove_unused=3*af+bl+bi+ba+bg,detect_polymorphism=bg)
                demand={}
                for stage in stages:
                    a=TRAVERSALS[stage]
                    d={key:context_keys*a['context']*uc[key]+a['goal']*ug[key]
                       for key in ('term_and_opening_entries','free_variable_scan_entries','type_node_entries')}
                    # Overcharge the entire fixed head/type/data family in
                    # each stage, regardless of removal and mutual exclusions.
                    d['type_node_entries']+=nonterm_type+(2 if stage=='remove_unused' else 0)
                    d['direct_Ident_registrations']=direct_ident[stage]
                    d['task_add_requests']=(H if stage!='detect_polymorphism' else 2)
                    d['task_fold_callback_entries']=H*(1 if stage!='remove_unused' else 2)
                    d['Hsdecl_constructor_requests']=(counts.get(3,0)+counts.get(4,0)+counts.get(1,0) if stage=='eliminate_builtin' else 0)
                    d['tdecl_constructor_requests']=(C if stage=='eliminate_builtin' else int(stage=='detect_polymorphism'))
                    d['type_application_requests']=(counts.get(1,0) if stage=='eliminate_builtin' else 0)
                    d['metadata_argument_visits']=8*H # tagged sets, raw meta folds, removal tests
                    d['eager_debug_cardinal_calls']=(3*C if stage=='detect_polymorphism' else 0)
                    d['dependency_closure_record_writes']=(closure_writes if stage=='remove_unused' else 0)
                    d['dependency_closure_id_fold_entries']=(closure_fold_entries if stage=='remove_unused' else 0)
                    d['successful_context_equality_semantic_entries']=(2*context_keys*env['M'] if stage=='eliminate_builtin' else 0)
                    demand[stage]=d
                rows.append(dict(goal=root['goal'],check_id=root['check_id'],root_index=root['root_index'],
                                 goal_candidate_unit=ug,demand=demand))
            routes[route]=rows
        # Z3 raw, CVC5 CE, Alt-Ergo CE. Alt-Ergo has no detect_polymorphism.
        composition={}
        for stage in stages:
            ordinary=routes['raw']+routes['ce']*(1 if stage=='detect_polymorphism' else 2)
            allrows=routes['raw']+routes['ce']
            names=ordinary[0]['demand'][stage]
            out={k:dict(ordinary=sum(r['demand'][stage][k] for r in ordinary),
                        one_episode_max=max(r['demand'][stage][k] for r in allrows)) for k in names}
            for k,v in out.items():
                v['with_shared_e_le_2']=v['ordinary']+2*v['one_episode_max']
                totals[stage][k]=totals[stage].get(k,0)+v['with_shared_e_le_2']
            composition[stage]=out
        domains.append(dict(case=case,registered_roots=f['registered_roots'],
            preparation_episodes_upper=env['preparation_episodes_upper'],
            context_unit=uc,task_nodes_upper=H,dependency_universe_upper=S,
            dependency_closure_writes_upper=closure_writes,
            nonterm_type_entries_per_stage_upper=nonterm_type,routes=routes,composition=composition))
    combined={k:sum(t[k] for t in totals.values()) for k in next(iter(totals.values()))}
    assert all(n<2**62 for n in combined.values())
    return dict(domains=domains,stage_totals=totals,combined_totals=combined,
        traversal_allowances=TRAVERSALS,
        budgets=dict(ordinary_preparations=354,preparations_upper=364,
            process_global_e_upper=2,fresh_stage_escape_allowance=False,
            per_stage_maxima_share_same_e=True,detect_poly_only_z3_and_cvc5=True),
        complete_for_named_source_operation_categories=True,
        R56_and_R57_preceding_charges_remain_required=True,
        source_arguments_machine_checked=False,
        ordinary_runtime_resources=dict(native_allocation_collection_stack_unpriced=True,
            no_new_aggregate_RAM_gate=True,no_allocator_internals_proof_required=True),
        remaining=dict(failed_hashcons_comparands=True,map_table_string_integer_primitive_costs=True,
            initial_counters_plus_total_later_demands=True,
            later_selected_transformations_and_printers=True,whole_quiet_capacity=True))

if __name__=='__main__':
    out=compose([read(HERE/f'{c}-inventory.json') for c in CASES],read(HERE/'driver-inventory.json'))
    (HERE/'result.json').write_text(json.dumps(out,sort_keys=True,indent=2)+'\n')
    print(json.dumps(out['combined_totals'],sort_keys=True,indent=2))
