"""Pure current-packet arithmetic; all call totals are mathematical integers."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = ROOT/'docs/evidence'
MAX_INT = 2**62-1
MAX_ARRAY = 2**54-1
MAX_STRING = 2**57-9

def rows(packet):
    return {r['case']: r for r in json.loads((EV/packet/'result.json').read_bytes())['cases']}

def height(n):
    # A valid height-balanced tree with child-height difference <=2 has at
    # at least 2**floor(h/3)-1 nodes. Add four for temporary join/rotation operands.
    return 3*(n+1).bit_length()+4

def derive():
    entry=rows('retained-why-printer-entry-20261020')
    demand=rows('retained-why-printer-demand-20261023')
    names=rows('retained-why-printer-name-tables-20261023')
    raw=rows('retained-why-raw-name-length-20261023')
    attrs=rows('retained-why-hsattr-demand-20261023')
    cases=[]
    for case,d in demand.items():
        dim=d['dimensions']; S,P,H,A,T=(dim[k] for k in ['S','P','H','A','T'])
        E=d['episodes_upper']; K=entry[case]['dimensions']['K']; V=entry[case]['dimensions']['V']
        assert all(dim[k] == names[case]['dimensions'][k] for k in dim)
        assert H == entry[case]['dimensions']['task_nodes']
        C=H*((2*S+P)*(T+1)+2*(A+1)*(T+2)+8)
        assert C == names[case]['candidate']['id_unique_calls_per_fresh_printer_upper']
        W=raw[case]['candidate_or_printed_unique_name_bytes_upper']
        Uattr=attrs[case]['lifetime_requests_and_increments_upper']
        assert attrs[case]['suffix_requests']['solver_request_printer'] == 0
        Kopen=K+2*P*P
        Ropen=S*(1+Kopen*V)
        U=S+(P+1)*Ropen
        assert U == entry[case]['dimensions']['validator_U']
        J=2*H*S
        Z=J+H
        X=2*C+H
        Y=3*C
        # Symbol-fold root: one type and possible ls per stored term, plus
        # binder/pattern types and signature arguments, all independently charged.
        Bsym=(T+1)*(Ropen+2*P+2*S+A+2)
        # Source partition: <=3HS opening entries, <=2HP binder/type entries,
        # <=4HA signature entries, and <=16H root/header helper entries.
        helper_roots=H*(3*S+2*P+4*A+16)
        helper_calls=16*helper_roots*(S+1)*U
        owners=[]
        def add(name,kind,updates,cardinality,source,**extra):
            r={'owner':name,'kind':kind,'update_or_entry_calls_per_request_upper':updates,
               'cardinality_or_length_upper':cardinality,'source':source,
               'process_calls_upper':E*updates}
            if kind in ('Extmap','Extset','Stdlib.Set'):
                r['height_and_temporary_height_operand_upper']=height(2*cardinality+1)
                r['single_point_operation_comparison_calls_upper']=r['height_and_temporary_height_operand_upper']
                r['single_point_operation_node_steps_upper']=8*r['height_and_temporary_height_operand_upper']
                r['single_binary_tree_operation_node_visits_upper']=16*(cardinality+1)**2
            r.update(extra);owners.append(r)
        add('info_syn (including sm0)','Extmap',4*H,4*H,'printer.ml:518-541; discriminate.ml:489-499',lookups_upper=C+4*H,override_values=[0,1,2],key_kind='ident')
        add('info_rliteral','Extmap',H,H,'printer.ml:543-544',lookups_upper=J,key_kind='ident')
        for n in ['meta_model_projection','meta_record_def']:
            add(n,'Extset',H,H,'task.ml:337-347; smtv2.ml:301-314',membership_calls_upper=H)
        add('info_model','Stdlib.Set',Z,Z,'cntexmp_printer.ml:27-79; smtv2.ml:301-318,359-365,476-482',remove_calls_upper=Z,ordering_semantics_claimed=False)
        add('type_coercions','Extmap',H,H,'smtv2.ml:301-306',find_def_calls_upper=H)
        add('type_coercions inner Sls','Extset',H,H,'smtv2.ml:305')
        add('type_fields','Extmap',H,H,'smtv2.ml:309-313',find_def_calls_upper=H)
        add('type_fields inner list','list',H,H,'smtv2.ml:312')
        add('type_sorts','Extmap',X,X,'smtv2.ml:267-270,390-395,654-658,908-909,925-927,963-965',key_bytes_upper=max(347,W))
        add('ty_tysymbol','Extmap',Y,Y,'smtv2.ml:270,377,386',final_find_opt_calls_upper=X)
        add('final filtered type_sorts','Extmap',X,X,'smtv2.ml:835-839',map_filter_root_calls_upper=1,key_bytes_upper=max(347,W))
        for n,src in [('constructors','856-857'),('constr_proj_id','897-898'),('record_fields','899-903')]:
            add(n,'Extmap',2*H,2*H,'smtv2.ml:'+src,key_bytes_upper=W if n=='constructors' else None,inner_list_length_upper=A if n!='constructors' else 0)
        add('constructor field_names/reverse/maps','list',2*H*A,A,'smtv2.ml:858-894,898,901',fold_index_upper=A+1,field_name_bytes_upper=W)
        add('projection attribute filter','Extset',2*H*A*Uattr,Uattr,'smtv2.ml:873-880',filter_root_calls_upper=2*H*A,substring_length_upper='existing attr_string length - 12; <= Sys.max_string_length')
        add('info_labels','Extmap',J,J,'cntexmp_printer.ml:104-129; smtv2.ml:421-424',find_calls_upper=J,key_bytes_upper=W)
        add('info_labels inner Sattr and temporary union','Extset',J*Uattr,Uattr,'cntexmp_printer.ml:110-127',union_and_fold_root_calls_each_upper=J,at_location_concatenations=0)
        add('read-only attribute tests','Extset',5*J+2*H,Uattr,'cntexmp_printer.ml:81-96,131-138; ident.ml:370-414; smtv2.ml:994-995',membership_calls_upper=5*J+2*H,exists_calls_upper=H,prefix_test_entries_upper=3*H*Uattr,new_container_allocations=0)
        for n,src in [('incr_list_axioms','812-813'),('incr_list_ldecls','681-687')]:
            add(n,'list',H,H,'smtv2.ml:'+src,final_iteration_entries_upper=H,formal_list_length_upper=A)
        add('queried_terms/model_map','Extmap',0,0,'smtv2.ml:736-767; R65 CE-off')
        add('vc_info/scalar info fields','fixed record',2*J+4*H,3,'cntexmp_printer.ml:16-25,81-96; smtv2.ml:823-826',integer_counter_fields=0,new_string_fields=0)
        add('prelude th_used','list',H,H,'printer.ml:424-429')
        cap=1 << (max(16,H)-1).bit_length()
        add('prelude dedup ht','mutable Hashtbl',H,H,'printer.ml:417-422; hashtbl.ml:66-76,115-152,344-409',mem_calls_upper=H,add_calls_upper=H,initial_capacity=16,capacity_upper=cap,scalar_size_interval=[0,H],largest_threshold_or_growth_operand=2*cap,largest_array_index_or_loop_successor=cap,largest_array_block_bytes=8*(cap+1),partial_resize_reachable_cells_upper=2*H,each_lookup_or_rehash_chain_visits_upper=H)
        add('syntax args arrays','array',C,max(A,T),'printer.ml:317-343',per_array_words_upper=max(A,T),index_upper=max(A,T)-1,Array_of_list_length_and_successor_upper=max(A,T))
        add('syntax precedence arrays','array',C,0,'printer.ml:325-326,342-343',num_ref_upper=17,precedence_subtractions=0)
        add('syntax scanners/substrings','scalar/string',16*C,347,'printer.ml:148-218,299-315',scalar_absolute_operand_upper=348,negative_substring_length_may_escape=True)
        add('unused lazy type-argument maps/arrays','array',0,0,'printer.ml:288-297,330-338; R62 no active %t/%v')
        add('Stv type-free-variable sets','Extset',0,0,'term.ml:87-89,1209; smtv2.ml:668,689,772,787-788,817',root_calls_upper=2*H,read_type_entries_upper=2*H*(T+1)*(Ropen+P+A+1))
        add('V26Par used-symbol Sid','Extset',H*Bsym,Bsym,'decl.ml:442-446,518-524; smtv2.ml:985-987',root_calls_upper=H)
        add('opening/substitution Mvs maps and enumeration spines','Extmap',helper_calls,2*Kopen,'term.ml:594-624,739-831',map_API_calls_upper=helper_calls,occurrence_count_operand_upper=max(S,V),occurrence_product_upper=max(S,V)**2,enumeration_spine_length_upper=height(2*Kopen))
        add('opening/copy Sattr maps','Extset',helper_calls,Uattr,'term.ml:648-675,739-831; ident.ml:187-219',map_API_calls_upper=helper_calls)
        add('opening argument/trigger/binder/pattern lists','list',helper_calls,max(S,P,A,T),'term.ml:588-624,648-675,739-831',binder_list_length_upper=P,trigger_list_length_upper=S,application_list_length_upper=A,type_argument_list_length_upper=T,case_branch_list_length_upper=2,selected_pattern_argument_list_length=0)
        add('general nonboolean branch Mvs/combine','Extmap',0,0,'smtv2.ml:547-640; R61 Boolean-only cases')
        add('Number.print_in_base scalar state','scalar',65*J,0,'number.ml:167-194; R66 literals',digits_interval=[-64,64],radix_upper=16,digit_remainder_upper=15,character_code_upper=70,physical_bigint_storage='retained native scalar service')
        largest_height=max(r.get('height_and_temporary_height_operand_upper',0) for r in owners)
        guards={
            'tree_height_arithmetic':largest_height+2<=MAX_INT,
            'Mvs_occurrence_products':max(S,V)**2<=MAX_INT,
            'prelude_hashtbl_size_growth_indices':max(H,2*cap,8*(cap+1))<=MAX_INT and cap<=MAX_ARRAY,
            'syntax_array_lengths_indices':max(A,T)<=MAX_ARRAY and max(A,T)+1<=MAX_INT,
            'explicit_list_lengths_and_projection_successor':max(H,A+1,Kopen)<=MAX_INT,
            'new_name_and_template_strings':max(347,W)<=MAX_STRING,
            'scanner_and_literal_scalars':348<=MAX_INT,
            'attribute_substrings':True,
        }
        assert all(guards.values())
        cases.append({'case':case,'dimensions':dict(dim,E=E,K=K,V=V,K_open=Kopen,R_open=Ropen,U=U,C=C,Uattr=Uattr,W=W),
            'owners':owners,'largest_tree_height_operand_upper':largest_height,
            'native_operand_guards':guards,'all_guards_pass':all(guards.values()),
            'source_argument_pending_independent_review':True})
    return {'scope':'Remaining private selected SMTv2 request-printer owners, including local helper containers and prelude dedup table',
        'cases':cases,'one_global_escape_budget':2,'save_entering_callbacks':2,'saves_upper':3,
        'fresh_owners_per_process_bound':'E; never E times the individual owner capacity',
        'source_argument_machine_checked':False,'full_printer_claim':False,'full_119_claim':False,
        'aggregate_RAM_gate':False,'historical_checker_replays':0}

if __name__ == '__main__':
    (HERE/'result.json').write_text(json.dumps(derive(),indent=2)+'\n')
