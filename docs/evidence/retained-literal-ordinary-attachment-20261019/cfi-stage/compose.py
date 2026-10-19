#!/usr/bin/env python3
"""Attach accepted named ordinary native capacities to actual-source236."""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
PRIOR = E/'retained-literal-ggc-attachment-20261019'
CFI = E/'retained-literal-cfi-cfg-ordinary-20261019'
PIPELINE = E/'retained-literal-pipeline-20261018'


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def require(value,message):
    if not value:
        raise ValueError(message)


class Context:
    def __init__(self,gcc_root,ada_root,plugin_include,gcc_match=None):
        pins = runpy.run_path(str(E/'retained-literal-lifetime-attachment-20261019/compose.py'))
        manifest = read(HERE/'inputs.json')
        pins['check_pins'](manifest)
        self.prior = runpy.run_path(str(PRIOR/'compose.py'))
        self.prior_context = self.prior['Context'](gcc_root,ada_root,plugin_include,gcc_match)
        self.reference = read(PRIOR/'result.json')
        require(len(self.reference['conditions']) == 236,'accepted236 condition schema')
        self.cfi = runpy.run_path(str(CFI/'derive.py'))
        self.cfi_reference = read(CFI/'result.json')
        self.cfi_inputs = self.cfi['verify_inputs'](gcc_root)
        require(self.cfi_inputs == dict(source_files=33,repository_files=23,source_excerpts=26),
            'complete accepted CFI/CFG source inventory')
        self.keys178 = read(E/'retained-literal-mem-ssa-attachment-20261019/result.json')['conditions'].keys()
        self.validation = dict(accepted_current_and_historical_records=len(manifest['files']),
            predecessor=self.prior_context.validation,CFI_CFG=self.cfi_inputs,
            identity_sets_overlap_and_must_not_be_added=True,no_new_historical_input_exception=True,
            source_configuration_and_owner_checks_precede_arithmetic=True,
            upstream_false_or_uncomputed_short_circuits_ordinary_evaluation=True,
            predecessor_suites_rerun=False,source_arguments_are_reviewed_handwritten_arguments=True)


def project(selected,keys):
    """Project actual guard values; never fabricate or promote a prerequisite."""
    result = copy.deepcopy(selected)
    for field in ('conditions','conditional_conditions'):
        result[field] = {k:selected[field][k] for k in keys}
    return result


def validate_joins(raw,selected,context):
    require(selected['conditions'].keys() == selected['conditional_conditions'].keys() ==
        context.reference['conditions'].keys(),'preserve accepted236 condition keys')
    require(all(type(v) is bool or v is None for field in ('conditions','conditional_conditions')
        for v in selected[field].values()),'boolean or uncomputed inherited236 arithmetic')
    # Original219 is boolean in every admitted predecessor result. The new17
    # GGC guards can be null when those prerequisites fail; keep these nulls in
    # the actual236 record and exclude only their keys from this validation.
    keys219 = context.prior_context.reference['conditions'].keys()
    require(all(type(selected[field][k]) is bool for field in ('conditions','conditional_conditions')
        for k in keys219),'original219 prerequisite schema remains boolean')
    source,counts = context.prior['validate_joins'](raw,project(selected,keys219),context.prior_context)
    core,mem,pools = (selected[k] for k in ('core_result','selected_native_MEM_counter_lifetime',
        'selected_native_shared_bitmap_pool_lifetime'))
    c,n = counts['output_calls'],counts['null_statements']
    x = dict(B=2*n+10,expansion_block_slots=n+6,T=n+5,K0=98+3*c,K=99+5*c,
        R0=64*c+n+16,M=7*c+5*n+20,Uf=7*c+7*n+46)
    # Check the accepted CFI source theorem's complete non-arithmetic premises
    # even on failed/uncomputed prerequisite paths. Do not enter its API by
    # changing inherited summaries or conditions to true.
    for row in (core,mem,pools):
        require(row['source'] == source and row['source_counts'] == counts,'ordinary same-source complete owner')
    require(core['actual_shared_inputs'] == selected['actual_shared_inputs'],'ordinary shared configuration inputs')
    shape,rtl,p = core['RTL_shape'],mem['RTL'],pools['extents']
    for key,value in dict(block_slots_upper=x['B'],edges_upper=x['B']-1,
        CFI_traces_upper=x['T'],CFI_rows_upper=2*n+10,first_unused_pseudo_number_upper=x['K'],
        first_unused_UID_upper=x['Uf'],IRA_entry_chain=x['M']).items():
        require(shape[key] == value,'ordinary accepted RTL shape owner '+key)
    for key,value in dict(pre_split_first_unused_pseudo_upper=x['K0'],
        final_first_unused_pseudo_upper=x['K'],final_first_unused_UID_upper=x['Uf']).items():
        require(rtl[key] == value,'ordinary accepted MEM/RTL owner '+key)
    for key in ('B','K','M','Uf'):
        require(p[key] == x[key],'ordinary accepted shared bitmap/ET extent '+key)
    dom = pools['dominance']
    require(dom['live_nodes_combined_upper'] == 2*x['B'] and dom['live_occurrences_combined_upper'] == 4*x['B'] and
        dom['shared_incoming_and_retained_pool_state_closed'] is True,'ordinary accepted shared ET owner')
    require(pools['new_GGC_events'] == 0 and mem['new_mem_attrs_events'] == 0,'ordinary disjoint GGC owners')
    ec = mem['emission_counter_endpoints']
    require(ec['CFI_label_counter_initial_value'] == 0 and ec['CFI_label_counter_at_exit_upper'] == 5 and
        ec['CFI_label_signed_temporary_maximum'] == 4 and ec['Main_label_alignment_span_upper'] == x['Uf'],
        'ordinary accepted CFI and emission label owners')
    ledger = selected['selected_native_GGC_ledger']
    if ledger is not None:
        require(ledger['source'] == source and ledger['source_counts'] == counts and
            ledger['source_path'] == selected['source_path'] and ledger['launch'] == selected['launch'] and
            ledger['complete_path_bound'] == selected['complete_path_bound'],'existing GGC actual source owner')
        rows = ledger['owner_rows']
        require(len({r['owner'] for r in rows}) == len(rows) == 50 and
            sum(r['positive_GGC_requests_upper'] for r in rows) == ledger['total_positive_GGC_events_upper'] ==
            selected['selected_positive_GGC_events_upper'] == selected['selected_active_pages_upper'],
            'existing complete disjoint GGC event owners')
    else:
        require(selected['selected_positive_GGC_events_upper'] is selected['selected_active_pages_upper'] is None,
            'existing uncomputed GGC owner bounds')
    return source,counts


