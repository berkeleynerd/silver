#!/usr/bin/env python3
"""Focused source/arithmetic/ownership/API checks; no predecessor execution."""
from pathlib import Path
import argparse,copy,json,runpy,time
HERE=Path(__file__).resolve().parent

def main():
    p=argparse.ArgumentParser();p.add_argument('--ada-root',required=True);args=p.parse_args();start=time.monotonic()
    m=runpy.run_path(str(HERE/'completion.py'));ctx=m['Context'](args.ada_root)
    prior=json.loads((m['REPO']/m['PRIOR']).read_text());conditions=prior['conditional_conditions'];rows=[]
    def check(name,value):
        if not value:raise AssertionError(name)
        rows.append(dict(name=name,passed=True))
    def reject(name,fn):
        try:fn()
        except (ValueError,KeyError,TypeError):check(name,True)
        else:raise AssertionError(name+' accepted')
    result=m['apply'](prior,conditions,ctx);a=result['derived']
    check('current verified-input record computes selected Ada',result['computed'] and result['complete_selected_Ada_frontend_capacity'])
    check('exact120 owners with no residual symbols',len(result['table_owners'])==120 and not result['unreconciled_fixed_census_rows'])
    check('no whole-native or resource overclaim',not result['complete_native_capacity'] and not result['whole_literal_pipeline_capacity_established'] and not result['physical_resource_guarantee'])
    check('no caller-settable residual-safe flag',result['caller_settable_residual_safe_premise'] is False)
    check('all67 backing objects have positive initialization',len(a['new67_tables'])==67 and all(t['initial']>0 and t['individual_bytes_upper']>0 for t in a['new67_tables'].values()))
    for k in sorted(ctx.required_conditions):
        for value in (False,None):
            bad=dict(conditions);bad[k]=value;x=m['apply'](prior,bad,ctx)
            check('retained condition '+k+'='+str(value),not x['computed'] and x['derived'] is None and not x['complete_selected_Ada_frontend_capacity'])
    bad=dict(conditions);bad.pop(next(iter(ctx.required_conditions)));reject('missing retained condition rejected',lambda:m['apply'](prior,bad,ctx))
    bad=dict(conditions);bad[next(iter(ctx.required_conditions))]=1;reject('integer is not Boolean evidence',lambda:m['apply'](prior,bad,ctx))
    for value in (True,False,None):
        superset=dict(conditions);superset['new_backend_guard']=value
        x=m['apply'](prior,superset,ctx);expected=value is True
        check('condition superset conjunct '+str(value),x['computed'] is expected and x['complete_selected_Ada_frontend_capacity'] is expected and (x['derived'] is not None) is expected and x['conditions']==superset and x['pending_conditions']==([] if expected else ['new_backend_guard']))
    for name,mutate in [
        ('different source identity',lambda x:x['selected_native_frontend_storage']['source'].update(sha256='0'*64)),
        ('different source counts',lambda x:x['selected_native_frontend_storage']['source_counts'].update(null_statements=1)),
        ('wrong constructor count',lambda x:x['selected_native_frontend_storage']['joined_logical_tables'].update(node_identities=1)),
        ('different physical opens',lambda x:x['selected_native_frontend_storage']['components']['physical_sources'].update(physical_files_upper=1)),
        ('historical five saved switches',lambda x:x['core_result']['Main_ALI_interface'].update(stored_native_switches=m['SWITCHES'][:5])),
        ('wrong source-byte identity',lambda x:x['core_result']['source_counts'].update(source_bytes=1))]:
        x=copy.deepcopy(prior);mutate(x);reject(name,lambda x=x:m['apply'](x,conditions,ctx))
    x=copy.deepcopy(prior);x['selected_native_frontend_storage']['components']['numeric']['tables']['Uints']['all_selected_checks_pass']=False
    check('failed inherited numeric owner blocks complete Ada',not m['apply'](x,conditions,ctx)['computed'])
    x=copy.deepcopy(prior);x['core_result']['Main_ALI_interface']['selected_Main_ALI_interface_fits']=False
    check('failed existing ALI writer blocks completion',not m['apply'](x,conditions,ctx)['computed'])
    # These are arithmetic boundary checks, not constructed accepted programs.
    for c,n in [(1,0),(1,1),(2,0),(19,37),(100000,100000)]:
        v=m['arithmetic'](c,n);check('arithmetic C='+str(c)+' N='+str(n),v['passed'] and v['partial_named']['frontend_node_allowance']==41275+19*c+4*n)
    last=(m['I32']-41275-1)//19
    check('node-domain boundary accepted',m['arithmetic'](last,0)['passed'])
    check('node-domain successor rejects overflow',not m['arithmetic'](last+1,0)['passed'])
    for c,n in [(0,0),(1,-1),(True,0),(1,False)]:reject('invalid C/N '+str((c,n)),lambda c=c,n=n:m['arithmetic'](c,n))
    check('fixed square exact',a['fixed_semantic_projection']['fixed_interval_and_choice_count_upper']==1700242756)
    check('fixed counted semantic nesting exact',a['fixed_semantic_projection']['fixed_semantic_copy_counted_nesting_upper']==1700283990)
    check('optional field sets independent of assertion-build assumption',a['individual_objects_bytes_upper']['Atree_each_optional_field_check_array']==6508848)
    check('generated metadata allocations retained',a['individual_objects_bytes_upper']['each_generated_node_or_entity_field_array']==14448)
    check('physical filename demand replaces204',a['new67_tables']['osint__file_name_chars__last_valX']['demand']==810540)
    check('compilation switch demand is actual10',a['new67_tables']['lib__compilation_switches__last_val']['demand']==10 and sum(map(len,m['SWITCHES']))==110)
    check('load stack uses peak42 not lifetime121',a['new67_tables']['lib__load_stack__last_val']['demand']==42)
    check('ALI Units and lib Units have distinct process instances',result['table_owners']['ali__units__last_val']['owner']!=result['table_owners']['lib__units__last_val']['owner'])
    check('numeric tables use corrected numeric owner',result['table_owners']['uintp__uints__last_val']['owner'].endswith('numeric.tables.Uints'))
    closure=json.loads((HERE/'closure-owner-audit.json').read_text())
    check('all inventory candidates have process/site owner',len(closure['allocator_sites'])==312 and len(closure['generic_instantiation_sites'])==223 and all(r['owner'] for r in closure['allocator_sites']+closure['generic_instantiation_sites']))
    output=dict(checks=len(rows),all_passed=True,elapsed_seconds=time.monotonic()-start,input_verification=ctx.verified_inputs,
        rows=rows,read_only_predecessor_JSON=True,native_prover_capture_predecessor_executions=0,
        arithmetic_boundaries_are_not_source_program_evaluations=True,independent_review='pending')
    (HERE/'completion-check-results.json').write_text(json.dumps(output,indent=2)+'\n')
    (HERE/'completion-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in output.items() if k!='rows'}))
if __name__=='__main__':main()
