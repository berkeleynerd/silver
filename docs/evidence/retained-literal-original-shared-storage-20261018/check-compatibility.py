#!/usr/bin/env python3
"""Exact emission-integration compatibility; preserves the accepted 208 checks."""
import argparse
import ast
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import time

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
PREVIOUS='e12e010fd1da984a45a6955928f3fc979aec4306'
INTEGRATION='7573e127ffb020ddfb1214491179c59442e7798b'
REVIEW='bee47bdef117d904931141ab4142a62ba6837058'
REVIEW_IDENTITY=dict(bytes=11729,
    sha256='0a93765653b15c3688ee0a4d599b5d48b6394fc39798ed936f4c00045336e745')
PACKET=HERE.relative_to(REPO)
AGGREGATE=Path('docs/evidence/retained-literal-pipeline-20261018')
TARGETS={
    'compose.py':dict(bytes=128015,sha256='d9c6c6ae53411dfeef1d5e5539b08339a95c0fe7fb0979476f98af7dfc4d1fd4'),
    'inputs.json':dict(bytes=35727,sha256='c47f1a014f8ce30f1484d4d6dd0c46ec2bb5f3caee983a7afb3c063665d7de75'),
    'result.json':dict(bytes=285628,sha256='6ce3e21dd9a061effc5b812a66f93725a2a5804b7597c466a3f51e8ed13a18b5')}
PROJECTIONS=['source','source_counts','complete_path_bound','native_original_Main_storage',
    'native_original_String_storage','native_original_helper_storage','native_synthetic_function_storage',
    'native_warning_map_demand','native_pool_lifetime','native_collector_callbacks',
    'native_counter_emission_interface','unresolved_predicates','failed_conditional_predicates',
    'whole_literal_pipeline_capacity_established']


def historical(revision,path):
    return subprocess.check_output(['git','show',revision+':'+str(path)],cwd=REPO)


