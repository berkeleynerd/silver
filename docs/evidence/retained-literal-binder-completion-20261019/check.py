#!/usr/bin/env python3
"""Focused new owner/boundary checks; no predecessor suite or native replay."""
import argparse
from copy import deepcopy
import json
from pathlib import Path
import runpy
import time

HERE=Path(__file__).resolve().parent
api=runpy.run_path(str(HERE/'compose.py'))


def program(body):
    return b'with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\nbegin\n'+body+b'\nend Main;\n'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',type=Path,required=True)
    args=p.parse_args(); start=time.monotonic(); checks=0; cases=[]
    context=api['Context']()
    # Different coordinates, calls, nulls and literal length leave binder
    # finite producer domains fixed while retaining exact physical identity.
    sources=[('C3N4',program(b'Silver_IO.Put_Line ("binder");\n'*3+b'null;\n'*4)),
        ('mixed_quotes',program(b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");')),
        ('large_literal',program(b'Silver_IO.Put ("'+b'a'*8192+b'");')),
        ('many_calls',program(b'Silver_IO.Put ("z");\n'*97))]
    projection=None
    for name,raw in sources:
        r=api['evaluate'](raw,context)
        assert r['source_identity']==api['identity'](raw); checks+=1
        assert r['binder_source_coverage_complete'] and r['binder_capacity_established']; checks+=1
        assert r['residuals']==[] and r['GPR_or_Gprbind_jobs']==0; checks+=1
        assert not r['whole_literal_pipeline_capacity_established'] and not r['production_launcher_adopted']; checks+=1
        selected={k:r[k] for k in ('names','graph','fixed_process_owners')}
        if projection is None: projection=selected
        assert selected==projection;checks+=1
        cases.append(dict(case=name,source=r['source_identity'],counts=r['source_counts'],binder_fits=True))
    raw=sources[0][1]
    invocation=context.inv['build'](raw,context.inv_context)
    assert api['evaluate'](raw,context,invocation)['binder_capacity_established'];checks+=1
    for name,change in [('source',lambda r:r['source_identity'].update(bytes=0)),
        ('job',lambda r:r['processes'][1]['argv'].append('-f')),
        ('environment',lambda r:r['processes'][1]['environment'].update(GCC_ROOT='/bad')),
        ('GPR',lambda r:r.update(GPR_or_Gprbind_jobs=1))]:
        bad=deepcopy(invocation);change(bad)
        try:api['evaluate'](raw,context,bad)
        except ValueError:checks+=1;cases.append(dict(case='reject_'+name,rejected=True))
        else:raise AssertionError(name)
    # Native ALI writer capacity remains required despite the absence of GPR.
    r=api['evaluate'](raw,context,path_bytes=977)
    assert not r['ALI_local_result']['selected_ALI_consumer_local_interfaces_fit'];checks+=1
    assert not r['binder_capacity_established'] and r['binder_source_coverage_complete'];checks+=1
    assert r['ALI_local_result']['Main_ALI_interface']['conditions']['writer'] is False;checks+=1
    cases.append(dict(case='P977_retains_native_writer_guard',binder_fits=False,residuals=r['residuals']))
    n=projection['names'];g=projection['graph']
    assert n['nonparser_entry_events']==3500 and n['nonparser_character_slots']==2608914;checks+=1
    assert n['entry_table']['demand']==20111 and n['entry_table']['capacities']==[6000,12000,24000];checks+=1
    assert n['character_table']['demand']==12838913 and n['character_table']['capacities'][-1]==25600000;checks+=1
    assert n['entry_table']['old_and_new_bytes']==576000 and n['character_table']['old_and_new_bytes']==38400000;checks+=1
    assert g['owned_coexisting_representation_bytes_upper']==3960128;checks+=1
    assert len(g['owner_maps'])==10 and g['outgoing_sets']['initial_buckets_each']==8;checks+=1
    # Model actual native growth, rather than merely re-evaluating its bound.
    states=0; max_capacity=0
    for initial in range(1,181):
        capacity=max(8,initial); peak=capacity
        for count in range(1291):
            if count/capacity>1.5:
                old=capacity;capacity*=2;peak=max(peak,old+capacity)
            b=api['hash_storage'](count,initial)
            assert capacity<=b['bucket_capacity_upper'] and peak<=b['coexisting_bucket_slots_upper']
            states+=1;max_capacity=max(max_capacity,capacity)
    checks+=states
    cases.append(dict(case='all_initials_and_growth_counts',states=states,largest_actual_capacity=max_capacity))
    # Per-vertex outgoing sets cover concentration, dispersion and zero degree.
    for degrees in ([367]+[0]*1289,[1]*367+[0]*923,[0]*1290,[3]*122+[1]+[0]*1167):
        bucket_overlap=0
        for degree in degrees:
            capacity=8;peak=8
            for count in range(1,degree+1):
                if count/capacity>1.5:
                    old=capacity;capacity*=2;peak=max(peak,old+capacity)
            bucket_overlap+=peak
        assert sum(degrees)<=367 and bucket_overlap<=g['outgoing_sets']['coexisting_bucket_slots_upper'];checks+=1
    # Successor rather than largest issued ID is required by sequencers.
    bad=api['graph_storage'](1,api['I32'],0,api['I32'])
    assert not bad['conditions']['invocation_ID_successors'];checks+=1
    assert not api['hash_storage'](api['I32'],180)['fits'];checks+=1
    for demand,initial,expected in [(6000,6000,6000),(6001,6000,12000),
        (12000,6000,12000),(12001,6000,24000),(12800000,50000,12800000),
        (12800001,50000,25600000)]:
        t=api['table_storage'](demand,initial,1,0,api['I32'])
        assert t['capacities'][-1]==expected;checks+=1
    bad=api['name_storage'](16611,10229999,32766,512,83,1048,7)
    assert not bad['conditions']['name_payload_Short'];checks+=1
    assert not api['table_storage'](api['I32'],50000,1,0,api['I32'])['fits'];checks+=1
    for raw_bad in (raw+b'\v',program(b'Silver_IO.Put (Unknown);')):
        try:api['evaluate'](raw_bad,context)
        except ValueError:checks+=1
        else:raise AssertionError('invalid source accepted')
    elapsed=time.monotonic()-start
    result=dict(all_checks_pass=True,checks=checks,seconds=elapsed,cases=cases,
        new_owner_projection_at_P512=projection,native_tool_executions=0,
        predecessor_suite_replays=0,selected_model='GPT-6 Astra',selected_effort='Extra High',
        runtime_settings_confirmed=False,token_usage=None,monetary_cost=None)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(checks=checks,seconds=elapsed,all_checks_pass=True)))


if __name__=='__main__':main()
