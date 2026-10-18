#!/usr/bin/env python3
"""Exercise the aggregate's actual-input joins and conditional conjunction."""
import argparse
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile

HERE=Path(__file__).resolve().parent


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ada-root',type=Path,required=True)
    p.add_argument('--frontend-packet',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    spec=importlib.util.spec_from_file_location('pipeline',HERE/'compose.py')
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    context=m.Context(a.ada_root,a.frontend_packet)
    fixture=m.read(HERE/'fixture.json')
    # Resolve caller file references before moving a descriptor to scratch.
    for key in ('source','native_descriptor','datarep_descriptor'):
        fixture[key]=str((HERE/fixture[key]).resolve())
    fixture['shared_inputs']={k:str((HERE/v).resolve()) for k,v in fixture['shared_inputs'].items()}
    rows=[]
    with tempfile.TemporaryDirectory(prefix='silver-null-pipeline-check-') as td:
        td=Path(td); descriptor=td/'descriptor.json';source=td/'main.adb'
        original=Path(fixture['source']).read_bytes()
        variants={
            'retained':original,
            'case_CRLF':original.upper().replace(b'\n',b'\r\n'),
            'comments_above_old_cap':b'-- ordinary comment\n'*300+original,
            'more_physical_lines':b'\n'*2000+original,
            'column_rejected':b'--'+b'a'*32764+b'\n'+original,
        }
        for name,raw in variants.items():
            descriptor.write_text(json.dumps(fixture));source.write_bytes(raw)
            result=m.evaluate(descriptor,context,source)
            expected=name!='column_rejected'
            assert result['evaluated_predicates_pass']==expected,(name,result['failed_obligations'])
            assert result['open_obligations']==[]
            assert result['whole_null_pipeline_capacity_established']==expected
            if expected:
                assert result['obligations']['Why_core']['source_counts']['W']==10
                assert result['obligations']['Why_core']['A_Main']==39
                assert result['obligations']['producer_ALI_GG']['ALI_file_bytes']==29622804
                assert result['obligations']['native_split_option_delta']['Main_ALI_bytes']==399
                launch=result['obligations']['unified_launch_descriptor']
                assert launch['conditions']['common_temporary_root_width']
                assert launch['launch_graph']['process_ID_decimal_width_upper']==10
                for phase in launch['launch_graph']['light']:
                    compact=phase['options_content'].encode()
                    name=hashlib.sha1(compact).hexdigest()[:8]+'.tmp'
                    assert Path(phase['options_path']).name==name
                    assert '-gnates='+phase['options_path'] in phase['argv']
                    assert phase['options_identity']==m.identity(compact+b'\n')
                    if phase['phase']=='phase2':
                        for settings in json.loads(compact)['file_specific'].values():
                            args=settings['why3_args']
                            assert args[args.index('-j')+1]==str(fixture['runtime']['workers'])
                assert all(row['semantic_payload_unchanged'] and row['aligned_extent']==8192
                           for row in launch['parent_configuration_projection'].values())
                assert result['native_tool_executions']==0
            rows.append(dict(case=name,source_bytes=len(raw),evaluated_predicates_pass=expected,
                             failed_obligations=result['failed_obligations']))
        modified=copy.deepcopy(fixture);modified['runtime']['workers']=3
        descriptor.write_text(json.dumps(modified));source.write_bytes(original)
        result=m.evaluate(descriptor,context,source)
        assert result['whole_null_pipeline_capacity_established']
        phases=result['obligations']['unified_launch_descriptor']['launch_graph']['light']
        assert Path(phases[0]['options_path']).name=='00af4613.tmp'
        for settings in json.loads(phases[1]['options_content'])['file_specific'].values():
            args=settings['why3_args']
            assert args[args.index('-j')+1]=='3'
        assert phases[1]['options_hash_input_sha1']==hashlib.sha1(phases[1]['options_content'].encode()).hexdigest()
        assert '-gnates='+phases[1]['options_path'] in phases[1]['argv']
        rows.append(dict(case='worker_options_binding',workers=3,
                         phase2_options_path=phases[1]['options_path']))
        for name,field,value,expected_failure in [
            ('worker_overflow','workers',2**30,'idle_why3server'),
            ('socket_directory_mismatch','socket_directory','/tmp','idle_why3server'),
            ('page_overflow','host_page_bytes',2**62,'linker'),
            ('binder_path_width','binder_source_directory','/tmp/short','binder_generation_and_fixed_compiler')]:
            modified=copy.deepcopy(fixture);modified['runtime'][field]=value
            descriptor.write_text(json.dumps(modified));source.write_bytes(original)
            result=m.evaluate(descriptor,context,source)
            assert expected_failure in result['failed_obligations']
            rows.append(dict(case=name,failed_obligations=result['failed_obligations']))
        for name,raw in [('VT_rejected',b'\x0b'+original),('syntax_rejected',original.replace(b'null;',b'raise;'))]:
            descriptor.write_text(json.dumps(fixture));source.write_bytes(raw)
            try:m.evaluate(descriptor,context,source)
            except ValueError as error:rows.append(dict(case=name,rejected=str(error)))
            else:raise AssertionError(name)
        modified=copy.deepcopy(fixture);bad=td/'bad.adc';bad.write_bytes(b'pragma SPARK_Mode(On);\n')
        modified['shared_inputs']['configuration']=str(bad);descriptor.write_text(json.dumps(modified));source.write_bytes(original)
        try:m.evaluate(descriptor,context,source)
        except ValueError as error:rows.append(dict(case='configuration_mismatch',rejected=str(error)))
        else:raise AssertionError('configuration mismatch')
    result=dict(cases=rows,case_count=len(rows),native_tool_executions=0,
                all_checks_pass=True,conditional_null_conjunction_checked=True)
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(cases=len(rows),all_checks_pass=True,native_tool_executions=0)))


if __name__=='__main__':main()
