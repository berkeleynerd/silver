#!/usr/bin/env python3
"""Additive selected-Ada transfer over a verified current-source predecessor.

No predecessor evaluator, compiler, capture or prover is imported/executed.
The caller verifies the source with the existing complete recognizer and passes
its fresh predecessor record. Context verifies source/evidence pins once.
"""
from pathlib import Path
import copy, hashlib, json, runpy
HERE=Path(__file__).resolve().parent
_partial=runpy.run_path(str(HERE/'derive.py'))
named_arithmetic,table,require,I32,I64=(_partial[k] for k in ('arithmetic','table','require','I32','I64'))
REPO=HERE.parents[2]
PRIOR='docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json'
SWITCHES=['-Wno-free-nonheap-object','-gnatA','-gnat2022','-gnata','-gnato','-gnatx','-mtune=generic','-march=x86-64','-gnateI1','-fsplit-wide-types']

def identity(raw):return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())

class Context:
    def __init__(self,ada_root,repository_root=REPO):
        self.ada_root=Path(ada_root);self.repository_root=Path(repository_root)
        self.inputs=json.loads((HERE/'completion-inputs.json').read_text())
        self.tables=json.loads((HERE/'completion-tables.json').read_text())
        self.census=json.loads((HERE/'fixed-table-census.json').read_text())['rows']
        closure=json.loads((HERE/'closure-owner-audit.json').read_text())
        for row in closure['source_files']:
            require(identity((self.ada_root/row['path']).read_bytes())=={k:row[k] for k in ['bytes','sha256']},'closure source pin '+row['path'])
        partial_inputs=json.loads((HERE/'inputs.json').read_text())
        for row in partial_inputs['files']:
            if row['root']=='repository':p=self.repository_root/row['path']
            elif row['root']=='ada':p=self.ada_root/row['path']
            else:
                require(row['path'].startswith('gcc/ada/'),'known GCC Ada build input')
                p=self.ada_root/row['path'].removeprefix('gcc/ada/')
            require(identity(p.read_bytes())==row['identity'],'retained partial source/evidence pin '+row['path'])
        for row in self.inputs['files']:
            require(identity((self.ada_root/row['path']).read_bytes())==row['identity'],'Ada source pin '+row['path'])
        for row in self.inputs['repository_files']:
            require(identity((self.repository_root/row['path']).read_bytes())==row['identity'],'repository evidence pin '+row['path'])
        for row in self.inputs['excerpts']:
            lines=(self.ada_root/row['path']).read_bytes().decode().split('\n')
            require('\n'.join(lines[row['first_LF_line']-1:row['last_LF_line']])==row['text'],'literal LF source correspondence')
        prior=json.loads((self.repository_root/PRIOR).read_text())
        self.required_conditions=frozenset(prior['conditional_conditions'])
        require(len(self.required_conditions)==367,'retained condition inventory')
        self.verified_inputs=dict(source_files=len(self.inputs['files']),repository_files=len(self.inputs['repository_files']),literal_LF_excerpts=len(self.inputs['excerpts']),closure_source_files=len(closure['source_files']),retained_partial_file_pins=len(partial_inputs['files']))

