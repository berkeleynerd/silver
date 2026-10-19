#!/usr/bin/env python3
"""Attach accepted IRA numeric arithmetic to the actual-source305 route."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import time

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
E=REPO/'docs/evidence'
PRIOR=E/'retained-literal-ordinary-attachment-20261019'
NUMERIC=E/'retained-literal-ira-numeric-20261019'
PIPELINE=E/'retained-literal-pipeline-20261018'
CFI_FIELD='selected_native_CFI_CFG_ordinary_lifetime'
IRA_FIELD='selected_native_IRA_ordinary_storage'
LRA_GUARD='native_GGC_LRA_signed_hard_register_frequency'


def read(path):return json.loads(Path(path).read_bytes())


def require(value,message):
    if not value:raise ValueError(message)


class Context:
    def __init__(self,gcc_root,ada_root,plugin_include,gcc_match=None):
        pins=runpy.run_path(str(E/'retained-literal-lifetime-attachment-20261019/compose.py'))
        self.manifest=read(HERE/'inputs.json')
        pins['check_pins'](self.manifest)
        self.prior=runpy.run_path(str(PRIOR/'compose.py'))
        self.prior_context=self.prior['Context'](gcc_root,ada_root,plugin_include,gcc_match)
        self.reference=read(PRIOR/'result.json')
        require(len(self.reference['conditions'])==305,'accepted305 guard schema')
        self.numeric=runpy.run_path(str(NUMERIC/'derive.py'))
        self.numeric_reference=read(NUMERIC/'result.json')
        verified=self.numeric['verify_inputs'](gcc_root)
        require(verified==self.manifest['numeric_source_inventory'],'complete accepted numeric LF/source inventory')
        self.validation=dict(accepted_current_and_historical_records=len(self.manifest['files']),
            predecessor=self.prior_context.validation,numeric=verified,
            inventory_sets_overlap_and_must_not_be_added=True,
            no_new_historical_input_exception=True,
            numeric_fixed_Hello_reconciliation_called=False,
            source_configuration_and_complete_owners_checked_before_short_circuit=True,
            source_argument_is_reviewed_handwritten_argument=True,
            predecessor_suites_rerun=False,pending_outer_IRA_LRA_or_hook_candidate_consumed=False)


def structural_ordinary(leaf,capacity):
    """Remove only explicitly exported arithmetic fields from full comparison."""
    result=copy.deepcopy(leaf)
    for key in ('local_representation_checks',capacity,'failed_predicates'):del result[key]
    return result


def validate_joins(raw,selected,context):
    require(selected['conditions'].keys()==selected['conditional_conditions'].keys()==
        context.reference['conditions'].keys(),'preserve accepted305 condition keys')
    require(all(type(v) is bool or v is None for field in ('conditions','conditional_conditions')
        for v in selected[field].values()),'boolean or uncomputed inherited305 arithmetic')
    # This accepted validation projects actual219 boolean values and preserves
    # the later null GGC state. No failed condition is promoted for an API call.
    keys236=context.prior_context.reference['conditions'].keys()
    source,counts=context.prior['validate_joins'](raw,
        context.prior['project'](selected,keys236),context.prior_context)
    c,n=counts['output_calls'],counts['null_statements']
    x=dict(A=4*c,K=99+5*c,B=2*n+10,M=7*c+5*n+20)
    x['P']=2*x['M']+x['B']
    core=selected['core_result'];pools=selected['selected_native_shared_bitmap_pool_lifetime']
    # Pure old count models validate complete existing owner dictionaries.
    # They are not new numeric evaluation and do not assert passing old guards.
    for field,capacity,expected in [
        (CFI_FIELD,'conditional_named_ordinary_container_capacity_established',
            context.prior_context.cfi['arithmetic'](c,n)),
        (IRA_FIELD,'conditional_named_IRA_allocation_capacity',
            context.prior_context.ira['arithmetic'](c,n))]:
        leaf=selected[field]
        if leaf is None:
            require(any(v is not True for f in ('conditions','conditional_conditions')
                for v in selected[f].values()),'null ordinary owner requires failed/uncomputed prerequisite')
            continue
        expected.update(source=source,source_counts=counts,source_path=selected['source_path'],
            launch=copy.deepcopy(selected['launch']),actual_shared_inputs=copy.deepcopy(selected['actual_shared_inputs']),
            complete_path_bound=selected['complete_path_bound'],same_source_accepted_owners_verified=True)
        if field==CFI_FIELD:
            expected.update(retained_owners=dict(shared_bitmap_and_ET=pools['dominance'],
                initial_CF_CFG_GGC=core['native_initial_CF_CFG_lifetime']['additional_GGC_request_events_upper'],
                emission_labels=selected['selected_native_MEM_counter_lifetime']['emission_counter_endpoints'],
                CFI_rows_and_vectors='existing separate GGC owner; no recharge',
                stack_variable_bitmap='existing shared bitmap/pool owner; no recharge'),inherited_guard_count=178)
        else:
            require(selected['selected_native_GGC_ledger'] is not None,'computed IRA owner requires actual GGC record')
            expected.update(retained_owners=dict(RTL_shape=core['RTL_shape'],shared_bitmap_extents=pools['extents'],
                existing_GGC_positive_events_upper=selected['selected_positive_GGC_events_upper'],
                existing_GGC_owner_rows=selected['selected_native_GGC_ledger']['owner_rows'],
                distinct_LRA_hard_usage_guard=selected['conditions'][LRA_GUARD]),
                accepted_source_implementation='66da47daa2c433a0872e8bbc626e0bb18850426e',
                accepted_source_review='3d00f8af990f45a537f7854e8c898d5c222ee394',
                fixed_Hello_reconciliation_used_as_actual_source_rule=False)
        require(leaf.keys()==expected.keys(),'complete ordinary owner field schema '+field)
        require(structural_ordinary(leaf,capacity)==structural_ordinary(expected,capacity),
            'complete actual ordinary source/configuration/request owners '+field)
        require(leaf['local_representation_checks'].keys()==expected['local_representation_checks'].keys() and
            all(type(v) is bool for v in leaf['local_representation_checks'].values()) and
            type(leaf[capacity]) is bool,'computed ordinary owner arithmetic schema '+field)
    attachment=copy.deepcopy(selected['ordinary_attachment'])
    expected=copy.deepcopy(context.reference['ordinary_attachment'])
    for item in (attachment,expected):
        for key in ('source','source_counts','guards','ordinary_status','not_computed_reasons',
            'ordinary_evaluation_performed','selected_named_ordinary_capacity_established'):del item[key]
    require(attachment==expected and selected['ordinary_attachment']['source']==source and
        selected['ordinary_attachment']['source_counts']==counts,'complete ordinary attachment owner metadata')
    a=selected['ordinary_attachment']['guards']
    require(a.keys()==context.reference['ordinary_attachment']['guards'].keys() and
        all(type(v) is bool or v is None for v in a.values()),'complete existing ordinary attachment guard schema')
    # Bind every numeric theorem extent before any numeric failure branch.
    require(core['RTL_shape']['split_referenced_pseudos_upper']==x['A'] and
        core['RTL_shape']['first_unused_pseudo_number_upper']==x['K'] and
        core['RTL_shape']['block_slots_upper']==x['B'] and
        core['RTL_shape']['IRA_entry_chain']==x['M'],'numeric actual A K B M RTL owners')
    require(all(pools['extents'][k]==x[k] for k in ('K','B','M','P')),'numeric actual K B M P bitmap owners')
    if selected[IRA_FIELD] is not None:
        require(all(selected[IRA_FIELD]['extents'][k]==v for k,v in x.items()),'numeric actual A K B M P IRA owner')
    return source,counts,x


def numeric_guards(leaf,context):
    result={}
    for field,prefix in [('inherited_representation_checks','native_IRA_numeric_inherited_'),
        ('local_numeric_checks','native_IRA_numeric_')]:
        expected=context.numeric_reference[field].keys()
        checks={k:None for k in expected} if leaf is None else leaf[field]
        require(checks.keys()==expected,'preserve accepted numeric guard schema '+field)
        for key,value in checks.items():
            require(leaf is None or type(value) is bool,'boolean IRA numeric arithmetic '+key)
            require(prefix+key not in result,'distinct new numeric predicate')
            result[prefix+key]=value
    value=None if leaf is None else leaf['conditional_selected_IRA_numeric_arithmetic']
    require(leaf is None or type(value) is bool,'boolean IRA numeric capacity conjunction')
    result['native_IRA_numeric_conditional_capacity']=value
    return result


def attach(raw,selected,context):
    source,counts,x=validate_joins(raw,selected,context)
    reasons=[f+'.'+k+('=uncomputed' if v is None else '=false')
        for f in ('conditions','conditional_conditions') for k,v in selected[f].items() if v is not True]
    for name,value in [('selected.evaluated_predicates_pass',selected['evaluated_predicates_pass']),
        ('selected.conditional_arithmetic_pass',selected['conditional_arithmetic_pass']),
        ('selected.named_ordinary_capacity',selected['selected_named_ordinary_capacity_established']),
        ('ordinary_attachment.named_capacity',selected['ordinary_attachment']['selected_named_ordinary_capacity_established']),
        ('core.conditional_arithmetic_pass',selected['core_result']['conditional_arithmetic_pass'])]:
        require(type(value) is bool,'boolean inherited capacity summary '+name)
        if not value:reasons.append(name+'=false')
    arithmetic=None if reasons else context.numeric['arithmetic'](counts['output_calls'],counts['null_statements'])
    guards=numeric_guards(arithmetic,context)
    require(not (guards.keys() & selected['conditions'].keys()),'numeric predicates cannot replace inherited305')
    leaf=None
    if arithmetic is not None:
        require(arithmetic['source_counts']==dict(output_calls=counts['output_calls'],null_statements=counts['null_statements']) and
            arithmetic['extents']==x,'actual numeric complete count and extent transfer')
        require(arithmetic['separate_LRA_signed_usage_guard'] is selected['conditions'][LRA_GUARD],
            'separate actual LRA10000 guard preserved')
        require(all(arithmetic[k]==0 for k in ('new_GGC_events','new_scalar_registrations','new_array_registrations',
            'new_shared_bitmap_or_ET_blocks')) and arithmetic['previous_storage_owners_modified'] is False,
            'numeric theorem cannot recharge existing owners')
        require(all(arithmetic[k] is False for k in ('aggregate_RAM_gate','outer_IRA_helper_capacity_closed',
            'remaining_LRA_arithmetic_closed','all_ordinary_native_capacity','complete_native_capacity',
            'whole_literal_pipeline_capacity_established','production_admission_changed')),'numeric scope remains named')
        leaf=dict(source=source,source_counts=copy.deepcopy(counts),source_path=selected['source_path'],
            launch=copy.deepcopy(selected['launch']),actual_shared_inputs=copy.deepcopy(selected['actual_shared_inputs']),
            complete_path_bound=selected['complete_path_bound'],arithmetic=arithmetic,
            same_source_complete_owners_verified=True,actual_source_numeric_adapter_attached=True,
            frozen_arithmetic_component_status_fields_retained_as_history=True,
            retained_owners=dict(RTL_shape=copy.deepcopy(selected['core_result']['RTL_shape']),
                bitmap_extents=copy.deepcopy(selected['selected_native_shared_bitmap_pool_lifetime']['extents']),
                ordinary_IRA=copy.deepcopy(selected[IRA_FIELD]),
                actual_GGC_owners=copy.deepcopy(selected['selected_native_GGC_ledger']),
                actual_GGC_events_upper=selected['selected_positive_GGC_events_upper'],
                inherited_numeric_guard_owners=copy.deepcopy(context.manifest['inherited_numeric_guard_owners']),
                separate_LRA10000_guard=selected['conditions'][LRA_GUARD]))
    result=copy.deepcopy(selected)
    for field in ('conditions','conditional_conditions'):result[field].update(guards)
    passed=not reasons and all(v is True for v in result['conditions'].values())
    conditional=not reasons and all(v is True for v in result['conditional_conditions'].values())
    result.update(scope='Actual-source selected literal route with named IRA numeric arithmetic, ordinary CFI/CFG and IRA storage, conditional GGC/indexed collector capacity; other native and pipeline obligations remain open',
        evaluated_predicates_pass=passed,conditional_arithmetic_pass=conditional,
        failed_predicates=[k for k,v in result['conditions'].items() if v is False],
        failed_conditional_predicates=[k for k,v in result['conditional_conditions'].items() if v is False],
        unresolved_predicates=[k for k,v in result['conditions'].items() if v is None],
        selected_native_IRA_numeric_arithmetic=leaf,selected_named_IRA_numeric_arithmetic_established=passed and conditional,
        validation=context.validation)
    result['IRA_numeric_attachment']=dict(source=source,source_counts=counts,inherited_guards=305,new_guards=len(guards),guards=guards,
        status='not_computed_upstream_prerequisites' if arithmetic is None else 'computed',not_computed_reasons=reasons,
        selected_named_IRA_numeric_arithmetic_established=passed and conditional,
        inherited_guard_maps_preserved=True,complete_owners_checked_before_short_circuit=True,
        accepted_numeric_source='9ed466e07f5db96f7240b33bb5055ba434deb192',
        accepted_numeric_review='7b702023dc213ced18fcdde6a3846a28cdb5e29b',
        separate_LRA10000_guard_preserved=True,new_GGC_events=0,new_scalar_registrations=0,
        new_array_registrations=0,new_shared_bitmap_or_ET_blocks=0,aggregate_RAM_gate=False,
        earlier_numeric_open_flags_are_component_history=True,independent_attachment_review_status='pending')
    result['accounting']+=' Named IRA numeric arithmetic is attached to actual complete source/configuration/launch and A/K/B/M/P owners without additional charge. Earlier numeric-open fields retain their frozen component scope; no outer IRA/LRA/native/pipeline capacity follows.'
    result['open_joins']['native_remaining_lifetime_and_collector']='Named IRA cost/frequency/equivalence/preference/pressure/fast-priority and allocation-cost arithmetic is attached conditionally. Outer IRA/equivalence/initial-value/reginfo/regstat helper capacity, remaining LRA arithmetic/storage, other helper/stack and native/producer/proof/parent obligations remain open. Existing ordinary/GGC/finalizer/bitmap/ET owners and conditional collector bounds remain unchanged; production materialization/source-binary correspondence stays separate.'
    return result


def evaluate(descriptor_path,context,source_override=None):
    prior=context.prior['evaluate'](descriptor_path,context.prior_context,source_override)
    return attach(Path(prior['source_path']).read_bytes(),prior,context)


if __name__=='__main__':
    start,timer=datetime.now(timezone.utc).isoformat(),time.perf_counter()
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor',type=Path,default=PIPELINE/'selected-route.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();result=evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),args.source)
    result['offline_run']=dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(passed=result['evaluated_predicates_pass'],guards=len(result['conditions']))))
