#!/usr/bin/env python3
"""One affected selected-route attachment run; no predecessor/broad suites."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import tempfile
import time

HERE=Path(__file__).resolve().parent


def main():
    started=datetime.now(timezone.utc).isoformat(); timer=time.perf_counter()
    m=runpy.run_path(str(HERE/'selected-route.py'))
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(HERE/'compose.py'))['arguments'](parser)
    parser.add_argument('--output',type=Path,required=True); args=parser.parse_args()
    ctx=m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    rows=[]; summaries=[]

    def check(name,value):
        if not value:raise AssertionError(name)
        rows.append(dict(name=name,passed=True))

    def reject(name,fn,fragment):
        try:fn()
        except ValueError as exc:check(name,fragment in str(exc))
        else:raise AssertionError(name+' accepted')

    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'; tail=b'\nend Main;\n'
    variants=[('Hello',hello,True),
        ('mixed_empty_8192',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("'+b'x'*8192+b'");'+tail,True),
        ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail,True),
        ('32766_calls',shell+b'Silver_IO.Put ("x");\n'*32766+tail,False),
        ('expanded_column_failure',shell+b'Silver_IO.Put ("'+b'x'*33000+b'");'+tail,False)]
    with tempfile.TemporaryDirectory(prefix='silver-selected-route-check-') as temp:
        source=Path(temp)/'main.adb'
        for name,raw,passing in variants:
            source.write_bytes(raw)
            result=m['evaluate'](HERE/'selected-route.json',ctx,None if name=='Hello' else source)
            core=result['core_result']; invocation=result['selected_native_invocation']; numeric=result['native_Ada_numeric']
            c=result['source_counts']['output_calls']
            check(name+' same actual source identities',result['source']==core['source']==invocation['source_identity']==m['identity'](raw)
                and numeric['source']['sha256']==result['source']['sha256'])
            check(name+' all old predicates preserved except three source gaps',all(result['conditions'][k]==
                (core['conditional_conditions'][k] if k in m['CLOSED'] else v) for k,v in core['conditions'].items())
                and all(result['conditional_conditions'][k]==v for k,v in core['conditional_conditions'].items()))
            check(name+' selected final diagnostics',result['evaluated_predicates_pass']==passing
                and result['conditional_arithmetic_pass']==passing and result['unresolved_predicates']==[]
                and set(core['unresolved_predicates'])==set(m['CLOSED'])
                and ('historical-in-derivation' in result['core_result_scope']))
            check(name+' selected source assessments closed independently of production',all(
                result['source_family_condition_assessments'][k]['source_family_premises_closed']
                and not result['source_family_condition_assessments'][k]['production_launcher_adopted'] for k in m['CLOSED']))
            check(name+' all numeric guards conjunctive',all(result['conditions']['native_Ada_numeric_'+k]==v
                for k,v in numeric['checks'].items()) and numeric['demands']==dict(Uints=28420+9*c,
                    Udigits=107726+(70+ctx.numeric_context.model['uint_digits'](c+2))*c,Ureals=67,Rep_Table=504))
            check(name+' immutable core GGC ledger unchanged',core['native_original_shared_storage']['partial_ledger']==
                ctx.core['attach_original_shared_storage'](dict(source=core['source'],source_counts=core['source_counts'],
                    complete_path_bound=core['complete_path_bound'],**{k:core[k] for k in
                    core['native_original_shared_storage']['source_capacity_projection_keys'] if k not in ('source','source_counts','complete_path_bound')},
                    whole_literal_pipeline_capacity_established=False,
                    unresolved_predicates=core['unresolved_predicates'],
                    failed_conditional_predicates=[k for k,v in core['conditional_conditions'].items()
                        if not k.startswith('native_original_shared_') and not v]),ctx.core_context)['partial_ledger'])
            check(name+' missing totals and broad flags remain open',result['complete_imported_allocation_events'] is None
                and result['complete_imported_allocation_bytes'] is None and not any(result[k] for k in
                ('whole_literal_pipeline_capacity_established','complete_native_capacity','complete_proof_pipeline_capacity',
                 'complete_parent_storage_closed','production_launcher_adopted','production_admission_changed','aggregate_RAM_gate'))
                and not invocation['proof_library_verification_waived'] and invocation['fixed_Silver_compile_jobs']==0)
            check(name+' 39 linker guards and exact conservative input preserved',invocation['link_interface']==core['literal_output_linker_historical_conservative']
                and len(core['literal_output_linker_refinement']['unchanged_other_checks'])==39
                and all(core['literal_output_linker']['link']['checks'][k]==v for k,v in
                    core['literal_output_linker_refinement']['unchanged_other_checks'].items()))
            if name=='Hello':
                baseline=result
                check('Hello accepted numeric exact equality',numeric==m['read'](m['E']/'retained-literal-ada-numeric-20261018/result.json'))
                check('Hello separate partial2312 and numeric28429',core['native_original_shared_storage']['partial_ledger']['known_selected_GGC_event_subtotal']==2312
                    and numeric['demands']['Uints']==28429)
            if name=='5000_calls':
                check('5000 old conservative failure remains diagnostic',invocation['link_interface']['link']['failed_sufficient_checks']==['fixed_signed_relocation_reach']
                    and core['literal_output_linker']['link']['failed_sufficient_checks']==[] and result['failed_predicates']==[])
            if name=='32766_calls':
                check('scope digit transition returns numeric success and linker failure',
                    numeric['demand_rows']['Main_constructor']['Udigits']==62*c
                    and numeric['all_selected_checks_pass']
                    and 'literal_output_linker_representation' in result['failed_predicates'])
            if name=='expanded_column_failure':
                check('real capacity failure returns full graph and all guards',result['failed_predicates']==
                    ['Main_expanded_columns','Main_ALI_interface','ALI_consumer_local_interfaces','GPR_parent_DW_local_interface']
                    and invocation['selected_native_launch_graph_computable'] and len(result['conditions'])==len(core['conditions'])+8)
            summaries.append(dict(name=name,source=result['source'],calls=c,demands=numeric['demands'],
                evaluated_predicates_pass=result['evaluated_predicates_pass'],failed_predicates=result['failed_predicates'],
                unresolved_predicates=result['unresolved_predicates'],core_unresolved_predicates=core['unresolved_predicates']))
        core=baseline['core_result'];invocation=baseline['selected_native_invocation'];numeric=baseline['native_Ada_numeric']
        for key in core['conditional_conditions']:
            changed=copy.deepcopy(core);changed['conditional_conditions'][key]=False
            if key not in m['CLOSED']:changed['conditions'][key]=False
            r=m['attach'](hello,changed,invocation,numeric,ctx)
            check('inherited guard failure stays conjunctive '+key,key in r['failed_predicates'] and not r['evaluated_predicates_pass'])
        for key in numeric['checks']:
            changed=copy.deepcopy(numeric);changed['checks'][key]=False;changed['all_selected_checks_pass']=False
            r=m['attach'](hello,core,invocation,changed,ctx)
            check('numeric guard failure stays conjunctive '+key,'native_Ada_numeric_'+key in r['failed_predicates']
                and not r['evaluated_predicates_pass'])
        for key in ('selected_native_launch_graph_computable','selected_main_emission_to_GAS_object_route_bound',
                    'selected_fixed_link_input_materialization_computable'):
            changed=copy.deepcopy(invocation);changed[key]=False
            r=m['attach'](hello,core,changed,numeric,ctx)
            check('invocation guard failure stays conjunctive '+key,'native_invocation_'+key in r['failed_predicates'])
        for label,path,value,fragment in [
            ('source identity',['source_identity','sha256'],'0'*64,'source/count'),
            ('counts',['source_counts','output_calls'],2,'source/count'),
            ('common path',['common_Main_bindings','phase1','path'],'/tmp/wrong/main.adb','common Main'),
            ('System',['shared_System','identity','bytes'],1,'configuration/System'),
            ('emission',['emission_interface','final_chain'],1,'exact emission'),
            ('link input',['link_interface','link','layout','retained_endpoint'],1,'conservative linker'),
            ('binder family',['binder_object_family','GGC_events_upper'],1,'binder family')]:
            changed=copy.deepcopy(invocation);obj=changed
            for k in path[:-1]:obj=obj[k]
            obj[path[-1]]=value
            reject(label,lambda:m['attach'](hello,core,changed,numeric,ctx),fragment)
        changed=copy.deepcopy(invocation)
        next(row for row in changed['materialization'] if row['role']=='silver_io.o')['identity']['bytes']=1
        reject('fixed object hash',lambda:m['attach'](hello,core,changed,numeric,ctx),'fixed object/linker')
        changed=copy.deepcopy(core);changed['Main_assembler_object_interface']['ELF']['file_bytes_upper']=-1
        reject('exact ELF interface',lambda:m['attach'](hello,changed,invocation,numeric,ctx),'assembly/ELF/storage')
        changed=copy.deepcopy(numeric);changed['demand_rows']['original_Main_constant_size_callbacks']['Uints']+=1
        reject('numeric ownership',lambda:m['attach'](hello,core,invocation,changed,ctx),'numeric demand ownership')
        descriptor=m['read'](HERE/'selected-route.json');descriptor['core_descriptor']=str(HERE/'selected-core-fixture.json')
        descriptor['runtime']['cwd']='/tmp/silver-literal-pipeline-20261018'
        path=Path(temp)/'route.json';path.write_text(json.dumps(descriptor))
        reject('historical short root cannot impersonate graph',lambda:m['evaluate'](path,ctx),'accepted source and temporary path classes')
        check('fixed route path conventions',len(invocation['graph']['project_root'])==109 and
            invocation['path_bytes']==513 and core['complete_path_bound']==512)
        check('historical fixture unchanged and distinct route',m['read'](HERE/'fixture.json')['launch']['native_Main'] !=
            core['launch']['native_Main'] and ctx.core_context.original_shared_source_validation['current_repository_files_verified']==35)
        baseline['offline_run']=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),
            scope='Hello generated once within affected attachment check; no separate replay')
        (HERE/'selected-route-result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    output=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        checks=len(rows),passed=rows,variants=summaries,validation=ctx.validation,
        implementation_inputs={name:m['identity']((HERE/name).read_bytes()) for name in
            ('selected-route.py','selected-route.json','selected-core-fixture.json','selected-route-inputs.json','check-selected-route.py')},
        native_tool_executions=0,predecessor_suites_rerun=False,broad_suites_rerun=False,
        selected_model=None,selected_effort=None,runtime_confirmed_model_effort=None,token_cost_measurements=None,
        validation_rework=dict(scope='Current scope-width repair; earlier 97-check attachment evidence remains in frozen64e347db16.',
            correction='Retain base-32768 scope digit width across the 32765/32766-call transition.',
            rerun_reason='Numeric formula and dependent exact-source join changed; this affected check includes the former rejection.'))
    args.output.write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:output[k] for k in ('checks','elapsed_seconds','native_tool_executions')}))


if __name__=='__main__':main()