def arithmetic(c,n,path=512):
    a=named_arithmetic(c,n,path)
    data=json.loads((HERE/'completion-tables.json').read_text())
    tables={}
    for row in data['rows']:
        d=row['demand_upper']
        if row['symbol']=='osint__file_name_chars__last_valX':d=1580*(path+1)
        t=table(d,row['initial'],row['increment_percent'],row['component_bytes_upper'],row['low'])
        t['owner']=row['owner'];t['demand_basis']=row['demand_basis'];tables[row['symbol']]=t
    objects=dict(Ada_argument_pointer_array=25*16+16,Ada_argument_each_String=max(24,path+8)+16,
        Ada_argument_each_local_copy=max(24,path+8)+16,
        Osint_File_Names_array=27*16+16,Osint_File_Indexes_array=27*4+16,
        selected_source_name_String=path+16,Config_File_Names_one_pointer_array=16+16,
        Config_File_Name=path+16,Mapping_File_Name=path+16,Output_Object_File_Name=path+16,
        each_saved_compilation_switch=max(map(len,SWITCHES))+16,
        each_selected_path_copy_or_join=2*path+32+16,
        each_search_path_element=path+16,Osint_search_file_literal=15+16,
        Osint_ALI_suffix=3+16,Fname_default_pattern=5+16,Fname_default_separator=1+16,
        configured_pattern_or_separator=path+16,
        Osint_file_hash_buckets=1021*8,Osint_file_hash_wrapper=32+3*16,
        SFN_hash_buckets=101*8,SFN_hash_wrapper=16,
        FPT_Mode_Table=1000*6*16,
        Atree_each_optional_field_check_array=data['optional_field_check_each_array_bytes_upper'],
        each_generated_node_or_entity_field_array=data['IL_field_enum_count']*16+16,
        fixed_membership_Alts=(41234+1)*32+16,
        fixed_discrete_interval_array=41234**2*32+16,
        fixed_case_choice_table=(41234**2+1)*48+16,
        Sem_Case_each_Link=4*16)
    checks=dict(named_partial=a['passed'],all67_tables=all(t['passed'] for t in tables.values()),
        all_individual_objects=all(v<=I64 for v in objects.values()),
        argument_count_and_successor=27+1<=I32,argument_and_path_successors=max(24,path+8,2*path+32)+1<=I32,
        physical_open_filename_append=1580*(path+1)+1<=I32,
        fixed_type_and_field_enum_indices=max(data['IL_type_enum_count'],data['IL_field_enum_count'])+1<=I32,
        fixed_interval_choice_count_successor=41234**2+1<=I32,
        fixed_copy_nesting_counter=(41234+1)*41234<=I32)
    return dict(counts=dict(C=c,N=n),partial_named=a,new67_tables=tables,
        individual_objects_bytes_upper=objects,stored_compilation_switches=SWITCHES,
        stored_compilation_switch_payload_characters=sum(map(len,SWITCHES)),
        fixed_semantic_projection=dict(new_Main_case_or_membership_or_generic_inputs=0,
            new_Main_general_semantic_graph_copy_inputs=0,reference_identity_renaming_preserves_edges=True,
            outer_scope_saves_owned_by_existing_common_terms=True,
            numeric_cache_misses_owned_by_existing_numeric_transfer=True,
            spelling_changes_owned_by_existing_name_and_new_path_terms=True,
            fixed_local_termination_and_representability='successful fixed execution plus source read projection; no physical stack-byte claim',
            fixed_interval_and_choice_count_upper=41234**2,
            fixed_semantic_copy_rank='lexicographic unvisited original entities, remaining fixed nonentity graph height; successful fixed traversal excludes a nonentity-only cycle; list cursors advance',
            fixed_semantic_copy_counted_nesting_upper=(41234+1)*41234),
        Main_traversal=dict(statement_work_recurrence='T(c,n)=T0+c*Tcall+n*Tnull; each statement returns before Next',
            active_statement_worker_recurrence='D(c+1,n)=max(D(c,n),Dcall); D(c,n+1)=max(D(c,n),Dnull)',
            local_numeric_query_descriptor=dict(H=4,A=19),
            syntax_and_lexical_scope_rank='strict child/parent chain; sibling traversal is iterative',
            aggregate_stack_bytes=None),
        checks=checks,passed=all(checks.values()),new_variable_count_restrictions=0,
        aggregate_RAM_gate=False,complete_native_capacity=False,actual_source_adapter=False)

def _owner(row,record,a):
    symbol=row['symbol'];name=symbol.split('__')[-2]
    if symbol in a['new67_tables']:return dict(owner=a['new67_tables'][symbol]['owner'],checks_pass=a['new67_tables'][symbol]['passed'])
    if symbol=='lib__units__last_val':
        return dict(owner='core_result.Main_ALI_interface.Main_ALI_writer.Units_table',checks_pass=record['core_result']['Main_ALI_interface']['Main_ALI_writer']['Units_table']['all_selected_checks_pass'])
    for key,t in a['partial_named']['named_fixed_tables'].items():
        if key.lower()==name:return dict(owner='partial_named.named_fixed_tables.'+key,checks_pass=t['passed'])
    for key,t in a['partial_named']['zero_attempt_diagnostic_tables'].items():
        if key.lower()==name:return dict(owner='partial_named.zero_attempt_diagnostic_tables.'+key,checks_pass=t['passed'])
    components=record['selected_native_frontend_storage']['components']
    order=['numeric','configuration','physical_sources','invocation','core_tables']
    for component in order:
        for key,t in components[component]['tables'].items():
            normalized=key.lower().removeprefix('ali_')
            if normalized==name:return dict(owner='selected_native_frontend_storage.components.'+component+'.tables.'+key,checks_pass=t['all_selected_checks_pass'])
    raise ValueError('Unreconciled actual table owner '+symbol)