def arithmetic_guards(cfi,context):
    expected = context.cfi_reference['local_representation_checks'].keys()
    checks = {k:None for k in expected} if cfi is None else cfi['local_representation_checks']
    require(checks.keys() == expected,'preserve accepted CFI/CFG guard schema')
    guards = {}
    for key,value in checks.items():
        require(cfi is None or type(value) is bool,'boolean ordinary CFI/CFG arithmetic '+key)
        guards['native_ordinary_CFI_CFG_'+key] = value
    value = None if cfi is None else cfi['conditional_named_ordinary_container_capacity_established']
    require(cfi is None or type(value) is bool,'boolean ordinary CFI/CFG capacity conjunction')
    guards['native_ordinary_CFI_CFG_conditional_capacity'] = value
    return guards


def attach(raw,selected,context):
    source,counts = validate_joins(raw,selected,context)
    reasons = [field+'.'+key+('=uncomputed' if value is None else '=false')
        for field in ('conditions','conditional_conditions') for key,value in selected[field].items() if value is not True]
    for name,value in [('selected.evaluated_predicates_pass',selected['evaluated_predicates_pass']),
        ('selected.conditional_arithmetic_pass',selected['conditional_arithmetic_pass']),
        ('core_result.conditional_arithmetic_pass',selected['core_result']['conditional_arithmetic_pass'])]:
        require(type(value) is bool,'boolean inherited capacity summary '+name)
        if not value:reasons.append(name+'=false')
    # All236 passing implies the actual older178 projection and summaries pass.
    # Neither a failed178 premise nor a null GGC check is promoted for this call.
    cfi = None if reasons else context.cfi['attach'](raw,project(selected,context.keys178),
        selected['selected_native_shared_bitmap_pool_lifetime'],selected['source_path'],selected['launch'])
    guards = arithmetic_guards(cfi,context)
    require(not (guards.keys() & selected['conditions'].keys()),'new ordinary guards cannot replace inherited236')
    if cfi is not None:
        require(cfi['source'] == source and cfi['source_counts'] == counts and
            cfi['source_path'] == selected['source_path'] and cfi['launch'] == selected['launch'] and
            cfi['actual_shared_inputs'] == selected['actual_shared_inputs'] and
            cfi['complete_path_bound'] == selected['complete_path_bound'] and
            cfi['same_source_accepted_owners_verified'] and cfi['inherited_guard_count'] == 178,
            'actual-source CFI/CFG theorem attachment')
        require(cfi['retained_owners']['shared_bitmap_and_ET'] == selected['selected_native_shared_bitmap_pool_lifetime']['dominance'] and
            cfi['retained_owners']['emission_labels'] == selected['selected_native_MEM_counter_lifetime']['emission_counter_endpoints'] and
            cfi['retained_owners']['initial_CF_CFG_GGC'] == selected['core_result']['native_initial_CF_CFG_lifetime']['additional_GGC_request_events_upper'],
            'exact existing ordinary pool GGC and emission owners')
        require(all(cfi[k] == 0 for k in ('new_GGC_events','new_scalar_registrations','new_array_registrations',
            'new_shared_bitmap_or_ET_pool_blocks')) and not cfi['dominance']['ET_pool_backing_recharged'],
            'ordinary theorem adds zero GGC finalizers and existing pool blocks')
        require(cfi['aggregate_ordinary_bytes'] is cfi['lifetime_ordinary_request_total'] is cfi['total_GGC_events'] is None and
            not any(cfi[k] for k in ('aggregate_RAM_gate','complete_all_ordinary_helper_lifetimes_closed',
            'complete_native_capacity','complete_collector_lifetime_closed','whole_literal_pipeline_capacity_established',
            'production_admission_changed')),'named ordinary scope remains narrow')
    result = copy.deepcopy(selected)
    for field in ('conditions','conditional_conditions'):result[field].update(guards)
    passed = all(v is True for v in result['conditions'].values()) and not reasons
    conditional = all(v is True for v in result['conditional_conditions'].values()) and not reasons
    result.update(scope='Actual-source selected literal route with named ordinary CFI/CFG capacities, accepted conditional GGC partition and collector indexed storage; remaining native/pipeline capacity open',
        evaluated_predicates_pass=passed,conditional_arithmetic_pass=conditional,
        failed_predicates=[k for k,v in result['conditions'].items() if v is False],
        failed_conditional_predicates=[k for k,v in result['conditional_conditions'].items() if v is False],
        unresolved_predicates=[k for k,v in result['conditions'].items() if v is None],
        selected_native_CFI_CFG_ordinary_lifetime=cfi,validation=context.validation,
        selected_named_ordinary_capacity_established=passed and conditional)
    result['ordinary_attachment'] = dict(source=source,source_counts=counts,inherited_guards=236,
        new_guards=len(guards),guards=guards,source_configuration_and_owner_checks_performed=True,
        ordinary_status='not_computed_upstream_prerequisites' if cfi is None else 'computed',
        not_computed_reasons=reasons,ordinary_evaluation_performed=cfi is not None,
        original178_projection_preserves_actual_values=True,nullable_GGC_checks_preserved=True,
        all_existing_ordinary_GGC_and_finalizer_owners_preserved=True,new_GGC_events=0,
        new_scalar_registrations=0,new_array_registrations=0,new_shared_bitmap_or_ET_pool_blocks=0,
        selected_named_ordinary_capacity_established=passed and conditional,
        accepted_CFI_implementation='f21a34471976916160fc82b8be62cfac2d0f6c65',
        accepted_CFI_review='4034d2d02a2ef7f0e5772f932ce0b2114df0217a',
        frozen_pending_and_incomplete_flags_preserved_as_history=True,
        independent_attachment_review_status='pending')
    result['accounting'] += (' Named ordinary CFI/CFG capacities attach to actual source/configuration and '
        'existing RTL, MEM, bitmap/ET and emission owners with zero GGC/finalizer/pool delta. Inherited false '
        'or uncomputed checks leave the ordinary theorem uncomputed; all original values and owners persist. '
        'Individual request ceilings do not supply aggregate RAM or lifetime ordinary totals.')
    result['open_joins']['native_remaining_lifetime_and_collector'] = (
        'Named ordinary CFI trace/index/queue/label, expansion maps/head-end/local declarations, jump register '
        'counts, CFG traversal and dominance scratch capacities are attached conditionally. IRA/LRA private '
        'arrays and allocation/cost-class pools, remaining ordinary helpers and stack, and other required '
        'native/producer/proof/parent phases remain open. Existing conditional GGC/indexed collector bounds '
        'are unchanged. Production launcher/materialization and source/binary correspondence remain separate.')
    return result


def evaluate(descriptor_path,context,source_override=None):
    selected = context.prior['evaluate'](descriptor_path,context.prior_context,source_override)
    return attach(Path(selected['source_path']).read_bytes(),selected,context)


if __name__ == '__main__':
    start,timer = datetime.now(timezone.utc).isoformat(),time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor',type=Path,default=PIPELINE/'selected-route.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),args.source)
    result['offline_run']=dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(passed=result['evaluated_predicates_pass'],guards=len(result['conditions']))))
