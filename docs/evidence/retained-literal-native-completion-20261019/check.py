#!/usr/bin/env python3
"""Focused native composition checks. No target execution or broad replay."""
import argparse
import copy
import json
from pathlib import Path
import runpy
import tempfile
import time

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]


def main():
    p=argparse.ArgumentParser(description=__doc__)
    api=runpy.run_path(str(HERE/'compose.py'))
    runpy.run_path(str(REPO/'docs/evidence/retained-literal-pipeline-20261018/compose.py'))['arguments'](p)
    p.add_argument('--gas-root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();start=time.perf_counter();checks=0
    def check(value):
        nonlocal checks
        assert value
        checks+=1
    def rejects(thunk):
        nonlocal checks
        try:thunk()
        except (ValueError,AssertionError):checks+=1
        else:raise AssertionError('invalid interface accepted')
    ctx=api['Context'](a.gcc_root,a.ada_root,a.plugin_include,a.gas_root,a.gcc_match)
    retained=api['read'](HERE/'result.json')
    register=retained['register_result'];raw=Path(register['source_path']).read_bytes()
    check(retained['source']==api['identity'](raw))
    check(retained['complete_native_capacity'] and len(retained['conditions'])==475)
    check(set(retained['coverage'])==set(api['STAGES']) and all(retained['coverage'].values()))
    check(not retained['complete_proof_pipeline_capacity'] and not retained['production_SPARK_Lean_correspondence_complete'])
    # Retained fresh default run supplies this explicit mutation baseline.
    # Each of both maps'408 values is individually made false and unknown.
    fault_cases=0
    for field in ('conditions','conditional_conditions'):
        for key in register[field]:
            for value in (False,None):
                r=dict(register);r[field]=dict(register[field]);r[field][key]=value
                out=api['attach'](r,raw,ctx)
                check(not out['complete_native_capacity'] and out[field][key] is value)
                check(not out['components'] and all(v is None for v in out['coverage'].values()))
                fault_cases+=1
    for key in ('evaluated_predicates_pass','conditional_arithmetic_pass',
                'selected_register_interfaces_capacity_established','selected_GGC_event_partition_closed',
                'selected_collector_indexed_storage_capacity_established'):
        r=dict(register);r[key]=False
        check(not api['attach'](r,raw,ctx)['complete_native_capacity'])
    bad=dict(register);bad['conditions']=dict(register['conditions']);bad['conditions'].pop(next(iter(bad['conditions'])))
    rejects(lambda:api['attach'](bad,raw,ctx))
    bad=dict(register);bad['conditions']=dict(register['conditions']);bad['conditions'][next(iter(bad['conditions']))]=1
    rejects(lambda:api['attach'](bad,raw,ctx))
    rejects(lambda:api['attach'](register,raw+b' ',ctx))
    # Exact runtime graph comparison is stronger than matching C/N or maxima.
    for kind in ('source_counts','environment','argv','path_bytes'):
        bad=copy.deepcopy(register);g=bad['predecessor_result']['selected_native_invocation']
        if kind=='source_counts':g['source_counts']['output_calls']+=1
        elif kind=='environment':g['processes'][0]['environment']['LANG']='C.UTF-8'
        elif kind=='argv':g['processes'][0]['argv'].append('-g')
        else:g['path_bytes']=512
        rejects(lambda:api['attach'](bad,raw,ctx))
    # Pure binder compiler arithmetic: fail the first-collection prerequisite.
    g=register['predecessor_result']['selected_native_invocation']
    checksum=copy.deepcopy(register['predecessor_result']['core_result']['accepted_output_binder_checksum'])
    checksum['first_collection_threshold']=checksum['universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection']
    check(not ctx.shells['binder_compiler'](g,checksum)['capacity_established'])
    rejects(lambda:ctx.assembler['numeric'](-1));rejects(lambda:ctx.assembler['numeric'](2**32))
    for value in (0,1,2**31-1,2**31,2**32-1):
        q=ctx.assembler['numeric'](value)
        check(q['output_bytes']==4 and q['decimal_digits']<=10 and q['operand_recursion_depth']<=2)
    # Fresh non-Hello inputs exercise source-sensitive composition and growth.
    prefix=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    suffix=b'\nend Main;\n'
    sources=[('mixed',prefix+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("a""b"); null;'+suffix),
             ('wide',prefix+b'Silver_IO.Put_Line ("'+b'X'*8192+b'");'+suffix),
             ('many',prefix+b'Silver_IO.Put ("");\n'*5000+suffix)]
    records=[]
    scratch=REPO/'tmp';scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='native-completion-check-',dir=scratch) as directory:
        for name,source in sources:
            path=Path(directory)/(name+'.adb');path.write_bytes(source)
            out=api['evaluate'](REPO/'docs/evidence/retained-literal-pipeline-20261018/selected-route.json',ctx,path)
            check(out['complete_native_capacity'] and not out['native_residuals'])
            check(out['source']==api['identity'](source) and len(out['conditions'])==475)
            check(out['components']['Ada']['exact_reconciled_fixed_census_rows']==120)
            check(out['register_result']['selected_positive_GGC_events_upper']==
                out['register_result']['predecessor_result']['selected_positive_GGC_events_upper']+4)
            records.append(dict(case=name,source=out['source'],counts=out['source_counts'],
                predicates=len(out['conditions']),complete_native_capacity=True,
                corrected_GGC_events=out['register_result']['selected_positive_GGC_events_upper']))
        invalid=Path(directory)/'invalid.adb';invalid.write_bytes(prefix+b'null;'+suffix)
        rejects(lambda:api['evaluate'](REPO/'docs/evidence/retained-literal-pipeline-20261018/selected-route.json',ctx,invalid))
    result=dict(checks=checks,individual_predecessor_fault_cases=fault_cases,
        fresh_additional_source_cases=records,default_baseline='retained fresh result.json; used only for explicit mutation probes',
        native_tool_executions=0,elapsed_seconds=time.perf_counter()-start)
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(checks=checks,elapsed_seconds=result['elapsed_seconds'])))


if __name__=='__main__':main()