def load(path,name):
    spec=importlib.util.spec_from_file_location(name,path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module


def functions(raw):
    return {n.name:ast.dump(n,include_attributes=False) for n in ast.parse(raw).body if isinstance(n,ast.FunctionDef)}


def main():
    started=datetime.now(timezone.utc).isoformat();timer=time.perf_counter()
    m=load(HERE/'compose.py','shared_current')
    parser=argparse.ArgumentParser(description=__doc__);m.arguments(parser)
    parser.add_argument('--previous-repo',type=Path,required=True)
    args=parser.parse_args();rows=[]

    def check(name,condition):
        if not condition:raise AssertionError(name)
        rows.append(dict(name=name,passed=True))

    def reject(name,fn,fragment):
        try:fn()
        except ValueError as exc:check(name,fragment in str(exc))
        else:raise AssertionError(name+' accepted')

    target_rows=[]
    for name,expected in TARGETS.items():
        path=AGGREGATE/name;raw=(REPO/path).read_bytes()
        check('exact integrated '+name,m.identity(raw)==expected and raw==historical(INTEGRATION,path))
        target_rows.append(dict(path=str(path),previous=m.identity(historical(PREVIOUS,path)),current=expected))
    previous_inputs=json.loads(historical(PREVIOUS,PACKET/'inputs.json'))
    adapted=copy.deepcopy(previous_inputs)
    for row in adapted:
        path=Path(row['path'])
        if path.parent==AGGREGATE and path.name in TARGETS:row.update(TARGETS[path.name])
    check('only three exact input pins changed',adapted==m.read(HERE/'inputs.json'))
    for name in ('compose.py','check.py','sources.json','result.json','check-results.json'):
        check('accepted shared file retained '+name,(HERE/name).read_bytes()==historical(PREVIOUS,PACKET/name))
    review_path=Path('docs/reviews/review-literal-original-shared-e12e010fd1.md')
    check('exact historical independent review retained',
        m.identity(historical(REVIEW,review_path))==REVIEW_IDENTITY)
    old_functions=functions(historical(PREVIOUS,AGGREGATE/'compose.py'))
    new_functions=functions((REPO/AGGREGATE/'compose.py').read_bytes())
    changed=[name for name,body in old_functions.items() if new_functions.get(name)!=body]
    check('only pre-existing top-level evaluate changed',changed==['evaluate'])
    derive=next(n for n in ast.parse((HERE/'compose.py').read_bytes()).body
                if isinstance(n,ast.FunctionDef) and n.name=='derive')
    reads={n.slice.value for n in ast.walk(derive) if isinstance(n,ast.Subscript)
           and isinstance(n.value,ast.Name) and n.value.id=='aggregate'
           and isinstance(n.slice,ast.Constant)}
    check('consumed projection inventory covers every direct aggregate read',reads==set(PROJECTIONS))
    previous_packet=args.previous_repo/PACKET
    for name in ('compose.py','inputs.json','sources.json'):
        check('previous Context source '+name,(previous_packet/name).read_bytes()==historical(PREVIOUS,PACKET/name))
    old=load(previous_packet/'compose.py','shared_previous')
    old_context=old.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    context=m.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    check('combined Context succeeds with historical source checks',context.repository_inputs_verified==38
        and context.complete_source_files_verified==60
        and context.aggregate_context.original_storage_source_validation['Main']['historical_repository_files_verified']==1
        and context.aggregate_context.emission_source_validation['historical_predecessor_repository_files_verified']==1)
    previous_aggregate=json.loads(historical(PREVIOUS,AGGREGATE/'result.json'))
    current_aggregate=m.read(REPO/AGGREGATE/'result.json')
    check('all consumed retained projections unchanged',all(previous_aggregate[k]==current_aggregate[k] for k in PROJECTIONS))
    retained=m.read(HERE/'result.json');retained.pop('offline_run')
    fresh=m.evaluate(REPO/AGGREGATE/'fixture.json',context)
    check('fresh default equals accepted shared semantic result',fresh==retained)
    fixture=m.read(REPO/AGGREGATE/'fixture.json')
    fixture['source']=str((REPO/AGGREGATE/fixture['source']).resolve())
    fixture['shared_inputs']={k:str((REPO/AGGREGATE/v).resolve()) for k,v in fixture['shared_inputs'].items()}
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n';tail=b'\nend Main;\n'
    variants=[('mixed_empty_8192',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("'+b'a'*8192+b'");'+tail),
        ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail)]
    outcomes=[dict(name='Hello',source=fresh['source'],shared_result_matches_accepted=True,
        retained_failed_conditional_predicates=fresh['retained_aggregate_failed_conditional_predicates'])]
    with tempfile.TemporaryDirectory(prefix='silver-shared-compat-') as tmp:
        root=Path(tmp);descriptor=root/'descriptor.json';source=root/'main.adb'
        descriptor.write_text(json.dumps(fixture))
        for name,raw in variants:
            source.write_bytes(raw)
            prior=old_context.aggregate.evaluate(descriptor,old_context.aggregate_context,source)
            current=context.aggregate.evaluate(descriptor,context.aggregate_context,source)
            check(name+' actual-source consumed projections match',all(prior[k]==current[k] for k in PROJECTIONS))
            a=old.derive(prior,old_context);b=m.derive(current,context)
            check(name+' shared result matches',a==b)
            check(name+' broad negatives preserved',not any(b[k] for k in (
                'whole_literal_pipeline_capacity_established','complete_global_counter_lifetime_closed',
                'complete_original_gigi_storage_closed','complete_collector_lifetime_closed',
                'later_consumers_included','aggregate_RAM_gate','production_admission_changed'))
                and b['complete_imported_allocation_events'] is None
                and b['complete_imported_allocation_bytes'] is None
                and b['remaining_Ada_integer_storage']['incoming_occupied'] is None
                and b['remaining_Ada_integer_storage']['incoming_allocated'] is None)
            if name=='5000_calls':
                check('5000 relocation failure remains exact',b['retained_aggregate_failed_conditional_predicates']==
                    ['literal_output_linker_representation'])
            outcomes.append(dict(name=name,source=b['source'],
                source_counts={k:v for k,v in b['source_counts'].items() if k!='decoded_literal_lengths'},
                shared_result_matches_previous=True,retained_failed_conditional_predicates=b['retained_aggregate_failed_conditional_predicates']))
        for name,path,value in [
            ('helper ownership',['native_original_String_storage','helper94_additions'],2),
            ('collector zero demand',['native_collector_callbacks','collector_callback_additional_GGC_events'],1),
            ('function frontier',['native_counter_emission_interface','interface','function_definition_numbers','Main'],2),
            ('warning finalizer',['native_warning_map_demand','conditional_map_transfer','additional_singleton_finalizer_registrations_ceiling'],0)]:
            changed=copy.deepcopy(current_aggregate);obj=changed
            for key in path[:-1]:obj=obj[key]
            obj[path[-1]]=value
            reject(name+' mutation rejected',lambda:m.derive(changed,context),'join')
        source.write_bytes(shell+b'Silver_IO.Put (Unknown);'+tail)
        reject('nonliteral source still rejected',lambda:m.evaluate(descriptor,context,source),'literal')
        old_here=m.HERE;m.HERE=root
        pins=m.read(old_here/'inputs.json');pins[0]['sha256']='0'*64
        (root/'inputs.json').write_text(json.dumps(pins))
        reject('future pin mismatch still rejected',lambda:m.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),'shared-storage input')
        m.HERE=old_here
    result=dict(previous_shared_freeze=PREVIOUS,accepted_review=REVIEW,integration_base=INTEGRATION,
        exact_retargeted_inputs=target_rows,consumed_projection_keys=PROJECTIONS,
        changed_preexisting_top_level_aggregate_functions=['evaluate'],
        aggregate_Context_has_additional_emission_validation=True,shared_derivation_unchanged=True,
        checks=len(rows),all_passed=True,checks_detail=rows,actual_source_cases=outcomes,
        retained_208_check_identity=m.identity((HERE/'check-results.json').read_bytes()),
        broad_208_success_rerun=False,native_tool_executions=0,whole_pipeline_capacity_established=False,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_model_confirmation=None,token_cost_measurements=None,
        started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:result[k] for k in ('checks','all_passed','broad_208_success_rerun','native_tool_executions','elapsed_seconds')}))


if __name__=='__main__':main()