def apply(frontend_record,conditions,context):
    """Compose a freshly source-verified predecessor; conditions may extend367.

    Returns unknown/false without derived capacity when any supplied condition
    is unknown/false. There is no caller-settable residual-safe condition.
    """
    require(isinstance(context,Context),'verified source/evidence context required')
    require(type(conditions) is dict and context.required_conditions<=set(conditions),'all retained367 conditions required')
    require(all(v is True or v is False or v is None for v in conditions.values()),'three-valued conditions')
    r=frontend_record;core=r['core_result'];fe=r['selected_native_frontend_storage'];counts=core['source_counts']
    require(fe['source_counts']==counts and fe['source']==core['source'],'same-source frontend projection')
    require(counts['source_sha256']==core['source']['sha256'] and counts['source_bytes']==core['source']['bytes'],'source identity/count agreement')
    c=counts['output_calls'];n=counts['null_statements']
    require(type(c) is int and c>=1 and type(n) is int and n>=0,'selected family C/N')
    require(counts['Put']+counts['Put_Line']==c and len(counts['decoded_literal_lengths'])==c,'source call/literal agreement')
    require(all(type(v) is int and v>=0 for v in counts['decoded_literal_lengths']),'nonnegative decoded literal lengths')
    require(sum(counts['decoded_literal_lengths'])==counts['decoded_literal_bytes'] and max(counts['decoded_literal_lengths'])==counts['maximum_literal_length'],'source literal byte agreement')
    path=core['complete_path_bound'];require(path==512,'selected complete pathname bound')
    require(fe['joined_logical_tables']['node_identities']==41275+19*c+4*n,'actual accepted constructor projection')
    physical=fe['components']['physical_sources']
    require(physical['physical_files_upper']==1580 and physical['permanent_source_entries_upper']==1589,'accepted physical open/source transfer')
    ali=core['Main_ALI_interface'];require(ali['stored_native_switches']==SWITCHES and ali['ALI_A_records']==10 and ali['ALI_A_payload_characters']==110,'actual current saved switch vector')
    a=arithmetic(c,n,path)
    owners={row['symbol']:_owner(row,r,a) for row in context.census}
    require(len(owners)==120 and all(v['owner'] for v in owners.values()),'exact120 owner reconciliation')
    checks=dict(arithmetic=a['passed'],all_inherited_components=fe['all_selected_component_checks_pass'] is True,
                all120_owners=all(v['checks_pass'] is True for v in owners.values()),
                ALI_writer=ali['selected_Main_ALI_interface_fits'] is True)
    pending=[k for k in sorted(conditions) if conditions[k] is not True]
    computed=not pending and all(checks.values())
    return dict(scope='Complete selected Main-process Ada frontend storage and local/counted traversal; fixed and Main work partitioned',
        source=copy.deepcopy(core['source']),source_counts=copy.deepcopy(counts),
        conditions=copy.deepcopy(conditions),pending_conditions=pending,
        retained_conditions={k:conditions[k] for k in sorted(context.required_conditions)},
        pending_retained_conditions=[k for k in pending if k in context.required_conditions],computed=computed,derived=a if computed else None,
        table_owners=owners,exact_reconciled_fixed_census_rows=120,unreconciled_fixed_census_rows=[],
        checks=checks,complete_selected_Ada_frontend_capacity=computed,
        selected_Ada_source_coverage='fixed read projection + actual Main constructor/caller closure + explicit changed path/argv/name terms',
        unresolved_selected_Ada_residuals=[] if computed else pending or [k for k,v in checks.items() if not v],
        caller_settable_residual_safe_premise=False,independent_review='pending',
        whole_literal_pipeline_capacity_established=False,complete_native_capacity=False,
        physical_resource_guarantee=False,aggregate_RAM_gate=False,native_tool_executions=0,
        source_recognizer_executed_here=False,requires_fresh_verified_predecessor=True)
